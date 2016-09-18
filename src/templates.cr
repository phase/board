require "ecr"
require "./board"

class BoardTemplate
  def initialize(@style : String, @content : String)
  end

  ECR.def_to_s "templates/board.ecr"
end

class IndexTemplate
  def initialize(@forums : Array(Forum))
  end

  ECR.def_to_s "templates/index.ecr"
end

class ForumTemplate
  def initialize(@forum_id : Int32, @threads : Array(ForumThread))
  end

  ECR.def_to_s "templates/forum.ecr"
end
