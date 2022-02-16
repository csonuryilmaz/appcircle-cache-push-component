# Appcircle Cache Push

Uploads user selected files and folders to Appcircle cache.

Required Input Variables

- `AC_CACHE_INCLUDED_PATHS`: Specifies the files and folder which should be in cache. Multiple glob patterns can be defined with colon seperated. For example; .gradle:app/build

Optional Input Variables

- `AC_CACHE_EXCLUDED_PATHS`: Specifies the files and folder which should be ignored from cache. Multiple glob patterns can be defined with colon seperated. For example; .gradle/*.lock:*.apk
