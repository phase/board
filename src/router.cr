require "kemal"
require "mysql"
require "crypto/bcrypt"
require "./board"
require "./style"
require "./config"
require "./templates"

generate_stylesheet "base"
stylesheet = File.read("style/base.css")
Board.config = Config.from_json(File.read("config.json"))

# index page showing all forums
get "/" do |env|
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  forums = Board.get_forums
  BoardTemplate.new(stylesheet, IndexTemplate.new(user, forums).to_s, user).to_s
end

# view threads in a forum
get "/forum/:id" do |env|
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  forum_id = env.params.url["id"].to_i
  threads = Board.get_threads(forum_id)
  BoardTemplate.new(stylesheet, ForumTemplate.new(user, forum_id, threads).to_s, user).to_s
end

# view posts in a thread
get "/thread/:id" do |env|
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  thread_id = env.params.url["id"].to_i
  posts = Board.get_posts(thread_id)
  BoardTemplate.new(stylesheet, ThreadTemplate.new(user, thread_id, posts).to_s, user).to_s
end

get "/new/thread/:forum_id" do |env|
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  forum_id = env.params.url["forum_id"].to_i
  forum = Board.get_forum(forum_id)
  BoardTemplate.new(stylesheet, NewThreadTemplate.new(user, forum).to_s, user).to_s
end

get "/login" do |env|
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  BoardTemplate.new(stylesheet, LoginTemplate.new().to_s, user).to_s
end

get "/logout" do |env|
  env.session["board_id"] = "-1"
  env.redirect "/"
end

get "/register" do |env|
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  BoardTemplate.new(stylesheet, RegisterTemplate.new().to_s, user).to_s
end

post "/new/thread" do |env|
  # Get parameters for thread
  name = env.params.body["name"]
  title = env.params.body["title"]
  forum_id = env.params.body["forum"].to_i32
  user_id = -1
  Board.get_user_id_from_session
  # Create the thread and get the id of it for redirection
  thread_id = Board.create_thread(name, title, forum_id, user_id).id
  if thread_id == -1
    env.redirect "/"
  else
    # Get parameter for first post
    post_text = env.params.body["text"].as(String)
    Board.create_post(post_text, thread_id, user_id)
    env.redirect "/thread/#{thread_id}"
  end
end

post "/new/post" do |env|
  # Get parameters for post
  text = env.params.body["text"]
  thread_id = env.params.body["thread"].to_i32
  user_id = -1
  Board.get_user_id_from_session
  # Create post and redirect to the thread its on
  post_id = Board.create_post(text, thread_id, user_id).id
  env.redirect "/thread/#{thread_id}##{post_id}"
end

post "/login" do |env|
  username = env.params.body["username"]
  password = env.params.body["password"]
  result = Board.login(username, password)
  if result[0] == "-1"
    # TODO: Error recovery
    env.redirect "/#error"
  else
    env.session["board_id"] = result[0]
    env.redirect "/"
  end
end

post "/register" do |env|
  username = env.params.body["username"]
  password = env.params.body["password"]
  encrypted_password = Crypto::Bcrypt::Password.create(password, cost: 6).to_s
  Board.create_user(username, encrypted_password)
  env.redirect "/login"
end

# http://kemalcr.com/docs/middlewares/#csrf
# csrf_handler = Kemal::Middleware::CSRF.new
# Kemal.config.add_handler csrf_handler

Kemal.run
