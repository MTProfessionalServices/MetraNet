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


#ifndef __NTEVENTMSG_H
#define __NTEVENTMSG_H

#include <NTEventArgs.h>

// @class NTEventMsg
class NTEventMsg
{
// @access Public:
public:
  // @cmember,menum The Windows NT event types.
  enum EventType 
  { 
    // @emem Informational event
    EVENT_INFO=1,
    // @emem Warning event
    EVENT_WARNING=2,
    // @emem Error event
    EVENT_ERROR=3 
  };
  // @cmember Constructor with a string
  NTEventMsg(EventType logLevel, const char *apString);
  // @cmember Constructor with an event id, arguments and possible raw data
  NTEventMsg(const DWORD aEventID, const NTEventArgs &arArgs, const DWORD aRawDataSize=0,
    void *apRawData=NULL) ;
  // @cmember Constructor with an event id and possible raw data
  NTEventMsg(const DWORD aEventID, const DWORD aRawDataSize=0, void *apRawData=NULL) ;
  // @cmember Destructor
  virtual ~NTEventMsg() ;

  // @cmember Get the severity for the event
  WORD GetSeverity() const ;
  // @cmember Get the event id
  DWORD GetEventId() const ;
  // @cmember Get the size of the raw data
  DWORD GetRawDataSize() const ;
  // @cmember Get a pointer to the raw data
  void *GetRawData() const ;
  // @cmember Get the arguments
  char **GetArgs() ;
  // @cmember Get the number of arguments
  WORD GetNumArgs() const ;
// @access Private:
private:
  // @cmember Default constructor. Don't allow consumers to use it.
  NTEventMsg() {} ;
  // @cmember Get the severity from the event id.
  void GetSeverityFromEventID() ; 

  // @cmember The event id
  DWORD         mEventId ;
  // @cmember The severity of the event
  WORD          mSeverity ;
  // @cmember The arguments for the event
  NTEventArgs    mArgs ;
  // @cmember The size of the raw data
  DWORD         mRawDataSize ;
  // @cmember The raw data to log
  void *        mpRawData ;
} ;

//
//	@mfunc
//	Get the severity for the event
//  @rdesc 
//  Returns the severity of the event.
// 
inline WORD NTEventMsg::GetSeverity() const
{
  return mSeverity ;
}

//
//	@mfunc
//	Get the event id
//  @rdesc 
//  Returns the event id
// 
inline DWORD NTEventMsg::GetEventId() const 
{
  return mEventId ;
}

//
//	@mfunc
//	Get the size of the raw data
//  @rdesc 
//  Returns the size of the raw data
// 
inline DWORD NTEventMsg::GetRawDataSize() const
{
  return mRawDataSize ;
}

//
//	@mfunc
//	Get the raw data
//  @rdesc 
//  Returns the raw data
// 
inline void *NTEventMsg::GetRawData() const
{
  return mpRawData ;
}

//
//	@mfunc
//	Get the number of arguments
//  @rdesc 
//  Returns the number of arguments.
// 
inline WORD NTEventMsg::GetNumArgs() const
{
  return mArgs.GetNumArgs() ;
}

//
//	@mfunc
//	Get the arguments
//  @rdesc 
//  Returns a pointer to the arguments
// 
inline char **NTEventMsg::GetArgs()  
{
  return mArgs.GetArgList() ;
}

//
//	@mfunc
//	Get the severity from the event id
//  @rdesc 
//  Returns the severity of the event
// 
inline void NTEventMsg::GetSeverityFromEventID() 
{
  // local variables ...
  DWORD nLocalSev ;

  // mask off the top two bits ... the high two bits indictae the severity ...
  nLocalSev = mEventId & 0xC0000000 ;
  mSeverity = (WORD) (nLocalSev >> 30) ;
}

#endif // __NTEVENTMSG_H

