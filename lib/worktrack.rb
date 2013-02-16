# really lazy checking of your daily work
#
require 'rubygems'
require 'listen'
require 'time'
require 'yaml'
require 'sequel'
require 'etc'

class WorkTrack
	def check_config(dir)
		if !File.exist?("#{dir}/.worktrack/config.yml")
			open("#{dir}/.worktrack/config.yml", 'a') { |conf|
				conf << "db_file: #{dir}/.worktrack/changes.db\n"
				conf << "watch_dir: #{dir}/Documents/\n"
			}
		end
	end

	def initialize()
		@user_dir=Etc.getpwuid.dir
		@gem_dir=File.dirname(File.expand_path(__FILE__))

		if !File.directory? "#{@user_dir}/.worktrack"
			Dir::mkdir("#{@user_dir}/.worktrack")
		end
		check_config("#{@user_dir}")

		@cnf = YAML::load(File.open("#{@user_dir}/.worktrack/config.yml"))
		@DB = Sequel.sqlite(@cnf['db_file'])

		# quick fix to make sure directory ends with /
		if @cnf['watch_dir'].split(//).last(1).join.to_s != "/"
			@cnf['watch_dir'] = "#{@cnf['watch_dir']}/"
		end

		# bind models to database. has to be done after db connection is created
		require 'worktrack/models'

		# create an Change table if not exists
		@DB.create_table? :changes do
		  primary_key :id
		  foreign_key :repo_id
		  String :action
		  String :filename
		  Time :timestamp
		end

		@DB.create_table? :repos do
		  primary_key :id
		  String :name
		  String :path
		end
	end

	def find_repo(name,path)
		#puts "try to find repo with #{name} under #{path}"
		repo = Repo.where(:name => name).first
		if repo.nil?
			Repo.insert(:name => name, :path => path)
			repo = Repo.where(:name => name).first
		end
		puts "Repository is #{repo.name}"
		return repo
	end

	def analyse(info,action)
		info.each { |f|
			f.slice! @cnf['watch_dir']
			@mylist=f.split("/")
			for i in 0..(@mylist.length - 1)
				@dir=""
				for j in 0..(i-1)
					if @mylist[j] != ""
						@dir = @dir + @mylist[j]+ "/" 
					end
				end
				@dir=@cnf['watch_dir'] + @dir
				if File.directory? "#{@dir}.git"
					@repo = find_repo(@mylist[j],@dir)
					@repo.add_change(:action => action, :filename => @mylist[@mylist.length - 1], :timestamp => Time.now)
					puts "\t#{Time.now} tracked #{@mylist[@mylist.length - 1]} in #{@dir}"
				end
			end
		}		
	end

	def dump_changes()
		puts "worktrack - another great nedeco idea\n\n"
		puts "#{Change.all.count} changes in #{Repo.all.count} Repositories"

		if Repo.all.count == 0 
			puts "go and do some work before you want to earn respect"
		else
			Repo.all.each {|rep|
				puts "#{rep.name}:"
				rep.changes.each {|change|
					puts "\t #{change.filename} #{change.action} on #{change.timestamp}"
				}
			}
		end
	end

	def run
		puts "going to monitor files in #{@cnf['watch_dir']}"
		Listen.to(@cnf['watch_dir'], :ignore => /history|changes.db/) do |modified, added, removed|
#			puts "modified: #{modified.inspect}" unless modified.length == 0 
#			puts "added: #{added.inspect}" unless added.length == 0 
#			puts "removed: #{removed.inspect}" unless removed.length == 0

			analyse(modified,"modified") unless modified.length == 0
			analyse(added,"added") unless added.length == 0
			analyse(removed,"removed") unless removed.length == 0
		end
	end
end