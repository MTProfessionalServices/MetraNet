/**************************************************************************
 * @doc NTEVENTMSG
 * 
 * @module Windows NT Event Msg encapsulation |
 * 
 * This class encapsulates the data that is needed to send an event to
 * the Windows NT event log.
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
 * @index | NTEVENTMSG
 ***************************************************************************/

#include <metra.h>
#include <NTEventMsg.h>
#include <mtglobal_msg.h>

//
//	@mfunc
//	Constructor with a string.
//	@parm The string to be logged the event log.
//  @rdesc 
//  No return value.
//  @devnote
//  This constructor should be used when logging a string of data to the NT event
//  log.
// 
NTEventMsg::NTEventMsg(EventType logLevel, const char *apString)
: mpRawData(NULL), mRawDataSize(0), mSeverity(logLevel)
{
  // initialize the arguments ...
  if (apString != NULL)
  {
    mArgs.Add(apString) ;
  }
  // set the event id ...
  mEventId = CORE_ERR_LOG_MSG ;

}
//
//	@mfunc
//	Constructor with an event id, arguments to be substituted, size of the raw data, 
//  and the raw data. 
//	@parm The event to be logged.
//  @parm The arguments to be substituted.
//  @parmopt The size of the raw data to be logged.
//  @parmopt The raw data to be logged.
//  @rdesc 
//  No return value.
//  @devnote
//  This constructor should be used when an event with substitution strings is to be
//  logged. The raw data size and raw data are optional parameters.
// 
NTEventMsg::NTEventMsg(const DWORD aEventID, const NTEventArgs &arArgs, const DWORD aRawDataSize,
                       void *apRawData)
: mEventId(aEventID), mpRawData(apRawData), mRawDataSize(aRawDataSize), mSeverity(0), mArgs(arArgs)
{
  // get the severity from the EventID ...
  GetSeverityFromEventID() ;
}

//
//	@mfunc
//	Constructor with an event id, size of the raw data, and the raw data. 
//	@parm The event to be logged.
//  @parmopt The size of the raw data to be logged.
//  @parmopt The raw data to be logged.
//  @rdesc 
//  No return value.
//  @devnote
//  This constructor should be used when an event with no substitution strings is to be
//  logged. The raw data size and raw data are optional parameters.
// 
NTEventMsg::NTEventMsg(const DWORD aEventID, const DWORD aRawDataSize, void *apRawData)
: mEventId(aEventID), mpRawData(apRawData), mRawDataSize(aRawDataSize), mSeverity(0)
{
  // get the severity from the EventID ...
  GetSeverityFromEventID() ;
}

//
//	@mfunc
//	Destructor.
//  @rdesc 
//  No return value
// 
NTEventMsg::~NTEventMsg()
{
}

