# Appcircle Cache Push

Uploads user selected files and folders to Appcircle cache.

Required Input Variables

- `AC_CACHE_LABEL`: User defined cache label to identify one cache from others. Both cache push and pull steps should have the same value to match.
- `AC_CACHE_INCLUDED_PATHS`: Specifies the files and folder which should be in cache. Multiple glob patterns can be defined with colon seperated. For example; .gradle:app/build
- `AC_TOKEN_ID`: System generated token used for getting signed url. Zipped cache file is uploaded to signed url.
- `ASPNETCORE_CALLBACK_URL`: System generated callback url for signed url web service. It's different for various environments.

Optional Input Variables

- `AC_CACHE_EXCLUDED_PATHS`: Specifies the files and folder which should be ignored from cache. Multiple glob patterns can be defined with colon seperated. For example; .gradle/*.lock:*.apk
- `AC_REPOSITORY_DIR`: Cloned git repository path. Included and excluded paths are defined relative to cloned repository, except `~` prefixed paths.

## Included & Excluded Paths

Cache step uses a pattern in order to select files and folders. That the pattern is not a regexp, it's closer to a shell glob. (_The verb "glob" is an old Unix term for filename matching in a shell._)

Also we have some keywords or characters for special use cases, especially for system folders. Following sections summarize cache step's supported patterns for included and excluded paths.

### System vs. Repository

In order to identify between a repository resource and system resource, cache step checks prefix of the given pattern.

Repository resources begin with directly glob pattern. They shouldn't be prefixed with `/` or other folder tree characters.

For example:

- `.gradle/`: Is .gradle folder in project repository.
- `local.properties`: Is single file in project repository.
- `*.apk`: Is related with .apk files in project repository.

Repository resources are generated with git clone on most cases. For this reason, take care of step order while using cache and git clone for repository reources.

System resources begin with `~/` pattern. These resources are generated on build and on most cases they're not included in repository.

For example:

- `~/.gradle/`: Is .gradle folder at $HOME.
- `~/Library/Caches/CocoaPods`: Is Cocoapods caches folder at $HOME.

### Glob Patterns

#### `*`

Match zero or more characters. A glob consisting of only the asterisk and no other characters or wildcards will match all files or folders in that folder. The asterisk is usually combined with a file extension.

Examples:

- `AC_CACHE_INCLUDED_PATHS=*`: All files and folders in repository.
- `AC_CACHE_INCLUDED_PATHS=*.properties`: All files with .properties extension in repository. (_no subdirectories included_)
- `AC_CACHE_INCLUDED_PATHS=gradle*`: All files and folders begin with "gradle" in repository. (_no subdirectories included_)
