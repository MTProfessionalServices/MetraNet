//
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
 * Created by: Raju Matta 
 * $Header$
 ***************************************************************************/

#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>

#include <windows.h>
#include <stdio.h>
#include <iostream>

#include <SetIterate.h>
#include <mtcomerr.h>
#include <errobj.h>

#import <comticketagent.tlb>
using namespace COMTICKETAGENTLib;
using namespace std;

int 
main(int argc, char** argv)
{
  try
  {
    cout << "Entering main()" << endl;

	  cout << "Entering Constructor" << endl;
	  ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
	  cout << "Leaving Constructor" << endl;

   	// create the MTLDAPImpl object
   	COMTICKETAGENTLib::ITicketAgentPtr ticketAgent;
		HRESULT hr = ticketAgent.CreateInstance("MetraTech.TicketAgent.1");
   	if (!SUCCEEDED(hr))
   	{
   		cout << "ERROR: unable to create instance of TicketAgent object" 
     			<< hex << hr << endl;
  		return (FALSE);
		}
	
    // first call
		ticketAgent->CreateTicket(
                                   "namespace", // BSTR sNamespace,
                                   "acctid",    // BSTR sAccountIdentifier,
                                   0);          // long lExpirationOffset,
   	if (!SUCCEEDED(hr))
   	{
   		cout << "ERROR: unable to initialize " << hex << hr << endl;
			return (FALSE);
		}

    // second call
		ticketAgent->CreateTicket(
                                   "namespace", // BSTR sNamespace,
                                   "acctid",    // BSTR sAccountIdentifier,
                                   0);          // long lExpirationOffset,
   	if (!SUCCEEDED(hr))
   	{
   		cout << "ERROR: unable to initialize " << hex << hr << endl;
			return (FALSE);
		}

#if DJM
	  cout << "Entering Destructor" << endl;
	  ::CoUninitialize();
	  cout << "Leaving Destructor" << endl;
#endif
	}
	catch (HRESULT hr)
	{
		cout << "***ERROR! " << hex << hr << dec << endl;
		return -1;
	}
	catch (_com_error err)
	{
		cout << "***ERROR _com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "  Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "  Source: " << (const char *) src << endl;
		return -1;
	}

  cout << "SUCCESS: Test succeeded"  << endl;

	return 0;
}
