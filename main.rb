require 'fileutils'
require 'pathname'

def get_env_variable(key)
  return nil if ENV[key].nil? || ENV[key].strip.empty?

  ENV[key].strip
end

ac_cache_included_paths = get_env_variable('AC_CACHE_INCLUDED_PATHS') || abort('Included paths must be defined.')
ac_cache_excluded_paths = get_env_variable('AC_CACHE_EXCLUDED_PATHS')

puts ac_cache_included_paths
puts ac_cache_excluded_paths
