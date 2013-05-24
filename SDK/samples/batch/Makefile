CXX = CC
INCLUDES = -I../../include -I../../../include
CFLAGS=-g -DUNIX

OBJECTS = batch.o

default all: batch

LIBS =  -L../../../lib/sun4os5 -lmtsdk -lsocket -lnsl -lthread

batch.o: batch.cpp	
	$(CXX) $(CFLAGS) $(INCLUDES) -c -o batch.o batch.cpp

batch: $(OBJECTS) 
	CC -g -xildoff -o batch $(OBJECTS) $(LIBS)

clean: 
	rm -f batch.o batch
