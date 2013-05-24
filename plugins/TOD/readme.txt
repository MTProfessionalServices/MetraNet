

Steps to created Time Of Day:

Insert New ATL Object...
Simple Object
Free Threaded.  ISupportsErrorInfo

added pipeline\include, propset directories to MIDL step
added pipeline\include, propset outdir directories to preprocessor 

import MTProcessor
implement IMTPipelineProcessor

add processors methods to header
add processor methods to .cpp
enable exception handling

#include <MTProcessor_i.c> in TOD.cpp