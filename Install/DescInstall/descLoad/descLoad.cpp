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
 * Created by: Chen He
 * $Header$
 ***************************************************************************/

#include <iostream>

#include <mtcom.h>
#include "MTUtil.h"
#include "Description.h"

using namespace std;

_COM_SMARTPTR_TYPEDEF(IUnknown, __uuidof(IUnknown));

static ComInitialize gComInitialize;

int 
main(int argc, char * argv[])
{
	if (argc > 1)
	{
		cout << "\nUsage: descload" << endl;
		cout << "\tThis does not take any options.  Just run descload" << endl;
		return 1;
	}

	try
	{
		Description desc;

		if (!desc.Init())
		{
			return 1;
		}

		if (!desc.LoadDescription())
		{
			cout << "Failed to load description table!" << endl;
			return 1;
		}
	}
	catch (HRESULT hr)
	{
		cout << "***ERROR! " << hex << hr << dec << endl;
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
	}
	catch (...)
	{
		cout << "***ERROR everything else " << endl;
	}

	return 0;
}

