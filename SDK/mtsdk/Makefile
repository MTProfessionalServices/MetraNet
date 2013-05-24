
DLLNAME = mtsdk

CXXOBJECTS = mtsdk.o

# The order of these libraries matters
EXTRA_LIBS = -lmsixapi \
	     -lmeterapi \
	     -lmsixapi \
	     -lunixnet \
	     -lmsix \
	     -lnetstream \
	     -lunixnet \
	     -lbase64 \
	     -lerrobj \
	     -lmtlocalmode \
	     -lmtcompress \
	     -L$(RWLIBDIR) \
	     -l$(RWLIBNAME)

default: hack  

# directories dll


hack: 
	chmod a+x ./mt_mash_libs_new
	./mt_mash_libs_new ${RWLIBDIR} ${RWLIBNAME} 

include $(BUILD_ROOT)/Build/unix/base.mak

include $(BUILD_ROOT)/Build/unix/dll.mak
