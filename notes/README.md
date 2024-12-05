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

1. Update the version number in `version.rb`
2. Run `bundle exec rake release`
3. Commit version and Gemlock file
4. Run `bundle exec rake release` again
5. Cancel push to rubygems.org 

GHA will publish gems to GHR and rubygems


To update specific gems in the project

`bundle update rubocop`