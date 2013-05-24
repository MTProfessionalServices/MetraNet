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
* $Header: c:\mainline\development\Core\DataAccess\QueryAdapter\MTQueryAdapter.cpp, 44, 11/11/2002 11:10:00 AM, Derek Young$
* 
***************************************************************************/
// MTQueryAdapter.cpp : Implementation of CMTQueryAdapter
#include "StdAfx.h"
#include "QueryAdapter.h"
#include "MTQueryAdapter.h"
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <MTDec.h>
#include <DBMiscUtils.h>
#include <DataAccessDefs.h>
#include <DBSQLRowset.h>
#include <mttime.h>
#include <formatdbvalue.h>
#include <mtcomerr.h>
#include <stdutils.h>
#include <mtprogids.h>
#include <metra.h>

// import the config loader ...
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

#import <MTServerAccess.tlb>


/////////////////////////////////////////////////////////////////////////////
// CMTQueryAdapter
CMTQueryAdapter::CMTQueryAdapter() 
: mpQueryCache(NULL)
{
}

CMTQueryAdapter::~CMTQueryAdapter() 
{
	/*
  // release the query cache ...
  if (mpQueryCache != NULL)
  {
		mpQueryCache->Release();
    mpQueryCache = NULL ;
  }
	*/
	
}

STDMETHODIMP CMTQueryAdapter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTQueryAdapter,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:          Init
// Arguments:     apConfigPath - The configuration path for the query file.
// Return Value:      
// Errors Raised: ??? - Unable to initialize query adapter. Cannot create query cache.
//                ??? - Unable to initialize query adapter
// Description:   The Init method initializes the query adapter by creating an
//  instance of the query cache COM singleton. If the query cache already exist 
//  within this process a pointer to the COM object is returned. Otherwise, a new
//  instance of the query cache is created. The query cache is then initialized with 
//  the relative configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::Init(BSTR apConfigPath)
{

  // if we havent initialized the query cache ...
  if (mpQueryCache == NULL)
  {
    try
    {
      QUERYADAPTERLib::IMTQueryCachePtr pQueryCache ;
      
      // get an instance of the query cache ... 
      HRESULT nRetVal = pQueryCache.CreateInstance("MTQueryCache.MTQueryCache.1") ;
      if (!SUCCEEDED(nRetVal))
      {
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "MTQueryAdapter::Init");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        return Error ("Unable to initialize query adapter. Cannot create query cache.", 
          IID_IMTQueryAdapter, nRetVal) ;
      }
      else
      {
        mpQueryCache = pQueryCache;
      }
    }
    catch (_com_error e)
    {
      SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "MTQueryAdapter::Init");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Error Description = %s", 
        (char*)e.Description()) ;
      return Error ("Unable to initialize query adapter. Cannot create query cache.") ;
    }
  }
  
  try
  {
	  
      HRESULT hr(S_OK);
      MetraTech_DataAccess_QueryManagement::IQueryMapperPtr qm;
      hr = qm.CreateInstance(__uuidof(MetraTech_DataAccess_QueryManagement::QueryMapper));
      if (FAILED(hr)) 
      {
         mLogger->LogVarArgs(LOG_ERROR, "Couldn't instantiate Query Management support. COM Error HResult=%d", hr);
         return hr;
      }

      if(!qm->Enabled)
      {
          if(NULL == apConfigPath || 0 >= wcslen((wchar_t*)apConfigPath))
		  { 
              _bstr_t errorBuffer; 
              errorBuffer = L"Unable to initialize query adapter. ConfigPath is empty or null"; 
              mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Error Description = %ls", errorBuffer) ;
              return Error ((const wchar_t *) errorBuffer, IID_IMTQueryAdapter, DB_ERR_INVALID_PARAMETER); 
		  } 
      }

      // initialize the query cache ...
      mpQueryCache->Init(apConfigPath) ;

      // copy the config path ...
      mConfigPath = apConfigPath ;

      // set up the mDBTypeIsOracle flag
      BSTR DBType ;

      mpQueryCache->raw_GetDBType (mConfigPath, &DBType) ;
      _bstr_t DBTypeBstr(DBType, false) ;

      if (DBTypeBstr == _bstr_t(ORACLE_DATABASE_TYPE))
      {
          mDBTypeIsOracle = TRUE ;
          mDBTypeIsSqlServer = FALSE;
          DBSQLRowset::SetDBTypeIsOracleFlag(mDBTypeIsOracle) ;
      }
      else
      {
          mDBTypeIsOracle = FALSE ;
          mDBTypeIsSqlServer = TRUE;
          DBSQLRowset::SetDBTypeIsOracleFlag(mDBTypeIsOracle) ;
      }


      //
      // caches the name of NetMeter and NetMeterStage databases
      // for future use by %%%NETMETER%%% and %%%NETMETERSTAGE%%% system parameters
      //
      MTSERVERACCESSLib::IMTServerAccessDataSetPtr servers(MTPROGID_SERVERACCESS);
      MTSERVERACCESSLib::IMTServerAccessDataPtr serverData;
      servers->Initialize();

      serverData = servers->FindAndReturnObject("NetMeter");
      mNetMeterDBName = serverData->GetDatabaseName();

      serverData = servers->FindAndReturnObject("NetMeterStage");
      mNetMeterStageDBName = serverData->GetDatabaseName();

  }
  catch (_com_error e)
  {
      SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "MTQueryAdapter::Init");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Error Description = %s", 
          (char*)e.Description()) ;
      return Error ("Unable to initialize query adapter.") ;
  }

  return S_OK;
}

// ----------------------------------------------------------------
// Name:     	    SetQueryTag
// Arguments:     apQueryTag - The query tag for the SQL query to create
// Return Value:  
// Errors Raised: 
// Description:   The SetQueryTag method calls the GetQueryString method
//  of the MTQueryCache COM object. If the call to GetQueryString fails,
//  an error is raised.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::SetQueryTag(BSTR apQueryTag)
{
	try
	{
		HRESULT nRetVal=S_OK ;
		// get the query from the query cache ...
		if (mpQueryCache != NULL)
		{
			if (mQueryLog->IsOkToLog(LOG_TRACE))
				mQueryLog->LogVarArgs(LOG_TRACE, "query tag: %s\n", (const char *) _bstr_t(apQueryTag));

			mQueryTag = apQueryTag ;
			_bstr_t tempStr = mpQueryCache->GetQueryString(mConfigPath, apQueryTag) ;
			mQueryStr = tempStr ;
		}
		return nRetVal;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Name:     	    GetQueryTag
// Arguments:     
// Return Value:  the query tag currently associated with the adapter
// Errors Raised: 
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetQueryTag(BSTR * apQueryTag)
{
	try
	{
		*apQueryTag = mQueryTag.copy();
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Name:     	    ClearQuery
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   The ClearQuery method clears the currently set query tag.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::ClearQuery()
{
  // clear the query tag and the query string ...
	mQueryTag = "" ;
  mQueryStr.resize(0) ;

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	    AddParam
// Arguments:     apParamTag - The name of the parameter
//                aParam     - The value of the parameter 
// Return Value:  
// Errors Raised: 0xE1500003L - Unable to get query. Invalid parameter
//                0xE1500007L - Invalid type for query parameter.
//                0xE1500005L - Unable to get query. Unable to find query parameter.
// Description:   The AddParam method adds the specified parameter to the
//  query string. All instances of the parameter tag will be replaced by the
//  parameter value that is passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::AddParam(BSTR apParamTag, VARIANT aParam, 
                                       VARIANT aDontValidateString)
{
	try
	{
		if (AddParamInternal(apParamTag, aParam, aDontValidateString) == FALSE)
		{
			wstring wstrParamTag = apParamTag ;
			// otherwise the tag should be found
			SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "MTQueryAdapter::AddParam") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			mLogger->LogVarArgs (LOG_ERROR, "Unable to find query parameter %s for query tag %s. Config Path = %s", 
													 ascii(wstrParamTag).c_str(), (char*) mQueryTag, (char*) mConfigPath) ;
			return Error ("Unable to get query. Unable to find query parameter.", IID_IMTQueryAdapter, DB_ERR_ITEM_NOT_FOUND) ;
		}
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}
// ----------------------------------------------------------------
// Name:     	    AddParamIfFound
// Arguments:     apParamTag - The name of the parameter
//                aParam     - The value of the parameter 
// Return Value:  
// Errors Raised: 0xE1500003L - Unable to get query. Invalid parameter
//                0xE1500007L - Invalid type for query parameter.

// Description:   The AddParamIfFound method adds the specified parameter to the
//  query string. All instances of the parameter tag will be replaced by the
//  parameter value that is passed. If a parameter was not found, return VARIANT_FALSE
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::AddParamIfFound(BSTR apParamTag, VARIANT aParam, 
                                       VARIANT aDontValidateString, VARIANT_BOOL* apParamFound)
{
	try
	{
		(*apParamFound) = AddParamInternal(apParamTag, aParam, aDontValidateString) == TRUE ? VARIANT_TRUE : VARIANT_FALSE;
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Name:     	    AddParam
// Arguments:     apParamTag - The name of the parameter
//                aParam     - The value of the parameter 
// Return Value:  
// Errors Raised: 0xE1500003L - Unable to get query. Invalid parameter
//                0xE1500007L - Invalid type for query parameter.
//                0xE1500005L - Unable to get query. Unable to find query parameter.
// Description:   The AddParam method adds the specified parameter to the
//  query string. All instances of the parameter tag will be replaced by the
//  parameter value that is passed.
// ----------------------------------------------------------------
bool CMTQueryAdapter::AddParamInternal(BSTR apParamTag, VARIANT aParam, 
																			 VARIANT aDontValidateString)
{
	wchar_t wstrParam[256] ;
	bool bFound=FALSE ;
	_variant_t vtValue ;
	wstring wstrParamTag = apParamTag ;
	_bstr_t newValue ;
	int nNum ;
	wchar_t *pString =NULL ;

	// validate the paramTag ... if it doesnt contain %% ... it's in 
	// the incorrect format ...
	if (wstrParamTag.find(L"%%") == wstring::npos)
	{
		SetError (DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, "MTQueryAdapter::AddParam") ;
		mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
		mLogger->LogVarArgs (LOG_ERROR, "Invalid paramter tag %s for for query tag %s. Config Path = %s", 
			ascii(wstrParamTag).c_str(), (const char *) mQueryTag, (const char *) mConfigPath);
		MT_THROW_COM_ERROR (IID_IMTQueryAdapter, DB_ERR_INVALID_PARAMETER) ;
	}
	// find the parameter tag in the query string ...
	while ((nNum = mQueryStr.find(wstrParamTag)) != wstring::npos)
	{
		// copy the variant out of the parameter ... if it's not 
		// VT_BYREF | VT_VARIANT then just copy it otherwise get the 
		// variant out of the variant (it comes this way from VB) ...
		if (aParam.vt != (VT_BYREF | VT_VARIANT))
		{
			vtValue = aParam ;
		}
		else
		{
			vtValue = aParam.pvarVal  ;
		}

		// if we haven't already created the string for the parameter
		if (bFound == FALSE)
		{
			// switch on the parameter type ...
			switch (vtValue.vt)
			{
			case VT_I2:
				// convert the value and replace it in the query ...
				swprintf_s (wstrParam, 256, L"%d", vtValue.iVal) ;
				pString = wstrParam ;
				break ;
			
			case VT_INT:
			case VT_I4:
				// convert the value and replace it in the query ...
				swprintf_s (wstrParam, 256, L"%d", vtValue.lVal) ;
				pString = wstrParam ;
				break ;

			case VT_I8:
				// convert the value and replace it in the query ...
				swprintf_s (wstrParam, 256, L"%I64d", vtValue.llVal) ;
				pString = wstrParam ;
				break ;

			case VT_R4:
				{
					// wsprintf does not support the printing of float characters so we use sprintf 
					// then copy it to a multibyte character ...
					char strParam[256] ;
					sprintf_s (strParam, 256, "%f", vtValue.fltVal) ;

					// copy to multibyte string ...
					int nLen = strlen(strParam) ;
					mbstowcs (wstrParam, strParam, nLen);	
					wstrParam[nLen] = L'\0';
					pString = wstrParam ;
				}
				break ;

			case VT_R8:
				{
					// wsprintf does not support the printing of float characters so we use sprintf 
					// then copy it to a multibyte character ...
					char strParam[256] ;
					sprintf_s (strParam, 256, "%.14E", vtValue.dblVal) ;

					// copy to multibyte string ...
					int nLen = strlen(strParam) ;
					mbstowcs (wstrParam, strParam, nLen);					
					wstrParam[nLen] = L'\0';
					pString = wstrParam ;
				}
				break ;

			case VT_DECIMAL:
				{
					MTDecimal dec(vtValue.decVal);
					string buffer = dec.Format();
					wstring wideBuffer;
					ASCIIToWide(wideBuffer, buffer);
					ASSERT(sizeof(wstrParam) > wideBuffer.length());
					wcscpy(wstrParam, wideBuffer.c_str());
					pString = wstrParam;
				}
				break ;

			case (VT_I2 | VT_BYREF):
				// convert the value and replace it in the query ...
				swprintf_s (wstrParam, 256, L"%d", *(vtValue.piVal)) ;
				pString = wstrParam ;
				break ;

			case (VT_INT | VT_BYREF):
			case (VT_I4 | VT_BYREF):
				// convert the value and replace it in the query ...
				swprintf_s (wstrParam, 256, L"%d", *(vtValue.plVal)) ;
				pString = wstrParam ;
				break ;

			case (VT_I8 | VT_BYREF):
				// convert the value and replace it in the query ...
				swprintf_s (wstrParam, 256, L"%I64d", *(vtValue.pllVal)) ;
				pString = wstrParam ;
				break ;

			case (VT_R4 | VT_BYREF):
				// convert the value and replace it in the query ...
				swprintf_s (wstrParam, 256, L"%f", *(vtValue.pfltVal)) ;
				pString = wstrParam ;
				break ;

			case (VT_R8 | VT_BYREF):
				// convert the value and replace it in the query ...
				swprintf_s (wstrParam, 256, L"%.14E", *(vtValue.pdblVal)) ;
				pString = wstrParam ;
				break ;

			case (VT_DECIMAL | VT_BYREF):
				{
					MTDecimal dec(*vtValue.pdecVal);
					string buffer = dec.Format();
					wstring wideBuffer;
					ASCIIToWide(wideBuffer, buffer);
					ASSERT(sizeof(wstrParam) > wideBuffer.length());
					wcscpy(wstrParam, wideBuffer.c_str());
					pString = wstrParam;
				}
				break ;

			case VT_BSTR:
				{
					if (mDBTypeIsOracle == TRUE && vtValue == _variant_t(""))
						newValue = MTEmptyString;
					else
					{
						if ((aDontValidateString.vt == VT_ERROR) || 
							((aDontValidateString.vt == VT_BOOL) && (aDontValidateString.boolVal == VARIANT_FALSE)) ||
							((aDontValidateString.vt == VT_I2) && (aDontValidateString.boolVal == VARIANT_FALSE)))
						{
							wstring wstrVal = ValidateString (vtValue.bstrVal) ;
							newValue = wstrVal.c_str() ;
						}
						else
							newValue = vtValue.bstrVal;
					}
					pString = (wchar_t*) newValue ;
					if(wcsstr(pString, (wchar_t*)wstrParamTag.c_str()))
					{
						SetError (DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, "MTQueryAdapter::AddParamInternal") ;
						mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
						mLogger->LogVarArgs (LOG_ERROR, "Invalid value [%s] on parameter [%s] for for query tag %s. Config Path = %s", 
						(char *) newValue, ascii(wstrParamTag).c_str(), (const char *) mQueryTag, (const char *) mConfigPath);
						MT_THROW_COM_ERROR (IID_IMTQueryAdapter, DB_ERR_INVALID_PARAMETER) ;
					}
				}
				break ;
			case VT_NULL:
				{
					pString = L"NULL";
					break;
				}
			case VT_DATE:
				{
					// convert the value to ODBC escape sequence and replace it in the query ...
					std::wstring buffer;
					BOOL bSuccess = FormatValueForDB(_variant_t(vtValue), FALSE, buffer);
					if (bSuccess == FALSE)
					{
						SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
							"MTQueryAdapter::AddParam");
						mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
						mLogger->LogVarArgs (LOG_ERROR, 
							"Invalid date for query parameter %s for query tag %s. Type = %x. Config Path = %s", 
							ascii(wstrParamTag).c_str(), (char*) mQueryTag, (long) vtValue.vt, (char*) mConfigPath) ;
						MT_THROW_COM_ERROR (IID_IMTQueryAdapter, DB_ERR_INCORRECT_TYPE) ;
					}
					// We have a string now, but don't validate it since it shouldn't have quotes escaped.
					newValue = _bstr_t(buffer.c_str());
					pString = (wchar_t *) newValue;
				}
				break;
			default:
				SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
					"MTQueryAdapter::AddParam");
				mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
				mLogger->LogVarArgs (LOG_ERROR, 
					"Invalid type for query parameter %s for query tag %s. Type = %x. Config Path = %s", 
					ascii(wstrParamTag).c_str(), (char*) mQueryTag, (long) vtValue.vt, (char*) mConfigPath) ;
				MT_THROW_COM_ERROR (IID_IMTQueryAdapter, DB_ERR_INCORRECT_TYPE) ;
				break ;
			}
			// set found to true ...
			bFound = TRUE ;
		}
		// replace the parameter tag with the generated parameter string ...
		mQueryStr.replace(nNum, wstrParamTag.size(), pString);

	}
	return bFound;

}

// ----------------------------------------------------------------
// Name:     	    GetQuery
// Arguments:     apQuery - The query string
// Return Value:  The query string
// Errors Raised: 0xE150000CL - Unable to get query. Parameter not specified.
//                0xE1500005L - Unable to get query. No query specified.
// Description:   The GetQuery method gets the completed query string. If not
//  all the parameters have been specified, an error is raised.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetQuery(BSTR * apQuery)
{
	try
	{

		int nNum ;
  
		// if we have a query string ...
		if (mQueryStr.length() == 0)
		{
			SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "MTQueryAdapter::GetQuery") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			mLogger->LogVarArgs (LOG_ERROR, "No query specified. ConfigPath = %s",
													 (char*)mConfigPath) ;
			return Error ("Unable to get query. No query specified.", IID_IMTQueryAdapter, DB_ERR_ITEM_NOT_FOUND) ;
		}

		HRESULT hr = ApplySystemParameters();
		if (FAILED(hr))
			return hr;


		if ((nNum = mQueryStr.find(L"%%")) != wstring::npos)
		{
			SetError (DB_ERR_PARAMETER_NOT_SPECIFIED, ERROR_MODULE, ERROR_LINE, 
								"MTQueryAdapter::GetQuery") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			mLogger->LogVarArgs (LOG_ERROR, "Parameter not specified for query tag = %s. ConfigPath = %s",
													 (char*)mQueryTag, (char*)mConfigPath) ;
			mLogger->LogVarArgs (LOG_ERROR, "Query string = %s", ascii(mQueryStr).c_str()) ;
			return Error ("Unable to get query. Parameter not specified.", IID_IMTQueryAdapter, 
										DB_ERR_PARAMETER_NOT_SPECIFIED) ;
		}

		// all query parameters have been filled in


		// copy the query string to a _bstr_t so we can return it ...
		_bstr_t newValue = mQueryStr.c_str() ;

		// Oracle only supports UTF8 character set. we have to do a little conversion here
		// Oracle does support UTF-16 (ver 9i and later?), so this conversion is not necessary.
		/********************
		if (mDBTypeIsOracle)
		{

			//Get the size of the resulting multibyte string
			long len = WideCharToMultiByte(CP_UTF8, 
																		 0, 
																		 mQueryStr.c_str(), 
																		 -1, 
																		 NULL, 0, NULL, NULL);

			if (len == 0)
				return S_FALSE;
				
			char * out = new char[len + 1];
	  
			len = WideCharToMultiByte(CP_UTF8, 
																0, 
																mQueryStr.c_str(), 
																-1, 
																out, len, NULL, NULL);

			if (len == 0)
			{
				delete [] out;
				return S_FALSE;
			}

			out[len] = NULL;
				
			newValue = out ;

			delete [] out;
		}
		********************/

		*apQuery = newValue.copy();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
  
  return S_OK;
}

HRESULT CMTQueryAdapter::ApplySystemParameters()
{
	// applies system paramters only if at least one param tag is still left
	if (mQueryStr.find(L"%%") == wstring::npos)
		return S_OK;

	// fills in the current MetraTime value
	if (mQueryStr.find(L"%%%SYSTEMDATE%%%") != wstring::npos)
	{
		_variant_t currentTime = GetMTTimeForDB();
		
		_variant_t varTrue(true);
		HRESULT hr = AddParam(L"%%%SYSTEMDATE%%%", currentTime, varTrue);
		if (FAILED(hr))
			return hr;
	}

	// fills in the temp table prefix if there is one
	//   SQLServer :  #
	//   Oracle    :  none
	if (mQueryStr.find(L"%%%TEMP_TABLE_PREFIX%%%") != wstring::npos)
	{
		_variant_t varTrue(true);
		_bstr_t prefix;
		if (mDBTypeIsOracle)
			prefix = "";
		else
			prefix = "#";
		
		HRESULT hr = AddParam(L"%%%TEMP_TABLE_PREFIX%%%", _variant_t(prefix), varTrue);
		if (FAILED(hr))
			return hr;
	}
	
	// fills in the actual name of the NetMeter database
	if (mQueryStr.find(L"%%%NETMETER%%%") != wstring::npos)
	{
		HRESULT hr = AddParam(L"%%%NETMETER%%%", _variant_t(mNetMeterDBName), _variant_t(true));
		if (FAILED(hr))
			return hr;
	}
	
	// fills in the actual name of the NetMeterStage database
	if (mQueryStr.find(L"%%%NETMETERSTAGE%%%") != wstring::npos)
	{
		HRESULT hr = AddParam(L"%%%NETMETERSTAGE%%%", _variant_t(mNetMeterStageDBName), _variant_t(true));
		if (FAILED(hr))
			return hr;
	}

 	// fills in WITH(READCOMMITTED) hint in case of SQLSERVER
	if (mQueryStr.find(L"%%%READCOMMITTED%%%") != wstring::npos)
	{
    _variant_t readcomm = mDBTypeIsOracle ? "" : "WITH(READCOMMITTED)";
		HRESULT hr = AddParam(L"%%%READCOMMITTED%%%", readcomm, _variant_t(true));
		if (FAILED(hr))
			return hr;
	}

	// string concatenation ops
	if (mQueryStr.find(L"%%%CONCAT%%%") != wstring::npos)
	{
    _variant_t concat = mDBTypeIsOracle ? "||" : "+";
		HRESULT hr = AddParam(L"%%%CONCAT%%%", concat, _variant_t(true));
		if (FAILED(hr))
			return hr;
	}

 	// upper func for case-insensitve compares in oracle and nop in sqlserver
	if (mQueryStr.find(L"%%%UPPER%%%") != wstring::npos)
	{
    _variant_t val = mDBTypeIsOracle ? "upper" : "";
		HRESULT hr = AddParam(L"%%%UPPER%%%", val, _variant_t(true));
		if (FAILED(hr))
			return hr;
	}

	// dual dummy table for oracle, nop on SQL server
	if (mQueryStr.find(L"%%%FROMDUAL%%%") != wstring::npos)
	{
    _variant_t dual = mDBTypeIsOracle ? "FROM DUAL" : "";
		HRESULT hr = AddParam(L"%%%FROMDUAL%%%", dual, _variant_t(true));
		if (FAILED(hr))
			return hr;
	}

	// Left-side of cast operator for table-valued functions in Oracle
  // Sql Server form: select * from func()
  // Oracle form:     select * from table(func())
	if (mQueryStr.find(L"%%%TABLE_L%%%") != wstring::npos)
	{
    _variant_t str = mDBTypeIsOracle ? "table(" : "";
		HRESULT hr = AddParam(L"%%%TABLE_L%%%", str, _variant_t(true));
		if (FAILED(hr))
			return hr;
	}

  // Right-side of cast operator for table-valued functions in Oracle
	if (mQueryStr.find(L"%%%TABLE_R%%%") != wstring::npos)
	{
    _variant_t str = mDBTypeIsOracle ? "table(" : "";
		HRESULT hr = AddParam(L"%%%TABLE_R%%%", str, _variant_t(true));
		if (FAILED(hr))
			return hr;
	}

	// Evaluates to the NetMeter database name and dots, e.g. "NetMeter.." 
	// for SqlServer and "NetMeter." when Oracle
	if (mQueryStr.find(L"%%%NETMETER_PREFIX%%%") != wstring::npos)
	{
		_variant_t prefix = mNetMeterDBName + (mDBTypeIsOracle ? "." : "..");
		
		HRESULT hr = AddParam(L"%%%NETMETER_PREFIX%%%", prefix, _variant_t(true));
		if (FAILED(hr))
			return hr;
	}

   // Evaluates to the staging database name and dots, e.g. "NetMeter.." 
	// for SqlServer and "NetMeter." when Oracle
	if (mQueryStr.find(L"%%%NETMETERSTAGE_PREFIX%%%") != wstring::npos)
	{
		_variant_t prefix = mNetMeterStageDBName + (mDBTypeIsOracle ? "." : "..");
		
		HRESULT hr = AddParam(L"%%%NETMETERSTAGE_PREFIX%%%", prefix, _variant_t(true));
		if (FAILED(hr))
			return hr;
	}

   return S_OK;
}

// ----------------------------------------------------------------
// Name:     	    GetUserName
// Arguments:     apUserName - The database user name from the dbaccess.xml file.
// Return Value:  The database user name
// Errors Raised: 
// Description:   The GetUserName method calls the GetUserName method of the 
//  MTQueryCache to the get the user name from the cache.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetUserName(BSTR * apUserName)
{
	return mpQueryCache->raw_GetUserName (mConfigPath,apUserName) ;
}

// ----------------------------------------------------------------
// Name:     	    GetPassword
// Arguments:     apPassword - The password from the dbaccess.xml file.
// Return Value:  The password
// Errors Raised: 
// Description:   The GetPassword method calls the GetPassword method of the 
//  MTQueryCache to the get the password from the cache.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetPassword(BSTR * apPassword)
{
	// get the password...
	return mpQueryCache->raw_GetPassword (mConfigPath,apPassword) ;
}

// ----------------------------------------------------------------
// Name:     	    GetDBName
// Arguments:     apDBName - The database name from the dbaccess.xml file.
// Return Value:  The database name
// Errors Raised: 
// Description:   The GetDBName method calls the GetDBName method of the 
//  MTQueryCache to the get the database name from the cache.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetDBName(BSTR * apDBName)
{
	// get the database name ...
	return mpQueryCache->raw_GetDBName (mConfigPath,apDBName);
}

// ----------------------------------------------------------------
// Name:     	    GetServerName
// Arguments:     apServerName - The server name from the dbaccess.xml file.
// Return Value:  The server name
// Errors Raised: 
// Description:   The GetServerName method calls the GetServerName method of the 
//  MTQueryCache to the get the server name from the cache.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetLogicalServerName(BSTR * apServerName)
{
	// get the server name ...
	return mpQueryCache->raw_GetLogicalServerName (mConfigPath,apServerName) ;
}

// ----------------------------------------------------------------
// Name:     	    GetServerName
// Arguments:     apServerName - The server name from the dbaccess.xml file.
// Return Value:  The server name
// Errors Raised: 
// Description:   The GetServerName method calls the GetServerName method of the 
//  MTQueryCache to the get the server name from the cache.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetServerName(BSTR * apServerName)
{
	// get the server name ...
	return mpQueryCache->raw_GetServerName (mConfigPath,apServerName) ;
}

// ----------------------------------------------------------------
// Name:     	    GetAccessType 
// Arguments:     apAccessType - The access type from the dbaccess.xml file.
// Return Value:  The access type
// Errors Raised: 
// Description:   The GetAccessType method calls the GetAccessType method of the 
//  MTQueryCache to the get the access type from the cache.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetAccessType(BSTR * apAccessType)
{
	// get the access type  ...
	return mpQueryCache->raw_GetAccessType (mConfigPath,apAccessType) ;
}

// ----------------------------------------------------------------
// Name:     	    GetDBType 
// Arguments:     apDBType - The database type from the dbaccess.xml file.
// Return Value:  The database type
// Errors Raised: 
// Description:   The GetDBType method calls the GetDBType method of the 
//  MTQueryCache to the get the database type from the cache.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetDBType(BSTR * apDBType)
{
	// get the database type ...
	return mpQueryCache->raw_GetDBType (mConfigPath,apDBType) ;
}

// ----------------------------------------------------------------
// Name:     	    GetProvider 
// Arguments:     apProvider - The provider from the dbaccess.xml file.
// Return Value:  The provider
// Errors Raised: 
// Description:   The GetProvider method calls the GetProvider method of the 
//  MTQueryCache to the get the provider from the cache.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetProvider(BSTR * apProvider)
{
	// get the provider ...
	return mpQueryCache->raw_GetProvider (mConfigPath,apProvider) ;
}

// ----------------------------------------------------------------
// Name:     	    GetTimeout
// Arguments:     apTimeout - The timeout value from the dbaccess.xml file.
// Return Value:  The timeour value
// Errors Raised: 
// Description:   The GetTimeout method calls the GetTimeout method of the 
//  MTQueryCache to the get the timeout value from the cache.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetTimeout(long * apTimeout)
{
	// get the timeout ...
  *apTimeout = mpQueryCache->GetTimeout (mConfigPath) ;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	    GetDataSource
// Arguments:     apDataSource - The data source from the dbaccess.xml file.
// Return Value:  The data source
// Errors Raised: 
// Description:   The GetDataSource method calls the GetDataSource method of the 
//  MTQueryCache to the get the data source from the cache.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryAdapter::GetDataSource(BSTR * apDataSource)
{
	// get the provider ...
	return mpQueryCache->raw_GetDataSource (mConfigPath,apDataSource) ;
}


STDMETHODIMP CMTQueryAdapter::SetRawSQLQuery(BSTR apQuery)
{
	ASSERT(apQuery);
	if(!apQuery) return E_POINTER;

	mQueryStr = _bstr_t(apQuery);
	return S_OK;

}

STDMETHODIMP CMTQueryAdapter::GetRawSQLQuery(VARIANT_BOOL FillInSystemDefaults, BSTR * apQuery)
{
	ASSERT(apQuery);
	if(!apQuery) return E_POINTER;

	// TODO: this should really share code with GetQuery.  I didn't want
	// to mess with GetQuery right now though.
	try
	{
		// if we have a query string ...
		if (mQueryStr.length() == 0)
		{
			SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "MTQueryAdapter::GetQuery") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			mLogger->LogVarArgs (LOG_ERROR, "No query specified. ConfigPath = %s",
													 (char*)mConfigPath) ;
			return Error ("Unable to get query. No query specified.", IID_IMTQueryAdapter, DB_ERR_ITEM_NOT_FOUND) ;
		}

		
		if (FillInSystemDefaults == VARIANT_TRUE)
		{
			HRESULT hr = ApplySystemParameters();
			if (FAILED(hr))
				return hr;
		}

		// copy the query string to a _bstr_t so we can return it ...
		_bstr_t newValue = mQueryStr.c_str() ;

		// Oracle only supports UTF8 character set. we have to do a little conversion here
		if (mDBTypeIsOracle)
		{

			//Get the size of the resulting multibyte string
			long len = WideCharToMultiByte(CP_UTF8, 
																		 0, 
																		 mQueryStr.c_str(), 
																		 -1, 
																		 NULL, 0, NULL, NULL);

			if (len == 0)
				return S_FALSE;
				
			char * out = new char[len + 1];
	  
			len = WideCharToMultiByte(CP_UTF8, 
																0, 
																mQueryStr.c_str(), 
																-1, 
																out, len, NULL, NULL);

			if (len == 0)
			{
				delete [] out;
				return S_FALSE;
			}

			out[len] = NULL;
				
			newValue = out ;

			delete [] out;
		}

		*apQuery = newValue.copy();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
  
  return S_OK;
}

STDMETHODIMP CMTQueryAdapter::GetDBDriver(BSTR * apDBDriver)
{
	return mpQueryCache->raw_GetDBDriver (mConfigPath,apDBDriver) ;
}

STDMETHODIMP CMTQueryAdapter::GetHinter(IDispatch** apHinter)
{
	try
	{
		*apHinter = NULL;

		// gets the hinter associated with the current query (if any)
		MetraTech_DataAccess_Hinter::IQueryHinterPtr hinter = mpQueryCache->GetHinter(mConfigPath, mQueryTag);
		if (hinter == NULL)
			return S_OK;
		
		// compiles the hinter if it isn't already compiled
		hinter->Compile(reinterpret_cast<QUERYADAPTERLib::IMTQueryAdapter*>(this));

		*apHinter = hinter.Detach();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMTQueryAdapter::IsOracle(VARIANT_BOOL * isOracle)
{
  // CR 15362 - Fixed return value
  *isOracle = mDBTypeIsOracle;
  return S_OK;
}

STDMETHODIMP CMTQueryAdapter::IsSqlServer(VARIANT_BOOL * isSqlServer)
{
  // CR 15362 - Fixed return value
  *isSqlServer = mDBTypeIsSqlServer;
  return S_OK;
}

STDMETHODIMP CMTQueryAdapter::GetSchemaDots(BSTR * apDots)
{
  *apDots = _bstr_t(mDBTypeIsOracle ? "." : "..");
  return S_OK;
}


