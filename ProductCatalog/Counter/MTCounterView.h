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
 * $Header$
 *
 ***************************************************************************/

#ifndef __MTCOUNTERVIEW_H_
#define __MTCOUNTERVIEW_H_

#include "counterincludes.h"

/////////////////////////////////////////////////////////////////////////////
// CCounterView
class CMTCounterView
{
public:
	CMTCounterView() {}
	HRESULT Create(BSTR aProductViewName, BSTR* apViewName);
	HRESULT CreateAllViews();
	HRESULT CreateUsageView(BSTR* apViewName);
	//HRESULT ViewExists(BSTR apViewName, VARIANT_BOOL* aFlag);
	HRESULT Remove(BSTR apProductView);
	_bstr_t GetViewName (const _bstr_t &arProductView);
private:
};

#endif //__MTCOUNTERVIEW_H_
