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
IKGT_TOOLCHAIN_PATH := $(TOOLCHAIN_ROOT)/gcc/x86_64-linux-android-4.9/bin

LK_ENV_VAR += ARCH_x86_64_TOOLCHAIN_INCLUDED=1
LK_ENV_VAR += BUILDROOT=$(TOP_DIR)/out/trusty/
LK_ENV_VAR += CLANG_BINDIR=$(TOOLCHAIN_ROOT)/clang/host/linux-x86/clang-4691093/bin
LK_ENV_VAR += ARCH_x86_64_TOOLCHAIN_PREFIX=$(TOOLCHAIN_ROOT)/gcc/x86_64-linux-android-4.9/bin/x86_64-linux-android-

IKGT_ENV_VAR += COMPILE_TOOLCHAIN=$(IKGT_TOOLCHAIN_PATH)/x86_64-linux-android-
IKGT_ENV_VAR += BUILD_DIR=$(TOP_DIR)/out/ikgt/

export TRUSTY_REF_TARGET=iot_joule

.PHONY: all ikgt trusty clean

all: ikgt trusty

trusty:
	@echo '****************************************************************'
	@echo '*   apply aosp diff patches...'
	@echo '****************************************************************'
	@build/aosp_diff/applypatch.sh

	@echo '****************************************************************'
	@echo '*   build trusty os...'
	@echo '****************************************************************'
	$(LK_ENV_VAR) $(MAKE) -C trusty sand-x86-64

ikgt:
	@echo '****************************************************************'
	@echo '*   build ikgt core...'
	@echo '****************************************************************'
	$(IKGT_ENV_VAR) $(MAKE) -C ikgt

clean:
	$(TRUSTY_ENV_VAR) $(MAKE) -C trusty spotless
	$(IKGT_ENV_VAR)   $(MAKE) -C ikgt clean
