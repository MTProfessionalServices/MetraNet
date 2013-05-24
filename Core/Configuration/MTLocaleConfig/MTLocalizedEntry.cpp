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

// MTLocalizedEntry.cpp : Implementation of CMTLocalizedEntry
#include "StdAfx.h"
#include "MTLocaleConfig.h"
#include "MTLocalizedEntry.h"


void CMTLocalizedEntry::PutExtension(BSTR newVal)
{
	_bstr_t bstrExtensionName = newVal;
	if(bstrExtensionName.length() > 0)
	{
		mExtension = mrwExtensionDir.c_str();
		mExtension += L"\\";
		mExtension += bstrExtensionName;
	}
	return;
}
