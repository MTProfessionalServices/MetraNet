CXX = CC
INCLUDES = -I../include
CFLAGS=-g -DUNIX 

OBJECTS = localmodesample.o

default all: localmodesample

LIBS =  -lsocket -lnsl -lthread -L../lib -lmtsdk 

localmodesample.o: localmodesample.cpp
	$(CXX) $(CFLAGS) $(INCLUDES) -c -o localmodesample.o localmodesample.cpp

localmodesample: $(OBJECTS) 
	CC -g -xildoff -o localmodesample $(OBJECTS) $(LIBS)

clean: 
	rm -f localmodesample.o localmodesample

