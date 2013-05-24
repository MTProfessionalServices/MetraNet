CXX = CC
INCLUDES = -I../include
CFLAGS=-g -DUNIX 

OBJECTS = compound.o

default all: compound

compound.o: compound.cpp
	$(CXX) $(CFLAGS) $(INCLUDES) -c -o $@ $<

compound: $(OBJECTS) 
	$(CXX) -g -xildoff -o compound $(OBJECTS) -L. -L../lib -lmtsdk -lsocket -lnsl -lthread 

clean: 
	rm -f compound.o compound



