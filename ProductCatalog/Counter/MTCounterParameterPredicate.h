	
// MTCounterParameterPredicate.h : Declaration of the CMTCounterParameterPredicate

#ifndef __MTCOUNTERPARAMETERPREDICATE_H_
#define __MTCOUNTERPARAMETERPREDICATE_H_

#include "resource.h"       // main symbols
#include "counterincludes.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterParameterPredicate
class ATL_NO_VTABLE CMTCounterParameterPredicate : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCounterParameterPredicate, &CLSID_MTCounterParameterPredicate>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCounterParameterPredicate, &IID_IMTCounterParameterPredicate, &LIBID_MTCOUNTERLib>
{
public:
	CMTCounterParameterPredicate()
	{
		m_pUnkMarshaler = NULL;
    mOperator = OPERATOR_TYPE_NONE;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERPARAMETERPREDICATE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCounterParameterPredicate)
	COM_INTERFACE_ENTRY(IMTCounterParameterPredicate)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		HRESULT hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);
    if(FAILED(hr))
      return hr;
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
  STDMETHOD(get_Operator)(/*[out, retval]*/ MTOperatorType* pVal);
	STDMETHOD(put_Operator)(/*[in]*/ MTOperatorType newVal);
	

// IMTCounterParameterPredicate
public:
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_ProductViewName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ProductViewName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ProductViewProperty)(/*[out, retval]*/ IProductViewProperty* *pVal);
	STDMETHOD(put_ProductViewProperty)(/*[in]*/ IProductViewProperty* newVal);
	STDMETHOD(get_Value)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_Value)(/*[in]*/ VARIANT newVal);
  STDMETHOD(get_CounterParameter)(/*[out, retval]*/ IMTCounterParameter **pVal);
	STDMETHOD(put_CounterParameter)(/*[in]*/ IMTCounterParameter* newVal);
  STDMETHOD(ToString)(/*[out, retval]*/ BSTR *pVal);
private:
  MTOperatorType mOperator;
  _variant_t mValue;
  MTPRODUCTVIEWLib::IProductViewPropertyPtr mPVProperty;
  MTCOUNTERLib::IMTCounterParameterPtr mCounterParam;
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
  _bstr_t mPVName;
  long mID;
};

#endif //__MTCOUNTERPARAMETERPREDICATE_H_
