#
# msg makefile
#
# billo 13-jul-1998

LIBNAME = sdk_msg

OBJECTS = mtmsg.o 

LOCAL_CLEAN = $(INCDIR)/sdk_msg.h $(INCDIR)/mtmsgdefs.h  mtmsgdefs.h

include $(BUILD_ROOT)/Build/unix/base.mak

default: mtmsgdefs.h $(INCDIR)/sdk_msg.h $(INCDIR)/mtmsgdefs.h $(LIBRARY) 

$(INCDIR)/sdk_msg.h: unix_sdk_msg.h
	$(CP) $< $@

$(INCDIR)/mtmsgdefs.h: mtmsgdefs.h
	$(CP) $< $@

mtmsgdefs.h: sdk.mc1 sdkheader.awk
	$(AWK) -f sdkheader.awk < sdk.mc1

include $(BUILD_ROOT)/Build/unix/library.mak
