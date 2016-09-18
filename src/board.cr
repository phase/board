require "mysql"
require "./style"
require "./config"
require "./templates"

class Forum
  getter id : Int32
  getter name : String
  getter title : String
  getter thread_count : Int32
  getter post_count : Int32

  def initialize(@id : Int32, @name : String, @title : String,
                 @thread_count : Int32, @post_count : Int32)
  end
end

class ForumThread
  getter id : Int32
  getter name : String
  getter title : String
  getter forum_id : Int32
  getter user_id : Int32
  getter replies : Int32
  getter views : Int32

  def initialize(@id : Int32, @name : String, @title : String,
                 @forum_id : Int32, @user_id : Int32, @replies : Int32,
                 @views : Int32)
  end
end

class ForumPost
  getter id : Int32
  getter text : String
  getter time : Int32
  getter thread_id : Int32
  getter poster_id : Int32

  def initialize(@id : Int32, @text : String, @time : Int32,
                 @thread_id : Int32, @poster_id : Int32)
  end
end

class User
  getter id : Int32
  getter name : String
  getter password : String # hash of password

  def initialize(@id : Int32, @name : String, @password : String)
  end
end

class Board
  @@config = Config.from_json(%({"name":"default_name", "mysql_url": "default_url"}))

  def self.config
    @@config
  end

  def self.config=(c : Config)
    @@config = c
  end


  def self.get_forums()
    forums = [] of Forum
    DB.open @@config.mysql_url do |db|
      db.query "select id, name, title, threads, posts from forums" do |rs|
        # puts "#{rs.column_name(0)} #{rs.column_name(1)} #{rs.column_name(2)}"
        rs.each do
          id = rs.read(Int32)
          name = rs.read(String)
          title = rs.read(String)
          thread_count = rs.read(Int32)
          post_count = rs.read(Int32)
          forums << Forum.new(id, name, title, thread_count, post_count)
          # puts "#{id} | #{name} | #{title}"
        end
      end
    end
    forums
  end

  def self.get_threads(forum_id : Int32)
    threads = [] of ForumThread
    DB.open @@config.mysql_url do |db|
      db.query "select id, name, title, user, replies, views from threads where forum = #{forum_id}" do |rs|
        rs.each do
          thread_id = rs.read(Int32)
          name = rs.read(String)
          title = rs.read(String)
          user_id = rs.read(Int32)
          replies = rs.read(Int32)
          views = rs.read(Int32)
          threads << ForumThread.new(thread_id, name, title, forum_id, user_id, replies, views)
        end
      end
    end
    threads
  end

  def self.get_thread(thread_id : Int32)
    thread = ForumThread.new(-1, "Invalid Thread Name", "Invalid Thread Title", -1, -1, -1, -1)
    DB.open @@config.mysql_url do |db|
      db.query "select name, title, user, replies, views, forum from threads where id = #{thread_id}" do |rs|
        rs.each do
          name = rs.read(String)
          title = rs.read(String)
          user_id = rs.read(Int32)
          replies = rs.read(Int32)
          views = rs.read(Int32)
          forum_id = rs.read(Int32)
          thread = ForumThread.new(thread_id, name, title, forum_id, user_id, replies, views)
        end
      end
    end
    thread
  end

  def self.get_posts(thread_id : Int32)
    posts = [] of ForumPost
    DB.open @@config.mysql_url do |db|
      db.query "select id, text, time, user from posts where thread = #{thread_id}" do |rs|
        rs.each do
          post_id = rs.read(Int32)
          text = String.new(rs.read(Slice(UInt8)))
          time = rs.read(Int32)
          poster_id = rs.read(Int32)
          posts << ForumPost.new(post_id, text, time, thread_id, poster_id)
        end
      end
    end
    posts
  end

  def self.get_user(user_id : Int32)
    user = User.new(-1, "Invalid User", "Invalid Hash")
    DB.open @@config.mysql_url do |db|
      db.query "select name, password from users where id = #{user_id}" do |rs|
        rs.each do
          name = rs.read(String)
          password = rs.read(String)
          user = User.new(user_id, name, password)
        end
      end
    end
    user
  end

end
