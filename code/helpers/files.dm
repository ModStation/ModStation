/**
 * Returns the contents of a file as a string.
 * Errors if the file doesn't exist or is empty.
 * @param filename	File path to read from.
 * @returns			Contents of the file, as a string.
 */
/proc/returnFileText(filename)
	if(!fexists(filename))
		error("File not found ([filename])")
		return

	var/text = file2text(filename)
	if(!text)
		error("File empty ([filename])")
		return

	return text

/**
 * Caches files in the client's cache.
 * @param ... Files to cache.
 */
/client/proc/cacheFiles()
	for(var/file in args)
		src << browse_rsc(file)

/**
 * Allows the user to browse through a tree of directories and select a file.
 * @param root				File path to treat as the root of what the user is allowed to browse.
 * @param valid_extensions	A list of extensions that the user is allowed to select.
 * @param max_iterations	Maximum number of directory changes that the user is allowed to do.
 * @returns 				The path that the user selected.
 */
/client/proc/browseFiles(root, list/valid_extensions, max_iterations = 10)
	if(!root || !valid_extensions || !valid_extensions.len)
		src << "<font color='red'>Error: browseFiles(): Invalid proc arguments. Reports this to a coder.</font>"
		return

	var/path = root

	for(var/i = 0, i < max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1,"/")

		var/choice = input(src,"Choose a file to access:","Download",null) as null|anything in choices
		switch(choice)
			if(null)
				return
			if("/")
				path = root
				continue
		path += choice

		if(copytext(path, -1, 0) != "/")		//didn't choose a directory, no need to iterate again
			break

	var/extension = copytext(path, -4, 0)
	if(!fexists(path) || !(extension in valid_extensions) )
		src << "<font color='red'>Error: browseFiles(): File not found/Invalid file([path]).</font>"
		return

	return path
