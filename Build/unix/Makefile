###########################################################################
### Unix SDK Makefile V1.1						###
###									###
### If you make changes increment the version number by x.1 and add	###
### your name to the list of editors below, labeling with a date and a  ###
### description of any changes you made.				###
###									###
###									###
### Editors:								###
###  07/13/2000	Robert Gebhardt						###
###	Created the make file.						###
###  08/18/2000 Robert Gebhardt						###
###	Finished update for SDK w/ STL.					###
###									###
###########################################################################

# This make file automatically generates rules for each of the library
# objects. This way, the make file should only build the files that
# have been changed. (As opposed to using pattern rules.)

### Make variables:

include base.inc

# VPATH allows make to search these directories for a missing
# dependency.

### core files:

VPATH :=          $(BUILD_ROOT)/Core/base64
VPATH := $(VPATH):$(BUILD_ROOT)/Core/compress
VPATH := $(VPATH):$(BUILD_ROOT)/Core/ConfigReaders
VPATH := $(VPATH):$(BUILD_ROOT)/Core/error
VPATH := $(VPATH):$(BUILD_ROOT)/Core/futil
VPATH := $(VPATH):$(BUILD_ROOT)/Core/msix
VPATH := $(VPATH):$(BUILD_ROOT)/Core/MTUtil
VPATH := $(VPATH):$(BUILD_ROOT)/Core/MTDecimalVal
VPATH := $(VPATH):$(BUILD_ROOT)/Core/netstream
VPATH := $(VPATH):$(BUILD_ROOT)/Core/sha
VPATH := $(VPATH):$(BUILD_ROOT)/Core/unixnet
VPATH := $(VPATH):$(BUILD_ROOT)/Core/xml
VPATH := $(VPATH):$(BUILD_ROOT)/Core/xmlconfig

### SDK files:

VPATH := $(VPATH):$(BUILD_ROOT)/SDK/meterapi
VPATH := $(VPATH):$(BUILD_ROOT)/SDK/msixapi
VPATH := $(VPATH):$(BUILD_ROOT)/SDK/localmode
VPATH := $(VPATH):$(BUILD_ROOT)/SDK/DataImportingSDK
VPATH := $(VPATH):$(BUILD_ROOT)/Msg

### Thirdparty files:

VPATH := $(VPATH):$(BUILD_ROOT)/Thirdparty/xmltok
VPATH := $(VPATH):$(BUILD_ROOT)/Thirdparty/md5

### samples:

VPATH := $(VPATH):$(SAMPLESDIR)/simple
VPATH := $(VPATH):$(SAMPLESDIR)/batch
VPATH := $(VPATH):$(SAMPLESDIR)/Compound
VPATH := $(VPATH):$(SAMPLESDIR)/localmode
VPATH := $(VPATH):$(SAMPLESDIR)/sessionset

### generated objects

VPATH := $(VPATH):$(LIBDIR)

libcsources := hashtable.c xmlparse.c xmlrole.c xmltok.c mtsocket.c uxfutil.c
libcxxsources := $(libcxxsources) base64.cpp mtmsg.cpp sdkcon.cpp msixapi.cpp
libcxxsources := $(libcxxsources) XMLParser.cpp md5c.cpp
libcxxsources := $(libcxxsources) errobj.cpp MSIXParser.cpp msix.cpp mtlocalmode.cpp
libcxxsources := $(libcxxsources) netstream.cpp unixnet.cpp MSIXHash.cpp
libcxxsources := $(libcxxsources) xmlconfig.cpp mtsha.cpp ISOTime.cpp
libcxxsources := $(libcxxsources) ConvertString.cpp MTConvertTime.cpp
libcxxsources := $(libcxxsources) MTDecimalVal.cpp mtmeterstore.cpp
libcxxsources := $(libcxxsources) MTTypeConvert.cpp mttime.cpp
# libcxxsources := $(libcxxsources) stdutils.cpp
libobjects := $(libcsources:.c=.o) $(libcxxsources:.cpp=.o)
depends = $(addprefix $(DEPDIR)/, $(libobjects:.o=.d))
samples := simple compound localmodesample sessionset batch

### Included make files:

.DEFAULT: all

### Command targets:

.PHONY: all clean depend-clean samples-clean lib-clean library samples install
all: library samples 
library: $(INCDIR)/mtmsgdefs.h $(INCDIR)/sdk_msg.h $(LIBDIR)/libmtsdk.a 
samples: $(samples)

$(BUILD_ROOT)/lib/$(BUILD_CONFIG):
	mkdir -p $@

$(DEPDIR):
	mkdir -p $@

builddirs: $(BUILD_ROOT)/depend $(BUILD_ROOT)/bin/$(BUILD_CONFIG) $(BUILD_ROOT)/lib/$(BUILD_CONFIG)
	mkdir -p $?

lib-clean: depend-clean
	@$(PRINT) "Cleaning library...\\n"
	$(RM) $(LIBDIR)/*.o
	$(RM) $(LIBDIR)/libmtsdk.a
	@$(PRINT) "Cleaning done.\\n"

depend-clean:
	@$(PRINT) "Cleaning dependencies...\\n"
	$(RM) $(DEPDIR)/*.d
	@$(PRINT) "Cleaning done.\\n"

samples-clean:
	@$(PRINT) "Cleaning samples...\\n"
	$(RM) $(SAMPLESDIR)/simple/simple
	$(RM) $(SAMPLESDIR)/Compound/compound
	$(RM) $(SAMPLESDIR)/localmodesample/localmodesample
	$(RM) $(SAMPLESDIR)/sessionset/sessionset
	$(RM) $(SAMPLESDIR)/DataImportingSDK/TestServiceMeter/TestServiceMeter
	$(RM) $(SAMPLESDIR)/DataImportingSDK/TestServicePreprocess/TestServicePreprocess
	$(RM) $(SAMPLESDIR)/batch/batch
	@$(PRINT) "Cleaning done.\\n"

# Clean everything.
clean:
	@$(PRINT) "Cleaning...\\n"
	$(RM) $(INCDIR)/mtmsgdefs.h
	$(RM) $(INCDIR)/sdk_msg.h
	$(RM) $(LIBDIR)/*.o
	$(RM) $(LIBDIR)/libmtsdk.a
	$(RM) $(DEPDIR)/*.d
	$(RM) $(SAMPLESDIR)/simple/simple
	$(RM) $(SAMPLESDIR)/Compound/compound
	$(RM) $(SAMPLESDIR)/localmodesample/localmodesample
	$(RM) $(SAMPLESDIR)/sessionset/sesssionset
	$(RM) $(SAMPLESDIR)/DataImportingSDK/TestServiceMeter/TestServiceMeter
	$(RM) $(SAMPLESDIR)/DataImportingSDK/TestServicePreprocess/TestServicePreprocess
	$(RM) $(SAMPLESDIR)/batch/batch
	@$(PRINT) "Cleaning done.\\n"

### Individual targets for samples:

# The order of these libraries matter with the unix linker.

# ---- Commenting out these lines since we are switching back to the SUN compiler
#libs:= $(SSL_LIB_DIRS) -L/opt/sxl/lib
#libs:= $(libs) -L/usr/local/lib/gcc-lib/sparc-sun-solaris2.6/2.95.2 

# ---- And instead, adding only the SSL lib paths
libs:= $(SSL_LIB_DIRS)

libs:= $(libs) -L$(LIBDIR) -lmtsdk $(SSL_LIBS) -lsocket -lnsl
simple: simple.cpp $(LIBDIR)/libmtsdk.a
	$(CXX) $(CXXFLAGS) -o $(dir $<)simple $< $(libs)
batch: batch.cpp $(LIBDIR)/libmtsdk.a
	$(CXX) $(CXXFLAGS) -o $(dir $<)batch $< $(libs)
compound: compound.cpp $(LIBDIR)/libmtsdk.a
	$(CXX) $(CXXFLAGS) -o $(dir $<)compound $< $(libs)
localmodesample: localmodesample.cpp
	$(CXX) $(CXXFLAGS) -o $(dir $^)localmodesample $^ $(libs)
sessionset: sessionset.cpp $(LIBDIR)/libmtsdk.a
	$(CXX) $(CXXFLAGS) -o $(dir $<)sessionset $< $(libs)
TestServiceMeter: TestServiceMeter.cpp
	$(CXX) $(CXXFLAGS) -o $(dir $^)TestServiceMeter $^ $(libs) -lmtsdk
TestServicePreprocess: TestServicePreprocess.cpp
	$(CXX) $(CXXFLAGS) -o $(dir $^)TestServicePreprocess $^ $(libs)
parsemeter: parsemeter.cpp
	$(CXX) $(CXXFLAGS) -o $(dir $^)parsemeter $^ $(libs)
parsepreprocess: parsepreprocess.cpp
	$(CXX) $(CXXFLAGS) -o $(dir $^)parsepreprocess $^ $(libs) -lmtsdk

##
## INSTALL
##

# This could use cleaning up.  But it's a decent start.

INSTALLDIRS = $(INSTALLDIR)/lib $(INSTALLDIR)/include $(INSTALLDIR)/samples

$(INSTALLDIRS):
	mkdir -p $@

install: all $(INSTALLDIRS)
	## Library.
	cp $(BUILD_ROOT)/lib/$(BUILD_CONFIG)/libmtsdk.a $(INSTALLDIR)/lib
	## Includes.
	cp $(BUILD_ROOT)/SDK/include/mtsdk.h $(INSTALLDIR)/include
	cp $(BUILD_ROOT)/include/sdk_msg.h $(INSTALLDIR)/include
	cp $(BUILD_ROOT)/include/mtmsgdefs.h $(INSTALLDIR)/include
	cp $(BUILD_ROOT)/SDK/include/mtmeterutils.h $(INSTALLDIR)/include
	## Sample Source Code.
	cp $(SAMPLESDIR)/makefile $(INSTALLDIR)/samples
	cp $(SAMPLESDIR)/simple/simple.cpp $(INSTALLDIR)/samples
	cp $(SAMPLESDIR)/sessionset/sessionset.cpp $(INSTALLDIR)/samples

### Special dependency rules:

# The sdk library itself, for now it is a large archive
# library. Ideally, we need this to be a shared object library,
# but we need all of the libraries we use to build this to be of
# the same format.

# Although RW is removed from usage in the SDK, the some
# files still include RW headers (ones that provide functionality
# outside the sdk in NT). This means that some RW symbols still
# appear in this library. This doesn't mean that samples need to
# link with the RW library.
$(LIBDIR)/libmtsdk.a:	$(libobjects) $(BUILD_ROOT)/lib/$(BUILD_CONFIG)
	@echo $(libobjects)
	$(CXXAR) $@ $^

# $(LIBDIR)/*.o

# The output of this awk script is redirected to /dev/null in order
# to not affect any error detection schemes in use. Normally the awk
# script prints output to the screen, in the case of this file, there
# are strings that deal with errors.
$(INCDIR)/mtmsgdefs.h:	$(BUILD_ROOT)/Msg/sdk.mc1 \
			$(BUILD_ROOT)/Msg/sdkheader.awk
	@$(PRINT) "Making include:\\t$(notdir $@)\\n"
	@$(AWK) -f $(BUILD_ROOT)/Msg/sdkheader.awk $(BUILD_ROOT)/Msg/sdk.mc1 \
		> /dev/null;
	@$(MV) mtmsgdefs.h $(INCDIR)/mtmsgdefs.h;
	@$(MV) sdk_msg.c $(INCDIR)/sdk_msg.c
	@$(PRINT) "Making include:\\t\\t\\t\\tDone.\\n"

$(INCDIR)/sdk_msg.h: $(BUILD_ROOT)/Msg/unix_sdk_msg.h
	@$(PRINT) "Making include:\\t$(notdir $@)\\n"
	@$(CP) $(BUILD_ROOT)/Msg/unix_sdk_msg.h $(INCDIR)/sdk_msg.h
	@$(PRINT) "Making include:\\t\\t\\t\\tDone.\\n"

### Implicit rules:

# When the dependencies aren't build yet, we need a rule to
# bootstrap the new rules.
$(DEPDIR)/%.d: %.c $(INCDIR)/mtmsgdefs.h $(INCDIR)/sdk_msg.h $(DEPDIR)
	$(make-C-depend)
$(DEPDIR)/%.d: %.cpp $(INCDIR)/mtmsgdefs.h $(INCDIR)/sdk_msg.h $(DEPDIR)
	$(make-CXX-depend)

### Canned sequences:

# Use this option when running build as a cron job, as
# it is much easier to to a simple redirection of stderror.

define make-C-object
$(CC) -c $(CFLAGS) $< -o $@
endef

define make-CXX-object
$(CXX) -c $(CXXFLAGS) $< -o $@
endef

define make-C-depend
$(CC-DEP) $(CPPFLAGS) $(CFLAGS) $< > $@
endef

define make-CXX-depend
$(CC-DEP) $(CPPFLAGS) $(CXXFLAGS) $< > $@
endef

include $(depends)






