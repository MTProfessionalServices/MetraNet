// MTServicesDef.cpp : Implementation of CMTServicesDef
#include "StdAfx.h"
#include "MTServices.h"
#include "MTServicesDef.h"

#include <mtglobal_msg.h>
#include <loggerconfig.h>


/////////////////////////////////////////////////////////////////////////////
// CMTServicesDef

STDMETHODIMP CMTServicesDef::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTServicesDef,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTServicesDef::Save()
{
	return S_OK;
}

STDMETHODIMP CMTServicesDef::get_dn(BSTR * pVal)
{
    *pVal = mDN.copy();
	return S_OK;
}

STDMETHODIMP CMTServicesDef::put_dn(BSTR newVal)
{
    mDN = newVal;
	return S_OK;
}

STDMETHODIMP CMTServicesDef::get_type(BSTR * pVal)
{
    *pVal = mType.copy();
	return S_OK;
}

STDMETHODIMP CMTServicesDef::put_type(BSTR newVal)
{
    mType = newVal;
    return S_OK;
}

STDMETHODIMP CMTServicesDef::get_length(long * pVal)
{
    *pVal = mLength;
	return S_OK;
}

STDMETHODIMP CMTServicesDef::put_length(long newVal)
{
    mLength = newVal;
    return S_OK;
}

STDMETHODIMP CMTServicesDef::get_required(BSTR * pVal)
{
    *pVal = mIsRequired.copy();
	return S_OK;
}

STDMETHODIMP CMTServicesDef::put_required(BSTR newVal)
{
    mIsRequired = newVal;
    return S_OK;
}

STDMETHODIMP CMTServicesDef::get_defaultVal(BSTR * pVal)
{
    *pVal = mDefaultValue.copy();
	return S_OK;
}

STDMETHODIMP CMTServicesDef::put_defaultVal(BSTR newVal)
{
    mDefaultValue = newVal;
    return S_OK;
}

STDMETHODIMP CMTServicesDef::Initialize()
{
	return S_OK;	
}

STDMETHODIMP CMTServicesDef::get_name(BSTR * pVal)
{
    *pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTServicesDef::put_name(BSTR newVal)
{
    mName = newVal;
	return S_OK;
}

STDMETHODIMP CMTServicesDef::get_majorversion(BSTR * pVal)
{
    *pVal = mMajorVersion.copy();
	return S_OK;
}

STDMETHODIMP CMTServicesDef::put_majorversion(BSTR newVal)
{
    mMajorVersion = newVal;
	return S_OK;
}

STDMETHODIMP CMTServicesDef::get_minorversion(BSTR * pVal)
{
    *pVal = mMinorVersion.copy();
	return S_OK;
}

STDMETHODIMP CMTServicesDef::put_minorversion(BSTR newVal)
{
    mMinorVersion = newVal;
    return S_OK;
}

STDMETHODIMP CMTServicesDef::get_tablename(BSTR * pVal)
{
    *pVal = mTableName.copy();
	return S_OK;
}

STDMETHODIMP CMTServicesDef::put_tablename(BSTR newVal)
{
    mTableName = newVal;
    return S_OK;
}

STDMETHODIMP CMTServicesDef::AddProperty(BSTR dn, 
										 BSTR type, 
										 long length, 
										 BSTR required, 
										 BSTR defaultvalue)
{
    mDN = dn;
    mType = type;
    mLength = length;
    mIsRequired = required;
    mDefaultValue = defaultvalue;
    
	return S_OK;
}


// @cmember,mfunc Hook to create an aggregate.
//	@@parm tag name
//	@@parm name -> value map of attributes
//	@@parm contents of the aggregate
//	@@rdesc object
XMLObject*
CMSIXDefinitionObjectFactory::CreateAggregate(
		const char * apName,
		const XMLNameValueMap * apAttributes,
		XMLObjectVector & arContents)
{
#if 0
	cout << "Aggregate: " << apName << endl;
	DumpContents(arContents);
#endif

	// compare name to servicedef
	// if yes, construct a new service def object
	// then call Parse() and give it contents
	// Once Parse() is completed, then we are done 
	// is this correct... DY
	if (0 == strcmp(apName, SERVICE_DEF_STR))
	{
		CMSIXDefinition* pDef = new CMSIXDefinition;
		if (pDef->Parse(arContents))
		{

			// get the new service id using the code lookup table
			int newID;
			if (!mpCodeLookup->GetEnumDataCode (pDef->GetName(), newID))
			{
				ASSERT(0);
				return (NULL);
			}

			// finally set the id
			pDef->SetID(newID);

#if 0
			cout << *pDef << endl;
#endif
			// make sure everything is ok
			pDef->PrintDefinitionContents();

			return pDef;
		}
		else
		{
			delete pDef;
			ASSERT (0);
			return NULL;
		}
	}
	else
	{
		return XMLObjectFactory::CreateAggregate(apName, 
												 apAttributes, 
												 arContents);
	}
}

STDMETHODIMP CMTServicesDef::WriteSet(::IMTConfigPropSet * apPropSet)
{
    HRESULT hr = S_OK;
	const char* procName = "CMTServicesDef::WriteSet";

    if (apPropSet == NULL)
	  return E_POINTER;

#if 0
	IMTConfigPropSetPtr aHours(apPropSet);

	IMTConfigPropSetPtr hoursSet = aHours->InsertSet(HOURSSET_TAG);
	if (hoursSet == NULL)
	{
	    //TODO: change it to ERROR_INVALID_WEEKDAY
	    hr = ERROR_INVALID_PARAMETER;
		SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (hr);
	}

	_variant_t varStartTime;
	string strStartTime(mStartTime);
    varStartTime = MTConvertTime(strStartTime);
	hoursSet->InsertProp(STARTTIME_TAG, MTConfigLib::PROP_TYPE_TIME, varStartTime.lVal);

	_variant_t varEndTime;
	string strEndTime(mEndTime);
	varEndTime = MTConvertTime(strEndTime);
	hoursSet->InsertProp(ENDTIME_TAG, MTConfigLib::PROP_TYPE_TIME, varEndTime.lVal);

	_variant_t var;
	var = mCode;
	hoursSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);
#endif

	return S_OK;
}
