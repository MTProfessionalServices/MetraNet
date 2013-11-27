include $(BUILD_ROOT)/Build/unix/paths.mak
include $(BUILD_ROOT)/Build/unix/$(BUILD_CONFIG).mak

CXX = CC
INCLUDES = -I. -I../../include -I../include -I/usr/local/ssl/include
CFLAGS=-g -DUNIX -instances=extern -ptr$(LIBDIR) -KPIC -DDEBUG -verbose=template 

OBJECTS = localmodetest.o

RWLIB =  -L$(RWLIBDIR) -l$(RWLIBNAME)

default all: localmodetest

localmodetest.o: test.cpp
	$(CXX) $(CFLAGS) $(INCLUDES) -c -o $@ $<

localmodetest: $(OBJECTS) $(BUILD_ROOT)/lib/$(BUILD_CONFIG)/libmtsdk.a
	CC -g -ptv -ptr$(LIBDIR) -xildoff -o localmodetest $(OBJECTS) -L. -L${BUILD_ROOT}/lib/sun4os5  $(MTLIBS) -L/opt/SUNWspro/SC4.2/lib  -lxmlconfig -lconfigreaders -lmtsdk -lcurses  -lsocket -lnsl $(RWLIB) -lthread -ldl -lC 

clean: 
	rm localmodetest.o localmodetest



