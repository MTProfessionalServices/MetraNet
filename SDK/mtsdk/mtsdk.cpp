/**************************************************************************
 * @doc MTSDK
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
 * Created by: Derek Young
 * $Header$
 ***************************************************************************/

#include <metra.h>

// all we need to do is export the classes and link with the correct libraries
#ifdef WIN32
#define MTSDK_DLL_EXPORT __declspec(dllexport)
#endif

#include <mtsdk.h>

#include <sdkcon.h>

#include <MSIX.h>

#ifdef UNIX
int mtsdk_stub_linker(void)
{
  assert(FALSE); // never call this function!
  MTMeterHTTPConfig *mmc = new MTMeterHTTPConfig("dummy");
  MTMeter *mm = new MTMeter(*mmc);
  MSIXSession *msix = new MSIXSession();
  return 0;
}
#endif
