/**************************************************************************
 * @doc dllmain
 * 
 * @module  Dllmain for the dbobjects dll|
 * 
 * This file contains dllmain for the dbobjects dll.
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
 * @index | dllmain
 ***************************************************************************/

#include <metra.h>
#include <NTLogServer.h>

static NTLogServer *pLogServer = NULL ;

extern "C" int APIENTRY DllMain (HINSTANCE Instance, DWORD Reason, LPVOID Reserved)
{
  // local variables ...
  
  switch (Reason)
  {
  case DLL_PROCESS_ATTACH:
//  pLogServer  = NTLogServer::GetInstance() ;
    break;
    
  case DLL_PROCESS_DETACH:
//  pLogServer->ReleaseInstance() ;
    pLogServer = NULL ;
    break;
    
  default:
    break;
  }
  
  return 1;
}
