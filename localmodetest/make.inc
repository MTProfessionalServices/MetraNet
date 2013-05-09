#############################################################
#Generated on Wed Sep  1 11:10:03 1999
#############################################################


RELATIVEDIR := SDK\localmodetest

SRC := test.cpp

INCLUDEDIRS := $(PIPELINE_INCLUDE) $(SDK_INCLUDE)

MIDL_INCLUDEDIRS := 

DEFINES := 

EXTRA_LIBS := configreaders.lib error.lib  dbobjects.lib  \
	handler.lib  mtsl.lib  mtlocalmode.lib ntlogger.lib  \
	xmltok.lib  threadtest.lib xml.lib msix.lib \
        mtutil.lib mtdecimalval.lib xmlconfig.lib msixapi.lib netstream.lib \
        meterapi.lib win32net.lib base64.lib

EXTRA_SYS_LIBS := ws2_32.lib

EXENAME := localmodetest

OVERRIDE_UNICODE_CPP_FLAGS := 1

TEST_UTILITY = 1
