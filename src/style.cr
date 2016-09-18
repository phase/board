require "process"

def generate_styleheet(s : String)
  Process.run("sass", ["style/#{s}.sass", "style/#{s}.css"])
  puts "Generated Stylsheet '#{s}' from Sass sources."
end
