S3GParser
=========

This module reads a raw S3G-Bytestream and converts it into Coffeescript objects. Each S3G packet
is converted into one object.



S3GHostStateMachine
-------------------


### Constructor
The `@states` object contains all possible states as attrubutes. For more information on  states,
see below. `@constants` is used to map form the byte values  (e.g. *\0xd5*) to the
respoective names (e.g. *PACKET_START*). The `@currentPacket` object contains the information
about the packet which is currently being parsed. The `@callback` is called everytime a packet is
 ready and has one argument  which contains the packet. 

    #!/usr/bin/env coffee
    class S3GHostStateMachine
      constructor: (@states, @constants, @callback) ->
        @state = @states.WAITING
        @currentPacket = {}
      read: (byte) ->

If the current parameter index exists, it means that the current byte is part of a parameter.
        
        if @state.currentParameterIndex?
            parameterInfos = @state.parameter[@state.currentParameterIndex]
            parameterName = Object.keys(parameterInfos)[0]
            parameterType = parameterInfos[parameterName]
            parameterSize = @constants.datatypes[parameterType].size
            @state.buffer = [] unless @state.buffer? 
            @state.buffer.push(byte)
            if @state.buffer.size == parameterSize
              # TODO: Add parameter to @currentPacket
            return 

        possibleTransitions = @state.transitions
        for transition in possibleTransitions
            if transition == @constants.nameForByte(byte)
                @state = @states[transition]
                @currentPacket.name = @state unless @state == @states.PACKET
        if @state.parameter?
            @state.currentParameterIndex = 0
###

States
------
Contains all the states the S3G protocol can be in.

    states =
      WAITING:
        transitions:
           ["PACKET_START"]
      PACKET:
        parameter:
                [ PACKET_LENGTH: "uint8",
                  PACKET_PAYLOAD : "payload" ]
            transitions:
              ["HOST_QUERY_COMMANDS", "HOST_ACTION_COMMANDS"] 
      GET_VERSION:
            parameter:
                [ HOST_VERSION: "uint16" ]
            transitions:
              [GET_VERSION_RESPONSE]
        GET_VERSION_RESPONSE
          parameter:
            [ FIRMWARE_VERSION: "uint16" ]
          transitions:
            ["WAITING"]
        INIT: true # No argument or response
        
Running from the Command line
-----------------------------

The parser can be run directly form the command line and in this case it whill just print out
the packages. Great for debugging!
 
    if require.main == module
        constants = require("./s3g_constants")

        s3ghsm = new S3GHostStateMachine(states, constants, (packet) -> console.log packet))
        fs = require('fs')
    
        writeFileStream = fs.createReadStream("serialdata/host.log", {bufferSize: 10})
        outputFileStream.on('data', (data) ->
            s3ghsm.read(byte) for byte in data 
        )
        