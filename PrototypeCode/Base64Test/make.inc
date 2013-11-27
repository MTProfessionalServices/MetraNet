#############################################################
#Generated on Thu Jul  1 11:24:00 1999
#############################################################


RELATIVEDIR := Core\base64\test

SRC := test.cpp

INCLUDEDIRS := \
	$(OUTPUTROOT)\$(RELATIVEDIR)\.. \
	$(SRCROOT)\shared\NameID \
	$(OUTPUTROOT)\shared\NameID \
	$(OUTPUTROOT)\Core\Configuration\PropSet \
	$(SRCROOT)\Core\Configuration\PropSet

MIDL_INCLUDEDIRS := 

DEFINES := 

EXTRA_LIBS := \
    configreaders.lib \
    mtsl.lib \
    mtutil.lib \
    error.lib \
    mtcrypto.lib \
    securestore.lib \
    ntlogger.lib \
    base64.lib \
    mtdes.lib \
    des.lib

EXTRA_SYS_LIBS := 

EXENAME := base64test

OVERRIDE_UNICODE_CPP_FLAGS :=

TEST_UTILITY := 1
