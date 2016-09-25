require "mysql"
require "crypto/bcrypt"
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
  getter post_count : Int32
  getter title : String

  def initialize(@id : Int32, @name : String, @password : String)
    @post_count = 0
    @title = ""
  end

  def initialize(@id : Int32, @name : String, @password : String,
                 @post_count : Int32, @title : String)
  end

  def logged_in?()
    id != -1
  end
end

class Board
  @@config = Config.from_json(%({"name":"default_name", "mysql_url": "default_url"}))
  @@sessions = {} of String => Int32 # Session keys to User IDs

  def self.config
    @@config
  end

  def self.config=(c : Config)
    @@config = c
  end

  def self.sessions
    @@sessions
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

  def self.get_forum(forum_id : Int32)
    forum = Forum.new(-1, "Invalid Forum", "Invalid Forum Title", -1, -1)
    DB.open @@config.mysql_url do |db|
      db.query "select name, title, threads, posts from forums where id = #{forum_id}" do |rs|
        rs.each do
          name = rs.read(String)
          title = rs.read(String)
          thread_count = rs.read(Int32)
          post_count = rs.read(Int32)
          forum = Forum.new(forum_id, name, title, thread_count, post_count)
        end
      end
    end
    forum
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
      db.query "select name, password, posts, title from users where id = #{user_id}" do |rs|
        rs.each do
          name = rs.read(String)
          password = rs.read(String)
          posts = rs.read(Int32)
          title = rs.read(String)
          user = User.new(user_id, name, password, posts, title)
        end
      end
    end
    user
  end

  def self.update_user(user_id : Int32, title : String)
    DB.open @@config.mysql_url do |db|
      db.exec "update users set title = ? where id = #{user_id}", title
    end
  end

  def self.create_forum(name : String, title : String)
    forum = Forum.new(-1, "Invalid Forum", "Invalid Forum Title", -1, -1)
    DB.open @@config.mysql_url do |db|
      db.exec "insert into forums (name, title) values (?, ?)", name, title
      # SELECT * FROM Table ORDER BY ID DESC LIMIT 1
      db.query "select id from forums order by id desc limit 1" do |rs|
        rs.each do
          id = rs.read(Int32)
          forum = Forum.new(id, name, title, 0, 0)
        end
      end
    end
    forum
  end

  def self.increment_view(thread_id : Int32)
    DB.open @@config.mysql_url do |db|
      views = 0
      db.query "select views from threads where id = #{thread_id}" do |rs|
        rs.each do
          views = rs.read(Int32)
        end
      end
      db.exec "update threads set views = #{views + 1} where id = #{thread_id}"
    end
  end

  def self.create_thread(name : String, title : String, forum_id : Int32, user_id : Int32)
    thread = ForumThread.new(-1, "Invalid Thread Name", "Invalid Thread Title", -1, -1, -1, -1)
    if user_id == -1
      return thread
    end

    DB.open @@config.mysql_url do |db|
      # Add thread to table
      db.exec "insert into threads (name, title, time, forum, user) values (?, ?, ?, ?, ?)",
        name, title, Time.now.epoch.to_i32, forum_id, user_id
      db.query "select id from threads order by id desc limit 1" do |rs|
        rs.each do
          id = rs.read(Int32)
          thread = ForumThread.new(id, name, title, forum_id, user_id, 0, 0)
        end
      end

      # Update thread count in forum
      thread_count = 0
      db.query "select threads from forums where id = #{forum_id}" do |rs|
        rs.each do
          thread_count = rs.read(Int32)
        end
      end
      db.exec "update forums set threads = #{thread_count + 1} where id = #{forum_id}"
    end
    thread
  end

  def self.create_post(text : String, thread_id : Int32, user_id : Int32)
    post = ForumPost.new(-1, "Invalid Post", -1, -1, -1)
    if user_id == -1
      return post
    end

    DB.open @@config.mysql_url do |db|
      # Add post to table
      time = Time.now.epoch.to_i32
      db.exec "insert into posts (text, time, thread, user, rev) values (?, ?, ?, ?, ?)",
        text, time, thread_id, user_id, 0
      db.query "select id from posts order by id desc limit 1" do |rs|
        rs.each do
          id = rs.read(Int32)
          post = ForumPost.new(id, text, time, thread_id, user_id)
        end
      end

      # Update reply count in thread
      replies = 0
      forum_id = -1
      db.query "select replies, forum from threads where id = #{thread_id}" do |rs|
        rs.each do
          replies = rs.read(Int32)
          forum_id = rs.read(Int32)
        end
      end
      db.exec "update threads set replies = #{replies + 1} where id = #{thread_id}"

      # Update post count in forum
      forum_posts = 0
      db.query "select posts from forums where id = #{forum_id}" do |rs|
        rs.each do
          forum_posts = rs.read(Int32)
        end
      end
      db.exec "update forums set posts = #{forum_posts + 1} where id = #{forum_id}"

      user_posts = 0
      db.query "select posts from users where id = #{user_id}" do |rs|
        rs.each do
          user_posts = rs.read(Int32)
        end
      end
      db.exec "update users set posts = #{user_posts + 1} where id = #{user_id}"
    end
    post
  end

  def self.create_user(username : String, hash : String)
    user = User.new(-1, "Invalid User", "Invalid Hash")
    DB.open @@config.mysql_url do |db|
      db.exec "insert into users (name, password) values (?, ?)", username, hash
      db.query "select id from users order by id desc limit 1" do |rs|
        rs.each do
          id = rs.read(Int32)
          user = User.new(id, username, hash)
        end
      end
    end
    user
  end

  def self.login(username : String, password : String)
    id = -1
    hash = "Invalid Hash"
    DB.open @@config.mysql_url do |db|
      db.query "select id, password from users where name = ?", username do |rs|
        rs.each do
          t_id = rs.read(Int32)
          t_hash = rs.read(String)
          t_password = Crypto::Bcrypt::Password.new(t_hash)
          if t_password == password
            id = t_id
            hash = t_hash
          end
        end
      end
    end

    if id < 0
      # TODO: Error recovery
      return {"-1", User.new(-1, username, hash)}
    end

    # TODO: Store Random because object creation is bad
    s = Random.new.next_u32.to_s
    @@sessions[s] = id
    return {s, User.new(id, username, hash)}
  end

  def self.get_page_views()
    views = 0
    DB.open @@config.mysql_url do |db|
      db.query "select front_page_views from stats where id = 1" do |rs|
        rs.each do
          views = rs.read(Int64)
        end
      end
    end
    return views
  end

  def self.increment_page_views()
    DB.open @@config.mysql_url do |db|
      views = 0
      db.query "select front_page_views from stats where id = 1" do |rs|
        rs.each do
          views = rs.read(Int64)
        end
      end
      db.exec "update stats set front_page_views = #{views + 1} where id = 1"
    end
  end

  macro get_user_from_session()
    if env.session["board_id"]?
      session_id = env.session["board_id"]
      if Board.sessions[session_id]?
        user_id = Board.sessions[session_id]
        user = Board.get_user(user_id)
      end
    end
  end

  macro get_user_id_from_session()
    if env.session["board_id"]?
      session_id = env.session["board_id"]
      if Board.sessions[session_id]?
        user_id = Board.sessions[session_id]
      end
    end
  end

end
