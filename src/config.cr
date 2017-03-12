require "json"

class Config
  JSON.mapping(
    name: String,
    session_secret: String,
    mysql_url: String,
  )
end

