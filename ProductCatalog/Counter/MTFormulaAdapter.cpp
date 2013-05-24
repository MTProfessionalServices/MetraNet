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

#include <StdAfx.h>
#include "FormulaAdapter.h"


HRESULT CMTFormulaAdapter::Init()
{
	HRESULT hr(S_OK);

	hr = mpQueryAdapter.CoCreateInstance(__uuidof(MTQueryAdapter));
	if(FAILED(hr))
		return hr;
	return mpQueryAdapter->Init(CONFIG_DIR);
}


HRESULT CMTFormulaAdapter::SetFormula(BSTR aFormula)
{
	ASSERT(aFormula);
	return mpQueryAdapter->SetRawSQLQuery(aFormula);
}

HRESULT CMTFormulaAdapter::GetFormula(BSTR* aFormula)
{
	return mpQueryAdapter->GetQuery(aFormula);
}

HRESULT CMTFormulaAdapter::SetParameter(BSTR aName, BSTR aValue)
{
	_bstr_t param = aName;
	_bstr_t delim = L"%%";
	param = delim + param;
	param += delim;
	_variant_t vtValidate;
	vtValidate.boolVal = FALSE;

	return mpQueryAdapter->AddParam(param, _variant_t(aValue), vtValidate);
}

