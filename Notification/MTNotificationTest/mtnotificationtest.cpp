/**************************************************************************
 * @doc 
 * 
 * @module 
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
 * @index | 
 ***************************************************************************/

#include <metra.h>
#include <stdio.h>
#include <iostream>
#include <MTNotification.h>
#include <mtglobal_msg.h>

using std::cout;
using std::endl;


extern "C" int wmain(int argc, wchar_t *argv[], wchar_t *env[])
{
  BOOL bRetCode=FALSE ;
  MTNotification notifyMe ;
  char myString[255] ;
  wchar_t myWString[255] ;

  bRetCode = notifyMe.Init() ;
  if (bRetCode == FALSE)
  {
    cout << "ERROR: unable to initialize notification object. Error = " <<  endl ;
    return 0 ;
  }
  for (int i=0; i < 10; i++)
  {
    // sending email message ...
    sprintf (myString, "Test email message #%d", i) ;
    bRetCode = notifyMe.SendEmail ("test mail", myString) ;
    if (bRetCode == FALSE)
    {
      cout << "ERROR: unable to send email. Error = " <<  endl ;
      return 0 ;
    }
    wsprintf (myWString, L"Test wide string email message #%d", i) ;
    bRetCode = notifyMe.SendEmail (L"test mail(wide string)", myWString) ;
    if (bRetCode == FALSE)
    {
      cout << "ERROR: unable to send email. Error = " <<  endl ;
      return 0 ;
    }
  }

  return 0 ;
}
