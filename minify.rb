# Script to minify JavaScript files in folder passed in first argument
# Created by Bas van Marwijk
# https://github.com/bascoder
# Run example: ruby minify.rb target_directory

dir = ARGV[0]
pattern = "#{dir}#{File::SEPARATOR}*.js"

unless dir.is_a? String
  puts 'Expect first argument to be a directory path, but was ' + dir.to_s
  exit -1
end

puts 'dir: ' + dir
puts 'pattern: ' + pattern
puts 'JavaScript (including min.js) files found: ' + Dir[pattern].each.size.to_s

js_count = 0
fail_count = 0
success_count = 0

#iterate over JS files
Dir[pattern].each do |file|
  # only iterate over source files, no min.js files
  if file.include? '.js' and !file.include? '.min.js'

    js_count += 1

    # subtract .js extension
    without_extension = file[0, file.length - 3]

    if "#{without_extension}.js" != file
      puts 'error in ruby script'
      puts without_extension + '.js'
      puts 'should equal'
      puts file

      # increment fail counter
      fail_count += 1
    else
      puts 'minify ' + file

      #uglifyjs $FileName$ -o $FileNameWithoutExtension$.min.js --source-map $FileNameWithoutExtension$.min.map
      command = "uglifyjs #{file} -o #{without_extension}.min.js --source-map #{without_extension}.min.map"

      # execute command
      system command

      # check if command succeeded
      if $?.success?
        success_count += 1

        puts 'Successfully minified ' + file
      else
        puts $?
        puts 'WARNING, minify command failed ' + command

        fail_count += 1
      end
    end
  end
end

puts "Processed #{js_count} files, #{success_count} successes and #{fail_count} failures"
# exit success if fail_count == 0
exit(fail_count)
