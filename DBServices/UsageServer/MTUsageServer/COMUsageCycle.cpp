// COMUsageCycle.cpp : Implementation of CCOMUsageCycle
#include "StdAfx.h"
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#include "MTUsageServer.h"
#include "COMUsageCycle.h"
#include <mtprogids.h>
#include <DBConstants.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
/*
#undef min
#undef max

#import <MTUsageCycle.tlb> 
*/


/////////////////////////////////////////////////////////////////////////////
// CCOMUsageCycle
CCOMUsageCycle::CCOMUsageCycle()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[UsageCycle]") ;
}

CCOMUsageCycle::~CCOMUsageCycle()
{
}

STDMETHODIMP CCOMUsageCycle::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMUsageCycle,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CCOMUsageCycle::Init(long aCycleType, ::ICOMUsageCyclePropertyColl *apPropColl)
{
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  
  // initialize the usage cycle ...
  bRetCode = mUsageCycle.Init(aCycleType, apPropColl) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mUsageCycle.GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger.LogVarArgs (LOG_ERROR,
      "Init() failed.Unable to initialize usage cycle. Error = 0x%x", nRetVal) ;
  }

  return nRetVal;
}

STDMETHODIMP CCOMUsageCycle::AddAccount(BSTR apStartDate, BSTR apEndDate,
                                        long aAccountID, LPDISPATCH pRowset)
{
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  
  // call the usage cycle AddAccount ... 
  bRetCode = mUsageCycle.AddAccount(apStartDate, apEndDate, aAccountID, pRowset) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mUsageCycle.GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger.LogVarArgs (LOG_ERROR,
      "AddAccount() failed. Unable to add account to usage cycle. Error = 0x%x", nRetVal) ;
  }
  
  return nRetVal;
}

STDMETHODIMP CCOMUsageCycle::UpdateAccount(BSTR apStartDate, BSTR apEndDate,
                                           long aAccountID, VARIANT aCurrentIntervalEndDate)
{
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  
  // call the usage cycle UpdateAccount ... 
  bRetCode = mUsageCycle.UpdateAccount(apStartDate, apEndDate, 
    aAccountID, aCurrentIntervalEndDate) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mUsageCycle.GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger.LogVarArgs (LOG_ERROR,
      "UpdateAccount() failed. Unable to update account for usage cycle. Error = 0x%x", nRetVal) ;
  }
  
  return nRetVal;
}

STDMETHODIMP CCOMUsageCycle::CreateInterval(BSTR apStartDate, BSTR apEndDate)
{
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  BOOL bIntervalExists=TRUE ;

  // call the usage cycle CreateInterval ... 
  bRetCode = mUsageCycle.CreateInterval (apStartDate, apEndDate, bIntervalExists) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mUsageCycle.GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger.LogVarArgs (LOG_ERROR,
      "CreateInterval() failed. Unable to create interval. Error = 0x%x", nRetVal) ;
  }
  else
  {
    // if the interval didnt exist ... update the account to interval mappings ...
    if (bIntervalExists == FALSE)
    {
      bRetCode = mUsageCycle.UpdateAccountToIntervalMapping() ;
      if (bRetCode == FALSE)
      {
        const ErrorObject *pError = mUsageCycle.GetLastError() ;
        nRetVal = pError->GetCode() ;
        mLogger.LogVarArgs (LOG_ERROR,
          "CreateInterval() failed. Unable to update account to interval mapping. Error = 0x%x", nRetVal) ;
      }
    }
  }
  
  return nRetVal;
}

