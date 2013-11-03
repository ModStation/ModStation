//checks if a file exists and contains text
//returns text as a string if these conditions are met
/proc/returnFileText(filename)
	if(!fexists(filename))
		error("File not found ([filename])")
		return

	var/text = file2text(filename)
	if(!text)
		error("File empty ([filename])")
		return

	return text

//Sends resource files to client cache
/client/proc/getFiles()
	for(var/file in args)
		src << browse_rsc(file)

/client/proc/browseFiles(root="data/logs/", max_iterations = 10, list/valid_extensions = list(".txt",".log",".htm"))
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