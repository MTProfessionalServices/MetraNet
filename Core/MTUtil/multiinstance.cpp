/**************************************************************************
 * @doc MULTIINSTANCE
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
#include <multiinstance.h>

#include <NTRegistryIO.h>
#include <stdutils.h>

BOOL IsMultiInstance()
{
	const wchar_t * branch = L"SOFTWARE\\MetraTech\\NetMeter\\";
	const wchar_t * value = L"MultiInstance";

	NTRegistryIO registry;
	BYTE buffer[64];
	DWORD size = sizeof(buffer);
	BYTE * pBuffer = buffer;

	if (!registry.OpenRegistryRaw(NTRegistryIO::LOCAL_MACHINE,
																branch, RegistryIO::READ_ACCESS))
		// may fail because the key doesn't exist - that's OK (although the branch should exist)
		return FALSE;


	if (!registry.ReadRegistryValue(value, RegistryIO::ULONG,
																	pBuffer, size))
		// may fail because the key doesn't exist - that's OK
		return FALSE;

	ULONG * val = (ULONG *) pBuffer;
	return (*val != 0);
}

BOOL ReadPortMappings(PortMappings & arMappings)
{
	const wchar_t * branch = L"SOFTWARE\\MetraTech\\NetMeter\\";
	const wchar_t * value = L"PortMappings";

	NTRegistryIO registry;
	BYTE buffer[1024];
	DWORD size = sizeof(buffer);
	BYTE * pBuffer = buffer;

	if (!registry.OpenRegistryRaw(NTRegistryIO::LOCAL_MACHINE,
																branch, RegistryIO::READ_ACCESS))
		return FALSE;


	if (!registry.ReadRegistryValue(value, RegistryIO::MULTI_STRING,
																	pBuffer, size))
		return FALSE;

	// for each line..
	wchar_t * token = (wchar_t *) buffer;
	while (*token)
	{
		wchar_t * nextToken = token + wcslen(token) + 1;

		// .. parse the mapping (example: 80=User1
		wchar_t * equals = wcschr(token, L'=');
		if (equals == NULL)
			return FALSE;							// parse error

		*equals = L'\0';

		wchar_t * endptr;
		long port = wcstol(token, &endptr, 10);
		if (endptr != token + wcslen(token))
			// not an integer
			return FALSE;							// parse error

		wstring name = equals + 1;
		string ascname = ascii(name);

		arMappings[port] = ascname;

		// next token
		token = nextToken;
	}

	return TRUE;
}

BOOL WritePortMappings(PortMappings & arMappings)
{
	const wchar_t * branch = L"SOFTWARE\\MetraTech\\NetMeter\\";
	const wchar_t * value = L"PortMappings";

	NTRegistryIO registry;
	BYTE buffer[1024];

	// TODO: this could cause a buffer over run (bad!)
	wchar_t * buffPtr = (wchar_t *) buffer;
	PortMappings::iterator it;
	for (it = arMappings.begin(); it != arMappings.end(); it++)
	{
		wchar_t portBuffer[200];
		int port = it->first;
		string nameAsc = it->second;

		wstring nameWide;
		string::const_iterator charIt;
		for (charIt = nameAsc.begin(); charIt != nameAsc.end(); charIt++)
			nameWide += (wchar_t)*charIt;

		swprintf(portBuffer, L"%d=%s", port, nameWide.c_str());
		wcscpy(buffPtr, portBuffer);
		int len = wcslen(portBuffer);
		buffPtr += len + 1;
	}
	*buffPtr++ = L'\0';

	// +2 for terminator
	DWORD size = ((char *) buffPtr - (char *) buffer);
	BYTE * pBuffer = buffer;

	if (!registry.OpenRegistryRaw(NTRegistryIO::LOCAL_MACHINE,
																branch, RegistryIO::WRITE_ACCESS))
		return FALSE;


	if (!registry.WriteRegistryValue(value, RegistryIO::MULTI_STRING,
																	 pBuffer, size))
		return FALSE;

	return TRUE;
}
