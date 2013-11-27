// MTXmlType.h : Declaration of the CMTXmlType

#ifndef __MTXMLTYPE_H_
#define __MTXMLTYPE_H_

#include "resource.h"       // main symbols
#include <metra.h>
#include "SchemaObjects.h"

/////////////////////////////////////////////////////////////////////////////
// CMTXmlType
class ATL_NO_VTABLE CMTXmlType : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTXmlType, &CLSID_MTXmlType>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTXmlType, &IID_IMTXmlType, &LIBID_SCHEMAREADERLib>
{
public:
	CMTXmlType()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTXMLTYPE)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTXmlType)
	COM_INTERFACE_ENTRY(IMTXmlType)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTXmlType
public:
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(get_Item)(/*[in]*/ long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
public: // non COM methods
	STDMETHOD(get_RequiredAttrs)(/*[out, retval]*/ IMTRequiredAttrs* *pVal);
	STDMETHOD(get_Element)(/*[in]*/ BSTR aElementName, /*[out, retval]*/ IMTXmlElement* *pVal);

	void SetType(MTSchemaType* apType) { mpType = apType; }
protected:
	MTSchemaType* mpType;
};

#endif //__MTXMLTYPE_H_
