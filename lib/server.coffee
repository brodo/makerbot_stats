# Makerbot Web API
# ================
# This web server provides status information about a Makerbot. It reads the binary communication
# between a Makerbot and the computer the Makerbot is plugged into by reading two named pipes. 
# One named pipe for the information sent by the host to the Makerbot (requests) and one for the 
# information sent by the Makerbot to the host (responses).


#!/usr/bin/env coffee

# Libararies used
# ---------------
sys = require("sys")
s3g = require("./s3g") # For decoding s3g packages to JSON


express = require("express")
app = express()
app.configure ->
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)

# This global varbiable contains all information in `makerbot.json`
makerbotInfos = 
  firmwareVersion: 123
  isBusy: false
  currentFile: "unknown.std"
  platformTemperature: 100
  toolheadTemperature: 200
  percentFinished: 12

# This allows cross domain AJAX requests for everything
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

app.get("/makerbot.json", (req, res) ->
  res.send(200, makerbotInfos)
)
module.exports.server = app

if require.main == module
  program = require('commander') # A command line option parser
  clc = require('cli-color') # For colorful output

  # Command line parameters
  # -----------------------

  program
    .version("0.3")
    .usage("./makerbot.coffee [options]")
    .option("-p, --port <n>", "specify a TCP port to listen on [8081]",8081, parseInt)
    .option("-r --responses <filename>", 
      "specify a named pipe which contains the binary data received from the Makerbot")
    .option("-w --request <filename>", 
      "specify a named pipe which contains the binary data sent to the Makerbot")
    .parse(process.argv)
  
    app.listen(program.port)
    console.log(clc.green("Listening on port #{program.port}")) 