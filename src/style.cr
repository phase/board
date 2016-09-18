require "process"

def generate_stylesheet(s : String)
  Process.run("sass", ["style/#{s}.sass", "style/#{s}.css", "--sourcemap=none", "--style", "compressed"])
  puts "Generated Stylesheet '#{s}' from Sass sources."
end
