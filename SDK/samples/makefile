##
## Makefile for MetraConnect samples
##
ifndef METRACONNECT
$(error Environment variable METRACONNECT not defined)
endif
ifndef OPENSSL
$(error Environment variable OPENSSL not defined)
endif
#
CXX      = CC
CFLAGS   = -DUNIX
INCLUDES = -I$(METRACONNECT)/include 
LIBS     = -L$(METRACONNECT)/lib -L$(OPENSSL)/lib -lmtsdk -lssl -lcrypto -lsocket -lnsl

TARGETS  = simple sessionset

default all: $(TARGETS)

%: %.cpp	
	$(CXX) $(CFLAGS) $(INCLUDES) -o $(@) $(<) $(LIBS)

clean: 
	rm -f $(TARGETS)
