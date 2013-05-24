	
// MTFilterItem.h : Declaration of the CMTFilterItem

#ifndef __MTFILTERITEM_H_
#define __MTFILTERITEM_H_

#include "Rowset.h"
#include "resource.h"       // main symbols
#include <comutil.h>

/////////////////////////////////////////////////////////////////////////////
// CMTFilterItem
class ATL_NO_VTABLE CMTFilterItem : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTFilterItem, &CLSID_MTFilterItem>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTFilterItem, &IID_IMTFilterItem, &LIBID_ROWSETLib>
{
public:
	CMTFilterItem()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTFILTERITEM)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTFilterItem)
	COM_INTERFACE_ENTRY(IMTFilterItem)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTFilterItem
public:
	STDMETHOD(get_Value)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_Value)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_Operator)(/*[out, retval]*/ MTOperatorType *pVal);
	STDMETHOD(put_Operator)(/*[in]*/ MTOperatorType newVal);
	STDMETHOD(get_PropertyName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_PropertyName)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_PropertyType)(/*[out, retval]*/ PropValType *pVal);
  STDMETHOD(put_PropertyType)(/*[in]*/ PropValType newVal);
	STDMETHOD(get_FilterString)(BSTR* pFilterStr);
	STDMETHOD(put_OperatorAsString)(BSTR pOperator);
  STDMETHOD(get_FilterCondition)(BSTR* pFilterCondition);
	STDMETHOD(put_IsWhereClause)(/*[in]*/ VARIANT_BOOL isWhere);
	STDMETHOD(get_IsWhereClause)(/*[out, retval]*/ VARIANT_BOOL *val);
  STDMETHOD(put_IsOracle)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_IsOracle)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	// ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode,(i.e ADO.NET record sets) 
	STDMETHOD(put_EscapeString)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_EscapeString)(/*[out, retval]*/ VARIANT_BOOL *pVal);

protected:
  _bstr_t GetStringValueForSQL();

	_variant_t mValue;
	MTOperatorType mOperator;
	_bstr_t mPropName;
  PropValType mPropType;
	VARIANT_BOOL mIsWhereClause;
  VARIANT_BOOL mIsOracle;
  // ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode,(i.e ADO.NET record sets)
  VARIANT_BOOL mEscapeString;
};

#endif //__MTFILTERITEM_H_
