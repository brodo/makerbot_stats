states =
	WAITING:
		transitions:
			 ["PACKET_START"]
	PACKET_START:
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








    GET_AVAILABLE_BUFFER_SIZE:
         response:
              BUFFER_SIZE: "uint32"
    CLEAR_BUFFER: true # No argument or response
    ABORT_IMMEDIATELY: true # No argument or response
    PAUSE: true # No argument or response
    TOOL_QUERY: true # Not implemented, because I currently don't do tool stuff
    IS_FINISHED:
         response:
              IS_FINISHED: "uint8"
    READ_FROM_EEPROM:
         parameter:
              MEMORY_OFFEST: "uint16"
              NUMBER_OF_BYTES: "unit8"
         response:
              DATA:
                   type: "byte"
                   size: "parameter.NUMBER_OF_BYTES"
    WRITE_TO_EEPROM:
         parameter:
              MEMORY_OFFEST: "uint16"
              NUMBER_OF_BYTES: "unit8"
              DATA:
                   type: "byte"
                   size: "parameter.NUMBER_OF_BYTES"
         response:
              DATA:
                   type: "byte"
                   size: "NUMBER_OF_BYTES"
    CAPTURE_TO_FILE: 
         parameter:
              FILE_NAME: "string"
         response:
              SD_RESPONSE_CODE: "uint8"
    END_CAPTURE:
         response:
              BYTECOUNT: "uint32"
    PLAYBACK_CAPTURE: 
         parameter:
              FILE_NAME: "string"
         response:
              SD_RESPONSE_CODE: "uint8"
    RESET: true # No argument or response
    GET_NEXT_FILENAME: 
         parameter:
              RESTART_LISTING: "uint8"
         
    GET_BUILD_NAME: 20
    GET_EXTENDED_POSITION: 21
    EXTENDED_STOP: 22
    GET_MOTHERBOARD_STATUS: 23
    GET_BUILD_STATS: 24
    GET_COMMUNICATION_STATS: 25
    GET_ADVANCED_VERSION: 27


