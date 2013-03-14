#!/usr/bin/env coffee

program = require('commander')
clc = require('cli-color')
sys = require("sys")
s3g = require("./s3g")

program
  .version("0.3")
  .usage("./makerbot.coffee [options]")
  .option("-p, --port <n>", "specify a TCP port to listen on [8081]",8081, parseInt)
  .option("-f --fifo <filename>", "specify a named pipe which contains the MakerBot serial communication.")
  .parse(process.argv)



express = require("express")
app = express()
app.configure ->
    app.use(express.bodyParser())
    app.use(express.methodOverride())
    app.use(app.router)

makerbotInfos = 
  firmwareVersion: 123
  isBusy: false
  currentFile: "unknown.std"
  platformTemperature: 100
  toolheadTemperature: 200
  percentFinished: 12


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

app.get("/makerbot", (req, res) ->
  checkSecretKey(req, res, ->
    res.send(200, makerbotInfos)
  )
)

app.options("/makerbot", (req, res) ->
  checkSecretKey(req, res, ->
    switchStatus = if switchIsOn then "on" else "off"
    res.send(200, {status: switchStatus})
  )
)


app.listen(program.port)
console.log("Listening on port #{program.port}")
