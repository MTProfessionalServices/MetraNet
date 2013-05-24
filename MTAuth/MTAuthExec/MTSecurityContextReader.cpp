// MTSecurityContextReader.cpp : Implementation of CMTSecurityContextReader
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTSecurityContextReader.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSecurityContextReader

STDMETHODIMP CMTSecurityContextReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSecurityContextReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


