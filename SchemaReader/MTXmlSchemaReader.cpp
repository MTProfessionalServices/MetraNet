// MTXmlSchemaReader.cpp : Implementation of CMTXmlSchemaReader
#include "StdAfx.h"
#include <metra.h>
#include "SchemaReader.h"
#include "MTXmlSchemaReader.h"
#include "MTXmlElement.h"
#include "MTXmlType.h"
#include <mtprogids.h>
#include <mtcomerr.h>
#include <string>

using std::string;

#import <MTConfigLib.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTXmlSchemaReader
STDMETHODIMP CMTXmlSchemaReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTXmlElement
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}



/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlSchemaReader::Initialize
// Description	  : 
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTXmlSchemaReader::Initialize(BSTR aFileName,BSTR aNamespacePrefix)
{
	// TODO: Add your implementation code here
	VARIANT_BOOL aUnused;

	MTConfigLib::IMTConfigPtr aMTConfig(MTPROGID_CONFIG);
	
	HRESULT hr = S_OK;
	try {
		// step 1: read the file into a propset
		MTConfigLib::IMTConfigPropSetPtr aPropSet = aMTConfig->ReadConfiguration(aFileName,&aUnused);

		// step 2: attempt to parse the schema
		_bstr_t aNamespacePrefixBstr(aNamespacePrefix);
		mSchema.ProcessSchema(aPropSet,(const char*)aNamespacePrefixBstr);
	}

	catch(ErrorObject& aError) {
		hr = Error(aError.GetProgrammerDetail().c_str());
	}
	catch(_com_error& aError) {
		_bstr_t aErrorStr = aError.Description();
		hr = ReturnComError(aError);
	}
	return hr;
}



/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlSchemaReader::get_Item
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlSchemaReader::get_Item(long aIndex, VARIANT *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	ASSERT(aIndex >= 0 && aIndex < (long)mSchema.GetElementOrderedList().size());

	CComObject<CMTXmlElement> * pXmlElement;
	CComObject<CMTXmlElement>::CreateInstance(&pXmlElement);
	if (!pXmlElement)
		return E_OUTOFMEMORY;

	// have to AddRef or the count will be 0
	IDispatch* pElementInterface;

	HRESULT hr =
		pXmlElement->QueryInterface(IID_IDispatch,
												 reinterpret_cast<void**>(&pElementInterface));
	if(SUCCEEDED(hr)) {

		string& aTempStr = mSchema.GetElementOrderedList()[aIndex];
		MTSchemaElement* pElement = mSchema.GetElementDictionary()[aTempStr];
		ASSERT(pElement);
		pXmlElement->SetElement(pElement);
		_variant_t aVariant(pElementInterface,false);
		::VariantClear(pVal);
		::VariantCopy(pVal,&aVariant);
	}

	return hr;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlSchemaReader::get__NewEnum
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlSchemaReader::get__NewEnum(LPUNKNOWN *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;
	return E_NOTIMPL;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlSchemaReader::get_Count
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlSchemaReader::get_Count(long *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	*pVal = mSchema.GetElementOrderedList().size();
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlSchemaReader::get_Element
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlSchemaReader::get_Element(BSTR aElementName, IMTXmlElement **pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;
	HRESULT hr;

	MTSchemaElement* aElement;

	string ElementNameStr = _bstr_t(aElementName);
	ElementNodeIterator it = mSchema.GetElementDictionary().find(ElementNameStr);
	if(it != mSchema.GetElementDictionary().end()) {
		aElement = it->second;
		ASSERT(aElement);
	
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
	else {
		hr = E_FAIL;
	}	

	return hr;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlSchemaReader::get_Type
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlSchemaReader::get_Type(BSTR aTypeName, IMTXmlType **pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;
	HRESULT hr;
	MTSchemaType* pType;
	
	string aTypeStr = _bstr_t(aTypeName);
	TypeIterator it = mSchema.GetTypeDictionary().find(aTypeStr);
	if(it != mSchema.GetTypeDictionary().end()) {
	
		pType = it->second;

		CComObject<CMTXmlType> * pXmlType;
		CComObject<CMTXmlType>::CreateInstance(&pXmlType);
		if (!pXmlType)
			return E_OUTOFMEMORY;

		hr = pXmlType->QueryInterface(IID_IMTXmlType,
													 reinterpret_cast<void**>(pVal));
		if(SUCCEEDED(hr)) {
			pXmlType->SetType(pType);
		}
	}
	else {
		hr = E_FAIL;
	}
	return hr;
}
