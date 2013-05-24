/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Boris Partensky
* $Header$
* 
***************************************************************************/

// MTLocalizedEntry.h : Declaration of the CMTLocalizedEntry

#ifndef __MTLOCALIZEDENTRY_H_
#define __MTLOCALIZEDENTRY_H_

#include "resource.h"       // main symbols
#include <LocaleConfig.h>


/////////////////////////////////////////////////////////////////////////////
// CMTLocalizedEntry
class CMTLocalizedEntry 
{
public:
	CMTLocalizedEntry(BSTR aExtension, BSTR aNamespace, BSTR aLangCode, BSTR aFQN, BSTR aValue)
	{
		GetExtensionsDir(mrwExtensionDir);
		PutExtension(aExtension);
		mNamespace = aNamespace;
		mLanguageCode = aLangCode;
		mFQN = aFQN;
		mLocalizedString = aValue;
	}
	~CMTLocalizedEntry(){}

	_bstr_t& GetLocalizedString()
	{
		return mLocalizedString;
	}
	_bstr_t& GetLanguageCode()
	{
		return mLanguageCode;
	}
	_bstr_t& GetFQN()
	{
		return mFQN;
	}
	_bstr_t& GetNamespace()
	{
		return mNamespace;
	}
	
	void PutExtension(BSTR aExtension);

	_bstr_t& GetExtension()
	{
		return mExtension;
	}
private:
	CMTLocalizedEntry(){}
	_bstr_t mNamespace;
	_bstr_t mFQN;
	_bstr_t mLanguageCode;
	_bstr_t mLocalizedString;
	_bstr_t mExtension;
	std::string mrwExtensionDir;

};

#endif //__MTLOCALIZEDENTRY_H_
