require 'fileutils'
require 'pathname'
require 'English'

def get_env_variable(key)
  return nil if ENV[key].nil? || ENV[key].strip.empty?

  ENV[key].strip
end

ac_cache_included_paths = get_env_variable('AC_CACHE_INCLUDED_PATHS') || abort('Included paths must be defined.')
ac_cache_excluded_paths = get_env_variable('AC_CACHE_EXCLUDED_PATHS')
ac_repository_path = get_env_variable('AC_REPOSITORY_DIR') || abort('Repository path must be defined.')

@cache = 'ac_cache'

puts ac_cache_included_paths
puts ac_cache_excluded_paths
puts ac_repository_path
puts ''

system("mkdir -p #{@cache}")

def run_command(command)
  puts "@@[command] #{command}"
  exit $CHILD_STATUS.exitstatus unless system(command)
end

def cache_global_path(base_path, included_path, base_replace_with = '')
  puts "Global Include: #{included_path}"

  included_path = included_path[(base_path.length + 1)..-1]
  base_path = base_replace_with unless base_replace_with.empty?
  glob_pattern = "#{base_path}/#{included_path}"

  zip_file = "#{@cache}/#{glob_pattern.gsub('/', '_')}.zip"
  zip = "zip -r -FS #{zip_file}"
  Dir.glob(glob_pattern).each do |f|
    zip += " #{f}"
  end
  run_command("#{zip} > #{zip_file}.log")
  system("ls -lh #{zip_file}")
end

def cache_repository_path(base_path, included_path)
  puts "Repository Include: #{included_path}"

  Dir.glob("#{base_path}/#{included_path}").each do |f|
    puts f
  end
end

ac_cache_included_paths.split(':').each do |included_path|
  included_path = included_path[1..-1] if !included_path.empty? && included_path[0] == '/'
  next if included_path.empty?

  # @todo: Check $home path for other types of agents and build profiles
  if included_path.start_with?('$HOME')
    cache_global_path('$HOME', included_path, '/setup')
  else
    cache_repository_path(ac_repository_path, included_path)
  end
end
