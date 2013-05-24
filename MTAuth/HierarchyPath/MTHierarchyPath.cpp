/**************************************************************************
 *
 * Copyright 2001 by MetraTech Corporation
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
 * Created by: Boris Partensky
 * $Author$
 * $Header$
 *
 ***************************************************************************/


#include "StdAfx.h"
#include "HierarchyPath.h"
#include "MTHierarchyPath.h"

/////////////////////////////////////////////////////////////////////////////
// CMTHierarchyPath

STDMETHODIMP CMTHierarchyPath::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTHierarchyPath
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTHierarchyPath::get_Pattern(BSTR *pVal)
{
	(*pVal) = msPattern.copy();
	return S_OK;
}

STDMETHODIMP CMTHierarchyPath::put_Pattern(BSTR newVal)
{
	msPattern = newVal;
	mpPattern = new CMTPathRegEx((char*)msPattern);
	return S_OK;
}

STDMETHODIMP CMTHierarchyPath::get_CaseSensitive(VARIANT_BOOL *pVal)
{
	(*pVal) = (mbCs) ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP CMTHierarchyPath::put_CaseSensitive(VARIANT_BOOL newVal)
{
	mbCs = (newVal == VARIANT_TRUE) ? true : false;
	return S_OK;
}

/* 
Returns true if file path passed as a parameter (aPath) is impilied by the file path in mpPattern object.
Logic in underlying C++ object (CMTPathRegex) is "stolen" 
from Java's FilePermission class implementation (java.io.FilePermission)

Recogized tokens indicating wild cards are: 

'*' - indicates all files in current directory. For example: "/metratech/*" will imply
			"/metratech/engineering", but will not imply "metratech/engineering/core"
'-' - indicates all files in current directory and, recursively, in all directories
			under this directory. For example: "metratech/-" will imply  both "metratech/engineering" and
			"metratech/engineering/core".
'<<ALL FILES>>' - indicates all files (currently not implemented)

*/
STDMETHODIMP CMTHierarchyPath::Implies(BSTR aPath, VARIANT_BOOL *aMatch)
{
	if (mpPattern == NULL)
		//pattern was never set
		return E_FAIL;

	msRequestedPath = aPath;
	mpPattern->SetCaseSensitive(mbCs);
	
	(*aMatch) = mpPattern->Implies(CMTPathRegEx((char*)msRequestedPath)) ? VARIANT_TRUE : VARIANT_FALSE;

	return S_OK;
}
