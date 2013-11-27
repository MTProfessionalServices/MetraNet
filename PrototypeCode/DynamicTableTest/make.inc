
RELATIVEDIR := Shared\DynamicTable\test

SRC := \
	test.cpp

INCLUDEDIRS := \
	$(OUTPUTROOT)\Core\DataAccess\QueryAdapter

MIDL_INCLUDEDIRS := 

DEFINES := 

EXTRA_LIBS := mtsl.lib error.lib dynamictable.lib msixdefcollection.lib mtcomerr.lib \
	xmltok.lib xml.lib codelookup.lib ntlogger.lib dbaccess.lib \
	configreaders.lib msix.lib mtutil.lib

EXTRA_SYS_LIBS := 

EXENAME := dynamictabletest

OVERRIDE_UNICODE_CPP_FLAGS :=
TEST_UTILITY = 1