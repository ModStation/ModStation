/*
 * Contains groups:
 *			Text searches
 *			Text modification
 *			Misc
 */

/*
 * Text searches
 */

//Checks the beginning of a string for a specified sub-string
//Returns the position of the substring or 0 if it was not found
/proc/ddHasPrefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)

//Checks the beginning of a string for a specified sub-string. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/ddHasPrefixEx(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtextEx(text, prefix, start, end)

//Checks the end of a string for a specified substring.
//Returns the position of the substring or 0 if it was not found
/proc/ddHasSuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext(text, suffix, start, null)

//Checks the end of a string for a specified substring. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/ddHasSuffixEx(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtextEx(text, suffix, start, null)

/*
 * Text modification
 */
/proc/replaceText(text, find, replacement)
	var/find_len = length(find)
	if(find_len < 1)	return text
	. = ""
	var/last_found = 1
	while(1)
		var/found = findtext(text, find, last_found, 0)
		. += copytext(text, last_found, found)
		if(found)
			. += replacement
			last_found = found + find_len
			continue
		return .

/proc/replaceTextEx(text, find, replacement)
	var/find_len = length(find)
	if(find_len < 1)	return text
	. = ""
	var/last_found = 1
	while(1)
		var/found = findtextEx(text, find, last_found, 0)
		. += copytext(text, last_found, found)
		if(found)
			. += replacement
			last_found = found + find_len
			continue
		return .

//Adds 'u' number of zeros ahead of the text 't'
/proc/addLZero(t, u)
	while (length(t) < u)
		t = "0[t]"
	return t

//Adds 'u' numbers of zeros behind the text 't'
/proc/addTZero(t, u)
	while(length(t) < u)
		t = "0[t]"
	return t

//Adds 'u' number of spaces ahead of the text 't'
/proc/addLSpace(t, u)
	while(length(t) < u)
		t = " [t]"
	return t

//Adds 'u' number of spaces behind the text 't'
/proc/addTSpace(t, u)
	while(length(t) < u)
		t = "[t] "
	return t

//Returns a string with reserved characters and spaces before the first letter removed
/proc/trimLeft(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

//Returns a string with reserved characters and spaces after the last letter removed
/proc/trimRight(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text)
	return trimLeft(trimRight(text))

//Returns a string with the first element of the string capitalized.
/proc/capitalize(var/t as text)
	return uppertext(copytext(t, 1, 2)) + copytext(t, 2)

//Centers text by adding spaces to either side of the string.
/proc/ddCenterText(message, length)
	var/new_message = message
	var/size = length(message)
	var/delta = length - size
	if(size == length)
		return new_message
	if(size > length)
		return copytext(new_message, 1, length + 1)
	if(delta == 1)
		return new_message + " "
	if(delta % 2)
		new_message = " " + new_message
		delta--
	var/spaces = addLSpace("",delta/2-1)
	return spaces + new_message + spaces

//Limits the length of the text. Note: MAX_MESSAGE_LEN and MAX_NAME_LEN are widely used for this purpose
/proc/ddLimitText(message, length)
	var/size = length(message)
	if(size <= length)
		return message
	return copytext(message, 1, length + 1)

/*
 * Misc
 */

/proc/stringSplit(txt, character)
	var/cur_text = txt
	var/last_found = 1
	var/found_char = findtext(cur_text, character)
	var/list/list = list()
	if(found_char)
		var/fs = copytext(cur_text, last_found, found_char)
		list += fs
		last_found = found_char + length(character)
		found_char = findtext(cur_text, character, last_found)
	while(found_char)
		var/found_string = copytext(cur_text, last_found, found_char)
		last_found = found_char+length(character)
		list += found_string
		found_char = findtext(cur_text, character, last_found)
	list += copytext(cur_text, last_found, length(cur_text) + 1)
	return list

/proc/stringMerge(text, compare, replace = "*")
//This proc fills in all spaces with the "replace" var (* by default) with whatever
//is in the other string at the same spot (assuming it is not a replace char).
//This is used for fingerprints
	var/newtext = text
	if(lentext(text) != lentext(compare))
		return 0
	for(var/i = 1, i < lentext(text), i++)
		var/a = copytext(text, i, i + 1)
		var/b = copytext(compare, i, i + 1)
//if it isn't both the same letter, or if they are both the replacement character
//(no way to know what it was supposed to be)
		if(a != b)
			if(a == replace) //if A is the replacement char
				newtext = copytext(newtext, 1, i) + b + copytext(newtext, i + 1)
			else if(b == replace) //if B is the replacement char
				newtext = copytext(newtext, 1, i) + a + copytext(newtext, i + 1)
			else //The lists disagree, Uh-oh!
				return 0
	return newtext

/proc/stringPercent(text, character = "*")
//This proc returns the number of chars of the string that is the character
//This is used for detective work to determine fingerprint completion.
	if(!text || !character)
		return 0
	var/count = 0
	for(var/i = 1, i <= lentext(text), i++)
		var/a = copytext(text, i, i + 1)
		if(a == character)
			count++
	return count

/proc/reverseText(text = "")
	var/new_text = ""
	for(var/i = length(text); i > 0; i--)
		new_text += copytext(text, i, i+1)
	return new_text

var/list/zero_character_only = list("0")
var/list/hex_characters = list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
var/list/alphabet = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
var/list/binary = list("0","1")

/proc/randomString(length, list/characters)
	. = ""
	for(var/i = 1, i <= length, i++)
		. += pick(characters)

/proc/repeatString(times, string = "")
	. = ""
	for(var/i = 1, i <= times, i++)
		. += string

/proc/randomShortColor()
	return randomString(3, hex_characters)

//merges non-null characters (3rd argument) from "from" into "into". Returns result
//e.g. into = "Hello World"
//     from = "Seeya______"
//     returns"Seeya World"
//The returned text is always the same length as into
//This was coded to handle DNA gene-splicing.
/proc/merge_text(into, from, null_char="_")
	. = ""
	if(!istext(into))
		into = ""
	if(!istext(from))
		from = ""
	var/null_ascii = istext(null_char) ? text2ascii(null_char,1) : null_char

	var/previous = 0
	var/start = 1
	var/end = length(into) + 1

	for(var/i = 1, i < end, i++)
		var/ascii = text2ascii(from, i)
		if(ascii == null_ascii)
			if(previous != 1)
				. += copytext(from, start, i)
				start = i
				previous = 1
		else
			if(previous != 0)
				. += copytext(into, start, i)
				start = i
				previous = 0

	if(previous == 0)
		. += copytext(from, start, end)
	else
		. += copytext(into, start, end)

//finds the first occurrence of one of the characters from needles argument inside haystack
//it may appear this can be optimised, but it really can't. findtext() is so much faster than anything you can do in byondcode.
//stupid byond :(
/proc/findChar(haystack, needles, start = 1, end = 0)
	var/temp
	var/len = length(needles)
	for(var/i = 1, i <= len, i++)
		temp = findtextEx(haystack, ascii2text(text2ascii(needles, i)), start, end)	//Note: ascii2text(text2ascii) is faster than copytext()
		if(temp)
			end = temp
	return end