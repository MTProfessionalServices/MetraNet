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
#include <metra.h>
#include <propids.h>
#include <mtprogids.h>
#include <autoptr.h>
#include <DBSQLRowset.h>
#include <MSIX.h>
#include "OdbcBatchIDWriter.h"
#include "OdbcConnection.h"
#include "OdbcConnMan.h"
#include "OdbcStatementGenerator.h"
#include "OdbcSessionMapping.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcException.h"
#include "OdbcStatement.h"
#include "OdbcSessionTypeConversion.h"
#include <mttime.h>
#include <RowsetDefs.h>
#import <rowsetinterfaceslib.tlb> rename ("EOF", "RowsetEOF") // no_namespace

_COM_SMARTPTR_TYPEDEF(ITransaction, IID_ITransaction);

COdbcBatchIDWriter::COdbcBatchIDWriter(const COdbcConnectionInfo & info)
    : 
#ifdef USE_BATCH_SUMMARY_TEMP_TABLE 
        mBatchInsertStatement(NULL),
        mpStatement(NULL)
#endif
{ 
#ifdef USE_BATCH_SUMMARY_TEMP_TABLE 
  mStagingDBName = COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalog();
  mpConnection = new COdbcConnection(info);
#endif
}


COdbcBatchIDWriter::~COdbcBatchIDWriter()
{
    Clear();
}

void COdbcBatchIDWriter::Clear()
{
#ifdef USE_BATCH_SUMMARY_TEMP_TABLE 
    delete mBatchInsertStatement;
    mBatchInsertStatement = NULL;
    delete mpStatement;
    mpStatement = NULL;
  delete mpConnection;
  mpConnection = NULL;
#endif
}

#ifdef USE_BATCH_SUMMARY_TEMP_TABLE 

void COdbcBatchIDWriter::CreateTempTable()
{
    // only create a temp table on SQL server

    if (mpConnection->GetConnectionInfo().GetDatabaseType()
            != COdbcConnectionInfo::DBTYPE_ORACLE)
    {
        mIsOracle = FALSE;
        if (mpStatement == NULL)
            mpStatement = mpConnection->CreateStatement();

        mpStatement->ExecuteUpdate(
            "if object_id('" + mStagingDBName + "..t_batch_summary_stage') is null "
      "create table " + mStagingDBName + "..t_batch_summary_stage "
            "( "
            "   tx_batch varbinary (16) NOT NULL, "
            " tx_batch_encoded varchar(24) NOT NULL, "
            "   n_completed int not null "
            ")");
    }
    else
        mIsOracle = TRUE;
}

void COdbcBatchIDWriter::CreateBatchSummaryInsertStatement(
    int aMaxArraySize /* = 100 */)
{
    mBatchInsertMaxArraySize = aMaxArraySize;

    // we must prepare the statement
    if (mpConnection->GetConnectionInfo().GetDatabaseType()
            == COdbcConnectionInfo::DBTYPE_ORACLE)
    {
        mIsOracle = TRUE;
        mBatchSummaryTable = "t_batch_summary";
        mBatchInsertStatement =
            mpConnection->PrepareInsertStatement(mBatchSummaryTable, aMaxArraySize);
    }
    else
    {
        mIsOracle = FALSE;
        mBatchSummaryTable = mStagingDBName + "..t_batch_summary_stage";
        mBatchInsertStatement =
            mpConnection->PrepareStatement("insert into " + mBatchSummaryTable + " (tx_batch, tx_batch_encoded, n_completed) values(?, ?, ?)",
                                                                         aMaxArraySize);
    }

    if (mpStatement == NULL)
        mpStatement = mpConnection->CreateStatement();

    ASSERT(mpStatement);

}
#endif

void COdbcBatchIDWriter::WriteBatchIDs(const std::map<std::wstring, int> & arBatchCountMap)
{

#ifdef USE_BATCH_SUMMARY_TEMP_TABLE 

    InsertCounts(arBatchCountMap);

    _variant_t varSystemDate = GetMTTimeForDB();
    std::string dateBuffer = (const char *) _bstr_t(varSystemDate);

    if (mIsOracle)
    {
        mpStatement->ExecuteUpdate("BEGIN LOCK TABLE t_batch IN EXCLUSIVE MODE;"
                                                            "insert into t_batch (tx_batch, tx_batch_encoded, tx_status, n_completed, n_failed, dt_first, dt_crt) "
                                                             " select tx_batch, tx_batch_encoded, 'A', 0, 0, " + dateBuffer + ", " + dateBuffer + " from " + mBatchSummaryTable +
                                                             " where tx_batch not in (select tx_batch from t_batch); "
                                                             "END;"
                                                             );


        mpStatement->ExecuteUpdate("update t_batch "
                                                             " set (n_completed,dt_first, tx_status, dt_last) = "
                                                             " select "
                                                             " t_batch.n_completed + summ.n_completed,  "
                                                             " case when t_batch.dt_first is null then " + dateBuffer + " else t_batch.dt_first end, "
                                                             " case when t_batch.tx_status = 'A' and (t_batch.n_completed + summ.n_completed) >= t_batch.n_expected then 'C' else t_batch.tx_status end, "
                                                             " " + dateBuffer +
                                                             " from " + mBatchSummaryTable + " summ"
                                                             " where t_batch.tx_batch = summ.tx_batch "
                                                             ")"
                                                             " where tx_batch in "
                                                             " (select tx_batch from t_batch_summary)");

    }
    else
    {
        mpStatement->ExecuteUpdate("insert into t_batch (tx_batch, tx_batch_encoded, tx_status, n_completed, n_failed, dt_first, dt_crt) "
                                                             "select tx_batch, tx_batch_encoded, 'A', 0, 0, " + dateBuffer + ", " + dateBuffer + " from " + mBatchSummaryTable +
                                                             " where tx_batch not in (select tx_batch from t_batch WITH(UPDLOCK))");

        mpStatement->ExecuteUpdate("update t_batch "
                                                             " set t_batch.n_completed = t_batch.n_completed + summ.n_completed, "
                                                             "     t_batch.dt_first = case when t_batch.dt_first is null then " + dateBuffer + " else t_batch.dt_first end, "
                                                             "     t_batch.tx_status = case when t_batch.tx_status = 'A' and (t_batch.n_completed + summ.n_completed) >= t_batch.n_expected then 'C' else t_batch.tx_status end, "
                                                             "     t_batch.dt_last = " + dateBuffer +
                                                             " from " + mBatchSummaryTable + " summ"
                                                             " where t_batch.tx_batch = summ.tx_batch ");
    }

#else

    std::map<std::wstring, int>::const_iterator it;
    int i = 0;

    for (it = arBatchCountMap.begin(); it != arBatchCountMap.end(); it++)
    {
        const std::wstring & id = it->first;
        long count = it->second;

        // --- increment n_completed of t_batch for batchUID using sproc ---
        rowset->InitializeForStoredProc("UpdateBatchStatus");

        // --- pass in batchUID as safeArray ---

        // decodes the UID back to binary 
        unsigned char batchUID[DB_UID_SIZE];
        MSIXUidGenerator::Decode(batchUID, WideStringToString(id.c_str()));

        // create safe array
        SAFEARRAYBOUND sabound[1] ;
        sabound[0].lLbound = 0 ;
        sabound[0].cElements = DB_UID_SIZE;
        SAFEARRAY * pSA = SafeArrayCreate (VT_UI1, 1, sabound);
        if (pSA == NULL)
            throw COdbcException("Unable to create safe arrary");

        // set uidData to the contents of the safe array ...
      unsigned char * uidData;
        ::SafeArrayAccessData(pSA, (void **)&uidData);
  
        // put the uid into the safe array ...
        memcpy(uidData, batchUID, DB_UID_SIZE);
  
        // Release lock on safe array
        ::SafeArrayUnaccessData(pSA);

        // assign the safe array to the variant ...
        _variant_t vtValue;
        vtValue.vt = (VT_ARRAY | VT_UI1);
        vtValue.parray = pSA ;
        rowset->AddInputParameterToStoredProc ( "a_tx_batch", MTTYPE_VARBINARY, INPUT_PARAM, vtValue);

        // --- pass in n_completed ---
        vtValue = count;
        rowset->AddInputParameterToStoredProc ( "a_n_completed", MTTYPE_INTEGER, INPUT_PARAM, vtValue);
    
        // -- execute it
        rowset->ExecuteStoredProc();

    }
#endif

}

void COdbcBatchIDWriter::InsertCounts(
    const std::map<std::wstring, int> & arCounts)
{
    // truncate batch summary table first to have a clean table to start with
    if (mIsOracle)
    {
        // on Oracle: truncate table within a DTC txn causes:
        //  [Oracle][ODBC][Ora]ORA-02089: COMMIT is not allowed in a subordinate session
        // so do a delete from instead:
        mpStatement->ExecuteUpdate("DELETE FROM " + mBatchSummaryTable);
    }
    else
        mpStatement->ExecuteUpdate("TRUNCATE TABLE " + mBatchSummaryTable);

    
    std::map<std::wstring, int>::const_iterator it;
    int i = 0;
    for (it = arCounts.begin(); it != arCounts.end(); it++)
    {
        const std::wstring & id = it->first;
        int count = it->second;

        // decodes the UID back to binary 
        unsigned char batchUID[16];
        std::string asciiID = WideStringToString(id.c_str());
        MSIXUidGenerator::Decode(batchUID, asciiID);

        mBatchInsertStatement->SetBinary(1, batchUID, 16);
        mBatchInsertStatement->SetString(2, asciiID);
        mBatchInsertStatement->SetInteger(3, count);
        mBatchInsertStatement->AddBatch();

        i++;
        if (i == mBatchInsertMaxArraySize)
        {
            mBatchInsertStatement->ExecuteBatch();
            mBatchInsertStatement->BeginBatch();
            i = 0;
        }
    }

    // if nothing needs to be done this call will just return
    mBatchInsertStatement->ExecuteBatch();
}

void COdbcBatchIDWriter::WriteBatchID(const std::wstring batchUidStrWide)
{
   std::string batchUidStr;
   ::WideStringToUTF8(batchUidStrWide, batchUidStr);

   // Decode the UID back to binary 
   unsigned char batchUID[DB_UID_SIZE];
   if (!MSIXUidGenerator::Decode(batchUID, batchUidStr))
   {
     throw COdbcException("Unable to decode the given batch ID.");
   }

   // Store the batch UID in an argument that can be passed
   // to a stored procedure.
   SAFEARRAYBOUND sabound[1] ;
   sabound[0].lLbound = 0;
   sabound[0].cElements = DB_UID_SIZE;
   SAFEARRAY * pSA = SafeArrayCreate (VT_UI1, 1, sabound);

   if (pSA == NULL)
   {
     throw COdbcException("Unable to create safe arrary");
   }

   // Set uidData to the contents of the safe array.
   unsigned char * uidData;
   ::SafeArrayAccessData(pSA, (void **)&uidData);
  
   // Put the uid into the safe array.
   memcpy(uidData, batchUID, DB_UID_SIZE);
  
   // Release lock on safe array
   ::SafeArrayUnaccessData(pSA);

   // Assign the safe array to the variant.
   _variant_t vtValue;
   vtValue.vt = (VT_ARRAY | VT_UI1);
   vtValue.parray = pSA ;

   // Prepare the stored procedure and execute
   RowSetInterfacesLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
   rowset->Init("queries\\MTBatch");
   rowset->InitializeForStoredProc("UpdateBatchStatus");

   rowset->AddInputParameterToStoredProc("tx_batch",         MTTYPE_VARBINARY, INPUT_PARAM, vtValue);
   rowset->AddInputParameterToStoredProc("tx_batch_encoded", MTTYPE_VARCHAR,   INPUT_PARAM, batchUidStr.c_str());
   rowset->AddInputParameterToStoredProc("n_completed",      MTTYPE_INTEGER,   INPUT_PARAM, 0);
   rowset->AddInputParameterToStoredProc("sysdate",          MTTYPE_DATE,INPUT_PARAM,GetMTOLETime());
    
   rowset->ExecuteStoredProc();
}

class AutoTransactionJoin
{
private:
  COdbcConnection * mpConnection;
public:
  AutoTransactionJoin(COdbcConnection * conn, MTPipelineLib::IMTTransactionPtr apTran)
    :
    mpConnection(conn)
  {
    IUnknownPtr unknownTxn = apTran->GetTransaction();
    ITransactionPtr txn = unknownTxn;
    if (txn == NULL)
    {
      throw COdbcException("Failure getting ITransaction from IMTTransaction");
    }
    mpConnection->JoinTransaction(txn.GetInterfacePtr());
  }
  ~AutoTransactionJoin()
  {
    mpConnection->LeaveTransaction();
  }
};

void COdbcBatchIDWriter::UpdateErrorCounts(
    const std::map<std::wstring, int> & arFailureCountMap,
  MTPipelineLib::IMTTransactionPtr apTran)
{
    InsertCounts(arFailureCountMap);

    _variant_t varSystemDate = GetMTTimeForDB();
    std::string dateBuffer = (const char *) _bstr_t(varSystemDate);

  AutoTransactionJoin tj(mpConnection, apTran);

    if (mIsOracle)
    {
        mpStatement->ExecuteUpdate("BEGIN LOCK TABLE t_batch IN EXCLUSIVE MODE;"
                                                            "insert into t_batch (id_batch,tx_namespace, tx_name, tx_batch, tx_batch_encoded, tx_status, n_completed, n_failed, n_expected, n_metered, dt_first, dt_crt) "
                                                             "select seq_t_batch.nextval,'pipeline', tx_batch_encoded, tx_batch, tx_batch_encoded, 'A', 0, 0, 0, 0, " + dateBuffer + ", " + dateBuffer + " from " + mBatchSummaryTable +
                                                             " where tx_batch not in (select tx_batch from t_batch);"
                                                             "END;"
                                                             );

        mpStatement->ExecuteUpdate("update t_batch "
                                                             " set (n_failed, dt_first, dt_last, tx_status) = "
                                                             "(SELECT "
                                                             "t_batch.n_failed + summ.n_completed, "
                                                             "case when t_batch.dt_first is null then " + dateBuffer + " else t_batch.dt_first end, "
                                                             " " + dateBuffer + ", "
                                                             // ESR-4575 MetraControl- failed batches have completed status. Corrected batches have failed status
                                                             // Added a condition to mark batches with failed transections as Failed
															 "case when UPPER(t_batch.tx_status) = 'A' and ((t_batch.n_failed + summ.n_completed) > 0) then 'F' when t_batch.tx_status = 'A' and (((t_batch.n_completed + summ.n_completed + t_batch.n_failed) = t_batch.n_expected) or "
                                                             "((t_batch.n_completed + summ.n_completed + t_batch.n_failed) = t_batch.n_metered)) then 'C' "
                                                             "when (t_batch.tx_status = 'A' and ((t_batch.n_completed + summ.n_completed + t_batch.n_failed) > t_batch.n_expected and t_batch.n_expected > 0) "
                                                             "or ((t_batch.n_completed + summ.n_completed + t_batch.n_failed) > t_batch.n_metered and t_batch.n_metered > 0)) "
                                                             "then 'F' "
                                                           "else t_batch.tx_status end "
                                                             " from " + mBatchSummaryTable + " summ "
                                                             " where t_batch.tx_batch = summ.tx_batch ) "
                                                             "WHERE tx_batch in ( select tx_batch from t_batch_summary)"
                                                             );
    }
    else
    {
        mpStatement->ExecuteUpdate("insert into t_batch (tx_namespace, tx_name, tx_batch, tx_batch_encoded, tx_status, n_completed, n_failed, n_expected, n_metered, dt_first, dt_crt) "
                                                             "select 'pipeline', tx_batch_encoded, tx_batch, tx_batch_encoded, 'A', 0, 0, 0, 0, " + dateBuffer + ", " + dateBuffer + " from " + mBatchSummaryTable +
                                                             " where tx_batch not in (select tx_batch from t_batch WITH(UPDLOCK))");

        mpStatement->ExecuteUpdate("update t_batch "
                                                             " set t_batch.n_failed = t_batch.n_failed + summ.n_completed, "
                                                             "     t_batch.dt_first = case when t_batch.dt_first is null then " + dateBuffer + " else t_batch.dt_first end, "
                                                             "     t_batch.dt_last = " + dateBuffer + ", "
                                                             "     t_batch.tx_status = "
                                                             // ESR-4575 MetraControl- failed batches have completed status. Corrected batches have failed status
                                                             // Added a condition to mark batches with failed transections as Failed
                                                             "       case when t_batch.tx_status = 'A' and ((t_batch.n_failed + summ.n_completed) > 0) then 'F' when t_batch.tx_status = 'A' and (((t_batch.n_completed + summ.n_completed + t_batch.n_failed) = t_batch.n_expected) or "
                                                             "                                             ((t_batch.n_completed + summ.n_completed + t_batch.n_failed) = t_batch.n_metered)) then 'C' "
                                                             "       when (t_batch.tx_status = 'A' and ((t_batch.n_completed + summ.n_completed + t_batch.n_failed) > t_batch.n_expected and t_batch.n_expected > 0) "
                                                             "                or ((t_batch.n_completed + summ.n_completed + t_batch.n_failed) > t_batch.n_metered and t_batch.n_metered > 0)) "
                                                             " then 'F' "
                               "       else t_batch.tx_status end "
                                                             " from " + mBatchSummaryTable + " summ "
                                                             " where t_batch.tx_batch = summ.tx_batch ");
    }
}
