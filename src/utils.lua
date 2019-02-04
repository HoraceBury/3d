-- utils

local composer = require("composer")

local utils = {}

function dump( ... )
	if (#arg > 1) then
		print("========================DUMP ("..#arg..")========================")
		for i=1, #arg do
			print("========================DUMP ["..i.."]========================")
			dump(arg[i])
		end
	else
		local t = arg[1]
		print("========================DUMP========================")
		for k,v in pairs(t) do
			print("\t",k,v)
		end
		print("========================DUMP========================")
	end
end

--local _print = print
--print = function( ... )
--	if (composer.isDebug) then
--		_print( unpack( arg ) )
--	end
--end

function createAnchor( parent )
	anchor = display.newRect( parent, -100, -100, 10, 10 )
	anchor.isVisible = false
	anchor.x, anchor.y = -100, -100
	physics.addBody( anchor, "static", { density=100, friction=0, bounce=0, isSensor=true } )
end

string.urlencode = function(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
--		str = string.gsub (str, "([^%w ])",	function ( c ) return string.format ("%%%02X", string.byte( c )) end)
		str = string.gsub (str, " ", "%%20")
	end
	return str
end

--[[
	Returns just the filename and the file extension as separate values from a full, any-depth pathname.
	
	Example:
		Parameter: "~/Library/Application Support/Corona Simulator/Crank/image1.png"
		Returns: "image1", "png"
]]--
string.extractFilenameAndExt = function( path )
	local t = string.split( path, "/" )
	local name, ext = unpack( string.split( t[#t], "." ) )
	return name, ext
end

--[[
	Creates a series of display groups with optional naming indices on the parent.
	
	Parameters:
		parent: Parent display group to insert the new display groups into.
		count: Number of display groups to create.
		...: Optional list of string names to give the new display groups on the parent.
	
	Returns:
		List of display groups which have been inserted into the parent display group as children.
	
	Example:
		local bg, content, buttons = display.newGroups( sceneGroup, 3, "bg", "content", "buttons" )
		print( sceneGroup.buttons.numChildren ) -- This will print 0 to show that buttons has nothing in it.
]]--
display.newGroups = function( parent, count, ... )
	local list = {}
	if (type(count) == "string") then
		table.insert( arg, 1, count )
		count = #arg
	end
	for i=1, count do
		local group = display.newGroup()
		list[ #list+1 ] = group
		parent:insert( group )
		if (arg[i] and type(arg[i]) == "string") then
			local class = arg[i]
			parent[ class ] = group
			group.class = class
		end
	end
	return unpack(list)
end

-- removes all child items in a display group
local function clear( group )
	while (group.numChildren > 0) do
		group[1]:removeSelf()
	end
end
display.clear = clear

-- converts x, y coordinates from within the group to be within the other group, going via the content group
local function localTo( group, other, x, y )
	x, y = group:localToContent( x, y )
	x, y = other:contentToLocal( x, y )
	return x, y
end
display.localTo = localTo
display.localToContentToLocal = localTo

-- adds functions to display group objects
local display_newGroup = display.newGroup
display.newGroup = function()
	local group = display_newGroup()
	
	function group:clear()
		return display.clear( group )
	end
	
	function group:localTo( other, x, y )
		return display.localTo( group, other, x, y )
	end
	
	return group
end

-- returns the index of the obj in the group if found, otherwise returns nil
display.indexOf = function( group, obj )
	for i=1, group.numChildren do
		if (group[i] == obj) then
			return i
		end
	end
	return nil
end

--[[
	Sorts the objects in a display group by the named property of those objects.
	
	Parameters:
		group: The display group to sort
		indexName: Optional. The name of the child object's property to sort by, default: 'y'
	
	Example:
		Sort all the display objects in a scene by their y position on-screen. The result is that
		the objects closer to the bottom of the screen will be closer to [1].
		display.sortDisplayGroupBy( sceneGroup, "y" )
	
	Notes:
		Uses the standard table.sort function to order (a,b) by a>b values.
]]--
function display.sortDisplayGroupBy( group, indexName )
	local list = {}
	
	for i=1, group.numChildren do
		list[i] = group[i]
	end
	
	table.sort( list, function(a,b)
		return a[ indexName or "y" ] > b[ indexName or "y" ]
	end )
	
	for i=1, #list do
		group:insert( i, list[i] )
	end
end

-- strokes a display object with specified colour
local function stroke( obj, colour, width )
	obj.stroke = { type="image", filename="brush2.png" }
	obj:setStrokeColor( unpack( colour ) )
	obj.strokeWidth = width or 3
end
display.stroke = stroke

-- returns a random RGB fill table
local function getRandomFill( isFullGamut )
	if (isFullGamut) then
		return { math.random(0,255)/255, math.random(0,255)/255, math.random(0,255)/255 }
	else
		return { math.random(100,200)/255, math.random(100,200)/255, math.random(100,200)/255 }
	end
end

-- encapsulates stroked lines
local _newLine = display.newLine
display.newLine = function( ... )
	if (#arg == 1) then
		local params = arg[1]
		local line = _newLine( unpack( params.path ) )
		if (params.parent) then params.parent:insert( line ) end
		line.x, line.y = params.x or line.x, params.y or line.y
		if (params.stroke) then display.stroke( line, params.stroke, params.strokeWidth ) end
		return line
	else
		return _newLine( unpack( arg ) )
	end
end

-- encapsulates full circle defining
local _newCircle = display.newCircle
display.newCircle = function( ... )
	if (#arg == 1) then
		local params = arg[1]
		local circle = _newCircle( params.x or 0, params.y or 0, params.radius or 0 )
		if (params.parent) then params.parent:insert( circle ) end
		if (params.fill) then circle:setFillColor( unpack( params.fill ) ) end
		circle.alpha = params.alpha or 1
		if (params.stroke) then display.stroke( circle, params.stroke, params.strokeWidth ) end
		circle.radius = params.radius
		return circle
	else
		return _newCircle( unpack( arg ) )
	end
end

-- encapsulates full rectangle defining
local _newRect = display.newRect
display.newRect = function( ... )
	if (#arg == 1) then
		local params = arg[1]
		local rect = _newRect( params.x or 0, params.y or 0, params.width or 1, params.height or 1 )
		if (params.parent) then params.parent:insert( rect ) end
		if (params.fill) then rect:setFillColor( unpack( params.fill ) ) end
		rect.alpha = params.alpha or 1
		if (params.stroke) then display.stroke( rect, params.stroke, params.strokeWidth ) end
		return rect
	else
		return _newRect( unpack( arg ) )
	end
end

-- replaces placeholders {1}, {2}, etc with args
-- eg: "hello banana" = strReplace("{1} {2}", "hello", "banana")
local function strReplace( str, ... )
	local function inner()
		for i=1, #arg do
			str = string.gsub( str, "{"..i.."}", arg[i] or "" )
		end
		return str
	end
	local status, result = pcall(inner)
	if (status) then
		return result
	else
		print("strReplace fail: ", result, str, unpack( arg ) )
		return nil
	end
end
string.replace = strReplace

-- splits a string into a table
-- str: the sring to split
-- sep: the separating char
local function strSplit( str, sep )
	sep = sep or "/" -- default for urls
	local tbl = {}
	
	-- get first separator
	local index = string.find( str, sep, 1, true )
	
	-- perform separations while there are substrings
	while (index ~= nil) do
		-- get string up to the separator
		local sub = string.sub( str, 1, index-1 )
		-- if the string is 1 chr or more (could be two adjacent separators)
		if (string.len( sub ) > 0) then
			tbl[ #tbl+1 ] = sub
		end
		-- get the rest of the string after the separator
		str = string.sub( str, index+1 )
		-- find the next separator
		index = string.find( str, sep, 1, true )
	end
	-- store the last substring
	if (string.len( str ) > 0) then
		tbl[ #tbl+1 ] = str
	end
	
	return tbl
end
string.split = strSplit

--[[
	Adds the function setPath() to a display object if the object has a .path property.
	
	Description:
		Allows parent group position values to be passed in the order x1,y1,x2,y2,x3,y3,x4,y4 instead of
		corner-relative values to change the path properties.
	
	newPathObject parameters:
		object: The object which to add the setPath() function to.
	
	newPathObject returns:
		The object parameter if it has a .path property, otherwise nil.
	
	setPath parameters:
		x1,y1,x2,y2,x3,y3,x4,y4: The anti-clockwise path x,y values relative to the display object's parent.
	
	setPath returns:
		nil
	
	Notes:
		This method must be called before the width and height of the display object are changed. This
		is because it requires the original dimensions of the rectangular display object during each
		path set. See the newPathRect and newPathImage functions for ease of use.
]]--
display.newPathObject = function( object )
	if (object.path ~= nil) then
		object._original_width = object.width
		object._original_height = object.height
		
		function object:setPath( ... )
			object.path.x1, object.path.y1 = arg[1]-(object.x-object._original_width/2), arg[2]-(object.y-object._original_height/2)
			object.path.x2, object.path.y2 = arg[3]-(object.x-object._original_width/2), arg[4]-(object.y+object._original_height/2)
			object.path.x3, object.path.y3 = arg[5]-(object.x+object._original_width/2), arg[6]-(object.y+object._original_height/2)
			object.path.x4, object.path.y4 = arg[7]-(object.x+object._original_width/2), arg[8]-(object.y-object._original_height/2)
		end
		
		return object
	end
end

--[[
	Creates a rect with standard newRect parameters and adds the setPath function as defined in newPathObject.
]]--
display.newPathRect = function(...)
	return display.newPathObject( display.newRect( unpack( arg ) ) )
end

--[[
	Creates a image with standard newImage parameters and adds the setPath function as defined in newPathObject.
]]--
display.newPathImage = function(...)
	return display.newPathObject( display.newImage( unpack( arg ) ) )
end

--[[
	Creates a imagerect with standard newImageRect parameters and adds the setPath function as defined in newPathObject.
]]--
display.newPathImageRect = function(...)
	return display.newPathObject( display.newImageRect( unpack( arg ) ) )
end

--[[
	Creates a mesh with standard newMesh parameters and adds the setPath function as defined in newPathObject.
]]--
display.newPathMesh = function( ... )
	local object = display.newPathObject( display.newMesh( unpack( arg ) ) )
	
	function object:setPath( ... )
		local x, y
		
		x, y = display.localTo( object, object.parent, arg[1], arg[2] )
		object.path:setVertex( 2, x, y )
		
		x, y = display.localTo( object, object.parent, arg[3], arg[4] )
		object.path:setVertex( 3, x, y )
		
		x, y = display.localTo( object, object.parent, arg[5], arg[6] )
		object.path:setVertex( 4, x, y )
		
		x, y = display.localTo( object, object.parent, arg[7], arg[8] )
		object.path:setVertex( 1, x, y )
	end
	
	function object:getVertex( index )
		local x, y = object.path:getVertex( index )
		x, y = display.localTo( object, object.parent, x, y )
		return x, y
	end
	
	function object:setVertex( index, x, y )
		x, y = display.localTo( object.parent, object, x, y )
		object.path:setVertex( index, x, y )
	end
	
	return object
end

--[[
	Converts an HSL color value to RGB. Conversion formula
	adapted from http://en.wikipedia.org/wiki/HSL_color_space.
	Assumes h, s, and l are contained in the set [0, 1] and
	returns r, g, and b in the set [0, 255].
	
	@param   {number}  h       The hue
	@param   {number}  s       The saturation
	@param   {number}  l       The lightness
	@return  {Array}           The RGB representation
	
	Ref: http://stackoverflow.com/a/9493060/71376
]]--
function hslToRgb(h, s, l)
    local r, g, b
    
    if (s == 0) then
        r = l
        g = l
        b = l
    else
        local hue2rgb = function(p, q, t)
            if (t < 0) then t = t + 1 end
            if (t > 1) then t = t - 1 end
            if (t < 1/6) then return p + (q - p) * 6 * t end
            if (t < 1/2) then return q end
            if (t < 2/3) then return p + (q - p) * (2/3 - t) * 6 end
            return p
        end
        
        local q
        if (l < 0.5) then
        	q = l * (1 + s)
        else
        	q = l + s - l * s
        end
        
        local p = 2 * l - q
        
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end
    
    return { math.round(r * 255), math.round(g * 255), math.round(b * 255) }
end
utils.hslToRgb = hslToRgb
graphics.hslToRgb = hslToRgb

--[[
	Converts an RGB color value to HSL. Conversion formula
	adapted from http://en.wikipedia.org/wiki/HSL_color_space.
	Assumes r, g, and b are contained in the set [0, 255] and
	returns h, s, and l in the set [0, 1].
	
	@param   {number}  r       The red color value
	@param   {number}  g       The green color value
	@param   {number}  b       The blue color value
	@return  {Array}           The HSL representation
	
	Ref: http://stackoverflow.com/a/9493060/71376
]]--
function rgbToHsl(r, g, b)
    r = r / 255
    g = g / 255
    b = b / 255
    
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h = (max + min) / 2
    local s, l = h, h

    if (max == min) then
        h = 0
        s = 0
    else
        local d = max - min
        
        if (l > 0.5) then
        	s = d / (2 - max - min)
        else
        	s = d / (max + min)
        end
        
        if (max == r) then
        	if (g < b) then
				h = (g - b) / d + 6
            else
				h = (g - b) / d + 0
            end
        elseif (max == g) then
            h = (b - r) / d + 2
        elseif (max == b) then
            h = (r - g) / d + 4
        end
        
        h = h / 6
    end

    return { h, s, l }
end
graphics.rgbToHsl = rgbToHsl
utils.rgbToHsl = rgbToHsl

-- https://forums.coronalabs.com/topic/15731-handy-code-snippets/?p=226815
-- input h-0-360(deg.), s-0-100(%), l-0-100(%)
local function hslToRgb2(h, s, l)
	if s == 0 then return l*.01,l*.01,l*.01 end
	local c, h = (1-math.abs(2*(l*.01)-1))*(s*.01), (h%360)/60
	local x, m = (1-math.abs(h%2-1))*c, ((l*.01)-.5*c)
	c = ({{c,x,0},{x,c,0},{0,c,x},{0,x,c},{x,0,c},{c,0,x}})[math.ceil(h)] or {c,x,0}
	return (c[1]+m),(c[2]+m),(c[3]+m)
end
graphics.hslToRgb2 = hslToRgb2
utils.hslToRgb2 = hslToRgb2

-- https://forums.coronalabs.com/topic/15731-handy-code-snippets/?p=226815
-- input h-0-360(deg.), s-0-100(%), v-0-100(%)
local function hsvToRgb(h,s,v)
	if s == 0 then return v*.01,v*.01,v*.01 end
	local c, h = ((s*.01)*(v*.01)), (h%360)/60
	local x, m = c*(1-math.abs(h%2-1)), (v*.01)-c
	c = ({{c,x,0},{x,c,0},{0,c,x},{0,x,c},{x,0,c},{c,0,x}})[math.ceil(h)] or {c,x,0}
	return (c[1]+m),(c[2]+m),(c[3]+m)
end
graphics.hsvToRgb = hsvToRgb
utils.hsvToRgb = hsvToRgb

return utils
