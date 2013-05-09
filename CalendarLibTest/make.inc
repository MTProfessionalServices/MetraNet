#############################################################
#Generated on Thu Jul  1 15:55:33 1999
#############################################################


RELATIVEDIR := Shared\CalendarLib\test

SRC := test.cpp

INCLUDEDIRS := $(OUTPUTROOT)\$(RELATIVEDIR)\..\..\..\core\configuration\calendar\MTCalendar \
	       $(OUTPUTROOT)\$(RELATIVEDIR)\..\..\..\include \
	$(OUTPUTROOT)\ProductCatalog\MTProductCatalog \
	$(SRCROOT)\ProductCatalog\MTProductCatalog


MIDL_INCLUDEDIRS := 

DEFINES := 

EXTRA_LIBS :=   calendarlib.lib  error.lib  mtsl.lib  ntlogger.lib  mtutil.lib zoneinfo.lib

EXTRA_SYS_LIBS := 

EXENAME := calendartest

OVERRIDE_UNICODE_CPP_FLAGS := 1
TEST_UTILITY = 1