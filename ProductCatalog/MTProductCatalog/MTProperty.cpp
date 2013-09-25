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
* $Header: MTProperty.cpp, 13, 9/24/2001 12:50:02 PM, Carl Shimer$
* 
***************************************************************************/

#include "StdAfx.h"

#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalog.h"
#include "MTProperty.h"

/////////////////////////////////////////////////////////////////////////////
// CMTProperty

/******************************************* error interface ***/
STDMETHODIMP CMTProperty::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProperty
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/
CMTProperty::CMTProperty()
{
	mUnkMarshalerPtr = NULL;
	mMetaDataPtr = NULL;
}

HRESULT CMTProperty::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mUnkMarshalerPtr.p);
}

void CMTProperty::FinalRelease()
{
	mUnkMarshalerPtr.Release();
}


/********************************** IMTProperty***/

STDMETHODIMP CMTProperty::get_Value(VARIANT *pVal)
{
	if (!pVal)
		return E_POINTER;
	HRESULT hr(S_OK);

	::VariantInit(pVal);
	::VariantCopy(pVal, &mValue);

	return hr;
}

STDMETHODIMP CMTProperty::put_Value(VARIANT newVal)
{
	//TODO: autoconvert flag if needed
	HRESULT hr(S_OK);
	PropValType type;
	_bstr_t bstrEnumerator;
	long lVal;
	_variant_t vNewVal(newVal);
	
	hr = get_DataType(&type);
	
	if(FAILED(hr))
		return hr;
	try
	{
		switch(type) {
			case MTPRODUCTCATALOGLib::PROP_TYPE_ENUM: {
				try {
					MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
					switch(V_VT(&vNewVal)) {
						case VT_BSTR:
						case VT_LPSTR: {
							BSTR enumspace;
							BSTR enumtype;
							hr = get_EnumSpace(&enumspace);
							if(FAILED(hr))
								return hr;
							hr = get_EnumType(&enumtype);
							if(FAILED(hr))
								return hr;
							_bstr_t bstrEnumSpace(enumspace, false);
							_bstr_t bstrEnumType(enumtype, false);

							//Internally Enum properties are stored as strings;
							//the below method is only needed to validate the correctness of passed in value
							
							if (_bstr_t(vNewVal).length() != 0) //ESR-6206 Approvals /extendedprop.Edition Error on Product offer edit
	                        {//tried set NULL Value
	 	                    lVal = enumConfig->GetID(bstrEnumSpace, bstrEnumType, (_bstr_t)vNewVal);
	                        }
							mValue = vNewVal;
							break;
						}
						case VT_I2:
						case VT_I4: 
						case VT_DECIMAL: {
							//Fred really wanted a value instead of the enumerator
							bstrEnumerator = enumConfig->GetEnumeratorValueByID(vNewVal);
							if(bstrEnumerator.length() == 0)
								bstrEnumerator = enumConfig->GetEnumeratorByID(vNewVal);
							mValue = bstrEnumerator;
							break;
						}

						case VT_NULL:
            case VT_EMPTY:
            {
 							//TODO: NULL or EMPTY not allowed for required properties.
							// ASSERT(!"Enum value can not be set to VT_NULL or VT_EMPTY!");
              mValue = vNewVal;
              break;
            }

						default:
							ASSERT(!"Unknown or unsupported VARIANT!");
					}
				}
				catch(_com_error& e) {
					MT_THROW_COM_ERROR(e.Error());
				}
				break;
			}
			default:
				mValue = vNewVal;
		}
	}

	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTProperty::GetMetaData(/*[out, retval]*/ IMTPropertyMetaData** apMetaData)
{
	if (!apMetaData)
		return E_POINTER;
	
	mMetaDataPtr.CopyTo(apMetaData);

	return S_OK;
}

STDMETHODIMP CMTProperty::SetMetaData(/*[in]*/ IMTPropertyMetaData* apMetaData)
{
	mMetaDataPtr = apMetaData;

	return S_OK;
}

STDMETHODIMP CMTProperty::get_Name(BSTR *pVal)
{
	return mMetaDataPtr->get_Name( pVal);
}

STDMETHODIMP CMTProperty::get_DisplayName(BSTR *pVal)
{
	return mMetaDataPtr->get_DisplayName( pVal);
}

STDMETHODIMP CMTProperty::get_DataType(PropValType *pVal)
{
	return mMetaDataPtr->get_DataType( pVal);
}

STDMETHODIMP CMTProperty::get_DataTypeAsString(BSTR *pVal)
{
	return mMetaDataPtr->get_DataTypeAsString( pVal);
}

STDMETHODIMP CMTProperty::get_Length(long *pVal)
{
	return mMetaDataPtr->get_Length( pVal);
}

STDMETHODIMP CMTProperty::get_EnumSpace(BSTR *pVal)
{
	return mMetaDataPtr->get_EnumSpace( pVal);
}

STDMETHODIMP CMTProperty::get_EnumType(BSTR *pVal)
{
	return mMetaDataPtr->get_EnumType( pVal);
}

STDMETHODIMP CMTProperty::get_Required(VARIANT_BOOL *pVal)
{
	return mMetaDataPtr->get_Required( pVal);
}

STDMETHODIMP CMTProperty::get_Extended(VARIANT_BOOL *pVal)
{
	return mMetaDataPtr->get_Extended( pVal);
}

STDMETHODIMP CMTProperty::get_PropertyGroup(BSTR *pVal)
{
	return mMetaDataPtr->get_PropertyGroup( pVal);
}

STDMETHODIMP CMTProperty::get_Attributes(IMTAttributes **pVal)
{
	return mMetaDataPtr->get_Attributes( pVal);
}

STDMETHODIMP CMTProperty::get_Overrideable(VARIANT_BOOL *pVal)
{
	return mMetaDataPtr->get_Overrideable(pVal);
}

STDMETHODIMP CMTProperty::get_SummaryView(VARIANT_BOOL *pVal)
{
	return mMetaDataPtr->get_SummaryView(pVal);
}

STDMETHODIMP CMTProperty::get_Empty(VARIANT_BOOL *pVal)
{
  (*pVal) = (V_VT(&mValue) == VT_EMPTY) ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

