// MTSQLAdapter.cpp : Implementation of CMTSQLAdapter

//////////////////////

#include "StdAfx.h"
#include "MTAccount.h"
#include "MTSQLAdapter.h"
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include "MTAccountPropertyCollection.h"
#include "MTSearchResultCollection.h"

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

#include <SetIterate.h>


/////////////////////////////////////////////////////////////////////////////
// CMTSQLAdapter

STDMETHODIMP CMTSQLAdapter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountAdapter,
		&IID_IMTAccountAdapter2
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------------
// Final Construct
HRESULT 
CMTSQLAdapter::FinalConstruct()
{
  SetPath(ACCOUNT_VIEW_CONFIG_PATH);
  SetIndexFile("accountview.xml");
  
  string buffer;
  HRESULT hr = S_OK;
  const char* procName = "CMTSQLAdapter::FinalConstruct";
  
  try
  {
    // instantiate a config loader object
    hr = mpConfigLoader.CreateInstance(MTPROGID_CONFIGLOADER);
    if (!SUCCEEDED(hr))
    {
		    buffer = "Unable to create config loader";
        mLogger->LogThis (LOG_ERROR, buffer.c_str());
        return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
    }
    
    // initialize the config loader
    mpConfigLoader->Init();
    
    
    if (!MSIXDefCollection::Initialize(aAccountViewDir))
    {
      hr = E_FAIL;
      buffer = "Unable to initialize base MSIX def Collection";
      mLogger->LogThis(LOG_ERROR, buffer.c_str());	
      return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
    }
    
    if (!mCreator.Initialize())
    {
      hr = E_FAIL;
      buffer = "Unable to initialize base account def creator";
      mLogger->LogThis(LOG_ERROR, buffer.c_str());	
      return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
    }
    
    //
    // post initialization
    //
    for (AccountDefListIterator it = GetDefList().begin(); it != GetDefList().end(); it++)
    {
      CMSIXDefinition * def = (*it);
      def->CalculateTableName(L"t_av_");
    }
    
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  
  return S_OK;
}


// ----------------------------------------------------------------------
// Final Release
void
CMTSQLAdapter::FinalRelease()
{
}

//
//
//
BOOL
CMTSQLAdapter::InstallAccountObjects()
{
  // get the appropriate def object
  CMSIXDefinition* aDef;
  if (!FindAccountView(wstring(mConfigFile), aDef))
    return (FALSE);
  
  // create the table
  if (!mCreator.CreateTable(*aDef))
    return (FALSE);
  
  return (TRUE);
}

//
//
//
BOOL
CMTSQLAdapter::UninstallAccountObjects()
{
    // get the appropriate def object
    CMSIXDefinition* aDef;
    if (!FindAccountView(wstring(mConfigFile), aDef))
	  return (FALSE);


	// drop the table
	if (!mCreator.DropTable(*aDef))
	    return (FALSE);

	return (TRUE);
}

//
//
//
BOOL
CMTSQLAdapter::InsertData(const wstring& ConfigFile, 
							   ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset)
{

    // get the appropriate def object
    CMSIXDefinition* aDef;
    if (!FindAccountView(ConfigFile, aDef))
	  return (FALSE);

	// create the table
	if (!mCreator.InsertData(*aDef, (MTACCOUNTLib::IMTAccountPropertyCollection*)mtptr, apRowset))
	    return (FALSE);
    
	return (TRUE);
}

//
//
//
BOOL
CMTSQLAdapter::UpdateData(const wstring& ConfigFile,
					      ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset)
{

    // get the appropriate def object
    CMSIXDefinition* aDef;
    if (!FindAccountView(ConfigFile, aDef))
	  return (FALSE);


	// create the table
	if (!mCreator.UpdateData(*aDef, (MTACCOUNTLib::IMTAccountPropertyCollection*)mtptr
    ,apRowset))
	    return (FALSE);

	return (TRUE);
}

//
//
//
BOOL 
CMTSQLAdapter::FindAccountView (const wstring &arName, 
                                     CMSIXDefinition * & arpAccountView)
{
	CMSIXDefinition * def;
	if (!FindDefinition(arName, def))
		return FALSE;

	arpAccountView = (CMSIXDefinition *) def;
	return TRUE;
}

//
//
//
STDMETHODIMP CMTSQLAdapter::Install()
{
    if (!InstallAccountObjects())
		return Error("Failed to create the SQLAdapter account table");

	return S_OK;
}

//
//
//
STDMETHODIMP CMTSQLAdapter::Uninstall()
{
    if (!UninstallAccountObjects())
		return Error("Failed to drop the SQLAdapter account table");

	return S_OK;
}

//
//
//
STDMETHODIMP CMTSQLAdapter::AddData(BSTR ConfigFile,
                                    ::IMTAccountPropertyCollection* mtptr, 
                                    VARIANT apRowset)
{
	const char* procName = "CMTSQLAdapter::AddData";

	// handle case where requested config file does not exist
	_bstr_t bstrConfigFile(ConfigFile);
	if(bstrConfigFile.length() == 0) {
		_bstr_t aBuff;
		aBuff = "Failed to find configfile entry in the AccountAdapters configuration file";
		mLogger->LogThis(LOG_ERROR,(const char*)aBuff);
		return Error((const char*)aBuff);
	}

	// 
	wstring wstrConfigFile = _bstr_t(ConfigFile);
	if (!InsertData(wstrConfigFile, mtptr, apRowset))
		return Error("Failed to insert data in the SQLAdapter account table");

	return S_OK;
}

//
//
//
STDMETHODIMP CMTSQLAdapter::UpdateData(BSTR ConfigFile,
										    ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset)
{
	const char* procName = "CMTSQLAdapter::UpdateData";
	
	// handle case where requested config file does not exist
	_bstr_t bstrConfigFile(ConfigFile);
	if(bstrConfigFile.length() == 0) {
		_bstr_t aBuff;
		aBuff = "Failed to find configfile entry in the AccountAdapters configuration file";
		mLogger->LogThis(LOG_ERROR,(const char*)aBuff);
		return Error((const char*)aBuff, IID_IMTAccountAdapter, CONFIG_FILE_ENTRY_MISSING);
	}

	// 
	wstring wstrConfigFile = _bstr_t(ConfigFile);
	if (!UpdateData(wstrConfigFile, mtptr, apRowset))
		return Error("Failed to update data in the SQLAdapter account table");

	return S_OK;
}

//
//
//
STDMETHODIMP CMTSQLAdapter::GetData(BSTR ConfigFile,
									long arAccountID,
									VARIANT apRowset,
									::IMTAccountPropertyCollection** mtptr)
{
	const char* procName = "CMTSQLAdapter::GetData";

  try
  {
    
    // handle case where requested config file does not exist
    _bstr_t bstrConfigFile(ConfigFile);
    if(bstrConfigFile.length() == 0) {
      _bstr_t aBuff;
      aBuff = "Failed to find configfile entry in the AccountAdapters configuration file";
      mLogger->LogThis(LOG_ERROR,(const char*)aBuff);
      return Error((const char*)aBuff, IID_IMTAccountAdapter, CONFIG_FILE_ENTRY_MISSING);
    }
    
    wstring wstrConfigFile = _bstr_t(ConfigFile);
    map<wstring, _variant_t> propcoll;
    
    // get the appropriate def object
    CMSIXDefinition* aDef;
    if (!FindAccountView(wstrConfigFile, aDef))
      return (ACCOUNT_VIEW_MISSING);
    
    // get the data.  if error code is for account not found then propagate
    // that error accordingly 
    if (!mCreator.GetData(*aDef, arAccountID, apRowset, propcoll)) 
    {
      const ErrorObject *pErrorObject = mCreator.GetLastError();
      if (pErrorObject->GetCode() == ACCOUNT_NOT_FOUND)
        return ACCOUNT_NOT_FOUND; 
      else
        return Error("Failed to get the data from the SQLAdapter account table");
    }
    
    // create the MTPropertyCollection object
    CComObject<CMTAccountPropertyCollection>* pMTAccountPropertyCollection;
    HRESULT hr = CComObject<CMTAccountPropertyCollection>::CreateInstance(
      &pMTAccountPropertyCollection);
    ASSERT (SUCCEEDED(hr));
    for (map<wstring, _variant_t>::iterator propcollitr = propcoll.begin(); propcollitr != propcoll.end(); propcollitr++)
    {
      // ------------------------------------------------------------
      // create the MTRangeCollection object
      CComPtr<::IMTAccountProperty> pMTAccountProperty;
      
      wstring wstrName = (*propcollitr).first;
      
      // TODO: is this required
      map<wstring, _variant_t>::const_iterator value = propcoll.find(wstrName);
      if (value == propcoll.end()) {
        mLogger->LogThis(LOG_ERROR, L"Value for account ID not found");
        return Error("Value for account ID not found");
      }
      
      // strip the c_ out of the column name
      _bstr_t bstrName = _bstr_t(wstrName.substr(2).c_str());
      
      pMTAccountPropertyCollection->Add(bstrName, (*value).second, &pMTAccountProperty);
    }
    
    pMTAccountPropertyCollection->QueryInterface(IID_IMTAccountPropertyCollection,
      (void **) mtptr);
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }

	return S_OK;
}


// ----------------------------------------------------------------------
STDMETHODIMP CMTSQLAdapter::Initialize(BSTR ConfigFile)
{
	// keep config file name for use in Install/Uninstall
	mConfigFile = ConfigFile;
	return S_OK;
}


STDMETHODIMP CMTSQLAdapter::SearchData(BSTR ConfigFile,
									   ::IMTAccountPropertyCollection* apAPC,
									   VARIANT apRowset,
									   ::IMTSearchResultCollection** mtp)
{
	// Get rowset.
	ROWSETLib::IMTSQLRowsetPtr rowset;
	_variant_t vRowset;
	if (OptionalVariantConversion(apRowset,VT_DISPATCH,vRowset)) 
		rowset = vRowset;

	HRESULT hr;
	if (rowset == NULL)
	{
		hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			return hr;
		ASSERT (rowset != NULL);
		hr = rowset->Init(L"\\Queries\\Database");
		if (FAILED(hr))
		{
			mLogger->LogThis(LOG_ERROR, "Init() failed. Unable to initialize database access layer");
			return hr;
		}
	}
	else
	{
	    hr = rowset->UpdateConfigPath(L"\\Queries\\Database");
		if (FAILED(hr))
		{
			mLogger->LogThis(LOG_ERROR, "UpdateConfigPath() failed. Unable to update configuration path");
			return hr;
		}
	}

	// create the ddl string
	wstring wstrName;
	wstring wstrValue;
	wstring langRequest;
	const char* procName = "CMTSQLAdapter::SearchData";

	// handle case where requested config file does not exist
	_bstr_t bstrConfigFile(ConfigFile);
	
	if(bstrConfigFile.length() == 0) 
	{
		_bstr_t aBuff;
		aBuff = "Failed to find configfile entry in the AccountAdapters configuration file";
		mLogger->LogThis(LOG_ERROR,(const char*)aBuff);
		return Error((const char*)aBuff, IID_IMTAccountAdapter, CONFIG_FILE_ENTRY_MISSING);
	}

	// get the appropriate def object
	wstring wstrConfigFile = _bstr_t(ConfigFile);
	CMSIXDefinition* aDef;
	if (!FindAccountView(wstrConfigFile, aDef))
		return (ACCOUNT_VIEW_MISSING);

	CComObject<CMTSearchResultCollection>*  pSearchResultColl;
	hr = CComObject<CMTSearchResultCollection>::CreateInstance(&pSearchResultColl);
	ASSERT (SUCCEEDED(hr));

	_bstr_t dbType = rowset->GetDBType();
	bool isOracle = (mtwcscasecmp(dbType, ORACLE_DATABASE_TYPE) == 0);

	hr = GenerateGetDataQuery(apAPC, langRequest, aDef->GetTableName(), false);
	if (FAILED(hr))
		return hr;

	// execute the language request
	hr = rowset->SetQueryString(langRequest.c_str());
	if (hr == S_OK)
		hr = rowset->Execute();
	if (FAILED(hr))
	{
		mLogger->LogThis(LOG_ERROR, "Database execution failed");
		return hr;
	}

	long lRecordCount = rowset->GetRecordCount();
	if (lRecordCount == 0)
	{
    	mLogger->LogThis (LOG_INFO, "0 count rowset for parameters passed");
		return ACCOUNT_NOT_FOUND;
	}
	else
	{
		// iterate through rowset to get all namespaces
		wstring ws;
		_bstr_t bstr_namespace;
		
		BOOL bRetCode=TRUE ;
		long lIndex = 0;
		while ((lIndex++ < lRecordCount) && (bRetCode == TRUE))
		{
			// create the MTPropertyCollection object
			CComObject<CMTAccountPropertyCollection>* pAccPropColl;
			HRESULT hr = CComObject<CMTAccountPropertyCollection>::CreateInstance(&pAccPropColl);
			ASSERT (SUCCEEDED(hr));

			long iColumnCount;
			iColumnCount =	rowset->GetCount();

			//iterate for each column in rowset
			for(int ix=0; ix < iColumnCount; ix++)
			{

				// create IMTAccountProperty object
				CComPtr<::IMTAccountProperty> pAccProp;
				_variant_t vtIndex;

				vtIndex = (long)ix;
				wstring wstrFieldName = rowset->GetName(vtIndex);

        //Noah 1/9/2003
        // Don't strip the c_ from the names.  Otherwise the calling function has to
        // specify the property names with c_

				// this is temporary
				//if(_wcsicmp(wstrFieldName.c_str(), L"id_acc")!=0)
				//{
      	//	wstrFieldName = wstrFieldName.substr(2);
				//}
				_variant_t vtValue = rowset->GetValue(vtIndex);

				//leave it as empty string if NULL comes back
				_bstr_t sValue;
				if (vtValue.vt != VT_NULL)
					 sValue = vtValue;

				_bstr_t fldname(wstrFieldName.c_str());

				// add this property to the account property collection
				pAccPropColl->Add(fldname, vtValue, &pAccProp);
			}

			// add this account to the search result
			pSearchResultColl->Add(pAccPropColl);

			// move to next record
			bRetCode = rowset->MoveNext();
		}

	}

	return(pSearchResultColl->QueryInterface(IID_IMTSearchResultCollection, (void **) mtp));
}



STDMETHODIMP CMTSQLAdapter::SearchDataWithUpdLock(BSTR ConfigFile,
									   ::IMTAccountPropertyCollection* apAPC,
									   BOOL wUpdLock,
									   VARIANT apRowset,									   
									   ::IMTSearchResultCollection** mtp)
{
	// Get rowset.
	ROWSETLib::IMTSQLRowsetPtr rowset;
	_variant_t vRowset;
	if (OptionalVariantConversion(apRowset,VT_DISPATCH,vRowset)) 
		rowset = vRowset;

	HRESULT hr;
	if (rowset == NULL)
	{
		hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			return hr;
		ASSERT (rowset != NULL);
		hr = rowset->Init(L"\\Queries\\Database");
		if (FAILED(hr))
		{
			mLogger->LogThis(LOG_ERROR, "Init() failed. Unable to initialize database access layer");
			return hr;
		}
	}
	else
	{
	    hr = rowset->UpdateConfigPath(L"\\Queries\\Database");
		if (FAILED(hr))
		{
			mLogger->LogThis(LOG_ERROR, "UpdateConfigPath() failed. Unable to update configuration path");
			return hr;
		}
	}

	// create the ddl string
	wstring wstrName;
	wstring wstrValue;
	wstring langRequest;
	const char* procName = "CMTSQLAdapter::SearchDataWithUpdLock";

	// handle case where requested config file does not exist
	_bstr_t bstrConfigFile(ConfigFile);
	
	if(bstrConfigFile.length() == 0) 
	{
		_bstr_t aBuff;
		aBuff = "Failed to find configfile entry in the AccountAdapters configuration file";
		mLogger->LogThis(LOG_ERROR,(const char*)aBuff);
		return Error((const char*)aBuff, IID_IMTAccountAdapter, CONFIG_FILE_ENTRY_MISSING);
	}

	// get the appropriate def object
	wstring wstrConfigFile = _bstr_t(ConfigFile);
	CMSIXDefinition* aDef;
	if (!FindAccountView(wstrConfigFile, aDef))
		return (ACCOUNT_VIEW_MISSING);

	CComObject<CMTSearchResultCollection>*  pSearchResultColl;
	hr = CComObject<CMTSearchResultCollection>::CreateInstance(&pSearchResultColl);
	ASSERT (SUCCEEDED(hr));

	_bstr_t dbType = rowset->GetDBType();
	bool isOracle = (mtwcscasecmp(dbType, ORACLE_DATABASE_TYPE) == 0);

	if (!isOracle && wUpdLock)
	{
		hr = GenerateGetDataQuery(apAPC, langRequest, aDef->GetTableName(), true);
		if (FAILED(hr))
			return hr;
	}
	else
	{
		hr = GenerateGetDataQuery(apAPC, langRequest, aDef->GetTableName(), false);
		if (FAILED(hr))
			return hr;
	}

	// execute the language request
	hr = rowset->SetQueryString(langRequest.c_str());
	if (hr == S_OK)
		hr = rowset->Execute();
	if (FAILED(hr))
	{
		mLogger->LogThis(LOG_ERROR, "Database execution failed");
		return hr;
	}

	long lRecordCount = rowset->GetRecordCount();
	if (lRecordCount == 0)
	{
    	mLogger->LogThis (LOG_INFO, "0 count rowset for parameters passed");
		return ACCOUNT_NOT_FOUND;
	}
	else
	{
		// iterate through rowset to get all namespaces
		wstring ws;
		_bstr_t bstr_namespace;
		
		BOOL bRetCode=TRUE ;
		long lIndex = 0;
		while ((lIndex++ < lRecordCount) && (bRetCode == TRUE))
		{
			// create the MTPropertyCollection object
			CComObject<CMTAccountPropertyCollection>* pAccPropColl;
			HRESULT hr = CComObject<CMTAccountPropertyCollection>::CreateInstance(&pAccPropColl);
			ASSERT (SUCCEEDED(hr));

			long iColumnCount;
			iColumnCount =	rowset->GetCount();

			//iterate for each column in rowset
			for(int ix=0; ix < iColumnCount; ix++)
			{

				// create IMTAccountProperty object
				CComPtr<::IMTAccountProperty> pAccProp;
				_variant_t vtIndex;

				vtIndex = (long)ix;
				wstring wstrFieldName = rowset->GetName(vtIndex);

        //Noah 1/9/2003
        // Don't strip the c_ from the names.  Otherwise the calling function has to
        // specify the property names with c_

				// this is temporary
				//if(_wcsicmp(wstrFieldName.c_str(), L"id_acc")!=0)
				//{
      	//	wstrFieldName = wstrFieldName.substr(2);
				//}
				_variant_t vtValue = rowset->GetValue(vtIndex);

				//leave it as empty string if NULL comes back
				_bstr_t sValue;
				if (vtValue.vt != VT_NULL)
					 sValue = vtValue;

				_bstr_t fldname(wstrFieldName.c_str());

				// add this property to the account property collection
				pAccPropColl->Add(fldname, vtValue, &pAccProp);
			}

			// add this account to the search result
			pSearchResultColl->Add(pAccPropColl);

			// move to next record
			bRetCode = rowset->MoveNext();
		}

	}

	return(pSearchResultColl->QueryInterface(IID_IMTSearchResultCollection, (void **) mtp));
}

// -------------------------------------------------------------------------
// @mfunc GenerateGetDataQuery
// @parm
// @rdesc Get the ddl information
// 
HRESULT CMTSQLAdapter::GenerateGetDataQuery(::IMTAccountPropertyCollection* apAPC,  
										 wstring& langRequest, const wstring& aTableName, BOOL wUpdLock)
{
	long arAccountID = -1;
	HRESULT hr = S_OK;
	string buffer;
    const char* procName = "CMTSQLAdapter::GenerateGetDataQuery";


	wstring wstrInputs;
	wstring wstrWhere;

	// dynamic query with the AND logic only
	BOOL bFirstTime = TRUE;


  // iterate through the collection 
	SetIterator<MTACCOUNTLib::IMTAccountPropertyCollectionPtr, 
		MTACCOUNTLib::IMTAccountPropertyPtr> it;
	hr = it.Init(apAPC);
	if (FAILED(hr))
		return hr;

  MTACCOUNTLib::IMTAccountPropertyPtr accprop = it.GetNext();

	// we have to have minimum one property
	if (accprop == NULL)
	{
		return EMPTY_SEARCH_CRITERIA_COLLECTION;
	}

	
	langRequest = L"SELECT * FROM ";
	langRequest += aTableName;

	if (wUpdLock)
		langRequest += L" WITH (UPDLOCK) ";

	// here we check see if _accountID==* ---convention

	_bstr_t fldName;
	_variant_t fldValue;
	_bstr_t fldDatatype;
	_bstr_t fldColumnname;

	fldName = accprop->GetName();
	fldValue = accprop->GetValue();
	string wfldName;
	wfldName = fldName;

	string wfldValue;
	_bstr_t b = fldValue;
	wfldValue = b;

	if(stricmp(wfldName.c_str(), "_accountID")==0 && 
	   stricmp(wfldValue.c_str(), "*")==0)
	{
		return hr;
	}

	wstrWhere = L" WHERE ";

	while (accprop != NULL)
	{

		//IMTAccountPropertyPtr

		if (bFirstTime == FALSE)
			wstrWhere += L" AND ";

		// perform the operation
		try 
		{
			_bstr_t fldName;
			_variant_t fldValue;
			_bstr_t fldDatatype;
			_bstr_t fldColumnname;

			fldName = accprop->GetName();
			fldValue = accprop->GetValue();
			
			_bstr_t sSqlVal;
			BOOL bRet = SqlStatementPrepareVar(fldValue, sSqlVal);

			wstrWhere += fldName;

			wstrWhere += L"=";
			wstrWhere += sSqlVal;

			bFirstTime = FALSE;
		
		}
		catch (_com_error& e)
		{
			buffer = "Unable to iterate";
			SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, buffer.c_str());
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			return (_com_error::WCodeToHRESULT(e.WCode()));
		}
		
		accprop = it.GetNext();
		if (accprop == NULL)
			break;

	}



	// if for boris don t puut wher4e claos
	langRequest += wstrWhere;

	// just to make it through and debug
	///langRequest = L"select * from t_av_contact";


	return (TRUE);
}

BOOL CMTSQLAdapter::SqlStatementPrepareVar(_variant_t& vtValue, _bstr_t& sVar)
{
	BOOL bRet = TRUE;
	_TCHAR buf[255] ;

	switch (vtValue.vt)
	{
	case VT_I2:
		{
			_stprintf(buf, _T("%hd"),V_I2(&vtValue));
			sVar = buf;
			break;
		}
    case VT_I4:
		{
			_stprintf(buf, _T("%d"),V_I4(&vtValue));
			sVar = buf;
			break;
		}
    case VT_R4:
		{
			_stprintf(buf, _T("%e"),(double)V_R4(&vtValue));
			sVar = buf;
			break;
		}
    case VT_R8:
		{
			_stprintf(buf, _T("%e"),V_R8(&vtValue));
			sVar = buf;
			break;
		}
    case VT_BSTR:
		{
			_bstr_t t;
			t += L"N'" ;
			t += V_BSTR (&vtValue) ;
			t += L"'" ;
			sVar = t;
			break ;
		}
		default:
		{
			mLogger->LogThis(LOG_ERROR, "un implemented vartype") ;
			bRet = FALSE;
			break ;
		}
	}

	return bRet;
}

STDMETHODIMP CMTSQLAdapter::GetPropertyMetaData(BSTR aPropertyName,
																								::IMTPropertyMetaData** apMetaData)
{
	try 
	{
	
		// loads the account view definition
		CMSIXDefinition* accountViewDef;
		if (!FindDefinition((const wchar_t*) mConfigFile, accountViewDef))
			return Error("Account view definition not found!"); 
		
		// finds the requested property
		_bstr_t propertyName(aPropertyName);
		CMSIXProperties* property;
		if (!accountViewDef->FindProperty((const wchar_t*) propertyName, property))
			return Error("Property not found in account view!");

		MTACCOUNTLib::IMTPropertyMetaDataPtr metaData;
		metaData.CreateInstance("Metratech.MTPropertyMetaData.1");

		_bstr_t name = property->GetDN().c_str();
		metaData->PutName(name);

		_bstr_t table  = accountViewDef->GetTableName().c_str();
		metaData->PutDBTableName(table);

		_bstr_t column = "c_" +  name;
		metaData->PutDBColumnName(column);

		// overloads the meaning of this property (if it is part of the key, then it is "required")
		metaData->PutRequired(property->GetPartOfKey()); 
		
		// set default value
		metaData->PutDefaultValue(_bstr_t(property->GetDefault().c_str())); 

		// sets the data type
		switch (property->GetPropertyType())
		{
		case CMSIXProperties::TYPE_WIDESTRING:
		case CMSIXProperties::TYPE_STRING:
			metaData->PutDataType(MTACCOUNTLib::PROP_TYPE_STRING);
			metaData->PutLength(property->GetLength());
			break;
		
		case CMSIXProperties::TYPE_INT32:
			metaData->PutDataType(MTACCOUNTLib::PROP_TYPE_INTEGER);
			break;

		case CMSIXProperties::TYPE_INT64:
			metaData->PutDataType(MTACCOUNTLib::PROP_TYPE_BIGINTEGER);
			break;

		case CMSIXProperties::TYPE_FLOAT:
		case CMSIXProperties::TYPE_DOUBLE:
			metaData->PutDataType(MTACCOUNTLib::PROP_TYPE_DOUBLE);
			break;

		case CMSIXProperties::TYPE_DECIMAL:
			metaData->PutDataType(MTACCOUNTLib::PROP_TYPE_DECIMAL);
			break;
			
		case CMSIXProperties::TYPE_ENUM:
			metaData->PutDataType(MTACCOUNTLib::PROP_TYPE_ENUM);
			metaData->PutEnumSpace(_bstr_t(property->GetEnumNamespace().c_str())); 
			metaData->PutEnumType(_bstr_t(property->GetEnumEnumeration().c_str())); 
			break;

		case CMSIXProperties::TYPE_BOOLEAN:
			metaData->PutDataType(MTACCOUNTLib::PROP_TYPE_BOOLEAN);
			break;
			
		case CMSIXProperties::TYPE_TIME:
		case CMSIXProperties::TYPE_TIMESTAMP:
			metaData->PutDataType(MTACCOUNTLib::PROP_TYPE_DATETIME);
			break;

		case CMSIXProperties::TYPE_NUMERIC:
		default:
			mLogger->LogThis(LOG_ERROR, "Unknown property data type!");
			ASSERT(0);
			break;
		}

		*apMetaData = reinterpret_cast<::IMTPropertyMetaData*>(metaData.Detach());
	}
	catch (_com_error& e)
	{
		mLogger->LogVarArgs(LOG_ERROR, "Exception thrown from GetPropertyMetaData! errorCode = %d, '%s'",
												e.Error(), (const char*) _bstr_t(e.Description()));
		//TODO:		ReturnComError(e);
		return e.Error();
	}
	
	return S_OK;
}

