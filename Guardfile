# guard

ignore(/.bundle/)
ignore(/.config/)
ignore(/.gem/)
ignore(/.git/)
ignore(/.guard_history/)
ignore(/.idea/)
ignore(/.local/)
ignore(/.node-gyp/)
ignore(/.rspec_status/)
ignore(/Gemfile.lock/)
ignore(/node_modules/)

def print_line(character)
  puts "\n" + character * 80 + "\n"
end

watch(/.*\.rb/) do |match|
  system("clear")
  print_line("=")
  path = match[0]
  puts "Processing file: #{path}..."
  system "rubocop --auto-correct #{path}"
  print_line("-")
  system "ruby *_test.rb"
  print_line("-")
end
