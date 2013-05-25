
/**************************************************************************
* @doc TEST
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
* Created by: Carl Shimer
*
* Modified by:
*
* $Header$
***************************************************************************/


#include <metralite.h>
#include <mtcom.h>
#include <mtprogids.h>
#include <ProductViewCollection.h>
#include <loggerconfig.h>
#include <DBConstants.h>
#include <UsageServerConstants.h>
#include "ProductViewOps.h"



ProductViewOps::ProductViewOps() {}

const char* gModule = "ProductViewOps";
/////////////////////////////////////////////////////////////////////////////
// Function name	: ProductViewOps::Initialize
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "ProductViewOps::Initialize()"
bool ProductViewOps::Initialize()
{
  // hold onto an instance of a database connection.  This is
  // necessary to avoid the ADO 15 second COM+ timeout.  wooHoo!!
  mRS.CreateInstance(MTPROGID_SQLROWSET);
  mRS->Init("queries\\database");

  return true;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: ProductViewOps::DropTable
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

bool ProductViewOps::DropTable(const wchar_t* pTable)
{
	// if pTable is NULL it means drop them all
	return PerformAction(true,pTable);

}


/////////////////////////////////////////////////////////////////////////////
// Function name	: ProductViewOps::AddTable
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

bool ProductViewOps::AddTable(const wchar_t* pTable)
{
	// if pTable is NULL it means add them all
	return PerformAction(false,pTable);
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: ProductViewOps::PerformAction
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "ProductViewOps::Initialize()"
bool ProductViewOps::PerformAction(bool bDropTable,const wchar_t* pTableName)
{
	// if pTable is NULL it means drop/add them all

	CProductViewCollection aProductViewCollection;
 
	NTLogger logger;
	LoggerConfigReader cfgRdr;
	logger.Init(cfgRdr.ReadConfiguration(PRODUCT_VIEW_STR), CORE_TAG);
  
	// call the initialize method on the collection object
	if (!aProductViewCollection.Initialize(pTableName))
	{
		SetError(FALSE,gModule,__LINE__,PROCEDURE,"Unable to initialize");
		logger.LogThis(LOG_ERROR, "Unable to initialize");
		return (FALSE);
	}

	if (bDropTable) {
		if(!aProductViewCollection.DropTables()) {
			SetError(FALSE,gModule,__LINE__,PROCEDURE,"failed to drop product view tables");
			logger.LogThis(LOG_ERROR, "failed to drop product view tables");
			return (FALSE);
		}
	}
	else {
		if(!aProductViewCollection.CreateTables()) {
			SetError(FALSE,gModule,__LINE__,PROCEDURE,"failed to create product view tables");
			logger.LogThis(LOG_ERROR, "failed to create product view tables");
			return (FALSE);
		}
	}


	// delete from the log table
	if (bDropTable)
	{
		if (!aProductViewCollection.DeleteFromPVLog())
		{
			SetError(FALSE,gModule,__LINE__,PROCEDURE,"Deleting from log failed");
			logger.LogThis(LOG_ERROR, "Unable to delete entry from log");
			return (FALSE);
		}
	}
	else  
	{
	    // add into the log table
	    if (!aProductViewCollection.InsertIntoPVLog())
		{
		    SetError(FALSE,gModule,__LINE__,PROCEDURE,"Insert into log failed");
			logger.LogThis(LOG_ERROR, "Unable to insert entry into log");
			return (FALSE);
		}
	}

	return (TRUE);

}

