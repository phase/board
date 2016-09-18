require "json"

class Config
  JSON.mapping(
    name: String,
    mysql_url: String,
  )
end
