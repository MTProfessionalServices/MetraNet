RELATIVEDIR := Shared/lrucachetest

SRC := Test.cpp

INCLUDEDIRS := $(OUTPUTROOT)\Shared\namedpipe \

MIDL_INCLUDEDIRS := 
  

DEFINES := 

EXTRA_LIBS := rscache.lib error.lib mtdec.lib mtcomerr.lib mtutil.lib mtobserver.lib mtsl.lib namedpipe.lib ntlogger.lib
EXTRA_SYS_LIBS := 

EXENAME := lrucachetest

OVERRIDE_UNICODE_CPP_FLAGS := 

TEST_UTILITY := 1