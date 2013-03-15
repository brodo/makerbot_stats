S3GParser
=========

This module reads a raw S3G-Bytestream and converts it into Coffeescript objects. Each S3G packet
is converted into one object. This is based on the S3G protocol definition which you can find 
[here](https://github.com/makerbot/s3g/blob/master/doc/s3gProtocol.md). This parser only works
with packets on the host network.

S3GHostStateMachine
-------------------

This is the class which does pretty much everything in this module. It implements a state machine
which can handle packets in the host network. The tool network is ignored for now.


### constructor
The `@states` object contains most states as attrubutes. For more information on  states,
see below. `@constants` is used to map form the byte values  (e.g. *\0xd5*) to the
respoective names (e.g. *PACKET*). The `@packet` object contains the information
about the packet which is currently being parsed. The `@callback` is called everytime a packet is
 ready and has the packet object as it's argument. 

    #!/usr/bin/env coffee
    class S3GHostStateMachine
      constructor: (@states, @constants, @callback) ->
        @state = "WAITING"
        @packet = null
        @requestParameters = null
        @responseParameters = null
        @parameterIndex = 0
        @buffer = null
        @positionInBuffer = 0
        @packetLength = 0

### read
Takes a byte from the FIFO and returns nothing. Manages `@state` and and `@packet`.
Packets look like this:

```
+------------+--------+---------+----------+
| START BYTE | LENGTH | PAYLOAD | CHECKSUM |
+------------+--------+---------+----------+
```

If the packet was sent by the host the payload looks like this:

```
+--------------+------------+
| HOST COMMAND | PARAMETERS |
+--------------+------------+
```

If the packet was sent by the printer the payload looks like this:

```
+---------------+------------+
| RESPONSE CODE | PARAMETERS |
+---------------+------------+
```

*"WAITING"* is the initial state and the state we enter after each packet. This might be the 
**first** byte of a packet.

      read: (byte) ->
        if @state == "WAITING"
          if byte == @constants.byteNames.OTHER.PACKET
            @packet = {}
            @state = "LENGTH"
            @response = null
            @packetLength = 0
          return

This is the **second** byte in the packet.

        if @state == "LENGTH"
          @packetLength = byte
          @state = "COMMAND_OR_RESPONSE_BYTE"
          return

This is the **third** byte in the packet. It might be a host command or a response code from the
printer. If it is a host command we save the types of it's parameters and the types of the
parameters the response will have. If the `@packet.LENGTH` is not 1 and there are no parameters
saved for the command or response in `@states` that means that there are paremeters which are not
known.

        if @state == "COMMAND_OR_RESPONSE_BYTE"
          code = @constants.nameForByte(byte)
          if @constants.isHostCommand(code)
            @packet.command = code
            if @states[code].parameters?
              @requestParameters = @states[code].parameters
              @state = "REQUEST_PARAMETERS"
            else
              @state = if @packetLength == 1 then "CHECKSUM" else "UNKNOWN_PARAMETERS"
            @responseParameters = @states[code]?.responseParameters
          else
            @packet.response = code
            if @responseParameters?
              @state = "RESPONSE_PARAMETERS"
            else
              @state = if @packetLength == 1 then "CHECKSUM" else "UNKNOWN_PARAMETERS"
          return

The next bytes are the **forth and all following** bytes in the packet until the checksum. (aka 
**the parameters**) `@parameterIndex` is the index of the parameter we are currently in. 
`@positionInBuffer` marks the position *inside* one parameter. `@buffer` is the buffer where we put
all bytes of a parameter as they come in.

There are four three of parameters:

1. Integers (including bit fields)
2. Strings
3. Byte Arrays

The sizes of the integers are taken from `intTypes`. The size of the strings is determinded
by the occurence of the first null byte. The size of byte arrays is read from the `LENGTH`
parameter. *Every parameter which specifies the length of a buye array must be called `LENGTH`.*

        if @state == "REQUEST_PARAMETERS" or "RESPONSE_PARAMETERS"
          if @state == "REQUEST_PARAMETERS" then @requestParameters?[@parameterIndex] 
          if @state == "RESPONSE_PARAMETERS" then @responseParameters?[@parameterIndex]
          parameterName = Object.keys(parameterInfos)[0]
          parameterType = parameterInfos[parameterName]
          if parameterType == "String"
            @handleStringParameter(parameterType, parameterName)
          else if parameterType == "Byte"
            @handleByteParameter(parameterType, parameterName)
          else
            @handleIntParameters(parameterInfos)
          if @parameterIndex == @requestParameters.length
            @state = "CHECKSUM"
            if @state == "REQUEST_PARAMETERS"
              @requestParameters = null
            else
               @responseParameters = null
          return

In case there are no parameters specified in `@states` but there are parameters nevertheless,
the `PAYLOAD` attribute is added to `@packet` with the base64 encoded payload. 

        if @state == "UNKNOWN_PARAMETERS"

          return

Now we are at the **last** byte in the packet. The checksum is ignored - we can't do anything 
about broken packages anyway.

        if @state == "CHECKSUM"
          @callback(@packet) if @packet?
          @state = "WAITING"

String parameters are directly saved as strings to the `@packet`

      handleStringParameter: (parameterType, parameterName) ->
        @packet[parameterName] = "" unless @packet[parameterName]?
        if byte == 0
          @parameterIndex += 1
        else
          @packet[parameterName] += String.fromCharCode(byte)

If the parameter is a byte array then it added appended to the `@packet` as a base64 encoded string. 

      handleByteParameter: (parameterType, parameterName) ->
        parameterSize = @packet.LENGTH
        if @positionInBuffer == 0 then @buffer = new Buffer(parameterSize)
        @buffer[@positionInBuffer] = byte
        @positionInBuffer += 1
        if @positionInBuffer == parameterSize
          @parameterIndex += 1
          @positionInBuffer = 0
          @packet[parameterName] = @buffer.toString('base64')

      handleIntParameter: (parameterType, parameterName) ->
        parameterSize = @constants.intTypes[parameterType].size
        if @positionInBuffer == 0 then @buffer = new Buffer(parameterSize)
        @buffer[@positionInBuffer] = byte
        @positionInBuffer += 1
        if @positionInBuffer == parameterSize
          @parameterIndex += 1
          @positionInBuffer = 0
          @generateIntParameter(parameterType)

      handleUnknownParameter: () ->
        parameterSize = @packet.LENGTH

      generateIntParameter: (type) ->
        methodName = "read#{parameterType}"
        parameterValue = @buffer[methodName]()
        @packet[parameterName] = parameterValue




States
------
Contains all the states the S3G protocol can be in, besides the special states "WAITING", "PACKET", 
"COMMAND_OR_RESPONSE_BYTE", "REQUEST_PARAMETERS", "RESPONSE_PARAMETERS", "LENGTH" and
"CHECKSUM".

    states =
      GET_VERSION:
        parameters:
          [ HOST_VERSION: "UInt16" ]
        responseParameters:
          [ FIRMWARE_VERSION: "UInt16" ]              
      INIT: true # No argument or response
      GET_AVAILABLE_BUFFER_SIZE:
        responseParameters:
          BUFFER_SIZE: "UInt32"
      CLEAR_BUFFER: true # No argument or response
      ABORT_IMMEDIATELY: true # No argument or response
      PAUSE: true # No argument or response
      TOOL_QUERY: true # Not implemented, because I currently don't do tool stuff
      IS_FINISHED:
        responseParameters:
          IS_FINISHED: "UInt8"
      READ_FROM_EEPROM:
        parameters:
          MEMORY_OFFEST: "UInt16"
          LENGTH: "UInt8"
        responseParameters:
          DATA: "Bytes"
      WRITE_TO_EEPROM:
        parameters:
          MEMORY_OFFEST: "UInt16"
          NUMBER_OF_BYTES: "UInt8"
          DATA: "Bytes"
        responseParameters:
          DATA: "Bytes"
      CAPTURE_TO_FILE: 
        parameters:
          FILE_NAME: "string"
        responseParameters:
          SD_RESPONSE_CODE: "UInt8"
      END_CAPTURE:
        responseParameters:
          BYTECOUNT: "UInt32"
      PLAYBACK_CAPTURE: 
        parameters:
          FILE_NAME: "String"
        responseParameters:
          SD_RESPONSE_CODE: "UInt8"
      RESET: true # No argument or response
      GET_NEXT_FILENAME: 
        parameters:
          RESTART_LISTING: "UInt8"
        responseParameters:
          SD_RESPONSE_CODE: "UInt8"
          NAME: "String"
      GET_BUILD_NAME:
        responseParameters:
          NAME: "String"
      GET_EXTENDED_POSITION:
        responseParameters:
          X_POSITION: "Int32"
          Y_POSITION: "Int32"
          Z_POSITION: "Int32"
          A_POSITION: "Int32"
          B_POSITIOM: "Int32"
          ENDSTOP_STATUS: "UInt16"
      EXTENDED_STOP:
        parameters:
          BITFIELD: "UInt8"
        responseParameters:
          RESERVED: "UInt8"
      GET_MOTHERBOARD_STATUS:
        responseParameters:
          BITFIELD: "UInt8"
      GET_BUILD_STATS:
        responseParameters:
          BUILD_STATE: "UInt8"
          HOURS_ELAPSED: "UInt8"
          MINUTES_ELAPSED: "UInt8"
          LINE_NUMBER: "UInt32"
          RESERVED: "UInt32"
      GET_COMMUNICATION_STATS:
        responseParameters:
          PACKETS_RECEIVED: "UInt32"
          PACKETS_SENT: "UInt32"
          UNRESPONDED_PACKETS: "UInt32"
          RETRIES: "UInt32"
          PACKETS_RECEIVED: "UInt32"
      GET_ADVANCED_VERSION:
        parameters:
          HOST_VERSION: "UInt16"
        responseParameters:
          FIRMWARE_VERSION: "UInt16"
          INTERNAL_VERSION: "UInt16"
          VARIANT: "UInt8"
          RESERVED1: "UInt8"
          RESERVED2: "UInt16"
      FIND_AXES_MINIMUMS:
        parameters:
          AXES: "UInt8"
          FEED_RATE: "UInt32"
          TIMEOUT: "UInt16"
      FIND_AXES_MAXIMUMS:
        parameters:
          AXES: "UInt8"
          FEED_RATE: "UInt32"
          TIMEOUT: "UInt16"
      DELAY:
        parameters:
          DELAY: "UInt32"
      CHANGE_TOOL:
        parameters:
          TOOL_ID: "UInt8"
      WAIT_FOR_TOOL_READY:
        parameters:
          TOOL_ID: "UInt8"
          DELAY: "UInt16"
          TIMEOUT: "UInt16"
      TOOL_ACTION_COMMAND:
        parameters:
          TOOL_ID: "UInt8"
          ACTION_COMMAND: "UInt8"
          LENGTH: "UInt8"
          TOOL_COMMAND: "Bytes"
      ENABLE_AXES:
        parameters:
          BITFIELD: "UInt8"
      QUEUE_EXTENDED_POINT:
        X_POSITION: "Int32"
        Y_POSITION: "Int32"
        Z_POSITION: "Int32"
        A_POSITION: "Int32"
        B_POSITIOM: "Int32"
        FEED_RATE: "UInt32"
      SET_EXTENDED_POSITION:
        parameters:
          X_POSITION: "Int32"
          Y_POSITION: "Int32"
          Z_POSITION: "Int32"
          A_POSITION: "Int32"
          B_POSITIOM: "Int32"
      WAIT_FOR_PLATFORM_READY:
        parameters:
          TOOL_ID: "UInt8"
          DELEY: "UInt16"
          TIMEOUT: "UInt16"
      QUEUE_EXTENDED_POINT_NEW:
        parameters:
          X_POSITION: "Int32"
          Y_POSITION: "Int32"
          Z_POSITION: "Int32"
          A_POSITION: "Int32"
          B_POSITIOM: "Int32"
          MOVEMENT_DURATION: "UInt32"
          BITFIELD: "UInt8"
      STORE_HOME_POSITIONS:
        parameters:
          BITFIELD: "UInt8"
      RECALL_HOME_POSITIONS:
        parameters:
          BITFIELD: "UInt8"
      SET_POT_VALUE:
        parameters:
          AXIS_VALUE: "UInt8"
          VALUE: "UInt8"
      SET_RGB_LED:
        parameters:
          RED: "UInt8"
          GREEN: "UInt8"
          BLUE: "UInt8"
          BLINK_RATE: "UInt8"
          RESERVED: "UInt8"
      SET_BEEP:
        parameters:
          FREQUENCY: "UInt16"
          BUZZ_LENGTH: "UInt16"
          RESERVED: "UInt8"
      WAIT_FOR_BUTTON:
        parameters:
          BUTTON_BITFIELD: "UInt8"
          TIMEOUT: "UInt16"
          OPTIONS_BITFIELD: "UInt8"
          














        
Running from the Command line
-----------------------------

The parser can be run directly form the command line and in this case it whill just print out
the packages. Great for debugging!
 
    if require.main == module
        constants = require("./s3g_constants")

        s3ghsm = new S3GHostStateMachine(states, constants, (packet) -> console.log(packet))
        fs = require('fs')
    
        fileStream = fs.createReadStream("serialdata/makerbot.log", {bufferSize: 10})
        fileStream.on('data', (data) ->
            s3ghsm.read(byte) for byte in data 
        )
        