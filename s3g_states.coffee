module.exports  =
    GET_VERSION:
      parameters:
        [ {HOST_VERSION: "UInt16LE"} ]
      responseParameters:
        [ {FIRMWARE_VERSION: "UInt16LE"} ]              
    INIT: true # No argument or response
    GET_AVAILABLE_BUFFER_SIZE:
      responseParameters:
        [ {BUFFER_SIZE: "UInt32LE"} ]
    CLEAR_BUFFER: true # No argument or response
    ABORT_IMMEDIATELY: true # No argument or response
    PAUSE: true # No argument or response
    TOOL_QUERY:  
      parameters:
        [ {TOOL_INDEX: "UInt8"},
          {PAYLOAD: "ToolQuery"}]
    IS_FINISHED:
      responseParameters:
        [ {IS_FINISHED: "UInt8"} ]
    READ_FROM_EEPROM:
      parameters:
        [ {MEMORY_OFFEST: "UInt16LE"},
          {LENGTH: "UInt8"} ]
      responseParameters:
        [ {DATA: "Bytes"} ]
    WRITE_TO_EEPROM:
      parameters:
        [ {MEMORY_OFFEST: "UInt16LE"},
          {NUMBER_OF_BYTES: "UInt8"},
          {DATA: "Bytes"} ]
      responseParameters:
        [ {DATA: "Bytes"} ]
    CAPTURE_TO_FILE: 
      parameters:
        [ {FILE_NAME: "String"} ]
      responseParameters:
        [ {SD_RESPONSE_CODE: "UInt8"} ]
    END_CAPTURE:
      responseParameters:
        [ {BYTECOUNT: "UInt32LE"} ]
    PLAYBACK_CAPTURE: 
      parameters:
        [ {FILE_NAME: "String"} ]
      responseParameters:
        [ {SD_RESPONSE_CODE: "UInt8"} ]
    RESET: true # No argument or response
    GET_NEXT_FILENAME: 
      parameters:
        [ {RESTART_LISTING: "UInt8"} ]
      responseParameters:
        [ {SD_RESPONSE_CODE: "UInt8"},
          {NAME: "String"}]
    GET_BUILD_NAME:
      responseParameters:
        {NAME: "String"}
    GET_EXTENDED_POSITION:
      responseParameters:
        [ {X_POSITION: "Int32LE"},
          {Y_POSITION: "Int32LE"},
          {Z_POSITION: "Int32LE"},
          {A_POSITION: "Int32LE"},
          {B_POSITION: "Int32LE"},
          {ENDSTOP_STATUS: "UInt16LE"} ]
    EXTENDED_STOP:
      parameters:
        [ {BITFIELD: "UInt8"} ]
      responseParameters:
        [ {RESERVED: "UInt8"} ]
    GET_MOTHERBOARD_STATUS:
      responseParameters:
        [ {BITFIELD: "UInt8"} ]
    GET_BUILD_STATS:
      responseParameters:
        [ {BUILD_STATE: "UInt8"},
          {HOURS_ELAPSED: "UInt8"},
          {MINUTES_ELAPSED: "UInt8"},
          {LINE_NUMBER: "UInt32LE"},
          {RESERVED: "UInt32LE"} ]
    GET_COMMUNICATION_STATS:
      responseParameters:
        [ {PACKETS_RECEIVED: "UInt32LE"},
          {PACKETS_SENT: "UInt32LE"},
          {UNRESPONDED_PACKETS: "UInt32LE"},
          {RETRIES: "UInt32LE"},
          {PACKETS_RECEIVED: "UInt32LE"}]
    GET_ADVANCED_VERSION:
      parameters:
        [ {HOST_VERSION: "UInt16LE"} ]
      responseParameters:
        [ {FIRMWARE_VERSION: "UInt16LE"},
          {INTERNAL_VERSION: "UInt16LE"},
          {VARIANT: "UInt8"},
          {RESERVED1: "UInt8"},
          {RESERVED2: "UInt16LE"} ]
    FIND_AXES_MINIMUMS:
      parameters:
        [ {AXES: "UInt8"},
          {FEED_RATE: "UInt32LE"},
          {TIMEOUT: "UInt16LE"} ]
    FIND_AXES_MAXIMUMS:
      parameters:
        [ {AXES: "UInt8"},
          {FEED_RATE: "UInt32LE"},
          {TIMEOUT: "UInt16LE"}]
    DELAY:
      parameters:
        [ {DELAY: "UInt32LE"} ]
    CHANGE_TOOL:
      parameters:
        [ {TOOL_ID: "UInt8"} ]
    WAIT_FOR_TOOL_READY:
      parameters:
        [ {TOOL_ID: "UInt8"},
          {DELAY: "UInt16LE"},
          {TIMEOUT: "UInt16LE"}]
    TOOL_ACTION_COMMAND:
      parameters:
        [ {TOOL_ID: "UInt8"},
          {ACTION_COMMAND: "UInt8"},
          {LENGTH: "UInt8"},
          {TOOL_COMMAND: "ToolPayload"}]
    ENABLE_AXES:
      parameters:
        [ {BITFIELD: "UInt8"} ]
    QUEUE_EXTENDED_POINT:
      [ {X_POSITION: "Int32LE"},
        {Y_POSITION: "Int32LE"},
        {Z_POSITION: "Int32LE"},
        {A_POSITION: "Int32LE"},
        {B_POSITION: "Int32LE"},
        {FEED_RATE: "UInt32LE"}]
    SET_EXTENDED_POSITION:
      parameters:
        [ {X_POSITION: "Int32LE"},
          {Y_POSITION: "Int32LE"},
          {Z_POSITION: "Int32LE"},
          {A_POSITION: "Int32LE"},
          {B_POSITION: "Int32LE"} ]
    WAIT_FOR_PLATFORM_READY:
      parameters:
        [ {TOOL_ID: "UInt8"},
          {DELEY: "UInt16LE"},
          {TIMEOUT: "UInt16LE"} ]
    QUEUE_EXTENDED_POINT_NEW:
      parameters:
        [ {X_POSITION: "Int32LE"},
          {Y_POSITION: "Int32LE"},
          {Z_POSITION: "Int32LE"},
          {A_POSITION: "Int32LE"},
          {B_POSITION: "Int32LE"},
          {MOVEMENT_DURATION: "UInt32LE"},
          {BITFIELD: "UInt8"} ]
    STORE_HOME_POSITIONS:
      parameters:
        [ {BITFIELD: "UInt8"} ]
    RECALL_HOME_POSITIONS:
      parameters:
        [ {BITFIELD: "UInt8"} ]
    SET_POT_VALUE:
      parameters:
        [ {AXIS_VALUE: "UInt8"},
          {VALUE: "UInt8"} ]
    SET_RGB_LED:
      parameters:
        [ {RED: "UInt8"},
          {GREEN: "UInt8"},
          {BLUE: "UInt8"},
          {BLINK_RATE: "UInt8"},
          {RESERVED: "UInt8"} ]
    SET_BEEP:
      parameters:
        [ {FREQUENCY: "UInt16LE"},
          {BUZZ_LENGTH: "UInt16LE"},
          {RESERVED: "UInt8"} ]
    WAIT_FOR_BUTTON:
      parameters:
        [ {BUTTON_BITFIELD: "UInt8"},
          {TIMEOUT: "UInt16LE"},
          {OPTIONS_BITFIELD: "UInt8"} ]
    DISPLAY_MESSAGE:
      parameters:
        [ {OPTIONS_BITFIELD: "UInt8"},
          {HORIZONTAL_POSITION: "UInt8"},
          {VERTICAL_POSITION: "UInt8"},
          {TIMEOUT: "UInt8"},
          {MESSAGE: "String"} ]
    SET_BUILD_PERCENT:
      parameters:
        [ {PERCENT: "UInt8"},
          {RESERVED: "UInt8"} ]
    QUEUE_SONG:
      parameters:
        [ {SONG_ID: "UInt8"} ]
    RESET_TO_FACTORY:
      parameters:
        [ {RESERVED: "UInt8"} ]
    BUILD_START_NOTIFICATION:
      parameters:
        [ {RESERVED: "UInt32LE"},
          {BUILD_NAME: "String"} ]
    BUILD_END_NOTIFICATION:
      parameters:
        parameters:
         [ {RESERVED: "UInt8"} ]
    QUEUE_EXTENDED_POINT_ACCELERATED:
      parameters:
        [ {X_POSITION: "Int32LE"},
          {Y_POSITION: "Int32LE"},
          {Z_POSITION: "Int32LE"},
          {A_POSITION: "Int32LE"},
          {B_POSITION: "Int32LE"},
          {DDA_FEEDRATE_IN_STEPS: "UInt32LE"},
          {AXES_BITFIELD: "UInt8"},
          {DISTANCE: "FloatLE"},
          {FEEDRATE_TIMES_64: "UInt16LE"} ]
    X3G_VERSION:
      parameters:
        [ {X3G_HIGH: "UInt8"},
          {X3G_LOW: "UInt8"},
          {RESERVED: "UInt8"},
          {RESERVED2: "UInt32LE"},
          {BOT_TYPE: "UInt16LE"},
          {RESERVED3: "UInt16LE"},
          {RESERVED4: "UInt32LE"},
          {RESERVED5: "UInt32LE"},
          {RESERVED6: "UInt8"} ]
    GENERIC_PACKET_ERROR: true
    SUCCESS: true
    ACTION_BUFFER_OVERFLOW: true
    CRC_MISMATCH: true
    PACKET_TOO_BIG: true
    COMMAND_NOT_SUPPORTED: true
    DOWNSTREAM_TIMEOUT: true
    TOOL_LOCK_TIMEOUT: true
    CANCEL_BUILD: true
    ACTIVE_LOCAL_BUILD: true
    OVERHEAT_STATE: true
    PACKET_TIMEOUT: true
    GET_VERSION:
      parameters:
        [{HOST_VERSION: "UInt16LE"}]
      responseParameters:
        [{FIRMWARE_VERSION: "UInt16LE"}]
    GET_TOOLHEAD_TEMP:
      responseParameters:
        [{CURRENT_TEMP: "Int16LE"}]
    GET_MOTOR_1_SPEED_RPM:
      responseParameters:
        [{ROTATION_DURATION: "UInt32LE"}]
    IS_TOOL_READY:
      responseParameters:
        [{IS_TOOL_READY: "UInt8"}]
    READ_FROM_EEPROM:
      parameters:
        [{MEMORY_OFFEST: "UInt16LE"},
         {LENGTH: "UInt8"}]
      responseParameters:
        [{EEPROM_DATA: "Bytes"}]
    WRITE_TO_EEPROM:
      parameters:
         [{MEMORY_OFFEST: "UInt16LE"},
          {LENGTH: "UInt8"},
          {DATA: "Bytes"}]
      responseParameters:
        [{NUMBER_OF_BYTES: "UInt8"}]
    GET_PLATFORM_TEMP:
      responseParameters:
        [{PLATFORM_TEMPERATURE: "Int16LE"}]
    GET_TOOLHEAD_TARGET_TEMP:
      responseParameters:
        [{TOOLHEAD_TARGET_TEMPERATURE: "Int16LE"}]
    GET_PLATFORM_TARGET_TEMP:
      responseParameters:
        [{PLATFORM_TARGET_TEMPERATURE: "Int16LE"}]
    IS_PLATFORM_READY:
      responseParameters:
        [{IS_PLATFORM_READY: "UInt8"}]
    GET_TOOL_STATUS:
      responseParameters:
        [{TOOL_STATUS_BITFIELD: "UInt8"}]
    GET_PID_STATE:
      responseParameters:
        [ {EXTRUDER_HEATER_ERROR: "Int16LE"},
          {EXTRUDER_HEATER_DELTAL: "Int16LE"},
          {EXTRUDER_HEATER_LAST: "Int16LE"},
          {EXTRUDER_HEATER_ERROR: "Int16LE"},
          {EXTRUDER_HEATER_DELTAL: "Int16LE"},
          {EXTRUDER_HEATER_LAST: "Int16LE"}]
    SET_TOOLHEAD_TARGET_TEMP:
      parameters:
        [{TARGET_TEMPERATURE: "Int16LE"}]
    SET_MOTOR_1_SPEED_RPM:
      parameters:
        [ {ROTATION_DURATION: "UInt32LE"} ]
    TOGGLE_MOTOR_1:
      parameters:
        [{BITFIELD: "UInt8"}]
    TOGGLE_FAN:
      parameters:
        [{FAN_STATUS: "UInt8"}]
    TOGGLE_EXTRA_OUTPUT:
      parameters:
        [{EXTRA_OUTPUT: "UInt8"}]
    SET_SERVO_1_POSITION:
      parameters:
        [{ANGLE:"UInt8"}]
    PAUSE: true
    ABORT: true
    SET_PLATFORM_TEMP: 
      parameters:
        [{TEMPERATURE: "Int16LE"}]








