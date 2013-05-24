/**************************************************************************
 * @doc CONVERTSTRING
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
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <MTUtil.h>

BOOL ASCIIToWide(wstring & arWstring, const string & arStr)
{
	return ASCIIToWide(arWstring, arStr.c_str(), arStr.length());
}


BOOL ASCIIToWide(wstring & arWstring, const char * apAscii, int aLen /* = -1 */,
								 int aCodePage /* = CP_ACP */)
{
	if (aLen < 0)
		aLen = strlen(apAscii);

#ifdef WIN32
	int len = MultiByteToWideChar(
		aCodePage,											// ANSI code page
		0,													// character-type options
		apAscii,										// address of string to map
		aLen,												// number of bytes in string
		NULL,												// address of wide-character buffer
		0);													// size of buffer

	if (len == 0)
	{
		arWstring = L"";
		return TRUE;
	}

	ASSERT(len > 0);
	wchar_t * out = new wchar_t[len];
	(void) MultiByteToWideChar(
		aCodePage,											// ANSI code page
		0,													// character-type options
		apAscii,										// address of string to map
		aLen,												// number of bytes in string
		out,												// address of wide-character buffer
		len);												// size of buffer

	// put it into the wstring
	arWstring.assign(out, len);
	delete [] out;
	return TRUE;

#else // WIN32

	// This fails on UNIX
  // int len = mbstowcs(NULL, scratch, aLen);

	wchar_t *out = new wchar_t[aLen + 1];
  int len = mbstowcs(out, apAscii, aLen);
	out[len] = wchar_t(L'\0');
  
  // wstring temp(out, len);
  // arWstring = temp;
  
  arWstring.assign(out, len);
	delete [] out;
	return TRUE;

#endif // WIN32

}


BOOL WideStringToUTF8(const wstring & arWide, string & arUTF)
{
#ifdef WIN32
	return WideStringToMultiByte(arWide, arUTF, CP_UTF8);
#else
	return WideStringToMultiByte(arWide, arUTF, 65001);
#endif
}

BOOL WideStringToMultiByte(const wstring & arWide, string & arMultibyte, UINT aCodePage)
{
	int len;
	
#ifdef WIN32
	
	len = WideCharToMultiByte(
		aCodePage,									// code page
		0,													// performance and mapping flags
		arWide.c_str(),				      // wide-character string
		arWide.length(),				    // number of chars in string
		NULL,												// buffer for new string
		0,													// size of buffer
		NULL,												// default for unmappable chars
		NULL);											// set when default char used
	
	if (len == 0)
		return FALSE;
	
	char * out = new char[len];
	len = WideCharToMultiByte(
		aCodePage,									// code page
		0,													// performance and mapping flags
		arWide.c_str(),	       			// wide-character string
		arWide.length(),				    // number of chars in string
		out,												// buffer for new string
		len,												// size of buffer
		NULL,												// default for unmappable chars
		NULL);											// set when default char used

	if (len == 0)
	{
		int err = ::GetLastError();
		return FALSE;
	}

	string temp(out, len);
	arMultibyte = temp;

	delete [] out;

	return TRUE;

#else
	// TODO: does this call use len correctly? Now it does.
	char * temp_str = new char[arWide.length()];
	len = wcstombs(temp_str, arWide.c_str(), arWide.length());
	delete [] temp_str;
	if (len == -1)
		return 0;										// an invalid mb was encountered

	// NOTE: wcstombs will only null terminate the string
	// if the original wide char string was null terminated.
	// therefore, we can make the array exactly the size
	// returned by the first call to wcstombs
	char * out = new char[len];
	if (wcstombs(out, arWide.c_str(), len) == -1)
	{
		delete [] out;
		return 0;										// an invalid mb was encountered
	}

	// put it into the wstring
	// TODO: can this be done differently?
	string temp(out, len);
	arMultibyte = temp;
	//arString.assign(out, len);

	delete [] out;
	return TRUE;

#endif
}

