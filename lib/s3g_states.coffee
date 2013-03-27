module.exports  =
    GetVersion:
      parameters:
        [ {HostVersion: "UInt16LE"} ]
      responseParameters:
        [ {FirmwareVersion: "UInt16LE"} ]              
    Init: true # No argument or response
    GetAvailableBufferSize:
      responseParameters:
        [ {BufferSize: "UInt32LE"} ]
    ClearBuffer: true # No argument or response
    AbortImmediately: true # No argument or response
    Pause: true # No argument or response
    ToolQuery:  
      parameters:
        [ {ToolIndex: "UInt8"},
          {Payload: "ToolQuery"}]
    IsFinished:
      responseParameters:
        [ {IsFinished: "UInt8"} ]
    ReadFromEeprom:
      parameters:
        [ {MemoryOffest: "UInt16LE"},
          {Length: "UInt8"} ]
      responseParameters:
        [ {Data: "Bytes"} ]
    WriteToEeprom:
      parameters:
        [ {MemoryOffest: "UInt16LE"},
          {Length: "UInt8"},
          {Data: "Bytes"} ]
      responseParameters:
        [ {Data: "Bytes"} ]
    CaptureToFile: 
      parameters:
        [ {FileName: "String"} ]
      responseParameters:
        [ {SdResponseCode: "UInt8"} ]
    EndCapture:
      responseParameters:
        [ {Bytecount: "UInt32LE"} ]
    PlaybackCapture: 
      parameters:
        [ {FileName: "String"} ]
      responseParameters:
        [ {SdResponseCode: "UInt8"} ]
    Reset: true # No argument or response
    GetNextFilename: 
      parameters:
        [ {RestartListing: "UInt8"} ]
      responseParameters:
        [ {SdResponseCode: "UInt8"},
          {Name: "String"}]
    GetBuildName:
      responseParameters:
        {BuildName: "String"}
    GetExtendedPosition:
      responseParameters:
        [ {XPosition: "Int32LE"},
          {YPosition: "Int32LE"},
          {ZPosition: "Int32LE"},
          {APosition: "Int32LE"},
          {BPosition: "Int32LE"},
          {EndstopStatus: "UInt16LE"} ]
    ExtendedStop:
      parameters:
        [ {Bitfield: "UInt8"} ]
      responseParameters:
        [ {Reserved: "UInt8"} ]
    GetMotherboardStatus:
      responseParameters:
        [ {Bitfield: "UInt8"} ]
    GetBuildStats:
      responseParameters:
        [ {BuildState: "UInt8"},
          {HoursElapsed: "UInt8"},
          {MinutesElapsed: "UInt8"},
          {LineNumber: "UInt32LE"},
          {Reserved: "UInt32LE"} ]
    GetFilamentStatus:
      responseParameters:
        [{FillamentPercent: "UInt8"}]
    GetCommunicationStats:
      responseParameters:
        [ {PacketsReceived: "UInt32LE"},
          {PacketsSent: "UInt32LE"},
          {UnrespondedPackets: "UInt32LE"},
          {Retries: "UInt32LE"},
          {PacketsReceived: "UInt32LE"}]
    GetAdvancedVersion:
      parameters:
        [ {HostVersion: "UInt16LE"} ]
      responseParameters:
        [ {FirmwareVersion: "UInt16LE"},
          {InternalVersion: "UInt16LE"},
          {Variant: "UInt8"},
          {Reserved1: "UInt8"},
          {Reserved2: "UInt16LE"} ]
    FindAxesMinimums:
      parameters:
        [ {Axes: "UInt8"},
          {FeedRate: "UInt32LE"},
          {Timeout: "UInt16LE"} ]
    FindAxesMaximums:
      parameters:
        [ {Axes: "UInt8"},
          {FeedRate: "UInt32LE"},
          {Timeout: "UInt16LE"}]
    Delay:
      parameters:
        [ {Delay: "UInt32LE"} ]
    ChangeTool:
      parameters:
        [ {ToolId: "UInt8"} ]
    WaitForToolReady:
      parameters:
        [ {ToolId: "UInt8"},
          {Delay: "UInt16LE"},
          {Timeout: "UInt16LE"}]
    ToolActionCommand:
      parameters:
        [ {ToolId: "UInt8"},
          {ActionCommand: "UInt8"},
          {Length: "UInt8"},
          {ToolCommand: "ToolArguments"}]
    EnableAxes:
      parameters:
        [ {Bitfield: "UInt8"} ]
    QueueExtendedPoint:
      [ {XPosition: "Int32LE"},
        {YPosition: "Int32LE"},
        {ZPosition: "Int32LE"},
        {APosition: "Int32LE"},
        {BPosition: "Int32LE"},
        {FeedRate: "UInt32LE"}]
    SetExtendedPosition:
      parameters:
        [ {XPosition: "Int32LE"},
          {YPosition: "Int32LE"},
          {ZPosition: "Int32LE"},
          {APosition: "Int32LE"},
          {BPosition: "Int32LE"} ]
    WaitForPlatformReady:
      parameters:
        [ {ToolId: "UInt8"},
          {Deley: "UInt16LE"},
          {Timeout: "UInt16LE"} ]
    QueueExtendedPointNew:
      parameters:
        [ {XPosition: "Int32LE"},
          {YPosition: "Int32LE"},
          {ZPosition: "Int32LE"},
          {APosition: "Int32LE"},
          {BPosition: "Int32LE"},
          {MovementDuration: "UInt32LE"},
          {Bitfield: "UInt8"} ]
    StoreHomePositions:
      parameters:
        [ {Bitfield: "UInt8"} ]
    RecallHomePositions:
      parameters:
        [ {Bitfield: "UInt8"} ]
    SetPotValue:
      parameters:
        [ {AxisValue: "UInt8"},
          {Value: "UInt8"} ]
    SetRgbLed:
      parameters:
        [ {Red: "UInt8"},
          {Green: "UInt8"},
          {Blue: "UInt8"},
          {BlinkRate: "UInt8"},
          {Reserved: "UInt8"} ]
    SetBeep:
      parameters:
        [ {Frequency: "UInt16LE"},
          {BuzzLength: "UInt16LE"},
          {Reserved: "UInt8"} ]
    WaitForButton:
      parameters:
        [ {ButtonBitfield: "UInt8"},
          {Timeout: "UInt16LE"},
          {OptionsBitfield: "UInt8"} ]
    DisplayMessage:
      parameters:
        [ {OptionsBitfield: "UInt8"},
          {HorizontalPosition: "UInt8"},
          {VerticalPosition: "UInt8"},
          {Timeout: "UInt8"},
          {Message: "String"} ]
    SetBuildPercent:
      parameters:
        [ {Percent: "UInt8"},
          {Reserved: "UInt8"} ]
    QueueSong:
      parameters:
        [ {SongId: "UInt8"} ]
    ResetToFactory:
      parameters:
        [ {Reserved: "UInt8"} ]
    BuildStartNotification:
      parameters:
        [ {Reserved: "UInt32LE"},
          {BuildName: "String"} ]
    BuildEndNotification:
      parameters:
        parameters:
         [ {Reserved: "UInt8"} ]
    QueueExtendedPointAccelerated:
      parameters:
        [ {XPosition: "Int32LE"},
          {YPosition: "Int32LE"},
          {ZPosition: "Int32LE"},
          {APosition: "Int32LE"},
          {BPosition: "Int32LE"},
          {DdaFeedrateInSteps: "UInt32LE"},
          {AxesBitfield: "UInt8"},
          {Distance: "FloatLE"},
          {FeedrateTimes64: "UInt16LE"} ]
    X3GVersion:
      parameters:
        [ {X3GHigh: "UInt8"},
          {X3GLow: "UInt8"},
          {Reserved: "UInt8"},
          {Reserved2: "UInt32LE"},
          {BotType: "UInt16LE"},
          {Reserved3: "UInt16LE"},
          {Reserved4: "UInt32LE"},
          {Reserved5: "UInt32LE"},
          {Reserved6: "UInt8"} ]
    GenericPacketError: true
    Success: true
    ActionBufferOverflow: true
    CrcMismatch: true
    PacketTooBig: true
    CommandNotSupported: true
    DownstreamTimeout: true
    ToolLockTimeout: true
    CancelBuild: true
    ActiveLocalBuild: true
    OverheatState: true
    PacketTimeout: true
    GetVersion:
      parameters:
        [{HostVersion: "UInt16LE"}]
      responseParameters:
        [{FirmwareVersion: "UInt16LE"}]
    GetToolheadTemp:
      responseParameters:
        [{ToolheadTemperature: "Int16LE"}]
    GetMotor1SpeedPwm:
      responseParameters:
        [{"Motor1Pwm" : "UInt8"}]
    GetMotor2SpeedPwm:
      responseParameters:
        [{"Motor2Pwm" : "UInt8"}]
    GetMotor1SpeedRpm:
      responseParameters:
        [{RotationDuration: "UInt32LE"}]
    GetMotor2SpeedRpm:
      responseParameters:
        [{RotationDuration: "UInt32LE"}]
    IsToolReady:
      responseParameters:
        [{IsToolReady: "UInt8"}]
    GetPlatformTemp:
      responseParameters:
        [{PlatformTemperature: "Int16LE"}]
    GetToolheadTargetTemp:
      responseParameters:
        [{ToolheadTargetTemperature: "Int16LE"}]
    GetFirmwareBuildName:
      responseParameters:
        [{"BuildName" : "String"}]
    GetPlatformTargetTemp:
      responseParameters:
        [{PlatformTargetTemperature: "Int16LE"}]
    IsPlatformReady:
      responseParameters:
        [{IsPlatformReady: "UInt8"}]
    GetToolStatus:
      responseParameters:
        [{ToolStatusBitfield: "UInt8"}]
    GetPidState:
      responseParameters:
        [ {ExtruderHeaterError: "Int16LE"},
          {ExtruderHeaterDeltal: "Int16LE"},
          {ExtruderHeaterLast: "Int16LE"},
          {ExtruderHeaterError: "Int16LE"},
          {ExtruderHeaterDeltal: "Int16LE"},
          {ExtruderHeaterLast: "Int16LE"}]
    SetToolheadTargetTemp:
      parameters:
        [{TargetTemperature: "Int16LE"}]
    SetMotor1SpeedPwm:
      parameters:
        [{PWMSpeed: "UInt8"}]
    SetMotor2SpeedPwm:
      parameters:
        [{PWMSpeed: "UInt8"}]
    SetMotor1SpeedRpm:
      parameters:
        [ {RotationDuration: "UInt32LE"} ]
    SetMotor2SpeedRpm:
      parameters:
        [ {RotationDuration: "UInt32LE"} ]
    SetMotor1Direction:
      parameters:
        [ {Clockwise: "UInt8"} ]
    SetMotor2Direction:
      parameters:
        [ {Clockwise: "UInt8"} ] 
    ToggleMotor1:
      parameters:
        [{Bitfield: "UInt8"}]
    ToggleMotor2:
      parameters:
        [{Bitfield: "UInt8"}]
    ToggleFan:
      parameters:
        [{FanStatus: "UInt8"}]
    ToggleExtraOutput:
      parameters:
        [{ExtraOutput: "UInt8"}]
    SetServo1Position:
      parameters:
        [{Angle:"UInt8"}]
    SelectTool: true
    Pause: true
    Abort: true
    SetPlatformTemp: 
      parameters:
        [{PlatformTargetTemperature: "Int16LE"}]








