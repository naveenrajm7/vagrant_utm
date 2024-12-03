## [0.1.1] - 2024-12-03 

IMPORTANT: This version of the plugin only works with UTM version 4.5.1 and above, and is incompatible with 0.0.1 version of the plugin.

### Added

- command: add new vagrant command `vagrant ip-address` (9252020)
- command: add help messages to custom plugin commands (a35466f)
- action: Set mac address when bringing up new machine (0efe15b) 

### Changed

- plugin: Make config.vm.box mandatory for this plugin (b5be5e8)

### Fixed

- disposable: allow disposable start only for machines already created (cbf591e)
- up: Set given mac address or random mac address for first interface of a machine to get different IPs of a same base box. 

### Removed

- Driver: Removed support for UTM version 4.5.x (9aea46e)

## [0.1.0] (Beta) - 2024-11-30

IMPORTANT: This version of the plugin only works with UTM version 4.5.1 and above, and is incompatible with previous versions of the plugin.

### Added

- driver: add new driver for UTM version 4.6.x (13d0ca0)
- vagrant: add vagrant box support (f7accad)
- command: support `vagrant package` command (39fb5a5)


### Removed

- Drop support for `utm_file_url` from provider config (4fb0ac0)
- Remove support for importing utm files in zip format (c988671)



## [0.0.1] (Pilot release) - 2024-08-08 

* Initial release with all basic vagrant commands
* Uses UTM file in zip format from a url as VM box to import