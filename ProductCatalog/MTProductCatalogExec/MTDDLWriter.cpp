/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTDDLWriter.h"

#include "MTExtendedPropWriter.h"
#include "pcexecincludes.h"

#include <ExtendedProp.h>
#include <ParamTable.h>
#include <formatdbvalue.h>

#import <MetraTech.Product.Hooks.DynamicTableUpdate.tlb> 
#import <MetraTech.Product.Hooks.InsertProdProperties.tlb>


/////////////////////////////////////////////////////////////////////////////
// CMTDDLWriter

/******************************************* error interface ***/
STDMETHODIMP CMTDDLWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTDDLWriter
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (::InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

/****************************************** IObjectControl ***/
HRESULT CMTDDLWriter::Activate()
{
  HRESULT hr = GetObjectContext(&mpObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CMTDDLWriter::CanBePooled()
{
  return FALSE;
} 

void CMTDDLWriter::Deactivate()
{
  mpObjectContext.Release();
} 

STDMETHODIMP CMTDDLWriter::SyncAdjustmentTables(IMTSessionContext* apCtxt)
{
  
  MTAutoContext context(mpObjectContext);
  
  try
  {
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
		rowset->InitializeForStoredProc("GENERATEADJUSTMENTTABLES");
    rowset->ExecuteStoredProc();
	}
	catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  return S_OK;
}


STDMETHODIMP CMTDDLWriter::SyncExtendedPropertyTables(IMTSessionContext* apCtxt)
{
  
  MTAutoContext context(mpObjectContext);
  
  try
  {
    std::map<std::wstring, bool> tableMap;  

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_EXTENDED_PROP_TABLES__");
    rowset->Execute();
    
    while (rowset->GetRowsetEOF().boolVal == VARIANT_FALSE) 
    {
      std::wstring tablename = rowset->GetValue("nm_tablename").bstrVal;
      tableMap[tablename] = false;
  
      rowset->MoveNext();
    }

    ExtendedPropCollection ExtPropTables; 
  
    if (!ExtPropTables.Init())
    {
      DWORD errorCode = ExtPropTables.GetLastErrorCode();

      if (errorCode == CORE_ERR_NOMSIXFILEFILES_FOUND)
      { //no files found, nothing to do
        return S_OK;
      }
      else
      { const ErrorObject* error = ExtPropTables.GetLastError();
        MT_THROW_COM_ERROR( "Error reading extended properties: %s",
                            error ? error->GetProgrammerDetail().c_str() : "unkown error" );
      }
    }
    
    MSIXDefCollection::MSIXDefinitionList& lst = ExtPropTables.GetDefList();
    list <CMSIXDefinition *>::iterator it;
    for ( it = lst.begin(); it != lst.end(); it++ )
    {
      CMSIXDefinition * pDef = *it;
    
      std::wstring tablename(pDef->GetTableName());
      std::string checksum(pDef->GetChecksum());
      
      std::wstring filename(pDef->GetName());
      filename += L".msixdef";

      rowset->ClearQuery();
      rowset->SetQueryTag("__GET_EXTENDED_PROP_CHECKSUM__");
      rowset->AddParam("%%TABLENAME%%", tablename.c_str());
      rowset->Execute();

      if (0 == rowset->GetRecordCount())
      {
        BOOL tableExists = FALSE;
        PCCache::GetLogger().LogVarArgs(LOG_INFO,
                                        "Creating new extended property table: %S",
                                        tablename.c_str());

        ExtendedPropCollection ExtPropTable;
        
        if (!ExtPropTable.Init(filename.c_str()))
          return Error(L"cannot initialize extended property tables");

        if (!tableExists)
        {
          if (!ExtPropTable.CreateTables())
            return Error(L"cannot create extended property tables");
        }
        else
        {
          if (!ExtPropTable.UpdateChecksums())
            return Error(L"cannot update checksums of extended property tables");
        }
      }
      else if (1 == rowset->GetRecordCount())
      {
        _bstr_t val = rowset->GetValue("tx_checksum").bstrVal;    
        std::string dbchecksum((const char*)val);
        
        long version = rowset->GetValue("n_version");

        BOOL recreateTable;
        BOOL updateChecksum;
        if (version == 0)
        {
          // NOTE: special case
          // if the version was moved down to 0, the user wants the
          // checksum to be regenerated.
          PCCache::GetLogger().LogVarArgs(LOG_INFO,"Extended property table %S has version number 0 in the database - regenerating checksum",
                                          tablename.c_str());
          updateChecksum = TRUE;
          recreateTable = FALSE;
        }
        else if (checksum != dbchecksum)
        {
          updateChecksum = TRUE;
          recreateTable = TRUE;
        }
        else
        {
          PCCache::GetLogger().LogVarArgs(LOG_INFO,"Extended property table did not change: %S", tablename.c_str());
          updateChecksum = FALSE;
          recreateTable = FALSE;
        }

        ExtendedPropCollection ExtPropTable;

        if (recreateTable)
        {
          PCCache::GetLogger().LogVarArgs(LOG_INFO,"Recreating changed extended property table: %S", tablename.c_str());

          if (!ExtPropTable.Init(filename.c_str()))
            return Error(L"cannot initialize extended property tables");
          if (!ExtPropTable.BackupTables())
            return Error(L"cannot backup extended property tables");
          if (!ExtPropTable.DropTables())
            return Error(L"cannot delete extended property tables");
          if (!ExtPropTable.CreateTables())
            return Error(L"cannot create extended property tables");

          _bstr_t defaultStr,columnList;
          XMLString kindStr = (*pDef->GetAttributes()->find(std::wstring(L"kind"))).second;
          MTPRODUCTCATALOGLib::MTPCEntityType kind = static_cast<MTPRODUCTCATALOGLib::MTPCEntityType>(atoi(ascii(kindStr).c_str()));

          // use the meta data object directly (instead of the product catalog object)
          // to allow retrieving load errors
          MTPRODUCTCATALOGLib::IMTProductCatalogMetaDataPtr metaData(__uuidof(MTProductCatalogMetaData));
          metaData->Load(VARIANT_TRUE); // TRUE = return error that occurs during load

          MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr propMetaDataSet = 
            metaData->GetPropertyMetaDataSet(kind);

          int count = 0;
          wchar_t* delimiter = L">||<";
          for(long i=1;i<= propMetaDataSet->GetCount();i++) {
            MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMetaData = propMetaDataSet->GetItem(i);
            if(propMetaData->GetExtended() == VARIANT_TRUE) {
              _variant_t vtDefault = propMetaData->GetDefaultValue();
              std::wstring aTempBuf;
              if (count > 0)
              {
                defaultStr += delimiter;
                columnList += delimiter;
              }
              FormatValueForDB(vtDefault,false,aTempBuf);
              defaultStr += aTempBuf.c_str();
              columnList += propMetaData->GetDBColumnName();
              count++;
            }
          }

          if (!ExtPropTable.MergeTables(columnList, defaultStr, delimiter))
          {
            std::wstring msg;
            msg += L"cannot merge extended property table ";
            msg += tablename;
            msg += L"; you must now manually merge the backup table and drop it when done";
            return Error(msg.c_str());
          }
        }
        if (updateChecksum)
        {
          if (!ExtPropTable.Init(filename.c_str()))
            return Error(L"cannot initialize extended property tables");  
          if (!ExtPropTable.UpdateChecksums())
            return Error(L"cannot update checksums of extended property tables");
        }

      }
      else 
          return (E_FAIL);
  

      // mark table as processed
      tableMap[tablename] = true;
    }

    ExtendedPropCollection ExtPropTable;
    
    // delete tables that did not have MSIX definitions
    typedef std::map<std::wstring, bool>::const_iterator CI;
    for(CI iter = tableMap.begin(); iter != tableMap.end(); ++iter)
    {
      if (false == iter->second)
        if (!ExtPropTable.DropTables((iter->first).c_str()))
          return Error(L"cannot delete extended property tables");
        else
          PCCache::GetLogger().LogVarArgs(LOG_INFO,"Removing extended property table: %S", (iter->first).c_str());
    }   

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// Synchronize paramtables in database with xml
// This method uses dynamic table update to update parameter tables.
STDMETHODIMP CMTDDLWriter::SyncParameterTables(IMTSessionContext* apCtxt)
{
	MTAutoContext context(mpObjectContext);

	try
	{
		// The current algorithm adds paramtables that do not yet exits
	    // TODO: update modified tables, remove none existing tables!!
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		//
		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionWriterPtr writer (__uuidof(MTPRODUCTCATALOGEXECLib::MTParamTableDefinitionWriter));
		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTParamTableDefinitionReader));

		// Generate parameter table name to id map.
		std::map<std::wstring, long> paramTableMap;
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr rs = reader->FindAsRowset(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt));
		while (rs->GetRowsetEOF().boolVal == VARIANT_FALSE) 
		{
			std::wstring tablename = rs->GetValue("nm_instance_tablename").bstrVal;
			long id = rs->GetValue("id_paramtable").lVal;

			StrToLower(tablename);
			paramTableMap[tablename] = id;
			rs->MoveNext();
		}

		// Get list of all parameter tables.
		ParamTableCollection paramTablesDefs;
		if (!paramTablesDefs.Init())
		{
			DWORD errorCode = paramTablesDefs.GetLastErrorCode();
			if (errorCode == CORE_ERR_NOMSIXFILEFILES_FOUND)
				return S_OK; // No files found, that's OK
			else
			{
				const ErrorObject* error = paramTablesDefs.GetLastError();
				MT_THROW_COM_ERROR( "Error initializing ParamTables: %s",
									error ? error->GetProgrammerDetail().c_str() : "unkown error" );
			}
		}

		// Initialize parameter table creator.
		ParamTableCreator paramTableCreator;
		if (!paramTableCreator.Init())
		{
			string err = "Cannot initialize parameter table creator";
			PCCache::GetLogger().LogVarArgs(LOG_ERROR, err.c_str());
			return Error(err.c_str());
		}

		// Loop through all the parameter definitions.
		MetraTech_Product_Hooks_InsertProdProperties::IInsertProdPropertiesPtr pIPP(__uuidof(MetraTech_Product_Hooks_InsertProdProperties::InsertProdProperties));
	    MSIXDefCollection::MSIXDefinitionList& lst = paramTablesDefs.GetDefList();
		list <CMSIXDefinition*>::iterator it;
		for (it = lst.begin(); it != lst.end(); it++)
		{
			CMSIXDefinition* pDef = *it;

			// Get parm table def checksum
			std::string checksum(pDef->GetChecksum());
			std::wstring tablename(pDef->GetTableName());

			// Check if param table already exists.
			_bstr_t paramTblName = pDef->GetName().c_str();
			MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionPtr parmTbl;
			parmTbl = reader->FindByName(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), paramTblName);
		    if (parmTbl != NULL)
			{
				PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Parameter Table Def (%s) already exists in the database", (char*) paramTblName);

				// We don't know if the base props have changed, but update them anyway.
				writer->Update(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), parmTbl);
				//xxx Not sure if we need this.

				// Compare checksums.
				rowset->SetQueryTag("__GET_PARAMTABLE_CHECKSUM__");
				rowset->AddParam("%%ID_PARAM%%", parmTbl->ID);
				rowset->Execute();
                if (rowset->GetRecordCount() != 1)
		        {
					// the checksum doesn't exist in the database but the
					// parameter table itself does - this means the checksum has intentionally
					// been deleted. In this case, update the checksum but don't drop the table.
					PCCache::GetLogger().LogVarArgs(LOG_INFO, "Parameter table checksum lost or deleted for table %s. Recreating with value %s",
												  (char*)paramTblName, checksum.c_str());

					// Add to t_object_history
					rowset->SetQueryTag("__ADD_PARAMTABLE_CHECKSUM__");
					rowset->AddParam("%%ID_PARAM%%", parmTbl->ID);
					rowset->AddParam("%%CHECKSUM%%", checksum.c_str());
					rowset->Execute();
				}
		        else // Found checksum
				{
					_bstr_t val = rowset->GetValue("tx_checksum").bstrVal;    
					std::string dbchecksum((const char*)val);
					long version = rowset->GetValue("n_version");
					BOOL updateChecksum = FALSE;
					if (version == 0)
					{
						// NOTE: special case
						// if the version was moved down to 0, the user wants the
						// checksum to be regenerated.
						updateChecksum = TRUE;
						PCCache::GetLogger().LogVarArgs(LOG_INFO, "Parameter table %s has version number 0 in the database - regenerating checksum",
														(char*)paramTblName);
					}
					else if (checksum != dbchecksum)
					{
						PCCache::GetLogger().LogVarArgs(LOG_INFO,"Recreating changed parameter table: %s", (char*)paramTblName);

						// Run dynamic table update.
						_bstr_t filename(pDef->GetFileName().c_str());
						MetraTech_Product_Hooks_DynamicTableUpdate::IDynamicTableUpdatePtr dynupdate(__uuidof(MetraTech_Product_Hooks_DynamicTableUpdate::DynamicTableUpdate));
						if(!dynupdate->UpdateTable(filename, NULL, FALSE, true))
						{
							string err = "Updating of parameter tables failed";
							PCCache::GetLogger().LogVarArgs(LOG_ERROR, err.c_str());
							return Error(err.c_str());
						}
						updateChecksum = TRUE;
					}
					else
					{
						PCCache::GetLogger().LogVarArgs(LOG_INFO,"Parameter table did not change: %s", (char*)paramTblName);
						updateChecksum = FALSE;
					}

					// Update checksum if changed.
					if (updateChecksum)
					{
						rowset->SetQueryTag("__UPDATE_PARAMTABLE_CHECKSUM__");
						rowset->AddParam("%%ID_PARAM%%", parmTbl->ID);
						rowset->AddParam("%%CHECKSUM%%", checksum.c_str());
						rowset->Execute();
					}
				}
			}
			else // param table does not exist, create it.
			{
				PCCache::GetLogger().LogVarArgs(LOG_INFO, "Creating Parameter table: %s", (char*) paramTblName);

				if (!paramTableCreator.SetupDatabase(*pDef))
				{
					string err = "Cannot create parameter table";
					PCCache::GetLogger().LogVarArgs(LOG_ERROR, err.c_str());
					return Error(err.c_str());
				}

				// Create table if it does not exist 
				MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionPtr parmTbl;
				HRESULT hr = parmTbl.CreateInstance(__uuidof(MTPRODUCTCATALOGLib::MTParamTableDefinition));
				if (FAILED(hr))
				{
					string err = "Cannot create MTParamTableDefinition";
					PCCache::GetLogger().LogVarArgs(LOG_ERROR, err.c_str());
					return Error(err.c_str());
				}

				parmTbl->Name = pDef->GetName().c_str();
				parmTbl->DBTableName = tablename.c_str();

				// Get the DisplayName
				const XMLNameValueMapDictionary * pAttrs = pDef->GetAttributes();
				if (pAttrs)
				{
					XMLNameValueMapDictionary::const_iterator findit = pAttrs->find(L"display_name");
					if (findit != pAttrs->end())
					{
						std::wstring displayName = findit->second;
						parmTbl->PutDisplayName(displayName.c_str());
					}
				}

				// Add to t_object_history
				MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionWriterPtr writer (__uuidof(MTPRODUCTCATALOGEXECLib::MTParamTableDefinitionWriter));
				long ID = writer->Create(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), parmTbl);
				ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
				rowset->Init(CONFIG_DIR);
				rowset->SetQueryTag("__ADD_PARAMTABLE_CHECKSUM__");
				rowset->AddParam("%%ID_PARAM%%", ID);
				rowset->AddParam("%%CHECKSUM%%", _bstr_t(pDef->GetChecksum().c_str()));
				rowset->Execute();

				// Add the properties in the t_param_table_prop table.
				pIPP->Initialize(pDef->GetFileName().c_str(), ID);
				if (pIPP->InsertProperties() == 0)
					MT_THROW_COM_ERROR("Inserting parameter table properties failed for %s", (char*) paramTblName);
			} // if 

      StrToLower(tablename);
			paramTableMap.erase(tablename);
		} // for

		// Drop the tables for which no msixdef files exist.
		typedef std::map<std::wstring, long>::const_iterator CI;
		for(CI iter = paramTableMap.begin(); iter != paramTableMap.end(); ++iter)
		{
			std::wstring tablename = iter->first;
			long ID = iter->second;

			PCCache::GetLogger().LogVarArgs(LOG_INFO, "Removing parameter table: %s", tablename.c_str());

			// Delete the parameter table
			CMSIXDefinition Def;
			if (!paramTableCreator.CleanupDatabase(Def, tablename.c_str()))
				return Error(L"Cannot delete parameter table");

			writer->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), ID);

			//Delete the checksum for the table
			rowset->SetQueryTag("__DELETE_PARAMTABLE_CHECKSUM__");
			rowset->AddParam("%%ID_PARAM%%", ID);
			rowset->Execute();

			//Delete the reference in t_pi_rulesetdef_map
			rowset->SetQueryTag("__DELETE_PARAMTABLE_DEFINITION_MAP__");
			rowset->AddParam("%%ID_PARAM%%", ID);
			rowset->Execute();

			//Delete the reference in t_rulesetdefinition
			rowset->SetQueryTag("__DELETE_PARAMTABLE_DEFINITION__");
			rowset->AddParam("%%ID_PARAM%%", ID);
			rowset->Execute();
		}

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Finished Product Catalog parameter table hook");
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

HRESULT CMTDDLWriter::CreateView(IMTSessionContext* apCtxt, BSTR aFromProductView,BSTR* apViewName)
{
  HRESULT hr(S_OK);
  MTAutoContext context(mpObjectContext);
  
  //See  if view name contains acc_usage
  //if YES then call CreateUsageView, otheriwse call InternalCreateView
  wstring sPVName = (const wchar_t*) aFromProductView;
  StrToLower(sPVName);
  
  if(sPVName.find(wstring(L"acc_usage")) == wstring::npos)
    hr = InternalCreateView(apViewName, aFromProductView);
  else
    hr = CreateUsageView(apCtxt, apViewName);
  
  if(FAILED(hr))
    return hr;
  
  context.Complete();
  return hr;
}

HRESULT CMTDDLWriter::CreateAllViews(IMTSessionContext* apCtxt)
{
  HRESULT hr(S_OK);
  MTAutoContext context(mpObjectContext);
  hr = InternalCreateView(NULL);
  if(FAILED(hr))
    return hr;
  
  context.Complete();
  return hr;
}
HRESULT CMTDDLWriter::CreateUsageView(IMTSessionContext* apCtxt, BSTR* apViewName)
{
  HRESULT hr(S_OK);
  BOOL bFirstTime=TRUE ;
  VARIANT_BOOL bViewExists;
  _bstr_t bstrViewName = GetViewName(L"t_acc_usage");
  _bstr_t bstrQuery;
  _variant_t vtParam ;
  ROWSETLib::IMTSQLRowsetPtr rs;
  CComPtr<IMTCounterViewReader> reader;

  MTAutoContext context(mpObjectContext);
  
  hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
  if(FAILED(hr))
    return hr;

  hr = reader.CoCreateInstance(__uuidof(MTCounterViewReader));
  
  if(FAILED(hr))
    return hr;
  (*apViewName) = bstrViewName.copy();
  reader->ViewExists(apCtxt, bstrViewName, &bViewExists);
  
  //view already there, don't create it
  if(bViewExists)
    return hr;
  
  try
  {
    //we never execute this query, it's only used to create
    //%%VIEWNAME%% parameter into CREATE_UNION_VIEW query
    rs->Init(CONFIG_DIR);
    rs->SetQueryTag(CREATE_COUNTER_USAGE_VIEW_SELECT_CLAUSE);
    bstrQuery += rs->GetQueryString() ;
    
    rs->Clear();
    //Set Query tag for view object creation
    rs->SetQueryTag(CREATE_COUNTER_UNION_VIEW);
    
    // add the parameters
    vtParam = bstrViewName;
    rs->AddParam (MTPARAM_VIEWNAME, vtParam) ;
    vtParam = bstrQuery;
    rs->AddParam (MTPARAM_SELECTCLAUSE, vtParam) ;
    
    // execute the query
    rs->Execute() ;
    context.Complete();
  }
  catch (_com_error& e)
  {
    return ReturnComError(e);
  }
  return hr;
}


STDMETHODIMP CMTDDLWriter::RemoveView(IMTSessionContext* apCtxt, BSTR aPVName)
{
  HRESULT hr(S_OK);
  ROWSETLib::IMTSQLRowsetPtr rs;
  _bstr_t bstrViewName = GetViewName(aPVName);
  _variant_t vtParam = bstrViewName;
  
  hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
  if(FAILED(hr))
    return hr;
  try
  {
    rs->Init(CONFIG_DIR);
    rs->SetQueryTag(DROP_COUNTER_UNION_VIEW);
    rs->AddParam (MTPARAM_VIEWNAME, vtParam);
    rs->Execute();
    if (mpObjectContext)
      mpObjectContext->SetComplete();
  }
  catch (_com_error& e)
  {
    if (mpObjectContext)
      mpObjectContext->SetAbort();
    return ReturnComError(e);
  }
  
  return hr;
}


_bstr_t CMTDDLWriter::GetViewName (BSTR arProductView)
{
  _bstr_t bstrPVName = arProductView;
  wstring viewName = (const wchar_t*) bstrPVName;

  //remove "t_" from the beginning if it's there
  if( viewName.find(L"t_") == 0)
  { 
    viewName.erase(0,2);
  }
  
  //strip all chars before and including first slash
  string::size_type pos = viewName.find (L"/") ;
  if (pos == string::npos)
  {
    pos = viewName.find (L"\\") ;
  }
  viewName.erase (0, pos+1) ;

  //limit to 19 chars
  string::size_type len = viewName.length() ;
  if (len > 19)
  {
    viewName.erase (19) ;
  }
  
  //prepend "t_vw_"
  viewName.insert(0, L"t_vw_");

  //replace "/" and "\" with "_" 
	string::size_type charpos;
  while( (charpos = viewName.find_first_of(L"/\\")) != string::npos)
  {
		viewName.replace(charpos, 1, L"_");
  }
  
  return _bstr_t (viewName.c_str());
}

HRESULT CMTDDLWriter::InternalCreateView( BSTR* apViewName,BSTR aFromProductView)
{
  HRESULT hr(S_OK);
  BOOL bFirstTime=TRUE ;
  BOOL bFoundMatch=FALSE;
  VARIANT_BOOL bViewExists;

  CProductViewCollection PVColl ;
  CMSIXDefinition *pProductView ;
  CMSIXProperties *pPVProp ;
  _bstr_t bstrViewName;
  _bstr_t bstrQuery;
  _bstr_t bstrSelect;
  _variant_t vtParam ;
  ROWSETLib::IMTSQLRowsetPtr rs;

  CComPtr<IMTCounterViewReader> reader;
  hr = reader.CoCreateInstance(__uuidof(MTCounterViewReader));
  
  if(FAILED(hr))
    return hr;

  hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
  if(FAILED(hr))
    return hr;

  if(aFromProductView)
  {
      bstrViewName = GetViewName(aFromProductView);
      hr = reader->ViewExists(NULL, bstrViewName, &bViewExists);
      if(FAILED(hr))
        return hr;
      //view already there, don't create it
    if(bViewExists)
    {
      (*apViewName) = bstrViewName.copy();
      return hr;
    }
  }
  try
  {
    //we never execute this query, it's only used to create
    //%%VIEWNAME%% parameter into CREATE_UNION_VIEW query
    rs->Init(CONFIG_DIR);
    
    // create the product view collection ...
    if(!PVColl.Initialize())
      return E_FAIL;
    
    // iterate thru the product view collection ...

    ProductViewDefList& lst = PVColl.GetDefList();
    list <CMSIXDefinition *>::iterator it;
    for ( it = lst.begin(); it != lst.end(); it++ )
    {
      // get the product view ...
      pProductView = *it ;
      _bstr_t pvname = pProductView->GetName().c_str();
      _bstr_t tablename = pProductView->GetTableName().c_str();
      
      //if productviewname was passed in, generate just one view
      //otherwise generate all views
      if(aFromProductView)
      {
        _bstr_t bstrSourcePVName = aFromProductView;
        if(_wcsicmp((const wchar_t*) bstrSourcePVName, (const wchar_t*)pvname))
        //no match in names,  go to next in PV collection
        {
        // ..unless someone put directly table name
          if(_wcsicmp((const wchar_t*) bstrSourcePVName, (const wchar_t*)tablename))
            continue;
        }
      }
      else
      {
        //creating all views, check view existance and continue if
        //it already exists
        bstrViewName = GetViewName(pvname);
        hr = reader->ViewExists(NULL, bstrViewName, &bViewExists);
        if(FAILED(hr))
          return hr;
        //view already there, don't create it
        if(bViewExists)
          continue;
      }
  
      //if no matches were found in PV collection, then generate error
      bFoundMatch = TRUE;
      
      // iterate thru the product view properties and create the select clause ...

      bFirstTime = TRUE ;
      MSIXPropertiesList::iterator PVPropCollIter;
      for (PVPropCollIter = pProductView->GetMSIXPropertiesList().begin();
           PVPropCollIter != pProductView->GetMSIXPropertiesList().end();
           ++PVPropCollIter)
      {
        pPVProp = *PVPropCollIter;
        
        // add the commas after the data already written ...
        if (bFirstTime == FALSE)
        {
          bstrSelect += L", pv." ;
        }
        // this is the first time through ... set the flag to false now ...
        else
        {
          bFirstTime = FALSE ;
          bstrSelect = L" pv." ;
        }
        
        // get the column name for the property ...
        bstrSelect += _bstr_t( pPVProp->GetColumnName().c_str() );
      }
      
      bFirstTime = TRUE;
      // set the query tag ...
      rs->SetQueryTag(CREATE_COUNTER_VIEW_SELECT_CLAUSE);
        
      vtParam = pProductView->GetTableName().c_str() ;
      rs->AddParam (MTPARAM_TABLENAME, vtParam) ;
      vtParam = bstrSelect;
      rs->AddParam (MTPARAM_SELECTCLAUSE, vtParam) ;
      bstrQuery += rs->GetQueryString() ;
      
      rs->Clear() ;
      //Set Query tag for view object creation
      rs->SetQueryTag(CREATE_COUNTER_UNION_VIEW);
      
     
      vtParam = bstrViewName;
      rs->AddParam (MTPARAM_VIEWNAME, vtParam) ;
      vtParam = bstrQuery;
      rs->AddParam (MTPARAM_SELECTCLAUSE, vtParam) ;
      
      // execute the query ...
      rs->Execute() ;
      bstrQuery = _bstr_t("");
    }

    // if no matches were found in PV collection, then generate error
    if (!bFoundMatch && aFromProductView)
		MT_THROW_COM_ERROR(MTPC_INVALID_PRODUCT_VIEW_NAME);
    else
		if(apViewName)
		{
			if(bstrViewName.length())
				(*apViewName) = bstrViewName.copy();
		}
  }
  catch (_com_error& e)
  {
    return ReturnComError(e);
  }
  return hr;
}

STDMETHODIMP CMTDDLWriter::ExecuteStatement(BSTR aQuery, VARIANT aQueryDir, IMTSQLRowset **ppRowset)
{
	MTAutoContext context(mpObjectContext);
	try {
	
		_variant_t queryDir;

		ROWSETLib::IMTSQLRowsetPtr aRowset(MTPROGID_SQLROWSET);
		if(OptionalVariantConversion(aQueryDir,VT_BSTR,queryDir)) {
			aRowset->Init((_bstr_t)queryDir);
		}
		else {
			aRowset->Init("queries\\database");
		}

		aRowset->SetQueryString(aQuery);
		aRowset->ExecuteDisconnected();
		*ppRowset = reinterpret_cast<IMTSQLRowset*>(aRowset.Detach());
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	context.Complete();
	return S_OK;
}
