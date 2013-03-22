byteNames =
  Other:
    Packet: 0xD5
  HostQueryCommands: 
    GetVersion: 0
    Init: 1
    GetAvailableBufferSize: 2
    ClearBuffer: 3
    AbortImmediately: 7
    Pause: 8
    ToolQuery: 10
    IsFinished: 11
    ReadFromEeprom: 12
    WriteToEeprom: 13
    CaptureToFile: 14
    EndCapture: 15
    PlaybackCapture: 16
    Reset: 17
    GetNextFilename: 18
    GetBuildName: 20
    GetExtendedPosition: 21
    ExtendedStop: 22
    GetMotherboardStatus: 23
    GetBuildStats: 24
    GetCommunicationStats: 25
    GetAdvancedVersion: 27
  HostActionCommands: 
    FindAxesMinimums: 131
    FindAxesMaximums: 132
    Delay: 133
    ChangeTool: 134
    WaitForToolReady: 135
    ToolActionCommand: 136
    EnableAxes: 137
    QueueExtendedPoint: 139
    SetExtendedPosition: 140
    WaitForPlatformReady: 141
    QueueExtendedPointNew: 142
    StoreHomePositions: 143
    RecallHomePositions: 144
    SetPotValue: 145
    SetRgbLed: 146
    SetBeep: 147
    WaitForButton: 148
    DisplayMessage: 149
    SetBuildPercent: 150
    QueueSong: 151
    ResetToFactory: 152
    BuildStartNotification: 153
    BuildEndNotification: 154
    QueueExtendedPointAccelerated: 155
    X3GVersion: 157
  ToolQueryCommands: 
    GetVersion: 0
    GetToolheadTemp: 2
    GetMotor1SpeedRpm: 17
    IsToolReady: 22
    ReadFromEeprom: 25
    WriteToEeprom: 26
    GetPlatformTemp: 30
    GetToolheadTargetTemp: 32
    GetPlatformTargetTemp: 33
    IsPlatformReady: 35
    GetToolStatus: 36
    GetPidState: 37
  ToolActionCommands: 
    Init: 1
    SetToolheadTargetTemp: 3
    SetMotor1SpeedRpm: 6
    SetMotor1Direction: 8
    ToggleMotor1: 10
    ToggleFan: 12
    ToggleExtraOutput: 13
    SetServo1Position: 14
    SetServo2Position: 15
    Pause: 23
    Abort: 24
    ToggleAbp: 27
    SetPlatformTemp: 31
  ResponseCodes: 
    GenericPacketError: 0x80
    Success: 0x81
    ActionBufferOverflow: 0x82
    CrcMismatch: 0x83
    PacketTooBig: 0x84
    CommandNotSupported: 0x85
    DownstreamTimeout: 0x87
    ToolLockTimeout: 0x88
    CancelBuild: 0x89
    ActiveLocalBuild: 0x8A
    OverheatState: 0x8B
    PacketTimeout: 0x8C
  SdError: 
    Success: 0
    NoCardPresent: 1
    InitializationFailed: 2
    PartitionTableError: 3
    FilesystemError: 4
    DirectoryError: 5

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
  

miniumumSizeForType = (type) ->
  switch type
    when 'String' then return 0
    when 'Bytes' then return 0
    when 'ToolQuery' then return 2
    when 'ToolArguments' then return 1
    else numberTypes[type].size

minimumParametersSize = (parameterArray) ->
  size = 0
  for parameter in parameterArray
    [name, type] for name, type of parameter
    size += miniumumSizeForType(type)
  return size

nameForHostByte = (byte) ->
  for codeName, codeNumber of byteNames.HostQueryCommands
    return codeName if codeNumber == byte
  for codeName, codeNumber of byteNames.HostActionCommands
          return codeName if codeNumber == byte
  for codeName, codeNumber of byteNames.ResponseCodes
          return codeName if codeNumber == byte

nameForToolByte = (byte) ->
  for codeName, codeNumber of byteNames.ToolQueryCommands
    return codeName if codeNumber == byte
  for codeName, codeNumber of byteNames.ToolActionCommands
          return codeName if codeNumber == byte

isHostCommand = (command) ->
  command of byteNames.HostQueryCommands or command of byteNames.HostActionCommands

module.exports.byteNames = byteNames
module.exports.numberTypes = numberTypes
module.exports.sizeForType = miniumumSizeForType
module.exports.minimumParametersSize = minimumParametersSize
module.exports.nameForToolByte = nameForToolByte
module.exports.nameForHostByte = nameForHostByte
module.exports.isHostCommand = isHostCommand