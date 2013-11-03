/*
 * Holds procs to help with list operations
 * Contains groups:
 *			Misc
 *			Sorting
 */

/*
 * Misc
 */

//Returns a list in plain english as a string
//Get rid of this at some point or at least make it use dd_Text2List() or tg_Text2List()
/proc/englishList(list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = input.len
	if (!total)
		return "[nothing_text]"
	else if (total == 1)
		return "[input[1]]"
	else if (total == 2)
		return "[input[1]][and_text][input[2]]"
	else
		var/output = ""
		var/index = 1
		while (index < total)
			if (index == total - 1)
				comma_text = final_comma_text

			output += "[input[index]][comma_text]"
			index++

		return "[output][and_text][input[index]]"

//Returns list element or null. Should prevent "index out of bounds" error.
/proc/listGetIndex(list/L, index)
	if(istype(L))
		if(isnum(index))
			if(isInRange(index,1,L.len))
				return L[index]
		else if(index in L)
			return L[index]

/proc/isList(list/L)
	if(istype(L))
		return 1

//Return either pick(list) or null if list is not of type /list or is empty
/proc/safePick(list/L)
	if(istype(L) && L.len)
		return pick(L)

//Checks if the list is empty
/proc/isEmptyList(list/L)
	if(!L.len)
		return 1

//Checks for specific types in a list
/proc/isTypeInList(atom/A, list/L)
	for(var/type in L)
		if(istype(A, type))
			return 1

//Empties the list by setting the length to 0. Hopefully the elements get garbage collected
/proc/clearList(list/list)
	if(istype(list))
		list.len = 0

//Removes any null entries from the list
/proc/listClearNulls(list/L)
	if(istype(L))
		while(null in L)
			L -= null

/*
 * Returns list containing all the entries from first list that are not present in second.
 * If skip_rep = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/diffList(list/first, list/second, skip_rep=0)
	if(!isList(first) || !isList(second))
		return
	var/list/result = list()
	if(skip_rep)
		for(var/e in first)
			if(!(e in result) && !(e in second))
				result += e
	else
		result = first - second
	return result

/*
 * Returns list containing entries that are in either list but not both.
 * If skip_ref = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/uniqueMergeList(list/first, list/second, var/skip_rep=0)
	if(!isList(first) || !isList(second))
		return
	var/list/result = list()
	if(skip_rep)
		result = diffList(first, second, skip_rep) + diffList(second, first, skip_rep)
	else
		result = first ^ second
	return result

//Pretends to pick an element based on its weight but really just seems to pick a random element.
/proc/pickWeight(list/L)
	var/total = 0
	for(var/item in L)
		if(!L[item])
			L[item] = 1
		total += L[item]

	total = rand(1, total)
	for(var/item in L)
		total -= L [item]
		if(total <= 0)
			return item

//Pick a random element from the list and remove it from the list.
/proc/pickAndTake(list/L)
	if(L.len)
		var/picked = rand(1, L.len)
		. = L[picked]
		L.Cut(picked, picked + 1)			//Cut is far more efficient that Remove()

//Returns the top(last) element from the list and removes it from the list (typical stack function)
/proc/pop(list/L)
	if(L.len)
		. = L[L.len]
		L.len--

/*
 * Sorting
 */

//Reverses the order of items in the list
/proc/reverseList(list/input)
	var/list/output = list()
	for(var/i = input.len; i >= 1; i--)
		output += input[i]
	return output

//Randomize: Return the list in a random order
/proc/shuffle(list/shufflelist)
	if(!shufflelist)
		return
	var/list/new_list = list()
	var/list/old_list = shufflelist.Copy()
	while(old_list.len)
		var/item = pick(old_list)
		new_list += item
		old_list -= item
	return new_list

//Return a list with no duplicate entries
/proc/uniqueList(list/L)
	var/list/K = list()
	for(var/item in L)
		if(!(item in K))
			K += item
	return K


//Divides up the list into halves to begin the sort
/proc/sortList(list/M, keep_associations = 0)
	if(M.len < 2)
		return M
	var/middle = M.len / 2 + 1 // Copy is first,second-1
	var/list/L = sortList(M.Copy(0, middle), keep_associations)
	var/list/R = sortList(M.Copy(middle), keep_associations)
	if(keep_associations)
		return mergeSortAssociations(L, R)
	return mergeSort(L, R)

//Does the actual sorting and returns the results back to sortList
/proc/mergeSort(list/L, list/R, order = 1)
	var/Li=1
	var/Ri=1
	var/list/result = list()
	while(Li <= L.len && Ri <= R.len)
		var/rL = L[Li]
		var/rR = R[Ri]
		if(sorttext(rL, rR) == order)
			result += L[Li++]
		else
			result += R[Ri++]

	if(Li <= L.len)
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

//Like above but preserves key=value structure
/proc/mergeSortAssociations(list/L, list/R)
	var/Li=1
	var/Ri=1
	var/list/result = list()
	while(Li <= L.len && Ri <= R.len)
		if(sorttext(L[Li], R[Ri]) < 1)
			result += R & R[Ri++]
		else
			result += L & L[Li++]

	if(Li <= L.len)
		return (result + L.Copy(Li, 0))
	return(result + R.Copy(Ri, 0))

// Returns the key based on the index
/proc/getKeyByIndex(list/L, index)
	var/i = 1
	for(var/key in L)
		if(index == i)
			return key
		i++

/proc/countByType(list/L, type)
	var/i = 0
	for(var/T in L)
		if(istype(T, type))
			i++
	return i