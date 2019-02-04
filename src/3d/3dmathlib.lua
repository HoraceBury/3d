-- 3d math lib

-- https://github.com/GregLukosek/3DMath
-- https://gist.github.com/BlackBulletIV/1055480
-- http://stackoverflow.com/questions/38275887/calculate-the-angle-between-a-point-and-a-3d-facet/38280979
-- http://www.fundza.com/vectors/normalize/
-- http://geomalgorithms.com/a03-_inclusion.html
-- http://ncalculators.com/matrix/3x3-matrix-multiplication-calculator.htm
-- https://www.mathsisfun.com/algebra/matrix-multiplying.html
-- http://www.scratchapixel.com/lessons/3d-basic-rendering/perspective-and-orthographic-projection-matrix/building-basic-perspective-projection-matrix
-- http://www.angusj.com/delphi/clipper.php
-- http://stackoverflow.com/questions/1109536/an-algorithm-for-inflating-deflating-offsetting-buffering-polygons
-- https://chortle.ccsu.edu/VectorLessons/vch07/vch07_14.html
-- https://www.mathsisfun.com/algebra/vectors-dot-product.html
-- http://www.mvps.org/DirectX/articles/math/dot/index.htm
-- http://www.intmath.com/vectors/7-vectors-in-3d-space.php#anglebetweenvectors
-- https://goocreate.com/learn/everything-you-always-wanted-to-know-about-rotation/
-- https://keithmaggio.wordpress.com/2011/01/19/math-magician-lookat-algorithm/
-- http://jwbales.us/precal/part6/part6.4.html
-- http://www.mathwarehouse.com/trigonometry/
-- http://stackoverflow.com/questions/15580952/angles-of-3d-vector-getting-both ***
-- http://www.euclideanspace.com/maths/geometry/affine/aroundPoint/
-- http://www.programming-techniques.com/2012/03/3d-rotation-algorithm-about-arbitrary.html

local normals = {
	{
		{ -100, -100, 100, 1 },
		{ -100, -100, -100, 1 },
		{ 100, -100, -100, 1 },
		{ 100, -100, 100, 1 },
	},
	{
		{ -100, -100, -100, 1 },
		{ -100, -100, 100, 1 },
		{ 100, -100, 100, 1 },
		{ 100, -100, -100, 1 },
	},
	{
		{ -100, -100, -100, 1 },
		{ -100, 100, -100, 1 },
		{ -100, 100, 100, 1 },
		{ -100, -100, 100, 1 },
	},
	{
		{ -100, -100, 100, 1 },
		{ -100, 100, 100, 1 },
		{ -100, 100, -100, 1 },
		{ -100, -100, -100, 1 },
	},
	{
		{ 100, -100, 100, 1 },
		{ 100, 100, 100, 1 },
		{ -100, 100, 100, 1 },
		{ -100, -100, 100, 1 },
	},
	{
		{ -100, -100, 100, 1 },
		{ -100, 100, 100, 1 },
		{ 100, 100, 100, 1 },
		{ 100, -100, 100, 1 },
	},
	{
		{ -100, -100, -100, 1 },
		{ -100, 100, -100, 1 },
		{ 100, 100, -100, 1 },
		{ 100, -100, -100, 1 },
	}
}

local lib = {}

local function newEmptyMatrix(...)
	if (arg[1] == nil) then
		return {
			{0,0,0,0},
			{0,0,0,0},
			{0,0,0,0},
			{0,0,0,0},
		}
	else
		return {
			{1,0,0,0},
			{0,1,0,0},
			{0,0,1,0},
			{0,0,0,1},
		}
	end
end
math.newEmptyMatrix = newEmptyMatrix
lib.newEmptyMatrix = newEmptyMatrix

local function newIdentityMatrix()
	return {
		{1,1,1,1},
	}
end
math.newIdentityMatrix = newIdentityMatrix
lib.newIdentityMatrix = newIdentityMatrix

local function setXYZ( indentmatrix, x, y, z )
	identmatrix = identmatrix or lib.newIdentityMatrix()
	indentmatrix[1][1] = x
	indentmatrix[1][2] = y
	indentmatrix[1][3] = z
end
math.setXYZ = setXYZ
lib.setXYZ = setXYZ

local function new3dMatrix( x, y, z )
	if (x == nil) then
		return {
			{0,0,0,0},
			{0,0,0,0},
			{0,0,0,0},
			{0,0,0,0},
		}
	elseif (type(x) == "table") then
		return {
			{x[1],x[2],x[3],0},
			{y[1],y[2],y[3],0},
			{z[1],z[2],z[3],0},
			{0,0,0,1},
		}
	else
		return {
			{x or 1,0,0,0},
			{0,y or 1,0,0},
			{0,0,z or 1,0},
			{0,0,0,1},
		}
	end
end
math.new3dMatrix = new3dMatrix
lib.new3dMatrix = new3dMatrix

local function newTranslationMatrix( x, y, z )
	return {
		{1,0,0,0},
		{0,1,0,0},
		{0,0,1,0},
		{x,y,z,1},
	}
end
math.newTranslationMatrix = newTranslationMatrix
lib.newTranslationMatrix = newTranslationMatrix

local function newXRotationMatrix( x )
	x = math.rad(x)
	return {
		{1,0,0,0},
		{0,math.cos(x),math.sin(x),0},
		{0,-math.sin(x),math.cos(x),0},
		{0,0,0,1},
	}
end
math.newXRotationMatrix = newXRotationMatrix
lib.newXRotationMatrix = newXRotationMatrix

local function newYRotationMatrix( y )
	y = math.rad(y)
	return {
		{math.cos(y),0,-math.sin(y),0},
		{0,1,0,0},
		{math.sin(y),0,math.cos(y),0},
		{0,0,0,1},
	}
end
math.newYRotationMatrix = newYRotationMatrix
lib.newYRotationMatrix = newYRotationMatrix

local function newZRotationMatrix( z )
	z = math.rad(z)
	return {
		{math.cos(z),math.sin(z),0,0},
		{-math.sin(z),math.cos(z),0,0},
		{0,0,1,0},
		{0,0,0,1},
	}
end
math.newZRotationMatrix = newZRotationMatrix
lib.newZRotationMatrix = newZRotationMatrix

local function newAxisRotationMatrix( angle, u, v, w )
    local L = (u*u + v * v + w * w)
    angle = math.rad(angle)
    
    local u2 = u * u
    local v2 = v * v
    local w2 = w * w
    
    local rotationMatrix = { {}, {}, {}, {} }
    
    rotationMatrix[1][1] = (u2 + (v2 + w2) * math.cos(angle)) / L
    rotationMatrix[1][2] = (u * v * (1 - math.cos(angle)) - w * math.sqrt(L) * math.sin(angle)) / L
    rotationMatrix[1][3] = (u * w * (1 - math.cos(angle)) + v * math.sqrt(L) * math.sin(angle)) / L
    rotationMatrix[1][4] = 0.0
    
    rotationMatrix[2][1] = (u * v * (1 - math.cos(angle)) + w * math.sqrt(L) * math.sin(angle)) / L
    rotationMatrix[2][2] = (v2 + (u2 + w2) * math.cos(angle)) / L
    rotationMatrix[2][3] = (v * w * (1 - math.cos(angle)) - u * math.sqrt(L) * math.sin(angle)) / L
    rotationMatrix[2][4] = 0.0
    
    rotationMatrix[3][1] = (u * w * (1 - math.cos(angle)) - v * math.sqrt(L) * math.sin(angle)) / L
    rotationMatrix[3][2] = (v * w * (1 - math.cos(angle)) + u * math.sqrt(L) * math.sin(angle)) / L
    rotationMatrix[3][3] = (w2 + (u2 + v2) * math.cos(angle)) / L
    rotationMatrix[3][4] = 0.0
    
    rotationMatrix[4][1] = 0.0
    rotationMatrix[4][2] = 0.0
    rotationMatrix[4][3] = 0.0
    rotationMatrix[4][4] = 1.0
    
    return rotationMatrix
end
lib.newAxisRotationMatrix = newAxisRotationMatrix
math.newAxisRotationMatrix = newAxisRotationMatrix

local function newScalingMatrix( x, y, z )
	return {
		{x,0,0,0},
		{0,y,0,0},
		{0,0,z,0},
		{0,0,0,1},
	}
end
math.newScalingMatrix = newScalingMatrix
lib.newScalingMatrix = newScalingMatrix

local function translateMatrix( matrix, x, y, z )
	local xyz = matrix[4]
	
	if (x) then xyz[1] = xyz[1] + x end
	if (y) then xyz[2] = xyz[2] + y end
	if (z) then xyz[3] = xyz[3] + z end
	
	return matrix
end
math.translateMatrix = translateMatrix
lib.translateMatrix = translateMatrix

local function rotateMatrix( matrix, rx, ry, rz )
	if (rx and rx ~= 0) then
		matrix = lib.multiply( matrix, lib.newXRotationMatrix( rx ) )
	end
	if (ry and ry ~= 0) then
		matrix = lib.multiply( matrix, lib.newYRotationMatrix( ry ) )
	end
	if (rz and rz ~= 0) then
		matrix = lib.multiply( matrix, lib.newZRotationMatrix( rz ) )
	end
	return matrix
end
math.rotateMatrix = rotateMatrix
lib.rotateMatrix = rotateMatrix

local function scaleMatrix( matrix, sx, sy, sz )
	
end
math.scaleMatrix = scaleMatrix
lib.scaleMatrix = scaleMatrix

local function printMatrix( matrix )
	local str = ""
	for r=1, #matrix do
		for c=1, #matrix[1] do
			str = str .. "\t" .. string.sub( tostring(matrix[r][c]), 1, 6 )
		end
		str = str .. "\n"
	end
	print(str)
end
math.printMatrix = printMatrix
lib.printMatrix = printMatrix

local function multiplyMatrix( aMatrix, bMatrix )
    if (#aMatrix[1] ~= #bMatrix) then       -- inner matrix-dimensions must agree
        return nil      
    end
    
    local empty = newEmptyMatrix()
    
    for aRow = 1, #aMatrix do
        for bCol = 1, #bMatrix[1] do
			local sum = empty[aRow][bCol]
            for bRow = 1, #bMatrix do
                sum = sum + aMatrix[aRow][bRow] * bMatrix[bRow][bCol]
            end
            empty[aRow][bCol] = sum
        end
    end
    
    return empty
end
math.multiplyMatrix = multiplyMatrix
lib.multiplyMatrix = multiplyMatrix

local function multiply( ... )
	local matrix = arg[1]
	
	for i=2, #arg do
		matrix = multiplyMatrix( matrix, arg[i] )
	end
	
	return matrix
end
math.multiply = multiply
lib.multiply = multiply

--[[
	Transpose a matrix - essentially reflect it across it's diagonal.
	
	Ref:
		https://en.wikipedia.org/wiki/Transpose
]]--
local function transposeMatrix( matrix )
	local transposed = {}
	for c=1, #matrix[1] do
		local row = {}
		transposed[#transposed+1] = row
		for r=1, #matrix do
			row[#row+1] = matrix[r][c]
		end
	end
	return transposed
end

--[[
	Builds a new matrix from a list of transformations.
	
	Parameters are a list of the following:
		{ { instruction, value }[, { instruction, value } ] }
	
	Instruction values:
		{ "xzy", xValue, yValue, zValue }
		{ "rx", rxValue }
		{ "ry", ryValue }
		{ "rz", rzValue }
	
	Returns:
		A new matrix generated from applying the sequence of tranforms to a new matrix.
]]--
local function buildMatrix( ... )
	local matrix = newEmptyMatrix()
	
	for i=1, #arg do
		local param = arg[i]
		if (param[1] == "xyz") then
			matrix = multiply( matrix, newTranslationMatrix( param[2], param[3], param[4] ) )
		elseif (param[1] == "rx") then
			matrix = multiply( matrix, newXRotationMatrix( param[2] ) )
		elseif (param[1] == "ry") then
			matrix = multiply( matrix, newYRotationMatrix( param[2] ) )
		elseif (param[1] == "rz") then
			matrix = multiply( matrix, newZRotationMatrix( param[2] ) )
		end
	end
	
	return matrix
end
math.buildMatrix = buildMatrix
lib.buildMatrix = buildMatrix

--[[
	Calculates the dot product of two 3d vectors.
	
	Parameters:
		a: {x,y,z} point in 3d space
		b: {x,y,z} point in 3d space
	
	Returns:
		The dot product, or magnitude, between the two vectors.
	
	Ref:
		https://chortle.ccsu.edu/VectorLessons/vch07/vch07_14.html
]]--
local function vector2d3dDotProduct( a, b )
	return a.x*b.x + a.y*b.y + (a.z or 0)*(b.z or 0)
end
math.vector2d3dDotProduct = vector2d3dDotProduct
lib.vector2d3dDotProduct = vector2d3dDotProduct

--[[
	Any number of dimensions dot product calculator.
]]--
local function dot_product( a, b, size )
	local dp = 0.0
	
	for i=1, size do
		dp = dp + a[i] * b[i]
	end
	
	return dp
end
math.dot_product = dot_product
lib.dot_product = dot_product

--[[
	Calculate the angle between a vector and a plane. The plane is made by a normal vector.
	Output is in radians and degrees.
	
	Parameters:
		vector: {x,y,z} point in 3d space
		normal: {x,y,z} point in 3d space
	
	Returns:
		Dot product of the two vectors
		Angle in radians
]]--
local function AngleVectorPlane( vector, normal )
	-- calculate the the dot product between the two input vectors.
	-- This gives the cosine between the two vectors.
	local dot = vector2d3dDotProduct( vector, normal )
	
	-- this is in radians
	local angle = math.cos( dot )
	
	return dot, math.deg( math.rad(90) - angle ) -- rad: 1.570796326794897 degress: 90 - angle
end
math.AngleVectorPlane = AngleVectorPlane
lib.AngleVectorPlane = AngleVectorPlane

-- Get length of 2D or 3D vector
local function vector2d3dLength( vector )
--	return math.sqrt( vector.x*vector.x + vector.y*vector.y + (vector.z or 0)*(vector.z or 0) )
	return math.sqrt( vector[1]*vector[1] + vector[2]*vector[2] + vector[3]*vector[3] )
end
math.vector2d3dLength = vector2d3dLength
lib.vector2d3dLength = vector2d3dLength

local function vector2d3dLengthOf( a, b )
	return math.vector2d3dLength{ b[1]-a[1], b[2]-a[2], b[3]-a[3] }
end
lib.vector2d3dLengthOf = vector2d3dLengthOf
math.vector2d3dLengthOf = vector2d3dLengthOf

-- Normalise 2D or 3D vector
local function normalise2d3dVector( vector )
	local len = vector2d3dLength( vector )
	
	if (len == 0) then
		return vector
	end
	
	local normalised = { vector[1]/len, vector[2]/len, vector[3]/len }
	
	return normalised
end
math.normalise2d3dVector = normalise2d3dVector
lib.normalise2d3dVector = normalise2d3dVector

local function dotProduct3d( a, b )
--	return a.x*b.x + a.y*b.y + a.z*b.z
	return a[1]*b[1] + a[2]*b[2] + a[3]*b[3]
end
math.dotProduct3d = dotProduct3d
lib.dotProduct3d = dotProduct3d

--[[
	Returns 3D angle between 2 points in space.
	
	Ref: http://stackoverflow.com/a/30968954/71376
	
	Original:
		We can find angle between 2 vectors according the dot production.
		angle = arccos ( a * b / |a| * |b| );
		where: 
		a * b = ax * bx + ay * by + az * bz
		|a| = sqrt( ax * ax + ay * ay + az * az )
		|b| = sqrt( bx * bx + by * by + bz * bz )
		Or just use this method: http://docs.unity3d.com/ScriptReference/Vector3.Angle.html
]]--
local function angle3dOf( a, b )
	if (a[1] ~= nil and a.x == nil) then
		a = {x=a[1],y=a[2],z=a[3]}
		b = {x=b[1],y=b[2],z=b[3]}
	end
	
	return math.acos(
		(a.x * b.x + a.y * b.y + a.z * b.z) /
		math.sqrt( a.x * a.x + a.y * a.y + a.z * a.z ) * math.sqrt( b.x * b.x + b.y * b.y + b.z * b.z )
	)
end

local function lengthOf3d( a, b )
	local vector = { x=b.x-a.x, y=b.y-a.y, z=b.z-a.z }
	return vector2d3dLength( vector )
end
math.lengthOf3d = lengthOf3d
lib.lengthOf3d = lengthOf3d

local function crossProduct3d( a, b )
	return {
		a[2]*b[3] - a[3]*b[2],
		a[3]*b[1] - a[1]*b[3],
		a[1]*b[2] - a[2]*b[1],
	}
end
math.crossProduct3d = crossProduct3d
lib.crossProduct3d = crossProduct3d

-- subtract vector b from vector a
local function subtract2d3dVectors( a, b )
--	local sub = { x=a.x-b.x, y=a.y-b.y }
	local sub = { a[1]-b[1], a[2]-b[2], a[3]-b[3] }
	
--	if (a.z ~= nil and b.z ~= nil) then
--		sub.z = a.z-b.z
--	end
	
	return sub
end
math.subtract2d3dVectors = subtract2d3dVectors
lib.subtract2d3dVectors = subtract2d3dVectors

--[[
	Returns the normalised direction vector of a facet.
	
	Parameters:
		facet: Defined as at least 3 points comprised of x,y,z values (integer indexed)
	
	Returns:
		{x,y,z}: Normalised (values divided by overall length) of the direction vector.
	
	Note:
		Returns incorrect values because back-facing values can have -0 instead of the correct 0 value.
]]--
local function getNormalDirectionVectorOfFacet( facet )
	local abVector = math.subtract2d3dVectors( facet[1], facet[2] )
	local abDirectionVector = math.normalise2d3dVector( abVector )
	
	local acVector = math.subtract2d3dVectors( facet[1], facet[4] )
	local acDirectionVector = math.normalise2d3dVector( acVector )
	
	local cross = math.crossProduct3d( abDirectionVector, acDirectionVector )
	
	return cross
end
--math.getNormalDirectionVectorOfFacet = getNormalDirectionVectorOfFacet
--lib.getNormalDirectionVectorOfFacet = getNormalDirectionVectorOfFacet

--Begin Function CalculateSurfaceNormal (Input Polygon) Returns Vector
--[[
	Calculates the surface normal (facing direction) of a polygon.
	
	Parameters:
		Polygon: Table of tables containing integer-indexed {x,y,z} values of the polygon points.
	
	Returns:
		Normalised vector indicating the 3D polygon's facing direction.
	
	Ref:
		https://www.opengl.org/wiki/Calculating_a_Surface_Normal
]]--
local function calculateSurfaceNormal( polygon )
	local normal = {0,0,0}
	
	for i=0, #polygon-1 do
		local index, nxtindex = i+1, ((i+1)%#polygon)+1
		local current = polygon[index]
		local nxt = polygon[nxtindex]
		
		normal[1] = normal[1] + ((current[2] - nxt[2]) * (current[3] + nxt[3]))
		normal[2] = normal[2] + ((current[3] - nxt[3]) * (current[1] + nxt[1]))
		normal[3] = normal[3] + ((current[1] - nxt[1]) * (current[2] + nxt[2]))
	end
	
	return math.normalise2d3dVector( normal )
end
math.calculateSurfaceNormal = calculateSurfaceNormal
lib.calculateSurfaceNormal = calculateSurfaceNormal

local function test_normals()
	print("\t\txy\txz\tzy")
	for i=1, #normals do
		local a, b = getNormalDirectionVectorOfFacet(normals[i]), calculateSurfaceNormal(normals[i])
		print(
			table.concat(a,","),
			table.concat(b,","),
			math.angleOf(b[1],b[2]),
			math.angleOf(b[1],b[3]),
			math.angleOf(b[3],b[2])
		)
	end
end
--test_normals()

-- http://stackoverflow.com/questions/38275887/calculate-the-angle-between-a-point-and-a-3d-facet/38280979
local function getBrightness( lightsource, facet )
	local facet_normal = normalise2d3dVector(
		crossProduct3d(
			subtract2d3dVectors(facet[2], facet[1]),
			subtract2d3dVectors(facet[3], facet[1])
		)
	)
	
	local subtractedVector = subtract2d3dVectors( lightsource, facet[1] )
	local direction_to_lightsource = normalise2d3dVector( subtractedVector )
	
	local cos_angle = dotProduct3d( direction_to_lightsource, facet_normal )
	
	if (cos_angle < 0) then cos_angle=0 end
	
	return cos_angle, subtractedVector
end
math.getBrightness = getBrightness
lib.getBrightness = getBrightness

-- https://gist.github.com/BlackBulletIV/1055480
-- https://www.mathsisfun.com/algebra/vectors-dot-product.html
-- http://www.mvps.org/DirectX/articles/math/dot/index.htm

-- If A and B are perpendicular (at 90 degrees to each other),
-- the result of the dot product will be zero, because cos(Θ) will be zero.
--print( dotProduct3d( {x=0,y=10,z=10}, {x=10,y=0,z=0} ) )

-- If the angle between A and B are less than 90 degrees,
-- the dot product will be positive (greater than zero),
-- as cos(Θ) will be positive, and the vector lengths are always positive values.
--print( dotProduct3d( {x=0,y=10,z=10}, {x=10,y=5,z=0} ) )

-- If the angle between A and B are greater than 90 degrees,
-- the dot product will be negative (less than zero), as cos(Θ) will be negative,
-- and the vector lengths are always positive values.
--print( dotProduct3d( {x=0,y=10,z=10}, {x=-10,y=5,z=-500} ) )

local function vector3dAngleOf( a, b )
	local a, b = normalise2d3dVector( a ), normalise2d3dVector( b )
	return math.deg(math.acos(dotProduct3d( a, b )))
end
math.vector3dAngleOf = vector3dAngleOf
lib.vector3dAngleOf = vector3dAngleOf

local function getAngleBetweenAandB( a, b )
-- http://stackoverflow.com/questions/19729831/angle-between-3-points-in-3d-space
--[[
	-- FIRST ANSWER...
	v1 = {A.x - B.x, A.y - B.y, A.z - B.z}
	--Similarly the vector BC (call it v2) is:
	v2 = {C.x - B.x, C.y - B.y, C.z - B.z}
	--The dot product of v1 and v2 is a function of the cosine of the angle between them (it's scaled by the product of their magnitudes). So first normalize v1 and v2:
	v1mag = sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z)
	v1norm = {v1.x / v1mag, v1.y / v1mag, v1.z / v1mag}
	v2mag = sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z)
	v2norm = {v2.x / v2mag, v2.y / v2mag, v2.z / v2mag}
	--Then calculate the dot product:
	res = v1norm.x * v2norm.x + v1norm.y * v2norm.y + v1norm.z * v2norm.z
	--And finally, recover the angle:
	angle = acos(res)
	
	-- SECOND ANSWER
	double GetAngleABC( double* a, double* b, double* c )
	{
		double ab[3] = { b[0] - a[0], b[1] - a[1], b[2] - a[2] };
		double bc[3] = { c[0] - b[0], c[1] - b[1], c[2] - b[2]  };

		double abVec = sqrt(ab[0] * ab[0] + ab[1] * ab[1] + ab[2] * ab[2]);
		double bcVec = sqrt(bc[0] * bc[0] + bc[1] * bc[1] + bc[2] * bc[2]);

		double abNorm[3] = {ab[0] / abVec, ab[1] / abVec, ab[2] / abVec};
		double bcNorm[3] = {bc[0] / bcVec, bc[1] / bcVec, bc[2] / bcVec};

		double res = abNorm[0] * bcNorm[0] + abNorm[1] * bcNorm[1] + abNorm[2] * bcNorm[2];

		return acos(res)*180.0/ 3.141592653589793;
	}
	double a[] = {1, 0, 0};
	double b[] = {0, 0, 0};
	double c[] = {0, 1, 0};
	std::cout<< "The angle of ABC is " << GetAngleABC(a,b,c)<< "º " << std::endl;
]]--
end

-- Ref: http://stackoverflow.com/questions/15817888/fast-rotation-transformation-matrix-multiplications
--[[
public struct Matrix3 
{
    public readonly double a11, a12, a13;
    public readonly double a21, a22, a23;
    public readonly double a31, a32, a33;
    ...
    public vec3 Multiply(vec3 rhs)
    {
        // y= A*x
        // fill vector by element
        return new vec3(
            (a11*rhs.X+a12*rhs.Y+a13*rhs.Z),
            (a21*rhs.X+a22*rhs.Y+a23*rhs.Z),
            (a31*rhs.X+a32*rhs.Y+a33*rhs.Z));
    }

    public mat3 Multiply(mat3 rhs)
    {
        // Y = A*X
        // fill matrix by row
        return new mat3(
            (a11*rhs.a11+a12*rhs.a21+a13*rhs.a31),
            (a11*rhs.a12+a12*rhs.a22+a13*rhs.a32),
            (a11*rhs.a13+a12*rhs.a23+a13*rhs.a33),

            (a21*rhs.a11+a22*rhs.a21+a23*rhs.a31),
            (a21*rhs.a12+a22*rhs.a22+a23*rhs.a32),
            (a21*rhs.a13+a22*rhs.a23+a23*rhs.a33),

            (a31*rhs.a11+a32*rhs.a21+a33*rhs.a31),
            (a31*rhs.a12+a32*rhs.a22+a33*rhs.a32),
            (a31*rhs.a13+a32*rhs.a23+a33*rhs.a33));
    }
}
]]--

--[[
	This code became the newAxisRotationMatrix function.
	Ref: http://www.programming-techniques.com/2012/03/3d-rotation-algorithm-about-arbitrary.html
void setUpRotationMatrix(float angle, float u, float v, float w)
{
    float L = (u*u + v * v + w * w);
    angle = angle * M_PI / 180.0; //converting to radian value
    float u2 = u * u;
    float v2 = v * v;
    float w2 = w * w; 
 
    rotationMatrix[0][0] = (u2 + (v2 + w2) * cos(angle)) / L;
    rotationMatrix[0][1] = (u * v * (1 - cos(angle)) - w * sqrt(L) * sin(angle)) / L;
    rotationMatrix[0][2] = (u * w * (1 - cos(angle)) + v * sqrt(L) * sin(angle)) / L;
    rotationMatrix[0][3] = 0.0; 
 
    rotationMatrix[1][0] = (u * v * (1 - cos(angle)) + w * sqrt(L) * sin(angle)) / L;
    rotationMatrix[1][1] = (v2 + (u2 + w2) * cos(angle)) / L;
    rotationMatrix[1][2] = (v * w * (1 - cos(angle)) - u * sqrt(L) * sin(angle)) / L;
    rotationMatrix[1][3] = 0.0; 
 
    rotationMatrix[2][0] = (u * w * (1 - cos(angle)) - v * sqrt(L) * sin(angle)) / L;
    rotationMatrix[2][1] = (v * w * (1 - cos(angle)) + u * sqrt(L) * sin(angle)) / L;
    rotationMatrix[2][2] = (w2 + (u2 + v2) * cos(angle)) / L;
    rotationMatrix[2][3] = 0.0; 
 
    rotationMatrix[3][0] = 0.0;
    rotationMatrix[3][1] = 0.0;
    rotationMatrix[3][2] = 0.0;
    rotationMatrix[3][3] = 1.0;
} 
]]--

return lib
