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

#ifndef __MTYAAC_H_
#define __MTYAAC_H_

#include "resource.h"       // main symbols
#include <MTAuth.h>
#include <MTObjectCollection.h>
#include <MTSecurityPrincipalImplbase.h>
#include "MTYAAC.h"
#include <map>

using std::map;
typedef map<int, MTYAACLib::IMTAccountTemplatePtr> TemplateMap;

/////////////////////////////////////////////////////////////////////////////
// CMTYAAC
class ATL_NO_VTABLE CMTYAAC : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTYAAC, &CLSID_MTYAAC>,
	public ISupportErrorInfo,
	public MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>
{
public:
	CMTYAAC() : 
			mbLoaded(false),
			mbFolder(false),
			mbBillable(false),
      mAccountID(-1),
      mCurrentFolderOwner(-1)
	{
		bstrYes = "1";
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTYAAC)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTYAAC)
	COM_INTERFACE_ENTRY(IMTYAAC)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IMTSecurityPrincipal)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
	COM_INTERFACE_ENTRY_FUNC(IID_NULL,0,_This)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>::put_PrincipalType(SUBSCRIBER_ACCOUNT_PRINCIPAL);	
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CMTYAAC & operator = (const CMTYAAC& arVal);

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

//   
  
  STDMETHODIMP LogAndReturnPrincipalError(_com_error& err)
  {
    return returnYAACError(err);
  }
  STDMETHODIMP LogPrincipalError(char* aMsg)
  {
    return LogYAACError(aMsg, LOG_DEBUG);
  }


// IMTYAAC
public:
	STDMETHOD(UpdateOwnedFolder)(/*[in]*/ long aFolderID);
	STDMETHOD(get_AccountExternalIdentifier)(BSTR *pVal);
	STDMETHOD(Refresh)(VARIANT RefDate);
	STDMETHOD(get_CurrentFolderOwner)(/*[out, retval]*/ long *pVal);
	STDMETHOD(SetOwnedFoldersBatch)(/*[in]*/ IMTCollectionEx* pCol,/*[in]*/ IMTProgress* pProgress,/*[out,retval]*/ IMTRowSet** ppErrors);
  STDMETHOD(get_AccountName)(BSTR *pVal);
  STDMETHOD(AccessibleCorporateAccounts)(VARIANT RefDate,IMTCollectionReadOnly** ppCol);
  STDMETHOD(get_Namespace)(BSTR* apVal);
  STDMETHOD(InitByName)(BSTR aName,BSTR aNamespace,IMTSessionContext* pCTX,VARIANT RefDate);
	STDMETHOD(GetDescendents)(/*[in]*/ IMTCollection* pCol,DATE RefDate,/*[in]*/ MTHierarchyPathWildCard treeHint,/*[in]*/ VARIANT_BOOL IncludeFolders, /*[in, optional]*/ VARIANT pAccountTypeNameList);
	STDMETHOD(CanManageAccount)(/*[out,retval]*/ VARIANT_BOOL* pRetVal);
	STDMETHOD(CopyConstruct)(/*[out, retval]*/ IMTYAAC** pNewYaac);
	STDMETHOD(get_AccountType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_CorporateAccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_HierarchyPath)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_LoginName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(Save)();
	STDMETHOD(get_IsFolder)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(GetAncestorMgr)(/*[out, reval]*/ IMTAncestorMgr** ppMgr);
	STDMETHOD(GetOwnedFolderList)(/*[out, retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(RemovedOwnedFolderById)(/*[in]*/ long aFolderID);
	STDMETHOD(AddOwnedFolderByID)(/*[in]*/ long aFolderID);
	STDMETHOD(GetStateHistory)(/*[in, optional]*/ VARIANT SystemDate,/*[out,retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(GetAccountStateMgr)(/*[out, retval]*/ IMTAccountStateManager** ppMgr);
	STDMETHOD(GetPaymentMgr)(/*[out, retval]*/ IMTPaymentMgr** ppPaymentMgr);
	STDMETHOD(InitAsSecuredResource)(/*[in]*/ long aAccountID,/*[in]*/ IMTSessionContext* pCTX,VARIANT RefDate);
	STDMETHOD(InitAsActor)(/*[in]*/ IMTSessionContext* pCTX,VARIANT RefDate);
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(GetAccountTemplate)(/*[in, optional]*/ VARIANT vRefDate, /*[in, optional]*/ VARIANT aAccountTypeID, /*[out, retval]*/ IMTAccountTemplate* *pVal);
	STDMETHOD(FromXML)(IMTSessionContext* aCtx, BSTR aXmlString);
	STDMETHOD(ToXML)(BSTR* apXmlString);
  STDMETHOD(DeleteTemplate)(/*[in, optional]*/ VARIANT aAccountTypeID, /*[out, retval]*/VARIANT_BOOL *bRetVal);
  STDMETHOD(GetOwnershipMgr)(/*[out, reval]*/ IDispatch** ppMgr);
  STDMETHOD(get_AccountTypeID)(/*[out, retval]*/ long *pVal);
  STDMETHOD(GetTemplatesAsRowset)(/*[in, optional]*/ VARIANT vRefDate, /*[out, retval]*/ IMTSQLRowset** ppRowset);
  STDMETHOD(GetAccountTemplateType)(/*[out, retval]*/ long *pVal);

 

  STDMETHOD(put_Billable)(/*[in]*/ VARIANT_BOOL newVal);
  STDMETHOD(put_Folder)(/*[in]*/ VARIANT_BOOL newVal);
  STDMETHOD(put_LoginName)(/*[in]*/ BSTR newVal);
  STDMETHOD(put_HierarchyPath)(/*[in]*/ BSTR newVal);
  STDMETHOD(put_CorporateAccountID)(/*[in]*/ long newVal);
  STDMETHOD(put_AccountTypeID)(/*[in]*/ long newVal);
  STDMETHOD(put_AccountType)(/*[in]*/ BSTR newVal);
  STDMETHOD(put_AccStatus)(/*[in]*/ BSTR newVal);
  STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
  STDMETHOD(put_NameSpace)(/*[in]*/ BSTR newVal);
  STDMETHOD(put_AccountName)(/*[in]*/ BSTR newVal);
  STDMETHOD(put_CurrentFolderOwner)(/*[in]*/ long newVal);
  STDMETHOD(put_Loaded)(/*[in]*/ VARIANT_BOOL newVal);
  STDMETHOD(put_AccountExternalIdentifier)(/*[in]*/ BSTR newVal);
  STDMETHOD(put_SessionContext)(/*[in]*/ IMTSessionContext* newVal);
  STDMETHOD(GetAvailableGroupSubscriptionsAsRowset)(DATE RefDate, VARIANT aFilter, IMTSQLRowset **ppRowset);
  

protected:
	MTYAACLib::IMTYAACPtr Me();
	void LookupAccountProperties(VARIANT RefDate);
  void LookupAccountByName(BSTR aName,BSTR aNamespace,VARIANT RefDate);
  void LookupAccountInternal(BSTR QueryFragment,VARIANT RefDate,long accountID,const char* ploginName);

protected: // properties
	// IMPORTANT: if you add new properties
	// make sure you modify operator=
	 
	bool mbLoaded;
	bool mbFolder;
	bool mbBillable;
	long mAccountID;
	_bstr_t mLoginName;
  _bstr_t mNameSpace;
	_bstr_t mHierarchyPath;
	long mCorporateAccountID;
	_bstr_t mAccountTypeStr;
  long mAccountTypeID;
	_bstr_t mAccStatus;
  _bstr_t mAccountName;
  long mCurrentFolderOwner;
  _bstr_t mExternalIdentifier;
  
protected: // properties that control cache of accessible corporate accounts
  GENERICCOLLECTIONLib::IMTCollectionPtr mAcessibleCol;
  void ManageAHAuthCheck(GENERICCOLLECTIONLib::IMTCollectionExPtr pCol);

protected:
	TemplateMap mTemplate;
	MTYAACLib::IMTPaymentMgrPtr mPaymentMgr;
	MTACCOUNTSTATESLib::IMTAccountStateManagerPtr mStateMgr;
	MTYAACLib::IMTAncestorMgrPtr mAncestorMgr;
  MetraTech_Accounts_Ownership::IOwnershipMgrPtr mOwnershipMgr;
  void InitPrincipalType();


private:
	_bstr_t bstrYes;
};


#endif //__MTYAAC_H_
