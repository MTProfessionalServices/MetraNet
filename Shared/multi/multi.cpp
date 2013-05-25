/**************************************************************************
 * @doc MULTI
 *
 * Copyright 2000 by MetraTech Corporation
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
#include <multi.h>

#include <domainname.h>
#include <ConfigDir.h>
#include <multiinstance.h>
#include <makeunique.h>
#include <stdutils.h>

BOOL MultiInstanceSetup::SetupMultiInstance(const char * apLogin,
																						const char * apPassword,
																						const char * apDomain)
{
	const char * functionName = "MultiInstanceSetup::SetupMultiInstance";

	//
	// if requested, impersonate a given user
	//
	BOOL multiInstance;
	wstring defaultDomainNameWide;
	string defaultDomainName;

	if (apLogin)
	{
		// if they pass in the parameters on the command line then
		// we're multiinstance no matter what.
		multiInstance = TRUE;

		if (!apPassword)
			apPassword = "";

		if (!apDomain)
		{
			if (!GetNTDomainName(defaultDomainNameWide))
			{
				SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
								 "Unable to read default NT domain name");
				return FALSE;
			}
			defaultDomainName = ascii(defaultDomainNameWide);
			apDomain = defaultDomainName.c_str();
		}

		HANDLE loginHandle = NULL;
		if (!::LogonUserA(const_cast<char *>(apLogin),
											const_cast<char *>(apDomain),
											const_cast<char *>(apPassword),
											// TODO: should we do this or LOGON32_LOGON_NETWORK?
											//LOGON32_LOGON_NETWORK,
											LOGON32_LOGON_INTERACTIVE,	// type of logon operation
											LOGON32_PROVIDER_DEFAULT, // logon provider
											&loginHandle))
		{
			string buffer("Unable to login as user ");
			buffer += apLogin;
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
							 buffer.c_str());
			return FALSE;
		}

		if (!::ImpersonateLoggedOnUser(loginHandle))
		{
			string buffer("Unable to impersonate user ");
			buffer += apLogin;
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
							 buffer.c_str());
			return FALSE;
		}

		// this will be appended to the configuration directory stored in the registry
		string loginStr(apLogin);
		SetNameSpace(loginStr);

		// set the string that will be prepended to all strings passed to MakeUnique
		SetUniquePrefix(apLogin);
	}
	else
	{
		if (IsMultiInstance())
		{
			multiInstance = TRUE;

			char buffer[256];
			DWORD len = sizeof(buffer) / sizeof(buffer[0]);

			if (!::GetUserNameA(buffer, &len))
			{
				SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
								 "Unable to get user name");
				return FALSE;
			}

			// this will be appended to the configuration directory stored in the registry
			string loginStr(buffer);
			SetNameSpace(loginStr);

			// set the string that will be prepended to all strings passed to MakeUnique
			SetUniquePrefix(loginStr.c_str());
		}
	}

	return TRUE;
}
