#############################################################
#Generated on Thu Jul  1 11:24:30 1999
#############################################################


RELATIVEDIR := AccountHierarchies\BatchHierarchy\test

SRC := BatchHierarchyTest.cpp

INCLUDEDIRS := $(SRCROOT)\Core\DataAccess\MTODBC $(SRCROOT)\Core\DataAccess\MTODBCUtils

MIDL_INCLUDEDIRS := 

DEFINES := 

EXTRA_LIBS :=  MTODBC.lib mtcomerr.lib MTODBCUtils.lib error.lib BatchHierarchy.lib

EXTRA_SYS_LIBS :=  odbcbcp.lib xolehlp.lib

EXENAME := BatchHierarchyTest

OVERRIDE_UNICODE_CPP_FLAGS := 1
TEST_UTILITY = 1