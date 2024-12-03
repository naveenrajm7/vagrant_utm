## [Unreleased] - 

IMPORTANT: This version of the plugin only works with UTM version 4.5.1 and above

### Added

- command: add new vagrant command `vagrant ip-address`
- command: add help messages to custom plugin commands 
- action: Set mac address when bringing up new machine 

### Changed

- plugin: Make config.vm.box mandatory for this plugin

### Fixed

- disposable: allow disposable start for already created machine
- up: Set given mac address or random mac address for first interface of a machine to get different IPs of a same base box. 

### Removed

- Driver: Removed support for UTM version 4.5.x

## [0.1.0] (Beta) - 2024-11-30

IMPORTANT: This version of the plugin only works with UTM version 4.5.1 and above, and is incompatible with previous versions of the plugin.

### Added

- driver: add new driver for UTM version 4.6.x [13d0ca0]()
- vagrant: add vagrant box support
- command: support `vagrant package` command


### Removed

- Drop support for `utm_file_url` from provider config
- Remove support for importing utm files in zip format



## [0.0.1] (Pilot release) - 2024-08-08 

* Initial release with all basic vagrant commands
* Uses UTM file in zip format from a url as VM box to import