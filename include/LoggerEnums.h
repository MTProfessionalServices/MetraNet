/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LISCENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 ***************************************************************************/

#ifndef __LOGGERENUMS_H
#define __LOGGERENUMS_H

typedef enum 
{
  __LOG_TAG_BEGIN = -1, // begin guard
  LOG_OFF = 0,
  LOG_FATAL = 1,
  LOG_ERROR = 2,
  LOG_WARNING = 3,
  LOG_INFO = 4,
  LOG_DEBUG = 5,
  LOG_TRACE = 6,
  __LOG_TAG_END = 7, // end guard
} MTLogLevel;

typedef enum 
{
  FILE_LOG,
  EVENT_LOG,
  FILE_AND_EVENT_LOG
} MTLoggingLocation ;

typedef enum 
{
  ROLLOVER_NEVER,
  ROLLOVER_DAILY,
  ROLLOVER_WEEKLY,
  ROLLOVER_MONTHLY
} MTLogRollover ;

typedef enum 
{
  LOGGING_OFF,
  LOGGING_ON
} MTLoggingState ;

#endif // __LOGGERENUMS_H
