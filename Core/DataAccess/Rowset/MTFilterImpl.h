	
// MTilter.h : Declaration of the CMTilter

#ifndef __MTFILTER_H_
#define __MTFILTER_H_

#include "Rowset.h"
#include "resource.h"       // main symbols
#include <vector>
#include <comutil.h>
namespace MTFilterNamespace
{
	class _CopyMapItem;
	typedef std::vector<CComPtr<IMTFilterItem> > FilterProp;
	typedef CComEnumOnSTL<IEnumVARIANT, &IID_IEnumVARIANT, VARIANT, _CopyMapItem, FilterProp> VarEnum;
	typedef ICollectionOnSTLImpl<IMTDataFilter, FilterProp, VARIANT, _CopyMapItem, VarEnum> CollImpl;

	class _CopyMapItem
	{
	public:
		static HRESULT copy(VARIANT* p1, 
							const CComPtr<IMTFilterItem> * p2) 
		{
			CComVariant var (*p2);
			return VariantCopy(p1, &var);
		}
		
		static void init(VARIANT* p) {p->vt = VT_EMPTY;}
		static void destroy(VARIANT* p) {VariantClear(p);}
	};
}


/////////////////////////////////////////////////////////////////////////////
// CMTFilter
class ATL_NO_VTABLE CMTFilter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTFilter, &CLSID_MTDataFilter>,
	public ISupportErrorInfo,
	public IDispatchImpl<MTFilterNamespace::CollImpl, &IID_IMTDataFilter, &LIBID_ROWSETLib>
{
public:
	CMTFilter()
  {
    mIsOracle = VARIANT_FALSE;
	// ESR-3281, default mEscapeString to FALSE, needs to be set to true when using IMTDataFilter
	mEscapeString = VARIANT_FALSE;
    m_pUnkMarshaler = NULL;
  }
	

DECLARE_REGISTRY_RESOURCEID(IDR_MTFILTER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTFilter)
	COM_INTERFACE_ENTRY(IMTDataFilter)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		mIsWhereClause = VARIANT_TRUE;
		// ESR-3281, default mEscapeString to FALSE, needs to be set to true when using IMTDataFilter
		mEscapeString = VARIANT_FALSE;

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

// IMTFilter
public:
	STDMETHOD(CreateMergedFilter)(/*[in]*/ IMTDataFilter* pFilter,MTMergeAction aMergeAction,
		/*[out,retval]*/ IMTDataFilter** pMergedFilter);
	STDMETHOD(Clear)();
	STDMETHOD(Remove)(/*[in]*/ long aIndex);
	STDMETHOD(Add)(/*[in]*/ BSTR propName,/*[in]*/ VARIANT aOperator,/*[in]*/ VARIANT Value);
//	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Item)(long aIndex,/*[out, retval]*/ IMTFilterItem* *pVal);
	STDMETHOD(get_FilterString)(BSTR* pFilterStr);
	STDMETHOD(put_FilterString)(BSTR pFilterStr);
  STDMETHOD(AddIsNull)(/*[in]*/ BSTR propName);
  STDMETHOD(AddIsNotNull)(/*[in]*/ BSTR propName);
	STDMETHOD(put_IsWhereClause)(/*[in]*/ VARIANT_BOOL isWhere);
	STDMETHOD(get_IsWhereClause)(/*[out, retval]*/ VARIANT_BOOL *val);
  STDMETHOD(put_IsOracle)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_IsOracle)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	// ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode,(i.e ADO.NET record sets) 
	// then "Escape" the string with ("N"), (ADO disconnected record sets DO NOT support unicode)
	STDMETHOD(put_EscapeString)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_EscapeString)(/*[out, retval]*/ VARIANT_BOOL *pVal);


	protected:

	// only used if as the result of a merge
	_bstr_t mFilterString;
  VARIANT_BOOL mIsOracle;
	VARIANT_BOOL mIsWhereClause;
	// ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode,(i.e ADO.NET record sets) 
	// then "Escape" the string with ("N"), (ADO disconnected record sets DO NOT support unicode)
	VARIANT_BOOL mEscapeString;

};

#endif //__MTFILTER_H_

