#!/usr/bin/env coffee
Makerbot Stats
==============
Make Makerbot status information avilable on the web. This package sniffs the serial communication
between the Makerbot and your Mac using [DTrace](http://dtrace.org/blogs/). The information is made
avaible through a small REST API.

Command Line Options
--------------------
Makerbot Stats needs to know which tty it should listen in on, every other argument is optional.


    program = require('commander') 
    clc = require('cli-color')
    program
      .version("0.3")
      .usage("makerbot_stats [tty-name]")
      .option("-p, --port <n>", "specify a TCP port to listen on [8081]",8081, parseInt)
    program.on('--help', ->
      console.log("  Examples:")
      console.log("")
      console.log("    $ makerbot_stats tty.usbmodem123")
    )
    program.parse(process.argv)

    console.log(clc.underline.bold("    MakerBot Stats 0.3    "))
    if program.args.length != 1
      console.log(clc.red.bold("ERROR: Please specify a tty filename. E.g. tty.usbmeodem123"))
      process.exit(1)

    server = require("../lib/server")
    server.server.listen(program.port)
    console.log("Listening on Port " + clc.green(program.port))

DTrace
------""
Makerbot Stats starts two instances of DTrace: One caputres every write operation to the tty, and 
the other caputres every read operation. DTrace needs to run with root rights.
    
    tty = program.args[0]
    sudo = require('sudo')
    options = 
      cachePassword: true,
      prompt: 'MakerBot Stats needs your password to start DTrace. Please enter your password:'
    write = sudo([ 'dtrace', '-s', '../dtrace/makerbotsniff_write', "tty.#{tty}", "cu.#{tty}" ], options)
    read = sudo([ 'dtrace', '-s', '../dtrace/makerbotsniff_read', "tty.#{tty}", "cu.#{tty}" ], options)
    
    

S3GParser
---------
The stdout ouf the DTrace script needs to be decoded from binary to JSON objects. 
`s3g.callback` is called by the s3g module when a packet is ready.

    makerbotStatsObject = 
      Tool0: {}
      Tool1: {}

    s3g = require("../lib/s3g")
    write.stdout.on('data', (data) ->
      s3g.readRequestByte(byte) for byte in data 
    )
    read.stdout.on('data', (data) ->
      s3g.readResponseByte(byte) for byte in data
    )

    interestingParameters = require("../lib/interesting_parameters")
    
    s3g.callback = (packet) ->
      console.log(packet)
      if packet.ToolIndex?
        currenttoolHeadInfo = makerbotStatsObject["Tool#{packet.ToolIndex}"]
        unless (packet.ToolheadTemperature? and packet.ToolheadTemperature == 0) or
          (packet.PlatformTemperature? and packet.PlatformTemperature == 0)
            currenttoolHeadInfo[name] = value for name, value of packet when name in interestingParameters

      else
        makerbotStatsObject[name] = value for name, value of packet when name in interestingParameters
      server.updateInfos(makerbotStatsObject)


Handle Shutdown
---------------

    process.on('exit', ->
      console.log(clc.red("Stopping MakerBot Stats"))
      write.kill()
      read.kill()
    ) 

     
    