#############################################################
#Wed Aug  9 14:21:47  2000
#############################################################


RELATIVEDIR := SDK\pluginSDK

#
# Rule to build all
#

$(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\.pluginSDKBuilt: $(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\.StaticLibs \
	$(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\.HeaderCopy
	@touch $(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\.pluginSDKBuilt


#
# Rule to build the headers
#

$(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\.HeaderCopy: $(MTOUTDIR)\$(OUTPUTTYPE)\include/MTConfig.h \
	$(MTOUTDIR)\$(OUTPUTTYPE)\include/MTConfigProp.h \
	$(MTOUTDIR)\$(OUTPUTTYPE)\include/MTConfigPropSet.h \
	$(MTOUTDIR)\$(OUTPUTTYPE)\include/MTSession.h \
	$(MTOUTDIR)\$(OUTPUTTYPE)\include/MTSessionProp.h \
	$(MTOUTDIR)\$(OUTPUTTYPE)\include/MTSessionPropType.h \
	$(MTOUTDIR)\$(OUTPUTTYPE)\include/MTSessionSet.h \
	$(MTOUTDIR)\$(OUTPUTTYPE)\include/PropValType.h \
	$(MTOUTDIR)\$(OUTPUTTYPE)\include/MTPipelinePlugIn.h \
	$(MTOUTDIR)\$(OUTPUTTYPE)\include/MTPipelinePlugIn_i.c \
	$(MTOUTDIR)\$(OUTPUTTYPE)\include/MTPipelineLib.tlb \
	$(ROOTDIR)\include/ComSkeleton.h \
	$(ROOTDIR)\include/SetIterate.h \
	$(PLUGINS_INCLUDE)/PlugInSkeleton.h
	$(CP) $^ $(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK
	@xcopy /s /q $(SRCDIR) $(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK
	@touch $(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\.HeaderCopy

#
# Rule to build the static libs
#

$(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\.StaticLibs: $(LIBDIR)/error.lib \
	$(LIBDIR)/mtcomerr.lib \
	$(LIBDIR)/skeleton.lib \
	$(LIBDIR)/$(RW_TOOLS_LIB)
	$(MKDIR) $(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\StaticLibs\$(OUTPUTTYPE)
	$(CP) $^ $(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\StaticLibs\$(OUTPUTTYPE)
	@touch $(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\.StaticLibs



LOCAL_TARGETS +=  $(MTOUTDIR)\$(OUTPUTTYPE)\SDK\pluginSDK\.pluginSDKBuilt

TEST_UTILITY := 1
