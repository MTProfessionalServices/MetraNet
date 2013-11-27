/**************************************************************************
 * @doc TEST
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
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <BatchHierarchy.h>
#include <mtprogids.h>
#include <OdbcConnection.h>
#include <OdbcConnMan.h>
#include <mtcom.h>

int main (int argc, char ** argv)
{
	ComInitialize aInit;

	COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	COdbcConnectionPtr odbcConnection = new COdbcConnection(info);

	MTPipelineLib::IMTTransactionPtr aTransaction(MTPROGID_MTTRANSACTION);

 MTBatchHierarchyLoaderAbstractPtr aBatchLoader = BatchCreateMgr::CreateInstance(
		"t_acc_create_temp","t_temp_hierarchy",
		odbcConnection,aTransaction);

	aBatchLoader->LoadFromTable();
	aBatchLoader->SortAndCommitToTempTable();


  return TRUE;
}



