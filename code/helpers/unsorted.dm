//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
 * A large number of misc global procs.
 */

//Inverts the colour of an HTML string
/proc/invertHTML(HTMLstring)

	if (!(istext(HTMLstring)))
		CRASH("Given non-text argument!")
		return
	else
		if(length(HTMLstring) != 7)
			CRASH("Given non-HTML argument!")
			return
	var/text_r = copytext(HTMLstring, 2, 4)
	var/text_g = copytext(HTMLstring, 4, 6)
	var/text_b = copytext(HTMLstring, 6, 8)
	var/r = hex2Num(text_r)
	var/g = hex2Num(text_g)
	var/b = hex2Num(text_b)
	text_r = num2Hex(255 - r, 2)
	text_g = num2Hex(255 - g, 2)
	text_b = num2Hex(255 - b, 2)
	return text("#[][][]", text_r, text_g, text_b)


/proc/getAngle(atom/movable/start, atom/movable/end)//For beams.
	if(!start || !end)
		return 0
	var/d_y
	var/d_x
	d_y = (32 * end.y + end.pixel_y) - (32 * start.y + start.pixel_y)
	d_x = (32 * end.x + end.pixel_x) - (32 * start.x + start.pixel_x)
	if(!d_y)
		return (d_x >= 0) ? 90 : 270
	. = arctan(d_x / d_y)
	if(d_y < 0)
		. += 180
	else if(d_x < 0)
		. += 360

/proc/getLine(atom/M, atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/p_x = M.x		//starting x
	var/p_y = M.y
	var/line[] = list(locate(p_x, p_y, M.z))
	var/d_x = N.x-p_x	//x distance
	var/d_y = N.y-p_y
	var/d_x_abs = abs(d_x)//Absolute value of x distance
	var/d_y_abs = abs(d_y)
	var/s_d_x = sign(d_x)	//Sign of x distance (+ or -)
	var/s_d_y = sign(d_y)
	var/x = d_x_abs >> 1	//Counters for steps taken, setting to distance/2
	var/y = d_y_abs >> 1	//Bit-shifting makes me l33t.  It also makes getLine() unnessecarrily fast.
	if(d_x_abs >= d_y_abs)	//x distance is greater than y
		for(var/j = 0; j < d_x_abs; j++)//It'll take d_x_abs steps to get there
			y += d_y_abs
			if(y >= d_x_abs)	//Every d_y_abs steps, step once in y direction
				y -= d_x_abs
				p_y += s_d_y
			p_x += s_d_x		//Step on in x direction
			line += locate(p_x, p_y, M.z)//Add the turf to the list
	else
		for(var/j = 0; j < d_y_abs; j++)
			x += d_x_abs
			if(x >= d_y_abs)
				x -= d_y_abs
				p_x += s_d_x
			p_y += s_d_y
			line += locate(p_x, p_y, M.z)
	return line

//Returns whether or not a player is a guest using their ckey as an input
/proc/isGuestKey(key)
	if (findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return 0

	var/i
	var/ch
	var/length = length(key)

	for (i = 7, i <= length, ++i)
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57)
			return 0
	return 1

//Turns 1479 into 147.9
/proc/formatFrequency(f)
	return "[round(f / 10)].[f % 10]"

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/getEdgeTargetTurf(atom/A, direction)

	var/turf/target = getTurf(A)
	if(!A || !target)
		return 0
		//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

		// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)

	return target

// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/getRangedTargetTurf(atom/A, direction, range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	if(direction & WEST)
		x = max(1, x - range)

	return locate(x, y, A.z)


// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/getOffsetTargetTurf(atom/A, d_x, d_y)
	var/x = min(world.maxx, max(1, A.x + d_x))
	var/y = min(world.maxy, max(1, A.y + d_y))
	return locate(x, y, A.z)


//Will return the contents of an atom recursivly to a depth of 'searchDepth'
/atom/proc/getAllContents(search_depth = 5)
	. = list()

	for(var/atom/part in contents)
		. += part
		if(part.contents.len && search_depth)
			. += part.getAllContents(search_depth - 1)


/atom/proc/getTypeInAllContents(type_path, search_depth = 5)
	for(var/atom/part in contents)
		if(istype(part, type_path))
			return 1
		if(part.contents.len && search_depth)
			if(part.getTypeInAllContents(type_path, search_depth - 1))
				return 1
	return 0


//Step-towards method of determining whether one atom can see another. Similar to viewers()
/proc/canSee(atom/source, atom/target, length = 5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = getTurf(source)
	var/turf/target_turf = getTurf(target)
	var/steps = 0

	while(current != target_turf)
		if(steps > length)
			return 0
		if(current.opacity)
			return 0
		for(var/atom/A in current)
			if(A.opacity)
				return 0
		current = get_step_towards(current, target_turf)
		steps++

	return 1

/proc/isBlockedTurf(turf/T)
	. = 0
	if(T.density)
		. = 1
	for(var/atom/A in T)
		if(A.density)//&&A.anchored
			. = 1

/proc/getStepTowards2(atom/ref , atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref,trg))
	var/turf/temp = get_step_towards(ref,trg)

	if(isBlockedTurf(temp))
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile = null
		var/break_point = 0

		while(!free_tile && break_point < 10)
			if(!isBlockedTurf(turf_last1))
				free_tile = turf_last1
				break
			if(!isBlockedTurf(turf_last2))
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1, dir_alt1)
			turf_last2 = get_step(turf_last2, dir_alt2)
			break_point++

		if(!free_tile)
			return get_step(ref, base_dir)
		else
			return get_step_towards(ref, free_tile)

	else
		return get_step(ref, base_dir)

//Takes: Anything that could possibly have variables and a varname to check.
//Returns: 1 if found, 0 if not.
/proc/hasVar(datum/A, var_name)
	if(A.vars.Find(lowertext(var_name)))
		return 1
	return 0

//Returns: all the areas in the world
/proc/returnAreas()
	. = list()
	for(var/area/A in world)
		. += A

//Returns: all the areas in the world, sorted.
/proc/returnSortedAreas()
	return sortList(returnAreas())

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/getAreaTypes(area_type)
	if(!area_type)
		return null
	if(istext(area_type))
		area_type = text2path(area_type)
	if(isarea(area_type))
		var/area/area_temp = area_type
		area_type = area_temp.type

	. = list()
	for(var/area/N in returnAreas())
		if(istype(N, area_type))
			. += N

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all atoms	(objs, turfs, mobs) in areas of that type of that type in the world.
/proc/getAtomsInArea(area_type)
	if(!area_type)
		return null
	if(istext(area_type))
		area_type = text2path(area_type)
	if(isarea(area_type))
		var/area/area_temp = area_type
		area_type = area_temp.type

	. = list()
	for(var/area/AR in getAreaTypes(area_type))
		for(var/atom/A in AR)
			. += A

/proc/duplicateObject(atom/movable/original, perfect_copy = 0 , same_loc = 0)
	if(!original)
		return null

	var/atom/movable/O = new original.type()

	if(same_loc)
		O.loc = original.loc

	if(perfect_copy)
		for(var/V in original.vars)
			if(!(V in list("type", "loc", "locs", "vars", "parent", "parent_type", "verbs", "ckey", "key")))
				O.vars[V] = original.vars[V]
	return O

proc/getCardinalDir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx + dy) < dy ? 3 : 12)

/proc/getTurf(atom/movable/AM)
	if(istype(AM))
		return getTurf(AM.loc)
	else if(isturf(AM))
		return AM

/proc/formatText(text)
	return replaceText(replaceText(text,"\proper ",""),"\improper ","")