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
 * $Header: c:\development35\ProductCatalog\Counter\MTCounter.h, 28, 7/9/2002 3:56:14 PM, Alon Becker$
 *
 ***************************************************************************/

#ifndef __MTCOUNTER_H_
#define __MTCOUNTER_H_

#include "counterincludes.h"
#include <PropertiesBase.h>

#include "FormulaAdapter.h"



#define DEFAULT_ALIAS L"COUNTER"
#define RESERVED_USAGE_ALIAS L"ReservedUsageTableAlias"
#define USAGE_TABLE L"t_acc_usage"


//#define PROCESS_HARCODED_PARAMS


/////////////////////////////////////////////////////////////////////////////
// CMTCounter
class ATL_NO_VTABLE CMTCounter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCounter, &CLSID_MTCounter>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCounter, &IID_IMTCounter, &LIBID_MTCOUNTERLib>,
  //public CMTPCBase,
	public PropertiesBase
{
  friend class CMTCounterParameter;
public:
  CMTCounter() : mpFormulaAdapter(new CMTFormulaAdapter())
	{
	
	}
  virtual ~CMTCounter()
	{
    if(mpFormulaAdapter)
    {
      delete mpFormulaAdapter;
      mpFormulaAdapter = NULL;
    }
	
	}
	HRESULT FinalConstruct();
 
	void FinalRelease();
	


DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTER)

DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCounter)
	COM_INTERFACE_ENTRY(IMTCounter)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
  COM_INTERFACE_ENTRY_FUNC(IID_NULL,0,_This)
END_COM_MAP()



// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCounter
public:
	STDMETHOD(SetSharedParameter)(/*[in]*/BSTR aParamName, /*[in]*/IMTCounterParameter* apParam);
	STDMETHOD(GetParameter)(/*[in]*/BSTR aParamName, /*[out, retval]*/IMTCounterParameter** apParam);
	STDMETHOD(Remove)();
	DEFINE_MT_PROPERTIES_BASE_METHODS1
	STDMETHOD(get_Alias)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Alias)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Type)(/*[out, retval]*/ IMTCounterType** pVal = NULL);
	STDMETHOD(put_Type)(/*[in]*/ IMTCounterType* newVal);
	STDMETHOD(get_TypeID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_TypeID)(/*[in]*/ long newVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[out, retval]*/ long newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(Load)(/*[in]*/long aDBID);
	STDMETHOD(get_Parameters)(/*[out, retval]*/ IMTCollection** pVal = NULL);
	STDMETHOD(Save)(/*[out, retval]*/long* aDBID);
	STDMETHOD(Execute)(long aStrategy, DATE aStartDate, DATE aEndDate, IMTCollection* apAccountList, IMTSQLRowset** aCounterValue);
	STDMETHOD(SetParameter)(/*[in]*/BSTR aParamName, /*[in]*/BSTR aParam, /*[in]*/VARIANT aDontValidateString);
	STDMETHOD(get_Formula)(MTViewPreference aFormulaView, /*[out, retval]*/ BSTR *pVal = NULL);
  STDMETHOD(get_PriceableItemID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PriceableItemID)(/*[out, retval]*/ long newVal);

  //CMTPCBase override
	//virtual void OnSetSessionContext(IMTSessionContext* apSessionContext);
private:
	STDMETHOD(LoadParams) (IMTCollection** apParams = NULL);
	BOOL HasID(){return (mlID > 0);}
  MTCOUNTERLib::IMTCounterTypePtr mpType;
  MTPRODUCTCATALOGLib::IMTProductCatalogPtr mpPC;
	MTObjectCollection<IMTCounterParameter>* mpParams;
	HRESULT GetHardcodedParameterValues(vector<_bstr_t>& aValues, unsigned int aPos=0);
	HRESULT ConstructSQLFormula(map<_bstr_t, _bstr_t>* apViewNames = NULL);
	HRESULT ConstructUserFormula();
	HRESULT AddHardcodedParameters();
  STDMETHODIMP ConstructExpandedFormula();
	//Reset state to empty
	HRESULT Reset();

	HRESULT CMTCounter::ConstructDiscountQueryStatement();
	HRESULT CMTCounter::ConstructAggrQueryStatement(_bstr_t& aStr, map<_bstr_t, _bstr_t>* apViewNames = NULL);

	_bstr_t mDiscountQueryStatement;
	_bstr_t mName;
	_bstr_t mDescription;
	_bstr_t mFormula;
	_bstr_t mAlias;
	_bstr_t mExpandedFormula;
	_bstr_t mSQLFormula;
	_bstr_t mUserFormula;
	long mlID;
	long mlTypeID;
	long mlNewTypeID;
	long mlNumSetParams;
	BOOL mbTypeChanged;
	BOOL mbAllHardcodedParametersSet;
  long mPIID;
  
	
	CComPtr<IUnknown> mUnkMarshalerPtr;
  CMTFormulaAdapter* mpFormulaAdapter;
};

#endif //__MTCOUNTER_H_
