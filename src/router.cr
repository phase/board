require "kemal"
require "mysql"
require "./board"
require "./style"
require "./config"
require "./templates"

generate_stylesheet "base"
stylesheet = File.read("style/base.css")
Board.config = Config.from_json(File.read("config.json"))

# index page showing all forums
get "/" do |env|
  forums = Board.get_forums
  BoardTemplate.new(stylesheet, IndexTemplate.new(forums).to_s).to_s
end

# view threads in a forum
get "/forum/:id" do |env|
  forum_id = env.params.url["id"].to_i
  threads = Board.get_threads(forum_id)
  BoardTemplate.new(stylesheet, ForumTemplate.new(forum_id, threads).to_s).to_s
end

# view posts in a thread
get "/thread/:id" do |env|
  thread_id = env.params.url["id"].to_i
  posts = Board.get_posts(thread_id)
  BoardTemplate.new(stylesheet, ThreadTemplate.new(thread_id, posts).to_s).to_s
end

post "/new/thread" do |env|
  # Get parameters for thread
  name = env.params.json["name"].as(String)
  title = env.params.json["title"].as(String)
  forum_id = env.params.json["forum"].as(Int64).to_i32
  user_id = env.params.json["user"].as(Int64).to_i32
  # Create the thread and get the id of it for redirection
  thread_id = Board.create_thread(name, title, forum_id, user_id).id

  # Get parameter for first post
  post_text = env.params.json["text"].as(String)
  Board.create_post(post_text, thread_id, user_id)
  env.redirect "/thread/#{thread_id}"
end

post "/new/post" do |env|
  # Get parameters for post
  puts env.params.query.to_s
  text = env.params.query["text"]
  thread_id = env.params.query["thread"].to_i32
  user_id = env.params.query["user"].to_i32
  puts "#{text}, #{thread_id}, #{user_id}"
  # Create post and redirect to the thread its on
  post_id = Board.create_post(text, thread_id, user_id)
  env.redirect "/thread/#{thread_id}#post_id"
end

# http://kemalcr.com/docs/middlewares/#csrf
# csrf_handler = Kemal::Middleware::CSRF.new
# Kemal.config.add_handler csrf_handler

Kemal.run
