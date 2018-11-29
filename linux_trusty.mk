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

TOOLCHAIN_ROOT ?= $(TOP_DIR)/toolchain

LK_ENV_VAR += ARCH_x86_64_TOOLCHAIN_INCLUDED=1
LK_ENV_VAR += BUILDROOT=$(TOP_DIR)/out/trusty/
LK_ENV_VAR += CLANG_BINDIR=$(TOOLCHAIN_ROOT)/clang/host/linux-x86/clang-4679922/bin
LK_ENV_VAR += ARCH_x86_64_TOOLCHAIN_PREFIX=$(TOOLCHAIN_ROOT)/gcc/x86_64-linux-android-4.9/bin/x86_64-linux-android-

TRUSTY_CA_ENV_VAR += BUILD_DIR=$(TOP_DIR)/out/trusty_ca/

export TRUSTY_REF_TARGET=linux_trusty

.PHONY: all trusty trusty_ca clean

all: trusty trusty_ca

trusty:
	@echo '****************************************************************'
	@echo '*   apply aosp diff patches...'
	@echo '****************************************************************'
	@build/aosp_diff/applypatch.sh $(TRUSTY_REF_TARGET)

	@echo '****************************************************************'
	@echo '*   build trusty os...'
	@echo '****************************************************************'
	$(LK_ENV_VAR) $(MAKE) -C trusty sand-x86-64

trusty_ca:
	@echo '****************************************************************'
	@echo '*   build trusty client application...'
	@echo '****************************************************************'
	$(TRUSTY_CA_ENV_VAR) $(MAKE) -C system/core

clean:
	$(TRUSTY_ENV_VAR) $(MAKE) -C trusty spotless
	$(TRUSTY_CA_ENV_VAR)  $(MAKE) -C system/core clean
