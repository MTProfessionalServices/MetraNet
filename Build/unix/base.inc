###########################################################################
### Unix SDK Makefile (Build System: base) V1.0				###
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


### Build system include:

include $(BUILD_CONFIG).inc

### Commonly used paths.

LIBDIR = $(BUILD_ROOT)/lib/$(BUILD_CONFIG)
DEPDIR = $(BUILD_ROOT)/depend
INCDIR = $(BUILD_ROOT)/include
SAMPLESDIR = $(BUILD_ROOT)/SDK/samples
INSTALLDIR = $(BUILD_ROOT)/MetraConnect
