/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

#ifndef _MT_SOURCE_INFO_H
#define _MT_SOURCE_INFO_H


// ----------------------------------------------------------------
// Object:      MTSourceInfo
// Description: helper for MT_THROW_COM_ERROR
// ----------------------------------------------------------------
class MTSourceInfo
{
public:
	MTSourceInfo(const char * apModule, int aLine);

	_bstr_t MTSourceInfo::GetSourceString();

	_com_error CreateComError(const IID& aIID, DWORD aErrorCode, ...);
	_com_error CreateComError(const IID& aIID, const char* aMsg, ...);
	_com_error CreateComError(const IID& aIID, const wchar_t* aMsg, ...);
	_com_error CreateComError(DWORD aErrorCode, ...);
	_com_error CreateComError(const char* aMsg, ...);
	_com_error CreateComError(const wchar_t* aMsg, ...);

protected:
	_com_error CreateErrorInfo(const IID& aIID, HRESULT aErrorCode, const _bstr_t aMsg);
	_com_error CreateComErrorFromErrorCode(const IID& aIID, DWORD aErrorCode, va_list aArglist);
	_com_error CreateComErrorFromString(const IID& aIID, const char* aMsg, va_list aArglist);
	_com_error CreateComErrorFromWString(const IID& aIID, const wchar_t* aMsg, va_list aArglist);


	
//data
	const char* mpModule;
	int   mLine;
};

#endif //_MT_SOURCE_INFO_H
