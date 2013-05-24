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
*
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"

#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <stdutils.h>
#include <DBConstants.h>
#include <OdbcConnection.h>

#include "MTProductCatalog.h"
#include "MTPropertyMetaData.h"
#include "PropertiesBase.h"
#include "mtprogids.h"


/////////////////////////////////////////////////////////////////////////////
// CMTPropertyMetaData

/******************************************* error interface ***/
STDMETHODIMP CMTPropertyMetaData::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPropertyMetaData
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/
CMTPropertyMetaData::CMTPropertyMetaData()
{
	mUnkMarshalerPtr = NULL;
	mAttributesPtr = NULL;
	mName = "";
	mDataType = PROP_TYPE_UNKNOWN;
	mLength = 0;
	mRequired = VARIANT_FALSE;
	mDefaultValue = vtMissing;
	mExtended = VARIANT_FALSE;	
	mPropertyGroup ="";
	mDBColumnName = "";
	mDBTableName = "";
  
  // are we running oracle?
	COdbcConnectionInfo info = COdbcConnectionInfo("NetMeter");
	mIsOracle = (info.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);

}

HRESULT CMTPropertyMetaData::FinalConstruct()
{
	HRESULT hr = CoCreateFreeThreadedMarshaler(	GetControllingUnknown(), &mUnkMarshalerPtr.p);
	if (FAILED(hr))
		return hr;

	//create nested attributes object
	hr = mAttributesPtr.CoCreateInstance(__uuidof(MTAttributes));

	return hr;
}

void CMTPropertyMetaData::FinalRelease()
{
	mAttributesPtr.Release();
	mUnkMarshalerPtr.Release();
}

/********************************** IMTPropertyMetaData***/
STDMETHODIMP CMTPropertyMetaData::get_Name(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_DisplayName(BSTR *pVal)
{
	//TODO!!: localization support
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mDisplayName.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_DisplayName(BSTR newVal)
{
	//TODO!!: localization support

	mDisplayName = newVal;
	return S_OK;
}


STDMETHODIMP CMTPropertyMetaData::get_DataType(PropValType *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mDataType;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_DataType(PropValType newVal)
{
	mDataType = newVal;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_DataTypeAsString(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;
	else
		*pVal = NULL;

	_bstr_t str;

	switch(mDataType)
	{
		case PROP_TYPE_INTEGER:  str = "int32";     break;
		case PROP_TYPE_BIGINTEGER:  str = "int64";     break;
		case PROP_TYPE_DOUBLE:   str = "double";    break;
		case PROP_TYPE_STRING:   str = "string";    break;
		case PROP_TYPE_DATETIME: str = "timestamp"; break;
		case PROP_TYPE_BOOLEAN:  str = "boolean";   break;
		case PROP_TYPE_SET:      str = "object";    break;
		case PROP_TYPE_OPAQUE:   str = "variant";   break;
		case PROP_TYPE_ENUM:     str = "enum";      break;
		case PROP_TYPE_DECIMAL:  str = "decimal";   break;
		case PROP_TYPE_ASCII_STRING:   str = "string";      break;
		case PROP_TYPE_UNICODE_STRING: str = "unistring";   break;

		default:
			return Error("invalid or unsupported DataType");
	}
	
	*pVal = str.copy();

	return S_OK;
}



STDMETHODIMP CMTPropertyMetaData::get_Length(long *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mLength;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_Length(long newVal)
{
	mLength = newVal;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_EnumSpace(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mEnumSpace.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_EnumSpace(BSTR newVal)
{
	mEnumSpace = newVal;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_EnumType(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mEnumType.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_EnumType(BSTR newVal)
{
	mEnumType = newVal;
	return S_OK;
}


STDMETHODIMP CMTPropertyMetaData::get_Required(VARIANT_BOOL *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mRequired;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_Required(VARIANT_BOOL newVal)
{
	mRequired = newVal;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_DefaultValue(VARIANT *pVal)
{
	if (pVal == NULL)
		return E_POINTER;
	
	::VariantInit(pVal);
	::VariantCopy(pVal, &mDefaultValue);

	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_DefaultValue(VARIANT newVal)
{
	mDefaultValue = newVal;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_Extended(VARIANT_BOOL *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mExtended;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_Extended(VARIANT_BOOL newVal)
{
	mExtended = newVal;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_PropertyGroup(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mPropertyGroup.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_PropertyGroup(BSTR newVal)
{
	mPropertyGroup = newVal;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_DBColumnName(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mDBColumnName.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_DBColumnName(BSTR newVal)
{
	mDBColumnName = newVal;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_DBTableName(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mDBTableName.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_DBTableName(BSTR newVal)
{
	mDBTableName = newVal;
	return S_OK;
}

const long MAX_ALIAS_LENGTH = 30;

STDMETHODIMP CMTPropertyMetaData::get_DBAliasName(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;
	
	// alias name is tablename_columnname with a maximum length of 30 chars
	long totalLength = mDBTableName.length() + 1 + mDBColumnName.length();

	_bstr_t alias;


	if (totalLength > MAX_ALIAS_LENGTH)
	{
		if (mDBColumnName.length() > MAX_ALIAS_LENGTH-1)
		{ 
			//column is already to long, use truncated column name only;
			std::string truncatedColumn(mDBColumnName, MAX_ALIAS_LENGTH);
			alias = truncatedColumn.c_str();
		}
		else
		{	 //truncate table name
			std::string truncatedTable(mDBTableName,
			                           MAX_ALIAS_LENGTH - mDBColumnName.length() -1);

			char buffer[MAX_ALIAS_LENGTH+1];
			sprintf(buffer,"%s_%s",	(const char*)truncatedTable.c_str(), (const char*)mDBColumnName);
			alias = buffer;
		}
	}
	else
	{
		//all fit, just concatenate
		char buffer[MAX_ALIAS_LENGTH+1];
		sprintf(buffer,"%s_%s",	(const char*)mDBTableName, (const char*)mDBColumnName);
		alias = buffer;
	}

	*pVal = alias.copy();
	return S_OK;
}

// returns the database type (to be) used for this property
// returns "" if property cannot be mapped directly to one db field
STDMETHODIMP CMTPropertyMetaData::get_DBDataType(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;
	else
		*pVal = NULL;

	_bstr_t str;

	switch(mDataType)
	{
		case PROP_TYPE_INTEGER:  
      str = mIsOracle ? DB_NUMBER_TYPE_ORACLE : DB_INT_TYPE; break;
		case PROP_TYPE_BIGINTEGER:  
      str = mIsOracle ? DB_NUMBER_TYPE_ORACLE: DB_BIGINT_TYPE; break;
		case PROP_TYPE_DOUBLE:   
      str = mIsOracle ? DB_NUMBER_TYPE_ORACLE : DB_DOUBLE_TYPE; break;
		case PROP_TYPE_STRING:   
      str = mIsOracle ? DB_WSTRING_TYPE_ORACLE : DB_WSTRING_TYPE; break;
		case PROP_TYPE_DATETIME: 
      str = mIsOracle ? DB_DATE_TYPE_ORACLE : DB_DATE_TYPE;    break;
		case PROP_TYPE_BOOLEAN:  
      str = mIsOracle ? DB_CHAR_TYPE_ORACLE : DB_CHAR_TYPE;    break;
		case PROP_TYPE_SET:      
        str = ""; break;
		case PROP_TYPE_OPAQUE:   
      str = ""; break;
		case PROP_TYPE_ENUM:     
      str = mIsOracle ? DB_NUMBER_TYPE_ORACLE : DB_INT_TYPE; break;
		case PROP_TYPE_DECIMAL:  
      str = mIsOracle ? DB_NUMBER_TYPE_ORACLE : DB_DECIMAL_TYPE; break;
		case PROP_TYPE_ASCII_STRING:   
      str = mIsOracle ? DB_VARCHAR_TYPE_ORACLE : DB_VARCHAR_TYPE; break;
		case PROP_TYPE_UNICODE_STRING: 
      str = mIsOracle ? DB_WSTRING_TYPE_ORACLE : DB_WSTRING_TYPE; break;

		default:
			return Error("invalid or unsupported DataType");

	}
	
	*pVal = str.copy();

	return S_OK;
}


STDMETHODIMP CMTPropertyMetaData::get_Attributes(IMTAttributes **pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	return mAttributesPtr.CopyTo(pVal);
}

STDMETHODIMP CMTPropertyMetaData::put_Attributes(IMTAttributes* newVal)
{
	mAttributesPtr = newVal;
	
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::InitDefault(PropValType aDataType, 
																			 VARIANT aDefault)
{
	try
  {
		mDataType = aDataType;
		
		if (aDataType == PROP_TYPE_STRING)
    {
			mLength = 256;
		}
		else
    {
			mLength = 0; //do we need length for no string types?
		}

		mEnumType = "";
		mEnumSpace = "";
		mDefaultValue = aDefault;

		//if default value is not provided set it according to type
		if (mDefaultValue.vt == VT_EMPTY)
		{
			switch (aDataType)
			{
				case PROP_TYPE_STRING:
					mDefaultValue = "";
					break;
			
				case PROP_TYPE_ENUM:
					//an IDs default value has to be PROPERTIES_BASE_NO_ID (to match PropertyBase::HasID())
					if(stricmp(mName, "ID") == 0)
						mDefaultValue = PROPERTIES_BASE_NO_ID;
          break;

				case PROP_TYPE_INTEGER:
					//an IDs default value has to be PROPERTIES_BASE_NO_ID (to match PropertyBase::HasID())
					if(stricmp(mName, "ID") == 0)
						mDefaultValue = PROPERTIES_BASE_NO_ID;
					else			
						mDefaultValue = 0L;
					break;
				
				case PROP_TYPE_BIGINTEGER:
          mDefaultValue = (__int64) 0;
					break;
				
				case PROP_TYPE_DOUBLE:
				case PROP_TYPE_DECIMAL:
					mDefaultValue = 0.0;
					break;

				case PROP_TYPE_BOOLEAN:
					mDefaultValue = VARIANT_FALSE;
					break;

				case PROP_TYPE_DATETIME:
				case PROP_TYPE_SET:
				case PROP_TYPE_OPAQUE:
					mDefaultValue = _variant_t(); //VT_EMPTY
					break;

			default:
				MT_THROW_COM_ERROR(IID_IMTPropertyMetaData, "Invalid data type: %d", aDataType);
			}
		}
		// other properties must be set by caller
	}
	catch( _com_error & )
	{
		_bstr_t errorstr = "Error occured initializing property metadata ";
		errorstr += mName;
		return Error((const char*)errorstr);
	}
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_Overrideable(VARIANT_BOOL *pVal)
{
	return GetAttributeValue("overrideable", pVal);
}

STDMETHODIMP CMTPropertyMetaData::get_SummaryView(VARIANT_BOOL *pVal)
{
	return GetAttributeValue("summaryview", pVal);
}

STDMETHODIMP CMTPropertyMetaData::GetAttributeValue(const char* apAttrName, VARIANT_BOOL *apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	//init
	*apVal = VARIANT_FALSE;

	try
	{
		//check attribute "overrideable" for "true",
		// note: attributes store strings
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr metaData = this;
		MTPRODUCTCATALOGLib::IMTAttributesPtr attribs = metaData->Attributes;
		MTPRODUCTCATALOGLib::IMTAttributePtr attrib = attribs->GetItem(apAttrName);
		_variant_t val = attrib->Value;

		mtwstring wValue(val.bstrVal); 
		wValue.toupper();

		if (wValue.compare(L"TRUE") == 0)
			*apVal = VARIANT_TRUE;
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_Enumerators(/*[out, retval]*/ IMTEnumeratorCollection * *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	try
	{
		if (mEnumeratorCollection == NULL)
		{
			MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);

			BSTR tmp;
			HRESULT hr = get_EnumSpace(&tmp);
			_bstr_t enumSpace(tmp, false);
			if (FAILED(hr))
				return hr;

			hr = get_EnumType(&tmp);
			_bstr_t enumType(tmp, false);
			if (FAILED(hr))
				return hr;

			if (enumSpace.length() == 0 || enumType.length() == 0)
				return Error("Unknown enumspace or enumtype");

			mEnumeratorCollection = enumConfig->GetEnumerators(enumSpace, enumType);
		}

		return mEnumeratorCollection.CopyTo((MTENUMCONFIGLib::IMTEnumeratorCollection * *) pVal);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
}

STDMETHODIMP CMTPropertyMetaData::put_Enumerators(/*[in]*/ IMTEnumeratorCollection * newVal)
{
	mEnumeratorCollection = (MTENUMCONFIGLib::IMTEnumeratorCollection *) newVal;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::get_Description(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mDescription.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaData::put_Description(BSTR newVal)
{
	mDescription = newVal;
	return S_OK;
}
