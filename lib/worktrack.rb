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

	def prettyprint(work_frames)
		# make some nice output
		if !work_frames.nil?
			@totalmin=0
			work_frames.each {|rep|
				if !rep.nil? && !rep.empty?
					puts "#{rep.first[:repository]}"
					rep.each {|work|
						puts "\t#{work[:amount]} minutes #{work[:from]} - #{work[:to]}"
						@totalmin = @totalmin + work[:amount]
					}
				end
			}
			puts "Total minutes worked: #{@totalmin}"
		end
	end


	def calctimeframe(from, to)
		puts "calculation timeframe from #{from} until #{to}\n"
		@work_frames=[]			
		Repo.all.each {|rep|
			@work_frames[rep.id] = []
		}
		@last_repo=0
		@starttime=0
		@endtime=0

		# 15 minutes by 60 seconds
		@corridor=15*60

		@DB.fetch("select * from changes where timestamp > '#{from}' and timestamp < '#{to}' order by repo_id") do |c|
			if (c[:repo_id] != @last_repo)
				if @starttime > 0
					@endtime = @starttime + @corridor unless @endtime > 0
					@rep=Repo.where(:id => @last_repo).first
					@work_frames[@last_repo] << {:repository => @rep.name, :from => Time.at(@starttime), :to => Time.at(@endtime), :amount => (@endtime - @starttime)/60 }
				end
				@endtime=0
				@starttime=0
				@last_repo=c[:repo_id]
			end
			unless @starttime > 0
				@starttime=c[:timestamp].to_i 
				@endtime=@starttime+@corridor
			end

			if c[:timestamp].to_i < (@endtime + @corridor)
				@endtime=c[:timestamp].to_i + @corridor
			else
				@rep=Repo.where(:id => c[:repo_id]).first
				@work_frames[c[:repo_id]] << {:repository => @rep.name, :from => Time.at(@starttime), :to => Time.at(@endtime), :amount => (@endtime - @starttime)/60 }
				@starttime=c[:timestamp].to_i
				@endtime=@starttime + @corridor
			end
		end
		if @starttime > 0
			@rep=Repo.where(:id => @last_repo).first
			@work_frames[@last_repo] << {:repository => @rep.name, :from => Time.at(@starttime), :to => Time.at(@endtime), :amount => (@endtime - @starttime)/60 }
		end

		prettyprint(@work_frames)

	end

	def dump_changes()
		puts "worktrack - another great nedeco idea\n"
		puts "#{Change.all.count} changes in #{Repo.all.count} Repositories\n\n"

		calctimeframe(Time.utc(Time.new.year, Time.new.month-1),Time.utc(Time.new.year, Time.new.month))
		calctimeframe(Time.utc(Time.new.year, Time.new.month),Time.now)

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