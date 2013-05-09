/**************************************************************************
 * @doc 
 * 
 * @module |
 *
 * This class is used to notify the administrator of critical errors
 * 
 * Copyright 1998, 1999 by MetraTech
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
 * @index | 
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <MTNotification.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>

// import the config loader ...
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

#import <cdonts.dll>

//
//	@mfunc
//	Constructor. Initialize the data members.
//  @rdesc 
//  No return value.
// 
MTNotification::MTNotification()
: mIsInitialized(FALSE), mState(FALSE)
{
}

//
//	@mfunc
//	Destructor.
//  @rdesc 
//  No return value
// 
MTNotification::~MTNotification()
{
  
}

//
//	@mfunc
//	@parm 
//  @rdesc 
//  Returns TRUE on successful initialization. Otherwise, FALSE is returned.
// 
BOOL MTNotification::Init()
{
  // local variables ...
  _bstr_t configPath ;
  _bstr_t state ;

	// start the try to catch _com_error ...
  try
  {
    // initialize the _com_ptr_t ...
    CONFIGLOADERLib::IMTConfigLoaderPtr configLoader("MetraTech.MTConfigLoader.1");

    // initialize the configLoader ...
    configLoader->Init() ;

    configPath = "Notification" ;
    CONFIGLOADERLib::IMTConfigPropSetPtr confSet = 
      configLoader->GetEffectiveFile((char*)configPath, 
      NOTIFICATION_FILE);

    // read in the notification configuration information ...
    CONFIGLOADERLib::IMTConfigPropSetPtr subset = confSet->NextSetWithName("email_config");
    
    // get the source and destination out of the config file ...
    mSource = subset->NextStringWithName("email_source") ;
    mDest = subset->NextStringWithName("email_destination");
    state = subset->NextStringWithName("state");

    // set the mState data member to the appropriate thing ...
    if ((state == (_bstr_t)"on") || (state == (_bstr_t)"ON"))
    {
      mState = TRUE ;
    }
    else
    {
      mState = FALSE ;
    }
    // set the initialized flag ...
    mIsInitialized = TRUE ;
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "MTNotification::Init");
    return FALSE ;
  }

  return TRUE;
}

//
//	@mfunc
//	@parm 
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
// 
BOOL MTNotification::SendEmail(const char *apSubject, const char *apData)
{
  // local variables ...
  _bstr_t subject ;
  _bstr_t body ;

  // if we are not initialized ... return FALSE ...
  if (mIsInitialized == FALSE)
  {
    return FALSE ;
  }
  // if the state is off ... return TRUE ...
  if (mState == FALSE)
  {
    return TRUE;
  }
  // start the try ...
  try
  {
    // initialize the _com_ptr_t ...
    CDONTS::INewMailPtr emailSender("CDONTS.Newmail");

    // copy the parameters ...
    subject = apSubject ;
    body = apData ; 

    // send the email ...
    emailSender->Send (mSource, mDest, subject, body) ;
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "MTNotification::SendEmail");
    return FALSE ;
  }
  return TRUE ;
}

//
//	@mfunc
//	@parm 
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
// 
BOOL MTNotification::SendEmail(const wchar_t *apSubject, const wchar_t *apData)
{
  // local variables ...
  _bstr_t subject ;
  _bstr_t body ;

  // if we are not initialized ... return FALSE ...
  if (mIsInitialized == FALSE)
  {
    return FALSE ;
  }
  // if the state is off ... return TRUE ...
  if (mState == FALSE)
  {
    return TRUE;
  }
  // start the try ...
  try
  {
    // initialize the _com_ptr_t ...
    CDONTS::INewMailPtr emailSender("CDONTS.Newmail");

    // copy the parameters ...
    subject = apSubject ;
    body = apData ; 

    // send the email ...
    emailSender->Send (mSource, mDest, subject, body) ;
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "MTNotification::SendEmail");
    return FALSE ;
  }
  return TRUE ;
}
