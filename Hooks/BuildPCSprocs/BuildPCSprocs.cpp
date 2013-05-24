/**************************************************************************
 * @doc CONFIGREFRESH
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
 * $Header$
 ***************************************************************************/

#include <metra.h>

#include <mtcom.h>
#import <MTConfigLib.tlb>
#include <HookSkeleton.h>
#include <mtprogids.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

// generate using uuidgen
//CLSID __declspec(uuid("ca4d4950-00c0-11d3-a1e8-006008c0e24a")) CLSID_BuildPCSprocs;

CLSID CLSID_BuildPCSprocs = { /* c8d1a63e-678d-4db4-9579-aee0fcbf5d12 */
    0xc8d1a63e,
    0x678d,
    0x4db4,
    {0x95, 0x79, 0xae, 0xe0, 0xfc, 0xbf, 0x5d, 0x12}
  };

class ATL_NO_VTABLE BuildPCSprocs :
  public MTHookSkeleton<BuildPCSprocs,&CLSID_BuildPCSprocs>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var, long* pVal);
 
 // ctor
 BuildPCSprocs() : mPrincipalRowset(MTPROGID_SQLROWSET),
	 mEpTableRowset(MTPROGID_SQLROWSET), mGenSprocRowset(MTPROGID_SQLROWSET) 
 {}

protected:
 ROWSETLib::IMTSQLRowsetPtr mPrincipalRowset;
 ROWSETLib::IMTSQLRowsetPtr mEpTableRowset;
 ROWSETLib::IMTSQLRowsetPtr mGenSprocRowset;
};

HOOK_INFO(CLSID_BuildPCSprocs, BuildPCSprocs,
						"MetraHook.BuildPCSprocs.1", "MetraHook.BuildPCSprocs", "free")


HRESULT BuildPCSprocs::ExecuteHook(VARIANT var, long* pVal)
{
	const char* aConfigDir = "queries\\PCPropQueryBuilder";

	try {

		mLogger.LogThis(LOG_INFO, "Creating Product Catalog extended property stored procedure(s)");

		// three different rowsets
		mPrincipalRowset->Init(aConfigDir);
		mEpTableRowset->Init(aConfigDir);
		mGenSprocRowset->Init(aConfigDir);

		// initialize the queries


		// step : run query that returns the list of principal tables in the system
		mPrincipalRowset->SetQueryTag("__GET_PRINCIPALS__");
		mPrincipalRowset->Execute();
		while(mPrincipalRowset->GetRowsetEOF().boolVal == VARIANT_FALSE) {

			// step : run query per principal that returns the list of extended property tables
			mEpTableRowset->ClearQuery();
			mEpTableRowset->SetQueryTag("__GET_EP_TABLES__");
			mEpTableRowset->AddParam("%%KIND%%",mPrincipalRowset->GetValue("id_principal"));
			mEpTableRowset->Execute();


			_bstr_t FromList;
			_bstr_t CaseList;
			_bstr_t ConditionClauses;

			// we should always go through this loop at least once because of t_base_props
			while(mEpTableRowset->GetRowsetEOF().boolVal == VARIANT_FALSE) {
				
				// step : run the stored procedure that generates the SQL case statement list for each extended property
				// table'
				_bstr_t aEpTableName = mEpTableRowset->GetValue("nm_ep_tablename");
				mGenSprocRowset->ClearQuery();
				mGenSprocRowset->SetQueryTag("__EXEC__GETCASELIST__");
				mGenSprocRowset->AddParam("%%TABLE_NAME%%",aEpTableName);
				mGenSprocRowset->Execute();

				// step : combine all the case statements into a unified query
				if(CaseList.length() != 0) {
					CaseList += ",";
				}
				CaseList += _bstr_t(mGenSprocRowset->GetValue(0l));

				// step : build the additional INNER JOIN where clauses
				mGenSprocRowset->ClearQuery();
				mGenSprocRowset->SetQueryTag("__BUILD_ADDITIONAL_WHERE_CLAUSES_");
				mGenSprocRowset->AddParam("%%TABLENAME%%",aEpTableName);
				ConditionClauses += mGenSprocRowset->GetQueryString();

				// step : build the from list
				mGenSprocRowset->ClearQuery();
				mGenSprocRowset->SetQueryTag("__BUILD_ADDITIONAL_FROM_CLAUSES_");
				mGenSprocRowset->AddParam("%%TABLENAME%%",aEpTableName);
				FromList += mGenSprocRowset->GetQueryString();

				mEpTableRowset->MoveNext();
			}
			_bstr_t aSprocName = mPrincipalRowset->GetValue("nm_inherit_sprocname");
			// step : drop the stored procedure
			
			mGenSprocRowset->ClearQuery();
			mGenSprocRowset->SetQueryTag("__DROP_EP_PROC__");
			mGenSprocRowset->AddParam("%%SPROC_NAME%%",aSprocName);
			// we don't care if this fails or not
			try {
				mGenSprocRowset->Execute();
			}
			catch(_com_error&) {

				mLogger.LogVarArgs(LOG_INFO,"Ignoring failure in dropping stored procedure %s",(const char*)aSprocName);
			}

			// step : create the stored procedure
			mGenSprocRowset->ClearQuery();
			mGenSprocRowset->SetQueryTag("__CREATE__TEMPLATEMATCH_QUERY__");
			mGenSprocRowset->AddParam("%%PROC_NAME%%",aSprocName);
			mGenSprocRowset->AddParam("%%SELECT_LIST%%",CaseList);
			mGenSprocRowset->AddParam("%%EXTRA_FROM_LIST%%",FromList);
			mGenSprocRowset->AddParam("%%EXTRA_WHERE_CLAUSES%%",ConditionClauses);
			mGenSprocRowset->Execute();

			mPrincipalRowset->MoveNext();
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

