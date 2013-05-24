/**************************************************************************
* Copyright 2004 by MetraTech
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
#include "MTSubInfo.h"
#include <mttime.h>
#include <mtcomerr.h>


/////////////////////////////////////////////////////////////////////////////
// CMTSubInfo

CMTSubInfo::CMTSubInfo()
{
  mAccountID          = -1;
  mCorporateAccountID = -1;
  mSubsID             = -1;
  mSubsStartDate      = getMinMTOLETime(); // Returns a _variant_t.
  mSubsStartDateType  = PCDATE_TYPE_NO_DATE;
  mSubsEndDate        = getMinMTOLETime(); // Returns a _variant_t.
  mSubsEndDateType    = PCDATE_TYPE_NO_DATE;
  mProdOfferingID     = -1;
  mIsGroupSub         = VARIANT_FALSE;
  mGroupSubID         = -1;

  m_pUnkMarshaler     = NULL;
}

HRESULT CMTSubInfo::FinalConstruct()
{
	try
  {
		return CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err)
  { 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
}

STDMETHODIMP CMTSubInfo::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSubInfo,
	};

	for (int i = 0; i < ((sizeof(arr))/(sizeof(arr[0]))); i++)
	{
		if (InlineIsEqualGUID(*arr[i], riid))
			return S_OK;
	}

	return S_FALSE;
}

STDMETHODIMP CMTSubInfo::get_AccountID(long* pVal)
{
	if (pVal == 0)
		return E_POINTER;

	(*pVal) = mAccountID;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::put_AccountID(long newVal)
{
  mAccountID = newVal;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::get_CorporateAccountID(long* pVal)
{
	if (pVal == 0)
		return E_POINTER;

	(*pVal) = mCorporateAccountID;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::put_CorporateAccountID(long newVal)
{
  mCorporateAccountID = newVal;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::get_SubsID(long* pVal)
{
	if (pVal == 0)
		return E_POINTER;

	(*pVal) = mSubsID;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::put_SubsID(long newVal)
{
  mSubsID = newVal;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::get_SubsStartDate(DATE* pVal)
{
	if (pVal == 0)
		return E_POINTER;

	(*pVal) = mSubsStartDate;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::put_SubsStartDate(DATE newVal)
{
  mSubsStartDate = newVal;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::get_SubsStartDateAsBSTR(BSTR* pVal)
{
	if (pVal == 0)
		return E_POINTER;

  HRESULT hr = S_OK;
  VARIANT vtOut;

  vtOut.vt = VT_EMPTY;  // VariantInit().

	try
	{
    VARIANT vtIn;

    vtIn.vt   = VT_DATE;
    vtIn.date = mSubsStartDate;

    hr = VariantChangeType(&vtOut, &vtIn, 0, VT_BSTR);

    vtIn.vt = VT_EMPTY; // VariantClear().

    if (hr == S_OK)
    {
  	  (*pVal) = vtOut.bstrVal;
      vtOut.vt = VT_EMPTY;
      vtOut.bstrVal = 0;
    }
	}
	catch (_com_error & err)
	{
    VariantClear(&vtOut);

		return ReturnComError(err);
	}		

  VariantClear(&vtOut);

	return hr;
}

STDMETHODIMP CMTSubInfo::put_SubsStartDateAsBSTR(BSTR newVal)
{
  HRESULT hr = S_OK;

	try
	{
    VARIANT vtIn;
    VARIANT vtOut;

    vtIn.vt      = VT_BSTR;
    vtIn.bstrVal = newVal;    // Do not copy.

    vtOut.vt     = VT_EMPTY;  // VariantInit().

    hr = VariantChangeType(&vtOut, &vtIn, 0, VT_DATE);

    vtIn.vt      = VT_EMPTY;
    vtIn.bstrVal = 0;         // Do not free.

    if (hr == S_OK)
  	  mSubsStartDate = vtOut.date;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return hr;
}

STDMETHODIMP CMTSubInfo::get_SubsStartDateType(MTPCDateType* pVal)
{
	if (pVal == 0)
		return E_POINTER;

	(*pVal) = mSubsStartDateType;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::put_SubsStartDateType(MTPCDateType newVal)
{
  mSubsStartDateType = newVal;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::get_SubsEndDate(DATE* pVal)
{
	if (pVal == 0)
		return E_POINTER;

	(*pVal) = mSubsEndDate;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::put_SubsEndDate(DATE newVal)
{
  mSubsEndDate = newVal;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::get_SubsEndDateAsBSTR(BSTR* pVal)
{
	if (pVal == 0)
		return E_POINTER;

  HRESULT hr = S_OK;
  VARIANT vtOut;

  vtOut.vt = VT_EMPTY;  // VariantInit().

	try
	{
    VARIANT vtIn;

    vtIn.vt   = VT_DATE;
    vtIn.date = mSubsEndDate;

    hr = VariantChangeType(&vtOut, &vtIn, 0, VT_BSTR);

    vtIn.vt = VT_EMPTY; // VariantClear().

    if (hr == S_OK)
    {
  	  (*pVal) = vtOut.bstrVal;
      vtOut.vt = VT_EMPTY;
      vtOut.bstrVal = 0;
    }
	}
	catch (_com_error & err)
	{
    VariantClear(&vtOut);

		return ReturnComError(err);
	}		

  VariantClear(&vtOut);

	return hr;
}

STDMETHODIMP CMTSubInfo::put_SubsEndDateAsBSTR(BSTR newVal)
{
  HRESULT hr = S_OK;

	try
	{
    VARIANT vtIn;
    VARIANT vtOut;

    vtIn.vt      = VT_BSTR;
    vtIn.bstrVal = newVal;    // Do not copy.

    vtOut.vt     = VT_EMPTY;  // VariantInit().

    hr = VariantChangeType(&vtOut, &vtIn, 0, VT_DATE);

    vtIn.vt      = VT_EMPTY;
    vtIn.bstrVal = 0;         // Do not free.

    if (hr == S_OK)
  	  mSubsEndDate = vtOut.date;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return hr;
}

STDMETHODIMP CMTSubInfo::get_SubsEndDateType(MTPCDateType* pVal)
{
	if (pVal == 0)
		return E_POINTER;

	(*pVal) = mSubsEndDateType;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::put_SubsEndDateType(MTPCDateType newVal)
{
  mSubsEndDateType = newVal;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::get_ProdOfferingID(long* pVal)
{
	if (pVal == 0)
		return E_POINTER;

	(*pVal) = mProdOfferingID;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::put_ProdOfferingID(long newVal)
{
  mProdOfferingID = newVal;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::get_IsGroupSub(VARIANT_BOOL* pVal)
{
	if (pVal == 0)
		return E_POINTER;

  (*pVal) = mIsGroupSub;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::get_GroupSubID(long* pVal)
{
	if (pVal == 0)
		return E_POINTER;

	(*pVal) = mGroupSubID;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::put_GroupSubID(long newVal)
{
  mGroupSubID = newVal;

  if (newVal == (-1))
    mIsGroupSub = VARIANT_FALSE;
  else
    mIsGroupSub = VARIANT_TRUE;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::GetAll(long*         pAccountID,
                                long*         pCorporateAccountID,
                                long*         pSubsID,
                                DATE*         pSubsStartDate,
                                MTPCDateType* pSubsStartDateType,
                                DATE*         pSubsEndDate,
                                MTPCDateType* pSubsEndDateType,
                                long*         pProdOfferingID,
                                VARIANT_BOOL* pIsGroupSub,
                                long*         pGroupSubID)
{
	if ((pAccountID          == 0)
   || (pCorporateAccountID == 0)
   || (pSubsID             == 0)
   || (pSubsStartDate      == 0)
   || (pSubsStartDateType  == 0)
   || (pSubsEndDate        == 0)
   || (pSubsEndDateType    == 0)
   || (pProdOfferingID     == 0)
   || (pIsGroupSub         == 0)
   || (pGroupSubID         == 0))
		return E_POINTER;

  *pAccountID          = mAccountID;
  *pCorporateAccountID = mCorporateAccountID;
  *pSubsID             = mSubsID;
  *pSubsStartDate      = mSubsStartDate;
  *pSubsStartDateType  = mSubsStartDateType;
  *pSubsEndDate        = mSubsEndDate;
  *pSubsEndDateType    = mSubsEndDateType;
  *pProdOfferingID     = mProdOfferingID;
  *pIsGroupSub         = mIsGroupSub;
  *pGroupSubID         = mGroupSubID;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::PutAll(long         newAccountID,
                                long         newCorporateAccountID,
                                long         newSubsID,
                                DATE         newSubsStartDate,
                                MTPCDateType newSubsStartDateType,
                                DATE         newSubsEndDate,
                                MTPCDateType newSubsEndDateType,
                                long         newProdOfferingID,
                                VARIANT_BOOL newIsGroupSub,
                                long         newGroupSubID)
{
  mAccountID          = newAccountID;
  mCorporateAccountID = newCorporateAccountID;
  mSubsID             = newSubsID;
  mSubsStartDate      = newSubsStartDate;
  mSubsStartDateType  = newSubsStartDateType;
  mSubsEndDate        = newSubsEndDate;
  mSubsEndDateType    = newSubsEndDateType;
  mProdOfferingID     = newProdOfferingID;
  mIsGroupSub         = newIsGroupSub;
  mGroupSubID         = newGroupSubID;

  return S_OK;
}

STDMETHODIMP CMTSubInfo::GetAllWithBSTRDates(long*         pAccountID,
                                             long*         pCorporateAccountID,
                                             long*         pSubsID,
                                             BSTR*         pSubsStartDate,
                                             MTPCDateType* pSubsStartDateType,
                                             BSTR*         pSubsEndDate,
                                             MTPCDateType* pSubsEndDateType,
                                             long*         pProdOfferingID,
                                             VARIANT_BOOL* pIsGroupSub,
                                             long*         pGroupSubID)
{
	if ((pAccountID          == 0)
   || (pCorporateAccountID == 0)
   || (pSubsID             == 0)
   || (pSubsStartDate      == 0)
   || (pSubsStartDateType  == 0)
   || (pSubsEndDate        == 0)
   || (pSubsEndDateType    == 0)
   || (pProdOfferingID     == 0)
   || (pIsGroupSub         == 0)
   || (pGroupSubID         == 0))
		return E_POINTER;

  *pAccountID          = mAccountID;
  *pCorporateAccountID = mCorporateAccountID;
  *pSubsID             = mSubsID;

  HRESULT hr1, hr2;

  hr1 = get_SubsStartDateAsBSTR(pSubsStartDate);
  hr2 = get_SubsEndDateAsBSTR(pSubsEndDate);

  *pSubsStartDateType  = mSubsStartDateType;
  *pSubsEndDateType    = mSubsEndDateType;
  *pProdOfferingID     = mProdOfferingID;
  *pIsGroupSub         = mIsGroupSub;
  *pGroupSubID         = mGroupSubID;

  if (FAILED(hr1))
    return hr1;

  if (FAILED(hr2))
    return hr2;

	return S_OK;
}

STDMETHODIMP CMTSubInfo::PutAllWithBSTRDates(long         newAccountID,
                                             long         newCorporateAccountID,
                                             long         newSubsID,
                                             BSTR         newSubsStartDate,
                                             MTPCDateType newSubsStartDateType,
                                             BSTR         newSubsEndDate,
                                             MTPCDateType newSubsEndDateType,
                                             long         newProdOfferingID,
                                             VARIANT_BOOL newIsGroupSub,
                                             long         newGroupSubID)
{
  mAccountID          = newAccountID;
  mCorporateAccountID = newCorporateAccountID;
  mSubsID             = newSubsID;

  HRESULT hr1, hr2;

  hr1 = put_SubsStartDateAsBSTR(newSubsStartDate);
  hr2 = put_SubsEndDateAsBSTR(newSubsEndDate);

  mSubsStartDateType  = newSubsStartDateType;
  mSubsEndDateType    = newSubsEndDateType;
  mProdOfferingID     = newProdOfferingID;
  mIsGroupSub         = newIsGroupSub;
  mGroupSubID         = newGroupSubID;

  if (FAILED(hr1))
    return hr1;

  if (FAILED(hr2))
    return hr2;

	return S_OK;
}
