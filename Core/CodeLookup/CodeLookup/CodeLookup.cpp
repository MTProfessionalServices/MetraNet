/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
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
 * Created by: Raju Matta
 * $Header$
 * 
 * 	CodeLookup.cpp : 
 *	--------------
 *	This is the implementation of the CodeLookup class.
 *	This class expands on the functionality provided by the class 
 *	CCOMCodeLookup.
 ***************************************************************************/


// All the includes

// ADO includes
#include <comdef.h>
#include <adoutil.h>

// Local includes
#include <CodeLookup.h>

#include <loggerconfig.h>

// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

#include <mtprogids.h>
#include <mtparamnames.h>

// All the constants

// @mfunc CCodeLookup default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// Code Lookup class
DLL_EXPORT CCodeLookup::CCodeLookup() :
	mpQueryAdapter(0)
{
    LoggerConfigReader cfgRdr;
    mLogger.Init(cfgRdr.ReadConfiguration("logging\\codelookup\\"), CODE_LOOKUP_TAG);
}


// @mfunc CCodeLookup copy constructor
// @parm CCodeLookup& 
// @rdesc This implementations is for the copy constructor of the 
// Code Lookup class
DLL_EXPORT CCodeLookup::CCodeLookup(const CCodeLookup &c)
{
	*this = c;
}

DLL_EXPORT CCodeLookup * CCodeLookup::GetInstance()
{
	return MTSingleton<CCodeLookup>::GetInstance();
}

DLL_EXPORT void CCodeLookup::ReleaseInstance()
{
	MTSingleton<CCodeLookup>::ReleaseInstance();
}


// @mfunc CCodeLookup assignment operator
// @parm 
// @rdesc This implementations is for the assignment operator of the 
// Code Lookup class
DLL_EXPORT const CCodeLookup& 
CCodeLookup::operator=(const CCodeLookup& rhs)
{
 	return ( *this );
}


// @mfunc CCodeLookup destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// Code Lookup class
DLL_EXPORT CCodeLookup::~CCodeLookup()
{
	if (mpQueryAdapter)
	{
		mpQueryAdapter->Release();
		mpQueryAdapter = NULL;
	}
}


// @mfunc Init
// @parm 
// @rdesc This function is responsible for getting the corresponding values 
// for the input parameters from the database.   It creates the language
// request and does the connect to the database and executes the query.
// Returns true or false depending on whether the function succeeded
// or not.  
DLL_EXPORT BOOL 
CCodeLookup::Init()
{
  HRESULT hOK = S_OK;
  const char* procName = "CCodeLookup::Init";
  
  // instantiate a query adapter object second
  try
  {
    // create the queryadapter ...
    IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
    // initialize the queryadapter ...
    mConfigPath = CODE_LOOKUP_CONFIG_PATH;
    queryAdapter->Init(mConfigPath);
    
    // extract and detach the interface ptr ...
    mpQueryAdapter = queryAdapter.Detach();
  }
  catch (_com_error e)
  {
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to initialize query adapter");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError());
    return FALSE;
  }
    
	// build the table for the enumerated data
	if (!BuildEnumDataTable())
	{
		mLogger.LogThis (LOG_ERROR, 
						 "Unable to build a local UI Enum Data table");
	    return FALSE;
	}

	return TRUE; 
}


// @mfunc GetEnumDataCode
// @parm tag name
// @parm tag type
// @rdesc returns the corresponding value from the map 
DLL_EXPORT BOOL  
CCodeLookup::GetEnumDataCode (const wchar_t * apCodeName, int& code)
{
	long newCode;

	// TODO: should this be an assert or an error condition?
	ASSERT(apCodeName && *apCodeName);
	EnumDataKey key(apCodeName);

	// find the value

	// enter critical section
	//mLock.Lock();

	// If the data is not found in the map, then
	// 1) add it to the database
	// 2) add it to the map

	// If the add to the database fails (concurrency), then it means that
	// the data exists in the table, but is not in the map.
	// So, do the refresh of the map once again, then retrieve the value
	// If the map still does not have it, then return an error

	EnumDataTable::iterator it = mEnumDataTable.find(key);
	if (it == mEnumDataTable.end())
	{
		mLogger.LogVarArgs(LOG_WARNING, 
											 L"Code Name <%s> does not exist in the Table", apCodeName);

		if (!AddEnumData(apCodeName, newCode))
		{
			mLogger.LogThis(LOG_WARNING, 
							L"Doing refresh again to avoid database concurrency error");
		    if (!BuildEnumDataTable())
			{
			    mLogger.LogThis (LOG_ERROR, 
								 "Unable to build a local UI Enum Data table");
				return FALSE;
			}

				EnumDataTable::iterator it2 = mEnumDataTable.find(key);
				if (it == mEnumDataTable.end())
				{
					mLogger.LogVarArgs(LOG_ERROR, 
														 L"Code Name <%s> does not exist in the Table", apCodeName);
					return FALSE;
				}
				else
					code = it->second;
		}
		else
		{
			code = newCode;
			mEnumDataTable[key] = code;
			mIDToName[code] = apCodeName;
		}
	}
	else
	{
		code = it->second;
		mLogger.LogVarArgs(LOG_DEBUG, 
											 L"Code Name <%s> exists in the Table", apCodeName);
	}
	
	// leave critical section
	//mLock.Unlock();

	return TRUE;
}


// @mfunc GetValue
// @parm tag name
// @parm tag type
// @rdesc returns the corresponding value from the map 
DLL_EXPORT BOOL  
CCodeLookup::GetValue (const int iCode, std::wstring& value)
{
	IDToName::const_iterator it;
	it = mIDToName.find(iCode);
	if (it != mIDToName.end())
	{
		// found
		value = it->second;
		return TRUE;
	}

	// if it does not exist in the table, log it and do another refresh
	// of the local map.  After that is done do another find.
	mLogger.LogVarArgs(
	  LOG_DEBUG, 
	  L"Code <%d> not found in Map. Doing another refresh", iCode);

	// build the table for the enumerated data
	if (!BuildEnumDataTable())
	{
	    mLogger.LogThis (LOG_ERROR, "Refresh failed");
		return FALSE;
	}

	mLogger.LogVarArgs(
	  LOG_DEBUG, 
	  L"After refresh, finding code <%d> in map again", iCode);


	it = mIDToName.find(iCode);
	if (it != mIDToName.end())
	{
		// found
		value = it->second;
		return TRUE;
	}

	// still not found.
	mLogger.LogVarArgs(LOG_DEBUG,
										 L"ID <%d> not found in map even after refresh", iCode);
	return FALSE;
}

//	@mfunc AddEnumData
//  @parm New Value
//  @rdesc Add a new record in the hash dictionary and also a corresponding
//  record in the database.  This functionality is only available for the
//  pipeline, hence the data is only being inserted into the pipeline table
DLL_EXPORT BOOL 
CCodeLookup::AddEnumData (const std::wstring& pNewValue, long& newCode)
{
	// local variables	
	int newID;

	// initialize the database
	if (!DBAccess::Init((wchar_t *)mConfigPath))
	{
		SetError(DBAccess::GetLastError());
	    mLogger.LogThis (LOG_ERROR, "Database initialization failed");
		return FALSE;
	}

  	// intialize the stored procedure ...
  	if (!DBAccess::InitializeForStoredProc(L"InsertEnumData"))
  	{
    	SetError(DBAccess::GetLastError());
	    mLogger.LogThis (LOG_ERROR, "Initialization of stored procedure failed");
		return FALSE;
  	}

  	// add the parameters ...
  	_variant_t vtValue = pNewValue.c_str() ;
  	if (!DBAccess::AddParameterToStoredProc (L"nm_enum_data", MTTYPE_VARCHAR, 
    	INPUT_PARAM, vtValue))
  	{
    	SetError(DBAccess::GetLastError());
	    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
		return FALSE;
  	}
  	if (!DBAccess::AddParameterToStoredProc (L"id_enum_data", MTTYPE_INTEGER, OUTPUT_PARAM))
  	{
    	SetError(DBAccess::GetLastError());
	    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
		return FALSE;
  	}

  	// execute the stored procedure ...
  	if (!DBAccess::ExecuteStoredProc())
  	{
    	SetError(DBAccess::GetLastError());
	    mLogger.LogThis (LOG_ERROR, "Unable to execute stored procedure.");
		return FALSE;
  	}

  	// get the parameter ...
  	if (!DBAccess::GetParameterFromStoredProc (L"id_enum_data", vtValue))
  	{
    	SetError(DBAccess::GetLastError());
	    mLogger.LogThis (LOG_ERROR, "Unable to execute stored procedure.");
		return FALSE;
  	}

  	newID = vtValue.lVal ;

	// disconnect from db
	if (!DBAccess::Disconnect())
	{
		SetError(DBAccess::GetLastError());
	    mLogger.LogThis (LOG_ERROR, "Database disonnect failed");
		return FALSE;
	}

	newCode = newID;

	// bug fix 11940
	// CodeLookup::AddEnumData method does not check fo -99 (error condition) after InsertEnumData stored proc returns.
	if (newCode == -99)
  {
		SetError(DBAccess::GetLastError());
	  mLogger.LogThis (LOG_ERROR, "Error inserting into t_enum_data table");
		return FALSE;
  }

	return TRUE;
}

//	@mfunc BuildEnumDataTable
// 	@parm  
//  @rdesc Builds the mapping between the codes and their values
BOOL 
CCodeLookup::BuildEnumDataTable ()
{

    // local variables
	int iEnumID;
	std::wstring wstrEnumName;
	DBSQLRowset rowset;
	std::wstring langRequest;

	// 	Build the language request here
	if (!CreateQueryToGetEnumData(langRequest))
	{
	    mLogger.LogThis(LOG_ERROR, "Unable to generate query to get enum data");
		return FALSE;
	}

	// initialize the database context
	if (!DBAccess::Init((wchar_t *)mConfigPath))
	{
		SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR, 
						"Database initialization failed for code lookup object");
		return FALSE;
	}
	
	// execute the language request
	if (!DBAccess::Execute(langRequest, rowset))
	{
		SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR, 
						"Database execution failed for code lookup object");
		return FALSE;
	}

	// If no rows found
	if (rowset.GetRecordCount() ==	0)
	{
	    mLogger.LogThis(LOG_DEBUG, "No rows found for this query. The table is empty");
		return TRUE;
	}
		
	// Parse the record set
  BOOL bRetCode=TRUE ;
	while ((!rowset.AtEOF()) && (bRetCode == TRUE))
	{
	    // no need to cast to variant
		rowset.GetIntValue(_variant_t(ENUM_DATA_ID_STR), iEnumID);
		rowset.GetWCharValue(_variant_t(ENUM_DATA_NAME_STR), wstrEnumName);

		// Fill up the hash dictionary 
		EnumDataKey key(wstrEnumName.c_str());
		mEnumDataTable[key] = iEnumID;

		mIDToName[iEnumID] = wstrEnumName;

		// Move to next record
		bRetCode = rowset.MoveNext();
	}
		
	// disconnect from the database
	if (!DBAccess::Disconnect())
	{
	    SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
	    return FALSE;
	}

	return TRUE; 
}

//
//
//
BOOL
CCodeLookup::CreateQueryToGetEnumData (std::wstring& langRequest)
{
	// get the query
	_bstr_t queryTag;

	try
	{
	    mpQueryAdapter->ClearQuery();
		queryTag = "__SELECT_ENUM_DATA__";
		mpQueryAdapter->SetQueryTag(queryTag);

		langRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error& e)
	{
	    ErrorObject* err = CreateErrorFromComError(e);
		SetError (err);
		delete err;  // object is copied, so delete this one
	    return (FALSE);
	}

	return (TRUE);
}

// 	@parm  
//  @rdesc 
//
BOOL
CCodeLookup::CreateQueryToAddEnumData (const wchar_t* pNewValue,
									   std::wstring& langRequest)
{
	// assert for null value
	ASSERT (pNewValue);

	// get the query
	_bstr_t queryTag;
	_variant_t vtParam;

	try
	{
	    mpQueryAdapter->ClearQuery();
		queryTag = "__ADD_ENUM_DATA__";
		mpQueryAdapter->SetQueryTag(queryTag);

		vtParam = pNewValue;
		mpQueryAdapter->AddParam(MTPARAM_NEWENUMDATAVALUE, pNewValue);

		langRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error& e)
	{
	    ErrorObject* err = CreateErrorFromComError(e);
		SetError (err);
		delete err;  // object is copied, so delete this one
	    return (FALSE);
	}

	return (TRUE);
}

