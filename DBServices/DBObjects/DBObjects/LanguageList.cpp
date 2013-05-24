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
* 	LanguageList.cpp : 
*	--------------
*	This is the implementation of the LanguageList class.
***************************************************************************/


// All the includes

// ADO includes
#include <comdef.h>
#include <adoutil.h>

// Local includes
#include <LanguageList.h>
#include <mtcomerr.h>
#include <loggerconfig.h>

// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "GetUserNameQA") no_namespace 

#include <mtprogids.h>
#include <mtparamnames.h>

using namespace std;

// All the constants

// @mfunc CLanguageList default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// Code Lookup class
DLL_EXPORT CLanguageList::CLanguageList() :
mpQueryAdapter(0)
{
  LoggerConfigReader cfgRdr;
  mLogger.Init(cfgRdr.ReadConfiguration("LanguageList"), "[LanguageList]");
}


DLL_EXPORT CLanguageList * CLanguageList::GetInstance()
{
  return MTSingleton<CLanguageList>::GetInstance();
}

DLL_EXPORT void CLanguageList::ReleaseInstance()
{
  MTSingleton<CLanguageList>::ReleaseInstance();
}

// @mfunc CLanguageList destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// Code Lookup class
DLL_EXPORT CLanguageList::~CLanguageList()
{
  if (mpQueryAdapter != 0)
  {
    mpQueryAdapter->Release();
    mpQueryAdapter = 0;
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
CLanguageList::Init()
{
  HRESULT hr = S_OK;
  const char* procName = "CLanguageList::Init";
  
  // instantiate a query adapter object second
  try
  {
    // create the queryadapter ...
    IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
    // initialize the queryadapter ...
    queryAdapter->Init("\\Queries\\Database");
    
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
  if (!BuildLanguageList())
  {
    mLogger.LogThis (LOG_ERROR, "Unable to build language list");
    return FALSE;
  }
  
  return TRUE;
}


//	@mfunc BuildLanguageList
// 	@parm  
//  @rdesc Builds the mapping between the codes and their values
//  A description would be "
//  LanguageID   LanguageCode
//  156          cn 
BOOL 
CLanguageList::BuildLanguageList ()
{
  
  // local variables
  wstring wstrEnumName;
  DBSQLRowset rowset;
  _bstr_t langRequest;
  _variant_t vtLanguageCode;
  int iLanguageID;
  _bstr_t wstrLanguageCode;
  
  // get the query
  _bstr_t queryTag;
  
  try
  {
    mpQueryAdapter->ClearQuery();
    queryTag = "__GET_LANGUAGE_CODES__";
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
  
  // initialize the database context
  if (!DBAccess::Init(L"\\Queries\\Database"))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis(LOG_ERROR, "Database initialization failed");
    return FALSE;
  }
  
  // execute the language request
  if (!DBAccess::Execute((const wchar_t*)langRequest, rowset))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis(LOG_ERROR, "Database execution failed");
    return FALSE;
  }
  
  // If no rows found
  if (rowset.GetRecordCount() ==	0)
  {
    return TRUE;
  }
		
  // Parse the record set
  BOOL bRetCode=TRUE ;
  while ((!rowset.AtEOF()) && (bRetCode == TRUE))
  {
    // no need to cast to variant
    rowset.GetIntValue(_variant_t("LanguageID"), iLanguageID);
    rowset.GetValue(_variant_t("LanguageCode"), vtLanguageCode);
    
    wstrLanguageCode = vtLanguageCode.bstrVal;
    
    
    // 
    mLanguageList.insert
      (LanguageList::value_type(iLanguageID, wstrLanguageCode));

		mReverseList.insert(ReverseLanguageList::value_type(wstrLanguageCode,iLanguageID));
    
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

//	@mfunc getLanguageListIterator
// 	@parm  
//  @rdesc Gets the value of the iterator
//  LanguageIDCode   LanguageString
//  156|cn           Chinese (CN)
DLL_EXPORT LanguageListIterator 
CLanguageList::GetLanguageListIterator () 
{
  // iterate through the map
  LanguageListIterator itr = mLanguageList.begin();
  return itr;
}

//	@mfunc getLanguageList
// 	@parm  
//  @rdesc Gets the reference to the language list map
DLL_EXPORT const LanguageList&
CLanguageList::GetLanguageList() 
{
  // iterate through the map
  if (mLanguageList.empty())
    mLogger.LogThis(LOG_ERROR, "Language List map is empty");
  
  return mLanguageList;
}

const ReverseLanguageList& CLanguageList::GetReverseLanguageList()
{
	return mReverseList;
}

ReverseLanguageListIterator CLanguageList::GetReverseLanguageListIterator()
{
	ReverseLanguageListIterator itr = mReverseList.begin();
	return itr;
}


