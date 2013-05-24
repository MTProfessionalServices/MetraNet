/**************************************************************************
 * @doc NTLOGMACROS
 * 
 * @module Logger class |
 *
 * This class is used to log data to the MetraTech file log or the Windows
 * NT based event log. 
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | NTLOGMACROS
 ***************************************************************************/

#ifndef __NTLOGMACROS_H
#define __NTLOGMACROS_H

// include files ...
#include <NTLogger.h>
#include <loggerinfo.h>

#ifdef _DEBUG
//
//	@mfunc
//	Log a debug message.
//
#define MT_LOG_DEBUG_STRING(apLogDir, apAppTag, apString)\
{ \
  NTLogger myLogger ;\
  LoggerConfigReader cfgRdr ; \
\
  myLogger.Init(cfgRdr.ReadConfiguration(apLogDir), apAppTag) ; \
  myLogger.LogThis (LOG_DEBUG, apString) ; \
}\

#else
// dummy macros for release
//
//	@mfunc
//	Log a debug message.
//
#define MT_LOG_DEBUG_STRING(apLogDir, apAppTag, apString)

#endif 

#ifdef _DEBUG
//
//	@mfunc
//	Log a info message.
//
#define MT_LOG_INFO_STRING(apLogDir, apAppTag, apString)\
{ \
  NTLogger myLogger ;\
  LoggerConfigReader cfgRdr ; \
\
  myLogger.Init(cfgRdr.ReadConfiguration(apLogDir), apAppTag) ; \
  myLogger.LogThis (LOG_INFO, apString) ; \
}\

#else
//
//	@mfunc
//	Log a info message.
//
#define MT_LOG_INFO_STRING(apLogDir, apAppTag, apString)

#endif


#ifdef _DEBUG
//
//	@mfunc
//	Log a debug message.
//
#define MT_LOG_DEBUG_WSTRING(apLogDir, apAppTag, apString)\
{ \
  NTLogger myLogger ;\
  LoggerConfigReader cfgRdr ; \
\
  myLogger.Init(cfgRdr.ReadConfiguration(apLogDir), apAppTag) ; \
  myLogger.LogThis (LOG_DEBUG, apString) ; \
}\

#else
//
//	@mfunc
//	Log a debug message.
//
#define MT_LOG_DEBUG_WSTRING(apLogDir, apAppTag, apString)

#endif

#ifdef _DEBUG
//
//	@mfunc
//	Log a info message.
//
#define MT_LOG_INFO_WSTRING(apLogDir, apAppTag, apString)\
{ \
  NTLogger myLogger ;\
  LoggerConfigReader cfgRdr ; \
\
  myLogger.Init(cfgRdr.ReadConfiguration(apLogDir), apAppTag) ; \
  myLogger.LogThis (LOG_INFO, apString) ; \
}\

#else
//
//	@mfunc
//	Log a info message.
//
#define MT_LOG_INFO_WSTRING(apLogDir, apAppTag, apString)

#endif

#ifdef MTTRACE
//
//	@mfunc
//	Log a debug message.
//
#define MT_LOG_TRACE_STRING(apLogDir, apAppTag, apString)\
{ \
  NTLogger myLogger ;\
  LoggerConfigReader cfgRdr ; \
\
  myLogger.Init(cfgRdr.ReadConfiguration(apLogDir), apAppTag) ; \
  myLogger.LogThis (LOG_TRACE, apString) ; \
}\

#else
// dummy macros for release
//
//	@mfunc
//	Log a debug message.
//
#define MT_LOG_TRACE_STRING(apLogDir, apAppTag, apString)

#endif 

#ifdef MTTRACE
//
//	@mfunc
//	Log a info message.
//
#define MT_LOG_TRACE_WSTRING(apLogDir, apAppTag, apString)\
{ \
  NTLogger myLogger ;\
  LoggerConfigReader cfgRdr ; \
\
  myLogger.Init(cfgRdr.ReadConfiguration(apLogDir), apAppTag) ; \
  myLogger.LogThis (LOG_TRACE, apString) ; \
}\

#else
//
//	@mfunc
//	Log a info message.
//
#define MT_LOG_TRACE_WSTRING(apLogDir, apAppTag, apString)

#endif

#ifdef _DEBUG
#define MT_LOG_FATAL_STRING(apLogDir, apAppTag, apString)\
{ \
	NTLogger myLogger ;\
	LoggerConfigReader cfgRdr ; \
\
	myLogger.Init(cfgRdr.ReadConfiguration(apLogDir), apAppTag) ; \
	myLogger.LogThis (LOG_FATAL, apString) ; \
}
#else
#define MT_LOG_FATAL_STRING(apLogDir, apAppTag, apString)
#endif

#endif // __NTLOGMACROS_H
