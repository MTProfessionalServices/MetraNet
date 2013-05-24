// MTEnumTypeInfo.cpp : Implementation of CMTEnumTypeInfo
#include "StdAfx.h"
#include "ReportingInfo.h"
#include "MTEnumTypeInfo.h"
#include <mtprogids.h>
#include <loggerconfig.h>
#include "ReportingDefs.h"
#include <mtparamnames.h>
#include <DataAccessDefs.h>

// import the rowset tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
using namespace ROWSETLib  ;

// import the config loader ...
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

/////////////////////////////////////////////////////////////////////////////
// CMTEnumTypeInfo
CMTEnumTypeInfo::CMTEnumTypeInfo()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("Database"), DBSVCS_TAG) ;
}

CMTEnumTypeInfo::~CMTEnumTypeInfo()
{
}

STDMETHODIMP CMTEnumTypeInfo::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTEnumTypeInfo
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTEnumTypeInfo::Add()
{
  //_bstr_t bstrName, bstrShortName;
  _bstr_t bstrProp ;
  long nValue, nDescID;
  _variant_t vtParam ;

  try
  {
    Remove() ;
  }
  catch(...)
  {
  }

	// start the try ...
  try
  {
    // create the rowset ...
    IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);

    // initialize the rowset ...
    _bstr_t configPath =  REPORTING_CONFIGDIR ;
    rowset->Init(configPath) ;

    // set the query tag ...
    _bstr_t queryTag = "__INSERT_ENUM_TYPE_INFO__" ;

    // initialize the _com_ptr_t ...
    CONFIGLOADERLib::IMTConfigLoaderPtr configLoader(MTPROGID_CONFIGLOADER);

    // initialize the configLoader ...
    configLoader->Init();

    CONFIGLOADERLib::IMTConfigPropSetPtr confSet = 
      configLoader->GetEffectiveFile(ENUMTYPE_CONFIGDIR, ENUMTYPE_FILE);

    // get the config data ...
    CONFIGLOADERLib::IMTConfigPropSetPtr subset;

    // read in the xml config file ...
    while ((subset = confSet->NextSetWithName("enumeration")) != NULL)
    {
      // read in the current view's data ...
      //bstrName = subset->NextStringWithName("service");
      bstrProp = subset->NextStringWithName("property_name");
      nValue  = subset->NextLongWithName("numeric_value");
      //bstrShortName = subset->NextStringWithName("short_name");
      nDescID = subset->NextLongWithName("description_id");

      // if the numeric value is -99 then its not really an enumerated type ...
      if (nValue == -99)
      {
        continue ;
      }

      try
      {
        // clear the rowset ...
        rowset->Clear() ;
        
        // set the query tag ...
        rowset->SetQueryTag (queryTag) ;
        
        // add the parameters ...
        vtParam = (long) nDescID ;
        rowset->AddParam (MTPARAM_DESCID, vtParam) ;
        vtParam = (long) nValue ;
        rowset->AddParam (MTPARAM_ENUM_CODE, vtParam) ;
        vtParam = bstrProp ;
        rowset->AddParam (MTPARAM_PROPERTY_NAME, vtParam) ;
        
        // execute the query ...
        rowset->Execute() ;
      }
      catch (_com_error e)
      {
        mLogger.LogVarArgs (LOG_ERROR,
          "Unable to insert enum type info to database. Error = <%x>", e.Error());
        mLogger.LogVarArgs (LOG_ERROR, 
            "Add() failed. Error Description = %s", (char*)e.Description()) ;
        return Error ("Unable to insert enum type info to database.",
          IID_IMTEnumTypeInfo, e.Error());
      }
    }
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR,
      "Unable to add enumeration information to database. Error = <%x>", e.Error());
    mLogger.LogVarArgs (LOG_ERROR, 
      "Add() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to add enumeration information to database.",
      IID_IMTEnumTypeInfo, e.Error());
  }
  
  return S_OK;
}

STDMETHODIMP CMTEnumTypeInfo::Remove()
{
	// start the try ...
  try
  {
    // create the rowset ...
    IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);

    // initialize the rowset ...
    _bstr_t configPath =  REPORTING_CONFIGDIR ;
    rowset->Init(configPath) ;

    // set the query tag ...
    _bstr_t queryTag = "__REMOVE_ENUM_TYPE_INFO__" ;
    rowset->SetQueryTag (queryTag) ;

    // execute the query ...
    rowset->Execute() ;
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to remove enum type information from database. Error = %x.", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Remove failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to remove enum type information from database", 
      IID_IMTEnumTypeInfo, e.Error()) ;
  }

	return S_OK;
}

STDMETHODIMP CMTEnumTypeInfo::Create()
{
  try
  {
    Drop() ;
  }
  catch(...)
  {
  }
	// start the try ...
  try
  {
    // create the rowset ...
    IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);

    // initialize the rowset ...
    _bstr_t configPath =  REPORTING_CONFIGDIR ;
    rowset->Init(configPath) ;

    // set the query tag ...
    _bstr_t queryTag = "__CREATE_ENUM_TYPE_TABLE__" ;
    rowset->SetQueryTag (queryTag) ;

    // execute the query ...
    rowset->Execute() ;
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to create enum type information table in database. Error = %x.", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to create query. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to create enum type information table in database", 
      IID_IMTEnumTypeInfo, e.Error()) ;
  }

	return S_OK;
}

STDMETHODIMP CMTEnumTypeInfo::Drop()
{
  IMTSQLRowsetPtr rowset;

  // start the try
  try
  {
    // initialize the rowset ...    
    HRESULT nRetVal = rowset.CreateInstance(MTPROGID_SQLROWSET);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to drop the reporting views. Rowset Create() failed.Error = %x", nRetVal) ;
      return Error ("Unable to drop the reporting views. Rowset Create() failed.", 
        IID_IMTEnumTypeInfo, E_FAIL) ;
    }
    _bstr_t configPath =  REPORTING_CONFIGDIR ;
    rowset->Init(configPath) ;
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to drop the enum type info. Rowset Init() failed.Error = %x", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Remove() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to drop the enum type info. Rowset Init() failed.", 
      IID_IMTEnumTypeInfo, E_FAIL) ;
  }
  
  // get the dbtype ...
  wstring wstrDBType = rowset->GetDBType() ;
  
    // if the dbtype is Oracle do not delete the views ...
  if (wcscmp(wstrDBType.c_str(), ORACLE_DATABASE_TYPE) == 0)
  {
    try
    {
      // set the query tag
      _bstr_t queryTag = "__FIND_TABLE__" ;
      rowset->SetQueryTag (queryTag) ;

      // add the parameter
      _variant_t vtParam ;
      vtParam = L"T_ENUM_TYPE_INFO" ;
      rowset->AddParam (MTPARAM_TABLENAME, vtParam) ;

      // execute the query ...
      rowset->Execute() ;

      _variant_t vtEOF = rowset->GetRowsetEOF() ;
      if (vtEOF.boolVal == VARIANT_FALSE)
      {
        // get the table name ...
        _variant_t vtValue = rowset->GetValue (((_variant_t) L"TableName")) ;
        
        // if the value != param then continue
        if (vtValue != vtParam)
        {
          return S_OK ;
        }
      }
      else
      {
        return S_OK ;
      }
    }
    catch (_com_error e)
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to find the enum type info.Error = %x", e.Error()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        "Remove() failed. Error Description = %s", (char*)e.Description()) ;
      return Error ("Unable to find the enum type info. Rowset Init() failed.", 
        IID_IMTEnumTypeInfo, E_FAIL) ;
    }
  }


	// start the try ...
  try
  {
    // set the query tag ...
    _bstr_t queryTag = "__DROP_ENUM_TYPE_TABLE__" ;
    rowset->SetQueryTag (queryTag) ;

    // execute the query ...
    rowset->Execute() ;
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to drop enum type information table in database. Error = %x.", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to create query. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to drop enum type information table in database", 
      IID_IMTEnumTypeInfo, e.Error()) ;
  }

	return S_OK;
}
