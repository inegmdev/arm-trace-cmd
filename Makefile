# Compiler
SYS_ROOT:=/home/inegm/i/trace/ti-processor-sdk-linux-rt-am62xx-evm-08.06.00.42/linux-devkit/sysroots

SYSROOT_INCLUDE_DIR:=$(abspath $(SYS_ROOT)/aarch64-linux/usr/include/)
SYSROOT_LIBS_DIR:=$(abspath $(SYS_ROOT)/aarch64-linux/usr/lib/)
CROSS_COMPILE:=$(SYS_ROOT)/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-

# Main Paths
LINUX_TRACE_MAIN_DIR:=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
LINUX_TRACE_OUT_DIR:=$(abspath $(LINUX_TRACE_MAIN_DIR)/__OUT)
LINUX_TRACE_BUILD_DIR:=$(abspath $(LINUX_TRACE_OUT_DIR)/Build)
LINUX_TRACE_OUT_BIN_DIR:=$(abspath $(LINUX_TRACE_OUT_DIR)/bin)
LINUX_TRACE_PATCHES_DIR:=$(realpath $(LINUX_TRACE_MAIN_DIR)/External/Patches)

# libtraceevent
EXTERNAL_LIBTRACEEVENT_PATCH_PATH:=$(realpath $(LINUX_TRACE_PATCHES_DIR)/libtraceevent.patch)
EXTERNAL_LIBTRACEEVENT_DIR:=$(realpath $(LINUX_TRACE_MAIN_DIR)/External/libtraceevent)
EXTERNAL_LIBTRACEEVENT_INCLUDE_DIR:=$(realpath $(EXTERNAL_LIBTRACEEVENT_DIR)/include)
EXTERNAL_LIBTRACEEVENT_BUILD_DIR:=$(abspath $(LINUX_TRACE_BUILD_DIR)/libtraceevent)
EXTERNAL_LIBTRACEEVENT_DEST_DIR:=$(abspath $(LINUX_TRACE_OUT_BIN_DIR)/libtraceevent)
EXTERNAL_LIBTRACEEVENT_LIB_DIR:=$(abspath $(EXTERNAL_LIBTRACEEVENT_DEST_DIR)/usr/local/lib64/)
EXTERNAL_LIBTRACEEVENT_PKGCONFIG_DIR:=$(abspath $(EXTERNAL_LIBTRACEEVENT_DEST_DIR)/usr/local/lib/x86_64-linux-gnu/pkgconfig)

EXTERNAL_LIBTRACEEVENT_OPTIONS:=
EXTERNAL_LIBTRACEEVENT_OPTIONS+= O=$(EXTERNAL_LIBTRACEEVENT_BUILD_DIR)
EXTERNAL_LIBTRACEEVENT_OPTIONS+= DESTDIR=$(EXTERNAL_LIBTRACEEVENT_DEST_DIR)

# Libtracefs
EXTERNAL_LIBTRACEFS_PATCH_PATH:=$(realpath $(LINUX_TRACE_PATCHES_DIR)/libtracefs.patch)
EXTERNAL_LIBTRACEFS_DIR:=$(realpath $(LINUX_TRACE_MAIN_DIR)/External/libtracefs)
EXTERNAL_LIBTRACEFS_INCLUDE_DIR:=$(realpath $(EXTERNAL_LIBTRACEFS_DIR)/include)
EXTERNAL_LIBTRACEFS_BUILD_DIR:=$(abspath $(LINUX_TRACE_BUILD_DIR)/libtracefs)
EXTERNAL_LIBTRACEFS_DEST_DIR:=$(abspath $(LINUX_TRACE_OUT_BIN_DIR)/libtracefs)
EXTERNAL_LIBTRACEFS_PKGCONFIG_DIR:=$(abspath $(EXTERNAL_LIBTRACEFS_DEST_DIR)/usr/local/lib/x86_64-linux-gnu/pkgconfig)

EXTERNAL_LIBTRACEFS_OPTIONS:=

EXTERNAL_LIBTRACEFS_OPTIONS+= O=$(EXTERNAL_LIBTRACEFS_BUILD_DIR)
EXTERNAL_LIBTRACEFS_OPTIONS+= DESTDIR=$(EXTERNAL_LIBTRACEFS_DEST_DIR)

# trace-cmd
EXTERNAL_TRACECMD_PATCH_PATH:=$(realpath $(LINUX_TRACE_PATCHES_DIR)/trace-cmd.patch)
EXTERNAL_TRACECMD_DIR:=$(realpath $(LINUX_TRACE_MAIN_DIR)/External/trace-cmd)
EXTERNAL_TRACECMD_INCLUDE_DIR:=$(realpath $(EXTERNAL_TRACECMD_DIR)/include/)
EXTERNAL_TRACECMD_TRACECMD_INCLUDE_DIR:=$(realpath $(EXTERNAL_TRACECMD_DIR)/tracecmd/include/)
EXTERNAL_TRACECMD_LIB_INCLUDE_DIR:=$(realpath $(EXTERNAL_TRACECMD_DIR)/lib/trace-cmd/include/)
EXTERNAL_TRACECMD_BUILD_DIR:=$(abspath $(LINUX_TRACE_BUILD_DIR)/trace-cmd)
EXTERNAL_TRACECMD_DEST_DIR:=$(abspath $(LINUX_TRACE_OUT_BIN_DIR)/trace-cmd)

EXTERNAL_TRACECMD_OPTIONS:=
EXTERNAL_TRACECMD_OPTIONS+= O=$(EXTERNAL_TRACECMD_BUILD_DIR)
EXTERNAL_TRACECMD_OPTIONS+= DESTDIR=$(EXTERNAL_TRACECMD_DEST_DIR)


# Common
COMMON_CFLAGS:=-I$(SYSROOT_INCLUDE_DIR) -I$(EXTERNAL_LIBTRACEEVENT_INCLUDE_DIR)/traceevent -D_LARGEFILE64_SOURCE -D__USE_GNU --sysroot=$(SYS_ROOT)/aarch64-linux/
COMMON_LDFLAGS:=-L$(SYSROOT_LIBS_DIR) -L$(EXTERNAL_LIBTRACEEVENT_LIB_DIR) --sysroot=$(SYS_ROOT)/aarch64-linux/
COMMON_OPTIONS:=
COMMON_OPTIONS+= CROSS_COMPILE=$(CROSS_COMPILE)
COMMON_OPTIONS+= CC=$(CROSS_COMPILE)gcc
COMMON_OPTIONS+= AR=$(CROSS_COMPILE)ar
COMMON_OPTIONS+= EXTRA_CFLAGS="$(COMMON_CFLAGS)"
COMMON_OPTIONS+= LDFLAGS="$(COMMON_LDFLAGS)"

# Common and reflection in libtraceevent and libtracefs
EXTERNAL_LIBTRACEEVENT_OPTIONS+= $(COMMON_OPTIONS)
EXTERNAL_LIBTRACEFS_OPTIONS+= $(COMMON_OPTIONS)
EXTERNAL_TRACECMD_OPTIONS+= CROSS_COMPILE=$(CROSS_COMPILE)
EXTERNAL_TRACECMD_OPTIONS+= USER_INCLUDES="-I$(SYSROOT_INCLUDE_DIR) -I$(EXTERNAL_LIBTRACEEVENT_INCLUDE_DIR)/traceevent -I$(EXTERNAL_TRACECMD_LIB_INCLUDE_DIR)/private -I$(EXTERNAL_TRACECMD_INCLUDE_DIR) -I$(EXTERNAL_LIBTRACEFS_INCLUDE_DIR) -I$(EXTERNAL_TRACECMD_LIB_INCLUDE_DIR) -I$(EXTERNAL_TRACECMD_TRACECMD_INCLUDE_DIR) -I$(EXTERNAL_TRACECMD_INCLUDE_DIR)/trace-cmd -I$(LINUX_TRACE_BUILD_DIR)/tracecmd/include/"
EXTERNAL_TRACECMD_OPTIONS+= LDFLAGS="-L$(EXTERNAL_LIBTRACEEVENT_BUILD_DIR)/lib/ -L$(EXTERNAL_LIBTRACEFS_BUILD_DIR)/lib/ --sysroot=$(SYS_ROOT)/aarch64-linux/"
EXTERNAL_TRACECMD_OPTIONS+= CC=$(CROSS_COMPILE)gcc
EXTERNAL_TRACECMD_OPTIONS+= AR=$(CROSS_COMPILE)ar


default: all
.PHONY: default

__pre_libtraceevent:
	cd $(EXTERNAL_LIBTRACEEVENT_DIR) && git reset --hard HEAD && git apply $(EXTERNAL_LIBTRACEEVENT_PATCH_PATH)
.PHONY: __pre_libtraceevent

libtraceevent: __pre_libtraceevent
	@mkdir -p $(EXTERNAL_LIBTRACEEVENT_BUILD_DIR)
	@$(MAKE) -C $(EXTERNAL_LIBTRACEEVENT_DIR) \
		clean libtraceevent.a $(EXTERNAL_LIBTRACEEVENT_OPTIONS)

	@$(MAKE) -C $(EXTERNAL_LIBTRACEEVENT_DIR) \
		install_pkgconfig $(EXTERNAL_LIBTRACEEVENT_OPTIONS)
.PHONY: libtraceevent

__pre_libtracefs:
	cd $(EXTERNAL_LIBTRACEFS_DIR) && git reset --hard HEAD && git apply $(EXTERNAL_LIBTRACEFS_PATCH_PATH)
.PHONY: __pre_libtracefs

libtracefs: __pre_libtracefs
	@mkdir -p $(EXTERNAL_LIBTRACEFS_BUILD_DIR)
	@export PKG_CONFIG_PATH=$(EXTERNAL_LIBTRACEEVENT_PKGCONFIG_DIR):$$PKG_CONFIG_PATH && \
	$(MAKE) -C $(EXTERNAL_LIBTRACEFS_DIR) \
		clean libtracefs.a $(EXTERNAL_LIBTRACEFS_OPTIONS)
	
	@export PKG_CONFIG_PATH=$(EXTERNAL_LIBTRACEEVENT_PKGCONFIG_DIR):$$PKG_CONFIG_PATH && \
	$(MAKE) -C $(EXTERNAL_LIBTRACEFS_DIR) \
		install_pkgconfig $(EXTERNAL_LIBTRACEFS_OPTIONS)
.PHONY: libtracefs

__pre_trace-cmd:
	cd $(EXTERNAL_TRACECMD_DIR) && git reset --hard HEAD && git apply $(EXTERNAL_TRACECMD_PATCH_PATH)
.PHONY: __pre_trace-cmd

trace-cmd: __pre_trace-cmd
	@mkdir -p $(EXTERNAL_TRACECMD_BUILD_DIR)
	@export PKG_CONFIG_PATH=$(EXTERNAL_LIBTRACEEVENT_PKGCONFIG_DIR):$(EXTERNAL_LIBTRACEFS_PKGCONFIG_DIR):$$PKG_CONFIG_PATH && \
	$(MAKE) -C $(EXTERNAL_TRACECMD_DIR) \
		clean trace-cmd $(EXTERNAL_TRACECMD_OPTIONS)
.PHONY: trace-cmd

all:
	$(MAKE) libtraceevent
	$(MAKE) libtracefs
	$(MAKE) trace-cmd
.PHONY: all