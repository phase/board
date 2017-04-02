require "spec"
require "crypto/bcrypt"
require "../src/board.cr"

Board.config = Config.from_json(File.read("config.json"))
rand = Random.new

describe "Board" do
  it "creates users" do
    username = rand.next_u.to_s
    password = Crypto::Bcrypt::Password.create("cat", cost: 6).to_s
    user = Board.create_user(username, password)
    user.id.should_not eq(-1)
  end

  it "creates forums" do
    name = "Generic Forum"
    title = "Generic Subtitle"
    forum = Board.create_forum(name, title)
    forum.id.should_not eq(-1)
  end

  it "creates threads" do
    name = "Generic Thread"
    title = "Generic Subtitle"
    user_id = 0
    forum_id = 0
    thread = Board.create_thread(name, title, user_id, forum_id)
    thread.id.should_not eq(-1)
  end

  it "creates posts" do
    text = "I think that is very interesting."
    user_id = 0
    thread_id = 0
    post = Board.create_post(text, thread_id, user_id)
    post.id.should_not eq(-1)
  end
end
