
GENERATORS_INSTALL_PATH := /lib/systemd/system-generators

UNITS_INSTALL_PATH      := /etc/systemd/system

#------------------------------------------------------------------------------

CD                := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Collect all generator files
GENERATORS        := $(wildcard generators/*)

# Generator destination paths
GENERATOR_TARGETS := $(addprefix $(GENERATORS_INSTALL_PATH)/,$(notdir $(GENERATORS)))

# Collect all unit files
SERVICES          := $(wildcard services/*.service)
MOUNTS            := $(wildcard mounts/*.mount) $(wildcard mounts/*.automount)

# Unit destination paths
UNIT_TARGETS      := $(addprefix $(UNITS_INSTALL_PATH)/,$(notdir $(SERVICES) $(MOUNTS)))

# 'make install' target files
INSTALL_TARGETS   := $(GENERATOR_TARGETS) $(UNIT_TARGETS)

# 'make uninstall' targets
UNINSTALL_TARGETS := $(addsuffix ._delete_,$(foreach x,$(INSTALL_TARGETS),$(wildcard $(x))))

# These will be restarted upon install/uninstall
RESTART_TARGETS   := local-fs.target remote-fs.target

#------------------------------------------------------------------------------

default: help

help:
	@echo "make install                   |  Install all units"
	@echo "make uninstall                 |  Remove installed units"

install: $(INSTALL_TARGETS)
	systemctl daemon-reload
	systemctl restart $(RESTART_TARGETS)

uninstall: $(UNINSTALL_TARGETS)
	systemctl daemon-reload
	systemctl restart $(RESTART_TARGETS)

.PHONY: defaults help install uninstall

#------------------------------------------------------------------------------

$(GENERATORS_INSTALL_PATH)/% : generators/%
	@ln -vf "$(CD)/$<" $@ 

$(UNITS_INSTALL_PATH)/% : services/%
	@ln -vf "$(CD)/$<" $@

$(UNITS_INSTALL_PATH)/% : mounts/%
	@ln -vf "$(CD)/$<" $@

%._delete_ : %
	@rm -vf $<
