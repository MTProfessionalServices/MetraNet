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
* $Header$
* 
***************************************************************************/


#ifndef __ROWSETEXECUTE_H__
#define __ROWSETEXECUTE_H__
#pragma once

#include "Rowset.h"
#include <MTRowSetImpl.h>
#include <errobj.h>
#include <atlbase.h>
#include <atlcom.h>
#include <mtprogids.h>
#include <mtcomerr.h>


// this class implements the IMTRowSetExecute interface.  However, we do NOT
// implement the Execute() method.  This is left up to the user.
template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
class MTRowSetExecute : public MTRowSetImpl<ExecuteInterface,piid,plibid>,
												public virtual ObjectWithError,
												public CComCoClass<T,pclsid>

{
public:

	MTRowSetExecute() : mInitialized(TRUE) {}
	virtual ~MTRowSetExecute() 
	{
		mInitialized = false;
	}
// ----------------------------------------------------------------
// The Clear method clears the current rowset.
// ----------------------------------------------------------------
	STDMETHOD(Clear)();
// ----------------------------------------------------------------
// The Init method initializes the rowset with the configuration path passed.
// ----------------------------------------------------------------
	STDMETHOD(Init)(/*[in]*/ BSTR apConfigPath);
	// ----------------------------------------------------------------
// The AddParam method adds the parameter to the the current query.
// ----------------------------------------------------------------
	STDMETHOD(AddParam)(/*[in]*/ BSTR apParamTag, /*[in]*/ VARIANT aParam, VARIANT aDontValidateString=VARIANT_FALSE);
// ----------------------------------------------------------------
// The SetQueryTag method sets the current query to create.
// ----------------------------------------------------------------
	STDMETHOD(SetQueryTag)(/*[in]*/ BSTR apQueryTag);

	// ----------------------------------------------------------------
// The ClearQuery method clears the current query..
// ----------------------------------------------------------------
	STDMETHOD(ClearQuery)();

	STDMETHOD(get_PopulatedRecordSet)(IDispatch** pDisp);
  STDMETHOD(put_PopulatedRecordSet)(IDispatch* pDisp);

	STDMETHOD(SetQueryString)( BSTR RawQuery);
	STDMETHOD(GetQueryString)( BSTR* apQuery);

	STDMETHOD(GetRawQueryString)(VARIANT_BOOL FillInSystemDefaults, BSTR* apQuery);

	STDMETHOD(AddParamIfFound)(/*[in]*/ BSTR apParamTag, /*[in]*/ VARIANT aParam, 
														VARIANT aDontValidateString=VARIANT_FALSE, VARIANT_BOOL* apFound=0);


protected:
	BOOL mInitialized;
private:
MTAutoInstance<MTAutoLoggerImpl<szMTRowSetExecuteTag,szDbObjectsDir> >	mLogger; 

};

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
template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::Init(BSTR apConfigPath)
{

  // if we've already allocated one ... delete it ...
  if (mpRowset != NULL)
  {
    delete mpRowset ;
    mpRowset = NULL ;
  }

  mpRowset = new DBSQLRowset ;
  if (mpRowset == NULL)
  {
    SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, 
      "MTSQLRowset::Init");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    return Error ("Init() failed. Unable to allocate rowset.") ;
  }


  // initialize the query adapter ...
  try
  {
    // create the queryadapter ...
    QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
    // initialize the queryadapter ...
    queryAdapter->Init(apConfigPath) ;
    
    // if we already have a queryadapter release it ...
    if (mpQueryAdapter != NULL)
    {
      mpQueryAdapter->Release() ;
      mpQueryAdapter = NULL ;
    }

    // extract and detach the interface ptr ...
    mpQueryAdapter = queryAdapter.Detach() ;
  }
  catch (_com_error e)
  {
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "MTSQLRowset::Init");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Error Description = %s", 
      (char*)e.Description()) ;
    return Error ("Init() failed. Unable to initialize query adapter.") ;
  }
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	Clear
// Arguments:     
// Return Value:  
// Errors Raised: 80020009 - Clear() failed. Unable to allocate rowset.
//                80020009 - Clear() failed. Unable to clear query adapter.
// Description:   The Clear method clears the current rowset and the current
//  query. 
// ----------------------------------------------------------------
template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::Clear()
{
  HRESULT nRetVal=S_OK ;

  // if we've already allocated one ... delete it ...
  if (mpRowset != NULL)
  {
    delete mpRowset ;
    mpRowset = NULL ;
  }

  // allocate a new one ...
  mpRowset = new DBSQLRowset ;
  if (mpRowset == NULL)
  {
    SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, 
      "MTSQLRowset::Clear") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mInitialized = FALSE ;
    return Error ("Clear() failed. Unable to allocate rowset.") ;
  }
  try
  {
    // clear the query ...
    if (mpQueryAdapter != NULL)
    {
      mpQueryAdapter->ClearQuery() ;
    }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
      "MTSQLRowset::Clear");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "Clear() failed. Error Description = %s", 
      (char*)e.Description()) ;
    mInitialized = FALSE ;
    return Error ("Clear() failed. Unable to clear query adapter.") ;
  }

	return nRetVal;
}

// ----------------------------------------------------------------
// Name:     	AddParam
// Arguments:     apParamTag - The name of the parameter 
//                aParam     - The value of the parameter
// Return Value:  
// Errors Raised: 80020009 - AddParam() failed. Unable to add parameter.
//                80020009 - AddParam() failed. MTSQLRowset not initialized.
// Description:   The AddParam method adds the specified parameter to the
//  query string. All instances of the parameter tag will be replaced by the
//  parameter value that is passed.
// ----------------------------------------------------------------
template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::AddParam(BSTR apParamTag, VARIANT aParam,  VARIANT aDontValidateString)
{
  // if we're initialized ...
  if (mInitialized == TRUE)
  {
    // add the parameter ...
    try 
    {
      mpQueryAdapter->AddParam(apParamTag, aParam, aDontValidateString) ;
    }
    catch (_com_error e)
    {
      SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
        "MTSQLRowset::AddParam");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, "AddParam() failed. Error Description = %s", 
        (char*)e.Description()) ;
      return Error ("AddParam() failed. Unable to add parameter.") ;
    }
  }
  else
  {
    mLogger->LogThis(LOG_ERROR, 
      "Unable to add parameter. Query adapter not initialized.") ;
    return Error ("AddParam() failed. MTSQLRowset not initialized.") ;
  }

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	AddParamIfFound
// Arguments:     apParamTag - The name of the parameter 
//                aParam     - The value of the parameter
// Return Value:  
// Errors Raised: 80020009 - AddParamIfFound() failed. Unable to add parameter.
//                80020009 - AddParamIfFound() failed. MTSQLRowset not initialized.
// Description:   The AddParam method adds the specified parameter to the
//  query string. All instances of the parameter tag will be replaced by the
//  parameter value that is passed. return false if param is not found and true otherwise
// ----------------------------------------------------------------
template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::AddParamIfFound(BSTR apParamTag, VARIANT aParam,  
																																							VARIANT aDontValidateString, VARIANT_BOOL* apFound)
{
  // if we're initialized ...
  if (mInitialized == TRUE)
  {
    // add the parameter ...
    try 
    {
      (*apFound) = mpQueryAdapter->AddParamIfFound(apParamTag, aParam, aDontValidateString);
    }
    catch (_com_error e)
    {
      SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
        "MTSQLRowset::AddParamIfFound");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, "AddParamIfFound() failed. Error Description = %s", 
        (char*)e.Description()) ;
      return Error ("AddParam() failed. Unable to add parameter.") ;
    }
  }
  else
  {
    mLogger->LogThis(LOG_ERROR, 
      "Unable to add parameter. Query adapter not initialized.") ;
    return Error ("AddParam() failed. MTSQLRowset not initialized.") ;
  }

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	SetQueryTag
// Arguments:     apQueryTag - the query tag to set
// Return Value:  
// Errors Raised: 80020009 - SetQueryTag() failed. Unable to set the query tag.
//                80020009 - SetQueryTag() failed. MTSQLRowset not initialized.
// Description:   The SetQueryTag method sets the query tag in the MTSQLRowset.
// ----------------------------------------------------------------

template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::SetQueryTag(BSTR apQueryTag)
{
  // if we're initialized ...
  if (mInitialized == TRUE)
  {
    // set the query tag ...
    try 
    {
      mpQueryAdapter->SetQueryTag(apQueryTag) ;
    }
    catch (_com_error e)
    {
      SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
        "MTSQLRowset::SetQueryTag");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, "SetQueryTag() failed. Error Description = %s", 
        (char*)e.Description()) ;
      return Error ("SetQueryTag() failed. Unable to set the query tag.") ;
    }
  }
  else
  {
    mLogger->LogThis(LOG_ERROR, 
      "Unable to set query tag. Query adapter not initialized.") ;
    return Error ("SetQueryTag() failed. MTSQLRowset not initialized.") ;
  }

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	ClearQuery
// Arguments:     
// Return Value:  
// Errors Raised: 80020009 - ClearQuery() failed. Unable to clear query adapter.
// Description:   The ClearQuery method clears the currently set query.
// ----------------------------------------------------------------
template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::ClearQuery()
{
  HRESULT nRetVal=S_OK ;

  try
  {
    // clear the query ...
    if (mpQueryAdapter != NULL)
    {
      mpQueryAdapter->ClearQuery() ;
    }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
      "MTSQLRowset::ClearQuery");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "ClearQuery() failed. Error Description = %s", 
      (char*)e.Description()) ;
    mInitialized = FALSE ;
    return Error ("ClearQuery() failed. Unable to clear query adapter.") ;
  }

	return nRetVal;
}

template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::get_PopulatedRecordSet(IDispatch** pDisp)
{
	ASSERT(pDisp);
	if(!pDisp) return E_POINTER;
	HRESULT hr = S_OK;

	try {
		_RecordsetPtr aRecordSet = mpRowset->GetRecordsetPtr();
		hr = aRecordSet.QueryInterface(IID_IDispatch,(void**)pDisp);
	}
	catch(_com_error& e) {
		return ReturnComError(e);
	}
	return S_OK;
}

template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::put_PopulatedRecordSet(IDispatch* pDisp)
{
	ASSERT(pDisp);
	if(!pDisp) return E_POINTER;
	HRESULT hr = S_OK;

	try {
    IDispatchPtr pDispPtr = pDisp;
    _RecordsetPtr tempRecordSet = pDispPtr; // QI
    if(tempRecordSet == NULL) {
      MT_THROW_COM_ERROR("PopulatedRecordSet: Query Interface failed for recordset");
    }
    mpRowset->PutRecordSet(tempRecordSet);
	}
	catch(_com_error& e) {
		return ReturnComError(e);
	}
	return S_OK;
}



template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::SetQueryString(BSTR RawQuery)
{
	ASSERT(RawQuery);
	if(!RawQuery) return E_POINTER;

	if(mpQueryAdapter == NULL) {
		return Error("Init must be called prior to execution");
	}

	return mpQueryAdapter->SetRawSQLQuery(RawQuery);
}

template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::GetQueryString(BSTR* apQuery)
{
	_bstr_t bstrQuery;
	try
	{
		if(mpQueryAdapter == NULL) {
			return Error("Init must be called prior to execution");
		}

		bstrQuery = mpQueryAdapter->GetQuery();
	}
	catch(_com_error& e) 
	{
		return ReturnComError(e);
	}
	(*apQuery) = bstrQuery.copy();
	return S_OK;
}

template <class ExecuteInterface,class T, const CLSID* pclsid,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetExecute<ExecuteInterface,T,pclsid,piid,plibid>::GetRawQueryString(VARIANT_BOOL FillInSystemDefaults, BSTR* apQuery)
{
	_bstr_t bstrQuery;
	try
	{
		if(mpQueryAdapter == NULL) {
			return Error("Init must be called prior to execution");
		}

		bstrQuery = mpQueryAdapter->GetRawSQLQuery(FillInSystemDefaults);
	}
	catch(_com_error& e) 
	{
		return ReturnComError(e);
	}
	(*apQuery) = bstrQuery.copy();
	return S_OK;
}

#endif //__ROWSETEXECUTE_H__
