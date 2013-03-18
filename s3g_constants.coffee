byteNames =
  OTHER:
    PACKET: 0xD5
  HOST_QUERY_COMMANDS: 
    GET_VERSION: 0
    INIT: 1
    GET_AVAILABLE_BUFFER_SIZE: 2
    CLEAR_BUFFER: 3
    ABORT_IMMEDIATELY: 7
    PAUSE: 8
    TOOL_QUERY: 10
    IS_FINISHED: 11
    READ_FROM_EEPROM: 12
    WRITE_TO_EEPROM: 13
    CAPTURE_TO_FILE: 14
    END_CAPTURE: 15
    PLAYBACK_CAPTURE: 16
    RESET: 17
    GET_NEXT_FILENAME: 18
    GET_BUILD_NAME: 20
    GET_EXTENDED_POSITION: 21
    EXTENDED_STOP: 22
    GET_MOTHERBOARD_STATUS: 23
    GET_BUILD_STATS: 24
    GET_COMMUNICATION_STATS: 25
    GET_ADVANCED_VERSION: 27
  HOST_ACTION_COMMANDS: 
    FIND_AXES_MINIMUMS: 131
    FIND_AXES_MAXIMUMS: 132
    DELAY: 133
    CHANGE_TOOL: 134
    WAIT_FOR_TOOL_READY: 135
    TOOL_ACTION_COMMAND: 136
    ENABLE_AXES: 137
    QUEUE_EXTENDED_POINT: 139
    SET_EXTENDED_POSITION: 140
    WAIT_FOR_PLATFORM_READY: 141
    QUEUE_EXTENDED_POINT_NEW: 142
    STORE_HOME_POSITIONS: 143
    RECALL_HOME_POSITIONS: 144
    SET_POT_VALUE: 145
    SET_RGB_LED: 146
    SET_BEEP: 147
    WAIT_FOR_BUTTON: 148
    DISPLAY_MESSAGE: 149
    SET_BUILD_PERCENT: 150
    QUEUE_SONG: 151
    RESET_TO_FACTORY: 152
    BUILD_START_NOTIFICATION: 153
    BUILD_END_NOTIFICATION: 154
    QUEUE_EXTENDED_POINT_ACCELERATED: 155
    X3G_VERSION: 157
  TOOL_QUERY_COMMANDS: 
    GET_VERSION: 0
    GET_TOOLHEAD_TEMP: 2
    GET_MOTOR_1_SPEED_RPM: 17
    IS_TOOL_READY: 22
    READ_FROM_EEPROM: 25
    WRITE_TO_EEPROM: 26
    GET_PLATFORM_TEMP: 30
    GET_TOOLHEAD_TARGET_TEMP: 32
    GET_PLATFORM_TARGET_TEMP: 33
    IS_PLATFORM_READY: 35
    GET_TOOL_STATUS: 36
    GET_PID_STATE: 37
  TOOL_ACTION_COMMANDS: 
    INIT: 1
    SET_TOOLHEAD_TARGET_TEMP: 3
    SET_MOTOR_1_SPEED_RPM: 6
    SET_MOTOR_1_DIRECTION: 8
    TOGGLE_MOTOR_1: 10
    TOGGLE_FAN: 12
    TOGGLE_EXTRA_OUTPUT: 13
    SET_SERVO_1_POSITION: 14
    SET_SERVO_2_POSITION: 15
    PAUSE: 23
    ABORT: 24
    TOGGLE_ABP: 27
    SET_PLATFORM_TEMP: 31
  RESPONSE_CODES: 
    GENERIC_PACKET_ERROR: 0x80
    SUCCESS: 0x81
    ACTION_BUFFER_OVERFLOW: 0x82
    CRC_MISMATCH: 0x83
    PACKET_TOO_BIG: 0x84
    COMMAND_NOT_SUPPORTED: 0x85
    DOWNSTREAM_TIMEOUT: 0x87
    TOOL_LOCK_TIMEOUT: 0x88
    CANCEL_BUILD: 0x89
    ACTIVE_LOCAL_BUILD: 0x8A
    OVERHEAT_STATE: 0x8B
    PACKET_TIMEOUT: 0x8C
  SD_ERROR: 
    SUCCESS: 0
    NO_CARD_PRESENT: 1
    INITIALIZATION_FAILED: 2
    PARTITION_TABLE_ERROR: 3
    FILESYSTEM_ERROR: 4
    DIRECTORY_ERROR: 5

numberTypes =
  UInt8: 
    size: 1
  UInt16LE:
    size: 2
  Int16LE:
    size: 2
  UInt32LE:
    size: 4
  Int32LE:
    size: 4
  FloatLE:
    size: 4
  


addAttributesToObject = (fromObject, toObject) ->
  toObject[key] = fromObject[key] for key in Object.keys(fromObject)
  return toObject

sizeForType = (type) ->
  if type == 'String' or type == 'Byte'
    return 0
  else
    numberTypes[type].size



nameForHostByte = (byte) ->
  for codeName, codeNumber of byteNames.HOST_QUERY_COMMANDS
    return codeName if codeNumber == byte
  for codeName, codeNumber of byteNames.HOST_ACTION_COMMANDS
          return codeName if codeNumber == byte
  for codeName, codeNumber of byteNames.RESPONSE_CODES
          return codeName if codeNumber == byte

nameForToolByte = (byte) ->
  for codeName, codeNumber of byteNames.TOOL_QUERY_COMMANDS
    return codeName if codeNumber == byte
  for codeName, codeNumber of byteNames.TOOL_ACTION_COMMANDS
          return codeName if codeNumber == byte

isHostCommand = (command) ->
  command of byteNames.HOST_QUERY_COMMANDS or command of byteNames.HOST_ACTION_COMMANDS

module.exports.byteNames = byteNames
module.exports.numberTypes = numberTypes
module.exports.sizeForType = sizeForType
module.exports.nameForToolByte = nameForToolByte
module.exports.nameForHostByte = nameForHostByte
module.exports.isHostCommand = isHostCommand
module.exports.addAttributesToObject = addAttributesToObject