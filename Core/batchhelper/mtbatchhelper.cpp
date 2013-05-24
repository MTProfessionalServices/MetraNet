/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#include <mtbatchhelper.h>


ROWSETLib::IMTRowSetPtr MTBatchHelper::PerformBatchOperation(IMTCollection* pCol,IMTProgress* pProgress)
{

  // initialize the smart pointers
	mColPtr = pCol;
  mProgressPtr = pProgress;
	//HRESULT hr;

  if(errorRs == NULL) {
    errorRs.CreateInstance(__uuidof(ROWSETLib::MTSQLRowset));
  }
  errorRs->InitDisconnected();
  errorRs->AddColumnDefinition("id_acc","int32",4);
  errorRs->AddColumnDefinitionByType("accountname",adBSTR,256);
  errorRs->AddColumnDefinitionByType("description",adVarChar,256);
  errorRs->OpenDisconnected();

	// get the base rowset back


	long size = mColPtr->GetCount();
	for(int i=1;i<= size;i++) {
    if(mProgressPtr != NULL)
		  mProgressPtr->SetProgress(i,size);
    long FailedAccountID;
    try{
      PerformSingleOp(i,FailedAccountID);
    }
    catch(_com_error& e){
			errorRs->AddRow();
			errorRs->AddColumnData("id_acc",FailedAccountID);
			errorRs->AddColumnData("description",(_variant_t)e.Description());
		}
	}
  if(errorRs->GetRecordCount() != 0) {
		errorRs->MoveFirst();
    ResolveAccountNames();
	}

  return errorRs;
}

void MTBatchHelper::ResolveAccountNames()
{

  if(errorRs->GetRecordCount() == 0) {
		// nothing to do
		return;
	}

  // sort the errors by account ID
  errorRs->Sort("id_acc",ROWSETLib::SORT_ASCENDING);


	ROWSETLib::IMTSQLRowsetPtr resolveRS(__uuidof(ROWSETLib::MTSQLRowset));
	resolveRS->Init(ACC_HIERARCHIES_QUERIES);
	resolveRS->SetQueryTag("__RESOLVE_FAILED_ACCOUNTS__");

	errorRs->MoveFirst();
	_bstr_t inStr;
	long count = errorRs->GetRecordCount();
	for(int i=0;i< count;i++) {
		
		inStr += _bstr_t(errorRs->GetValue("id_acc"));
		if(i + 1 != count) {
			inStr += ",";
		}
		errorRs->MoveNext();
	}
	resolveRS->AddParam("%%RESOLVEIDS%%",inStr);
	resolveRS->Execute();

	errorRs->MoveFirst();
	for(i=0;i<resolveRS->GetRecordCount();i++) {
		errorRs->ModifyColumnData("accountname",resolveRS->GetValue("displayname"));
		errorRs->MoveNext();
		resolveRS->MoveNext();
	}
	errorRs->MoveFirst();

}
