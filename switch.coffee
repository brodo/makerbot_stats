#!/usr/bin/env coffee

program = require('commander')
clc = require('cli-color')
sys = require("sys")
fs = require("fs")
stdin = process.openStdin()
switchIsReady = false
switchIsOn = true

program
  .version("0.3")
  .usage("./switch.coffee [options] <tty>")
  .option("-p, --port <n>", "specify a TCP port to listen on [8080]",8080, parseInt)
  .parse(process.argv)

if program.args.length != 1
  console.log("#{clc.red("Error:")} You need to specify a tty which should be used to communicate with the switch.")
  process.exit(1);

console.log program.args[0]

SerialPort = require("serialport").SerialPort
spSwitcher = new SerialPort(program.args[0], {
    baudrate: 57600
})

switchOn = (callback) ->
  if switchIsReady
    spSwitcher.write("S\x01#", (err, results) -> 
      if not err?
        switchIsOn = true
      if callback
        callback(err)
    )
  else
    callback(new Error("Switch is not connected via USB")) if callback

switchOff = (callback) ->
  if switchIsReady
    spSwitcher.write("S\x00#", (err, results) -> 
      if not err?
        switchIsOn = false
      if callback
        callback(err)
    )
  else
    callback(new Error("Switch is not connected via USB")) if callback

spSwitcher.on("open",->
  spSwitcher.on('data', (data) ->
    if data.toString()[0..4] == "Hello"
      console.log('Power Switch is online!')
      switchIsReady = true
      switchOn()
  )  
)

stdin.addListener("data", (input) ->
    # note:  input is an object, and when converted to a string it will
    # end with a linefeed.  
    command = input.toString()[0..-2]
    switchOff() if command == "off"
    switchOn() if command == "on"
)


express = require("express")
app = express()
app.configure ->
    app.use(express.bodyParser())
    app.use(express.methodOverride())
    app.use(app.router)

checkSecretKey = (request, response, callback) ->
  secretKey = request.get("Authorization")
  if secretKey == "MoKAd3h5EV0nqNq2K7bhAeDOdHZo8nn8Z00S6Tyr"
    callback()
  else
    console.log("Not authorized")
    response.send(401, {error: "not authorized"})


app.all('/*', (req, res, next) ->
    res.header("Access-Control-Allow-Origin", "*")
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE")
    res.header("Access-Control-Allow-Headers", "Authorization")
    res.header("Content-Type", 'application/json, text/javascript')
    if req.method == 'OPTIONS'
      res.send(200)
      return
    next()
)

app.get("/switch", (req, res) ->
  checkSecretKey(req, res, ->
    switchStatus = if switchIsOn then "on" else "off"
    res.send(200, {status: switchStatus})
  )
)

app.options("/switch", (req, res) ->
  checkSecretKey(req, res, ->
    switchStatus = if switchIsOn then "on" else "off"
    res.send(200, {status: switchStatus})
  )
)

app.post("/switch", (req, res, next) ->
  checkSecretKey(req, res, ->
    console.log("Switching")
    desiredStatus = req.body.status
    
    sendJSON = (err)=>
      switchStatus = if switchIsOn then "on" else "off"
      result = {status: switchStatus}
      result.error = err.toString() if err
      res.send(200, result)
      
    switchOn(sendJSON) if desiredStatus == "on"
    switchOff(sendJSON) if desiredStatus == "off"
  )
)

app.listen(program.port)
console.log("Listening on port #{program.port}")
