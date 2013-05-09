#############################################################
#Generated on Mon Apr 16 9:18:27 2001
#############################################################


RELATIVEDIR := Core\DataAccess\MTODBCUtils\test

SRC := test.cpp BcpViewWriter.cpp ColumnArrayWriter.cpp

INCLUDEDIRS := $(SRCROOT)\Core\DataAccess\MTODBC \
	$(SRCROOT)\Core\DataAccess\MTODBCUtils \
	$(SRCROOT)\Shared\ServerAccess\MTServerAccess \
	$(OUTPUTROOT)\Shared\ServerAccess\MTServerAccess \


MIDL_INCLUDEDIRS := 

DEFINES := 

EXTRA_LIBS :=   MTODBC.lib MTODBCUtils.lib ProductView.lib dbobjects.lib error.lib mtcomerr.lib mtsl.lib propids.lib \
	dbaccess.lib ntlogger.lib configreaders.lib msix.lib \
	xml.lib msixdefcollection.lib codelookup.lib mtutil.lib \
	dynamictable.lib sharedsess.lib \
	mtdec.lib mtdecimalval.lib base64.lib


EXTRA_SYS_LIBS := odbc32.lib odbcbcp.lib xolehlp.lib 

EXENAME := testmtodbc

OVERRIDE_UNICODE_CPP_FLAGS :=

AUTO_BINARY_VERSION := 0

TEST_UTILITY := 1
