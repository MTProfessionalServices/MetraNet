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


#ifndef __MTCOUNTERTYPE_H_
#define __MTCOUNTERTYPE_H_

#include "counterincludes.h"
#include <PropertiesBase.h>


/////////////////////////////////////////////////////////////////////////////
// CMTCounterType
class ATL_NO_VTABLE CMTCounterType : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCounterType, &CLSID_MTCounterType>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCounterType, &IID_IMTCounterType, &LIBID_MTCOUNTERLib>,
	public PropertiesBase
{
public:
	CMTCounterType()
	{
		mID = -1L;
		mpParams = NULL;
		mpCounters = NULL;
	}
	
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERTYPE)

DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCounterType)
	COM_INTERFACE_ENTRY(IMTCounterType)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCounterType
public:
	DEFINE_MT_PROPERTIES_BASE_METHODS1
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[out, retval]*/ long newVal);
	STDMETHOD(GetCounters)(/*[out, retval]*/IMTCollection** apCounters);
	STDMETHOD(GetCounter)(/*[in]*/long aDBID, /*[out, retval]*/IMTCounter** apCounter);
	STDMETHOD(RemoveCounter)(/*[in]*/long aDBID);
	STDMETHOD(CreateCounter)(/*[out, retval]*/IMTCounter** aCounterInstance);
	STDMETHOD(get_FormulaTemplate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_FormulaTemplate)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Parameters)(/*[out, retval]*/ IMTCollection** pVal);
	STDMETHOD(put_Parameters)(/*[in]*/ IMTCollection* pVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(Load)(/*[in]*/ long aDBID);
	STDMETHOD(LoadByName)(/*[in]*/ BSTR aName);
	STDMETHOD(Save)(/*[in]*/ long* aDBID);
	STDMETHOD(get_ValidForDistribution)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ValidForDistribution)(/*[in]*/ VARIANT_BOOL newVal);

private:
	//TODO: temp - use one from properties
	BOOL HasID(){return (mID > 0);}
	MTPRODUCTCATALOGLib::IMTProductCatalogPtr mPC;
	MTObjectCollection<IMTCounterParameter>* mpParams;
	MTObjectCollection<IMTCounter>* mpCounters;
	long mID;
	_bstr_t mFormulaTemplate;
	_bstr_t mName;
	_bstr_t mDescription;
	
	CComPtr<IUnknown> mUnkMarshalerPtr;
};

#endif //__MTCOUNTERTYPE_H_

