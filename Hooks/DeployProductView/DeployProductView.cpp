/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Carl Shimer
 *
 * $Date: 7/26/2002 1:52:17 PM$
 * $Author: Ralf Boeck$
 * $Revision: 13$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <comip.h>
#include <HookSkeleton.h>
#include <mtprogids.h>
#include <comip.h>
#include <ProductViewOps.h>
#include <NTLogger.h>
#include <ProductViewCollection.h>
#include <DBAccess.h>
#include <DBConstants.h>
#include <UsageServerConstants.h>
#include "DBViewHierarchy.h"
//#include <autoinstance.h>

#include <ConfigDir.h>
#include <stdutils.h>

#define DEPLOYPRODUCTVIEW_STR "DeployProductView"
#define DEPLOYPRODUCTVIEW_TAG "[DeployProductView]"

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
using namespace ROWSETLib;
#import <NameID.tlb>
#import <MetraTech.Product.Hooks.DynamicTableUpdate.tlb> 

using namespace std;

const char* gModuleName = "DeployProductView";

// generate using uuidgen
CLSID CLSID_DeployProductView = { // 7f208000-1006-11d4-aed4-00c04f54fe3b
    0x7f208000,
    0x1006,
    0x11d4,
    {0xae,0xd4,0x00,0xc0,0x4f,0x54,0xfe,0x3b}
  };

class ATL_NO_VTABLE DeployProductView :
  public MTHookSkeleton<DeployProductView,&CLSID_DeployProductView>,
  public DBAccess
{
public:
 virtual HRESULT ExecuteHook(VARIANT var, long* pVal);

};

HOOK_INFO(CLSID_DeployProductView, 
      DeployProductView,
      "MetraHook.DeployProductView.1", 
      "MetraHook.DeployProductView", 
      "free")


/////////////////////////////////////////////////////////////////////////////
// Function name  : DeployProductView::ExecuteHook
// Description      : 
// Return type    : HRESULT 
// Argument         : 
// Argument         : 
/////////////////////////////////////////////////////////////////////////////

HRESULT DeployProductView::ExecuteHook(VARIANT var, long* pVal)
{
  HRESULT hr = S_OK;
  string buffer;
  const char* procName = "DeployProductView::ExecuteHook";

  CProductViewCollection aProductViewCollection;
  CMSIXDefinition aProductViewDef;
  DBSQLRowset rowset;
  
  NTLogger logger;
  LoggerConfigReader cfgRdr;
  logger.Init(cfgRdr.ReadConfiguration(DEPLOYPRODUCTVIEW_STR), 
              DEPLOYPRODUCTVIEW_TAG);
  
  // initialize the database context
  if (!DBAccess::Init(L"\\Database"))
  {
    SetError(DBAccess::GetLastError());
    logger.LogThis(LOG_ERROR, "Database initialization failed for User Config");
    return (E_FAIL);
  }

  // Adding code to create the t_view_hierarchy table here.  
  // This may deserve its own hook one day.
  //
  MTAutoSingleton<DBViewHierarchy> hierarchy;

  ROWSETLib::IMTSQLRowsetPtr view_rowset(MTPROGID_SQLROWSET);
  view_rowset->Init(L"\\Queries\\Database");
  view_rowset->SetQueryTag(L"__TRUNCATE_VIEW_HIERARCHY__");
  view_rowset->Execute();

  NAMEIDLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);
  DBView* pView;
  try
  {
	  if(FALSE == hierarchy->FindView(nameID->GetNameID(L"Root"), pView))
	  {
		  buffer = "Unable to load view hierarchy";
		  logger.LogThis(LOG_ERROR, buffer.c_str());
		  return FALSE;
	  }
  }
  catch(ErrorObject e)
  {
	  return Error("Unable to load view hierarchy");
  }
  if (FALSE == pView->LoadProducts(&hierarchy, NULL))
  {
	  buffer = "Unable to load view hierarchy";
	  logger.LogThis(LOG_ERROR, buffer.c_str());
	  return FALSE;
  }
  if(FALSE == hierarchy->FindView(nameID->GetNameID(L"ProductOfferingParent"), pView))
  {
	  buffer = "Unable to load view hierarchy";
	  logger.LogThis(LOG_ERROR, buffer.c_str());
	  return FALSE;
  }			
  if(FALSE == pView->LoadProducts(&hierarchy, NULL))
  {
	  buffer = "Unable to load view hierarchy";
	  logger.LogThis(LOG_ERROR, buffer.c_str());
	  return FALSE;
  }

  //
  // end create of t_view_hierarchy
  //

  // read the xml product view list file
  // for each in the list
  //     build the collection
  //     get the definition
  //     get the checksum
  //     compare the checksum with the checksum in the table
  //     if different drop and create
  //     else continue
  // done

  // create the productviewops object
  ProductViewOps aProductViewOps;

  // call the initialize method on the collection object
  if (!aProductViewCollection.Initialize())
  {
    buffer = "Unable to initialize product view collection";
    logger.LogThis(LOG_ERROR, buffer.c_str());
    logger.LogErrorObject(LOG_ERROR, aProductViewCollection.GetLastError());
    return Error(buffer.c_str());
  }

  // get the definition list
  ProductViewDefList DefList = aProductViewCollection.GetDefList();

  // for each item in the list
  list <CMSIXDefinition *>::iterator it;
  for ( it = DefList.begin(); it != DefList.end(); it++ )
  {
    CMSIXDefinition* def = *it;
    //DumpMSIXDef(def);
    string pvname = ascii(def->GetName());

	 // md5 of the create table statement
    string pvchecksum = def->GetChecksum();

    // check for the checksum in the table
  
    // execute the language request
    wstring langRequest;
    langRequest = L"select tx_checksum, id_revision from t_product_view_log where ";
    langRequest += L"nm_product_view = N'";
    langRequest += def->GetName();
    langRequest += L"'";
 
    if (!DBAccess::Execute(langRequest, rowset))
    {
      logger.LogThis(LOG_ERROR, "Database execution failed");
      return Error("Database execution failed");
    }
    
    wstring wstrdbchecksum;

	 // number of checksums found determines actions
	 //   0 - product view is new, so create
	 //   1 - product view exists, compare the checksums
	 //  >1 - database consistency error
	 if (rowset.GetRecordCount() ==  0)
    {
		 // this product view doesn't exist
		 logger.LogVarArgs (LOG_WARNING, L"No rows found for product view <%s>",
			 def->GetName().c_str());
		 logger.LogThis (LOG_WARNING, "The product view does not exist");
		 logger.LogVarArgs (LOG_INFO, "Creating <%s>...", pvname.c_str());

		 // initialize the product view ops object
		 if(!aProductViewOps.Initialize()) 
		 {
			 buffer = "Unable to initialize product view ops object";
			 logger.LogThis(LOG_ERROR, buffer.c_str());
			 return Error(buffer.c_str());
		 }

		 wstring wstrxmlfilename;
		 wstrxmlfilename = def->GetName() + L".msixdef";
		 // reverse this so it has the correct path.

		 string aFile = def->GetFileName();
		 string aTempFile = aFile;
		 size_t len = wcslen(L"config\\productview\\");
		 aTempFile = aTempFile.substr(len,aTempFile.length());
		 wstring aWideFile;
		 ASCIIToWide( aWideFile, aTempFile);

		 if(!aProductViewOps.AddTable(aWideFile.c_str()))
		 {
			 buffer = "Unable to add table";
			 logger.LogThis(LOG_ERROR, buffer.c_str());
			 return Error(buffer.c_str());
		 }

		 // Partitoned Views ...
		 // The table is now created in the NetMeter database.  If partitioned
		 // views are enbaled it now needs to be depolyed to the partition 
		 // databases.  The stored proc prtn_deploy_usage_table performs this
		 // action.  prtn_deploy_usage_table exits pleasantly if partitioning
		 // is not enabled, so no need to check if partitioning is enabled
		 // beforehand.

		 // the snap...
		 if (!DBAccess::InitializeForStoredProc(L"prtn_deploy_usage_table"))
		 {
			 // bad snap
			 SetError(DBAccess::GetLastError());
			 logger.LogThis (LOG_ERROR, "Initialization of stored procedure failed for DepolyPartitionedTable");
			 return Error("Couldn't init DBAccess for DepolyPartitionedTable");
		 }

		 // the tee...
		 _variant_t vtValue = def->GetTableName().c_str();
		 if (!DBAccess::AddParameterToStoredProc (L"tabname", MTTYPE_VARCHAR, 
			 INPUT_PARAM, vtValue))
		 {
			 // fumble
			 SetError(DBAccess::GetLastError());
			 logger.LogThis (LOG_ERROR, "Unable to add parameter to stored proc DepolyPartitionedTable.");
			 return Error("Couldn't add param to DepolyPartitionedTable");
		 }

		 // the kick 
		 if (!DBAccess::ExecuteStoredProc())
		 {
			 // no good
			 SetError(DBAccess::GetLastError());
			 logger.LogThis (LOG_ERROR, "Unable to execute stored proc DepolyPartitionedTable.");
			 return FALSE;
		 }

			// "i'm going to disney world!"
			logger.LogVarArgs (LOG_INFO, "<%s> created!", pvname.c_str());
		}
		else if (rowset.GetRecordCount() > 1)
		{
			// more than 1 checksum is too many, possible constraint violation
			logger.LogVarArgs(LOG_ERROR, L"More than one row found for <%s>.",
							  def->GetName().c_str());
			return (E_FAIL);
		}
		else
		{
			// found the single checksum we expected
			rowset.GetWCharValue(_variant_t("tx_checksum"), wstrdbchecksum);

			int revID;
			rowset.GetIntValue(_variant_t("id_revision"), revID);

			string strdbchecksum = ascii(wstrdbchecksum);

			logger.LogThis(LOG_DEBUG, "------------------------------------------");
			logger.LogVarArgs(LOG_DEBUG, "Name --> <%s>", pvname.c_str());
			logger.LogVarArgs(LOG_DEBUG, "PV Checksum --> <%s>", def->GetChecksum().c_str());
			logger.LogVarArgs(LOG_DEBUG, "DB Checksum --> <%s>", strdbchecksum.c_str());
			logger.LogVarArgs(LOG_DEBUG, "DB Revision --> <%d>", revID);

			BOOL updateLogEntry = FALSE;
			BOOL recreateTable = FALSE;
			BOOL checksumMatches = FALSE;
			if (revID == 0)
			{
				// special case - the revision ID is 0.  This means update the checksum in the database
				logger.LogThis(LOG_DEBUG, "Database revision is 0.  Updating checksum with new value");
				updateLogEntry = TRUE;
				recreateTable = FALSE;
			}
			else if (strdbchecksum == pvchecksum)
			{
				logger.LogThis (LOG_DEBUG, "Equal");
				updateLogEntry = FALSE;
				recreateTable = TRUE;
				checksumMatches = TRUE;
			}
			else
			{
				logger.LogThis (LOG_DEBUG, "Unequal");
				updateLogEntry = TRUE;
				recreateTable = TRUE;
				logger.LogVarArgs (LOG_INFO, "Dropping and creating <%s>...", pvname.c_str());
			}

			CProductViewCollection aProductViewCollectionWithFile;
			if (recreateTable || updateLogEntry)
			{
				// convert the product view name to a filename
				wstring wstrxmlfilename;
				wstrxmlfilename = def->GetName() + L".msixdef";

				// replace forward slashes with backslashes (RCD is not
				// happy with forward slashes)
				for (int i = 0; i < (int) wstrxmlfilename.length(); i++)
				{
				  if (wstrxmlfilename[i] == L'/')
					wstrxmlfilename[i] = L'\\';
				}

				// call the initialize method on the collection object
				if (!aProductViewCollectionWithFile.Initialize(wstrxmlfilename.c_str()))
				{
				  buffer = "Unable to initialize product view collection";
				  logger.LogThis(LOG_ERROR, buffer.c_str());
				  logger.LogErrorObject(LOG_ERROR, aProductViewCollection.GetLastError());
				  return Error(buffer.c_str());
				}
			}

			if (recreateTable)
			{
				_bstr_t filenamestr = def->GetFileName().c_str();
				MetraTech_Product_Hooks_DynamicTableUpdate::IDynamicTableUpdatePtr dynupdate(__uuidof(MetraTech_Product_Hooks_DynamicTableUpdate::DynamicTableUpdate));
				if( !dynupdate->UpdateTable(filenamestr, NULL, checksumMatches, true) )
				{
					buffer = "Updating of tables failed";
					logger.LogThis(LOG_ERROR, buffer.c_str());
					return Error(buffer.c_str());
				}
			}

			if (updateLogEntry)
			{
				// update the log table
				if (!aProductViewCollectionWithFile.UpdatePVLog(pvname.c_str(), pvchecksum.c_str()))
				{
				  SetError(FALSE,gModuleName,__LINE__,procName,"Updating log failed");
				  logger.LogThis(LOG_ERROR, "Unable to update log entry");
				  return (FALSE);
				}
			}
		}
	}
  
  // disconnect from the database
  if (!DBAccess::Disconnect())
  {
    SetError(DBAccess::GetLastError());
    logger.LogThis(LOG_ERROR, "Database disconnect failed");
    return (E_FAIL);
  }

  return hr;
}
