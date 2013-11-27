// MTXmlSchemaReader.h : Declaration of the CMTXmlSchemaReader

#ifndef __MTXMLSCHEMAREADER_H_
#define __MTXMLSCHEMAREADER_H_

#include "resource.h"       // main symbols
#include "SchemaObjects.h"

/////////////////////////////////////////////////////////////////////////////
// CMTXmlSchemaReader
class ATL_NO_VTABLE CMTXmlSchemaReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTXmlSchemaReader, &CLSID_MTXmlSchemaReader>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTXmlSchemaReader, &IID_IMTXmlSchemaReader, &LIBID_SCHEMAREADERLib>
{
public:
	CMTXmlSchemaReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTXMLSCHEMAREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTXmlSchemaReader)
	COM_INTERFACE_ENTRY(IMTXmlSchemaReader)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
// IMTXmlSchemaReader
public:
	STDMETHOD(get_Type)(/*[in]*/ BSTR aTypeName, /*[out, retval]*/ IMTXmlType* *pVal);
	STDMETHOD(get_Element)(/*[in]*/ BSTR aElementName, /*[out, retval]*/ IMTXmlElement* *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(get_Item)(/*[in]*/ long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(Initialize)(/*[in]*/ BSTR aFileName,BSTR aNamespacePrefix);

protected:
	MTschema mSchema;
};

#endif //__MTXMLSCHEMAREADER_H_
