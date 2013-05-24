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

#ifndef __MTACCOUNTTEMPLATE_H_
#define __MTACCOUNTTEMPLATE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTAccountTemplate
class ATL_NO_VTABLE CMTAccountTemplate : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountTemplate, &CLSID_MTAccountTemplate>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAccountTemplate, &IID_IMTAccountTemplate, &LIBID_MTYAACLib>
{
public:
	CMTAccountTemplate() :
			mID(-1),
			mAccountID(-1),
      mCorporateAccountID(-1),
			mDateCreated(0),
			bApplyDefaultPolicy(false)
	{

		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTTEMPLATE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountTemplate)
	COM_INTERFACE_ENTRY(IMTAccountTemplate)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		mProp.CreateInstance(__uuidof(MTYAACLib::MTAccountTemplateProperties));
		mSubscriptions.CreateInstance(__uuidof(MTYAACLib::MTAccountTemplateSubscriptions));
    MTYAACLib::IMTAccountTemplatePtr This = this;
    mSubscriptions->AccountTemplate = This;

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAccountTemplate
public:
	STDMETHOD(NearestParentInfo)(/*[in, optional]*/ VARIANT vRefDate, IMTSQLRowset** ppRowset);
	STDMETHOD(Clear)();
  STDMETHOD(CopyTemplateFromParent)(/*[in, optional]*/ VARIANT vRefDate);
  STDMETHOD(CopyTemplateFromFolder)(long aFolderID, /*[in, optional]*/ VARIANT vRefDate);
	STDMETHOD(get_Properties)(/*[out, retval]*/ IMTAccountTemplateProperties** pVal);
	STDMETHOD(put_Properties)(/*[in]*/ IMTAccountTemplateProperties* newVal);
	STDMETHOD(get_ApplyDefaultSecurityPolicy)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ApplyDefaultSecurityPolicy)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	
	STDMETHOD(get_TemplateAccountName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_TemplateAccountName)(/*[in]*/ BSTR newVal);
	
	STDMETHOD(get_TemplateAccountNameSpace)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_TemplateAccountNameSpace)(/*[in]*/ BSTR newVal);

	STDMETHOD(get_TemplateAccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_TemplateAccountID)(/*[in]*/ long newVal);
	
	
	STDMETHOD(get_DateCrt)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_DateCrt)(/*[in]*/ DATE newVal);
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(GetSubscriptionsAsRowSet)(/*[out, retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(GetAvailableProductOfferingsAsRowset)(VARIANT RefDate,IMTSQLRowset **ppRowset);
	STDMETHOD(GetAvailableGroupSubscriptionsAsRowset)(VARIANT RefDate,IMTSQLRowset **ppRowset);
	STDMETHOD(LoadMainMembers)(/*in*/ long aAccountTypeID, /*[in, optional]*/ VARIANT vRefDate, /*[out, retval]*/ VARIANT_BOOL* bRetVal);
	STDMETHOD(LoadSubscription)(/*[out, retval]*/ VARIANT_BOOL* bRetVal);
	STDMETHOD(LoadProperties)(/*[out, retval]*/ VARIANT_BOOL* bRetVal);
	STDMETHOD(Load)(/*[in, optional]*/ VARIANT vRefDate, /*[out, retval]*/ VARIANT_BOOL* bRetVal);
	STDMETHOD(SaveSubscriptions)(/*[out, retval]*/ VARIANT_BOOL* bRetVal);
	STDMETHOD(SaveMainMember)(/*[in, optional]*/ VARIANT vRefDate, /*[out, retval]*/ VARIANT_BOOL* bRetVal);
	STDMETHOD(SaveProperties)(/*[out, retval]*/ VARIANT_BOOL* bRetVal);
	STDMETHOD(Save)(/*[in, optional*/ VARIANT vRefDate, /*[out, retval]*/ VARIANT_BOOL* bRetVal);
	STDMETHOD(Initialize)(/*[in]*/ IMTSessionContext* pCTX,/*[in]*/ long aAccountID, /*in*/ long aCorporateID, /*in*/ long aAccountTypeID, /*[in, optional]*/ VARIANT vRefDate);
	STDMETHOD(get_Subscriptions)(/*[out, retval]*/ IMTAccountTemplateSubscriptions** pVal);
  STDMETHOD(get_TemplateAccountTypeID)(/*[out, retval]*/ long *pVal);
  STDMETHOD(put_TemplateAccountTypeID)(/*[in]*/ long newVal);
protected:
	long mID;
	long mAccountID;
	long mTemplateAccountID;
  long mAccountTypeID;
	_bstr_t mTemplateAccountName;
	_bstr_t mTemplateAccountNameSpace;
  long mCorporateAccountID;
	DATE mDateCreated;
	_bstr_t mName;
	_bstr_t mDesc;
	bool bApplyDefaultPolicy;
	MTYAACLib::IMTAccountTemplatePropertiesPtr mProp;
	MTYAACLib::IMTAccountTemplateSubscriptionsPtr mSubscriptions;
	MTAUTHLib::IMTSessionContextPtr mCTX;
};

#endif //__MTACCOUNTTEMPLATE_H_
