// MTReportingView.cpp : Implementation of CMTReportingView
#include "StdAfx.h"
#include <metra.h>
#include "ReportingInfo.h"
#include "MTReportingView.h"
#include <mtprogids.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <ProductViewCollection.h>
#include <DBConstants.h>
#include <mtparamnames.h>
#include <DataAccessDefs.h>
#include "ReportingDefs.h"
#import <RCD.tlb>
#include <SetIterate.h>
#include <RcdHelper.h>
#include <stdutils.h>
#include <MSIXDefinition.h>
#include <list>

 // import the rowset tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
using namespace ROWSETLib;

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

#import <MTConfigLib.tlb>

using namespace MTConfigLib;
using std::list;
 /////////////////////////////////////////////////////////////////////////////
// CMTReportingView
CMTReportingView::CMTReportingView()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("Database"), "MTReportingView") ;
}

CMTReportingView::~CMTReportingView()
{
  TearDown() ;
}

void CMTReportingView::TearDown() 
{
}

STDMETHODIMP CMTReportingView::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTReportingView
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTReportingView::Add()
{
	BOOL bRetCode=TRUE ;
  BOOL bFirstTime=TRUE ;
  _variant_t vtParam ;
  wstring wstrCmd,wstrQuery ;
  _variant_t vtEOF, vtValue, vtIndex ;
  wstring wstrTableSuffix ;
  CProductViewCollection PVColl ;
  CMSIXDefinition *pProductView ;
  CMSIXProperties *pPVProp ;
  wstring viewName ;
  _bstr_t queryTag ;

  // start the try ...
  try
  {
    Remove() ;
  }
  catch (_com_error e)
  {
  }


  // start the try
  try
  {
    // create the rowset ...
    IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
    // initialize the queryadapter ...
    _bstr_t configPath = REPORTING_CONFIGDIR ;
    queryAdapter->Init(configPath) ;
    
    // create the product view collection ...
    bRetCode = PVColl.Initialize() ;
    if (bRetCode == FALSE)
    {
      mLogger.LogThis (LOG_ERROR, 
        "Unable to initialize product view collection from configuration files.") ;
      return FALSE ;
    }

    // iterate thru the product view collection ...
  	MSIXDefCollection::MSIXDefinitionList & lst = PVColl.GetDefList(); 
	std::list<CMSIXDefinition *>::iterator it;
	

  	for (it = lst.begin(); it != lst.end(); it++ )
    {
      // get the product view ...
   		pProductView = *it;

      // iterate thru the product view properties and create the select clause ...
      bFirstTime = TRUE ;
      MSIXPropertiesList::iterator PVPropCollIter;
			for (PVPropCollIter = pProductView->GetMSIXPropertiesList().begin();
					 PVPropCollIter != pProductView->GetMSIXPropertiesList().begin();
					 ++PVPropCollIter)
			{
        // get the property ...
        pPVProp = *PVPropCollIter;

        // add the commas after the data already written ...
        if (bFirstTime == FALSE)
        {
          wstrCmd += L", pv." ;
        }
        // this is the first time through ... set the flag to false now ...
        else
        {
          bFirstTime = FALSE ;
          wstrCmd = L" pv." ;
        }

        // get the column name for the property ...
        wstrCmd += pPVProp->GetColumnName() ;
      }

      // iterate thru the table suffix list to create the query to create the view ...
      queryTag = "__CREATE_REPORTING_VIEW__" ;
      bFirstTime = TRUE ;
	 
	  std::list<std::wstring> tableSuffixColl;
	  std::list<std::wstring>::iterator iter;
      for (iter = tableSuffixColl.begin(); iter != tableSuffixColl.end(); iter++)
      {
        // set the query tag ...
        queryAdapter->SetQueryTag (queryTag) ;
        
        // add the parameters ...
        vtParam = pProductView->GetTableName().c_str() ;
        queryAdapter->AddParam (MTPARAM_TABLENAME, vtParam) ;
        vtParam = wstrCmd.c_str() ;
        queryAdapter->AddParam (MTPARAM_SELECTCLAUSE, vtParam) ;
        
        // get the query ...
        //wstrQuery += queryAdapter->GetQuery() ;

        // add the UNION after the data already written ...
        if (bFirstTime == FALSE)
        {
          wstrQuery += L" UNION " ;
        }
        // this is the first time through ... set the flag to false now ...
        else
        {
          bFirstTime = FALSE ;
          wstrQuery = L"" ;
        }
        // add the query to the current string ...
        wstrQuery += queryAdapter->GetQuery() ;
      }

      // create the view name from the product view name ...
      // table name is a string manipulation of the name
      // for example: if name is metratech.com/audioconfcall, the
      // table name gets translated to t_pv_metratech_com_audioconfcall
      viewName = pProductView->GetName() ;
      GetViewName(viewName) ;
      
      // initialize the rowset ...    
      IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
      configPath =  REPORTING_CONFIGDIR ;
      rowset->Init(configPath) ;
      
      // clear the rowset ...
      rowset->Clear() ;

      // set the query tag ...
      queryTag = "__CREATE_REPORTING_VIEW_UNION__" ;
      rowset->SetQueryTag (queryTag) ;
      
      // add the parameters ...
      vtParam = viewName.c_str() ;
      rowset->AddParam (MTPARAM_VIEWNAME, vtParam) ;
      vtParam = wstrQuery.c_str() ;
      rowset->AddParam (MTPARAM_SELECTCLAUSE, vtParam) ;
      
      // execute the query ...
      rowset->Execute() ;
    }
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to create the reporting views. Error = %x", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Add() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to create the reporting views.", 
          IID_IMTReportingView, E_FAIL) ;
  }

  // create the other views ...
  try
  {
    // create the rowset and configloader ...
    IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    VARIANT_BOOL flag;
    
		// create an instance of the RCD
		RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
		aRCD->Init();
		RCDLib::IMTRcdFileListPtr aFileList = 
      aRCD->RunQuery("config\\Queries\\dataAnalysisView\\DataAnalysisViewInstall.xml",VARIANT_TRUE);

		if(aFileList->GetCount() == 0) 
    {
      // log error that we can't find any configuration
      mLogger.LogVarArgs (LOG_ERROR, 
        "Add() failed. Unable to find the data analysis view install files.") ;
      return Error ("Unable to find the data analysis view install files.", 
        IID_IMTReportingView, E_FAIL) ;
		}

		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
		if(FAILED(it.Init(aFileList))) 
      return E_FAIL;

		while(TRUE) 
    {
      // get the next element in the list ...
			_variant_t aVariant= it.GetNext();
			_bstr_t afile = aVariant;
			if(afile.length() == 0) 
      {
				break;
			}

      // initialize the _com_ptr_t ...
      MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

      // read the configuration file ...
      MTConfigLib::IMTConfigPropSetPtr confSet = config->ReadConfiguration(afile, &flag);

      // initialize the rowset ...
      wstring wstrConfigPath(afile) ;

      // remove the DataAnalysisViewInstall.xml ...
	  string::size_type index = strfind(wstrConfigPath, L"DataAnalysisViewInstall.xml") ;
      if (index != string::npos)
      {
        // remove the DataAnalysisViewInstall.xml ...
        wstrConfigPath = wstrConfigPath.erase (index, wstrConfigPath.length() - index) ;
      }
      rowset->Init (wstrConfigPath.c_str()) ;
      
      MTConfigLib::IMTConfigPropSetPtr subSet = confSet->NextSetWithName ("create_view_tags") ;
      
      // read in the XML config file name
      MTConfigLib::IMTConfigPropPtr queryTag = subSet->NextWithName("query_tag");
      
      while (queryTag != NULL)
      {
        MTConfigLib::PropValType type;
        _variant_t propVal;
        
        // get the value
        propVal = queryTag->GetValue(&type);
        if (type != MTConfigLib::PROP_TYPE_STRING)
        {		  			  		
          mLogger.LogVarArgs (LOG_ERROR, 
            "Datatype mismatch while parsing DataAnalysis Install file. Type = %x",
            (long) type) ;
          return FALSE;
        }
        
        // set the query tag ...
        rowset->SetQueryTag (propVal.bstrVal) ;
        
        try
        {
          // execute the query ...
          rowset->Execute() ;
        }
        catch (_com_error e)
        {
        }
        
        // clear the rowset ...
        rowset->Clear() ;
        
        // get the next entry in the list ...
        queryTag = subSet->NextWithName("query_tag");
      }
    }
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to create the data analysis views. Error = %x", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Add() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to create the data analysis views.", 
          IID_IMTReportingView, E_FAIL) ;
  }

	return S_OK;
}

STDMETHODIMP CMTReportingView::Remove()
{
	BOOL bRetCode=TRUE ;
  _variant_t vtParam ;
  CProductViewCollection PVColl ;
  CMSIXDefinition *pProductView ;
  wstring viewName ;
  _bstr_t queryTag ;
  IMTSQLRowsetPtr rowset ;
  HRESULT nRetVal=S_OK ;

  // start the try
  try
  {
    // initialize the rowset ...    
    nRetVal = rowset.CreateInstance(MTPROGID_SQLROWSET);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to drop the reporting views. Rowset Create() failed.Error = %x", nRetVal) ;
      return Error ("Unable to drop the reporting views. Rowset Create() failed.", 
        IID_IMTReportingView, E_FAIL) ;
    }
    _bstr_t configPath =  REPORTING_CONFIGDIR ;
    rowset->Init(configPath) ;
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to drop the reporting views. Rowset Init() failed.Error = %x", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Remove() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to drop the reporting views. Rowset Init() failed.", 
          IID_IMTReportingView, E_FAIL) ;
  }

  // get the dbtype ...
  wstring wstrDBType = rowset->GetDBType() ;

  // if the dbtype is Oracle do not delete the views ...
  if (wcscmp(wstrDBType.c_str(), ORACLE_DATABASE_TYPE) == 0)
  {
    return S_OK ;
  }

  try
  {
    // create the product view collection ...
    bRetCode = PVColl.Initialize() ;
    if (bRetCode == FALSE)
    {
      mLogger.LogThis (LOG_ERROR, 
        "Unable to initialize product view collection from configuration files.") ;
      return FALSE ;
    }

    // iterate thru the product view collection ...
   	MSIXDefCollection::MSIXDefinitionList & lst = PVColl.GetDefList(); 
	std::list<CMSIXDefinition *>::iterator it;
    for (it = lst.begin(); it != lst.end(); it++ )
    {
      // get the product view ...
      pProductView = *it ;

      // iterate thru the table suffix list to create the query to create the view ...
      queryTag = "__DROP_REPORTING_VIEW__" ;

      // clear the query ...
      rowset->Clear() ;
      
      // set the query tag ...
      rowset->SetQueryTag (queryTag) ;
      
      // create the view name from the product view name ...
      // table name is a string manipulation of the name
      // for example: if name is metratech.com/audioconfcall, the
      // table name gets translated to t_pv_metratech_com_audioconfcall
      viewName = pProductView->GetName() ;
      GetViewName (viewName) ;
      
      // add the parameters ...
      vtParam = viewName.c_str() ;
      rowset->AddParam (MTPARAM_VIEWNAME, vtParam) ;
      
      try
      {
        // execute the query ...
        rowset->Execute() ;
      }
      catch (_com_error e)
      {
      }
    }
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to drop the reporting views. Error = %x", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Remove() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to drop the reporting views.", 
          IID_IMTReportingView, E_FAIL) ;
  }

  // create the other views ...
  try
  {
    // create the rowset and configloader ...
    IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    VARIANT_BOOL flag;
    
		// create an instance of the RCD
		RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
		aRCD->Init();
		RCDLib::IMTRcdFileListPtr aFileList = 
      aRCD->RunQuery("config\\Queries\\dataAnalysisView\\DataAnalysisViewInstall.xml",VARIANT_TRUE);

		if(aFileList->GetCount() == 0) 
    {
      // log error that we can't find any configuration
      mLogger.LogVarArgs (LOG_ERROR, 
        "Add() failed. Unable to find the data analysis view install files.") ;
      return Error ("Unable to find the data analysis view install files.", 
        IID_IMTReportingView, E_FAIL) ;
		}

		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
		if(FAILED(it.Init(aFileList))) 
      return E_FAIL;

		while(TRUE) 
    {
      // get the next element in the list ...
			_variant_t aVariant= it.GetNext();
			_bstr_t afile = aVariant;
			if(afile.length() == 0) 
      {
				break;
			}

      // initialize the _com_ptr_t ...
      MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

      // read the configuration file ...
      MTConfigLib::IMTConfigPropSetPtr confSet = config->ReadConfiguration(afile, &flag);

      // initialize the rowset ...
      wstring wstrConfigPath(afile) ;

      // remove the DataAnalysisViewInstall.xml ...
	  string::size_type index = strfind(wstrConfigPath, L"DataAnalysisViewInstall.xml") ;
      if (index != string::npos)
      {
        // remove the DataAnalysisViewInstall.xml ...
        wstrConfigPath = wstrConfigPath.erase (index, wstrConfigPath.length()-index) ;
      }
      rowset->Init (wstrConfigPath.c_str()) ;
      
      MTConfigLib::IMTConfigPropSetPtr subSet = confSet->NextSetWithName ("drop_view_tags") ;
      
      // read in the XML config file name
      MTConfigLib::IMTConfigPropPtr queryTag = subSet->NextWithName("query_tag");
      
      while (queryTag != NULL)
      {
        MTConfigLib::PropValType type;
        _variant_t propVal;
        
        // get the value
        propVal = queryTag->GetValue(&type);
        if (type != MTConfigLib::PROP_TYPE_STRING)
        {		  			  		
          mLogger.LogVarArgs (LOG_ERROR, 
            "Datatype mismatch while parsing DataAnalysis Install file. Type = %x",
            (long) type) ;
          return FALSE;
        }
        
        // set the query tag ...
        rowset->SetQueryTag (propVal.bstrVal) ;
        
        try
        {
          // execute the query ...
          rowset->Execute() ;
        }
        catch (_com_error e)
        {
        }
        
        // clear the rowset ...
        rowset->Clear() ;
        
        // get the next entry in the list ...
        queryTag = subSet->NextWithName("query_tag");
      }
    }
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to drop the data analysis views. Error = %x", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Remove() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to drop the data analysis views.", 
          IID_IMTReportingView, E_FAIL) ;
  }

  return S_OK;
}

void CMTReportingView::GetViewName (wstring &arViewName)
{
	string::size_type pos = arViewName.find_first_of (L"/", 0);
  if (pos == string::npos)
  {
    pos = arViewName.find_first_of (L"\\") ;
  }
  arViewName.erase (0, pos+1) ;
  int len = arViewName.length() ;
  if (len > 19)
  {
    arViewName.erase (19, len-19) ;
  }
  arViewName.insert (0, L"t_vw_") ;
  
  // replace all /'s with _'s...
  string::size_type nNum;
	while( (nNum = arViewName.find_first_of(L"/\\")) != string::npos)
  {
		arViewName.replace(nNum, 1, L"_");
  }
  
}
