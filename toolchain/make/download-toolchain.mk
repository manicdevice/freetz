include $(TOOLCHAIN_DIR)/make/kernel/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/libtool-host/libtool-host.mk
include $(TOOLCHAIN_DIR)/make/target/uclibc/uclibc.mk

ifeq ($(strip $(FREETZ_TOOLCHAIN_CCACHE)),y)
	CCACHE:=ccache-kernel ccache
endif

KERNEL_TOOLCHAIN_MD5:=$(call qstrip,$(FREETZ_DL_KERNEL_TOOLCHAIN_MD5))
KERNEL_TOOLCHAIN_VERSION:=$(call qstrip,$(FREETZ_DL_KERNEL_TOOLCHAIN_VERSION))
KERNEL_TOOLCHAIN_SUFFIX:=$(call qstrip,$(FREETZ_DL_TOOLCHAIN_SUFFIX))
KERNEL_TOOLCHAIN_SOURCE:=$(TARGET_ARCH)_gcc-$(KERNEL_TOOLCHAIN_GCC_VERSION)-freetz-$(KERNEL_TOOLCHAIN_VERSION)-$(KERNEL_TOOLCHAIN_SUFFIX).tar.lzma

TARGET_TOOLCHAIN_MD5:=$(call qstrip,$(FREETZ_DL_TARGET_TOOLCHAIN_MD5))
TARGET_TOOLCHAIN_VERSION:=$(call qstrip,$(FREETZ_DL_TARGET_TOOLCHAIN_VERSION))
TARGET_TOOLCHAIN_SUFFIX:=$(call qstrip,$(FREETZ_DL_TOOLCHAIN_SUFFIX))
TARGET_TOOLCHAIN_SOURCE:=$(TARGET_ARCH)_gcc-$(TARGET_TOOLCHAIN_GCC_VERSION)_uClibc-$(TARGET_TOOLCHAIN_UCLIBC_VERSION)-freetz-$(TARGET_TOOLCHAIN_VERSION)-$(TARGET_TOOLCHAIN_SUFFIX).tar.lzma

$(KERNEL_TOOLCHAIN_DIR):
	@mkdir -p $@

$(TARGET_TOOLCHAIN_DIR):
	@mkdir -p $@

$(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(KERNEL_TOOLCHAIN_SOURCE) $(FREETZ_DL_TOOLCHAIN_SITE) $(KERNEL_TOOLCHAIN_MD5)

$(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TARGET_TOOLCHAIN_SOURCE) $(FREETZ_DL_TOOLCHAIN_SITE) $(TARGET_TOOLCHAIN_MD5)

download-toolchain: $(KERNEL_CROSS_COMPILER) kernel-configured \
			$(TARGET_CROSS_COMPILER) target-toolchain-kernel-headers \
			$(TARGET_SPECIFIC_ROOT_DIR)/lib/libc.so.0 \
			$(CCACHE) $(STDCXXLIB) $(TARGET_CXX_CROSS_COMPILER_SYMLINK_TIMESTAMP) libtool-host $(if $(FREETZ_PACKAGE_GDB_HOST),gdbhost)

gcc-kernel: $(KERNEL_CROSS_COMPILER)
$(KERNEL_CROSS_COMPILER): $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) | \
		$(KERNEL_TOOLCHAIN_SYMLINK_DOT_FILE) $(TOOLS_DIR)/busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	$(RM) -r $(TOOLCHAIN_BUILD_DIR)/$(KERNEL_TOOLCHAIN_COMPILER)
	$(TOOLS_DIR)/busybox tar $(VERBOSE) -xf $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	@touch $@

gcc: $(TARGET_CROSS_COMPILER)
$(TARGET_CROSS_COMPILER): $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) | \
		$(TARGET_TOOLCHAIN_SYMLINK_DOT_FILE) $(TOOLS_DIR)/busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	$(RM) -r $(TOOLCHAIN_BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)
	$(TOOLS_DIR)/busybox tar $(VERBOSE) -xf $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	@touch $@

download-toolchain-clean:

download-toolchain-dirclean: kernel-toolchain-dirclean target-toolchain-dirclean

download-toolchain-distclean: kernel-toolchain-distclean target-toolchain-distclean

kernel-toolchain-dirclean:

target-toolchain-dirclean:

.PHONY: gcc-kernel gcc
