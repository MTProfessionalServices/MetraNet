include $(BUILD_ROOT)/Build/unix/paths.mak
include $(BUILD_ROOT)/Build/unix/$(BUILD_CONFIG).mak

CXX = CC
INCLUDES = -I. -I../../include -I../include
CFLAGS=-ptr$(BUILD_ROOT)/lib/sun4os5/Templates.DB -g -DUNIX -instances=extern -ptr$(LIBDIR) -KPIC -DDEBUG -verbose=template 
#CFLAGS=-g -DUNIX -instances=static -ptr$(LIBDIR) -KPIC -DDEBUG -verbose=template 

OBJECTS = autosdk.o

RWLIB =  -L$(RWLIBDIR) -l$(RWLIBNAME)

LIBS =  -L. -L${BUILD_ROOT}/lib/sun4os5  $(MTLIBS) -L/opt/SUNWspro/SC4.2/lib \
         -lautosdklib -lxmlconfig -lconfigreaders -lmtsdk -lxml -lmtutil -lthreadtest \
	-lcurses  -lsocket -lnsl $(RWLIB) \
	-lthread -ldl -lC

default all: autosdk

autosdk.o: autosdk.cpp
	$(CXX) $(CFLAGS) $(INCLUDES) -c -o $@ $<

autosdk: $(OBJECTS) $(BUILD_ROOT)/lib/$(BUILD_CONFIG)/libmtsdk.a
	CC -g -ptv -ptr$(LIBDIR) -xildoff -o autosdk $(OBJECTS) \
	$(LIBS)

clean: 
	rm -f autosdk.o autosdk

