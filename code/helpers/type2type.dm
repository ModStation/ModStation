//Returns an integer given a hex input, supports negative values "-ff"
//skips preceding invalid characters
//breaks when hittin invalid characters thereafter
/proc/hex2Num(hex)
	. = 0
	if(istext(hex))
		var/negative = 0
		var/len = length(hex)
		for(var/i = 1, i <= len, i++)
			var/num = text2ascii(hex,i)
			switch(num)
				if(48 to 57)	num -= 48	//0-9
				if(97 to 102)	num -= 87	//a-f
				if(65 to 70)	num -= 55	//A-F
				if(45)			negative = 1//-
				else
					if(num)		break
					else		continue
			. *= 16
			. += num
		if(negative)
			. *= -1
	return .

//Returns the hex value of a decimal number
//len == length of returned string
//if len < 0 then the returned string will be as long as it needs to be to contain the data
//Only supports positive numbers
//if an invalid number is provided, it assumes num==0
//Note, unlike previous versions, this one works from low to high <-- that way
/proc/num2Hex(num, len=2)
	if(!isnum(num))
		num = 0
	num = round(abs(num))
	. = ""
	var/i = 0
	while(1)
		if(len <= 0)
			if(!num)	break
		else
			if(i >= len)	break
		var/remainder = num / 16
		num = round(remainder)
		remainder = (remainder - num) * 16
		switch(remainder)
			if(1 to 9)
				. = "[remainder]" + .
			if(10 to 15)
				. = ascii2text(remainder+87) + .
			else
				. = "0" + .
		i++
	return .


//Attaches each element of a list to a single string seperated by 'seperator'.
/proc/ddList2Text(list/the_list, separator)
	var/total = the_list.len
	if(!total)
		return
	var/count = 2
	var/newText = "[the_list[1]]"
	while(count <= total)
		if(separator)
			newText += separator
		newText += "[the_list[count]]"
		count++
	return newText


//slower then dd_list2text, but correctly processes associative lists.
proc/tgList2Text(list/list, glue=",")
	if(!istype(list) || !list.len)
		return
	var/output
	for(var/i = 1 to list.len)
		output += (i != 1 ? glue : null) + (!isnull(list["[list[i]]"]) ? "[list["[list[i]]"]]" : "[list[i]]")
	return output


//Converts a text string into a list by splitting the string at each seperator found in text (discarding the seperator)
//Returns an empty list if the text cannot be split, or the split text in a list.
//Not giving a "" seperator will cause the text to be broken into a list of single letters.
/proc/text2List(text, seperator="\n")
	. = list()

	var/text_len = length(text)					//length of the input text
	var/seperator_len = length(seperator)		//length of the seperator text

	if(text_len >= seperator_len)
		var/last_i = 1

		for(var/i = 1, i <= (text_len + 1 - seperator_len), i++)
			if(cmptext(copytext(text, i, i + seperator_len), seperator))
				if(i != last_i)
					. += copytext(text,last_i,i)
				last_i = i + seperator_len

		if(last_i <= text_len)
			. += copytext(text, last_i, 0)
	else
		. += text
	return .

//Converts a text string into a list by splitting the string at each seperator found in text (discarding the seperator)
//Returns an empty list if the text cannot be split, or the split text in a list.
//Not giving a "" seperator will cause the text to be broken into a list of single letters.
//Case Sensitive!
/proc/text2ListEx(text, seperator="\n")
	. = list()

	var/text_len = length(text)					//length of the input text
	var/seperator_len = length(seperator)		//length of the seperator text

	if(text_len >= seperator_len)
		var/last_i = 1

		for(var/i = 1, i <= (text_len + 1 - seperator_len), i++)
			if(cmptextEx(copytext(text, i, i + seperator_len), seperator))
				if(i != last_i)
					. += copytext(text, last_i, i)
				last_i = i + seperator_len

		if(last_i <= text_len)
			. += copytext(text, last_i, 0)
	else
		. += text
	return .

//Splits the text of a file at seperator and returns them in a list.
/proc/file2List(filename, seperator="\n")
	return text2List(returnFileText(filename), seperator)


//Turns a direction into text
/proc/dir2Text(direction)
	switch(direction)
		if(1.0)
			return "north"
		if(2.0)
			return "south"
		if(4.0)
			return "east"
		if(8.0)
			return "west"
		if(5.0)
			return "northeast"
		if(6.0)
			return "southeast"
		if(9.0)
			return "northwest"
		if(10.0)
			return "southwest"
		else
	return

//Turns text into proper directions
/proc/text2Dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return 1
		if("SOUTH")
			return 2
		if("EAST")
			return 4
		if("WEST")
			return 8
		if("NORTHEAST")
			return 5
		if("NORTHWEST")
			return 9
		if("SOUTHEAST")
			return 6
		if("SOUTHWEST")
			return 10
		else
	return

//Converts an angle (degrees) into an ss13 direction
/proc/angle2Dir(var/degree)

	// Will filter out extra rotations and negative rotations
	// E.g: 540 becomes 180. -180 becomes 180.
	// Thanks to Flexicode for the formula.
	degree = ((degree % 360 + 22.5) + 360) % 365

	if(degree < 45)		return NORTH
	if(degree < 90)		return NORTHEAST
	if(degree < 135)	return EAST
	if(degree < 180)	return SOUTHEAST
	if(degree < 225)	return SOUTH
	if(degree < 270)	return SOUTHWEST
	if(degree < 315)	return WEST
	return NORTH|WEST

//returns the north-zero clockwise angle in degrees, given a direction

/proc/dir2Angle(var/D)
	switch(D)
		if(NORTH)		return 0
		if(SOUTH)		return 180
		if(EAST)		return 90
		if(WEST)		return 270
		if(NORTHEAST)	return 45
		if(SOUTHEAST)	return 135
		if(NORTHWEST)	return 315
		if(SOUTHWEST)	return 225
		else			return null

//Returns the angle in english
/proc/angle2Text(var/degree)
	return dir2Text(angle2Dir(degree))

//colour formats //violates pascalCase but rgb2HSL, rgb2Hsl, RGB2HSL all look stupid
/proc/rgb2hsl(red, green, blue)
	red /= 255
	green /= 255
	blue /= 255;
	var/max = max(red,green,blue)
	var/min = min(red,green,blue)
	var/range = max - min

	var/hue=0
	var/saturation=0
	var/lightness=0;
	lightness = (max + min)/2
	if(range != 0)
		if(lightness < 0.5)
			saturation = range / (max + min)
		else
			saturation = range / (2 - max - min)

		var/dred = ((max - red) / (6 * max)) + 0.5
		var/dgreen = ((max - green) / (6 * max)) + 0.5
		var/dblue = ((max - blue) / (6 * max)) + 0.5

		if(max == red)
			hue = dblue - dgreen
		else if(max == green)
			hue = dred - dblue + (1 / 3)
		else
			hue = dgreen - dred + (2 / 3)
		if(hue < 0)
			hue++
		else if(hue > 1)
			hue--

	return list(hue, saturation, lightness)

//violates pascalCase, see above
/proc/hsl2rgb(hue, saturation, lightness)
	var/red
	var/green
	var/blue;
	if(saturation == 0)
		red = lightness * 255
		green = red
		blue = red
	else
		var/a
		var/b
		if(lightness < 0.5)
			b = lightness * (1 + saturation)
		else
			b = (lightness + saturation) - (saturation * lightness)
		a = 2 * lightness - b

		red = round(255 * hue2rgb(a, b, hue + (1 / 3)))
		green = round(255 * hue2rgb(a, b, hue))
		blue = round(255 * hue2rgb(a, b, hue - (1 / 3)))

	return list(red, green, blue)

//violates pascalCase, see above
/proc/hue2rgb(a, b, hue)
	if(hue < 0)
		hue++
	else if(hue > 1)
		hue--
	if(6 * hue < 1)
		return (a + (b - a) * 6 * hue)
	if(2 * hue < 1)
		return b
	if(3 * hue < 2)
		return (a + (b - a) * ((2 / 3) - hue) * 6)
	return a

// Very ugly, BYOND doesn't support unix time and rounding errors make it really hard to convert it to BYOND time.
// returns "YYYY-MM-DD" by default
/proc/unix2Date(timestamp, seperator = "-")

	if(timestamp < 0)
		return 0 //Do not accept negative values

	var/year = 1970 //Unix Epoc begins 1970-01-01
	var/day_in_seconds = 86400 //60secs*60mins*24hours
	var/days_in_year = 365 //Non Leap Year
	var/days_in_lyear = days_in_year + 1//Leap year
	var/days = round(timestamp / day_in_seconds) //Days passed since UNIX Epoc
	var/tmp_days = days + 1 //If passed (timestamp < dayInSeconds), it will return 0, so add 1
	var/list/months_in_days = list() //Months will be in here ***Taken from the PHP source code***
	var/month = 1 //This will be the returned MONTH NUMBER.
	var/day //This will be the returned day number.

	while(tmp_days > days_in_year) //Start adding years to 1970
		year++
		if(isLeap(year))
			tmp_days -= days_in_lyear
		else
			tmp_days -= days_in_year

	if(isLeap(year)) //The year is a leap year
		months_in_days = list(-1,30,59,90,120,151,181,212,243,273,304,334)
	else
		months_in_days = list(0,31,59,90,120,151,181,212,243,273,304,334)

	var/m_days = 0
	var/month_index = 0

	for(var/m in months_in_days)
		month_index++
		if(tmp_days > m)
			m_days = m
			month = month_index

	day = tmp_days - m_days //Setup the date

	return "[year][seperator][((month < 10) ? "0[month]" : month)][seperator][((day < 10) ? "0[day]" : day)]"

/*
var/list/test_times = list("December" = 1323522004, "August" = 1123522004, "January" = 1011522004,
						   "Jan Leap" = 946684800, "Jan Normal" = 978307200, "New Years Eve" = 1009670400,
						   "New Years" = 1009836000, "New Years 2" = 1041372000, "New Years 3" = 1104530400,
						   "July Month End" = 744161003, "July Month End 12" = 1343777003, "End July" = 1091311200)
for(var/t in test_times)
	world.log << "TEST: [t] is [unix2date(test_times[t])]"
*/

/proc/isLeap(y)
	return (y % 4 == 0 && (y % 100 != 0 || y % 400 == 0))


/proc/radian2Degree(radians)
				  // 180 / Pi
	return radians * 57.2957795

/proc/degree2Radian(degrees)
				  // Pi / 180
	return degrees * 0.0174532925

//Converts a bitfield to a list of numbers (or words if a wordlist is provided)
/proc/bitfield2List(bitfield = 0, list/wordlist)
	var/list/r = list()
	if(istype(wordlist,/list))
		var/max = min(wordlist.len,16)
		var/bit = 1
		for(var/i = 1, i <= max, i++)
			if(bitfield & bit)
				r += wordlist[i]
			bit = bit << 1
	else
		for(var/bit = 1, bit <= 65535, bit = bit << 1)
			if(bitfield & bit)
				r += bit

	return r

/proc/age2Description(age)
	switch(age)
		if(0 to 1)
			return "infant"
		if(1 to 3)
			return "toddler"
		if(3 to 13)
			return "child"
		if(13 to 19)
			return "teenager"
		if(19 to 30)
			return "young adult"
		if(30 to 45)
			return "adult"
		if(45 to 60)
			return "middle-aged"
		if(60 to 70)
			return "aging"
		if(70 to INFINITY)
			return "elderly"
		else
			return "unknown"

//E = MC^2
/proc/mass2energy(M)
	. = M * (SPEED_OF_LIGHT_SQ)

//M = E/C^2
/proc/energy2mass(E)
	. = E / (SPEED_OF_LIGHT_SQ)