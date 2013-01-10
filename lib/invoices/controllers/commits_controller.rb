class CommitsController
  def initialize(raw_commits)
    @raw_commits = raw_commits
  end
  def index 
    @raw_commits.map do |line|
      Commit.new(line)
    end
  end
end
