#
# core makefile
#
# billo 09-jul-1998

SUBDIRS = error \
	  base64 \
	  xml \
	  msix \
	  netstream \
	  unixnet \
          futil \
          sha \
          compress \
          MTUtil \
          xmlconfig \
          ConfigReaders

include $(BUILD_ROOT)/Build/unix/base.mak

default: subdirs_all

clean: subdirs_clean

include $(BUILD_ROOT)/Build/unix/subdirs.mak


