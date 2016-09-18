require "kemal"
require "mysql"
require "./board"
require "./style"
require "./templates"

generate_stylesheet "base"
stylesheet = File.read("style/base.css")
sql_url = File.read("config.txt")

# index page showing all forums
get "/" do |env|
  forums = get_forums(sql_url)
  BoardTemplate.new(stylesheet, IndexTemplate.new(forums).to_s).to_s
end

# view threads in a forum
get "/forum/:id" do |env|
  forum_id = env.params.url["id"].to_i
  threads = get_threads(sql_url, forum_id)
  BoardTemplate.new(stylesheet, ForumTemplate.new(forum_id, threads).to_s).to_s
end

# view posts in a thread
get "/thread/:id" do |env|
  thread_id = env.params.url["id"].to_i
  posts = get_posts(sql_url, thread_id)
  BoardTemplate.new(stylesheet, ThreadTemplate.new(thread_id, posts).to_s).to_s
end

csrf_handler = Kemal::Middleware::CSRF.new
Kemal.config.add_handler csrf_handler

Kemal.run
