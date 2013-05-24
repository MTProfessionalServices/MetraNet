/**************************************************************************
 * @doc TEST
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Carl Shimer
 * $Header$
 ***************************************************************************/

#include <mtcom.h>
#include "test.h"
#include <mtprogids.h>



const char* aFile="e:\\dev\\development\\config\\Deployment\\hooks.xml";

static ComInitialize gComInitialize;

void MTGetHostName(char buff[],int size)
{
	WSADATA data;
	::WSAStartup(MAKEWORD(1, 0), &data);
  if(::gethostname(buff,size) != 0) {
    DWORD err;
    err = WSAGetLastError();
  }
  ::WSACleanup();
}


int main()
{
  char aRemoteHost[100];
  MTConfigLib::IMTConfigPtr aConfig(MTPROGID_CONFIG);
  MTConfigLib::IMTConfigPropPtr aConfigProp;
  MTConfigLib::IMTConfigPropSetPtr aHookSet;
  MTConfigLib::PropValType aPropValType;
  VARIANT_BOOL checksumMatch;

  MTGetHostName(aRemoteHost,100);
#if 0
  IMTConfigPropSetPtr aPropset = aConfig->ReadConfigurationFromHost(aRemoteHost,
    aFile,VARIANT_FALSE,&checksumMatch);

  IMTHookHandlerPtr aHookHandler(MTPROGID_HOOKHANDLER);
  aHookHandler->Read(aPropset.GetInterfacePtr());
  
  aHookHandler->ExecuteAll();
#else
  IMTConfigPropSetPtr aPropset = aConfig->ReadConfiguration(aFile,&checksumMatch);
     
  aConfigProp = aPropset->NextWithName("deployment_hooks");
  if (aConfigProp == NULL)
  {
    return FALSE;
  }
  aPropValType = aConfigProp->GetPropType();
  
  if(aPropValType == MTConfigLib::PROP_TYPE_SET)
  {
    aHookSet = aConfigProp->GetPropValue();

    IMTHookHandlerPtr aHookHandler(MTPROGID_HOOKHANDLER);
   
    aHookHandler->Read(( MTHOOKHANDLERLib::IMTConfigPropSet*)aHookSet.GetInterfacePtr());

    aHookHandler->ExecuteAll();
  }
#endif

 return TRUE;
}
