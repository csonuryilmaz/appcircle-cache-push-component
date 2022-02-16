# Appcircle Cache Push

Uploads user selected files and folders to Appcircle cache.

Required Input Variables

- `AC_CACHE_INCLUDED_PATHS`: Specifies the files and folder which should be in cache. Multiple glob patterns can be defined with colon seperated. For example; .gradle:app/build
- `AC_REPOSITORY_DIR`: Cloned git repository path. Included and excluded paths are defined relative to cloned repository, except `$HOME` prefixed paths.

Optional Input Variables

- `AC_CACHE_EXCLUDED_PATHS`: Specifies the files and folder which should be ignored from cache. Multiple glob patterns can be defined with colon seperated. For example; .gradle/*.lock:*.apk
