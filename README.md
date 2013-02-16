==worktrack

worktrack is provides a small binary that tracks one of your directories for file changes. Assuming your directory has many directories being git repositories underneath.

Whenever a file is modified, removed or added worktrack will search for the git respository this file belongs to and make an entry into it's own database with a timestamp.

=== Installation

Install the gemfile

	gem install worktrack

Start worktrack

	worktrack

worktrack will add a directory called ".worktrack" under your home directory with a config.yml file containing the configuration. By default it will start monitoring the directory ~/Documents for changes and store these changes to a SQLite database under ~/.worktrack/changes.db. 

=== Show work done

Running the command 
	
	worktrack -show

will show a list of changes made like this:

	worktrack - another great nedeco idea

	18 changes in 1 Repositories
	worktrack:
		 test added on 2013-02-16 22:09:07 +0100
		 test removed on 2013-02-16 22:09:08 +0100
		 worktrack.rb modified on 2013-02-16 22:15:16 +0100
		 worktrack.rb modified on 2013-02-16 22:15:36 +0100
		 worktrack.rb modified on 2013-02-16 22:16:29 +0100
		 worktrack.rb modified on 2013-02-16 22:16:31 +0100
		 worktrack.rb modified on 2013-02-16 22:16:40 +0100
		 worktrack.rb modified on 2013-02-16 22:16:55 +0100
		 index modified on 2013-02-16 22:19:26 +0100
		 d177bb10f5dbc889c1c4a273ff36b1e8a7e77b added on 2013-02-16 22:19:26 +0100
		 COMMIT_EDITMSG modified on 2013-02-16 22:19:33 +0100
		 index modified on 2013-02-16 22:19:33 +0100
		 b894001457bf96372e39512655f1303332d9c2 added on 2013-02-16 22:19:33 +0100
		 2c9d823c762424fa79ad53b693e1c9edcc5b1b added on 2013-02-16 22:19:33 +0100
		 master modified on 2013-02-16 22:19:33 +0100
		 master modified on 2013-02-16 22:19:33 +0100
		 HEAD modified on 2013-02-16 22:19:33 +0100
		 5faa2138e310a1b86f129e00b9fa03f3bf94fe added on 2013-02-16 22:19:33 +0100

=== Credits 

Thanks to the team around guard to provide the listen gem. Thanks to Jan for treating me to track the time spent on work for customers better ;)

=== Todo

Fork, branch, change, commit merge requests. 

This is a starting point that shows an idea. It needs much more work to become a usefull tool.