CXX = CC
INCLUDES = -I../include
CFLAGS=-g -DUNIX

OBJECTS = simple.o

default all: simple

LIBS =  -lsocket -lnsl -lthread -L../lib -lmtsdk 

simple.o: simple.cpp	
	$(CXX) $(CFLAGS) $(INCLUDES) -c -o simple.o simple.cpp

simple: $(OBJECTS) 
	CC -g -xildoff -o simple $(OBJECTS) $(LIBS)

clean: 
	rm -f simple.o simple



