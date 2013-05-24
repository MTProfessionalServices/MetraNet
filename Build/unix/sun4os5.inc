###########################################################################
### Unix SDK Makefile (Build System: sun4os5) V1.0			###
###									###
### If you make changes increment the version number by x.1 and add	###
### your name to the list of editors below, labeling with a date and a  ###
### description of any changes you made.				###
###									###
###									###
### Editors:								###
###  07/13/2000	Robert Gebhardt						###
###	Created this include file.					###
###									###
###########################################################################


### Programs:

#This should be edited when the new make system is installed.
CXX = CC
CC = cc
#CC-DEP = gcc -MM
CC-DEP = CC -xM1
CPP = CC
LD = CC
AR = ar
CXXAR = CC -xar -o
AWK = nawk
SED = /usr/local/bin/sed
CAT = cat
YACC = bison
LEX = flex
SHELL = /bin/sh
MAKE = make
MKDIR = mkdir -p
CP = cp -f 
MV = mv -f
PRINT = printf

# RW Stuff that should be removed.
#RWLIBNAME = tls7s
#RWLIBDIR = /opt/spm/workspaces/SOLARIS26/SUNPRO42/7s/lib
#RWINCDIR = /opt/spm/workspaces/SOLARIS26/SUNPRO42/7s

# Dinkumware library.
#DWLIB = /opt/sxl/lib/sxl.a
#DWINCDIR = /opt/sxl/include

## This section controls whether OpenSSL or RSA SSL is built.
## Open SSL is the default

# OpenSSL
SSL_INCDIRS := -I/usr/local/ssl/include/openssl -I/usr/local/ssl/include
SSL_LIB_DIRS := -L/usr/local/ssl/lib
SSL_LIBS := -lssl -lcrypto
SSL_DEFS :=

# RSA SSL
# SSL_INCDIRS := -I/usr/local/sslc13/library/include
# SSL_LIB_DIRS := -L/usr/local/sslc13/library/lib
# SSL_LIBS := -lsslc
# SSL_DEFS := -DUSE_RSA_SSL

### Flags

INCFLAGS := $(SSL_INCDIRS) -I$(BUILD_ROOT)/Msg -I$(BUILD_ROOT)/include
INCFLAGS := $(INCFLAGS) -I$(BUILD_ROOT)/SDK/include

#CFLAGS := -g -fhonor-std -fno-builtin -fno-gnu-linker -DDEBUG -DUNIX $(SSL_DEFS) # GCC LINE
CFLAGS := -g -DDEBUG -DUNIX $(SSL_DEFS) # SunPro LINE
#CFLAGS := $(CFLAGS) -D_REENTRANT -I$(DWINCDIR) $(INCFLAGS) # GCC LINE
CFLAGS := $(CFLAGS) $(INCFLAGS) # SunPro LINE - note no 3rd party stl include

#CXXFLAGS := -g -fhonor-std -fno-builtin -fno-gnu-linker -DDEBUG -DUNIX $(SSL_DEFS)
CXXFLAGS := -g -DDEBUG -DUNIX $(SSL_DEFS)
#CXXFLAGS := $(CXXFLAGS) -D_REENTRANT -I$(DWINCDIR) $(INCFLAGS) # GCC LINE
CXXFLAGS := $(CXXFLAGS) $(INCFLAGS) # SunPro LINE - No 3rd party stl
