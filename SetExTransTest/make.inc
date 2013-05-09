RELATIVEDIR := Utils\SetExTrans\testextrans

SRC := testextrans.cpp

INCLUDEDIRS := $(SRCROOT)\Utils\SetExTrans	\
		$(OUTPUTROOT)\Utils\SetExTrans

EXTRA_LIBS := SetExTrans.lib  
               
EXENAME := extranstest

OVERRIDE_UNICODE_CPP_FLAGS := 1

AUTO_BINARY_VERSION := 0

TEST_UTILITY := 1