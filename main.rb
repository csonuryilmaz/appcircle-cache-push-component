require 'fileutils'
require 'pathname'
require 'English'

def get_env_variable(key)
  return nil if ENV[key].nil? || ENV[key].strip.empty?

  ENV[key].strip
end

def run_command(command)
  puts "@@[command] #{command}"
  exit $CHILD_STATUS.exitstatus unless system(command)
end

def run_command_silent(command)
  exit $CHILD_STATUS.exitstatus unless system(command)
end

def install_deps_if_not_exist(tool)
  run_command_silent("dpkg -s #{tool} > /dev/null 2>&1 || apt-get -y install #{tool} > /dev/null 2>&1")
end

ac_cache_included_paths = get_env_variable('AC_CACHE_INCLUDED_PATHS') || abort('Included paths must be defined.')
ac_cache_excluded_paths = get_env_variable('AC_CACHE_EXCLUDED_PATHS')
ac_repository_path = get_env_variable('AC_REPOSITORY_DIR') || abort('Repository path must be defined.')
ac_cache_label = get_env_variable('AC_CACHE_LABEL') || abort('Cache label path must be defined.')

install_deps_if_not_exist('curl')
install_deps_if_not_exist('zip')

@cache = "ac_cache/#{ac_cache_label}"
zipped = "ac_cache/#{ac_cache_label.gsub('/', '_')}.zip"

puts ac_cache_included_paths
puts ac_cache_excluded_paths
puts ac_repository_path
puts ''

system("mkdir -p #{@cache}/repository")

def cache_path(base_path, included_path, excluded_paths)
  puts "Global Include: #{included_path}"

  glob_pattern = "#{base_path}/#{included_path}"

  paths = Dir.glob(glob_pattern)
  return if paths.empty?

  zip_file = "#{@cache}/#{glob_pattern.gsub('/', '_')}.zip"
  zip = "zip -r -FS #{zip_file}"
  paths.each do |f|
    zip += " #{f}"
  end
  zip += ' -x' unless excluded_paths.empty?
  excluded_paths.each do |excluded|
    zip += " #{excluded}"
  end
  run_command("#{zip} > #{zip_file}.log")
  run_command_silent("ls -lh #{zip_file}")
end

def cache_repository_path(base_path, included_path, excluded_paths)
  puts "Repository Include: #{included_path}"

  cwd = Dir.pwd
  Dir.chdir(base_path)
  paths = Dir.glob(included_path.to_s)

  if paths.empty?
    Dir.chdir(cwd)
    return
  end

  zip_file = "#{cwd}/#{@cache}/repository/#{included_path.gsub('/', '_')}.zip"
  zip = "zip -r -FS #{zip_file}"
  paths.each do |f|
    zip += " #{f}"
  end
  zip += ' -x' unless excluded_paths.empty?
  excluded_paths.each do |excluded|
    zip += " #{excluded}"
  end
  run_command("#{zip} > #{zip_file}.log")
  run_command_silent("ls -lh #{zip_file}")

  Dir.chdir(cwd)
end

def get_excluded_paths(paths)
  r_excludes = []
  g_excludes = []

  paths.split(':').each do |path|
    path = path[1..-1] if !path.empty? && path[0] == '/'
    next if path.empty?

    # @todo: Check $home path for other types of agents and build profiles
    if path.start_with?('$HOME')
      path = path[('$HOME'.length + 1)..-1]
      g_excludes.push("/setup/#{path}")
    else
      r_excludes.push(path)
    end
  end
  { 'global' => g_excludes, 'repository' => r_excludes }
end

excluded_paths = get_excluded_paths(ac_cache_excluded_paths)
puts excluded_paths

ac_cache_included_paths.split(':').each do |included_path|
  included_path = included_path[1..-1] if !included_path.empty? && included_path[0] == '/'
  next if included_path.empty?

  # @todo: Check $home path for other types of agents and build profiles
  if included_path.start_with?('$HOME')
    included_path = included_path[('$HOME'.length + 1)..-1]
    cache_path('/setup', included_path, excluded_paths['global'])
  else
    cache_repository_path(ac_repository_path, included_path, excluded_paths['repository'])
  end
end

run_command_silent("[ -s #{zipped} ] || rm -f #{zipped}")
run_command("zip -r -0 -FS #{zipped} #{@cache}")
run_command_silent("ls -lh #{zipped}")

if get_env_variable('AC_CACHE_PUT_URL')
  puts ''
  puts 'Uploading cache...'
  run_command_silent("curl -X PUT -H \"Content-Type: application/zip\" --upload-file #{zipped} $AC_CACHE_PUT_URL")
end
