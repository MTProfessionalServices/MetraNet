/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header: PropertiesBase.h, 8, 10/1/2001 11:55:30 AM, Ralf Boeck$
* 
***************************************************************************/

#ifndef __PROPERTIESBASE_H_
#define __PROPERTIESBASE_H_

#include <comdef.h>


const long PROPERTIES_BASE_NO_ID = -1L; //value of no ID

#import "MTProductCatalog.tlb" rename ("EOF", "RowsetEOF")

// ----------------------------------------------------------------
// Object:      PropertiesBase
// Description: base class for com objects implementing get_Properties()
//
//              Here's "How to implement MTProperties in 25 easy steps":
//
//              (1) make sure the system knows the meta data for the new class "MyObj":
//
//              (1a) in MtProductCatalog.idl:
//                   add MyObj as a new enum value to MTPCEntityType enum
//
//              (1b) in MTProductCatalogMetaData.h:
//                   add MyObj as a new enum value to MetaDataSetIndexType
//
//              (1c) in MTProductCatalogMetaData.cpp:
//                   modify CMTProductCatalogMetaData::EntityTypeToIndex()
//                   to add a new enum mapping for MyObj
//
//              (1d) in MTProductCatalogMetaData.cpp:
//                   modify CMTProductCatalogMetaData::LoadPropertyMetaData()
//                   to set up the meta data of MyObj
//
//              (2) derive from PropertiesBase and add DEFINE_MT_PROPERTIES_BASE_METHODS:
//
//                  class ATL_NO_VTABLE CMyObj : 
//                    public CComObjectRootEx ...,
//                    public PropertiesBase
//                  {
//                    DEFINE_MT_PROPERTIES_BASE_METHODS
//                    ...
//                  }
//
//              (3) call LoadPropertiesMetaData() in FinalConstruct(), passing in
//                  the correct entity type:
//
//                  HRESULT CMyObj::FinalConstruct()
//                  { ...
//                     LoadPropertiesMetaData( PCENTITY_TYPE_MY_OBJ );
//                  }
//
//              (4) in each accessor / mutator call GetPropertyValue/PutPropertyValue
//                  passing in the name of the property:
//
//                  STDMETHODIMP CMyObj::get_Name(BSTR *pVal)
//                  { return GetPropertyValue("Name", pVal); }
//
//                  STDMETHODIMP CMyObj::put_Name(BSTR newVal)
//                  { return PutPropertyValue("Name", newVal); }
//
// Note:         To avoid the DEFINE_MT_PROPERTIES_BASE_METHODS macro, PropertiesBase could
//               have been implemented using a template instead. Templates require 
//               coding in the .h file and add complexity. The same issue occurs
//               in the PriceableItem.h.
//               The macro implementation was found to be easier to understand and maintain.

class PropertiesBase  
{

protected:
	PropertiesBase();
	virtual ~PropertiesBase();

	void LoadPropertiesMetaData (MTPCEntityType aEntityType);

	STDMETHOD(get_Properties)(/*[out, retval]*/ IMTProperties  **pVal);

	MTPRODUCTCATALOGLib::IMTPropertyPtr GetPropertyPtr(char* apPropertyName);
	HRESULT GetPropertyValue(char* apPropertyName, BSTR *apVal);
	HRESULT PutPropertyValue(char* apPropertyName, BSTR aNewVal);
	HRESULT GetPropertyValue(char* apPropertyName, VARIANT *apVal);
	HRESULT PutPropertyValue(char* apPropertyName, VARIANT aNewVal);
	HRESULT GetPropertyValue(char* apPropertyName, long *apVal);
	HRESULT PutPropertyValue(char* apPropertyName, long aNewVal);
	HRESULT GetPropertyValue(char* apPropertyName, VARIANT_BOOL *apVal);
	HRESULT PutPropertyValue(char* apPropertyName, VARIANT_BOOL aNewVal);
	HRESULT GetPropertyValue(char* apPropertyName, DATE *apVal);
	HRESULT PutPropertyValue(char* apPropertyName, DATE aNewVal);
	HRESULT GetPropertyValue(char* apPropertyName, DECIMAL *apVal);
	HRESULT PutPropertyValue(char* apPropertyName, DECIMAL aNewVal);
	HRESULT GetPropertyObject(char* apPropertyName, IDispatch**apObject);
	HRESULT PutPropertyObject(char* apPropertyName, IDispatch* apObject);

	long GetID();
	bool HasID();

	void ValidateProperties();
	void CopyExtendedProperties(IMTProperties* targetProps);

	//overridable methods
	virtual HRESULT OnGetProperties();

private:

//data
	CComPtr<IMTProperties> mPropertiesPtr;
};

#define DEFINE_MT_PROPERTIES_BASE_METHODS1				\
	STDMETHOD(get_Properties)(/*[out, retval]*/ IDispatch  **pVal)		\
	{																																	\
		HRESULT hr = OnGetProperties();																	\
		if(FAILED(hr))																									\
			return hr;																										\
		CComPtr<IMTProperties> ptr;																			\
		hr = PropertiesBase::get_Properties(&ptr);											\
		if(FAILED(hr))																									\
			return hr;																										\
		(*pVal) = (IDispatch*) ptr.Detach();														\
		return S_OK;																										\
	}



// macro that needs to be included in all derived classes
#define DEFINE_MT_PROPERTIES_BASE_METHODS															\
	STDMETHOD(get_Properties)(/*[out, retval]*/ IMTProperties  **pVal)	\
	{																																		\
		HRESULT	hr = OnGetProperties();																		\
		if(FAILED(hr))																										\
			return hr;																											\
		return PropertiesBase::get_Properties(pVal);											\
	}


#endif // __PROPERTIESBASE_H_
