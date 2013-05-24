// MTAssignmentAction.h : Declaration of the CMTAssignmentAction

#ifndef __MTASSIGNMENTACTION_H_
#define __MTASSIGNMENTACTION_H_

#include "resource.h"       // main symbols

#include <autologger.h>

#if 0
namespace {
  char AssignmentActionMsg[] = "RuleSetConfig";
}
#endif

/////////////////////////////////////////////////////////////////////////////
// CMTAssignmentAction
class ATL_NO_VTABLE CMTAssignmentAction : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAssignmentAction, &CLSID_MTAssignmentAction>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAssignmentAction, &IID_IMTAssignmentAction, &LIBID_MTRULESETLib>
{
public:
	CMTAssignmentAction()
	{
	}

	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTASSIGNMENTACTION)

DECLARE_GET_CONTROLLING_UNKNOWN()
DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAssignmentAction)
	COM_INTERFACE_ENTRY(IMTAssignmentAction)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAssignmentAction
public:
	STDMETHOD(get_PropertyValue)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_PropertyValue)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_PropertyName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_PropertyName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_PropertyType)(/*[out, retval]*/ ::PropValType *pVal);
	STDMETHOD(put_PropertyType)(/*[in]*/ ::PropValType val);
	STDMETHOD(get_EnumType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumType)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EnumSpace)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumSpace)(/*[in]*/ BSTR newVal);


private:
	_bstr_t mPropName;
	_variant_t mValue;
	::PropValType mType;
	_bstr_t mEnumType;
	_bstr_t mEnumSpace;

	CComPtr<IUnknown> m_pUnkMarshaler;
};

#endif //__MTASSIGNMENTACTION_H_
