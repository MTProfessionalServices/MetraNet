// COMUsageInterval.cpp : Implementation of CCOMUsageInterval
#include "StdAfx.h"
#include "MTUsageServer.h"
#undef min
#undef max
#include "COMUsageInterval.h"
#include <loggerconfig.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageInterval

CCOMUsageInterval::CCOMUsageInterval()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[UsageInterval]") ;
}

CCOMUsageInterval::~CCOMUsageInterval()
{
}

STDMETHODIMP CCOMUsageInterval::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMUsageInterval,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CCOMUsageInterval::Init(BSTR apStartDate, BSTR apEndDate)
{
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  
  // initialize the usage interval ...
  bRetCode = mUsageInterval.Init(apStartDate, apEndDate) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mUsageInterval.GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger.LogVarArgs (LOG_ERROR,
      "Unable to initialize usage interval. Error = 0x%x", nRetVal) ;
    return Error ("Unable to initialize usage interval.", 
      IID_ICOMUsageInterval, nRetVal) ;
  }

  return nRetVal;
}

STDMETHODIMP CCOMUsageInterval::get_Exists(VARIANT * pVal)
{
	HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  BOOL bExists=FALSE ;
  _variant_t vtValue ;
  
  // check to see if there is a usage interval exists ...
  bRetCode = mUsageInterval.Exists(bExists) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mUsageInterval.GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger.LogVarArgs (LOG_ERROR,
      "Unable to check for existence of usage interval. Error = 0x%x", nRetVal) ;
    return Error ("Unable to check for existence of usage interval.", 
      IID_ICOMUsageInterval, nRetVal) ;
  }
  // set te return val ...
  if (bExists == TRUE)
  {
    vtValue = (VARIANT_BOOL) VARIANT_TRUE ;
    *pVal = vtValue.Detach() ;
  }
  else
  {
    vtValue = (VARIANT_BOOL) VARIANT_FALSE ;
    *pVal = vtValue.Detach() ;
  }

  return nRetVal;
}


STDMETHODIMP CCOMUsageInterval::Create()
{
	HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // call the usage interval create ... 
  bRetCode = mUsageInterval.Create() ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mUsageInterval.GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger.LogVarArgs (LOG_ERROR,
      "Unable to create usage interval. Error = 0x%x", nRetVal) ;
    return Error ("Unable to create usage interval.", 
      IID_ICOMUsageInterval, nRetVal) ;
  }

  return nRetVal;
}

STDMETHODIMP CCOMUsageInterval::AddAccount(long aAccountID)
{
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  
  // call the usage interval AddAccount ... 
  bRetCode = mUsageInterval.AddAccount(aAccountID) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mUsageInterval.GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger.LogVarArgs (LOG_ERROR,
      "Unable to add account to usage interval. Error = 0x%x", nRetVal) ;
    return Error ("Unable to add account to usage interval.", 
      IID_ICOMUsageInterval, nRetVal) ;
  }
  
  return nRetVal;
}


STDMETHODIMP CCOMUsageInterval::get_AccountExists(long aAccountID, VARIANT * pVal)
{
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  BOOL bExists=FALSE ;
  _variant_t vtValue ;
  
  // check to see if there is a usage interval exists ...
  bRetCode = mUsageInterval.AccountExists(aAccountID, bExists) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mUsageInterval.GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger.LogVarArgs (LOG_ERROR,
      "Unable to check for existence of account in usage interval. Error = 0x%x", nRetVal) ;
    return Error ("Unable to check for existence of account in usage interval.", 
      IID_ICOMUsageInterval, nRetVal) ;
  }
  // set te return val ...
  if (bExists == TRUE)
  {
    vtValue = (VARIANT_BOOL) VARIANT_TRUE ;
    *pVal = vtValue.Detach() ;
  }
  else
  {
    vtValue = (VARIANT_BOOL) VARIANT_FALSE ;
    *pVal = vtValue.Detach() ;
  }

  return nRetVal;

}
