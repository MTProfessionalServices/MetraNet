/**************************************************************************
 * @doc MTAUDITOR
 *
 * Copyright 1999 by MetraTech Corporation
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
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

#include <audit.h>

#include <errutils.h>
#include <multi.h>

#include <iostream>
using namespace std;

static ComInitialize sComInitialize;

int main(int argc, char * argv[])
{
	try
	{
		if (argc == 2 && 0 == strcmp(argv[1], "/?"))
		{
			cout << "usage: mtauditor [hours] [-auto]" << endl;
			cout << "  purges successful sessions completed within hours." << endl;
			cout << "  with no argument, checks sessions in the last 24 hours." << endl;
			cout << "  with -auto argument, audits periodically." << endl;
			return 1;
		}

		// negative means test forever
		long hours = 24;
		BOOL automatic = FALSE;
		BOOL find = FALSE;

		const char * login = NULL;
		const char * password = NULL;
		const char * domain = NULL;

		int i = 2;
		while (i < argc)
		{
			if (0 == strcmp(argv[i], "-login"))
			{
				i++;
				if (i >= argc)
				{
					cout << "login name required after -login" << endl;
					return FALSE;
				}
				login = argv[i];
			}
			else if (0 == strcmp(argv[i], "-password"))
			{
				i++;
				if (i >= argc)
				{
					cout << "password required after -password" << endl;
					return FALSE;
				}
				password = argv[i];
			}
			else if (0 == strcmp(argv[i], "-domain"))
			{
				i++;
				if (i >= argc)
				{
					cout << "domain required after -domain" << endl;
					return FALSE;
				}
				domain = argv[i];
			}
			else if (0 == strcmp(argv[i], "-auto"))
				automatic = TRUE;
			else if (0 == strcmp(argv[i], "-find"))
				find = TRUE;
			else
			{
				char * end;
				hours = strtol(argv[i], &end, 10);
				if (end != argv[i] + strlen(argv[i]))
				{
					cout << "Hours must be expressed as an integer" << endl;
					return 1;
				}
			}
			i++;
		}

#if 0
		int hours;
		if (argc == 2)
		{
			char * end;
			hours = strtol(argv[1], &end, 10);
			if (end != argv[1] + strlen(argv[1]))
			{
				cout << "Hours must be expressed as an integer" << endl;
				return 1;
			}
		}
		else
			hours = 24;
#endif


		MultiInstanceSetup multiSetup;
		if (!multiSetup.SetupMultiInstance(login, password, domain))
		{
			string buffer;
			StringFromError(buffer, "Auditing failed", multiSetup.GetLastError());
			cout << buffer.c_str() << endl;
			return -1;
		}


		MTAuditor auditor;

		if (find)
		{
			auditor.Init(TRUE);
			std::list<std::string> uids;
			if (!auditor.FindLostSessions(uids, 1000))
			{
				string buffer;
				StringFromError(buffer, "Auditing failed", auditor.GetLastError());
				cout << buffer.c_str() << endl;
				return -1;
			}

			std::list<std::string>::iterator it;
			for (it = uids.begin(); it != uids.end(); it++)
				cout << it->c_str() << endl;
		}
		else if (automatic)
		{
			auditor.Init();
			auditor.StartThread();
			HANDLE hThread;
			hThread = auditor.ThreadHandle();
			::WaitForSingleObject(hThread, INFINITE);
			return 0;
		}
		else
		{
			auditor.Init();
			if (!auditor.AuditSessions(hours))
			{
				string buffer;
				StringFromError(buffer, "Auditing failed", auditor.GetLastError());
				cout << buffer.c_str() << endl;
				return -1;
			}
		}
	}
	catch (_com_error & err)
	{
		cout << "_com_error thrown: " << endl;
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
	return 0;
}
