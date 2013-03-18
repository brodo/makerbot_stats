#!/usr/bin/env coffee

S3GParser
=========
This module reads a raw S3G-Bytestream and converts it into Coffeescript objects. Each S3G packet
is converted into one object. This is based on the S3G protocol definition which you can find 
[here](https://github.com/makerbot/s3g/blob/master/doc/s3gProtocol.md). This parser only works
with packets on the host network.


S3GStateMachine
---------------

Superclass of `S3GHostStateMachine` and `S3GToolStateMachine`.

### constructor
The `@states` object contains most states as attrubutes. For more information on states,
see [s3g_states.coffee](s3g_states.html). `@constants` is used to map form the byte values  
(e.g. *\0xd5*) to the
respoective names (e.g. *PACKET*). The `@packet` object contains the information
about the packet which is currently being parsed. The `@callback` is called everytime a packet is
 ready and has the packet object as it's argument. 
    
    class S3GStateMachine
      constructor: (@states, @constants, @callback) ->
        @packet = null
        @requestParameters = null
        @responseParameters = null
        @parameterIndex = 0
        @buffer = null
        @positionInBuffer = 0
        @packetLength = 0
        @responseByteLengthArray = []
        @inSync = false
        


String parameters are directly saved as strings to the `@packet`

      handleStringParameter: (parameterType, parameterName, byte) ->
        @packet[parameterName] = "" unless @packet[parameterName]?
        if byte == 0
          @parameterIndex += 1
        else
          @packet[parameterName] += String.fromCharCode(byte)

If the parameter is a byte array then it added appended to the `@packet` as a base64 encoded string. 

      handleByteParameter: (parameterType, parameterName, byte) ->
        parameterSize = if @packet.LENGTH? then @packet.LENGTH else @responseByteLengthArray.shift()
        if parameterSize == 0
          @parameterIndex += 1
        if @positionInBuffer == 0 then @buffer = new Buffer(parameterSize)
        @buffer[@positionInBuffer] = byte
        @positionInBuffer += 1
        if @positionInBuffer == parameterSize
          @parameterIndex += 1
          @positionInBuffer = 0
          @packet[parameterName] = @buffer.toString('base64')

      handleNumberParameter: (parameterType, parameterName, byte) ->
        parameterSize = @constants.numberTypes[parameterType].size
        if @positionInBuffer == 0 then @buffer = new Buffer(parameterSize)
        @buffer[@positionInBuffer] = byte
        @positionInBuffer += 1
        if @positionInBuffer == parameterSize
          @parameterIndex += 1
          @positionInBuffer = 0
          methodName = "read#{parameterType}"
          parameterValue = @buffer[methodName](0)
          @packet[parameterName] = parameterValue

      handleUnknownParameter: (byte) ->
        parameterSize = @packetLength
        if @positionInBuffer == 0 then @buffer = new Buffer(parameterSize)
        @buffer[@positionInBuffer] = byte
        @positionInBuffer += 1
        if @positionInBuffer == parameterSize
          @packet["UNKNOWN_PARAMETERS"] = @buffer.toString('base64')





S3GHostStateMachine
-------------------
This class implements a state machine which can handle packets in the host network.
The host packets look like this:

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

The initial state of a host state machine is *WAITING*
  
    class S3GHostStateMachine extends S3GStateMachine 
      constructor: (states, constants, callback) ->
        super(states, constants, callback)
        @state = "WAITING"
        @toolStateMachine = null
        @responseParametersArray = []

### parse
Takes a byte from the FIFO and returns nothing. Manages `@state` and and `@packet`.
*"WAITING"* is the initial state and the state we enter after each packet. This might be the 
**first** byte of a packet.

      parse: (byte) ->
        if @state == "WAITING"
          if byte == @constants.byteNames.OTHER.PACKET
            @packet = {}
            @state = "LENGTH"
            @packetLength = 0
            @parameterIndex = 0
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
          code = @constants.nameForHostByte(byte)
          if not code?
            @state = "UNKNOWN_PARAMETERS"
            return
          if @constants.isHostCommand(code)
            if code == "INIT" then @inSync = true
            @requestParameters = null
            @packet.COMMAND = code
            if @states[code].parameters?
              @requestParameters = @states[code].parameters
              @state = "REQUEST_PARAMETERS"
            else
              @state = if @packetLength == 1 then "CHECKSUM" else "UNKNOWN_PARAMETERS"
            @responseParameters = @states[code]?.responseParameters
            if @responseParameters?
              @responseParametersArray.push(@responseParameters)
          else
            @packet.RESPONSE = code
            if @responseParametersArray.length > 0
              @responseParameters = @responseParametersArray[0]
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
4. Tool Querys

The sizes of the integers are taken from `numberTypes`. The size of the strings is determinded
by the occurence of the first null byte. The size of byte arrays is read from the `LENGTH`
parameter. *Every parameter which specifies the length of a byte array must be called `LENGTH`.*

        if @state == "REQUEST_PARAMETERS" or @state == "RESPONSE_PARAMETERS"
          if @state == "REQUEST_PARAMETERS"
            parameterInfos = @requestParameters?[@parameterIndex] 
          if @state == "RESPONSE_PARAMETERS"
            parameterInfos = @responseParameters?[@parameterIndex]
          parameterName = Object.keys(parameterInfos)[0]
          parameterType = parameterInfos[parameterName]
          if parameterType == "String"
            @handleStringParameter(parameterType, parameterName, byte)
          else if parameterType == "Bytes"
            @handleByteParameter(parameterType, parameterName, byte)

The parameter type "ToolQuery" only exists in the `TOOL_QUERY` command. It contains the payload 
of a tool network packet. This means it contains the the command and the command parameters,
 but not the tool id. 

          else if parameterType == "ToolQuery"
            @toolStateMachine = new S3GToolStateMachine(@states, @constants,
              (toolPacket) =>
                @packet.TOOL_PACKET = toolPacket
                @responseParameters = @toolStateMachine.responseParameters
                @responseParametersArray.push(@responseParameters)
                @state = "CHECKSUM"
              )
            @state = "TOOL_PARAMETER"
            @toolStateMachine.parse(@packet.TOOL_INDEX)
            @toolStateMachine.parse(byte)

The parameter type "ToolPayload" only exists in the `TOOL_ACTION_COMMAND` command. It contains 
the parameters of a tool network packet. This means it contains the command parameters, but not 
the command itself and also not the tool id.

          else if parameterType == "ToolPayload"
            @toolStateMachine = new S3GToolStateMachine(@states, @constants,
              (toolPacket) =>
                @packet.TOOL_PACKET = toolPacket
                @responseParameters = @toolStateMachine.responseParameters
                @responseParametersArray.push(@responseParameters)
                @state = "CHECKSUM"
            )
            @toolStateMachine.parse(@packet.TOOL_ID)
            @toolStateMachine.parse(@packet.ACTION_COMMAND)
            @toolStateMachine.parse(byte)
            @state = "TOOL_PARAMETER"
          else
            @handleNumberParameter(parameterType, parameterName, byte)

          if @state == "REQUEST_PARAMETERS" and @parameterIndex == @requestParameters.length
            @state = "CHECKSUM"
            if @responseParameters?
              responseValues = (param[key] for key of param for param in @responseParameters)
              flatValues = [].concat.apply([], responseValues)
              if 'Bytes' in flatValues and @packet.LENGTH?
                @responseByteLengthArray.push(@packet.LENGTH)
                
            @requestParameters = null
          if @state == "RESPONSE_PARAMETERS" and @parameterIndex == @responseParameters.length
            @state = "CHECKSUM"
            @responseParameters = null
            @responseParametersArray.shift()
            return

In case there are no parameters specified in `@states` but there are parameters nevertheless,
the `PAYLOAD` attribute is added to `@packet` with the base64 encoded payload. 

        if @state == "UNKNOWN_PARAMETERS"
          @handleUnknownParameter(byte)
          @responseParametersArray = []
          @responseByteLengthArray = []
          if @positionInBuffer == @packetLength
            @state = "CHECKSUM"
            @positionInBuffer = 0
            @parameterIndex = 0
          return
        if @state == "TOOL_PARAMETER"
          @toolStateMachine.parse(byte)
          return

Now we are at the **last** byte in the packet. The checksum is ignored - we can't do anything 
about broken packages anyway.

        if @state == "CHECKSUM"
          @callback(@packet) if @packet?
          @state = "WAITING"
          return


       
S3GToolStateMachine
-------------------
This class implements a state machine which can handle packets in the tool network.
The tool packets look like this:

```
+---------+---------+-----------+
| TOOL ID | COMMAND | ARGUMENTS |
+---------+---------+-----------+
```

      class S3GToolStateMachine extends S3GStateMachine
        constructor: (states, constants, callback) ->
          @state = "TOOL_ID"
          super(states, constants, callback)
        parse: (byte) ->
          if @state == "TOOL_ID"
            @packet = {}
            @packet.TOOL_ID = byte
            @state = "COMMAND"
            return
          if @state == "COMMAND"
            code = @constants.nameForToolByte(byte)
            @packet.COMMAND = code
            @responseParameters = states[code]?.responseParameters
            @requestParameters = states[code]?.requestParameters
            if @requestParameters?
              @state = "PARAMETERS" 
            else
              @callback(@packet)
            return
          if @state == "PARAMETERS"
            parameterInfos = @requestParameters?[@parameterIndex] 
            parameterName = Object.keys(parameterInfos)[0]
            parameterType = parameterInfos[parameterName]
            if parameterType == "String"
              @handleStringParameter(parameterType, parameterName, byte)
            else if parameterType == "Bytes"
              @handleByteParameter(parameterType, parameterName, byte)
            else
              @handleNumberParameter(parameterType, parameterName, byte)
            if @parameterIndex == @requestParameters.length
              @state = "TOOL_ID"
              @callback(@packet)



        
Running from the Command line
-----------------------------

The parser can be run directly form the command line and in this case it whill just print out
the packages. Great for debugging!
 
    if require.main == module
        constants = require("./s3g_constants")
        states = require("./s3g_states")



        s3ghsm = new S3GHostStateMachine(states, constants,
          (packet) -> 
           console.log(packet)
        )

        fs = require('fs')
        fileStream = fs.createReadStream("serialdata/makerbot.log", {bufferSize: 10})
        fileStream.on('data', (data) ->
          for byte in data
            s3ghsm.parse(byte)
        )
        