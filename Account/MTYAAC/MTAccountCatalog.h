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

#ifndef __MTACCOUNTCATALOG_H_
#define __MTACCOUNTCATALOG_H_

#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTAccountCatalog
class ATL_NO_VTABLE CMTAccountCatalog : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountCatalog, &CLSID_MTAccountCatalog>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAccountCatalog, &IID_IMTAccountCatalog, &LIBID_MTYAACLib>
{
public:
	CMTAccountCatalog();

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTCATALOG)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountCatalog)
	COM_INTERFACE_ENTRY(IMTAccountCatalog)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();
	void FinalRelease();


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAccountCatalog
public:
	STDMETHOD(Refresh)();
  STDMETHOD(GetMAMFilter)(/*[out,retval]*/ IMTDataFilter** apFilter);
  STDMETHOD(GetAccountByName)(BSTR aName,BSTR aNamespace,VARIANT RefDate,IMTYAAC **apYAAC);
  STDMETHOD(GetAccountMetaData)(/*[out,retval]*/ IMTPropertyMetaDataSet** apMetaData);
  STDMETHOD(GetAccount)(/*[in]*/ long aAccountID,VARIANT RefDate,/*[out,retval]*/ IMTYAAC** apYAAC);
	STDMETHOD(GetActorAccount)(VARIANT RefDate,/*[out,retval]*/ IMTYAAC** apYAAC);
	STDMETHOD(FindAccountByIDAsRowset)(/*[in]*/ DATE aRefDate, /*[in]*/ long aAccountID, /*[in, optional]*/VARIANT trx, /*[out,retval]*/ IMTSQLRowset** apRowset);
  STDMETHOD(FindAccountByNameAsRowset)(DATE aRefDate, BSTR aName, BSTR aNamespace, /*[in, optional]*/VARIANT trx, IMTSQLRowset **apRowset);
	STDMETHOD(FindAccountsAsRowset)(/*[in]*/ DATE aRefDate, /*[in]*/ IMTCollection* apColumns, /*[in]*/ IMTDataFilter* apFilter,  /*[in]*/ IMTDataFilter* apJoinFilter, /*[in]*/ IMTCollection* apOrder, /*[in]*/ long aMaxRows, /*[out]*/ VARIANT* apMoreRows, /*[in, optional]*/VARIANT trx, /*[out,retval]*/ IMTSQLRowset** apRowset);
	STDMETHOD(GenerateAccountSearchQuery)(/*[in]*/ DATE aRefDate, /*[in]*/ IMTCollection* apColumns, /*[in]*/ IMTDataFilter* apFilter,  /*[in]*/ IMTDataFilter* apJoinFilter, /*[in]*/ IMTCollection* apOrder, /*[in]*/ long aMaxRows, /*[out,retval]*/ BSTR * apQuery);
	STDMETHOD(Init)(/*[in]*/ IMTSessionContext* apCTX);
  STDMETHOD(BatchCreateOrUpdateOwnerhip)
  ( IMTCollection* pCol,
    IMTProgress* pProgress,
    VARIANT transaction,
    IMTRowSet** ppRowset);
  STDMETHOD(BatchDeleteOwnerhip)
  ( IMTCollection* pCol,
    IMTProgress* pProgress,
    VARIANT transaction,
    IMTRowSet** ppRowset);

  /* Begin - Added for Kona Account Types Feature */

  STDMETHOD (GetAllAccountTypes)(/*[out, retval]*/  IMTCollection** apTypes);
  STDMETHOD (GetAllAccountTypesAsRowset)(/*[out, retval] */ IMTSQLRowset** apRowset);
  STDMETHOD (GetAccountTypeByName)(/*[in]*/ BSTR aName, /*[out, retval]*/ IMTAccountType** apAccType);
  STDMETHOD (GetAccountTypeByID) (/*[in]*/ long aType, /*[out, retval]*/ IMTAccountType** apAccType);
  STDMETHOD (FindAllAccountTypesWithOperation) (/*[in]*/ BSTR operation, /*[out, retval]*/  IMTCollectionReadOnly** apTypes);
  /* End - Added for Kona Account Types Feature */

  STDMETHOD(GenerateParameterizedAccountSearchQuery)(/*[in]*/ DATE aRefDate, /*[in]*/ IMTCollection* apColumns, /*[in]*/ IMTDataFilter* apFilter,  /*[in]*/ IMTDataFilter* apJoinFilter, /*[in]*/ IMTCollection* apOrder, /*[in]*/ long aMaxRows, /*[out,retval]*/ BSTR * apQuery);
private:
  MTYAACLib::IMTYAACPtr InternalGetActorAccount(VARIANT RefDate);
  MTENUMCONFIGLib::IEnumConfigPtr InternalGetEnumConfig();
  wstring GetMAMStateFilterClause();

	CComPtr<IUnknown> m_pUnkMarshaler;
  bool mInitialized;
  
  //cached data:
  MTYAACLib::IMTSessionContextPtr mSessionContext;
  MTYAACLib::IMTYAACPtr mActorAccount;
 	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
  wstring mMAMStateFilterClause;
};

#endif //__MTACCOUNTCATALOG_H_
