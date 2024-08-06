# VagrantPlugin UTM

vagrant_utm is a [Vagrant](http://www.vagrantup.com) plugin which adds [UTM](https://mac.getutm.app) provider to Vagrant, 
allowing Vagrant to control and provision UTM virtual machines via UTM's API.

Refer to the [documentation](https://naveenrajm7.github.io/vagrant_utm/) for more details.

## Installation

```bash
vagrant plugin install vagrant_utm
```

## Usage

```ruby
Vagrant.configure("2") do |config|
  config.vm.provider :utm do |utm|
    utm.utm_file_url = "http://localhost:8000/vm_utm.zip"
  end
end
```

```bash
vagrant up
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Vagrant

To test your plugin with vagrant, run
```bash
bundle exec vagrant <command> --debug
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/naveenrajm7/vagrant_utm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/naveenrajm7/vagrant_utm/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). However, it uses vagrant library and parts of the code from virtualbox plugin both of which is BSL.
Please be aware of this if you intend on redistributing this plugin. 

## Credits

* [Vagrant plugin development docs](https://developer.hashicorp.com/vagrant/docs/plugins/development-basics)
* Other vagrant plugins
    * [virtualbox](https://github.com/hashicorp/vagrant/tree/main/plugins/providers/virtualbox)
    * [tart](https://letiemble.github.io/vagrant-tart/)

## Code of Conduct

Everyone interacting in the VagrantUtm project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/naveenrajm7/vagrant_utm/blob/main/CODE_OF_CONDUCT.md).
