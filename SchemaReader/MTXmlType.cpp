// MTXmlType.cpp : Implementation of CMTXmlType
#include "StdAfx.h"
#include "SchemaReader.h"
#include "MTXmlType.h"
#include "MTXmlElement.h"
#include "MTRequiredAttrs.h"

using std::string;

/////////////////////////////////////////////////////////////////////////////
// CMTXmlType

STDMETHODIMP CMTXmlType::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTXmlType
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

#define VALIDATE_PARAMS() \
	ASSERT(mpType && pVal); \
	if(!(mpType && pVal)) return E_POINTER; \


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlType::get_Name
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlType::get_Name(BSTR *pVal)
{
	VALIDATE_PARAMS();
	_bstr_t aTemp = mpType->GetName().c_str();
	*pVal = aTemp.copy();
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlType::get_Count
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlType::get_Count(long *pVal)
{
	VALIDATE_PARAMS();
	*pVal = mpType->GetElementList().size();
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlType::get_Item
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlType::get_Item(long aIndex, VARIANT *pVal)
{
	VALIDATE_PARAMS();

	CComObject<CMTXmlElement> * pXmlElement;
	CComObject<CMTXmlElement>::CreateInstance(&pXmlElement);
	if (!pXmlElement)
		return E_OUTOFMEMORY;

	// have to AddRef or the count will be 0
	IMTXmlElement* pElementInterface;

	HRESULT hr =
		pXmlElement->QueryInterface(IID_IMTXmlElement,
												 reinterpret_cast<void**>(&pElementInterface));
	if(SUCCEEDED(hr)) {

		MTSchemaElement* pElement = mpType->GetElementList()[aIndex];
		pXmlElement->SetElement(pElement);
		_variant_t aVariant = (IDispatch*)pElementInterface;
		::VariantClear(pVal);
		::VariantCopy(pVal,&aVariant);
	}

	return hr;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlType::get__NewEnum
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlType::get__NewEnum(LPUNKNOWN *pVal)
{
	VALIDATE_PARAMS();
	return E_NOTIMPL;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlType::get_Element
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlType::get_Element(BSTR aElementName, IMTXmlElement **pVal)
{
	MTSchemaElement* aElement;

	HRESULT hr = E_FAIL;
	string ElementNameStr = _bstr_t(aElementName);
	MTSchemaElementList& aElementList = mpType->GetElementList();

	for(unsigned int i=0;i<aElementList.size();i++) {
		if(aElementList[i]->GetName() == ElementNameStr) {
			aElement = aElementList[i];

			CComObject<CMTXmlElement> * pXmlElement;
			CComObject<CMTXmlElement>::CreateInstance(&pXmlElement);
			if (!pXmlElement)
				return E_OUTOFMEMORY;

			hr = pXmlElement->QueryInterface(IID_IMTXmlElement,
														 reinterpret_cast<void**>(pVal));
			if(SUCCEEDED(hr)) {
				pXmlElement->SetElement(aElement);
			}
		}
	}
	return hr;
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlType::get_Element
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlType::get_RequiredAttrs(IMTRequiredAttrs **pVal)
{
	ASSERT(pVal && mpType);
	if(!(pVal && mpType)) return E_POINTER;

	HRESULT hr = S_OK;

	AutoAttrList aAttrList = mpType->getAttrList();

	if(aAttrList) {
		CComObject<CMTRequiredAttrs> * pXmlElement;
		CComObject<CMTRequiredAttrs>::CreateInstance(&pXmlElement);

			hr = pXmlElement->QueryInterface(IID_IMTRequiredAttrs,
									 reinterpret_cast<void**>(pVal));
			if(SUCCEEDED(hr)) {
				pXmlElement->PutAttrList(aAttrList);
			}
	}
	else {
		*pVal = NULL;
	}

	return hr;
}
