-- general testing file

local iolib = require("iolib")
local json = require("json")
local matrixlib = require("3d.matrixlib")
local shapelib = require("3d.shapelib")
local texturelib = require("3d.texturelib")
local widget = require( "widget" )

local function getImageDimensions( ... )
	local image = display.newImage( unpack( arg ) )
	local dims = { width=image.width, height=image.height }
	image = display.remove( image )
	return dims
end

local function testLineStretch()
	local image = display.newImage( "3d/monkeyswing.png" )
	image.x, image.y = display.actualCenterX, display.actualCenterY-250
	display.newRect( image.x, image.y, 100, 100 ).alpha = .4
	
	local a, b = display.newCircle( display.actualCenterX, display.actualContentHeight*.24, 20 ), display.newCircle( display.actualCenterX, display.actualContentHeight*.36, 20 )
	
	local line = display.newLine( a.x, a.y, b.x, b.y )
	local dot = display.newCircle( (a.x+b.x)/2, (a.y+b.y)/2, 15 )
	
	display.newRect( display.actualCenterX, display.actualContentHeight*.8, 100, 100 )
	local rect = display.newRect( display.actualCenterX, display.actualContentHeight*.8, 100, 100 )
	
	local trans
	
	local function touch(e)
		e.target.x, e.target.y = e.x, e.y
		
		if (trans) then trans=transition.cancel( trans ) end
		
		display.remove( line )
		line = display.newLine( a.x, a.y, b.x, b.y )
		
		display.remove( rect )
		rect = display.newRect( display.actualCenterX, display.actualContentHeight*.8, 0.0001, math.lengthOf( a, b ) )
		
		display.remove( dot )
		dot = display.newCircle( (a.x+b.x)/2, (a.y+b.y)/2, 15 )
		
		local dx, dy = image:contentToLocal( dot.x, dot.y )
		
		rect.fill = { type="image", filename="3d/monkeyswing.png" }
		rect.fill.scaleX, rect.fill.scaleY = image.width/rect.width, image.height/rect.height
		rect.fill.x, rect.fill.y = dx/image.width, dy/image.height
		rect.fill.rotation = math.angleOf( a, b ) - 90
		
--		rect.width = 300
		
		local shift = 300
		trans = transition.to( rect.path, { time=2000, x1=-shift, x2=-shift, x3=shift, x4=shift } )
--		rect.path.x1 = -350
--		rect.path.x2 = -350
--		rect.path.x3 = 350
--		rect.path.x4 = 350
		
		return true
	end
	a:addEventListener( "touch", touch )
	b:addEventListener( "touch", touch )
	
	touch{ name="touch", phase="began", target=a, x=a.x, y=a.y }
end
--testLineStretch()

local function testRectFill()
	local g = display.newGroup()
	g.x, g.y = display.actualCenterX, display.actualCenterY
	
	local e = display.newImage( "3d/earth.png" )
	local d = { width=e.width, height=e.height }
	e = display.remove( e )
	
	local m = 25
	
	local colwidth, rowheight = d.width/m, d.height/m
	
	for r=1, m do
		for c=1, m do
			local rect = display.newRect(
				g,
				-d.width/2 + c*colwidth - colwidth/2,
				-d.height/2 + r*rowheight - rowheight/2,
				colwidth, rowheight
			)
			rect.fill = { filename="3d/earth.png", type="image" }
			rect.fill.scaleX, rect.fill.scaleY = m, m
			rect.fill.x, rect.fill.y = rect.x/d.width, rect.y/d.height
			local x, y = rect.x, rect.y
			transition.to( rect, { delay=1000, time=2000, x=rect.x*1.1, y=rect.y*1.1 } )
			transition.to( rect, { delay=5000, time=2000, x=x, y=y } )
		end
	end
end
--testRectFill()

local function testShadeMonkey()
	local image = display.newImage( "3d/monkeyswing.png" )
	image.x, image.y = display.actualCenterX, display.actualContentHeight*.82
	image:setFillColor( .5,1,.5,1 )
	
	local y = display.actualCenterY
	
	local widget = require("widget")
	
	local red, green, blue, alpha
	
	local function sliderListener( event )
		image:setFillColor( red.value/100, green.value/100, blue.value/100, alpha.value/100 )
	end
	
	display.newText{ x=display.actualCenterX, y=y+100, text="red" }
	red = widget.newSlider {
		top = y+100,
		left = 50,
		width = 650,
		value = 100,
		listener = sliderListener
	}
	
	display.newText{ x=display.actualCenterX, y=y+150, text="green" }
	green = widget.newSlider {
		top = y+150,
		left = 50,
		width = 650,
		value = 100,
		listener = sliderListener
	}
	
	display.newText{ x=display.actualCenterX, y=y+200, text="blue" }
	blue = widget.newSlider {
		top = y+200,
		left = 50,
		width = 650,
		value = 100,
		listener = sliderListener
	}
	
	display.newText{ x=display.actualCenterX, y=y+250, text="alpha" }
	alpha = widget.newSlider {
		top = y+250,
		left = 50,
		width = 650,
		value = 100,
		listener = sliderListener
	}
	
	image.y = alpha.y + image.height*.6
	
	sliderListener()
end
--testShadeMonkey()

-- http://cpetry.github.io/NormalMap-Online/
-- https://forums.coronalabs.com/topic/62669-has-anyone-discovered-a-good-technique-to-animate-point-lights/?hl=normalmapwith1dirlight#entry325153
local function testNormalMapping()
	local g = display.newGroup()
	g.x, g.y = display.actualCenterX, display.actualCenterY
	
	local e = display.newImage( "3d/earth.png" )
	local d = { width=e.width, height=e.height }
	e = display.remove( e )
	
	local object = display.newRect( g, 0, 0, d.width, d.height )
	
	local compositePaint = {
		type="composite",
		paint1={ type="image", filename="3d/earth.png" },
		paint2={ type="image", filename="3d/earthnormal.png" }
	}
	
	object.fill = compositePaint
	object.fill.effect = "composite.normalMapWith1DirLight"
	
	local x, y = math.random(-10,10)/10, math.random(-10,10)/10
	
	object.fill.effect.dirLightDirection = { x, y, 1 }
	object.fill.effect.dirLightColor = { 1, 1, 1, 1 }
	object.fill.effect.ambientLightIntensity = 1
	
	local pt = {x=0,y=-250}
	local dot = display.newCircle( g, 0, -250, 5 )
	dot.fill = {1,.5,.5}
	
	timer.performWithDelay( 50, function()
		pt = math.rotateTo( pt, 2 )
		dot.x, dot.y = pt.x, pt.y
		object.fill.effect.dirLightDirection = { pt.x/250, pt.y/250, 0 }
	end, 0 )
end
--testNormalMapping()

local function testStripMesh()
	local function dot( mesh, index, vertices )
		local ox, oy = mesh.path:getVertexOffset()
		local x, y = mesh.path:getVertex( index )
		local dot = display.newCircle( mesh.x-ox+x, mesh.y-oy+y, 15 )
		
		dot:addEventListener( "touch", function(e)
			dot.x, dot.y = e.x, e.y
			local x, y = mesh:contentToLocal( e.x, e.y )
			mesh.path:setVertex( index, x+ox, y+oy )
			return true
		end )
	end
	
	local vertices = {
		0,0,
		0,500,
		250,0,
		500,500,
		500,0
	}
	
	local mesh = display.newMesh(
		{
			x = display.actualCenterX,
			y = display.actualContentHeight*.75,
			mode = "strip",
			vertices = vertices
		})
	
	mesh.fill = { type="image", filename="3d/earth.png" }
	
	local vertexX, vertexY = mesh.path:getVertex( 3 )
	mesh.path:setVertex( 3, vertexX, vertexY )
	
	for i=1, #vertices-1, 2 do
		dot( mesh, (i+1)/2, vertices )
	end
end
--testStripMesh()

local function testBrightness()
	local earth = display.newImage( "3d/earth.png" )
	earth.x, earth.y = display.actualCenterX, display.actualCenterY
	earth.xScale, earth.yScale = .5, .5
	
	earth.fill.effect = "filter.levels"
	earth.fill.effect.white = 1
	earth.fill.effect.black = 0
	
	local pt = display.newCircle( display.actualCenterX, display.actualCenterY, 15 )
	pt.fill = {1,.5,.5}
	pt.z = -1500
	
	local t = display.newText{ x=pt.x, y=200, text="", fontSize=60 }
	
	local faceta = {
		{ pt.x-pt.width/2, pt.y-pt.height/2, 10 },
		{ pt.x-pt.width/2, pt.y+pt.height/2, 10 },  
		{ pt.x+pt.width/2, pt.y+pt.height/2, 10 },  
--		{ pt.x+pt.width/2, pt.y-pt.height/2, 10 },  
	}
	local facetb = {
--		{ pt.x-pt.width/2, pt.y+pt.height/2, 10 },  
		{ pt.x+pt.width/2, pt.y+pt.height/2, 10 },  
		{ pt.x+pt.width/2, pt.y-pt.height/2, 10 },  
		{ pt.x-pt.width/2, pt.y-pt.height/2, 10 },  
	}
	
	Runtime:addEventListener( "touch", function(e)
		pt.x, pt.y = e.x, e.y
--		local ba = (math.abs( getBrightness( {pt.x,pt.y,pt.z}, faceta ) ) * 1)
		local ba = getBrightness( {pt.x,pt.y,pt.z}, faceta )
--		local bb = 1 - (math.abs( getBrightness( pt, facetb ) ) * 1)
--		local c = (ba+bb)/2
		t.text = ba
		earth.fill.effect.gamma = ba
		return true
	end )
end
--testBrightness()

local function testFx()
	local earth = display.newImage( "3d/earth.png" )
	earth.x, earth.y = display.actualCenterX, display.actualCenterY
	earth.xScale, earth.yScale = .65, .65
	earth.fill.effect = "filter.levels"
	earth.fill.effect.white = 0.5
	earth.fill.effect.black = 0.1
	earth.fill.effect.gamma = 1
	
	local widget = require("widget")
	
	local white, black, gamma
	
	local function sliderListener( event )
		earth.fill.effect.white = white.value/100
		earth.fill.effect.black = black.value/100
		earth.fill.effect.gamma = gamma.value/100
	end
	
	display.newText{ x=display.actualCenterX, y=70, text="white" }
	white = widget.newSlider {
		top = 100,
		left = 50,
		width = 650,
		value = 50,  -- Start slider at 10% (optional)
		listener = sliderListener
	}
	
	display.newText{ x=display.actualCenterX, y=170, text="black" }
	black = widget.newSlider {
		top = 200,
		left = 50,
		width = 650,
		value = 10,  -- Start slider at 10% (optional)
		listener = sliderListener
	}
	
	display.newText{ x=display.actualCenterX, y=270, text="gamma" }
	gamma = widget.newSlider {
		top = 300,
		left = 50,
		width = 650,
		value = 100,  -- Start slider at 10% (optional)
		listener = sliderListener
	}
	
	sliderListener()
end
--testFx()

local function compositeTest()
	local object = display.newRect( display.actualCenterX, display.actualCenterY, 500, 250 )
	
	-- Set up the composite paint (distinct images)
	local compositePaint = {
		type="composite",
		paint1={ type="image", filename="3d/earth.png" },
		paint2={ type="image", filename="3d/normalearth.png" }
	}
	
	-- Apply the composite paint as the object's fill
	object.fill = compositePaint
	
	-- Set a composite blend as the fill effect
	object.fill.effect = "composite.normalMapWith1DirLight"
	
	object.fill.effect.dirLightDirection = { 1, 0, 0 }
	object.fill.effect.dirLightColor = { 0.3, 0.4, 1, 0.8 }
	object.fill.effect.ambientLightIntensity = 1
	
	object.fill.scaleX, object.fill.scaleY = 2, 2
end
--compositeTest()

local function test3dAngle()
	local centre = display.newCircle( display.actualCenterX, display.actualCenterY, 10 )
	centre.fill = {1,0,0}

	local pt = display.newCircle( display.actualCenterX, display.actualCenterY-100, 10 )
	pt.fill = {0,0,1}

	local t = display.newText{ x=display.actualCenterX, y=200, text="0", fontSize=50 }

	local a = 0

	timer.performWithDelay( 10, function()
		local p = math.rotateTo( {x=0,y=-100}, a )
		pt.x, pt.y = display.actualCenterX+p.x, display.actualCenterY+p.y
		a = a + 1
		p.z=p.y
		p.y=0
		t.text = a..": "..tostring(vector3dAngleOf( {x=100,y=0,z=0}, p ))
	end, 360 )
end
--test3dAngle()

local function testShader()
	local rect = display.newRect( display.actualCenterX, display.actualCenterY, 200, 200 )
	local compositePaint = {
		type="composite",
		paint1={ type="image", filename="3d/earth.png" },
		paint2={ type="image", filename="3d/black.png" }
	}
	rect.fill = {type="image",filename="3d/earth.png"}
	rect.fill.effect = "filter.bloom"
--	rect.fill.effect.levels.white = 0.9
rect.fill.effect.levels.black = 0.1
--	rect.fill.effect.levels.gamma = 1
rect.fill.effect.add.alpha = .2
--	rect.fill.effect.blur.horizontal.blurSize = 20
--	rect.fill.effect.blur.horizontal.sigma = 140
--	rect.fill.effect.blur.vertical.blurSize = 20
--	rect.fill.effect.blur.vertical.sigma = 240
transition.to( rect.fill.effect.levels, { time=3000, black=1 } )
	
	local pt = display.newCircle( display.actualCenterX, display.actualCenterY, 10 )
	pt.fill = {1,.5,.5}
	
	Runtime:addEventListener( "touch", function(e)
		pt.x, pt.y = e.x, e.y
		e.z = 1000
		
		local alen = lengthOf3d( e, {x=display.actualCenterX-100, y=display.actualCenterY-100, z=100} )
		local blen = lengthOf3d( e, {x=display.actualCenterX-100, y=display.actualCenterY+100, z=100} )
		local clen = lengthOf3d( e, {x=display.actualCenterX+100, y=display.actualCenterY+100, z=100} )
		local dlen = lengthOf3d( e, {x=display.actualCenterX+100, y=display.actualCenterY-100, z=100} )
		
		local ab = math.abs( alen-blen )
		local bc = math.abs( blen-clen )
		
		local bright = ab
		if (bc > ab) then bright=bc end
		
		print(ab,bc,bright)
		
--		rect.
		
		return true
	end )
end
--testShader()

local function find3dDirectionVector()
	local group = display.newGroup()
	group.x, group.y = display.actualCenterX, display.actualCenterY
	
	local a = {
--		transformed={}, flat={}, image=display.newPathRect( group,0,0,200,200 ),
--		{ -100, -100, -100, 1 },
--		{ -100, 100, -100, 1 },
--		{ 100, 100, -100, 1 },
--		{ 100, -100, -100, 1 },
		{ 100, -100, -100, 1 },
		{ 100, 100, -100, 1 },
		{ 100, 100, 100, 1 },
		{ 100, -100, 100, 1 },
	}
	local b = {
		transformed={}, flat={}, image=display.newPathRect( group,0,0,200,200 ),
		{ -100, -100, -100, 1 },
		{ -100, 100, -100, 1 },
		{ 100, 100, -100, 1 },
		{ 100, -100, -100, 1 },
	}
	local c = {
		transformed={}, flat={}, image=display.newPathRect( group,0,0,200,200 ),
		{ -10, 0, -100, 1 },
		{ -10, 0, -200, 1 },
		{ 10, 0, -200, 1 },
		{ 10, 0, -100, 1 },
	}
	local d = {
		transformed={}, flat={}, image=display.newPathRect( group,0,0,200,200 ),
		{ 100, -10, 0, 1 },
		{ 100, 10, 0, 1 },
		{ 200, 10, 0, 1 },
		{ 200, -10, 0, 1 },
	}
	
	local t = math.newTranslationMatrix( 0, 0, 100 )
	
	local _X, _Y, _Z = math.random(0,360), math.random(0,360), math.random(0,360)
	local matrix = math.multiply( math.newYRotationMatrix( _Y ), math.newXRotationMatrix( _X ) )
	matrix = math.multiply( matrix, math.newZRotationMatrix( _Z ) )
	matrix = math.multiply( matrix, t )
	
	matrixlib.processFacet( b, matrix )
	matrixlib.processFacet( c, matrix )
	
	local plane = table.unpack( b.flat, {"x","y"} )
	b.image:setPath( unpack( plane ) )
	if (b.image.isVisible) then
		b.image:setFillColor( 0,1,0 )
	else
		b.image:setFillColor( 1,0,0 )
		b.image.isVisible = true
	end
	
	local planec = table.unpack( c.flat, {"x","y"} )
	c.image:setPath( unpack( planec ) )
	c.image.isVisible = true
	c.image:setFillColor( 0,0,1,.5 )
	
--	print(json.prettify(json.encode(b)))
	
	-- http://stackoverflow.com/questions/38551514/find-the-direction-vector-of-3d-facet
	-- http://www.intmath.com/vectors/7-vectors-in-3d-space.php#anglebetweenvectors
	local bt = b.transformed
	
	local function getLookAtMatrix( bt )
		local T = math.normalise2d3dVector( math.subtract2d3dVectors( bt[2], bt[1] ) ) -- normalize(P1 - P0)
		local N = math.normalise2d3dVector( math.crossProduct3d( math.subtract2d3dVectors( bt[3], bt[1] ), T ) ) -- normalize(cross(T, P2 - P0))
		local B = math.normalise2d3dVector( math.crossProduct3d( T, N ) ) -- normalize(cross(T, N))
		local rotmat = math.new3dMatrix( T, B, N ) -- rotMat = mat3(T, N, B)
		return rotmat
	end
	local rotmat = getLookAtMatrix( bt )
	
	rotmat = math.multiply( math.newXRotationMatrix( 0 ), rotmat )
	
	local post = a
	post.transformed = {}
	post.flat = {}
	post.image = display.newPathRect( group,0,0,200,200 )
	post.image.fill = {0,0,0,0}
	post.image.strokeWidth = 10
	
	matrixlib.processFacet( d, rotmat )
	local planed = table.unpack( d.flat, {"x","y"} )
	d.image:setPath( unpack( planed ) )
	d.image.isVisible = true
	d.image:setFillColor( 0,1,1,.5 )
	
	matrixlib.processFacet( a, rotmat )
	
	local plane = table.unpack( post.flat, {"x","y"} )
	post.image:setPath( unpack( plane ) )
	
	if (post.image.isVisible) then
--		post.image:setFillColor( 0,0,0 )
		post.image.stroke = { 0,0,0 }
		post.image.isVisible = true
	else
--		post.image:setFillColor( 0,0,1 )
		post.image.stroke = { 0,0,1 }
		post.image.isVisible = true
	end
	
	return group
end
--local g = find3dDirectionVector()
--timer.performWithDelay( 750, function()
--g = display.remove(g)
--g = find3dDirectionVector()
--end, 20 )

local function findDirVec( x, y, z )
	local group = display.newGroup()
	group.x, group.y = display.actualCenterX, display.actualCenterY
	
	local a = {
		transformed={}, flat={}, image=display.newPathRect( group,0,0,200,200 ),
		{ -100, -100, -100, 1 },
		{ -100, 100, -100, 1 },
		{ 100, 100, -100, 1 },
		{ 100, -100, -100, 1 },
	}
	a.image.fill = {0,1,0}
	a.image.strokeWidth = 0
	
	local b = {
		transformed={}, flat={}, image=display.newPathRect( group,0,0,200,200 ),
		{ -100, -100, -100, 1 },
		{ -100, 100, -100, 1 },
		{ 100, 100, -100, 1 },
		{ 100, -100, -100, 1 },
--		{ -100, -100, 100, 1 },
--		{ -100, 100, 100, 1 },
--		{ -100, 100, -100, 1 },
--		{ -100, -100, -100, 1 },
	}
	b.image.fill = {0,0,0,0}
	b.image.stroke = {1,0,0}
	b.image.strokeWidth = 10
	b.image.isVisible = false
	
	local matrix, X, Y, Z, away =
		math.newXRotationMatrix( 0 ),
		math.newXRotationMatrix( x ), -- math.random(0,360) ),
		math.newYRotationMatrix( y ), -- math.random(0,360) ),
		math.newZRotationMatrix( z ), -- math.random(0,360) ),
		math.newTranslationMatrix( 0, 0, 10 )
	
	matrix = math.multiply( matrix, X )
	matrix = math.multiply( matrix, Y )
	matrix = math.multiply( matrix, Z )
	matrix = math.multiply( matrix, away )
	
	matrixlib.processFacet( a, matrix )
	
	a.image:setPath( unpack( table.unpack( a.flat, {"x","y"} ) ) )
	
	if (a.image.isVisible) then
		a.image:setFillColor( 0,1,0 )
	else
		a.image:setFillColor( 1,0,0 )
		a.image.isVisible = true
	end
	
	-- ----------------------------
	
	-- initialise direction rotation matrix
	local dirmat = {
		{1,0,0},
		{0,1,0},
		{0,0,1},
	}
	
	-- Vector3 forward = object2.pos - object1.pos
	local dirvec = math.getNormalDirectionVectorOfFacet( a.transformed )
	
	-- forward.normalize()
	dirvec = math.normalise2d3dVector( dirvec )
	
	-- Vector3 up = new Vector3( 0, 1, 0 )
	dirmat[1][1], dirmat[2][1], dirmat[3][1] = dirvec[1], dirvec[2], dirvec[3]
	
	-- Vector3 tangentTheta = CrossProduct( forward, up )
	local tangent = math.crossProduct3d( dirvec, {0,1,0} )
	
	-- if (tangentTheta.length < .001) then
	if (math.vector2d3dLength( tangent ) < .001) then
		-- up = new Vector3( 1, 0, 0 )
		dirmat[1][2], dirmat[2][2], dirmat[3][2] = 1, 0, 0
		-- tangentTheta = CrossProduct( forward, up )
		tanget = math.crossProduct3d( dirvec, {1,0,0} )
	end
	
	-- tangentTheta.normalize()
	local normaltangent = math.normalise2d3dVector( tangent )
	
	-- up = CrossProduct( forward, tangentTheta )
	local normalcross = math.normalise2d3dVector( math.crossProduct3d( tangent, dirvec ) )
	
	-- Matrix rotation = new Matrix(
	-- 	forward.x, up.x, tangentTheta.x,
	-- 	forward.y, up.y, tangentTheta.y,
	-- 	forward.z, up.z, tangentTheta.z,
	-- )
	dirmat[1][2], dirmat[2][2], dirmat[3][2] = normalcross[1], normalcross[2], normalcross[3]
	dirmat[1][3], dirmat[2][3], dirmat[3][3] = normaltangent[1], normaltangent[2], normaltangent[3]
	
	dirmat[1][4], dirmat[2][4], dirmat[3][4] = 0, 0, 0
	dirmat[4] = {0,0,0,1}
	
	math.printMatrix( dirmat )
	
	-- ----------------------------
	
	matrixlib.processFacet( b, dirmat )
	
	b.image:setPath( unpack( table.unpack( b.flat, {"x","y"} ) ) )
	
	print(json.prettify(json.encode(b.transformed)))
	
	if (b.image.isVisible) then
		b.image.stroke = { 1,1,1 }
	else
		b.image.stroke = { 0,0,0 }
		b.image.isVisible = true
	end
	
	return group
end
--local x, y, z = 0, 0, 0
--local g = findDirVec( x, y, z )
--timer.performWithDelay( 50, function()
----	y = y + 10
----	z = z + 10
--	x = x + 10
--	g = display.remove(g)
--	g = findDirVec( x, y, z )
--end, 0 )

local function findDirVec2( x, y, z )
	local group = display.newGroup()
	group.x, group.y = display.actualCenterX, display.actualCenterY
	
	local a = {
		transformed={}, flat={}, image=display.newPathRect( group,0,0,200,200 ),
		{ -100, -100, -100, 1 },
		{ -100, 100, -100, 1 },
		{ 100, 100, -100, 1 },
		{ 100, -100, -100, 1 },
	}
	a.image.fill = {0,1,0}
	a.image.strokeWidth = 0
	
	local b = {
		transformed={}, flat={}, image=display.newPathRect( group,0,0,200,200 ),
		{ -100, -100, -100, 1 },
		{ -100, 100, -100, 1 },
		{ 100, 100, -100, 1 },
		{ 100, -100, -100, 1 },
--		{ -100, -100, 100, 1 },
--		{ -100, 100, 100, 1 },
--		{ -100, 100, -100, 1 },
--		{ -100, -100, -100, 1 },
	}
	b.image.fill = {0,0,0,0}
	b.image.stroke = {1,0,0}
	b.image.strokeWidth = 10
	b.image.isVisible = false
	
	local matrix, X, Y, Z, away =
		math.newXRotationMatrix( 0 ),
		math.newXRotationMatrix( x ), -- math.random(0,360) ),
		math.newYRotationMatrix( y ), -- math.random(0,360) ),
		math.newZRotationMatrix( z ), -- math.random(0,360) ),
		math.newTranslationMatrix( 0, 0, 10 )
	
	matrix = math.multiply( matrix, X )
	matrix = math.multiply( matrix, Y )
	matrix = math.multiply( matrix, Z )
	matrix = math.multiply( matrix, away )
	
	matrixlib.processFacet( a, matrix )
	
	a.image:setPath( unpack( table.unpack( a.flat, {"x","y"} ) ) )
	
	if (a.image.isVisible) then
		a.image:setFillColor( 0,1,0 )
	else
		a.image:setFillColor( 1,0,0 )
		a.image.isVisible = true
	end
	
	-- ----------------------------
--Vector3 forward = object2.pos - object1.pos;
--forward.normalize();
--Vector3 up = new Vector3(0, 1.0, 0);
--Vector3 tangent0 = CrossProduct(forward, up);
--if (tangent0.length < 0.001f)
--{
--  up = new Vector3(1.0, 0, 0);
--  tangent0 = CrossProduct(forward, up);
--}
--tangent0.normalize();
--up = CrossProduct(forward, tangent0);
--
--Matrix rotation = new Matrix(
--  forward.x, up.x, tangent0.x,
--  forward.y, up.y, tangent0.y,
--  forward.z, up.z, tangent0.z
--);
	
	-- Vector3 forward = object2.pos - object1.pos
	local forward = math.getNormalDirectionVectorOfFacet( a.transformed )
	
	-- forward.normalize()
	forward = math.normalise2d3dVector( forward )
	
	-- Vector3 up = new Vector3( 0, 1, 0 )
	local up = {0,1,0}
	
	-- Vector3 tangentTheta = CrossProduct( forward, up )
	local tangentTheta = math.crossProduct3d( forward, up )
	
	-- if (tangentTheta.length < .001) then
	if (math.vector2d3dLength( tangentTheta ) < .001) then
		-- up = new Vector3( 1, 0, 0 )
		up = {1,0,0}
		-- tangentTheta = CrossProduct( forward, up )
		tanget = math.crossProduct3d( forward, up )
	end
	
	-- tangentTheta.normalize()
	tangentTheta = math.normalise2d3dVector( tangentTheta )
	
	-- up = CrossProduct( forward, tangentTheta )
	up = math.crossProduct3d( forward, tangentTheta )
	
	-- Matrix rotation = new Matrix(
	-- 	forward.x, up.x, tangentTheta.x,
	-- 	forward.y, up.y, tangentTheta.y,
	-- 	forward.z, up.z, tangentTheta.z,
	-- )
	local dirmatrix = {
		{ forward[1], up[1], tangentTheta[1], 0 },
		{ forward[2], up[2], tangentTheta[2], 0 },
		{ forward[3], up[3], tangentTheta[3], 0 },
		{ 0, 0, 0, 1 },
	}
	
	math.printMatrix( dirmatrix )
	
	-- ----------------------------
	
	matrixlib.processFacet( b, dirmatrix )
	
	b.image:setPath( unpack( table.unpack( b.flat, {"x","y"} ) ) )
	
	print(json.prettify(json.encode(b.transformed)))
	
	if (b.image.isVisible) then
		b.image.stroke = { 1,1,1 }
	else
		b.image.stroke = { 0,0,0 }
		b.image.isVisible = true
	end
	
	return group
end
--local x, y, z = 0, 0, 0
--local g = findDirVec2( x, y, z )
--timer.performWithDelay( 50, function()
----	y = y + 10
----	z = z + 10
--	x = x + 10
--	g = display.remove(g)
--	g = findDirVec2( x, y, z )
--end, 0 )

local function findDirVecBasic( x, y, z )
	local group = display.newGroup()
	group.x, group.y = display.actualCenterX, display.actualCenterY
	
	local a = {
		transformed={}, flat={}, image=display.newPathRect( group,0,0,200,200 ),
		{ -100, -100, -100, 1 },
		{ -100, 100, -100, 1 },
		{ 100, 100, -100, 1 },
		{ 100, -100, -100, 1 },
	}
	a.image.fill = {0,1,0}
	a.image.strokeWidth = 0
	
	local matrix, X, Y, Z, away =
		math.newXRotationMatrix( 0 ),
		math.newXRotationMatrix( x ), -- math.random(0,360) ),
		math.newYRotationMatrix( y ), -- math.random(0,360) ),
		math.newZRotationMatrix( z ), -- math.random(0,360) ),
		math.newTranslationMatrix( 0, 0, 10 )
	
	matrix = math.multiply( matrix, X )
	matrix = math.multiply( matrix, Y )
	matrix = math.multiply( matrix, Z )
	matrix = math.multiply( matrix, away )
	
	matrixlib.processFacet( a, matrix )
	
	a.image:setPath( unpack( table.unpack( a.flat, {"x","y"} ) ) )
	
	if (a.image.isVisible) then
		a.image:setFillColor( 0,1,0 )
	else
		a.image:setFillColor( 1,0,0 )
		a.image.isVisible = true
	end
	
	local vector = math.calculateSurfaceNormal( a.transformed )
	
	local b = {
		transformed={}, flat={}, image=display.newPathRect( group,0,0,200,200 ),
		{ 100, -100, 100, 1 },
		{ 100, 100, 100, 1 },
		{ -100, 100, 100, 1 },
		{ -100, -100, 100, 1 },
	}
	b.image.fill = {0,1,0}
	b.image.strokeWidth = 0
	b.image.alpha = .5
	
--	print(table.concat(math.calculateSurfaceNormal(a),","),table.concat(math.calculateSurfaceNormal(b),","))
	
	matrixlib.processFacet( b, math.newXRotationMatrix( 0 ) )
	
	b.image:setPath( unpack( table.unpack( b.flat, {"x","y"} ) ) )
	
	if (b.image.isVisible) then
		b.image:setFillColor( 0,1,0 )
	else
		b.image:setFillColor( 1,0,0 )
		b.image.isVisible = true
	end
	
	local bvector = math.calculateSurfaceNormal( b.transformed )
	
	local a1 = math.angleOf( vector[3], vector[2] )
	local b1 = math.angleOf( bvector[3], bvector[2] )
	
	local ar = math.smallestAngleDiff( a1,b1 )
	
	local pt = math.rotateTo( {x=bvector[3], y=bvector[2]}, ar, {x=0,y=0} )
	bvector[3], bvector[2] = pt.x, pt.y
	
	local a2 = math.angleOf( vector[1], vector[3] )
	local b2 = math.angleOf( bvector[1], bvector[3] )
	
	local br = math.smallestAngleDiff( a2,b2 )
	
	print( "z-y",ar,"\nx-z", br )
	
	local zy_xz = math.newXRotationMatrix( -ar )
	zy_xz = math.multiply( zy_xz, math.newYRotationMatrix( -br ) )
	
	matrixlib.processFacet( b, zy_xz )
	
	b.image:setPath( unpack( table.unpack( b.flat, {"x","y"} ) ) )
	
	if (b.image.isVisible) then
		b.image:setFillColor( 0,0,1 )
		b.image.isVisible = true
	else
		b.image:setFillColor( 0,1,1 )
		b.image.isVisible = true
	end
	
end
--findDirVecBasic( 0, 0, math.random(0,360) )

local function testImageSheetMapping()
	local g = display.newGroup()
	g.x, g.y = display.actualCenterX, display.actualCenterY
	
	local image = getImageDimensions( "3d/earth.png" )
	local normal = getImageDimensions( "3d/earthnormal.png" )
	
	local options =
	{
		width = image.width,
		height = image.height,
		numFrames = 1,
		sheetContentWidth = image.width,
		sheetContentHeight = image.height,
	}
	local options =
	{
		frames={
			{
				x=0, y=0,
				width=image.width/2, height=image.height/2,
			},
			{
				x=image.width/2, y=0,
				width=image.width/2, height=image.height/2,
			},
			{
				x=0, y=image.height/2,
				width=image.width/2, height=image.height/2,
			},
			{
				x=image.width/2, y=image.height/2,
				width=image.width/2, height=image.height/2,
			},
		},
		sheetContentWidth = image.width,
		sheetContentHeight = image.height,
	}
	
	local imageSheet = graphics.newImageSheet( "3d/earth.png", options )
	local imageSheetNormal = graphics.newImageSheet( "3d/earthnormal.png", options )
	
	local rect = display.newRect( g, 0, 0, image.width/2, image.height/2 )
	
	local frame = 1
	
	local compositePaint = {
		type="composite",
		paint1={
			type = "image",
			sheet = imageSheet,
			frame = frame
		},
		paint2={
			type = "image",
			sheet = imageSheetNormal,
			frame = frame
		},
	}
	
	rect.fill = compositePaint
	
	local x, y = math.random(-10,10)/10, math.random(-10,10)/10
	
	rect.fill.effect = "composite.normalMapWith1DirLight"
	rect.fill.effect.dirLightDirection = { x, y, 1 }
	rect.fill.effect.dirLightColor = { 1, 1, 1, 1 }
	rect.fill.effect.ambientLightIntensity = 1
	
	local pt = {x=0,y=-250}
	local dot = display.newCircle( g, 0, -250, 5 )
	dot.fill = {1,.5,.5}
	
	timer.performWithDelay( 50, function()
		pt = math.rotateTo( pt, 10 )
		dot.x, dot.y = pt.x, pt.y
		rect.fill.effect.dirLightDirection = { pt.x/250, pt.y/250, 0 }
	end, 0 )
end
--testImageSheetMapping()

local function testImageSheet()
	local function getImageSheet( render )
		local frames =
		{
			{ name="face", 565,254 , 565,400 , 773,400 , 773,254 },		-- face
			{ name="top", 565,47 , 565,254 , 773,254 , 773,47 },		-- top
			{ name="bottom", 565,400 , 565,607 , 773,607 , 773,400 },	-- bottom
			{ name="right", 773,254 , 773,400 , 981,400 , 981,254 },	-- right
			{ name="left", 357,254 , 357,400 , 565,400 , 565,254 },		-- left
			{ name="back", 149,254 , 149,400 , 357,400 , 357,254 },		-- back
		}
		
		local dim = getImageDimensions( "3d/cubes/spock.png" )
		
		local framelist = {}
		
		local options = {
			frames = framelist,
			sheetContentWidth = dim.width,
			sheetContentHeight = dim.height,
		}
		
		for i=1, #frames do
			local frame = frames[i]
			framelist[#framelist+1] = {
				x=frame[1], y=frame[2],
				width=frame[5]-frame[1], height=frame[6]-frame[2],
			}
		end
		
		if (render == nil or render == true) then
			local imagesheet = graphics.newImageSheet( "3d/cubes/spock.png", options )
			
			for i=1, #options.frames do
				local rect = display.newRect(
					display.actualCenterX, display.actualContentHeight/8*i*1.2,
					options.frames[i].width, options.frames[i].height )
					
				rect.fill = { type="image", sheet=imagesheet, frame=i }
			end
		end
		
		return options
	end
	
	local function getFacetObjects( options )
		local objects = {}
		
		for i=1, #options.frames do
			objects[#objects+1] = {
				isDirtyRender = true,
				group = nil,
				filename = "3d/cubes/spock.png",
				matrix=nil,
				{
					flat={},
					transformed={},
					filename=nil,
					image=nil,
					rect={
						width=options.frames[i].width,
						height=options.frames[i].height,
					},
					fill={ process="imagesheet" },
					frame=options.frames[i],
					{ options.frames[i].x, options.frames[i].y, 0, 1 },
					{ options.frames[i].x, options.frames[i].y+options.frames[i].height, 0, 1 },
					{ options.frames[i].x+options.frames[i].width, options.frames[i].y+options.frames[i].height, 0, 1 },
					{ options.frames[i].x+options.frames[i].width, options.frames[i].y, 0, 1 },
				}
			}
		end
		
		return objects
	end
	
	local options = getImageSheet( false )
	local objects = getFacetObjects( options )
	
--	print(json.prettify(json.encode(objects)))
	
	return options, objects
end
--testImageSheet()

local function testEnvironment()
	local sun = shapelib.newSphere( "3d/sun.jpg", "3d/earthnormal.jpg", 100, 10, 10 )
	local earth = shapelib.newSphere( "3d/earth.png", "3d/earthnormal.jpg", 50, 10, 10 )
	local moon = shapelib.newSphere( "3d/moon.jpg", "3d/moonnormal.jpg", 20, 10, 10 )
	
	matrixlib.add( sun )
	matrixlib.add( earth )
	matrixlib.add( moon )
	
	matrixlib.start()
	matrixlib.rotate( earth, 0, 0, 23.5 )
	
	matrixlib.translate( sun, 0, 0, 50 )
	matrixlib.translate( earth, 250, 0, 50 )
	matrixlib.translate( moon, 350, 0, 50 )
	
	timer.performWithDelay( 1000/60, function()
		matrixlib.rotate( sun, 0, -1 )
--		matrixlib.rotate( moon, 0, 1 )
		
		matrixlib.rotate( earth, 0, 1, 0 )
		
--		matrixlib.orbit( {earth}, sun, 0, 3, 2 )
		matrixlib.orbit( {earth,moon}, sun, 0, 2, 2 )
		matrixlib.orbit( {moon}, earth, 0, -1, 0 )
	end, 0 )
end
testEnvironment()

local function testFold()
	local nothingmatrix = math.newTranslationMatrix( 0, 0, 0 )
	
	local facets = {
		name = "folder",
		isDirtyRender = true,
		group = nil, -- will reference the facets table when textured
		filename = filename,
		normalfilename = normalfilename,
		flat = nil, -- flattened points for the whole shape (includes z)
		transformed = nil, -- points for the whole shape
		matrix = math.newXRotationMatrix(0), -- will be this object's transform matrix
		location = {x=0,y=0,z=0,rx=0,ry=0,rz=0}, -- location in space
		aligns = {
			-- {}, {}: facet to transform, facet to align with
			-- facet: index of facet
			-- a, b: point indices to align
			{ { facet=2, a=1, b=2 }, { facet=1, a=4, b=3 } },
			{ { facet=3, a=1, b=4 }, { facet=1, a=2, b=3 } },
			{ { facet=4, a=1, b=2 }, { facet=2, a=4, b=3 } },
			{ { facet=5, a=4, b=3 }, { facet=3, a=1, b=2 } },
			{ { facet=6, a=4, b=3 }, { facet=5, a=1, b=2 } },
		},
		joins = {
			-- {}, {}: data for each facet involved in a join
			-- facet: index of the facet being joined
			-- a, b: indices of the axis points to rotate around (nil to avoid rotating)
			-- join: index of the point on this facet to join
			-- ext: list of facets to transform cumulatively with this facet transform
			{ { facet=2, a=1, b=2, join=3, ext={4} }, { facet=3, a=1, b=4, join=3, ext={5,6} } },
			{ { facet=4, a=1, b=2, join=3, ext={} }, { facet=3, a=nil, b=nil, join=2, ext={} } },
			{ { facet=5, a=3, b=4, join=1, ext={6} }, { facet=1, a=nil, b=nil, join=1, ext={} } },
			{ { facet=6, a=3, b=4, join=1, ext={} }, { facet=1, a=nil, b=nil, join=4, ext={} } },
		}
	}
	
	facets[#facets+1] = {
		flat={},
		transformed={},
		filename=nil,
		image=nil,
		isAlwaysVisible=true,
		rect={ width=200, height=200 },
		fill={ process="rgb", 1,.5,.5 },
		frame=nil,
		{ -100,-100,0,1 },
		{ -100,100,0,1 },
		{ 100,100,0,1 },
		{ 100,-100,0,1 },
--		{ -141,0,0,1 },
--		{ 0,141,0,1 },
--		{ 141,0,0,1 },
--		{ 0,-141,0,1 },
		matrix = nothingmatrix,
	}
	facets[#facets+1] = {
		flat={},
		transformed={},
		filename=nil,
		image=nil,
		isAlwaysVisible=true,
		rect={ width=200, height=200 },
		fill={ process="rgb", .5,1,.5 },
		frame=nil,
		{ 100,-100,0,1 },
		{ 100,100,0,1 },
		{ 300,100,0,1 },
		{ 300,-100,0,1 },
--		{ 222,-220,0,1 },
--		{ 170,-27,0,1 },
--		{ 363,24,0,1 },
--		{ 415,-168,0,1 },
		matrix = nothingmatrix, -- math.multiply( math.newZRotationMatrix(15), math.newTranslationMatrix( 100, -150, 0 ) )
	}
--	matrixlib.processObject(facets,nothingmatrix)
--	dump(unpack(facets[#facets].transformed))
	facets[#facets+1] = {
		flat={},
		transformed={},
		filename=nil,
		image=nil,
		isAlwaysVisible=true,
		rect={ width=200, height=200 },
		fill={ process="rgb", .5,.5,1 },
		frame=nil,
--		{ -100,100,0,1 },
--		{ -100,300,0,1 },
--		{ 100,300,0,1 },
--		{ 100,100,0,1 },
		{ -22,220,0,1 },
		{ -74,413,0,1 },
		{ 118,465,0,1 },
		{ 170,272,0,1 },
		matrix = nothingmatrix, -- math.multiply( math.newZRotationMatrix(15), math.newTranslationMatrix( 100, 150, 0 ) ),
	}
--	matrixlib.processObject(facets,nothingmatrix)
--	dump(unpack(facets[#facets].transformed))
	facets[#facets+1] = {
		flat={},
		transformed={},
		filename=nil,
		image=nil,
		isAlwaysVisible=true,
		rect={ width=200, height=200 },
		fill={ process="rgb", 1,.75,0 },
		frame=nil,
		{ 300,-100,0,1 },
		{ 300,100,0,1 },
		{ 500,100,0,1 },
		{ 500,-100,0,1 },
		matrix = nothingmatrix,
	}
	facets[#facets+1] = {
		flat={},
		transformed={},
		filename=nil,
		image=nil,
		isAlwaysVisible=true,
		rect={ width=200, height=200 },
		fill={ process="rgb", 1,.5,.25 },
		frame=nil,
		{ -300,100,0,1 },
		{ -300,300,0,1 },
		{ -100,300,0,1 },
		{ -100,100,0,1 },
		matrix = nothingmatrix,
	}
	facets[#facets+1] = {
		flat={},
		transformed={},
		filename=nil,
		image=nil,
		isAlwaysVisible=true,
		rect={ width=200, height=200 },
		fill={ process="rgb", .9,.9,.9 },
		frame=nil,
		{ -500,100,0,1 },
		{ -500,300,0,1 },
		{ -300,300,0,1 },
		{ -300,100,0,1 },
		matrix = nothingmatrix,
	}
	
	facets = texturelib.generateTextureSheet( "3d/cubes/spock.png", nil, texturelib.spock, "mesh", true, true )
	
	matrixlib.add( facets )
	matrixlib.start()
	
	local function rotateForJoin( facets, joinindex, r )
		local function getShiftedRotationAxis( facets, join )
			if (join.a == nil or join.b == nil) then return nil end
			
			local facet = facets[join.facet].transformed
			local a, b = facet[join.a], facet[join.b]
			
			return { b[1]-a[1], b[2]-a[2], b[3]-a[3] }
		end
		
		local function getAxisShift( facet, join )
			local vertex = facet.transformed
			return -vertex[join.a][1], -vertex[join.a][2], -vertex[join.a][3]
		end
		
		local function foldFacet( facet, join, axis, r )
			local x, y, z = getAxisShift( facet, join )
			
			facet.foldmatrix = math.multiply(
				math.newTranslationMatrix( x, y, z ),
				math.newAxisRotationMatrix( r, axis[1], axis[2], axis[3] ),
				math.newTranslationMatrix( -x, -y, -z )
			)
			
			facet.matrix = math.multiply( facet.shiftmatrix, facet.parentmatrix, facet.foldmatrix )
			
			for i=1, #join.ext do
				local extfacet = facets[join.ext[i]]
				extfacet.parentmatrix = math.multiply( facet.parentmatrix, facet.foldmatrix )
				extfacet.matrix = math.multiply( extfacet.shiftmatrix, extfacet.parentmatrix )
			end
		end
		
		local m = facets.matrix
		facets.matrix = nothingmatrix
		
		matrixlib.processObject( facets )
		
		local fold = facets.joins[joinindex]
		local joinA, joinB = fold[1], fold[2]
		local facetA, facetB = facets[joinA.facet], facets[joinB.facet]
		local axisA, axisB = getShiftedRotationAxis( facets, joinA ), getShiftedRotationAxis( facets, joinB )
		
		if (axisA) then
			foldFacet( facetA, joinA, axisA, r )
		end
		if (axisB) then
			foldFacet( facetB, joinB, axisB, -r )
		end
		
		facets.matrix = m
		matrixlib.processObject( facets )
		
		local len = math.vector2d3dLengthOf( facetA.transformed[joinA.join], facetB.transformed[joinB.join] )
		
		return len
	end
	
	local function initParentMatrices( facets )
		for i=1, #facets do
			facets[i].parentmatrix = math.newTranslationMatrix( 0,0,0 )
		end
	end
	
	local function cleanFoldingMatrices( facets )
		for i=1, #facets do
			facets[i].shiftmatrix = nil
			facets[i].foldmatrix = nil
			facets[i].parentmatrix = nil
		end
	end
	
	local function shiftToAlign( facets )
		local function alignFacetsForRotation( facets )
			local aligns = facets.aligns
		
			matrixlib.processObject( facets )
		
			for i=1, #aligns do
				local align = facets.aligns[i]
				local facetA, facetB = facets[align[1].facet], facets[align[2].facet]
				local transformedA, transformedB = facetA.transformed, facetB.transformed
			
				local lineA = {
					a={ x=transformedA[align[1].a][1], y=transformedA[align[1].a][2] },
					b={ x=transformedA[align[1].b][1], y=transformedA[align[1].b][2] },
				}
				local lineB = {
					a={ x=transformedB[align[2].a][1], y=transformedB[align[2].a][2] },
					b={ x=transformedB[align[2].b][1], y=transformedB[align[2].b][2] },
				}
			
				local angle = math.angleBetweenLines( lineA, lineB )
				facetA.matrix = math.newZRotationMatrix( -angle )
				matrixlib.processObject( facets )
			end
		end
	
		local function moveFacetsToTouch( facets )
			local aligns = facets.aligns
		
			for i=1, #aligns do
				local align = facets.aligns[i]
				local facetA, facetB = facets[align[1].facet], facets[align[2].facet]
				local transformedA, transformedB = facetA.transformed, facetB.transformed
			
				local lineA = {
					a={ x=transformedA[align[1].a][1], y=transformedA[align[1].a][2] },
					b={ x=transformedA[align[1].b][1], y=transformedA[align[1].b][2] },
				}
				local lineB = {
					a={ x=transformedB[align[2].a][1], y=transformedB[align[2].a][2] },
					b={ x=transformedB[align[2].b][1], y=transformedB[align[2].b][2] },
				}
			
				local ax, ay = (lineA.a.x + lineA.b.x) / 2, (lineA.a.y + lineA.b.y) / 2
				local bx, by = (lineB.a.x + lineB.b.x) / 2, (lineB.a.y + lineB.b.y) / 2
			
				facetA.matrix = math.multiply( facetA.matrix, math.newTranslationMatrix( bx-ax, by-ay, 0 ) )
				matrixlib.processObject( facets )
			end
		end
		
		local function prepareShiftMatrices( facets )
			for i=1, #facets do
				facets[i].shiftmatrix = facets[i].matrix
			end
		end
		
		local function resetTransformedTables( facets )
			for i=1, #facets do
				facets[i].flat = {}
				facets[i].transformed = {}
			end
		end
		
		alignFacetsForRotation( facets )
		moveFacetsToTouch( facets )
		prepareShiftMatrices( facets )
		resetTransformedTables( facets )
	end
	
	local function prepareCompositeMatricesForFolding( facets )
		for i=1, #facets do
			facets[i].parentmatrix = facets[i].matrix
		end
	end
	
	initParentMatrices( facets )
--	matrixlib.processObject( facets )
	shiftToAlign( facets )
--	prepareCompositeMatricesForFolding( facets )

	local joinindex = 1
	local rotation = 1
	local rotationinc = 1
	local len = 1000000000
	
	matrixlib.rotate( facets, 30, 0, 0 )
	matrixlib.processObject( facets )
	
local function enterFrame()
	if (joinindex <= #facets.joins) then
		local newlen = rotateForJoin( facets, joinindex, rotation )
		
		if (newlen < len) then
			rotation = rotation + rotationinc
			len = newlen
		elseif (newlen > len) then
			rotateForJoin( facets, joinindex, rotation-rotationinc )
			joinindex = joinindex + 1
			len = 1000000000
			rotation = 0
		end
	end
	
--	if (joinindex == 1) then
		matrixlib.rotate( facets, 0, 2, 0 )
--	elseif (joinindex == 2) then
--		matrixlib.rotate( facets, 0, -2, 0 )
--	elseif (joinindex == 3) then
--		matrixlib.rotate( facets, 0, -3, 0 )
--	else
--		matrixlib.rotate( facets, 0, 5, 0 )
--	end
end

timer.performWithDelay( 1000, function()
	Runtime:addEventListener( "enterFrame", enterFrame )
end, 1 )

end
--testFold()

local function produceCubeSpockFacets()
	local facets = {
		name = "folder",
		isDirtyRender = true,
		group = nil, -- will reference the facets table when textured
		filename = filename,
		normalfilename = normalfilename,
		flat = nil, -- flattened points for the whole shape (includes z)
		transformed = nil, -- points for the whole shape
		matrix = math.newXRotationMatrix(0), -- will be this object's transform matrix
		location = {x=0,y=0,z=0,rx=0,ry=0,rz=0}, -- location in space
		aligns = {
			-- {}, {}: facet to transform, facet to align with
			-- facet: index of facet
			-- a, b: point indices to align
			{ { facet=2, a=1, b=2 }, { facet=1, a=4, b=3 } },
			{ { facet=3, a=1, b=4 }, { facet=1, a=2, b=3 } },
			{ { facet=4, a=1, b=2 }, { facet=2, a=4, b=3 } },
			{ { facet=5, a=4, b=3 }, { facet=3, a=1, b=2 } },
			{ { facet=6, a=4, b=3 }, { facet=5, a=1, b=2 } },
		},
		joins = {
			-- {}, {}: data for each facet involved in a join
			-- facet: index of the facet being joined
			-- a, b: indices of the axis points to rotate around (nil to avoid rotating)
			-- join: index of the point on this facet to join
			-- ext: list of facets to transform cumulatively with this facet transform
			{ { facet=2, a=1, b=2, join=3, ext={4} }, { facet=3, a=1, b=4, join=3, ext={5,6} } },
			{ { facet=4, a=1, b=2, join=3, ext={} }, { facet=3, a=nil, b=nil, join=2, ext={} } },
			{ { facet=5, a=3, b=4, join=1, ext={6} }, { facet=1, a=nil, b=nil, join=1, ext={} } },
			{ { facet=6, a=3, b=4, join=1, ext={} }, { facet=1, a=nil, b=nil, join=4, ext={} } },
		}
	}
	
	local filename = "3d/cubes/spock.png"
	
	local options, objects = testImageSheet()
	
	for i=1, #objects do
		local object = objects[i]
		object.isAlwaysVisible = true
	end
	
	print(json.prettify(json.encode(objects)))
	
	facets[#facets+1] = {
		flat={},
		transformed={},
		filename=filename,
		image=nil,
		isAlwaysVisible=true,
		rect=nil, -- { width=200, height=200 },
		mesh={},
		fill={
			process="imagesheet"
		},
		frame={
--			x=x+dim.width/2-colwidth/2, y=y+dim.height/2-rowheight/2,
			width=colwidth, height=rowheight,
		},
		{ -100,-100,0,1 },
		{ -100,100,0,1 },
		{ 100,100,0,1 },
		{ 100,-100,0,1 },
		matrix = nothingmatrix,
	}
	
	local image = display.newImage( filename )
	image.x, image.y = display.actualCenterX, display.actualCenterY
	
	
end
--produceCubeSpockFacets()

local function testFilledMesh()
	local function a()
		local mesh = display.newMesh(
			{
				x = 100,
				y = 100,
				mode = "fan",
				vertices = {
					0,-100,
					-100,-100,
					-100,100,
					100,100
				}
			})
		mesh:translate( mesh.path:getVertexOffset() )  -- Translate mesh so that vertices have proper world coordinates

		mesh.fill = { type="image", filename="3d/earth.png" }
		
		timer.performWithDelay( 3000, function()
			timer.performWithDelay( 10, function()
				local vertexX, vertexY = mesh.path:getVertex( 1 )
--				print(vertexX, vertexY)
				mesh.path:setVertex( 1, vertexX+1, vertexY )
			end, 101 )
		end, 1 )
		
		display.newCircle( 100, 100, 5 ).fill = {1,0,0}
	end
	
	local function b()
		local mesh = display.newMesh(
			{
				x = 400,
				y = 100,
				mode = "fan",
				vertices = {
					0,-100,
					-100,-100,
					-100,100,
					100,100
				}
			})
		mesh:translate( mesh.path:getVertexOffset() )  -- Translate mesh so that vertices have proper world coordinates

		mesh.fill = { type="image", filename="3d/earth.png" }

		timer.performWithDelay( 3000, function()
			timer.performWithDelay( 10, function()
				local vertexX, vertexY = mesh.path:getVertex( 1 )
--				print(vertexX, vertexY)
				mesh.path:setVertex( 1, vertexX+1, vertexY )
			end, 101 )
		end, 1 )

		display.newCircle( 400, 100, 5 ).fill = {0,0,1}
	end
	
	local function c()
		local vertices = {
			100,-100,
			-100,-100,
			-100,100,
			100,100
		}
		
		local mesh = display.newMesh(
			{
				x = display.actualCenterX,
				y = display.actualCenterY,
				mode = "fan",
				vertices = vertices,
			})
		mesh:translate( mesh.path:getVertexOffset() )  -- Translate mesh so that vertices have proper world coordinates

		mesh.fill = { type="image", filename="3d/earth.png" }
		
		local function dot( index )
			local x, y = mesh.path:getVertex( index )
			x, y = display.localTo( mesh, mesh.parent, x, y )
			print( index, x, y )
			
			local circle = display.newCircle( mesh.parent, x, y, 20 )
			
			circle:addEventListener( "touch", function(e)
				local x, y = display.localTo( e.target.parent, mesh, e.x, e.y )
				circle.x, circle.y = e.x, e.y
				mesh.path:setVertex( index, x, y )
				return true
			end )
		end
		
		dot( 1 )
		dot( 2 )
		dot( 3 )
		dot( 4 )
	end
	
	local function d()
		local group = display.newGroup()
		group.x, group.y = display.actualCenterX, display.actualCenterY+500
		
		local earth = display.newImage( group, "3d/earth.png" )
		
		local rect = display.newPathRect( group, 0, 0, 200, 200 )
		
		rect:setPath(
			-200, -200,
			-100, 100,
			100, 100,
			100, -100
		)
		
		rect.fill = { type = "image", filename = "3d/earth.png" }
	end
	
	a()
	b()
	c()
	d()
end
--testFilledMesh()

local function testMeshShape()
	local dim = getImageDimensions( "3d/earth.png" )
--	local normal = getImageDimensions( "3d/earthnormal.png" )
	
	local facets = {
		name = "mesher",
		isDirtyRender = true,
		group = nil, -- will reference the facets table when textured
		filename = "3d/earth.png",
		normalfilename = "3d/earthnormal.png",
		matrix = math.newXRotationMatrix(0), -- will be this object's transform matrix
		location = {x=0,y=0,z=0,rx=0,ry=0,rz=0}, -- location in space
		{
			flat={},
			transformed={},
			filename=filename,
			image=nil,
			isAlwaysVisible=true,
			rect=nil, -- { width=200, height=200 },
			mesh={},
			fill={
				process="imagesheet"
			},
			frame={
				x=0, y=0,
				width=dim.width, height=dim.height,
			},
			{ -200,-200,0,1 },
			{ -200,200,0,1 },
			{ 200,200,0,1 },
			{ 200,-200,0,1 },
			matrix = nothingmatrix,
		}
	}
	
	matrixlib.add( facets )
	matrixlib.start()
	
	matrixlib.rotate( facets, -50, 0, 0 )
	
	Runtime:addEventListener( "enterFrame", function()
		matrixlib.rotate( facets, 0, 1, 0 )
	end )
end
--testMeshShape()

local function testMeshShapes()
	local dim = getImageDimensions( "3d/earth.png" )
--	local normal = getImageDimensions( "3d/earthnormal.png" )
	
	local facets = {
		name = "mesher",
		isDirtyRender = true,
		group = nil, -- will reference the facets table when textured
		filename = "3d/earth.png",
		normalfilename = "3d/earthnormal.png",
		matrix = math.newXRotationMatrix(0), -- will be this object's transform matrix
		location = {x=0,y=0,z=0,rx=0,ry=0,rz=0}, -- location in space
	}
	
	local function addFacet()
		facets[#facets+1] = {
			flat={},
			transformed={},
			filename=filename,
			image=nil,
			isAlwaysVisible=true,
			rect=nil, -- { width=200, height=200 },
			mesh={},
			fill={
				process="imagesheet"
			},
			frame={
				x=0, y=0,
				width=dim.width, height=dim.height,
			},
			{ -200,-200,0,1 },
			{ -200,200,0,1 },
			{ 200,200,0,1 },
			{ 200,-200,0,1 },
			matrix = nothingmatrix,
		}
	end
	
--	addFacet()
	--[[
	matrixlib.add( facets )
	matrixlib.start()
	
	matrixlib.rotate( facets, -50, 0, 0 )
	
	Runtime:addEventListener( "enterFrame", function()
		matrixlib.rotate( facets, 0, 1, 0 )
	end )
	]]--
	
--	local group = display.newGroup()
--	group.x, group.y = display.actualCenterX, display.actualCenterY
--	group.xScale, group.yScale = .75, .75
	
--	local image = display.newImage( group, "3d/cubes/spock.png" )
	
--	local faces = {
--		{ name="face", 565,254 , 565,400 , 773,400 , 773,254 }, -- face
--		{ name="top", 565,47 , 565,254 , 773,254 , 773,47 },   -- top
--		{ name="bottom", 565,400 , 565,607 , 773,607 , 773,400 }, -- bottom
--		{ name="right", 773,254 , 773,400 , 981,400 , 981,254 }, -- right
--		{ name="left", 357,254 , 357,400 , 565,400 , 565,254 }, -- left
--		{ name="back", 149,254 , 149,400 , 357,400 , 357,254 }, -- back
--	}
	
	local facets = texturelib.generateTextureSheet( "3d/cubes/spock.png", nil, texturelib.spock, "mesh", true )
	
	local face, top, bottom, right, left, back = 1, 2, 3, 4, 5, 6
	
	facets.aligns = {
		-- {}, {}: facet to transform, facet to align with
		-- facet: index of facet
		-- a, b: point indices to align
		{ { facet=top, a=2, b=3 },		{ facet=face, a=1, b=4 } },
		{ { facet=bottom, a=1, b=4 },	{ facet=face, a=2, b=3 } },
		{ { facet=right, a=1, b=2 },	{ facet=face, a=4, b=3 } },
		{ { facet=left, a=4, b=3 },		{ facet=face, a=1, b=2 } },
		{ { facet=back, a=4, b=3 },		{ facet=left, a=1, b=2 } },
	}
	facets.joins = {
		-- {}, {}: data for each facet involved in a join
		-- facet: index of the facet being joined
		-- a, b: indices of the axis points to rotate around (nil to avoid rotating)
		-- join: index of the point on this facet to join
		-- ext: list of facets to transform cumulatively with this facet transform
		{ { facet=top, a=2, b=3, join=4, ext={} },		{ facet=right, a=1, b=2, join=4, ext={} } },
		{ { facet=bottom, a=1, b=4, join=3, ext={} },	{ facet=right, a=nil, b=nil, join=3, ext={} } },
		{ { facet=left, a=4, b=3, join=1, ext={back} },	{ facet=top, a=nil, b=nil, join=1, ext={} } },
		{ { facet=back, a=4, b=3, join=1, ext={} },		{ facet=right, a=nil, b=nil, join=4, ext={} } },
	}
	
	for i=1, #facets do
		facets[i].matrix = math.newTranslationMatrix( (i-1)*100, 0, 0 )
	end
	
	matrixlib.add( facets )
	matrixlib.start()
	
	matrixlib.rotate( facets, 0, -90, 0 )
	
	Runtime:addEventListener( "enterFrame", function()
		matrixlib.rotate( facets, 0, 1, 0 )
	end )
end
--testMeshShapes()

local function createNewImageSheet( filename, options )
	local colours = {
		{1,.7,.7,.6},
		{.7,1,.7,.6},
		{.7,.7,1,.6},
	}
	
	local function newZoomDevice( parent )
		local group = display.newGroups( parent, 1 )
		group.class = "zoomdevice"
		
		local x, y = parent:contentToLocal( display.actualCenterX, 50 )
		group.x, group.y = x, y
		
		local slider = widget.newSlider {
			top = y,
			left = x-display.actualCenterX+50,
			width = display.actualContentWidth-100,
			value = 25,
			listener = function(e)
				parent:setZoom( e.value/25 )
			end
		}
		parent:insert( slider )
		
		return group
	end
	
	local function newPlusDevice( parent )
		local group = display.newGroups( parent, 1 )
		group.class = "plusdevice"
		
		local x, y = parent:contentToLocal( display.actualContentWidth-50, display.actualContentHeight-50 )
		group.x, group.y = x, y
		
		local circle = display.newCircle( group, 0, 0, 40 )
		circle.fill = {0,1,0}
		circle.strokeWidth = 10
		circle.stroke = {0,.5,0}
		
		local plus = display.newText{ parent=group, text="+", x=1, y=-9, fontSize=80 }
		plus.fill = {0,.5,0}
		
		group:addEventListener( "touch", function(e)
			return true
		end )
		
		group:addEventListener( "tap", function(e)
			parent:addPolygon()
			return true
		end )
		
		return group
	end
	
	local function newPrintDevice( parent, editgroup )
		local group = display.newGroups( parent, 1 )
		group.class = "printdevice"
		
		local x, y = parent:contentToLocal( 50, display.actualContentHeight-50 )
		group.x, group.y = x, y
		
		local rect = display.newRoundedRect( group, 0, 0, 80, 80, 15 )
		rect.fill = {.7,.7,1}
		rect.strokeWidth = 10
		rect.stroke = {0,0,1}
		
		local a = display.newLine( group, -20, -15, 20, -15 )
		a.strokeWidth = 6
		a.stroke = {0,0,.7}
		
		local a = display.newLine( group, -20, 0, 20, 0 )
		a.strokeWidth = 6
		a.stroke = {0,0,.7}
		
		local a = display.newLine( group, -20, 15, 20, 15 )
		a.strokeWidth = 6
		a.stroke = {0,0,.7}
		
		group:addEventListener( "touch", function(e)
			return true
		end )
		
		local function generateFacets( facets )
			for i=1, editgroup.numChildren do
				if (editgroup[i].class == "facet") then
					facets[#facets+1] = editgroup[i]:getFacet()
				end
			end
		end
		
		local function generateJoins( joins )
			for i=1, editgroup.numChildren do
				if (editgroup[i].class == "mesh") then
					local join = {}
				end
			end
		end
		
		local function generateAligns( joins )
			for i=1, editgroup.numChildren do
				if (editgroup[i].class == "mesh") then
					local join = {}
				end
			end
		end
		
		group:addEventListener( "tap", function(e)
			local object, facets, joins, aligns = {}, {}, {}, {}
			object.facets = facets
			object.joins = joins
			object.aligns = aligns
			
			generateFacets( facets )
			generateJoins( joins )
			generateAligns( aligns )
			
			print(json.prettify(json.encode(facets)))
			
			iolib.wrDocs( "ceiling_cat.json", json.encode(facets) )
			
			return true
		end )
		
		return group
	end
	
	--[[local function oldSequenceDevice( parent, editgroup )
		local group = display.newGroups( parent, 1 )
		group.class = "sequencedevice"
		
		local x, y = parent:contentToLocal( 150, display.actualContentHeight-50 )
		group.x, group.y = x, y
		
		local rect = display.newRoundedRect( group, 0, 0, 80, 80, 15 )
		rect.fill = {1,.7,1}
		rect.strokeWidth = 10
		rect.stroke = {1,0,1}
		
		local nums = display.newText{ parent=group, x=0, y=0, text="123", fontSize=32 }
		nums.strokeWidth = 6
		nums.fill = {1,0,1}
		
		group:addEventListener( "touch", function(e)
			return true
		end )
		
		local link = nil
		group.links = {}
		
		function group:link(e)
			if (link.a == nil) then
				link.a = e.target
			elseif (link.b == nil) then
				link.b = e.target
				group.links[ #group.links+1 ] = link
				link = nil
				editgroup:removeEventListener( "link", group )
			end
		end
		
		group:addEventListener( "tap", function(e)
			editgroup:dispatchEvent{ name="sequence", phase="began", target=group }
			link = { a=nil, b=nil }
			editgroup:addEventListener( "link", group )
			return true
		end )
		
		return group
	end]]--
	
	local function newSequenceDot( editgroup )
		local group = display.newGroups( editgroup, 1 )
		group.class = "sequencebase"
		group.mode = "move"
		group.previous = nil
		
		local x, y = editgroup:contentToLocal( display.actualCenterX, display.actualCenterY )
		group.x, group.y = x, y
		
		local circle = display.newCircle( group, 0, 0, 30 )
		circle.fill = {0,0,0,0}
		circle.stroke = {1,0,0}
		circle.strokeWidth = 8
		circle.isHitTestable = true
		
		group:addEventListener( "tap", function(e)
			if (group.mode == "move") then
				group.mode = "drag"
				circle.stroke = {0,1,0}
			else
				group.mode = "move"
				circle.stroke = {1,0,0}
			end
			return true
		end )
		
		function group:takeFocus(e)
			group:doMove(e)
		end
		
		group:addEventListener( "touch", function(e)
			if (group.mode == "move") then
				return group:doMove(e)
			else
				return group:doDrag(e)
			end
		end )
		
		function group:doMove(e)
			if (e.phase == "began") then
				display.currentStage:setFocus( e.target )
				e.target.hasFocus = true
				return true
			elseif (e.target.hasFocus) then
				e.target.x, e.target.y = editgroup:contentToLocal( e.x, e.y )
				
				if (e.phase == "moved") then
				else
					display.currentStage:setFocus( nil )
					e.target.hasFocus = nil
				end
				return true
			end
			return false
		end
		
		function group:doDrag(e)
			newSequenceDot( editgroup ):takeFocus(e)
			return true
		end
		
		return group
	end
	
	local function newSequenceDevice( parent, editgroup )
		local group = display.newGroups( parent, 1 )
		group.class = "sequencedevice"
		
		local x, y = parent:contentToLocal( 150, display.actualContentHeight-50 )
		group.x, group.y = x, y
		
		local rect = display.newRoundedRect( group, 0, 0, 80, 80, 15 )
		rect.fill = {1,.7,1}
		rect.strokeWidth = 10
		rect.stroke = {1,0,1}
		
		local nums = display.newText{ parent=group, x=0, y=0, text="123", fontSize=32 }
		nums.strokeWidth = 6
		nums.fill = {1,0,1}
		
		group:addEventListener( "touch", function(e)
			return true
		end )
		
		group:addEventListener( "tap", function(e)
			newSequenceDot( editgroup )
			return true
		end )
		
		return group
	end
	
	local function drag( e )
		if (e.phase == "began") then
			display.currentStage:setFocus( e.target )
			e.target.hasFocus = true
			e.target.prev = e
			if (e.target.doBegin) then e.target:doBegin( 0, 0 ) end
			return true
		elseif (e.target.hasFocus) then
			local prev = e.target.prev
			local x, y = e.x-prev.x, e.y-prev.y
			
			if (e.phase == "moved") then
				if (e.target.doMove) then e.target:doMove( x, y ) end
				
				e.target.prev = e
			else
				if (e.target.finishMove) then e.target:finishMove( x, y ) end
				display.currentStage:setFocus( nil )
				e.target.hasFocus = nil
				e.target.prev = nil
			end
			
			return true
		end
		return false
	end
	
	local function convertFacetVerticesToMeshVertices( frame )
		local vertex = {}
		
		vertex[1], vertex[2] = frame[7], frame[8]
		
		for i=1, 6 do
			vertex[#vertex+1] = frame[i]
		end
		
		return vertex
	end
	
	local group = display.newGroup()
	group.x, group.y = display.actualCenterX, display.actualCenterY
	
	local editgroup = display.newGroups( group, 1 )
	
	local zoom = newZoomDevice( group )
	local plus = newPlusDevice( group )
	local printer = newPrintDevice( group, editgroup )
	local sequence = newSequenceDevice( group, editgroup )
	
	editgroup:addEventListener( "touch", drag )
	
	local image = display.newImage( editgroup, filename )
	image.class = "image"
	editgroup.image = image
	image.anchorX, image.anchorY = 0, 0
	
	local function findNextConnectingFacet( index )
		local function testConnection( targetindex )
			
		end
		
		for i=index+1, editgroup.numChildren do
			if (editgroup[i].class == "mesh" and testConnection[i]) then
				return editgroup[i]
			end
		end
		return nil
	end
	
	function group:setZoom( value )
		local x, y = editgroup:contentToLocal( display.actualCenterX, display.actualCenterY )
		editgroup.xScale, editgroup.yScale = value, value
		local px, py = editgroup:contentToLocal( display.actualCenterX, display.actualCenterY )
		editgroup.x, editgroup.y = editgroup.x-(x-px)*editgroup.xScale, editgroup.y-(y-py)*editgroup.yScale
		editgroup:dispatchEvent{ name="scale" }
	end
	
	function editgroup:doMove( x, y )
		editgroup.x, editgroup.y = editgroup.x+x, editgroup.y+y
	end
	
	local function polygonMove( self, x, y )
		self.x, self.y = self.x + x/editgroup.xScale, self.y + y/editgroup.yScale
		for i=1, 4 do
			local circle = self["circle"..i]
			circle.x, circle.y = circle.x + x/editgroup.xScale, circle.y + y/editgroup.yScale
		end
	end
	
	local function changeColourOrDelete(e)
		if (e.numTaps == 1) then
			e.target.colourindex = e.target.colourindex + 1
			if (e.target.colourindex > #colours) then e.target.colourindex = 1 end
			e.target.fill = colours[ e.target.colourindex ]
		elseif (e.numTaps == 2) then
			for i=1, 4 do
				display.remove( e.target["circle"..i] )
			end
			display.remove( e.target )
		end
		return true
	end
	
	function group:addPolygon( vertices )
		local group = display.newGroups( editgroup, 1 )
		group.class = "facet"
		
		local function getDefaultFacet()
			local vertices = {
				display.actualCenterX-100, display.actualCenterY-100,
				display.actualCenterX-100, display.actualCenterY+100,
				display.actualCenterX+100, display.actualCenterY+100,
				display.actualCenterX+100, display.actualCenterY-100,
			}
			
			for i=1, #vertices-1, 2 do
				vertices[i], vertices[i+1] = group:contentToLocal( vertices[i], vertices[i+1] )
			end
			
			return vertices
		end
		
		function group:getFacet()
			local facet = {}
			
			for i=1, group.numChildren do
				if (group[i].class == "dot") then
					local x, y = display.localToContentToLocal( group[i], editgroup, 0, 0 )
					facet[#facet+1] = { x, y, 0, 1 }
				end
			end
			
			local vertex = table.remove( facet, 1 )
			table.insert( facet, 4, vertex )
			
			return facet
		end
		
		local function addPoint( mesh, index, radius )
			local x, y = mesh:getVertex( index )
			
			local dot = display.newCircle( group, x, y, radius or 15 )
			dot.class = "dot"
			dot.xScale, dot.yScale = 1/editgroup.xScale, 1/editgroup.yScale
			
			dot.index = index
			dot.fill = {1,1,1,.1}
			dot.strokeWidth = 2
			dot.stroke = {1,0,0}
			
			local function doSnap()
				local function findClosestDot()
					for i=1, editgroup.numChildren do
						local facet = editgroup[i]
						if (facet.class == "facet" and facet ~= group) then
							for f=1, facet.numChildren do
								local closest = facet[f]
								if (closest.class == "dot") then
									if (math.lengthOf( dot, closest ) < 30/editgroup.xScale) then
										return closest
									end
								end
							end
						end
					end
				end
				
				local closest = findClosestDot()
				
				if (closest) then
					local x, y = display.localTo( closest.parent, editgroup, closest.x, closest.y )
					dot.x, dot.y = x, y
					mesh:setVertex( index, x, y )
				end
			end
			
			function dot:touch(e)
				if (e.phase == "began") then
					display.currentStage:setFocus( e.target )
					e.target.hasFocus = true
					return true
				elseif (e.target.hasFocus) then
					local x, y = group:contentToLocal( e.x, e.y )
					dot.x, dot.y = x, y
					
					mesh:setVertex( index, x, y )
					
					if (e.phase == "moved") then
					else
						doSnap()
						display.currentStage:setFocus( nil )
						e.target.hasFocus = nil
					end
					return true
				end
				return false
			end
			
			function dot:scale(e)
				dot.xScale, dot.yScale = 1/editgroup.xScale, 1/editgroup.yScale
			end
			
			function dot:move(e)
				dot.x, dot.y = dot.x+e.x, dot.y+e.y
			end
			
			dot:addEventListener( "touch" )
			dot:addEventListener( "scale" )
			group:addEventListener( "move", dot )
			editgroup:addEventListener( "scale", dot )
		end
		
		local function constructFacetMeshAndPoints( vertices )
			local v, o = math.centrePolygon( vertices )
			vertices = v
			
			local mesh = display.newPathMesh{
				parent=group,
				mode="fan",
				vertices=vertices,
			}
			
			mesh.x, mesh.y = o.x, o.y
			mesh.fill = {math.random(180,250)/255,math.random(180,250)/255,math.random(180,250)/255,.6}
			
			for i=1, 4 do
				addPoint( mesh, i )
			end
			
			function mesh:touch(e)
				if (e.phase == "began") then
					display.currentStage:setFocus( e.target )
					e.target.hasFocus = true
					e.target.prev = e
					return true
				elseif (e.target.hasFocus) then
					local prev = e.target.prev
					local x, y = e.x-prev.x, e.y-prev.y
					
					mesh.x, mesh.y = mesh.x+x/editgroup.xScale, mesh.y+y/editgroup.yScale
					group:dispatchEvent{ name="move", target=group, x=x/editgroup.xScale, y=y/editgroup.yScale }
					
					if (e.phase == "moved") then
						e.target.prev = e
					else
						display.currentStage:setFocus( nil )
						e.target.hasFocus = nil
						e.target.prev = nil
					end
					return true
				end
				return false
			end
			
			mesh:addEventListener( "touch" )
			
			return mesh
		end
		
		if (vertices == nil) then vertices = getDefaultFacet() end
		group.mesh = constructFacetMeshAndPoints( vertices )
		
		local function setAsBase(e)
			
			return true
		end
		
		editgroup:addEventListener( "sequence", function(e)
			if (e.phase == "began") then
				mesh:addEventListener( "tap", setAsBase )
			elseif (e.phase == "ended") then
				mesh:removeEventListener( "tap", setAsBase )
			end
			return true
		end )
		
		return group
	end
	
	local function loadOptions()
		local function convertFacetToVertex( facet )
			local vertex = {}
			for i=1, #facet do
				vertex[#vertex+1] = facet[i][1]
				vertex[#vertex+1] = facet[i][2]
			end
			return vertex
		end
		
		for i=1, #options do
			group:addPolygon( convertFacetToVertex( options[i] ) )
		end
	end
	
	editgroup.x, editgroup.y = editgroup.x-image.width/2, editgroup.y-image.height/2
	
	if (options) then
		loadOptions( options )
	end
end

--local ceiling_cat = {
--                      {{502.24981689453,1011.25,0,1},{578.24981689453,1010.75,0,1},{581.74981689453,920.25,0,1},{499.24981689453,920.25,0,1}},
--                      {{499.24981689453,920.25,0,1},{581.74981689453,920.25,0,1},{643.74987792969,877.75,0,1},{437.74981689453,877.75,0,1}},
--                      {{578.24981689453,1010.75,0,1},{702.74981689453,948.25,0,1},{654.74975585938,897.25,0,1},{581.74981689453,920.25,0,1}},
--                      {{437.74984741211,877.75,0,1},{643.74987792969,877.75,0,1},{631.93676757812,736.97448730469,0,1},{450.29122924805,736.97448730469,0,1}},
--                      aligns={},
--                      joins={}
--                    }
-- createNewImageSheet( "3d/cubes/ceiling_cat.png", json.decode( iolib.wrDocs( "ceiling_cat.json" ) ) )



--[[
display.newCircle( 0, 0, 25 ).fill = {0,0,1}

local vertices = {
	display.actualCenterX+100, display.actualCenterY-100,
	display.actualCenterX-100, display.actualCenterY-100,
	display.actualCenterX-100, display.actualCenterY+100,
	display.actualCenterX+100, display.actualCenterY+100,
}

vertices, options = math.centrePolygon( vertices )

dump(vertices)
print("  ",options.x,options.y,"\n","   ")


local mesh = display.newPathMesh{
	mode = "fan",
	x=options.x, y=options.y,
	vertices = vertices
}
mesh.fill = {1,0,0}

for i=1, 4 do
	print(mesh:getVertex(i))
end

print(mesh.x,mesh.y,mesh.path:getVertexOffset())
]]--
