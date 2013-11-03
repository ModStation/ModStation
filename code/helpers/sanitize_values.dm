//general stuff
/proc/sanitizeInteger(number, min = 0, max = 1, default = 0)
	if(isnum(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitizeText(text, default = "")
	if(istext(text))
		return text
	return default

/proc/sanitizeList(value, list/L, default) //was called sanitize_inlist()
	if(value in L)
		return value
	if(default)
		return default
	return safePick(L)



//more specialised stuff
/proc/sanitizeGender(gender, neuter=0, plural=0, default="male")
	switch(gender)
		if(MALE, FEMALE)
			return gender
		if(NEUTER)
			if(neuter)
				return gender
			else
				return default
		if(PLURAL)
			if(plural)
				return gender
			else
				return default
	return default


/proc/sanitizeHex(color, desired_format=3, include_crunch=0, default) //was called sanitize_hexcolor
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

	var/start = 1 + (text2ascii(color, 1) == 35)
	var/color_len = length(color)
	var/iteration_size = 1 + ((color_len + 1) - start != desired_format)

	. = ""
	for(var/i = start, i <= color_len, i += iteration_size)
		var/ascii = text2ascii(color, i)
		switch(ascii)
			if(48 to 57)
				. += ascii2text(ascii)		//numbers 0 to 9
			if(97 to 102)
				. += ascii2text(ascii)		//letters a to f
			if(65 to 70)
				. += ascii2text(ascii + 32)	//letters A to F - translates to lowercase
			else
				break

	if(length(.) != desired_format)
		if(default)
			return default
		return crunch + repeatString(desired_format, "0")

	return crunch + .

/proc/sanitizeOOCColor(color)
	var/list/HSL = rgb2hsl(hex2Num(copytext(color, 2, 4)), hex2Num(copytext(color, 4, 6)),hex2Num(copytext(color, 6, 8)))
	HSL[3] = min(HSL[3],0.4)
	var/list/RGB = hsl2rgb(arglist(HSL))
	return "#[num2Hex(RGB[1],2)][num2Hex(RGB[2],2)][num2Hex(RGB[3],2)]"

// Run all strings to be used in an SQL query through this proc first to properly escape out injection attempts.
/proc/sanitizeSQL(t as text)
	var/sanitized_text = replaceText(t, "'", "\\'")
	sanitized_text = replaceText(sanitized_text, "\"", "\\\"")
	return sanitized_text

//	TEXT SANITIZATION
//Removes a few problematic characters
/proc/sanitizeSimple(t, list/repl_chars = list("\n"="#","\t"="#","�"="�"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char)
	return t

//Runs byond's sanitization proc along-side sanitize_simple
/proc/sanitize(t, list/repl_chars = null)
	return html_encode(sanitizeSimple(t, repl_chars))


//Returns null if there is any bad text in the string
/proc/rejectBadText(text, max_length = 512)
	if(length(text) > max_length)
		return
	var/non_whitespace = 0
	for(var/i = 1, i <= length(text), i++)
		switch(text2ascii(text, i))
			if(62,60,92,47)		//rejects the text if it contains these bad characters: <, >, \ or /
				return
			if(127 to 255)		//rejects weird letters like �
				return
			if(0 to 31)			//more weird stuff
				return
			if(32)				//whitespace
				continue
			else			non_whitespace = 1
	if(non_whitespace)//only accepts the text if it has some non-spaces
		return text

//Ensure the frequency is within bounds of what it should be sending/recieving at
/proc/sanitizeFrequency(f)
	f = round(f)
	f = max(1441, f) // 144.1
	f = min(1489, f) // 148.9
	if ((f % 2) == 0) //Ensure the last digit is an odd number
		f += 1
	return f