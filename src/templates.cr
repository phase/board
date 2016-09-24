require "ecr"
require "./board"

class BoardTemplate
  def initialize(@style : String, @content : String, @user : User)
  end

  ECR.def_to_s "templates/board.ecr"
end

class IndexTemplate
  def initialize(@user : User, @forums : Array(Forum))
  end

  ECR.def_to_s "templates/index.ecr"
end

class ForumTemplate
  def initialize(@user : User, @forum_id : Int32, @threads : Array(ForumThread))
  end

  ECR.def_to_s "templates/forum.ecr"
end

class ThreadTemplate
  def initialize(@user : User, @thread_id : Int32, @posts : Array(ForumPost))
  end

  ECR.def_to_s "templates/thread.ecr"
end

class NewThreadTemplate
  def initialize(@user : User, @forum : Forum)
  end

  ECR.def_to_s "templates/new_thread.ecr"
end

class LoginTemplate
  ECR.def_to_s "templates/login.ecr"
end

class RegisterTemplate
  ECR.def_to_s "templates/register.ecr"
end
