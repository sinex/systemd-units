#------------------------------------------------------------------------------
CD                := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
HOSTNAME          := $(shell hostname)
HOST_MAKEFILE     := $(wildcard Makefile.$(HOSTNAME))
DEBUG             ?= 0
ifeq ($(DEBUG),1)
D := echo
else
D :=
endif

# Load install targets from host file if it exists
ifneq ($(HOST_MAKEFILE),)
include $(HOST_MAKEFILE)
#! Host-specific generators to install
GENERATORS ?=
#! Host-specific services to install
SERVICES   ?=
#! Host-specific mounts to install
MOUNTS     ?=
else
GENERATORS ?= *
SERVICES   ?= *
MOUNTS     ?= *
endif

#! Host-specific generator installation path
GENERATOR_INSTALL_PATH  ?= /etc/systemd/system-generators

#! Host-specific unit installation path
UNIT_INSTALL_PATH       ?= /etc/systemd/system

#------------------------------------------------------------------------------

# Source file paths
GENERATOR_FILES      := $(foreach x,$(GENERATORS),$(wildcard generators/$(x)))
SERVICE_FILES        := $(foreach x,$(SERVICES),$(wildcard services/$(x).service))
MOUNT_FILES          := $(foreach x,$(MOUNTS),$(wildcard mounts/$(x).mount) $(wildcard mounts/$(x).automount))

# Target file paths
GENERATOR_TARGETS := $(addprefix $(patsubst %/,%,$(GENERATOR_INSTALL_PATH))/,$(notdir $(GENERATOR_FILES)))
UNIT_TARGETS      := $(addprefix $(patsubst %/,%,$(UNIT_INSTALL_PATH))/,$(notdir $(SERVICE_FILES) $(MOUNT_FILES)))

# 'make install' target files
INSTALL_TARGETS   := $(GENERATOR_TARGETS) $(UNIT_TARGETS)

# 'make uninstall' fake targets
UNINSTALL_TARGETS := $(addsuffix ._delete_,$(foreach x,$(INSTALL_TARGETS),$(wildcard $(x))))

# These will be restarted upon install/uninstall
RESTART_TARGETS   := local-fs.target remote-fs.target

#------------------------------------------------------------------------------

default: help

help:
	@echo "make install                   |  Install all units"
	@echo "make uninstall                 |  Remove installed units"
	echo $(INSTALL_TARGETS)

preview:
	@echo "Targets for host '$(HOSTNAME)':"
	@printf "\t%s\n" $(INSTALL_TARGETS)
	

install: $(INSTALL_TARGETS)
	$(D) systemctl daemon-reload
	$(D) systemctl restart $(RESTART_TARGETS)

uninstall: $(UNINSTALL_TARGETS)
	$(D) systemctl daemon-reload
	$(D) systemctl restart $(RESTART_TARGETS)

.PHONY: defaults help install uninstall

#------------------------------------------------------------------------------

$(GENERATOR_INSTALL_PATH)/% : generators/%
	@$(D) ln -vf "$(CD)/$<" $@ 

$(UNIT_INSTALL_PATH)/% : services/%
	@$(D) ln -vf "$(CD)/$<" $@

$(UNIT_INSTALL_PATH)/% : mounts/%
	@$(D) ln -vf "$(CD)/$<" $@

%._delete_ : %
	@$(D) rm -vf $<
