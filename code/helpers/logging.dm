//print an error message to world.log
/proc/error(msg)
	world.log << "## ERROR: [msg]"

//print a warning message to world.log
/proc/warning(msg)
	world.log << "## WARNING: [msg]"

//print a testing-mode debug message to world.log
/proc/testing(msg)
#ifdef TESTING
	world.log << "## TESTING: [msg]"
#endif