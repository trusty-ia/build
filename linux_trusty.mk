################################################################################
# Copyright (c) 2017 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

TOP_DIR = $(shell pwd)

LK_ENV_VAR += BUILDROOT=$(TOP_DIR)/out/trusty/
LK_ENV_VAR += ARCH_x86_64_TOOLCHAIN_PREFIX=/usr/bin/

IKGT_ENV_VAR += COMPILE_TOOLCHAIN=/usr/bin/
IKGT_ENV_VAR += BUILD_DIR=$(TOP_DIR)/out/ikgt/
IKGT_BIN_DIR = $(TOP_DIR)/out/ikgt/evmm_lk_pkg.bin

TRUSTY_CA_ENV_VAR += BUILD_DIR=$(TOP_DIR)/out/trusty_ca/

TRUSTY_CA_BIN = $(TOP_DIR)/out/trusty_ca/usr/bin
TRUSTY_CA_LIB = $(TOP_DIR)/out/trusty_ca/usr/lib64
TRUSTY_CA_SERVICE = $(TOP_DIR)/release/usr/lib/systemd/system

export TRUSTY_REF_TARGET=linux_trusty
export BOOT_ARCH=abl_cl
export LKBIN_DIR=$(TOP_DIR)/out/trusty/build-sand-x86-64/

.PHONY: all trusty ikgt trusty_ca clean

all: trusty ikgt trusty_ca

trusty:
	@echo '****************************************************************'
	@echo '*   apply aosp diff patches...'
	@echo '****************************************************************'
	@build/aosp_diff/applypatch.sh $(TRUSTY_REF_TARGET)

	@echo '****************************************************************'
	@echo '*   build trusty os...'
	@echo '****************************************************************'
	$(LK_ENV_VAR) $(MAKE) -C trusty sand-x86-64 NOECHO=@

trusty_ca:
	@echo '****************************************************************'
	@echo '*   build trusty client application...'
	@echo '****************************************************************'
	$(TRUSTY_CA_ENV_VAR) $(MAKE) -C system/core

ikgt: trusty
	@echo '****************************************************************'
	@echo '*   build ikgt core...'
	@echo '****************************************************************'
	$(IKGT_ENV_VAR) $(MAKE) -C ikgt

install:
	@echo 'install binary, lib, service of trusty_ca'
	mkdir -p $(DESTDIR)/usr/securestorage
	mkdir -p $(DESTDIR)/usr/bin
	mkdir -p $(DESTDIR)/usr/bin/securestorage
	cp $(TRUSTY_CA_BIN)/keymaster_test $(DESTDIR)/usr/bin
	cp $(TRUSTY_CA_BIN)/storageproxyd $(DESTDIR)/usr/bin
	mkdir -p $(DESTDIR)/usr/lib64
	cp $(TRUSTY_CA_LIB)/libinteltrustystorage.so $(DESTDIR)/usr/lib64
	cp $(TRUSTY_CA_LIB)/libkeymaster.so $(DESTDIR)/usr/lib64
	cp $(TRUSTY_CA_LIB)/libtrusty.so $(DESTDIR)/usr/lib64
	mkdir -p $(DESTDIR)/usr/lib/systemd/system
	cp $(TRUSTY_CA_SERVICE)/storaged.service $(DESTDIR)/usr/lib/systemd/system
	mkdir -p $(DESTDIR)/usr/lib/systemd/system/multi-user.target.wants
	ln -s ../storaged.service $(DESTDIR)/usr/lib/systemd/system/multi-user.target.wants/storaged.service

clean:
	$(TRUSTY_ENV_VAR) $(MAKE) -C trusty spotless
	$(TRUSTY_CA_ENV_VAR)  $(MAKE) -C system/core clean
	$(IKGT_ENV_VAR)   $(MAKE) -C ikgt clean
