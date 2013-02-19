##worktrack

worktrack is provides a small binary that tracks one of your directories for file changes. Assuming your directory has many directories being git repositories underneath.

Whenever a file is modified, removed or added worktrack will search for the git respository this file belongs to and make an entry into it's own database with a timestamp.

###Installation

Install the gemfile

	gem install worktrack

Start worktrack

	worktrack

worktrack will add a directory called ".worktrack" under your home directory with a config.yml file containing the configuration. By default it will start monitoring the directory ~/Documents for changes and store these changes to a SQLite database under ~/.worktrack/changes.db. 

###Show work done

Running the command 
	
	worktrack -show

will show a list of changes made on the month before and the current month like this:

	worktrack - another great nedeco idea
	5807 changes in 7 Repositories

	calculation timeframe from 2013-01-01 00:00:00 UTC until 2013-02-01 00:00:00 UTC
	Total minutes worked: 0
	calculation timeframe from 2013-02-01 00:00:00 UTC until 2013-02-19 22:28:15 +0100
	worktrack
		52 minutes 2013-02-16 22:09:07 +0100 - 2013-02-16 23:01:56 +0100
		37 minutes 2013-02-18 00:18:49 +0100 - 2013-02-18 00:56:06 +0100
	puppet
		15 minutes 2013-02-17 09:32:39 +0100 - 2013-02-17 09:47:44 +0100
		15 minutes 2013-02-18 12:12:45 +0100 - 2013-02-18 12:28:28 +0100
	rollout_admin
		15 minutes 2013-02-18 15:28:10 +0100 - 2013-02-18 15:43:11 +0100
		25 minutes 2013-02-19 07:07:39 +0100 - 2013-02-19 07:33:29 +0100
	admin-interface
		60 minutes 2013-02-19 07:50:06 +0100 - 2013-02-19 08:50:15 +0100
		52 minutes 2013-02-19 09:32:38 +0100 - 2013-02-19 10:24:46 +0100
		16 minutes 2013-02-19 10:41:08 +0100 - 2013-02-19 10:57:47 +0100
	syslog-analyzer
		95 minutes 2013-02-19 13:44:37 +0100 - 2013-02-19 15:20:01 +0100
	Total minutes worked: 382


###Credits 

Thanks to the team around guard to provide the listen gem. Thanks to Jan for treating me to track the time spent on work for customers better ;)

###Todo

Fork, branch, change, commit merge requests. 

This is a starting point that shows an idea. It needs much more work to become a usefull tool.