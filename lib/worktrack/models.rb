class WorkTrack::Repo < Sequel::Model(:repos)
  one_to_many :changes
end

class WorkTrack::Change < Sequel::Model(:changes)
  many_to_one :repo
end
