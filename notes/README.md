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