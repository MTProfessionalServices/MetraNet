/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: 
* $Header: MTSQLRowset.cpp, 45, 7/26/2002 5:55:50 PM, Raju Matta$
* 
***************************************************************************/
// MTSQLRowset.cpp : Implementation of CMTSQLRowset
#include "StdAfx.h"
#include "Rowset.h"
#include "MTSQLRowset.h"
#include <DBSQLRowset.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <optionalvariant.h>

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")

// import the performance tlb ...
#import <MetraTech.Performance.tlb>

// import the config loader ...
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

/////////////////////////////////////////////////////////////////////////////
// CMTSQLRowset
CMTSQLRowset::CMTSQLRowset() 
{
}

CMTSQLRowset::~CMTSQLRowset()
{

  if (!mDBAccess.Disconnect())
	{
		SetError (mDBAccess.GetLastError(), "Unable to disconnect from database");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
	}
}

HRESULT CMTSQLRowset::FinalConstruct()
{
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mpUnkMarshaler.p);
		if (FAILED(hr))
			throw _com_error(hr);
		else
			return hr;
	}	
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

void CMTSQLRowset::FinalRelease()
{
	mpUnkMarshaler.Release();
}


STDMETHODIMP CMTSQLRowset::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSQLRowset,
    &IID_IMTRowSetExecute,
    &IID_IMTRowSet
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


// ----------------------------------------------------------------
// Name:     	UpdateConfigPath
// Arguments:     apConfigPath - the relative configuration path
// Return Value:  
// Errors Raised: 80020009 - UpdateConfigPath() failed. Unable to initialize query adapter.
// Description:   The UpdateConfigPath method reads the query file 
//  from the specified directory and uses that query file for future 
//  queries.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::UpdateConfigPath(BSTR apConfigPath)
{
  // local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  try
  {
    // initialize the queryadapter ...
    mpQueryAdapter->Init(apConfigPath) ;
  }
  catch (_com_error e)
  {
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "MTSQLRowset::UpdateConfigPath");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "UpdateConfigPath() failed. Error Description = %s", 
      (char*)e.Description()) ;
    return Error ("UpdateConfigPath() failed. Unable to initialize query adapter.") ;
  }

  return S_OK ;
}

// ----------------------------------------------------------------
// Name:     	Init
// Arguments:     apConfigPath - The relative configuration path to the query file
// Return Value:  
// Errors Raised: 80020009 - Init() failed. Unable to allocate rowset.
//                80020009 - Init() failed. Unable to initialize query adapter.
//                80020009 - Init() failed. Unable to initialize dbaccess layer
// Description:   The Init method initializes the rowset by initializing the
//  connection to the database and by reading the query file from the 
//  specified configuration path.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::Init(BSTR apConfigPath)
{
	HRESULT hr = MTRowSetExecute<IMTSQLRowset,CMTSQLRowset,&CLSID_MTSQLRowset,&IID_IMTSQLRowset, &LIBID_ROWSETLib>::Init(apConfigPath);
	if(FAILED(hr)) {
		return hr;
	}

  // local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we're already initialized ...
  if (mInitialized == TRUE)
  {
    // disconnect from the database
    if (!mDBAccess.Disconnect())
    {
      SetError (mDBAccess.GetLastError(), "Unable to disconnect from database");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }

  // make a copy of the configPath ...
  _bstr_t configPath = apConfigPath ;

	
	// initialize the database access layer with the db config info read ...
  bRetCode = mDBAccess.Init((wchar_t*)configPath) ;
  if (bRetCode == FALSE)
  {
      SetError (mDBAccess.GetLastError(), "Init() failed. Unable to initialize dbaccess layer");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return Error("Init() failed. Unable to initialize dbaccess layer") ;
  }

  mStoredProcName = NULL;

  // set the initialized flag ...
  mInitialized = TRUE ;

  return S_OK ;

}

//
//	@mfunc
//	Changes DBName re-initialize and connect the database context object.
//  @rdesc 
//  Returns OK on success. Otherwise, sets the error code
//  
STDMETHODIMP CMTSQLRowset::ChangeDbName(BSTR newDbName)
{
  BOOL bRetCode = mDBAccess.ChangeDbName((wchar_t*) newDbName) ;
  if (bRetCode == FALSE)
  {
      SetError (mDBAccess.GetLastError(), "Init() failed. Unable to change DBNAme and re-initialize dbaccess layer");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return Error("Init() failed. Unable to initialize dbaccess layer") ;
  }
  return S_OK ;
}

// The Init method initializes the rowset with the configuration path passed.
STDMETHODIMP CMTSQLRowset::InitDisconnected()
{

  // if we've already allocated one ... delete it ...
  if (mpRowset != NULL)
  {
    delete mpRowset ;
    mpRowset = NULL ;
  }

  mpRowset = new DBSQLRowset;

  // initialize the query adapter ...
  try
  {
		mpRowset->InitDisconnected();
  }
  catch (_com_error e)
  {
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "MTSQLRowset::InitDisconnected");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Error Description = %s", 
      (char*)e.Description()) ;
    return Error ("Init() failed. Unable to initialize disconnected rowset.") ;
  }
	return S_OK;

}

// The Init method initializes the rowset with the configuration path passed.
STDMETHODIMP CMTSQLRowset::OpenDisconnected()
{
  if (mpRowset == NULL)
  {
    SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, 
      "MTSQLRowset::OpenDisconnected");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    return Error ("OpenDisconnected() failed. Unable to allocate rowset.") ;
  }

  try
  {
		_RecordsetPtr & rs = mpRowset->GetRecordsetPtr();
		rs->Open(vtMissing, vtMissing, adOpenStatic,adLockBatchOptimistic,-1);
  }
  catch (_com_error e)
  {
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "MTSQLRowset::OpenDisconnected");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "OpenDisconnected() failed. Error Description = %s", 
      (char*)e.Description()) ;
    return Error ("OpenDisconnected() failed. Unable to initialize disconnected rowset.") ;
  }
	return S_OK;

}





// ----------------------------------------------------------------
// Name:     	Execute
// Arguments:     
// Return Value:  
// Errors Raised: 80020009 - Execute() failed. Unable to get query.
//                80020009 - Execute() failed. Unable to execute query.
//                80020009 - Execute() failed. MTSQLRowset not initialized.
// Description:   The Execute method gets the query that has been created and 
//  executes it using the database access layer.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::Execute()
{
  _bstr_t queryString ;
  BOOL bRetCode=TRUE ;

  // if we're initialized ...
  if (mInitialized == TRUE)
  {
    // get the query ...
    try 
    {
      queryString = mpQueryAdapter->GetQuery() ;
    }
    catch (_com_error e)
    {
      SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
        "MTSQLRowset::Execute");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, "Execute() failed. Error Description = %s", 
        (char*)e.Description()) ;
      return Error ("Execute() failed. Unable to get query.") ;
    }
    
    MetraTech_Performance::IPerformanceStopWatchWrapperPtr performanceStopWatchWrapperPtr;
    HRESULT hr = performanceStopWatchWrapperPtr.CreateInstance(__uuidof(MetraTech_Performance::PerformanceStopWatchWrapper));
    performanceStopWatchWrapperPtr->Start();
      
    // execute the query ...
    bRetCode = mDBAccess.Execute ((wchar_t*)queryString, *mpRowset) ;
    _bstr_t queryTag = mpQueryAdapter->GetQueryTag();
    
    if ((char*)queryTag == NULL)
    {
      performanceStopWatchWrapperPtr->Stop(queryString);
    }
    else
    {
      performanceStopWatchWrapperPtr->Stop(mpQueryAdapter->GetQueryTag());
    }
    
    if (bRetCode == FALSE)
    {
      SetError (mDBAccess.GetLastError()) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return Error ("Execute() failed. Unable to execute query.") ;
    }
  }
  else
  {
    mLogger->LogThis(LOG_ERROR, 
      "Unable to execute query. Query adapter not initialized.") ;
    return Error ("Execute() failed. MTSQLRowset not initialized.") ;
  }

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	ExecuteConnected
// Arguments:     
// Return Value:  
// Errors Raised: 80020009 - Execute() failed. Unable to get query.
//                80020009 - Execute() failed. Unable to execute query.
//                80020009 - Execute() failed. MTSQLRowset not initialized.
// Description:   The Execute method gets the query that has been created and 
//  executes it using the database access layer
// ----------------------------------------------------------------

// NOTE: this method correctly uses connected recordsets (unlike Execute)
STDMETHODIMP CMTSQLRowset::ExecuteConnected()
{
  _bstr_t queryString ;
  BOOL bRetCode=TRUE ;

  // if we're initialized ...
  if (mInitialized == TRUE)
  {
    // get the query ...
    try 
    {
      queryString = mpQueryAdapter->GetQuery() ;
    }
    catch (_com_error e)
    {
      SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
        "MTSQLRowset::Execute");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, "Execute() failed. Error Description = %s", 
        (char*)e.Description()) ;
      return Error ("Execute() failed. Unable to get query.") ;
    }
    MetraTech_Performance::IPerformanceStopWatchWrapperPtr performanceStopWatchWrapperPtr;
    HRESULT hr = performanceStopWatchWrapperPtr.CreateInstance(__uuidof(MetraTech_Performance::PerformanceStopWatchWrapper));
    performanceStopWatchWrapperPtr->Start();
    // execute the query ...
    bRetCode = mDBAccess.ExecuteConnected ((wchar_t*)queryString, *mpRowset) ;
    performanceStopWatchWrapperPtr->Stop(mpQueryAdapter->GetQueryTag());
    if (bRetCode == FALSE)
    {
      SetError (mDBAccess.GetLastError()) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return Error ("Execute() failed. Unable to execute query.") ;
    }
  }
  else
  {
    mLogger->LogThis(LOG_ERROR, 
      "Unable to execute query. Query adapter not initialized.") ;
    return Error ("Execute() failed. MTSQLRowset not initialized.") ;
  }

	return S_OK;
}


// ----------------------------------------------------------------
// Name:     	ExecuteDisconnected
// Arguments:     
// Return Value:  
// Errors Raised: 80020009 - Execute() failed. Unable to get query.
//                80020009 - Execute() failed. Unable to execute query.
//                80020009 - Execute() failed. MTSQLRowset not initialized.
// Description:   The Execute method gets the query that has been created and 
//  executes it using the database access layer, then disconnects rowset and closes
//  the connection
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::ExecuteDisconnected()
{
  _bstr_t queryString ;
  BOOL bRetCode=TRUE ;

  // if we're initialized ...
  if (mInitialized == TRUE)
  {
    // get the query ...
    try 
    {
      queryString = mpQueryAdapter->GetQuery() ;
    }
    catch (_com_error e)
    {
      SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
        "MTSQLRowset::Execute");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, "Execute() failed. Error Description = %s", 
        (char*)e.Description()) ;
      return Error ("Execute() failed. Unable to get query.") ;
    }
    // execute the query and disconnect rowset from connnection
		// use adLockBatchOptimistic to get an updatable rowset
    MetraTech_Performance::IPerformanceStopWatchWrapperPtr performanceStopWatchWrapperPtr;
    HRESULT hr = performanceStopWatchWrapperPtr.CreateInstance(__uuidof(MetraTech_Performance::PerformanceStopWatchWrapper));
    performanceStopWatchWrapperPtr->Start();
    bRetCode = mDBAccess.ExecuteDisconnected((wchar_t*)queryString, *mpRowset, adLockBatchOptimistic) ; 
    performanceStopWatchWrapperPtr->Stop(mpQueryAdapter->GetQueryTag());
    if (bRetCode == FALSE)
    {
      SetError (mDBAccess.GetLastError()) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return Error ("Execute() failed. Unable to execute query.") ;
    }

		// close connection
    if (!mDBAccess.Disconnect())
    {
      SetError (mDBAccess.GetLastError(), "Unable to disconnect from database");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    mLogger->LogThis(LOG_ERROR, 
      "Unable to execute query. Query adapter not initialized.") ;
    return Error ("Execute() failed. MTSQLRowset not initialized.") ;
  }

	return S_OK;
}


// ----------------------------------------------------------------
// Name:     	BeginTransaction
// Arguments:     
// Return Value:  
// Errors Raised: 80020009 - BeginTransaction() failed. Unable to begin transaction.
// Description:   The BeginTransaction method begins a local transaction. 
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::BeginTransaction()
{
	// begin the transaction ...
  BOOL bRetCode = mDBAccess.BeginTransaction() ;
  if (bRetCode == FALSE)
  {
    SetError (mDBAccess.GetLastError()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("BeginTransaction() failed. Unable to begin transaction.") ;
  }

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	CommitTransaction
// Arguments:     
// Return Value:  
// Errors Raised: 80020009 - CommitTransaction() failed. Unable to commit transaction.
// Description:   The CommitTransaction method commits a previosuly started transaction.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::CommitTransaction()
{
	// commit the transaction ...
  BOOL bRetCode = mDBAccess.CommitTransaction() ;
  if (bRetCode == FALSE)
  {
    SetError (mDBAccess.GetLastError()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("CommitTransaction() failed. Unable to commit transaction.") ;
  }

	return S_OK;
}


// ----------------------------------------------------------------
// Name:     	RollbackTransaction
// Arguments:     
// Return Value:  
// Errors Raised: 80020009 - RollbackTransaction() failed. Unable to rollback transaction.
// Description:   The RollbackTransaction method rolls back a transaction.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::RollbackTransaction()
{
	// rollback the transaction ...
  BOOL bRetCode = mDBAccess.RollbackTransaction() ;
  if (bRetCode == FALSE)
  {
    SetError (mDBAccess.GetLastError()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("RollbackTransaction() failed. Unable to rollback transaction.") ;
  }

	return S_OK;
}


// ----------------------------------------------------------------
// Name:     	JoinDistributedTransaction
// Arguments:     transactioncookie - The transaction cookie of the transaction to join
// Return Value:  
// Errors Raised: 80020009 - JoinDistributedTransaction() failed. Unable to join Distributed transaction.
// Description:   The JoinDistributedTransaction method joins a
//  distrbuted transaction specified by the transaction cookie.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::JoinDistributedTransaction(/*[in]*/ IMTTransaction * apTransaction)
{
	try
	{
		RowSetInterfacesLib::IMTTransactionPtr transaction(apTransaction);

		BOOL bRetCode = mDBAccess.JoinDistributedTransaction(transaction);
		if (bRetCode == FALSE)
		{
			SetError (mDBAccess.GetLastError()) ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			return Error ("JoinDistributedTransaction() failed. Unable to join Distributed transaction.") ;
		}
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

// ----------------------------------------------------------------
// The GetDistributedTransaction method joins a distributed transaction.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::GetDistributedTransaction(/*[out, retval]*/ IMTTransaction * * apTransaction)
{
	try
	{
		// TODO: no longer supported!  remove this method
		return E_NOTIMPL;

#if 0
		if (!apTransaction)
			return E_POINTER;

		RowSetInterfacesLib::IMTTransactionPtr transaction = mDBAccess.GetDistributedTransaction();
		if (transaction == NULL)
		{
			*apTransaction = NULL;
			return S_OK;
		}

		return transaction->QueryInterface(__uuidof(transaction), (void**) apTransaction);
#endif
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}


// ----------------------------------------------------------------
// Name:     	InitializeForStoredProc
// Arguments:     apStoredProc - the stored procedure name
// Return Value:  
// Errors Raised: 80020009 - InitializeForStoredProc() failed. Unable to initialize rowset for stored procedure.
// Description:   The InitializeForStoredProc method initializes the 
//  rowset for the specified stored procedure.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::InitializeForStoredProc (BSTR apStoredProcName)
{
  // local variables
  BOOL bRetCode=TRUE ;

  mStoredProcName = apStoredProcName;

  // call initialize for stored proc ...
  bRetCode = mDBAccess.InitializeForStoredProc (apStoredProcName) ;
  if (bRetCode == FALSE)
  {
    SetError (mDBAccess.GetLastError()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("InitializeForStoredProc() failed. Unable to initialize rowset for stored procedure.") ;
  }

  return S_OK ;
}

// ----------------------------------------------------------------
// Name:     	AddInputParameterToStoredProc
// Arguments:     apParamName - The name of the parameter
//                aType       - The type of the parameter
//                aDirection  - The direction of the parameter
//                aValue      - The value of the parameter
// Return Value:  
// Errors Raised: 80020009 - AddInputParameterToStoredProc() failed. Unable to add parameter to stored procedure.
// Description:   The AddInputParameterToStoredProc method adds the specified parameter
//  to the stored procedure.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::AddInputParameterToStoredProc (BSTR apParamName, 
    long aType, long aDirection, VARIANT aValue)
{
  // local variables
  BOOL bRetCode=TRUE ;

  // call add parameter for stored proc ...
  bRetCode = mDBAccess.AddParameterToStoredProc (apParamName, (MTParameterType) aType,
    (MTParameterDirection) aDirection, aValue) ;
  if (bRetCode == FALSE)
  {
    SetError (mDBAccess.GetLastError()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("AddInputParameterToStoredProc() failed. Unable to add parameter to stored procedure.") ;
  }

  return S_OK ;
}

// ----------------------------------------------------------------
// Name:     	AddOutputParameterToStoredProc
// Arguments:     apParamName - The name of the parameter
//                aType       - The type of the parameter
//                aDirection  - The direction of the parameter
// Return Value:  
// Errors Raised: 80020009 - AddOutputParameterToStoredProc() failed. Unable to add parameter to stored procedure.
// Description:   The AddOutputParameterToStoredProc method adds the specified parameter
//  to the stored procedure.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::AddOutputParameterToStoredProc (BSTR apParamName, 
    long aType, long aDirection)
{
  // local variables
  BOOL bRetCode=TRUE ;

  // call add parameter for stored proc ...
  bRetCode = mDBAccess.AddParameterToStoredProc (apParamName, (MTParameterType) aType,
    (MTParameterDirection) aDirection) ;
  if (bRetCode == FALSE)
  {
    SetError (mDBAccess.GetLastError()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("AddOutputParameterToStoredProc() failed. Unable to add parameter to stored procedure.") ;
  }

  return S_OK ;
}



// ----------------------------------------------------------------
// Name:     	ExecuteStoredProc
// Arguments:     
// Return Value:  
// Errors Raised: 80020009 - ExecuteStoredProc() failed.
// Description:   The ExecuteStoredProc method executes the stored procedure.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::ExecuteStoredProc()
{
  // local variables
  BOOL bRetCode=TRUE ;

  // call execute for stored proc ...
  MetraTech_Performance::IPerformanceStopWatchWrapperPtr performanceStopWatchWrapperPtr;
  HRESULT hr = performanceStopWatchWrapperPtr.CreateInstance(__uuidof(MetraTech_Performance::PerformanceStopWatchWrapper));
  performanceStopWatchWrapperPtr->Start();
  

  bRetCode = mDBAccess.ExecuteStoredProc(*mpRowset) ;
  performanceStopWatchWrapperPtr->Stop(mStoredProcName);
  
  if (bRetCode == FALSE)
  {
    SetError (mDBAccess.GetLastError()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Stored procedure execution failed") ;
  }

  return S_OK ;
}


// ----------------------------------------------------------------
// Name:     	GetParameterFromStoredProc
// Arguments:     apParamName - The parameter name
//                apValue - The value of the parameter
// Return Value:  the value of the parameter
// Errors Raised: 80020009 - GetParameterFromStoredProc() failed. Unable to get parameter from stored procedure.
// Description:   The GetParameterFromStoredProc method gets the specified 
//  parameter from the stored procedure.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::GetParameterFromStoredProc (BSTR apParamName, 
                                           VARIANT * apValue)
{
  // local variables
  BOOL bRetCode=TRUE ;
  _variant_t value ;

  // call get parameter from stored proc ...
  bRetCode = mDBAccess.GetParameterFromStoredProc (apParamName, value) ;
  if (bRetCode == FALSE)
  {
    SetError (mDBAccess.GetLastError()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("GetParameterFromStoredProc() failed. Unable to get parameter from stored procedure.") ;
  }

  // copy the variant ...
  *apValue = value.Detach() ;

  return bRetCode ;
}

// ----------------------------------------------------------------
// Name:     	GetDBType
// Arguments:     apDBType - the database type 
// Return Value:  the database type
// Errors Raised: 
// Description:   The GetDBType method gets the database type that is being used.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::GetDBType(BSTR * apDBType)
{
	// get the database type ...
	return mpQueryAdapter->raw_GetDBType (apDBType) ;
}


// TODO: document these (dyoung)

// ----------------------------------------------------------------
// The AddRow method adds a row to the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::AddRow()
{
	// if we have a rowset ...
  if (mpRowset != NULL) {
		try
		{
			mpRowset->AddRow();
		}
		catch (_com_error & e) {
			return ReturnComError(e);
		}
	}
	return S_OK;
}

// ----------------------------------------------------------------
// The AddColumnData adds the data in the specified column.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::AddColumnData(/*[in]*/ BSTR apName, /*[in]*/ VARIANT aValue)
{
  if (mpRowset != NULL) {
		try {
			mpRowset->AddColumnData(apName, aValue);
		}
		catch (_com_error & e) {
			return ReturnComError(e);
		}
	}
	return S_OK;
}

// ----------------------------------------------------------------
// The ModifyColumnData modifies the data in the specified column.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::ModifyColumnData(/*[in]*/ BSTR apName, /*[in]*/ VARIANT aValue)
{
	// WARNING: not implemented by the C++ object

  if (mpRowset != NULL)
  {
		try {
			mpRowset->ModifyColumnData(apName, aValue);
		}
		catch (_com_error & e) {
			return ReturnComError(e);
		}
	}
	return S_OK;
}

// ----------------------------------------------------------------
// The AddColumnDefinition method adds a new column to the rowset definition.
// ----------------------------------------------------------------
STDMETHODIMP CMTSQLRowset::AddColumnDefinition(/*[in]*/ BSTR apName,
																							 /*[in]*/ BSTR apType, int aLen)
{
  if (mpRowset != NULL)
  {
		try {
			mpRowset->AddColumnDefinition(apName, apType, aLen);
		}
		catch (_com_error & e) {
			return ReturnComError(e);
		}
	}
	return S_OK;
}


STDMETHODIMP CMTSQLRowset::AddColumnDefinitionByType(BSTR apName,long apType,int aLen)
{
 if (mpRowset != NULL) {
		try {
			mpRowset->AddColumnDefinition(apName, (DataTypeEnum)apType, aLen);
		}
		catch (_com_error & e) {
			return ReturnComError(e);
		}
	}
 return S_OK;
}


STDMETHODIMP CMTSQLRowset::SaveToFile(BSTR aFileName,VARIANT StyleSheet)
{
	try {
    _variant_t vtStyleSheet;
    if(OptionalVariantConversion(StyleSheet,VT_BSTR,vtStyleSheet)) {
      MSXML2::IXMLDOMDocumentPtr aDomDoc("MSXML2.DOMDocument.4.0");
      IDispatchPtr pDisp = aDomDoc;
      _variant_t vtDisp(pDisp,true);
      mpRowset->GetRecordsetPtr()->Save(vtDisp, adPersistXML);
      // add the stylesheet as a processing instruction
      MSXML2::IXMLDOMProcessingInstructionPtr piPtr;

      piPtr = aDomDoc->createProcessingInstruction("xml-stylesheet",_bstr_t(vtStyleSheet));
      aDomDoc->insertBefore(piPtr,_variant_t(IDispatchPtr(aDomDoc->GetchildNodes()->Getitem(0)),true));
      aDomDoc->save(aFileName);
    }
    else {
      mpRowset->GetRecordsetPtr()->Save(aFileName, adPersistXML);
    }

	}
	catch (_com_error & e) {
		return ReturnComError(e);
	}
  return S_OK;
}

STDMETHODIMP CMTSQLRowset::SaveToXml(VARIANT apStyleSheetNode, BSTR* apXmlString)
{
  try 
  {
    MSXML2::IXMLDOMDocumentPtr domDoc("MSXML2.DOMDocument.4.0");
    IDispatchPtr pDisp = domDoc;
    _variant_t vtDisp(pDisp,true);
    mpRowset->GetRecordsetPtr()->Save(vtDisp, adPersistXML);

    _bstr_t xmlString;
    _variant_t varStyleSheetNode;
    if(OptionalVariantConversion(apStyleSheetNode, VT_DISPATCH, varStyleSheetNode)) 
    {
      MSXML2::IXMLDOMNodePtr styleSheetNode = varStyleSheetNode;
      xmlString = domDoc->transformNode(styleSheetNode);
    }
    else
    {
      xmlString = domDoc->xml;
    }

    *apXmlString = xmlString.copy();
  }
  catch (_com_error & e) {
    return ReturnComError(e);
  }
  return S_OK;
}
