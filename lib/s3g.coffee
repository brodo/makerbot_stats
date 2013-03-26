#!/usr/bin/env coffee

# S3GParser
# =========
# This module reads a raw S3G-Bytestream and converts it into Coffeescript objects. Each S3G packet
# is converted into a `RawPacket` first. Then it is analyzed and a `RequestPacket` or a 
# `ResponsePacket` is created out of the `RawPacket`.
# This is based on the S3G protocol definition which you can find 
# [here](https://github.com/makerbot/s3g/blob/master/doc/s3gProtocol.md). This parser only works
# with packets on the host network.

# Includes
# --------

s3g_constants = require('./s3g_constants')
s3g_states = require('./s3g_states')

# Global Variables
# ----------------
UnansweredPackageResponseQueue = []
ResponseBufferQueue = []
PacketStart = s3g_constants.byteNames.Other.Packet

# DTraceOutputStateMachine
# -------------------
# This class implements a state machine which can handle the DTrace output:

# ```
# +-----------+--------+---------+
# | BEGINDATA | LENGTH | PAYLOAD |
# +-----------+--------+---------+
# ```

class DTraceOutputStateMachine
  constructor: (@callback) ->
    @state = "WAITING"
    @startString = "BEGINDATA"
    @bufferSize = @startString.length
    @charBuffer = ""
    @sizeLength = 5 #The size field is 5 bytes long
    @sizeStr = ""
    @contentLength = 0
    @currentPosition = 0
  read: (byte) =>
    switch @state
      when "WAITING"
        if @charBuffer.length == @bufferSize
          # Shift the buffer one character to the right.
          char = String.fromCharCode(byte)
          @charBuffer = @charBuffer[1..] 
          @charBuffer += String.fromCharCode(byte)
        else
          @charBuffer += String.fromCharCode(byte)
        if @charBuffer == @startString
          @state = "LENGTH"
          @charBuffer = ""
      when "LENGTH"
        @sizeStr += String.fromCharCode(byte)
        if @sizeStr.length == @sizeLength
          @contentLength = parseInt(@sizeStr, 10)
          @sizeStr = ""
          @state = "CONTENT"
      when "CONTENT"
        @callback(byte)
        @currentPosition += 1
        if @currentPosition == @contentLength
          @currentPosition = 0
          @contentLength = 0
          @state = "WAITING"




# S3GPacketStateMachine
# -------------------
# This class implements a state machine which can handle packets in the host network.
# The host packets look like this:

# ```
# +------------+--------+---------+----------+
# | START BYTE | LENGTH | PAYLOAD | CHECKSUM |
# +------------+--------+---------+----------+
# ```


class S3GPacketStateMachine
  buffer: []
  state: "WAITING"
  length: 0
  # `@callback` gets called with the buffer, when a packet is ready. 
  constructor: (@callback) ->
  read: (byte) ->
    switch @state
      when "WAITING" 
        if byte == PacketStart
          @state = "LENGTH"
          @buffer = []
      when "LENGTH"
        @length = byte
        @state = "PAYLOAD"
      when "PAYLOAD"
        @buffer.push(byte)
        if @buffer.length == @length
          @state = "CHECKSUM"
      when "CHECKSUM"
        if byte == @calculateChecksum() then @callback(@buffer)
        @state = "WAITING"
  # This Method calculates the iButton/Maxim CRA of the payload.
  # It was taken from 
  # [The S3G Python library](https://github.com/makerbot/s3g/blob/master/makerbot_driver/Encoder/Crc.py)
  calculateChecksum: ->
    crctab = [
      0, 94, 188, 226, 97, 63, 221, 131, 194, 156, 126, 32, 163, 253, 31, 65,
      157, 195, 33, 127, 252, 162, 64, 30, 95, 1, 227, 189, 62, 96, 130, 220,
      35, 125, 159, 193, 66, 28, 254, 160, 225, 191, 93, 3, 128, 222, 60, 98,
      190, 224, 2, 92, 223, 129, 99, 61, 124, 34, 192, 158, 29, 67, 161, 255,
      70, 24, 250, 164, 39, 121, 155, 197, 132, 218, 56, 102, 229, 187, 89, 7,
      219, 133, 103, 57, 186, 228, 6, 88, 25, 71, 165, 251, 120, 38, 196, 154,
      101, 59, 217, 135, 4, 90, 184, 230, 167, 249, 27, 69, 198, 152, 122, 36,
      248, 166, 68, 26, 153, 199, 37, 123, 58, 100, 134, 216, 91, 5, 231, 185,
      140, 210, 48, 110, 237, 179, 81, 15, 78, 16, 242, 172, 47, 113, 147, 205,
      17, 79, 173, 243, 112, 46, 204, 146, 211, 141, 111, 49, 178, 236, 14, 80,
      175, 241, 19, 77, 206, 144, 114, 44, 109, 51, 209, 143, 12, 82, 176, 238,
      50, 108, 142, 208, 83, 13, 239, 177, 240, 174, 76, 18, 145, 207, 45, 115,
      202, 148, 118, 40, 171, 245, 23, 73, 8, 86, 180, 234, 105, 55, 213, 139,
      87, 9, 235, 181, 54, 104, 138, 212, 149, 203, 41, 119, 244, 170, 72, 22,
      233, 183, 85, 11, 136, 214, 52, 106, 43, 117, 151, 201, 74, 20, 246, 168,
      116, 42, 200, 150, 21, 75, 169, 247, 182, 232, 10, 84, 215, 137, 107, 53
    ]
    val = 0
    for x in @buffer
      val = crctab[val ^ x]
    return val

class Packet
  parse: (parameters, payload) ->
    offset = 1 # Current position in the array
    unless parameters then return
    for parameter in parameters
      [name, type] for name, type of parameter
      # The offset is not updated at "Byte", "ToolQuery" and "ToolArguments" because parameters
      # of these types always are the last parameter in the buffer.
      switch type
        when "String" then offset = @readString(offset, payload, name)
        when "Bytes" then this[name] = payload[offset..] 
        when "ToolQuery"
          @readToolQuery(offset, payload)
        when "ToolArguments" then @readToolArguments(offset, payload)
        else offset = @readNumber(offset, payload, name, type)
  readString: (offset, payload, name) ->
    restBuffer = payload[offset..-1]
    # get all bytes until the zero-byte
    stringBuffer = restBuffer[0..restBuffer.indexOf(0)-1] 
    offset += (stringBuffer.length)
    if stringBuffer.length > 0
      str = (String.fromCharCode(byte) for byte in stringBuffer).reduce((a,b)-> a+b)
      this[name] = str
    return offset
  readNumber: (offset, payload, name, type) -> 
    parameterSize = s3g_constants.numberTypes[type].size
    buffer = new Buffer(payload[offset..(offset+parameterSize)])
    methodName = "read#{type}"
    this[name] = buffer[methodName](0)
    return (offset + parameterSize)
  # Reads a tool query parameter.
  # ```
  # +---------+---------+-----------+
  # | TOOL ID | COMMAND | ARGUMENTS |
  # +---------+---------+-----------+
  #              ^        ^ 
  #              |        | 
  #              +---+----+ 
  #                  |      
  #                  |      
  #               ToolQuery 
  # ```
  readToolQuery: (offset, payload) ->
    # Tool queries are always the last parameter.
    queryBytes = payload[offset..]
    # The first byte of the tool query is the command byte
    @ToolCommand = s3g_constants.nameForToolByte(queryBytes[0])
    # The `responseParameters` of the tool packet become the `responseParametres` of the host packet.
    @responseParameters = s3g_states[@ToolCommand].responseParameters
    toolParameters = s3g_states[@ToolCommand].parameters
    @parse(toolParameters, queryBytes[1..])
  # Reads a tool arguments parameter.
  # ```
  # +---------+---------+-----------+
  # | TOOL ID | COMMAND | ARGUMENTS |
  # +---------+---------+-----------+
  #                          ^ 
  #                          | 
  #                     ToolArguments                                                                     
  # ```
  readToolArguments: (offset, payload) ->
    # The `ActionCommand` is a normal integer parsed by `readToolQuery`, so we replace it by 
    # it's name.

    @ActionCommand = s3g_constants.nameForToolByte(@ActionCommand)
    @responseParameters = s3g_states[@ActionCommand].responseParameters
    @parse(s3g_states[@ActionCommand].parameters, payload)

# RequestPacket
# ---------------
# This class represents a packet for which it is not yet determined if it is a request or a response
class RequestPacket extends Packet
  constructor: (payload) ->
    @command = s3g_constants.nameForHostByte(payload[0])
    @responseParameters = s3g_states[@command].responseParameters
    @parse(s3g_states[@command].parameters, payload)
  expectsAnswer: ->
    @responseParameters?

# ResponsePacket
# ---------------
# This class represents a packet for which it is not yet determined if it is a request or a response
class ResponsePacket extends Packet
  constructor: (payload, parameters) ->
    @responseCode = s3g_constants.nameForHostByte(payload[0])
    @parse(parameters, payload)

requestPacketStateMachine = new S3GPacketStateMachine((buffer) -> 
  packet = new RequestPacket(buffer)
  if packet.expectsAnswer() then UnansweredPackageResponseQueue.push(packet.responseParameters)
  delete packet.responseParameters
  if module.exports.callback then module.exports.callback(packet) else console.log(packet)
  
)
responsePacketStateMachine = new S3GPacketStateMachine((buffer) ->
  # If there is no Unansered request, we don't know what this is the answer to
  if UnansweredPackageResponseQueue.length > 0
    packet = new ResponsePacket(buffer, UnansweredPackageResponseQueue.shift())
    if module.exports.callback then module.exports.callback(packet) else console.log(packet)
)

writeDTraceStateMachine = new DTraceOutputStateMachine(
  (byte) ->
    requestPacketStateMachine.read(byte)
)
readDTraceStateMachine = new DTraceOutputStateMachine(
  (byte) -> 
    responsePacketStateMachine.read(byte)
  )

module.exports.readRequestByte = writeDTraceStateMachine.read
module.exports.readResponsetByte = readDTraceStateMachine.read

# Running from the Command line
# -----------------------------

# The parser can be run directly form the command line and in this case it whill just print out
# the packages. Great for debugging!



if require.main == module
  fs = require('fs')
  requestFileStream = fs.createReadStream( "../serialdata/write", {bufferSize: 10})
  responseFileStream = fs.createReadStream("../serialdata/read", {bufferSize: 10})

  requestFileStream.on('data', (data) ->
    for byte in data
      writeDTraceStateMachine.read(byte)
  )  
  responseFileStream.on('data', (data) ->
    for byte in data
      readDTraceStateMachine.read(byte)
  )
