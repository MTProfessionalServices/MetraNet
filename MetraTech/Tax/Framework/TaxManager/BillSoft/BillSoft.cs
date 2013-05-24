//=============================================================================
// Copyright 1997-2012 by MetraTech
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
// REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
// OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
// INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
// RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech, and USER
// agrees to preserve the same.
//
//-----------------------------------------------------------------------------
// AUTHOR: Joseph Barnett
// MODULE: BillSoft.cs
// DESCRIPTION: Implements the BillSoft Tax Vendor Layer Interface
//
// TODO:
//
//=============================================================================

#region

using System;
using System.IO;
using System.Collections.Generic;

using MetraTech.Interop.RCD;
using MetraTech.Tax.Framework;
using MetraTech.Tax.Framework.DataAccess;

#endregion

namespace MetraTech.Tax.Framework.MtBillSoft
{
    public class BillSoftSyncTaxManagerDBBatch : SyncTaxManagerBatchDb
    {
        public static Logger mLogger = new Logger("[TaxManager.BillSoft.SyncTaxManagerDBBatch]");
        private readonly BillSoftConfiguration mConfig;
        private Boolean mBillHelperCreated;
        private BillSoftHelper mBillSoft;

        public BillSoftSyncTaxManagerDBBatch()
        {
            mBillHelperCreated = false;
            try
            {
                IMTRcd rcd = new MTRcd();
                mConfig = new BillSoftConfiguration(Path.Combine(rcd.ExtensionDir, @"BillSoft\config\BillSoftPathFile.xml"));
                mBillHelperCreated = false;
            }
            catch (Exception ex)
            {
                mLogger.LogException("BillSoftSyncTaxManagerDBBatch init error", ex);
                throw ex;
            }
        }

#if false
    public BillSoftSyncTaxManagerDBBatch(int runId, Boolean isAuditingNeeded, Boolean taxDetailsNeeded)
    {
      mBillHelperCreated = false;
      try
      {
        mLogger.LogTrace("Constructor called");
        IMTRcd rcd = new MTRcd();
        mConfig = new BillSoftConfiguration(Path.Combine(rcd.ExtensionDir, @"BillSoft\config\BillSoftPathFile.xml"));
        TaxRunId = runId;
        TaxDetailsNeeded = taxDetailsNeeded;
        IsAuditingNeeded = isAuditingNeeded;
        CreateBillSoftHelper();
      }
      catch (Exception ex)
      {
        mLogger.LogException("BillSoftSyncTaxManagerDBBatch init error", ex);
        throw ex;
      }
    }
#endif
        private void CreateBillSoftHelper()
        {
            // If taxRunId not set, and exception will be thrown. Push it up stack
            mBillSoft = new BillSoftHelper(mConfig, TaxRunId, IsAuditingNeeded,
                                            TaxDetailsNeeded, GetInputTaxTableName(),
                                            GetOutputTaxTableName(), MaximumNumberOfErrors);
            mBillSoft.InfoMethod += ReportInfo;
            mBillSoft.WarningMethod += ReportWarning;
            mBillSoft.ProgressMethod += ReportProgress;

            mBillHelperCreated = true;
        }

        /// <summary>
        /// Calculate taxes for a single transaction.  Before calling this, make sure
        /// you have set: (1) TaxRunID, (2) IsAuditingNeeded, (3) TaxDetailsNeeded,
        /// (4) have filled inRow with the transaction.
        /// </summary>
        /// <param name="inRow">an input row filled with transaction to tax.</param>
        /// <param name="outRow">an output row is allocated and filled with results.</param>
        /// <param name="detailRows">a list is allocated.  If TaxDetailsNeeded, filled with results.</param>
        public override void CalculateTaxes(TaxableTransaction inRow,
                                            out TransactionTaxSummary outRow,
                                            out List<TransactionIndividualTax> detailRows)
        {
            mBillSoft.CalculateTaxes(inRow, out outRow, out detailRows);
        }

        public override void CalculateTaxes()
        {
            if (!mBillHelperCreated) CreateBillSoftHelper();
            mLogger.LogTrace("CalculateTaxes invoked");
            mBillSoft.CalculateTaxes();
        }

        protected override void RollbackVendorAudit()
        {
            if (!mBillHelperCreated) CreateBillSoftHelper();
            mLogger.LogTrace("RollbackVendorAudit invoked");
            mBillSoft.RollbackVendorAudit();
        }
    }
}
