#
# Builds Java SDK
#

BASEDIR = com/metratech/sdk/base
UTILSDIR = com/metratech/sdk/utils
SAMPLESDIR = com/metratech/sdk/samples
THIRDPARTYDIR = /src/Thirdparty/Java

CLASSPATH= .;$(BASEDIR);$(UTILSDIR);$(THIRDPARTYDIR);.\jcert.jar;.\jnet.jar;.\jsse.jar 

BASE = MSIXObject MSIXProperty MSIXPropertyList MSIXSessionStatus \
	MSIXStatus MSIXStatusCode MSIXString MSIXTimeStamp MSIXUID \
	MSIXValue MSIXWriter MTException MTFileConnection \
	MTHTTPConnection MTMeter MTMeterConnection MTMeterImpl \
	MTMeterMSIXSession MTMeterProperty MTMeterSession \
	MTMSIXMessage MTMSIXParser MTParseException \
	MTPropertyException MTSessionException

UTILS = ConsoleApp MTLogger

SAMPLES = CompoundMeter CompoundThread Failover LocalPlayback \
	LocalRecord SimpleMeter SynchronousMeter SSLMeter

FILES = $(addprefix $(BASEDIR)/, $(BASE)) \
	$(addprefix $(UTILSDIR)/, $(UTILS)) \
	$(addprefix $(SAMPLESDIR)/, $(SAMPLES))

SRCS = $(addsuffix .java, $(FILES))
OBJS = $(addsuffix .class, $(FILES))

all: $(OBJS)

%.class: %.java
	javac -g -classpath $(CLASSPATH) $<

clean:
	rm -f $(OBJS)

# dependencies
BASEOBJS = $(addprefix $(BASEDIR)/, $(addsuffix .class, $(BASE)))
SAMPLEOBJS = $(addprefix $(SAMPLESDIR)/, $(addsuffix .class, $(SAMPLES)))
$(SAMPLEOBJS): $(BASEOBJS)
