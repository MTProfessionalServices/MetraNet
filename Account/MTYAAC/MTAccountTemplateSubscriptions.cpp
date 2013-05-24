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
#include "MTAccountTemplateSubscriptions.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAccountTemplateSubscriptions

STDMETHODIMP CMTAccountTemplateSubscriptions::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTAccountTemplateSubscriptions,
    &IID_IMTCollectionEx,
    &IID_IMTCollection,
    &IID_IMTCollectionReadOnly
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTAccountTemplateSubscriptions::AddSubscription(IMTAccountTemplateSubscription **ppTemplateSub)
{
	try {
		MTYAACLib::IMTAccountTemplateSubscriptionPtr sub(__uuidof(MTYAACLib::MTAccountTemplateSubscription));
		IDispatchPtr pdisp = sub;
		InternalAdd(_variant_t(pdisp.GetInterfacePtr()));
		*ppTemplateSub = reinterpret_cast<IMTAccountTemplateSubscription*>(sub.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to create new AccountTemplateSubscription",LOG_ERROR);
	}
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscriptions::get_GetItemIndexWithProductOfferingID(long lngPOID, long *pVal)
{
	try {

    MTYAACLib::IMTCollectionPtr col((IMTCollection*)this);

	  for(int index = 1;index <= col->GetCount();index++) {
		  MTYAACLib::IMTAccountTemplateSubscriptionPtr sub = col->GetItem(index);
		  if(sub->GetProductOfferingID() == lngPOID) {
			  *pVal = index;
			  return S_OK;
		  }
	  }
  }
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to create new AccountTemplateSubscription",LOG_ERROR);
	}
	*pVal = -1;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscriptions::RemoveSubscription(long aProductOfferingID)
{
  try {
    MTYAACLib::IMTCollectionPtr col((IMTCollection*)this);

	  for(int index = 1;index <= col->GetCount();index++) {
		  MTYAACLib::IMTAccountTemplateSubscriptionPtr sub = col->GetItem(index);
		  if (sub->GetSubscriptionProductOfferingID() == aProductOfferingID) {
        col->Remove(index);
			  return S_OK;
		  }
	  }
  }
  catch(_com_error& err) {
		return returnYAACError(err,"Failed to find product offering in collection",LOG_ERROR);
  }
	return S_OK;
}
STDMETHODIMP CMTAccountTemplateSubscriptions::get_AccountTemplate(IMTAccountTemplate** ppVal)
{
  try
  {
    if(*ppVal == NULL)
      return E_POINTER;
    MTYAACLib::IMTAccountTemplatePtr outPtr = mAccountTemplate;
    (*ppVal) = reinterpret_cast<IMTAccountTemplate*>(outPtr.Detach());
  }
  catch(_com_error& err) 
  {
    return returnYAACError(err,"Failed to get account template subscription",LOG_ERROR);
  }
  return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscriptions::put_AccountTemplate(IMTAccountTemplate* pVal)
{
  mAccountTemplate = pVal;
  return S_OK;
}