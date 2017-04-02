require "kemal"
require "kemal-session"
require "mysql"
require "crypto/bcrypt"
require "./board"
require "./style"
require "./config"
require "./templates"

generate_stylesheet "base"
stylesheet = File.read("style/base.css")
Board.config = Config.from_json(File.read("config.json"))

Session.config.secret = Board.config.session_secret

# index page showing all forums
get "/" do |env|
  Board.increment_page_views
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  forums = Board.get_forums
  BoardTemplate.new(stylesheet, IndexTemplate.new(user, forums).to_s, user).to_s
end

# view threads in a forum
get "/forum/:id" do |env|
  Board.increment_page_views
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  forum_id = env.params.url["id"].to_i rescue -1
  threads = Board.get_threads(forum_id)
  BoardTemplate.new(stylesheet, ForumTemplate.new(user, forum_id, threads).to_s, user).to_s
end

# view posts in a thread
get "/thread/:id" do |env|
  Board.increment_page_views
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  thread_id = env.params.url["id"].to_i rescue -1
  Board.increment_view(thread_id)
  posts = Board.get_posts(thread_id)
  BoardTemplate.new(stylesheet, ThreadTemplate.new(user, thread_id, posts).to_s, user).to_s
end

get "/new/thread/:forum_id" do |env|
  Board.increment_page_views
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  forum_id = env.params.url["forum_id"].to_i rescue -1
  forum = Board.get_forum(forum_id)
  BoardTemplate.new(stylesheet, NewThreadTemplate.new(user, forum).to_s, user).to_s
end

get "/login" do |env|
  Board.increment_page_views
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  BoardTemplate.new(stylesheet, LoginTemplate.new().to_s, user).to_s
end

get "/logout" do |env|
  Board.increment_page_views
  env.session.string("board_id", "-1")
  env.redirect "/"
end

get "/register" do |env|
  Board.increment_page_views
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  BoardTemplate.new(stylesheet, RegisterTemplate.new().to_s, user).to_s
end

get "/profile/:id" do |env|
  Board.increment_page_views
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  profile_id = env.params.url["id"].to_i rescue -1
  profile = Board.get_user(profile_id)
  BoardTemplate.new(stylesheet, ProfileTemplate.new(user, profile).to_s, user).to_s
end

get "/edit/profile" do |env|
  Board.increment_page_views
  user = User.new(-1, "Invalid User", "Invalid Password")
  Board.get_user_from_session
  if user.id == -1
    env.redirect "/login"
  else
    BoardTemplate.new(stylesheet, EditProfileTemplate.new(user).to_s, user).to_s
  end
end

post "/new/thread" do |env|
  # Get parameters for thread
  _name = env.params.body["name"]
  name = _name.is_a?(String) ? _name : _name[0]
  _title = env.params.body["title"]
  title = _title.is_a?(String) ? _title : _title[0]
  _forum_id = env.params.body["forum"]
  forum_id = (_forum_id.is_a?(String) ? _forum_id : _forum_id[0]).to_i32

  user_id = -1
  Board.get_user_id_from_session

  # Create the thread and get the id of it for redirection
  thread_id = Board.create_thread(name, title, forum_id, user_id).id
  if thread_id == -1
    BoardTemplate.new(stylesheet, ErrorTemplate.new("Couldn't create thread.").to_s, Board.get_user(user_id)).to_s
  else
    # Get parameter for first post
    post_text = env.params.body["text"].as(String)
    Board.create_post(post_text, thread_id, user_id)
    env.redirect "/thread/#{thread_id}"
  end
end

post "/new/post" do |env|
  # Get parameters for post
  _text = env.params.body["text"]
  text = _text.is_a?(String) ? _text : _text[0]
  _thread_id = env.params.body["thread"]
  thread_id = (_thread_id.is_a?(String) ? _thread_id : _thread_id[0]).to_i32

  user_id = -1
  Board.get_user_id_from_session
  # Create post and redirect to the thread its on
  post_id = Board.create_post(text, thread_id, user_id).id
  env.redirect "/thread/#{thread_id}##{post_id}"
end

post "/login" do |env|
  _username = env.params.body["username"]
  username = _username.is_a?(String) ? _username : _username[0]
  _password = env.params.body["password"]
  password = _password.is_a?(String) ? _password : _password[0]

  result = Board.login(username, password)
  if result[0] == "-1"
    # TODO: Error recovery
    env.redirect "/#error"
  else
    env.session.string("board_id", result[0])
    env.redirect "/"
  end
end

post "/register" do |env|
   _username = env.params.body["username"]
  username = _username.is_a?(String) ? _username : _username[0]
  _password = env.params.body["password"]
  password = _password.is_a?(String) ? _password : _password[0]

  encrypted_password = Crypto::Bcrypt::Password.create(password, cost: 6).to_s
  Board.create_user(username, encrypted_password)
  env.redirect "/login"
end

post "/edit/profile" do |env|
  user_id = -1
  Board.get_user_id_from_session
  if user_id == -1
    env.redirect "/login"
  else
    _title = env.params.body["title"]
    title = _title.is_a?(String) ? _title : _title[0]

    Board.update_user(user_id, title)
    env.redirect "/profile/#{user_id}"
  end
end

# http://kemalcr.com/docs/middlewares/#csrf
# csrf_handler = Kemal::Middleware::CSRF.new
# Kemal.config.add_handler csrf_handler

Kemal.run
