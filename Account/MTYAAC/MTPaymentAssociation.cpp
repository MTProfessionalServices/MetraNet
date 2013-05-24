/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include "MTYAAC.h"
#include "MTPaymentAssociation.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPaymentAssociation

STDMETHODIMP CMTPaymentAssociation::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPaymentAssociation
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTPaymentAssociation::Initialize(IMTSessionContext *pCTX, long aPayer, long aPayee, DATE StartDate, DATE EndDate)
{
	mCTX = pCTX;
	mPayer = aPayer;
	mPayee = aPayee;
	mStartDate = StartDate;
	mEndDate = EndDate;
	return S_OK;
}

STDMETHODIMP CMTPaymentAssociation::get_Payer(long *pVal)
{
	*pVal = mPayer;
	return S_OK;
}

STDMETHODIMP CMTPaymentAssociation::get_PayerYAAC(IMTYAAC **pVal)
{
	try {
		MTYAACLib::IMTYAACPtr yaacPtr(__uuidof(MTYAACLib::MTYAAC));
		yaacPtr->InitAsSecuredResource(mPayer,CTXCAST(mCTX),mStartDate);
		*pVal = reinterpret_cast<IMTYAAC*>(yaacPtr.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"MTPaymentAssociation: Failed to create payer YAAC");
	}
	return S_OK;
}

STDMETHODIMP CMTPaymentAssociation::get_PayeeYAAC(IMTYAAC **pVal)
{
	try {
		MTYAACLib::IMTYAACPtr yaacPtr(__uuidof(MTYAACLib::MTYAAC));
		yaacPtr->InitAsSecuredResource(mPayee,CTXCAST(mCTX),mStartDate);
		*pVal = reinterpret_cast<IMTYAAC*>(yaacPtr.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"MTPaymentAssociation: Failed to create payee YAAC");
	}
	return S_OK;
}


STDMETHODIMP CMTPaymentAssociation::get_Payee(long *pVal)
{
	*pVal = mPayee;
	return S_OK;
}


STDMETHODIMP CMTPaymentAssociation::get_StartDate(DATE *pVal)
{
	*pVal = mStartDate;
	return S_OK;
}

STDMETHODIMP CMTPaymentAssociation::get_EndDate(DATE *pVal)
{
	*pVal = mEndDate;
	return S_OK;
}
