// MTXmlElement.h : Declaration of the CMTXmlElement

#ifndef __MTXMLELEMENT_H_
#define __MTXMLELEMENT_H_
#pragma once

#include "resource.h"       // main symbols
#include <metra.h>
#include "SchemaObjects.h"

/////////////////////////////////////////////////////////////////////////////
// CMTXmlElement
class ATL_NO_VTABLE CMTXmlElement : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTXmlElement, &CLSID_MTXmlElement>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTXmlElement, &IID_IMTXmlElement, &LIBID_SCHEMAREADERLib>
{
public:
	CMTXmlElement() : mpElement(NULL) {}
	CMTXmlElement(MTSchemaElement* aElement) : mpElement(aElement)
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTXMLELEMENT)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTXmlElement)
	COM_INTERFACE_ENTRY(IMTXmlElement)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTXmlElement
public: // COM methods
	STDMETHOD(get_MaxOccurs)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_MinOccurs)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_IsSet)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_Type)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_FixedValue)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Fixed)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_InlineType)(/*[out, retval]*/ IMTXmlType* *pVal);

public:
	void SetElement(MTSchemaElement* aElement) { ASSERT(aElement); mpElement = aElement; }

protected:
	MTSchemaElement* mpElement;
};

#endif //__MTXMLELEMENT_H_
