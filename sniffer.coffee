#!/usr/bin/env coffee

program = require('commander')
SerialPort = require("serialport").SerialPort
clc = require('cli-color')
net = require('net')

program
  .version("0.1")
  .usage("[options] <tty master> <tty slave>")
  .option("-b, --baudrate <n>", "specify a baud rate", parseInt)
  .option("-p, --port <n>", " [OPTIONAL] specify a TCP port to listen on", parseInt)

program.on('--help', ->
  console.log('  Examples:')
  console.log('')
  console.log('    $ sniffer -b 57600 /dev/tty.usbserial /dev/ttySomeSlave');
  console.log('       Passes everything from the usb TTY to a slave terminal and vice versa.');
  console.log('       Opens both TTYs with a baud rate of 57600.');
  console.log('       Streams the traffic to stdout.');
  console.log('    $ sniffer -b 115200 -p 3000 /dev/tty.usbserial /dev/ttySomeSlave');
  console.log('       Passes everything from the usb TTY to a slave terminal and vice versa.');
  console.log('       Opens both TTYs with a baud rate of 57600.');
  console.log('       Streams the traffic to TCP port 3000.');
)

program.parse(process.argv)

if not program.baudrate? and program.args < 2
  console.log("#{clc.red("Error:")} sniffer cannot run without command line options.")
  console.log("Use #{clc.bold('--help')} for more indofmation.")
  process.exit(1);

if not program.baudrate?
  console.log("#{clc.red("Error:")} Please specify a baud rate using the #{clc.bold('-b')} command line option.")
  process.exit(1);
if program.args.length < 2
  console.log("#{clc.red("Error:")} Please specify exactly two terminal devices")
  process.exit(1)

runServer = false
socket = null
if program.port
  runServer = true
  net.createServer((sock) -> socket = sock).listen(program.port, "localhost")

sp1 = new SerialPort(program.args[0], {
     baudrate: program.baudrate
})

sp2 = new SerialPort(program.args[1], {
     baudrate: program.baudrate
})

sp1IsOpen = false
sp2IsOpen = false

sp1.on("open", ->
  sp1IsOpen = true
  sp1.on("data", (data) ->
    if sp2IsOpen
      sp2.write(data, (err, res) ->
        console.error("#{clc.red("Error:")} #{err}") if err
      )
      if socket? then socket.write(data) else process.stdout.write(data.toString())
  )
)


sp2.on("open", ->
  sp2IsOpen = true
  sp2.on("data", (data) ->
    if sp1IsOpen
      sp1.write(data, (err, res) ->
        console.error("#{clc.red("Error:")} #{err}") if err
      )
      if socket? then socket.write(data) else process.stdout.write(data.toString())
  )
)
