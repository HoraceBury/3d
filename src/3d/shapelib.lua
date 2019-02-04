-- shape lib

-- http://www.deviantart.com/browse/all/artisan/origami/cubeecraft/?view_mode=2&order=9&q=spaceship

local json = require("json")
local texturelib = require("3d.texturelib")

local function getImageDimensions( ... )
	local image = display.newImage( unpack( arg ) )
	local dims = { width=image.width, height=image.height }
	image = display.remove( image )
	return dims
end

local lib = {}

local function getImageSheetFromFacets( facets )
	local dim = getImageDimensions( facets.filename )
	
	local frames = {}
	
	local imagesheet = {
		sheetContentWidth = dim.width,
		sheetContentHeight = dim.height,
		frames = frames,
	}
	
	for i=1, #facets do
		frames[#frames+1] = facets[i].frame
	end
	
--	print(json.prettify(json.encode(imagesheet)))
	
	return imagesheet
end
lib.getImageSheetFromFacets = getImageSheetFromFacets

local function newSphere( filename, normalfilename, radius, rows, cols )
	local function pointOnSphere( radius, row, col, rows, cols, corner )
		local latangle = row*(180/rows)
		
		if (row == 0) then
			latangle = .01
		elseif (row == rows) then
			latangle = 179.99
		end
		
		local latitude = math.rotateTo( {x=0,y=-radius }, latangle )
		local longitude = math.rotateTo( {x=0,y=latitude.x}, col*(360/cols) )
		
		return { longitude.x, latitude.y, longitude.y, 1 }
	end
	
	local function createFacetRow( dim, radius, rowindex, rows, cols, rowheight, filename, facets )
		local colwidth = dim.width/cols
		
		for c=1, cols do
			local x, y = -dim.width/2+c*colwidth-colwidth/2, -dim.height/2+rowindex*rowheight-rowheight/2
			
			facets[#facets+1] = {
				flat={},
				transformed={},
				filename=filename,
				image=nil,
				rect={
					width=colwidth,
					height=rowheight,
				},
				fill={
--					x=x/dim.width,
--					y=y/dim.height,
--					scaleX=cols,
--					scaleY=rows,
					process="imagesheet"
				},
				frame={
					x=x+dim.width/2-colwidth/2, y=y+dim.height/2-rowheight/2,
					width=colwidth, height=rowheight,
				},
				pointOnSphere( radius, rowindex-1, c-1, rows, cols ),
				pointOnSphere( radius, rowindex, c-1, rows, cols ),
				pointOnSphere( radius, rowindex, c, rows, cols ),
				pointOnSphere( radius, rowindex-1, c, rows, cols ),
			}
		end
	end
	
	local function createFacets( dim, radius, rows, cols, filename, facets )
		local rowheight = dim.height/rows
		
		for r=1, rows do
			if (r == 1) then
				createFacetRow( dim, radius, 1, rows*4, cols, rowheight/4, filename, facets )
				createFacetRow( dim, radius, 2, rows*4, cols, rowheight/4, filename, facets )
				createFacetRow( dim, radius, 2, rows*2, cols, rowheight/2, filename, facets )
			elseif (r == rows) then
				createFacetRow( dim, radius, rows*2-1, rows*2, cols, rowheight/2, filename, facets )
				createFacetRow( dim, radius, rows*4-1, rows*4, cols, rowheight/4, filename, facets )
				createFacetRow( dim, radius, rows*4, rows*4, cols, rowheight/4, filename, facets )
			else
				createFacetRow( dim, radius, r, rows, cols, rowheight, filename, facets )
			end
		end
	end
	
	local name = string.extractFilenameAndExt( filename )
	
	local facets = {
		name = name,
		isDirtyRender = true,
		group = nil, -- will reference the facets table when textured
		filename = filename,
		normalfilename = normalfilename,
--		flat = nil, -- flattened points for the whole shape (includes z)
--		transformed = nil, -- points for the whole shape
		matrix = math.newXRotationMatrix(0), -- will be this object's transform matrix
		location = {x=0,y=0,z=0,rx=0,ry=0,rz=0}, -- location in space
	}
	
	local dim = getImageDimensions( filename )
	createFacets( dim, radius, rows, cols, filename, facets )
	
--	print(json.prettify(json.encode(facets)))
	
	return facets
end
lib.newSphere = newSphere

local function newOutlinedImage( filename, thickness, textureEdgeFacets )
	local shrinkname, maskname = texturelib.generateMask( filename )
	local outline = graphics.newOutline( 1, shrinkname, system.DocumentsDirectory )
	local name = string.extractFilenameAndExt( filename )
	
	local facets = {
		name = name,
		isDirtyRender = true,
		group = nil, -- will reference the facets table when textured
		filename = filename,
--		flat = nil, -- for the whole shape
--		transformed = nil, -- for the whole shape
		matrix = math.newXRotationMatrix(0), -- will be this object's transform matrix
		location = {x=0,y=0,z=0,rx=0,ry=0,rz=0}, -- location in space
	}
	
	local image = getImageDimensions( filename )
	local hw, hh = image.width/2, image.height/2
	
	for i=1, #outline-1, 2 do
		outline[i] = outline[i] - hw
		outline[i+1] = outline[i+1] - hh
	end
	
	for i=#outline-1, 3, -2 do
		local len = math.lengthOf( outline[i-2], outline[i-1], outline[i-0], outline[i+1] )
		facets[#facets+1] = {
			flat={},
			transformed={},
			filename=nil,
			image=nil,
			rect={
				width=.0001,
				height=len,
			},
			fill=nil,
			{ outline[i-0], outline[i+1], thickness, 1 },
			{ outline[i-2], outline[i-1], thickness, 1 },
			{ outline[i-2], outline[i-1], -thickness, 1 },
			{ outline[i-0], outline[i+1], -thickness, 1 },
		}
		
		if (textureEdgeFacets) then
			facets[#facets].fill = {
				filename=filename,
				baseDir=system.ResourcesDirectory,
				x=((outline[i-0]+outline[i-2])/2)/image.width,
				y=((outline[i-1]+outline[i+1])/2)/image.height,
				scaleX=(image.width/.0001)*1,
				scaleY=(image.height/len)*5,
				rotation=-(math.angleOf( outline[i-0], outline[i+1], outline[i-2], outline[i-1] )-90),
			}
		end
	end
	
	local len = math.lengthOf( outline[#outline-1], outline[#outline], outline[1], outline[2] )
	facets[#facets+1] = {
		flat={},
		transformed={},
		filename=filename,
		image=nil,
		rect={
			width=20,
			height=math.lengthOf( outline[#outline-1], outline[#outline], outline[1], outline[2] ),
		},
		fill={
			filename=filename,
			baseDir=system.ResourcesDirectory,
			x=((outline[#outline-1]+outline[1])/2)/image.width,
			y=((outline[#outline]+outline[2])/2)/image.height,
			scaleX=(image.width/.0001)*1,
			scaleY=(image.height/len)*5,
			rotation=-(math.angleOf( outline[#outline-1], outline[#outline], outline[1], outline[2] )-90),
		},
		{ outline[1], outline[2], thickness, 1 },
		{ outline[#outline-1], outline[#outline], thickness, 1 },
		{ outline[#outline-1], outline[#outline], -thickness, 1 },
		{ outline[1], outline[2], -thickness, 1 },
	}
	
	facets[#facets+1] = {
		flat={},
		transformed={},
		filename=filename,
		image=nil,
		rect={
			width=image.width,
			height=image.height,
		},
		fill={ x=0, y=0, scaleX=1, scaleY=1 },
		sorttofront=true,
		{ -hw, -hh, -thickness, 1 },
		{ -hw, hh, -thickness, 1 },
		{ hw, hh, -thickness, 1 },
		{ hw, -hh, -thickness, 1 },
	}
	
	facets[#facets+1] = {
		flat={},
		transformed={},
		filename=filename,
		image=nil,
		rect={
			width=image.width,
			height=image.height,
		},
		fill={ x=0, y=0, scaleX=-1, scaleY=1 },
		sorttofront=true,
		{ hw, -hh, thickness, 1 },
		{ hw, hh, thickness, 1 },
		{ -hw, hh, thickness, 1 },
		{ -hw, -hh, thickness, 1 },
	}
	
	return facets
end
lib.newOutlinedImage = newOutlinedImage

return lib
