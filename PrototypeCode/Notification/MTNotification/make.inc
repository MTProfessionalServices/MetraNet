#############################################################
#Generated on Thu Jul  1 11:24:39 1999
#############################################################


RELATIVEDIR := Core\Notification\MTNotification

SRC := MTNotification.cpp

INCLUDEDIRS := $(OUTPUTROOT)\$(RELATIVEDIR)\..\..\..\include $(OUTPUTROOT)\$(RELATIVEDIR)\..\..\..\bin

MIDL_INCLUDEDIRS := 

DEFINES := LOGGER_EXPORTING

EXTRA_LIBS := error.lib

EXTRA_SYS_LIBS := 

DLLNAME := mtnotification

OVERRIDE_UNICODE_CPP_FLAGS := 

$(SRCROOT)\$(RELATIVEDIR)/MTNotification.cpp: $(BINDIR)/cdonts.dll

TEST_UTILITY := 1
