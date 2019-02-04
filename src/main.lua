-- main

math.randomseed( os.time() )

system.activate( "multitouch" )

system.deviceName = system.getInfo("model").."_"..display.actualContentWidth.."_"..display.actualContentHeight
print(system.deviceName)

require("physics")
physics.start()
physics.setGravity(0,10)
--physics.setDrawMode("hybrid")
--physics.setPositionIterations( 6 )

require("mathlib")
require("tablelib")
require("utils")
require("timerlib")
--local colourlib = require("colourlib")
local composer = require("composer")
--local levellib = require("levellib")
local iolib = require("iolib")
local json = require("json")
--local levelslib = require("marbled.levelslib")
--local scoreslib = require("scoreslib")
--local locklib = require("marbled.locklib")
composer.isDebug = false
iolib.isdebug = composer.isDebug
composer.isEditorEnabled = true
composer.isTutorialEnabled = true
--composer.recycleOnSceneChange = true

--levelslib.define( "guid", "pieces", "scale", "squarecount", "balltarget", "guid" )
--scoreslib.define( "guid", "guid", "iscomplete", "isunlocked" )

io.output():setvbuf('no') 		-- **debug: disable output buffering for Xcode Console
print(system.orientation)
if (string.sub( system.orientation, 1, 8 ) ~= "portrait" and system.getInfo("model") ~= "Apple TV") then
	display.actualContentWidth, display.actualContentHeight = display.actualContentHeight, display.actualContentWidth
end
print("display.actualContentWidth, display.actualContentHeight: ", math.round(display.actualContentWidth), math.round(display.actualContentHeight))
display.actualCenterX, display.actualCenterY = display.actualContentWidth*.5, display.actualContentHeight*.5
display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "background", .1, .1, .1 )

local accel = function( event )
	if (event.isShake) then
		composer.isDebug = not composer.isDebug
		Runtime:dispatchEvent{ name="debug", isDebug=composer.isDebug }
		if (composer.isDebug) then
			display.setStatusBar( display.DefaultStatusBar )
			physics.setDrawMode("hybrid")
		else
			display.setStatusBar( display.HiddenStatusBar )
			physics.setDrawMode("normal")
		end
	end
	return true
end
--Runtime:addEventListener( "accelerometer", accel )

--composer.gotoScene( "menu", { effect="fade", time=400 } )
--composer.gotoScene( "blocks.blocks2", { effect="fade", time=400 } )
--composer.gotoScene( "chocks.chocks1", { effect="fade", time=400 } )
--composer.gotoScene( "ropes.ropes2", { effect="fade", time=400 } )
--composer.gotoScene( "elastic.elastic1", { effect="fade", time=400 } )
--composer.gotoScene( "poles.poles1", { effect="fade", time=400 } )
--composer.gotoScene( "reflect.reflect2", { effect="fade", time=400 } )
--composer.gotoScene( "fields.fields1", { effect="fade", time=400 } )
--composer.gotoScene( "weights.weights1", { effect="fade", time=400 } )
--composer.gotoScene( "follow.followtest", { effect="fade", time=400 } )
--composer.gotoScene( "trace.traceedit", { effect="fade", time=400 } )
--composer.gotoScene( "trace.trace1", { effect="fade", time=400, params={ level="trace/tillershitch.data" } } )
--composer.gotoScene( "process.level1", { effect="fade", time=400 } )
--composer.gotoScene( "tilt10.tilt10", { effect="fade", time=400 } )
--composer.gotoScene( "swope.swope1", { effect="fade", time=400 } )
--composer.gotoScene( "pongtrails.pongtrails1", { effect="fade", time=400 } )
--composer.gotoScene( "asternauts.asternauts1", { effect="fade", time=400 } )
--composer.gotoScene( "runrunner.runrunner1", { effect="fade", time=400 } )
--composer.gotoScene( "marbled.marbledmenu", { effect="fade", time=200, params={ target=nil } } )
--composer.gotoScene( "marbled.marbled1", { effect="fade", time=200, params={ filename="marbled/levels/section1/section1level1.json", section=1, level=1, isCustom=false } } )

-- require("batnball.backgroundlib")
timer.performWithDelay( 300, function()
	-- composer.gotoScene( "batnball.loadingscene", { params={ name="levelone" } } )
end, 1 )




--require("touchguidelib").enableGuide()

local function generateGuidsInDocsFolder()
	local guid = require("guid")
	local files = iolib.docListing( "", "section.*.json" )
	
	local data = json.decode( iolib.wrDocs( "section2level.json" ) )
	data.iscomplete = nil
	data.isunlocked = nil
	data.squarecount = 4
	print(json.prettify( data ))
	
	for i=1, 18 do
		data.guid = guid.generate()
		iolib.wrDocs( "section2level"..string.format( "%02d", i )..".json", json.prettify( data ) )
	end
end
--generateGuidsInDocsFolder()

local function cleanDocs()
	local files = iolib.docListing( "", "png" )
	
	for i=1, #files do
		print("Removing: "..files[i])
		iolib.removeDoc( files[i] )
	end
end
cleanDocs()

require("3d.matrixlib")
require("3d.tests")

--require("mixzlejewels.boardlib").newBoard()
--require("cataclysm.boardlib").newBoard()
--require("batnball.boardlib").newBoard()

--composer.gotoScene( "tilttv.startscene", { params={  } } )
--composer.gotoScene( "rally.orientscene", { params={  } } )
--composer.gotoScene( "remote.remotescene", { params={  } } )
--composer.gotoScene( "plonk.plonk1", { params={  } } )

--local remote = require("remote")
--remote.startServer( "8080" )
--local dot = display.newCircle( display.actualCenterX, display.actualCenterY, 25 )
--dot.fill = {1,0,0}
--
--local text = display.newText{ x=display.actualCenterX, y=150, fontSize=60, text="" }
--local factor = 100
--
--Runtime:addEventListener( "enterFrame" , function()
--	text.text = remote.xInstant.."\n"..remote.yInstant.."\n"..remote.zInstant
--	dot.x, dot.y = dot.x + remote.xGravity * factor, dot.y + remote.yInstant * factor
--end )

local function testManual()

-- load namespace
local socket = require("socket")
dump(socket)

local function getIpAddress()
	-- Connect to the client
	local client = socket.connect( "www.apple.com", 80 )
	
	-- Get IP and port from client
	local ip, port = client:getsockname()
	
	-- Print the IP address and port to the terminal
	print( "IP Address:", ip )
	print( "Port:", port )
	
	return ip, port
end
--local ip, port = getIpAddress()

print("environment: ",system.getInfo("environment"))
if (system.getInfo("environment") == "simulator") then
-- find out which port the OS chose for us
print("ip: "..ip,"port: "..port)
local master = socket.tcp()
print("setoption( \"reuseaddr\" , true ): ",master:setoption( "reuseaddr" , true ))
print("bind("..ip..", 8080): ",master:bind(ip, "8080"))
print("listen: ",master:listen(0))
print("settimeout: ",master:settimeout(0))
timer.performWithDelay( 10, function()
	local client = master:accept()
	if (client) then
--		print("client: ",client)
		local mssg = client:receive("*l")
		if (mssg) then
		print("mssg: ",mssg)
			local text = display.newText{ text=tostring(mssg), x=display.actualCenterX, y=display.actualCenterY, fontSize=32 }
			transition.to( text, { time=1500, alpha=0 } )
		end
	end
--	print("test")
end, 0 )
else
	local count = 0
	timer.performWithDelay( 1000, function()
		local text = display.newText{ text=tostring(ip)..":"..tostring(port), x=display.actualCenterX, y=display.actualCenterY, fontSize=32 }
		transition.to( text, { time=1500, alpha=0 } )
		network.request("http://192.168.0.17:8080/bonza/"..count)
		count = count + 1
	end, 0 )
end

end
--testManual()

local function testAutoLan()
	print(system.getInfo("environment"))
	if (system.getInfo("environment") == "simulator") then
		local text = display.newText{ text="Server created", x=display.actualCenterX, y=display.actualCenterY, fontSize=32 }
		transition.to( text, { time=1500, alpha=0 } )
		local server = require "Server"
		server:start()
		local clients = {} --table to store all of our client objects.
		local numClients = 0

		--lets just send stuff to all our clients
		local function sendStuff()
			for i,client in pairs(clients) do
				client:send("this server has been up for"..system.getTimer())
			end
		end
		Runtime:addEventListener("enterFrame", sendStuff)
		
		local function events(event)
			dump(event)
		end
		
		local function autolanPlayerJoined(event)
			local client = event.client
			--print("client object: ", client) --this represents the connection to the client. you can use this to send messages and files to the client. You should save this in a table somewhere.
			--now lets save the client object so we can use it in the future to send messages
			clients[client] = client --trick, we can use the table object itself as the key, this will make it easier to determine which client we received a message from
			numClients = numClients + 1
			client.myJoinTime = system.getTimer() --you can add whatever values you want to the table to retrieve it later in the receved listener
			client.myName = "Player "..numClients
			--we can begin using the client object to send messages now!
			--client:send("Hello Player!")
			print("autolanPlayerJoined") 
		end
		Runtime:addEventListener("autolanPlayerJoined", autolanPlayerJoined)

		Runtime:addEventListener("autolanPlayerDropped", events)
		Runtime:addEventListener("autolanReceived", events)
		Runtime:addEventListener("autolanFileReceived", events)
	else
		local text = display.newText{ text="Client created", x=display.actualCenterX, y=display.actualCenterY, fontSize=32 }
		transition.to( text, { time=1500, alpha=0 } )

		local client = require "Client"
		client:start()
		client:autoConnect()
		
		local function events(event)
			dump(event)
		end
		
		local function autolanConnected(event)
			print("broadcast", event.customBroadcast) --this is the user defined broadcast recieved from the server, it tells us about the server state.
			print("serverIP," ,event.serverIP) --this is the user defined broadcast recieved from the server, it tells us about the server state.
			--now that we have a connecton, let us just constantly send stuff to the server as an example
			local function sendStuff()
				client:send("hello world, the time here is"..system.getTimer())
			end
			Runtime:addEventListener("enterFrame", sendStuff)
			print("connection established")
		end
		Runtime:addEventListener("autolanConnected", events)
		Runtime:addEventListener("autolanServerFound", events)
		Runtime:addEventListener("autolanDisconnected", events)
		Runtime:addEventListener("autolanReceived", events)
		Runtime:addEventListener("autolanFileReceived", events)
		Runtime:addEventListener("autolanConnectionFailed", events)
	end
end
--testAutoLan()
