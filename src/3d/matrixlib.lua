-- matrix lib

display.setDefault( "background", .4,.4,.4 )

local json = require("json")
require("3d.3dmathlib")

local texturelib = require("3d.texturelib")
local shapelib = require("3d.shapelib")

local rows, cols = 14, 14

local drawlayer = display.newGroup()
drawlayer.x, drawlayer.y = display.actualCenterX, display.actualCenterY/2

--local sp = shapelib.newSphere( "3d/earth.png", "3d/earthnormal.png", 200, rows, cols )
--local sp = shapelib.newOutlinedImage( "3d/corona.png", 20, true )
--local sp = shapelib.newOutlinedImage( "3d/monkeyswing.png", 20, true )

local imagesheet
if (sp and sp[1].frame) then
	imagesheet = shapelib.getImageSheetFromFacets( sp )
end

--------------------------------------------------------------------------------

local lib = {}

local function sortObjectsByZdepth( draw, objects )
	local function compare( a, b )
		return a.centreflat.z < b.centreflat.z
	end
	
	local tbl = {}
	
--	for i=1, #objects do
--		tbl[#tbl+1] = objects[i]
--	end
	
	table.sort( objects, compare )
	
	for i=#objects, 1, -1 do
		draw:insert( i, objects[i].group )
	end
end
lib.sortObjectsByZdepth = sortObjectsByZdepth

local function sortFacetsByZdepth( object )
	local function zAvg( flat )
		local avg = 0
		for i=1, #flat do
			avg = avg + flat[i].z
		end
		return avg / #flat
	end
	
	local function compare( a, b )
		return zAvg( a.flat ) > zAvg( b.flat )
	end
	
	local function findVisibleFacets( object )
		local t = {}
		for i=1, #object do
			if (object[i].image.isVisible) then
				t[#t+1] = object[i]
			end
		end
		return t
	end
	
	local visibleOnly = findVisibleFacets( object )
	
	table.sort( visibleOnly, compare )
	
	for i=1, #visibleOnly do
		if (visibleOnly[i].sorttofront) then
			object.group:insert( visibleOnly[i].image )
		else
			object.group:insert( 1, visibleOnly[i].image )
		end
	end
end
lib.sortFacetsByZdepth = sortFacetsByZdepth

local function updateFacets( object )
	for f=1, #object do
		local facet = object[f]
		local plane = table.unpack( facet.flat, {"x","y"} )
		
		if (facet.image.isVisible) then
			if (facet.image.setPath) then
				facet.image:setPath( unpack( plane ) )
			end
		end
	end
end
lib.updateFacets = updateFacets

lib.light = {0,-200,-400,1}
lib.light2d = {0,0}

local function shadeFacets( object )
	for f=1, #object do
		local facet = object[f]
		if (facet.image.isVisible) then
			local bright, subtractedVector = math.getBrightness( lib.light, facet.transformed )
			bright = bright*.85+.15
			if (facet.fill.process == "rgb") then
				facet.image:setFillColor( bright*facet.fill[1], bright*facet.fill[2], bright*facet.fill[3], facet.fill[4] or 1 )
			else
				facet.image:setFillColor( bright )
			end
			if (facet.image.fill.effect) then
				facet.image.fill.effect.dirLightDirection = { lib.light2d.x, lib.light2d.y, 1 }
			end
		end
	end
end
lib.shadeFacets = shadeFacets

lib.focalLen = 600

-- takes: {1,2,3}, {4x4}
-- returns: {x,y}
local function processPoint( point, matrix )
	local post = math.multiply( { point }, matrix )[1]
	
	local perspective = lib.focalLen / ( lib.focalLen + post[3] )
	
	local flat = { x= post[1] * perspective, y= post[2] * perspective, z= perspective }
	
	return flat, post
end
lib.processPoint = processPoint

-- takes: {{1,2,3},{1,2,3},{1,2,3},{1,2,3}}, matrix
-- produces: {{x,y,z},{x,y,z},{x,y,z},{x,y,z}}
local function processFacet( facet, matrix )
	local flat = facet.flat
	local transformed = facet.transformed
	
	if (facet.matrix) then
		matrix = math.multiply( facet.matrix, matrix )
	end
	
	for i=1, #facet do
		flat[i], transformed[i] = processPoint( facet[i], matrix )
	end
	
	facet.image.isVisible = facet.isAlwaysVisible or not math.isPolygonClockwise( flat )
end
lib.processFacet = processFacet

-- takes: {{{1,2,3,4},{1,2,3,4}}}, matrix
-- returns: {{{x,y},{x,y},{x,y},{x,y}}}
local function processObject( object, cameramatrix )
	object.visiblecount = 0
	
	local matrix = math.multiply(
		object.matrix,
		math.newTranslationMatrix( object.location.x, object.location.y, object.location.z )
	)
	
	if (cameramatrix) then
		matrix = math.multiply( matrix, cameramatrix )
	end
	
	for i=1, #object do
		local facet = object[i]
		processFacet( facet, matrix )
	end
	
	object.centreflat, object.centretransformed = processPoint( {0,0,0,1}, matrix )
end
lib.processObject = processObject

-- takes: {{{1,2,3,4},{1,2,3,4}}}, nil
-- returns: {{{x,y},{x,y},{x,y},{x,y}}}
local function processMatrix( shape, matrix )
	processObject( shape, matrix )
end
lib.processMatrix = processMatrix

local function textureSurfaces( parent, object )
	local imagesheet
	
	if (object.filename and object[1].frame) then
		imagesheet = graphics.newImageSheet( object.filename, shapelib.getImageSheetFromFacets( object ) )
		normalsheet = graphics.newImageSheet( object.normalfilename, shapelib.getImageSheetFromFacets( object ) )
	end
	
	for i=1, #object do
		object.group = object.group or display.newGroups( parent, 1 )
		parent:insert( object.group )
		object.group.shape = object
		object.matrix = math.newTranslationMatrix( 0, 0, 0 )
		local facet = object[i]
		local rect = facet.rect
		local mesh = facet.mesh
		
		local filename = object[i].filename or object.filename
		
		local image = facet.image
		
		if (rect and image == nil) then
			facet.image = display.newPathRect( object.group, 0, 0, rect.width, rect.height )
			image = facet.image
		elseif (mesh and image == nil) then
			local vertices = {}
			local v = nil
			while (v ~= 3) do
				if (v == nil) then v = 3 end
				v = v + 1
				if (v > 4) then v = 1 end
				vertices[#vertices+1] = facet[v][1]
				vertices[#vertices+1] = facet[v][2]
			end
			facet.image = display.newPathMesh{ x=0,y=0, mode="fan", vertices=vertices }
			image = facet.image
		end
		
		if (filename and object[i].fill) then
			if (facet.fill.process == "imagesheet") then
				local compositePaint = {
					type="composite",
					paint1={ type="image", sheet=imagesheet, frame=i },
					paint2={ type="image", sheet=normalsheet, frame=i },
				}
				image.fill = compositePaint
				image.fill.effect = "composite.normalMapWith1DirLight"
				image.fill.effect.dirLightDirection = { 0, 0, 1 }
				image.fill.effect.dirLightColor = { 1, 1, 1, 1 }
				image.fill.effect.ambientLightIntensity = 1
			elseif (facet.fill.process == "extract") then
				local filename, baseDir = texturelib.extractTextureFragment(
					facet.fill.filename or filename,
					facet.fill.baseDir or system.ResourceDirectory,
					facet.fill.x, facet.fill.y,
					facet.rect.width, facet.rect.height,
					facet.fill.scaleX, facet.fill.scaleY
				)
				local mapFilename, mapBaseDir = texturelib.extractTextureFragment(
					object.normalfilename,
					system.ResourceDirectory,
					facet.fill.x, facet.fill.y,
					facet.rect.width, facet.rect.height,
					facet.fill.scaleX, facet.fill.scaleY
				)
				local compositePaint = {
					type="composite",
					paint1={ type="image", filename=filename, baseDir=baseDir },
					paint2={ type="image", filename=mapFilename, baseDir=mapBaseDir }
				}
				image.fill = compositePaint
				image.fill.effect = "composite.normalMapWith1DirLight"
				image.fill.effect.dirLightDirection = { 0, 0, 1 }
				image.fill.effect.dirLightColor = { 1, 1, 1, 1 }
				image.fill.effect.ambientLightIntensity = 1
			else
				image.fill = { type="image", filename=facet.fill.filename or filename, baseDir=facet.fill.baseDir or system.ResourceDirectory }
				image.fill.scaleX, image.fill.scaleY = facet.fill.scaleX, facet.fill.scaleY
				image.fill.x, image.fill.y = facet.fill.x, facet.fill.y
				image.fill.rotation = facet.fill.rotation
				image.fill.effect = facet.fill.effect
			end
		elseif (facet.fill.process == "rgb") then
			image.fill = { facet.fill[1], facet.fill[2], facet.fill[3], facet.fill[4] or 1 }
		end
	end
end
lib.textureSurfaces = textureSurfaces

------------------------------------------------------------------------------

local object = sp

local isTouchHappening, isRotationHappening = false, true

local matrix = math.newYRotationMatrix( 0 )
local lightmatrix = math.newYRotationMatrix( 0 )

if (object) then
	lib.textureSurfaces( drawlayer, object )
end

--local line = display.newLine( display.actualCenterX, display.actualCenterY, 0, 0 )
--local text = display.newText{ x=display.actualCenterX, y=display.actualContentHeight*.8, text=lib.light2d[1]..","..lib.light2d[2] }

local enterFrame = function()
	if (not isTouchHappening and isRotationHappening) then
		matrix = math.multiply( matrix, math.newYRotationMatrix( 1 ) )
	end
	
	if (object) then
		lib.light2d = lib.processPoint( lib.light, lightmatrix )
		lib.processMatrix( object, matrix ) -- only matrix process facets if their primary is visible
		lib.sortFacetsByZdepth( object ) -- switch this with hideBackFacingFacets so only visible facets are sorted
		lib.updateFacets( object )
		lib.shadeFacets( object )
	end
	
	local pt = math.rotateTo( {x=lib.light[1], y=lib.light[2]}, 5 )
	lib.light[1], lib.light[2] = pt.x, pt.y
	
--	text.text = math.round(lib.light2d.x)..","..math.round(lib.light2d.y)..","..math.round(lib.light2d.z)
end
Runtime:addEventListener( "enterFrame", enterFrame )

------------------------------------------------------------------------------

local draw, isRunning, objects, camera = display.newGroup(), false, {}, math.newTranslationMatrix( 0, 0, 0 )
draw.x, draw.y = display.actualCenterX, display.actualCenterY

local cameramatrix = math.newTranslationMatrix( 0, 0, 0 )

local function run()
	for i=1, #objects do
		local object = objects[i]
		
--		local matrix = math.multiply(
--			object.matrix,
--			math.newTranslationMatrix( object.location.x, object.location.y, object.location.z )
--		)
--		matrix = math.multiply( matrix, cameramatrix )
		
		lib.light2d = lib.processPoint( lib.light, lightmatrix )
		lib.processObject( object, cameramatrix )
		lib.sortFacetsByZdepth( object )
		lib.updateFacets( object )
		lib.shadeFacets( object )
	end
	
	sortObjectsByZdepth( draw, objects )
end

local function start()
	if (not isRunning) then
		Runtime:addEventListener( "enterFrame", run )
		isRunning = true
		print("3D Environment Started with "..#objects.." objects.")
	end
end
lib.start = start

local function stop()
	if (isRunning) then
		Runtime:removeEventListener( "enterFrame", run )
		isRunning = false
		print("3D Environment stopped.")
	end
end
lib.stop = stop

local function add( object )
	textureSurfaces( draw, object )
	objects[#objects+1] = object
	draw:insert( object.group )
	print("Added shape '"..(object.name or "<unnamed>").."'.")
end
lib.add = add

local function remove( object )
	table.remove( objects, object )
	display.remove( object.group )
	print("Removed shape '"..(object.name or "<unnamed>").."'.")
end
lib.remove = remove

local function translate( object, x, y, z )
	local loc = object.location
	loc.x, loc.y, loc.z = loc.x+x or 0, loc.y+y or 0, loc.z+z or 0
end
lib.translate = translate

local function rotate( object, rx, ry, rz )
	local loc = object.location
	object.matrix = math.rotateMatrix( object.matrix, rx, ry, rz )
end
lib.rotate = rotate

--[[
	Orbits the table of objects around the 'around' object by the rotation angles ox, oy and oz.
]]--
local function orbit( objects, around, ox, oy, oz )
	local objloc, arloc = objects[1].location, around.location
	local x, y, z = objloc.x-arloc.x, objloc.y-arloc.y, objloc.z-arloc.z
	
	local matrix = math.rotateMatrix( math.newEmptyMatrix(1), ox, oy, oz )
	local post = math.multiply( { { x, y, z, 1 } }, matrix )[1]
	
	x, y, z = post[1]-x, post[2]-y, post[3]-z
	
	for i=1, #objects do
		local objloc = objects[i].location
--		objloc.x, objloc.y, objloc.z = post[1]+arloc.x, post[2]+arloc.y, post[3]+arloc.z
		objloc.x, objloc.y, objloc.z = objloc.x+x, objloc.y+y, objloc.z+z
	end
end
lib.orbit = orbit

local function moveCamera( x, y, z, rx, ry, rz )
	local xyz = cameramatrix[4]
	
	if (x) then xyz[1] = xyz[1] - x end
	if (y) then xyz[2] = xyz[2] - y end
	if (z) then xyz[3] = xyz[3] - z end
	
	if (rx) then
		cameramatrix = math.multiply( cameramatrix, math.newXRotationMatrix( -rx ) )
	end
	
	if (ry) then
		cameramatrix = math.multiply( cameramatrix, math.newYRotationMatrix( -ry ) )
	end
	
	if (rz) then
		cameramatrix = math.multiply( cameramatrix, math.newZRotationMatrix( -rz ) )
	end
end
lib.moveCamera = moveCamera

------------------------------------------------------------------------------

local prev = nil
Runtime:addEventListener( "touch", function(e)
	if (e.phase == "began") then
		prev = e
	else
		moveCamera( (e.x-prev.x)/1, (e.y-prev.y)/1 )
		prev = e
	end
	return true
end )

local smoothfactor = .1

local function newTouchPoint(e)
	local group = display.newGroup()
	group.x, group.y = e.x, e.y
	e.target = group
	
	function group:touch(e)
		if (e.phase == "began") then
			e.target.hasFocus = true
			display.currentStage:setFocus( group )
			e.target.prev = e
			isTouchHappening = true
			return true
		elseif (e.target.hasFocus) then
			
			matrix = math.multiply( matrix, math.newYRotationMatrix( (e.target.prev.x-e.x)*smoothfactor ) )
			matrix = math.multiply( matrix, math.newXRotationMatrix( (e.y-e.target.prev.y)*smoothfactor ) )
			
			lib.light[1], lib.light[2] = drawlayer:contentToLocal( e.x, e.y )
			
			e.target.prev = e
			
			if (e.phase == "moved") then
			else
				e.target.hasFocus = true
				display.currentStage:setFocus( nil )
				group = display.remove( group )
				isTouchHappening = false
			end
			return true
		end
		return false
	end
	group:addEventListener( "touch", group )
	
	return group:touch(e)
end

--[[
Runtime:addEventListener( "touch", function(e)
	if (e.phase == "began") then
		return newTouchPoint(e)
	end
	return false
end )

Runtime:addEventListener( "tap", function(e)
	isRotationHappening = not isRotationHappening
	return true
end )
]]--

return lib
