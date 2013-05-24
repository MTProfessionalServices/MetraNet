/**************************************************************************
* @doc SIMPLE
*
* Copyright 1998 by MetraTech Corporation
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
* Created by: Anagha Rangarajan
***************************************************************************/
#include <metra.h>
#include <mtcom.h>
#include <mtprogids.h>
#include <comip.h>
#include <NTLogger.h>
#include <DBAccess.h>
#include <DBConstants.h>
#include "DBViewHierarchy.h"

#include <ConfigDir.h>
#include <stdutils.h>

#include <string>
#include <iostream>

using namespace std;

#define DEPLOYVIEWHIERARCHY_STR "DeployViewHierarchy"
#define DEPLOYVIEWHIERARCHY_TAG "[DeployViewHierarchy]"


#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
using namespace ROWSETLib;
#import <NameID.tlb>



int main(int argc, char** argv)
{
	ComInitialize ci(COINIT_MULTITHREADED);

 //initialize the logger
  NTLogger logger;
  LoggerConfigReader cfgRdr;
  logger.Init(cfgRdr.ReadConfiguration(DEPLOYVIEWHIERARCHY_STR),
              DEPLOYVIEWHIERARCHY_TAG);

  MTAutoSingleton<DBViewHierarchy> hierarchy;
  string buffer;

  ROWSETLib::IMTSQLRowsetPtr view_rowset(MTPROGID_SQLROWSET);
  view_rowset->Init(L"\\Queries\\Database");
  view_rowset->SetQueryTag(L"__TRUNCATE_VIEW_HIERARCHY__");
  view_rowset->Execute();

  NAMEIDLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);
  DBView* pView;
  if(FALSE == hierarchy->FindView(nameID->GetNameID(L"Root"), pView))
  {
      buffer = "Unable to load view hierarchy";
	  logger.LogThis(LOG_ERROR, buffer.c_str());
	  return FALSE;
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
  logger.LogThis(LOG_DEBUG, "View_hierarchy updated successfully");
  return 0;
}
