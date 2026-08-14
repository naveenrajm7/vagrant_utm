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

Publishing is done by GitHub Actions. Pushing a tag matching "v*" triggers `.github/workflows/gem.yml`,
which builds the gem once and then publishes it to GitHub Packages and rubygems.org, and creates the
GitHub release with the `.gem` attached.

So locally we only bump the version and push the tag.

1. Update
  CHANGELOG.md (move the `[Unreleased]` entries under a new `[x.y.z] - YYYY-MM-DD` heading)
  version number in `version.rb`
  version number in `Gemfile.lock` (the `vagrant_utm (x.y.z)` line under `PATH`)
2. Commit
3. Run `bundle exec rake release:guard_clean release:source_control_push`
   (checks the tree is clean, creates the annotated tag, pushes the commit and the tag)
4. Watch the run: `gh run watch $(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')`

Do not run plain `bundle exec rake release`. It appends `release:rubygem_push`, which publishes the gem
from your machine and duplicates what GHA already does — the old workaround was to cancel that push by
hand, which is a race you can lose. Running the two subtasks above is the same flow without the race.

After the run, confirm the gem actually shipped what you expect:

```bash
gem unpack vagrant_utm-x.y.z.gem
# every shipped applescript should be ASCII; non-ASCII bytes broke 0.1.5 (see #50)
file vagrant_utm-x.y.z/lib/vagrant_utm/scripts/*.applescript
```


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

If `bundle install` fails building grpc

```
third_party/zlib/zutil.h:147: #define fdopen(fd,mode) NULL
_stdio.h:320: error: expected identifier or '('
```

grpc 1.56.2 (pulled in by the pinned vagrant 2.4.1) vendors a zlib that defines `fdopen` to `NULL` on
macOS, which newer Xcode clang rejects. CI is unaffected because Linux uses a precompiled grpc, so the
test suite still runs there. Until the vagrant pin moves, `rake` also works without `bundle exec`, which
is enough to run the release subtasks above.
