# systemd-units

A collection of custom systemd units and generators

## Configuration

Create a new Makefile with a suffix matching the machine's hostname:

```sh
vim Makefile.$(hostname)
```

The following variables can be set in the new Makefile.

If no host-specific Makefile is found, **ALL** units and generators will be installed

```make
#! Host-specific generators to install
GENERATORS ?=

#! Host-specific services to install
SERVICES   ?=

#! Host-specific mounts to install
MOUNTS     ?=

#! Host-specific generator installation path
GENERATOR_INSTALL_PATH  ?= /etc/systemd/system-generators

#! Host-specific unit installation path
UNIT_INSTALL_PATH       ?= /etc/systemd/system
```

### Specifying units to install

* `GENERATORS` must contain filenames which exist in the `generators/` directory

* `SERVICES` and `MOUNTS` must contain filenames **without extension** which exist in their respective directories

_e.g._

```make
# Makefile.fred
SERVICES   := jupyter-notebook
GENERATORS := samba-automount-generator.sh
MOUNTS     := storage-pvr
```


## Usage


```sh
# List Makefile targets
make help

# Preview configured targets
make preview

# Install all targets
make install

# Uninstall all targets
make uninstall
```

