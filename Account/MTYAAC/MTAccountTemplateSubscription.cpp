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
#include "MTAccountTemplateSubscription.h"
#include "MTDate.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAccountTemplateSubscription

STDMETHODIMP CMTAccountTemplateSubscription::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountTemplateSubscription
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTAccountTemplateSubscription::Initialize(IMTSessionContext *pCTX, IMTSQLRowset *pRowset)
{
	try {
		ROWSETLib::IMTSQLRowsetPtr rs(pRowset);
		//id_po in case of individual sub or id_group
		//in case of a group sub
    _variant_t vPOID = rs->GetValue("ID_PO");
    _variant_t vGROUPID = rs->GetValue("ID_GROUP");
    if(V_VT(&vPOID) != VT_NULL)
    {
      mProductOfferingID = (long)vPOID;
      ASSERT(V_VT(&vGROUPID) == VT_NULL);
    }
    else
    {
      ASSERT(V_VT(&vGROUPID) != VT_NULL);
      ASSERT(V_VT(&vPOID) == VT_NULL);
      mGroupID = (long)vGROUPID;
    }
    mGroupSubName = MTMiscUtil::GetString(rs->GetValue("NM_GROUPSUBNAME"));
		_variant_t vtDateVal;
		mStartDate = 0.0;
		mEndDate = 0.0;
		vtDateVal = rs->GetValue("VT_START");
		if (V_VT(&vtDateVal) != VT_NULL)
			mStartDate = vtDateVal;
		vtDateVal = rs->GetValue("VT_END");
		if (V_VT(&vtDateVal) != VT_NULL)
			mEndDate = vtDateVal;
		//real id po for both individual and group subscriptions
		mSubscriptionProductOfferingID = rs->GetValue("ProductOfferingID");
	}
	catch(_com_error& err) {
		return returnYAACError(err,"failed to intialize AccountTemplateSubscription",LOG_ERROR);
	}
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::Save(long lngTemplateID, VARIANT_BOOL *pSuccess)
{
	try {
    *pSuccess = VARIANT_FALSE;
		MTYAACEXECLib::IMTGenDbWriterPtr writer(__uuidof(MTYAACEXECLib::MTGenDbWriter));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
    _variant_t vtNull;
    vtNull.ChangeType(VT_NULL);
    /* enforce check constraints at app level */
    if(mProductOfferingID > 0 && mGroupID > 0)
      MT_THROW_COM_ERROR("Both 'ProductOfferingID' And 'GroupID' can not be specified!");
    if(mProductOfferingID < 0 && mGroupID < 0)
      MT_THROW_COM_ERROR("Either 'ProductOfferingID' Or 'GroupID' has to be specified!");
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("ADD_TEMPLATE_SUBS");
    queryAdapter->AddParam("%%ID_PO%%",mProductOfferingID <= 0 ? vtNull : mProductOfferingID);
    queryAdapter->AddParam("%%ID_GROUP%%",mGroupID <= 0 ? vtNull : mGroupID);
		queryAdapter->AddParam("%%TEMPLATEID%%",lngTemplateID);

		wstring DateVal;
		FormatValueForDB(_variant_t(mStartDate,VT_DATE),FALSE,DateVal);
		queryAdapter->AddParam("%%STARTDATE%%",DateVal.c_str(),VARIANT_TRUE);
		FormatValueForDB(_variant_t(mEndDate,VT_DATE),FALSE,DateVal);
		queryAdapter->AddParam("%%ENDDATE%%",DateVal.c_str(),VARIANT_TRUE);
		writer->ExecuteStatement(queryAdapter->GetQuery());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"failed to save account template subscription",LOG_ERROR);
	}
  *pSuccess = VARIANT_TRUE;
 	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::get_ProductOfferingID(long *pVal)
{
	*pVal = mProductOfferingID;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::put_ProductOfferingID(long newVal)
{
	mProductOfferingID = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::get_GroupID(long *pVal)
{
	*pVal = mGroupID;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::put_GroupID(long newVal)
{
	mGroupID = newVal;
	return S_OK;
}


STDMETHODIMP CMTAccountTemplateSubscription::get_GroupSubscription(VARIANT_BOOL *pVal)
{
	*pVal = mGroupID > 0 ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::get_GroupSubName(BSTR *pVal)
{
	*pVal = mGroupSubName.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::put_GroupSubName(BSTR newVal)
{
	mGroupSubName = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::get_StartDate(DATE *pVal)
{
	*pVal = mStartDate;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::put_StartDate(DATE newVal)
{
	mStartDate = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::get_EndDate(DATE *pVal)
{
	*pVal = mEndDate;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::put_EndDate(DATE newVal)
{
	mEndDate = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::ToString(BSTR *pVal)
{
	_bstr_t retval;
	char buff[20];
	retval = "ProductOfferingID=";
	retval += ltoa(mProductOfferingID,buff,10);
	retval += "; GroupSubscription=" + mGroupID > 0 ? "T" : "F";
	MTDate dateStart(mStartDate);
	string tempBuff;
	dateStart.ToString("%Y-%m-%d %H:%M:%S", tempBuff);
	retval += "; StartDate=";
	retval += tempBuff.c_str();
	MTDate dateEnd(mEndDate);
	dateEnd.ToString("%Y-%m-%d %H:%M:%S", tempBuff);
	retval += "; EndDate=";
	retval += tempBuff.c_str();
	retval += "; GroupSubName=" + mGroupSubName;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::get_SubscriptionProductOfferingID(long *pVal)
{
	*pVal = mSubscriptionProductOfferingID;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateSubscription::put_SubscriptionProductOfferingID(long newVal)
{
	mSubscriptionProductOfferingID = newVal;
	return S_OK;
}
