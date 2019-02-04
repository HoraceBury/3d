-- timer lib

local tags = {}

local cancel, pause, performWithDelay, resume = timer.cancel, timer.pause, timer.performWithDelay, timer.resume

timer.cancel = function( idOrTag )
	if (type(idOrTag) == "string") then
		cancel( tags[idOrTag] )
		tags[idOrTag] = nil
	else
		cancel( idOrTag )
	end
end

timer.pause = function( idOrTag )
	if (type(idOrTag) == "string") then
		return pause( tags[idOrTag] )
	else
		return pause( idOrTag )
	end
end

--[[
	Adds the optional tag parameter to the standard performWithDelay function.
	
	Parameters:
		tag: optional, allows naming the timer created
		delay: delay in milliseconds
		listener: callback function
		iterations: (optional) number of times to repeat, default is 1, 0 is infinite
	
	Returns:
		The timer handle created.
]]--
timer.performWithDelay = function( ... )
	if (type(arg[1]) == "string") then
		local tag = table.remove( arg, 1 )
		local id = performWithDelay( unpack( arg ) )
		if (id) then
			tags[tag] = id
			return id
		end
		return
	else
		return performWithDelay( unpack( arg ) )
	end
end

timer.resume = function( idOrTag )
	if (type(idOrTag) == "string") then
		return resume( tags[idOrTag] )
	else
		return resume( idOrTag )
	end
end
