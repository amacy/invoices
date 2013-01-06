class CommitsController
  def initialize(git_root)
    @git_root = git_root
  end
  def index 
    @git_root.map do |line|
      Commit.new(line)
    end
  end
end
