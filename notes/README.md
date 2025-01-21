# Notes

This directory will hold documentation about the project.


# Development

To invoke vagrant with the plugin in development
```bash
bundle exec vagrant <command> --debug
```

To locally launch docs site
```bash
cd docs
bundle exec jekyll serve
```

To release 

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`
GitHub action upon tag push with "v*" will publish gem to GHR and rubygems

1. Update 
  CHANGELOG.md
  version number in `version.rb`
  version number Gemlock file
2. Commit 
3. Run `bundle exec rake release` (Commit and tags are pushed)
4. Cancel push to rubygems.org 

GHA will publish gems to GHR and rubygems


To update specific gems in the project

`bundle update rubocop`

To update all gems

`bundle update`

To update project after a version bump 

```
Unable to resolve dependency: user requested 'vagrant_utm (= 0.1.1)'
```

Due to mismatch versions between global installed version and plugin version in the development setup, since they are same name.
Fix: Uninstall the global version, while using different version of development setup
