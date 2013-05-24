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
// MODULE: BillSoftHelper.cs
// DESCRIPTION: Implements the BillSoft Tax Vendor Layer Concrete Logic
//
// TODO: (Lots)
//  Correct Rounding
//  Network Failure detection/handling
//  Common Exception type cleanup and failure path handling (instead of exceptions)
//  Threading and Thread Safety
//  Concurrent Sessions and Data partitioning
//  Error isolation, splitting out errored entries
//  Resubmit or error records
//  Table updates for errored records
//=============================================================================

#region

using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using BillSoft.EZTaxNET;
using MetraTech.Tax.Framework.MtBillSoft;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.Tax.Framework.DataAccess;

#endregion

namespace MetraTech.Tax.Framework.MtBillSoft
{
    /// <summary>
    /// BillSoftHelper interfaces with the BillSoft EZTax interface.
    /// </summary>
    public class BillSoftHelper : IDisposable
    {
        private const string mConstDetailTableName = "t_tax_details";
        private const String mConstBillSoftQueryDir = @"Queries\Tax\BillSoft";
        private const String mConstDBInstallQueryDir = @"Queries\DBInstall\Tax";
        /// <summary>
        /// Logging interface
        /// </summary>
        public static Logger mLogger = new Logger("[TaxManager.BillSoft.BillSoftHelper]");

        #region C'tors and D'tor

        /// <summary>
        /// Creates a BillSoft Helper
        /// </summary>
        /// <param name="cfg">Configuration Helper Object</param>
        /// <param name="run_id">RunID for this instance (must match and t_tax_input_XXX where XXX is the ID.</param>
        /// <param name="isAuditingNeeded"></param>
        /// <param name="taxDetailsNeeded"></param>
        /// <param name="inputTable"></param>
        /// <param name="outputTable"></param>
        public BillSoftHelper(BillSoftConfiguration cfg, int run_id, bool isAuditingNeeded, bool taxDetailsNeeded,
                              string inputTable, string outputTable, int maximumNumberOfErrors)
        {
            mOverrideTableMissing = false;
            mErrorCount = 0;
            mMaximumNumberOfErrors = maximumNumberOfErrors;
            try
            {
                mConfig = cfg;
                mRunId = run_id;
                mIsAuditingNeeded = isAuditingNeeded;
                mTaxDetailsNeeded = taxDetailsNeeded;
                mOutTbl = outputTable;
                mInTbl = inputTable;

                //------------------------------------------------
                // Quick Sanity Check before allowing BillSoft execution
                // Lets see if the install is even there by testing for
                // one of the file paths.
                //------------------------------------------------
                if (!File.Exists(mConfig.EZTaxFilePaths.DLL)) // Test for the EZTax.dll binary.
                    throw new FileNotFoundException("BillSoft installation not found, has it been installed? Is the correct paths set in the BillSoft.xml configuration file?");
                var tmp = mConfig.EZTaxFilePaths.DLL;
                var path = tmp.Replace(@"Data\EZTax.dll", @"DLL\EZTax2.dll");
                mLogger.LogDebug("path={0}", path);
                var checker = new CompatibilityChecker(path);

                if (!checker.AreBinariesCompatible)
                {
                    throw new TaxException(String.Format("BillSoft installation is {0}-bit, which is not compatible with your MetraNet installation. Please update your BillSoft installation for correct operation.", (checker.Is32Bit) ? "32" : "64"));
                }
                mLogger.LogDebug("EZTax.dllversion={0}", EZTax.DllVersion);

                // Minimal Functional Check of BillSoft
                mLogger.LogInfo(String.Format("Loading the EZTax DLL Creation {2} Days Since {3} Version {0} Database version {1}", EZTax.DllVersion, EZTax.GetDatabaseVersion(mConfig.EZTaxFilePaths.Data), checker.LinkDate, (int)checker.DaysSinceCreation()));

                if (checker.IsOutOfDate)
                {
                    mLogger.LogWarning(String.Format("BillSoft installation is out of date, or soon will be. It is currently {0} days old. It was created on {1}. Please update your installation for correct operation.", (int)checker.DaysSinceCreation(), checker.LinkDate));
                }
                //------------------------------------------------
                // Cache containers
                //------------------------------------------------
                mExemptionsByAccount = new Dictionary<int, List<BillSoftExemption>>();
                mOverridesByAccount = new Dictionary<int, List<Override>>();
                //------------------------------------------------
                // EZTax Session Primary Interface
                // Fix up auditlog name first
                //------------------------------------------------
                // Incoming this shoudl be a path, confirm it is a directory
                mConfig.EZTaxFilePaths.Log = PrepareLogFileDirectoryAndPath(mConfig.LogPrefix, mConfig.EZTaxFilePaths.Log, mRunId);
                mSession = new EZTaxSession(mIsAuditingNeeded, mConfig.EZTaxFilePaths);
            }
            catch (EZTaxException ex)
            {
                string msg = String.Format("BillSoft Reported {0} Error Code {1}. There seems to be a problem with your BillSoft Installation, if installed please see file {2} for more detail on error.", ex.Message, ex.ErrorCode, mConfig.EZTaxFilePaths.Status);
                mLogger.LogException(msg, ex);
                throw new TaxException(msg);
            }
            catch (Exception ex)
            {
                mLogger.LogException("BillSoft Helper Exception caught during initialization", ex);
                throw ex;
            }
        }


        /// <summary>
        /// Destructor
        /// </summary>
        ~BillSoftHelper()
        {
        }

        #endregion // Constuctors

        #region IDisposable Implementation

        /// <summary>
        /// Public disposable implementation
        /// </summary>
        public void Dispose()
        {
            DisposeBillSoftSession();
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Internal disposal and cleanup
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void DisposeBillSoftSession()
        {
            if (mSession == null)
                return;

            mSession.Dispose();
            mSession = null;
        }

        #endregion // IDisposable Implementation

        #region Public Methods

        public void RollbackVendorAudit()
        {
            if (mSession != null)
            {
                mSession.Dispose();
                mSession = null;
            }

            // Force the collection otherwise 
            // we get a file help by process exception.
            GC.Collect();

            // To rollback in BillSoft means to only delete the runId log file
            // On init of the class instance, the Logfile name was set);
            if (File.Exists(mConfig.EZTaxFilePaths.Log))
                File.Delete(mConfig.EZTaxFilePaths.Log);
        }

        private void InvokeReportEvent(ReportMethod function, string msg)
        {
            if (null != function)
                function(msg);

        }

        /// <summary>
        /// Calculate taxes for a single transaction.  Before calling this, make sure
        /// you have set: (1) TaxRunID, (2) IsAuditingNeeded, (3) TaxDetailsNeeded,
        /// (4) have filled inRow with the transaction.
        /// </summary>
        /// <param name="inRow">an input row filled with transaction to tax.</param>
        /// <param name="outRow">an output row is allocated and filled with results.</param>
        /// <param name="detailRows">a list is allocated.  If TaxDetailsNeeded, filled with results.</param>
        public void CalculateTaxes(TaxableTransaction inRow,
                                   out TransactionTaxSummary outRow,
                                   out List<TransactionIndividualTax> detailRows)
        {
            // This should never be the case, but make sure we have a billsoft session.
            if (null == mSession)
            {
                mSession = new EZTaxSession(mIsAuditingNeeded, mConfig.EZTaxFilePaths);
            }

            // We need to prepare to write the details and 
            // we need to load the product catalog map.
            mOutputDetailWriter = new TaxManagerBatchDbTableWriter(mConstDetailTableName, mConfig.NumPerBulkInsertBatch);
            mPCMapper = new ProductCodeMapper(mConstBillSoftQueryDir);
            mPCMapper.PopulateMappingDictionary();

            // Load exemptions and overrides 
            GetExemptionsEntries();
            GetOverrideEntries();

            CalculateTaxesForTransaction(inRow, out outRow, out detailRows);

            // TODO: We currently are NOT writing these details out to the database.
            // This should be changed to write out the details.
        }

        /// <summary>
        /// Before calling this, make sure: (1) you've initialized the tax detail writer (mOutputDetailWriter) and
        /// (2) loaded the product map (mPCMapper), (3) loaded exemptions and overrides
        /// </summary>
        /// <param name="inRow"></param>
        /// <param name="outRow"></param>
        /// <param name="detailRows"></param>
        private void CalculateTaxesForTransaction(TaxableTransaction inRow,
                                                  out TransactionTaxSummary outRow,
                                                  out List<TransactionIndividualTax> detailRows)
        {
            long id_tax_charge;
            int id_acc;
            int id_usage_interval;
            RoundingAlgorithm roundingAlgorithm;
            int roundingDigits;

            try
            {
                // Prepare a transaction for the calculation
                var trans = mSession.CreateTransaction();

                // Given an input tax row, load the values into the billsoft transaction.
                // If the taxable amount is negative, we assume this is an adjustment.
                var isAdjustment = LoadInputRowIntoBillSoftTransaction(trans, inRow);

                // Retrieve some values that we need from the tax input row.
                id_acc = inRow.GetInt32("id_acc").GetValueOrDefault();
                id_usage_interval = inRow.GetInt32("id_usage_interval").GetValueOrDefault();
                id_tax_charge = inRow.GetInt64("id_tax_charge").GetValueOrDefault();
                roundingAlgorithm = Rounding.GetAlgorithm(inRow.GetString("round_alg"));
                roundingDigits = inRow.GetInt32("round_digits").GetValueOrDefault();

                // Apply exemptions and overrides for the account.
                ApplyExemptions(id_acc, ref trans);
                ApplyOverrides(id_acc);

                // Set up whether we want logging or not.
                mSession.ReturnLogInfo = mIsAuditingNeeded;

                // Calculate taxes.
                var taxes = (isAdjustment) ? trans.CalculateAdjustments() : trans.CalculateTaxes();

                // We're going to take the calculated taxes and put them in a list.
                var taxList = new List<TaxData>();  // Hold list of billsoft data structure for taxes.
                if (null != taxes)
                {
                    mLogger.LogDebug(String.Format("BillSoft calculated {0} separate taxes for the transaction.", taxes.Length));
                    taxList.AddRange(taxes);
                }
                else
                {
                    mLogger.LogDebug("EZTax did not return any taxes for this transaction.");
                }

                // Write the audit for the calculated taxes.
                WriteAuditLog(taxList);

                // Construct the list we need to return containing the tax details rows.
                FillTaxDetailsList(id_tax_charge, id_acc, id_usage_interval, taxList, out detailRows);

                // Create the output row containing the aggregation of the individual charges.
                AggregateIntoTaxOutputRow(id_tax_charge, taxList, roundingAlgorithm, roundingDigits, out outRow);

                // Cleanup the session.
                mSession.ClearOverrides();
                mSession.ClearExclusions();
            }
            catch (EZTaxException ex)
            {
                mLogger.LogException("EZTaxException exception caught while calculating taxes. ", ex);
                throw;
            }
            catch (Exception ex)
            {
                mLogger.LogException("General exception caught while calculating taxes. ", ex);
                throw;
            }
        }

        /// <summary>
        /// Primary Calculation Interface. All input table entries are computed 
        /// for taxes and taxes are placed in the detail table and output tables.    
        /// 
        /// If exemptions or overrides exist, they are applied before the calculations.
        /// </summary>
        public void CalculateTaxes()
        {
            try
            {
                InvokeReportEvent(InfoMethod, "Creating tax output table.");
                TaxManagerBatchDbTableWriter.CreateOutputTable(mOutTbl);

                mInputReader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, mRunId, false);
                mOutputWriter = new TaxManagerBatchDbTableWriter(mOutTbl, mConfig.NumPerBulkInsertBatch);
                mOutputDetailWriter = new TaxManagerBatchDbTableWriter(mConstDetailTableName, mConfig.NumPerBulkInsertBatch);
                mPCMapper = new ProductCodeMapper(mConstBillSoftQueryDir);
                mPCMapper.PopulateMappingDictionary();

                // First get all exemptions and overrides 
                // before processing input table
                GetExemptionsEntries();
                GetOverrideEntries();

                TaxableTransaction inRow;
                Int64 calculationIterationCount = 0;

                InvokeReportEvent(InfoMethod, "Tax calculations beginning.");

                while (null != (inRow = mInputReader.GetNextTaxableTransaction()))
                {
                    try
                    {
                        TransactionTaxSummary outRow;
                        List<TransactionIndividualTax> detailRows;

                        // Given the input row, calculate the output row and the tax details.
                        CalculateTaxesForTransaction(inRow, out outRow, out detailRows);

                        // Tell the database tax detail writer about the detail rows (we actually commit this later)
                        WriteTaxDetails(detailRows);

                        // Tell the database tax output writer about the output row (we actually commit this later)
                        mOutputWriter.Add(outRow);

                        // Report how many transactions we processed so far
                        if (ProgressMethod != null)
                            ProgressMethod((int)++calculationIterationCount);
                    }

                    catch (EZTaxException ex)
                    {
                        mLogger.LogException("A BillSoft error occurred while calculating taxes. ", ex);
                        InvokeReportEvent(WarningMethod, "A BillSoft error occurred while calculating taxes.");

                        if (mMaximumNumberOfErrors < (++mErrorCount))
                            throw ex;

                        InvokeReportEvent(InfoMethod,
                          String.Format("errorCount={0} does not exceed MaximumNumberOfErrors={1}, continuing. ", mErrorCount, mMaximumNumberOfErrors));
                        continue;
                    }
                    catch (Exception ex)
                    {
                        mLogger.LogException("An error occured while calculating taxes. ", ex);
                        InvokeReportEvent(WarningMethod, "An error occured while calculating taxes.");

                        if (mMaximumNumberOfErrors < (++mErrorCount))
                            throw ex;

                        InvokeReportEvent(InfoMethod,
                          String.Format("errorCount={0} does not exceed MaximumNumberOfErrors={1}, continuing. ", mErrorCount, mMaximumNumberOfErrors));
                        continue;
                    }

                }
            }
            catch (EZTaxException ex)
            {
                mLogger.LogException("A BillSoft error occurred while calculating taxes. ", ex);
                throw ex;
            }
            catch (Exception ex)
            {
                mLogger.LogException("An error occurred while calculating taxes. ", ex);
                throw ex;
            }
            finally
            {
                //------------------------------------------------
                // Perform bulk persistence of details and output.
                //------------------------------------------------
                InvokeReportEvent(InfoMethod, "Persisting calculation beginning.");
                mInputReader.Close();
                mOutputDetailWriter.Commit(); // Commit the details
                mOutputWriter.Commit(); // Commit the output
                InvokeReportEvent(InfoMethod, "Persisting calculation complete.");
            }
        }
        #endregion

        #region Internal Private Methods
        /// <summary>
        /// Logs the taxes to the audit file.
        /// </summary>
        /// <param name="taxes"></param>
        private void WriteAuditLog(ICollection<TaxData> taxes)
        {
            if (!mIsAuditingNeeded || taxes.Count < 1) return;
            // Fill in the information to write to the log file

            mLogger.LogDebug("Writing sample data to the EZTax log file...");
            mSession.WriteToLog(taxes.Select(tax => new TaxLogData
            {
                PCode = tax.PCode,
                TaxType = tax.TaxType,
                TaxLevel = tax.TaxLevel,
                CalcType = tax.CalcType,
                TaxRate = tax.Rate,
                TaxAmount = tax.TaxAmount,
                SaleAmount = tax.TaxableMeasure,
                ExemptSaleAmount = tax.ExemptSaleAmount,
                Billable = tax.Billable,
                Compliance = tax.Compliance,
                Surcharge = tax.Surcharge,
                // The fields listed below are only returned with each tax calculation when the EZTaxSession's
                // returnLogInfo(boolean) method is invoked with a paremeter of true. Otherwise, only the fields 
                // listed above are returned, and the fields listed below will be either null or zero.
                RefundUncollect = tax.RefundUncollect,
                InvoiceNumber = tax.InvoiceNumber,
                ServiceLevelNumber = tax.ServiceLevelNumber,
                Optional = tax.Optional,
                Minutes = tax.Minutes,
                Lines = tax.Lines,
                Locations = tax.Locations,
                CustomerNumber = tax.CustomerNumber,
                CompanyIdentifier = tax.CompanyIdentifier,
                AdjustmentType = tax.AdjustmentType,
                ExemptionType = tax.ExemptionType,
                OptionalAlpha1 = tax.OptionalAlpha1,
                Optional4 = tax.Optional4,
                Optional5 = tax.Optional5,
                Optional6 = tax.Optional6,
                Optional7 = tax.Optional7,
                Optional8 = tax.Optional8,
                Optional9 = tax.Optional9,
                Optional10 = tax.Optional10
            }).ToArray());
            mLogger.LogDebug("Write to log successful.");
        }

        /// <summary>
        /// Consolidates the taxes into single row entry for output table
        /// where all the jusristiction taxes are consolidated to a single 
        /// jusrisdiction entry.
        /// </summary>
        /// <param name="id_tax_charge"></param>
        /// <param name="taxes"></param>
        /// <param name="addedCount"></param>
        private void AggregateIntoTaxOutputRow(long id_tax_charge, ICollection<TaxData> taxes, RoundingAlgorithm roundingAlgorithm, int roundingDigits, out TransactionTaxSummary row)
        {
            mLogger.LogDebug("Entered ConsolidateTaxes method ...");
            row = new TransactionTaxSummary()
            {
                TaxFedAmount = (decimal)0.0D,
                TaxStateAmount = (decimal)0.0D,
                TaxCountyAmount = (decimal)0.0D,
                TaxLocalAmount = (decimal)0.0D,
                TaxOtherAmount = (decimal)0.0D,
                TaxFedName = "",
                TaxStateName = "",
                TaxCountyName = "",
                TaxLocalName = "",
                TaxOtherName = "",
                IdTaxCharge = id_tax_charge
            };

            if (taxes == null || taxes.Count == 0)
            {
                mLogger.LogDebug("EZTax did not return any taxes for this transaction. We are not considering this an error.");
                return;
            }

            double nFedTaxHighest = double.MinValue;
            double nStateTaxHighest = double.MinValue;
            double nCountyTaxHighest = double.MinValue;
            double nLocalTaxHighest = double.MinValue;
            double nOtherTaxHighest = double.MinValue;

            uint jcode = 0;
            AddressData[] jaddr = null;
            //-------------------------------------------------------------------------------------------------------
            // If there are more than one type of tax, then tax_level will be consolidated to the highest tax amount.
            // For example, there are two state level taxes, MA $20.00 and NY $30.00 Then the state tax will be 
            // consolidated to NY with a total of $50.00. This situation, however, is very rare. 
            //-------------------------------------------------------------------------------------------------------
            foreach (var tax in taxes)
            {
                int nError = 0;
                //-------------------------------------------------------------------------------------------------------
                // Invoke EZTax API here to get the address for this j_code.
                // This API gives address of the jurisdiction code. Eventhough it returns array of addresses, for our purpose,
                // we can just access the first element of the array. They are all going to be the same except for zipcode information.
                // Since we do not want zipcode information here, we are ok to get the information we want from the first element of this
                // array.
                //-------------------------------------------------------------------------------------------------------
                if (0 == jcode) // Only set once
                {
                    jcode = mSession.PCodeToJCode(tax.PCode);
                    jaddr = mSession.GetAddress(jcode);

                    if (jaddr.Length == 0)
                    {
                        mLogger.LogError(
                          "Can't get the Address from JCode!. EZTax returned error ({0}). Cannot set tax level jurisdictions.",
                          nError);
                        throw new TaxException(String.Format("Can't get the Address from JCode!. EZTax returned error ({0}). Cannot set tax level jurisdictions.",
                          nError));
                    }
                }

                //------------------------------------------------
                // Federal Consolidation
                //------------------------------------------------
                if (tax.TaxLevel == TaxLevel.Federal)
                {
                    if (tax.TaxAmount > nFedTaxHighest)
                    {
                        nFedTaxHighest = tax.TaxAmount;
                        if (jaddr != null) row.TaxFedName = GetNameOrDefault(tax.PCode, jaddr[0].CountryISO);
                    }
                    if (tax.Billable) row.TaxFedAmount += (decimal)tax.TaxAmount;
                }
                //------------------------------------------------
                // State Consolidation
                //------------------------------------------------
                if (tax.TaxLevel == TaxLevel.State)
                {
                    if (tax.TaxAmount > nStateTaxHighest)
                    {
                        nStateTaxHighest = tax.TaxAmount;
                        if (jaddr != null) row.TaxStateName = GetNameOrDefault(tax.PCode, jaddr[0].State);
                    }
                    if (tax.Billable) row.TaxStateAmount += (decimal)tax.TaxAmount;
                }
                //------------------------------------------------
                // County Consolidation
                //------------------------------------------------
                if (tax.TaxLevel == TaxLevel.County)
                {
                    if (tax.TaxAmount > nCountyTaxHighest)
                    {
                        nCountyTaxHighest = tax.TaxAmount;
                        if (jaddr != null) row.TaxCountyName = GetNameOrDefault(tax.PCode, jaddr[0].County);
                    }
                    if (tax.Billable) row.TaxCountyAmount += (decimal)tax.TaxAmount;
                }
                //------------------------------------------------
                // Local Consolidation
                //------------------------------------------------
                if (tax.TaxLevel == TaxLevel.Local)
                {
                    if (tax.TaxAmount > nLocalTaxHighest)
                    {
                        nLocalTaxHighest = tax.TaxAmount;
                        if (jaddr != null) row.TaxLocalName = GetNameOrDefault(tax.PCode, jaddr[0].Locality);
                    }
                    if (tax.Billable) row.TaxLocalAmount += (decimal)tax.TaxAmount;
                }
                //------------------------------------------------
                // Other Consolidation
                //------------------------------------------------
                if (tax.TaxLevel != TaxLevel.Other) continue;
                if (tax.TaxAmount > nOtherTaxHighest)
                {
                    nOtherTaxHighest = tax.TaxAmount;
                    if (jaddr != null) row.TaxOtherName = GetNameOrDefault(tax.PCode, jaddr[0].ZipBegin + "-" + jaddr[0].ZipEnd);
                }
                if (tax.Billable) row.TaxOtherAmount += (decimal)tax.TaxAmount;
            } /* foreach */

            row.TaxFedRounded = Rounding.Round(row.TaxFedAmount.GetValueOrDefault(), roundingAlgorithm, roundingDigits);
            row.TaxStateRounded = Rounding.Round(row.TaxStateAmount.GetValueOrDefault(), roundingAlgorithm, roundingDigits);
            row.TaxCountyRounded = Rounding.Round(row.TaxCountyAmount.GetValueOrDefault(), roundingAlgorithm, roundingDigits);
            row.TaxLocalRounded = Rounding.Round(row.TaxLocalAmount.GetValueOrDefault(), roundingAlgorithm, roundingDigits);
            row.TaxOtherRounded = Rounding.Round(row.TaxOtherAmount.GetValueOrDefault(), roundingAlgorithm, roundingDigits);
            mLogger.LogDebug("Exiting ConsolidateTaxes method with success return code...");
        }

        /// <summary>
        /// Helper to get the name of creates a default entry.
        /// </summary>
        /// <param name="pcode"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        private static string GetNameOrDefault(uint pcode, string name)
        {
            if (String.IsNullOrEmpty(name) || name == "-")
                return String.Empty;
            return name;
        }

        /// <summary>
        /// Given calculated BillSoft taxes, create an output list of
        /// tax details rows suitable for later writing to the tax details
        /// output table.
        /// </summary>
        /// <param name="id_tax_charge"></param>
        /// <param name="id_acc"></param>
        /// <param name="id_usage_interval"></param>
        /// <param name="taxes"></param>
        /// <param name="taxDetails"></param>
        private void FillTaxDetailsList(long id_tax_charge, int id_acc, int id_usage_interval, ICollection<TaxData> taxes, out List<TransactionIndividualTax> taxDetails)
        {
            taxDetails = new List<TransactionIndividualTax>();

            var now = DateTime.Now;

            foreach (var row in taxes.Select(entry => new TransactionIndividualTax
            {
                DateOfCalc = now,
                IdTaxRun = mRunId,
                IdAcc = id_acc,
                IdUsageInterval = id_usage_interval,
                IdTaxCharge = id_tax_charge,
                IdTaxDetail = mGlobalDetailId++,
                TaxAmount = (decimal)entry.TaxAmount,
                Rate = (decimal)entry.Rate,
                IsImplied =
                  (entry.Billable) ? false : true,
                TaxJurLevel =
                  (int)BillSoftConstantConverter.GetTaxLevel(entry.TaxLevel),
                TaxJurName =
                  BillSoftConstantConverter.GetEZTaxLevel(entry.TaxLevel),
                TaxType = (int)(entry.TaxType),
                TaxTypeName =
                  BillSoftConstantConverter.GetEZTaxType(entry.TaxType)
            }))
            {
                taxDetails.Add(row);
            }
        }

        /// <summary>
        /// Given a list of tax details, add them to the mOutputDetailWriter for
        /// later writing.  You must ultimately tell the mOutputDetailWriter to
        /// commit these changes.
        /// </summary>
        /// <param name="taxDetails"></param>
        private void WriteTaxDetails(List<TransactionIndividualTax> taxDetails)
        {
            // Add to tax details to be written.
            if (mTaxDetailsNeeded)
            {
                foreach (TransactionIndividualTax detailRow in taxDetails)
                {
                    mOutputDetailWriter.Add(detailRow);
                }
            }
        }

        #endregion

        #region Input Table Row Parsing

        /// <summary>
        /// Fills a Transaction object with sample transaction data.
        /// </summary>
        /// <param name="transaction">Transaction object.</param>
        /// <param name="row"></param>
        /// <returns>True if the amount is negative.</returns>
        private bool LoadInputRowIntoBillSoftTransaction(Transaction transaction, TaxableTransaction row)
        {
            mLogger.LogDebug("Loading BillSoft transaction.");

            bool isAdjustment = false;

            // Bill-to jurisdiction must always be specified.
            // The origination and termination jurisdictions are
            // optional, but if one of them is entered, all three
            // jurisdictions must be specified as well.
            transaction.BillToPCode = GetPCode(ref row, "svc_addr_pcode");
            if (0 == transaction.BillToPCode)
                throw new TaxException("svc_addr_pcode must be set. Cannot calculate taxes.");

            transaction.OriginationPCode = GetPCode(ref row, "orig_pcode");
            transaction.TerminationPCode = GetPCode(ref row, "term_pcode");

            /* Vendor PARAMETER TABLE */
            decimal amount = row.GetDecimal("amount").GetValueOrDefault();
            string product_code = row.GetString("product_code");
            int? transaction_type = row.GetInt32("transaction_type");
            int? service_type = row.GetInt32("service_type");
            int id_tax_charge = row.GetInt32("id_tax_charge").GetValueOrDefault();

            string invoice_id = row.GetString("invoice_id");
            string customer_type = row.GetString("customer_type");
            DateTime invoice_date = row.GetDateTime("invoice_date").GetValueOrDefault(); //		date	null	Date of the invoice
            string is_implied_tax = row.GetString("is_implied_tax");
            string round_alg = row.GetString("round_alg");
            int round_digits = row.GetInt32("round_digits").GetValueOrDefault();
            int lines = row.GetInt32("lines").GetValueOrDefault();
            int locations = row.GetInt32("location").GetValueOrDefault();
            string client_resale = row.GetString("client_resale"); //		string	S	S-Sale, R-Resale
            string inc_code = row.GetString("inc_code"); //		string	I	Customer Inside or Outside incorporated area
            string is_regulated = row.GetString("is_regulated");
            decimal call_duration = row.GetDecimal("call_duration").GetValueOrDefault(); //		decimal	0	
            string svc_class_ind = row.GetString("svc_class_ind"); //		string	D	Long Distance or Local primary (D or L)
            string lifeline_flag = row.GetString("lifeline_flag"); //		string	I	L- lifeline customer, I - not lifeline
            string facilities_flag = row.GetString("facilities_flag"); //		string	N	facilities based flag (F or N)
            string franchise_flag = row.GetString("franchise_flag"); //		string	N	Franchise or Non-Franchise (F or N)
            string bus_class_ind = row.GetString("bus_class_ind"); //		string	C	Business class indicator (C-CLEC or I-ILEC)

            ProductMapping pcmap;

            // Hopefully, we have a service_type and a transaction_type from the
            // transaction.  If not, we are going to have to take the product code,
            // and look up the service_type and transaction_type.

            if (service_type.HasValue && transaction_type.HasValue)
            {
                mLogger.LogDebug("Using given BillSoft service type and transaction type.");
                pcmap = new ProductMapping();
                pcmap.product_code = product_code;
                pcmap.service_type = service_type.Value;
                pcmap.transaction_type = transaction_type.Value;
            }
            else
            {
                mLogger.LogDebug("Since we do not have a BillSoft service type and transaction type, " +
                                 "we will attempt to look up the product code in the BillSoft product code table.");
                pcmap = mPCMapper.GetProductCode(product_code);
            if (null == pcmap)
            {
                string msg =
                      String.Format("Unable to find Product Code {0} in product code mapping table. Unable to process tax transaction.",
                                product_code);
                mLogger.LogError(msg);
                throw new TaxException(msg);
            }
            }

            // Store the idTaxCharge into the optional field. 
            // Then it will get written to the billsoft log
            transaction.Optional = (uint)id_tax_charge;
            // TODO: extracted it, but the Billable Flag on the taxData is used. WHat do we need this for?
            bool isImplied = BillSoftConstantConverter.ConvertStringToBoolean(is_implied_tax);

            UInt32 invid;
            UInt32.TryParse(invoice_id, out invid);
            transaction.InvoiceNumber = invid;

            transaction.TransactionType = (short)pcmap.transaction_type;
            transaction.ServiceType = (short)pcmap.service_type;
            transaction.Charge = (double)EnsurePositiveAmount(amount, ref isAdjustment);
            transaction.Minutes = (double)call_duration;
            transaction.Date = invoice_date;

            transaction.Lifeline = BillSoftConstantConverter.LifeLine(lifeline_flag);
            transaction.Lines = lines;
            transaction.Locations = locations;

            transaction.BusinessClass = BillSoftConstantConverter.GetEZTaxBusinessClass(bus_class_ind);
            transaction.CustomerType = BillSoftConstantConverter.GetEZTaxCustomerType(customer_type);
            transaction.FacilitiesBased = BillSoftConstantConverter.Facilities(facilities_flag);
            transaction.Franchise = BillSoftConstantConverter.Franchise(franchise_flag);
            transaction.Incorporated = BillSoftConstantConverter.InsideCustomer(inc_code);

            transaction.Regulated = BillSoftConstantConverter.Regulated(is_regulated);
            transaction.Sale = BillSoftConstantConverter.ClientResale(client_resale);
            transaction.ServiceClass = BillSoftConstantConverter.ServiceClass(svc_class_ind);

            // TODO: What is the company ID?
            //transaction.CompanyIdentifier = "MetraTech";
            //transaction.CustomerNumber = "MetraTech Inc.";
            // TODO: Must this be set? What do we set it to?
            transaction.DiscountType = DiscountType.AccountLevel;
            return isAdjustment;
        }

        private static decimal EnsurePositiveAmount(decimal amount, ref bool isAdjustment)
        {
            if (amount >= 0)
                return amount;

            isAdjustment = true;
            return -(amount);
        }

        /// <summary>
        /// Simple helper to get pcode
        /// </summary>
        /// <param name="row"></param>
        /// <param name="fieldnm"></param>
        /// <returns></returns>
        private static UInt32 GetPCode(ref TaxableTransaction row, string fieldnm)
        {
            UInt32 pcode;
            try
            {
                pcode = (uint)row.GetInt32(fieldnm).GetValueOrDefault();
            }
            catch
            {
                pcode = 0;
            }
            return pcode;
        }
        #endregion

        #region Override Logic
        /// <summary>
        /// Adds an override to the account mapped override dictionary
        /// Not that if the override is global, it is added to the -1 Account ID.
        /// </summary>
        /// <param name="reader"></param>
        private void AddOverrideToOverrideMap(IMTDataReader reader)
        {
            var o = new Override
            {
                id_tax_override = reader.GetInt32("id_tax_override"),
                id_acc = reader.GetInt32("id_acc"),
                id_ancestor = reader.GetInt32("id_ancestor"),
                Pcode = reader.GetInt32("Pcode"),
                Scope = reader.GetInt32("Scope"),
                replace_jur = BillSoftConstantConverter.ConvertStringToBoolean(reader.GetString("replace_jur")),
                levelExempt = BillSoftConstantConverter.ConvertStringToBoolean(reader.GetString("levelExempt")),
                tax_rate = reader.GetDecimal("tax_rate"),
                maximum = reader.GetDecimal("maximum"),
                excess = reader.GetDecimal("excess"),
                tax_type = reader.GetInt32("tax_type"),
                // NOTE: Do we assume these are tax types specified by EZTax
                jur_level = (int)BillSoftConstantConverter.GetTaxLevel((TaxJurisdiction)reader.GetInt32("jur_level")),
                // NOTE: Do we assume these are tax level specified by EZTax
                effectiveDate = reader.GetDateTime("effectiveDate"),
                create_date = reader.GetDateTime("create_date"),
                update_date = reader.GetDateTime("update_date")
            };

            //---------------------------------------------------------------------------
            // PROCESSING RULES
            //---------------------------------------------------------------------------
            // ancestor account id.   
            // If -1, then does not apply, otherwise specifies that all 
            // accounts under this account should receive the override (inclusively).  
            // If id_ancestor AND id_acc is specified, then an error is logged 
            // and id_acc is ignored.
            if (IsSet(o.id_ancestor) && IsSet(o.id_acc))
            {
                // Both can't be set to something valid.
                var msg =
                  String.Format(
                    "Cannot have both id_ancestor and id_acc set for override. Please fix override entry at id_tax_override={0}",
                    o.id_tax_override);
                mLogger.LogError(msg);
                throw new TaxException(msg);
            }

            if (IsNotSet(o.id_ancestor) && IsNotSet(o.id_acc))
            {
                // Add to bucket which is for every account (ID == -1)
                AddToOverrideByAccount(-1, o);
            }
            else if (IsSet(o.id_ancestor))
            {
                GetAllAccountsForOverrideGroup(ref o);
            }
            else // Add account specific override
            {
                AddToOverrideByAccount(o.id_acc, o);
            }
        }
        /// <summary>
        /// Loops throught both account specific and global overrides and applies to 
        /// the session before tax calculation.
        /// </summary>
        /// <param name="id_acc"></param>
        private void ApplyOverrides(int id_acc)
        {
            // Check if there are any overrides
            if (mOverrideTableMissing ||
               (!mOverridesByAccount.ContainsKey(-1) &&
                !mOverridesByAccount.ContainsKey(id_acc)))
            {
                mLogger.LogDebug("There are no BillSoft overrides for account: " + id_acc);
                return;
            }

            var qualifiedOverrides = new List<Override>();

            // First get each override in the default bucket
            if (mOverridesByAccount.ContainsKey(-1))
                qualifiedOverrides.AddRange(mOverridesByAccount[-1]);

            if (mOverridesByAccount.ContainsKey(id_acc))
                qualifiedOverrides.AddRange(mOverridesByAccount[id_acc]);

            foreach (var theOverride in qualifiedOverrides)
            {
                string printableOverrideConfig = String.Format(
                     "Configured override: Override ID {0} Parent ID {1} Account ID {2} Jurisdiction {3} Scope {4} Pcode {5} Replace Jurisdiction {14} Level Exempt {13} Type {6} Rate {7} Maximum {11} Excess {12} Creation Date {8} Update Date {9} Effective Date {10}",
                    theOverride.id_tax_override, theOverride.id_ancestor, theOverride.id_acc, BillSoftConstantConverter.GetEZTaxLevel((TaxLevel)theOverride.jur_level),
                    BillSoftConstantConverter.GetEZTaxLevel((TaxLevel)theOverride.Scope),
                    theOverride.Pcode, BillSoftConstantConverter.GetEZTaxType((short)theOverride.tax_type),
                    theOverride.tax_rate, theOverride.create_date, theOverride.update_date, theOverride.effectiveDate, theOverride.maximum, theOverride.excess, theOverride.levelExempt, theOverride.replace_jur);
                mLogger.LogDebug("Attempting to add an override. " + printableOverrideConfig);

                if (theOverride.Pcode == 0)
                {
                    mLogger.LogError(
                      String.Format(
                        "Ignoring override {0} id_ancestor {1} id_acc {2} level_jur {3} is invalid because the PCode is 0.",
                        theOverride.id_tax_override, theOverride.id_ancestor, theOverride.id_acc, theOverride.jur_level));
                    continue;
                }

                mLogger.LogDebug("Constructing a new override.");

                // Get a list of all taxes for this jurisdiction
                TaxRateInfo[] taxRates = mSession.GetTaxRates((uint)theOverride.Pcode);
                TaxRateInfo taxRate = null;

                foreach (TaxRateInfo tax in taxRates)
                {
                    // Display the information for the State Sales Tax for this jurisdiction
                    if (tax.TaxLevel == (TaxLevel)theOverride.jur_level &&
                        tax.TaxType == (short)theOverride.tax_type &&
                        tax.Scope == (TaxLevel)theOverride.Scope)
                    {
                        taxRate = tax;
                    }
                }

                if (null == taxRate)
                {
                    mLogger.LogInfo(
                      String.Format(
                        "No tax rate info match found for pcode {0} level {1} type {2}, creating a new one",
                        theOverride.Pcode,
                        ((TaxJurisdiction)theOverride.jur_level).ToTaxTypeName(),
                        BillSoftConstantConverter.GetEZTaxType((short)theOverride.tax_type)));

                    taxRate = new TaxRateInfo
                    {
                        Scope = (TaxLevel)theOverride.Scope,
                        TaxLevel = (TaxLevel)theOverride.jur_level,
                        TaxType = (short)theOverride.tax_type
                    };
                }

                mLogger.LogDebug("Setting these override values: tax level: " + taxRate.TaxLevel +
                                 " tax type: " + taxRate.TaxType +
                                 " tax scope: " + taxRate.Scope);

                var historyRecord = new TaxRateHistory { EffectiveDate = theOverride.effectiveDate, LevelExempt = theOverride.levelExempt };

                /* NOTE: THESE ARE THE BRACKET FIELDS 
                 * bracket1.CountyOverrideTax;
                 * bracket1.MaxBase;
                 * bracket1.ReplaceCounty;
                 * bracket1.ReplaceState;
                 * bracket1.StateOverrideTax;
                 * bracket1.TaxRate;
                 */

                // Create a bracket
                var band = new TaxBracketInfo { TaxRate = (double)theOverride.tax_rate, MaxBase = ((double)theOverride.maximum == 0.0) ? TaxBracketInfo.NoLimit : (double)theOverride.maximum };

                if (theOverride.replace_jur)
                {
                    switch ((TaxLevel)theOverride.jur_level)
                    {
                        case TaxLevel.County:
                            band.ReplaceCounty = true;
                            break;
                        case TaxLevel.State:
                            band.ReplaceState = true;
                            break;
                    }
                }

                // Add the bracket to the history      
                historyRecord.Brackets.Add(band);

                mLogger.LogDebug("Setting this override tax band: rate: " + band.TaxRate +
                                   " County tax: " + band.CountyOverrideTax +
                                   " State tax: " + band.StateOverrideTax +
                                   " Replace county: " + band.ReplaceCounty +
                                   " Replace state: " + band.ReplaceState);

                taxRate.History.Add(historyRecord);

                try
                {
                    mSession.AddOverrideByPCode((uint)theOverride.Pcode, taxRate);
                }
                catch (Exception e)
                {
                    mLogger.LogError("Failed to add a BillSoft override.  The override was based on this configuration information: " + printableOverrideConfig);
                    throw e;
                }
            }
        }
        #endregion // Override Logic

        #region Exemptions Logic
        /// <summary>
        /// Populated the account to exemption mapping table
        /// </summary>
        /// <param name="reader"></param>
        private void PopulateExemptionsLookupTable(IMTDataReader reader)
        {
            try
            {
                var e = new BillSoftExemption
                          {
                              id_ancestor = reader.GetInt32("id_ancestor"),
                              id_acc = reader.GetInt32("id_acc"),
                              id_tax_exemption = reader.GetInt32("id_tax_exemption"),
                              pcode = reader.GetInt32("pcode"),
                              tax_type = reader.GetInt32("tax_type"),
                              jur_level = reader.GetInt32("jur_level"),
                              start_date = reader.GetDateTime("start_date"),
                              end_date = reader.GetDateTime("end_date"),
                              create_date = reader.GetDateTime("create_date"),
                              update_date = reader.GetDateTime("update_date")
                          };

                // Certificate can be null, and if the GetString 
                // is called and there is nothing there,
                // and exception will be thrown.
                try
                {
                    e.certificate_id = reader.GetString("certificate_id");
                }
                catch
                {
                    e.certificate_id = String.Empty;
                }

                // Quickly check for error case if we have to ignore 
                // this entry
                if (IsNotSet(e.id_ancestor) && IsNotSet(e.id_acc))
                {
                    mLogger.LogError("Found entry where both id_acc and id_ancestor are both -1, ignoring tax exemption");
                    return;
                }
                mLogger.LogDebug(String.Format("Caching Tax Exemption " +
                                               "e.id_tax_exemption{9},e.id_ancestor{10},e.id_acc{0}," +
                                               "e.certificate_id{1},e.pcode{2},e.tax_type{3},e.jur_level{4}," +
                                               "e.start_date{5},e.end_date{6},e.create_date{7},e.update_date{8}",
                                               e.id_acc, e.certificate_id, e.pcode, e.tax_type,
                                               e.jur_level, e.start_date, e.end_date, e.create_date,
                                               e.update_date, e.id_tax_exemption, e.id_ancestor));
                //---------------------------------------------------------------------------
                // PROCESSING RULES
                //---------------------------------------------------------------------------
                // Ancestor account id.   If -1, then does not apply, otherwise specifies 
                // that all accounts under this account should receive the exemption (inclusively).    
                // Error if id_ancestor and id_acc are -1.
                //---------------------------------------------------------------------------
                if (IsSet(e.id_ancestor))
                {
                    GetAllAccountsForExceptionGroup(ref e);
                }
                //---------------------------------------------------------------------------
                // Account ID.  If -1, does not apply otherwise specifies the account that has the exemption.
                //---------------------------------------------------------------------------
                else if (IsSet(e.id_acc))
                {
                    AddToExemptionsByAccount(e.id_acc, e);
                }
            }
            catch (Exception e)
            {
                mLogger.LogError(e.ToString());
                throw new TaxException(e.ToString());
            }
        }
        /// <summary>
        /// Adds the exemptions to the account to exemption mapping table
        /// </summary>
        /// <param name="id_acc"></param>
        /// <param name="e"></param>
        private void AddToExemptionsByAccount(int id_acc, BillSoftExemption e)
        {
            List<BillSoftExemption> list;
            if (!mExemptionsByAccount.ContainsKey(id_acc))
            {
                list = new List<BillSoftExemption>();
                mExemptionsByAccount.Add(id_acc, list);
            }
            else
            {
                list = mExemptionsByAccount[id_acc];
            }
            list.Add(e);
        }
        /// <summary>
        /// Adds override to the account to override mapping table
        /// </summary>
        /// <param name="id_acc"></param>
        /// <param name="e"></param>
        private void AddToOverrideByAccount(int id_acc, Override e)
        {
            List<Override> list;
            if (!mOverridesByAccount.ContainsKey(id_acc))
            {
                list = new List<Override>();
                mOverridesByAccount.Add(id_acc, list);
            }
            else
            {
                list = mOverridesByAccount[id_acc];
            }
            list.Add(e);
        }
        /// <summary>
        /// Applies the exemptions for the account to the transaction
        /// </summary>
        /// <param name="id_acc"></param>
        /// <param name="trans"></param>
        private void ApplyExemptions(int id_acc, ref Transaction trans)
        {
            // Check if there are any account level exemptions
            if (mExemptionTableMissing ||
                !mExemptionsByAccount.ContainsKey(id_acc))
            {
                mLogger.LogDebug("No exemptions");
                return;
            }


            mLogger.LogDebug(String.Format("Adding exemptions for account {0}", id_acc));

            var exemption = new TaxExemption();
            var list = mExemptionsByAccount[id_acc];
            foreach (var e in list)
            {
                //---------------------------------------------------------------------------
                // BillSoft PCode specific to an exemption. If the pcode is 0, then all taxes of the tax type 
                // (tax_type) and tax jurisdication level (jur_level) specified are considered exempt 
                // regardless of the particular jurisdiction they are calculated for.
                //---------------------------------------------------------------------------
                if (e.pcode != 0)
                {
                    exemption.JCode = mSession.PCodeToJCode((uint)e.pcode);
                }
                //---------------------------------------------------------------------------
                // BillSoft tax type code specifying a particular tax. 
                // 0 means applies to all taxes in the jurisdication.  
                // Note that this doesn't guarantee that all taxes in the tax level will be exempt.  
                // Some taxes are not exemptable by default.  See Overrides to learn how 
                // you can change the exemptability status or particular taxes.
                //---------------------------------------------------------------------------
                mLogger.LogInfo(
                  String.Format(
                    "Applying Exemptions for account {0} pcode {3} for tax type {2} for charge {1} tax calculation", id_acc,
                    trans.Charge, BillSoftConstantConverter.GetEZTaxType((short)e.tax_type), e.pcode));
                exemption.TaxType = (short)e.tax_type;
                exemption.TaxLevel = BillSoftConstantConverter.GetTaxLevel((TaxJurisdiction)e.jur_level);
                trans.Exemptions.Add(exemption);
            }
        }
        #endregion // Exemptions Logic

        #region Table Manipulation and Query Methods

        /// <summary>
        /// Executes the query specified by tag. This only 
        /// executes queries in the dbinstall query area
        /// </summary>
        /// <param name="table">tablename to be create</param>
        /// <param name="tag">tag used in query file</param>
        public static void CreateTableWithTag(string table, string tag)
        {
            using (var conn = ConnectionManager.CreateConnection())
            using (var stmt = conn.CreateAdapterStatement(mConstDBInstallQueryDir, tag.Trim()))
            {
                stmt.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Gets the override entries from the database
        /// </summary>
        private static void GetValuesFromTable(string tblnm, string actionString, ref bool ignoreTableFlag, TableProcessor tableProcessingFunction)
        {
            mLogger.LogInfo(String.Format("Loading {0} data", actionString));

            using (var conn = ConnectionManager.CreateConnection())
            using (var stmt = conn.CreateAdapterStatement(mConstBillSoftQueryDir, "__GET_ALL_FROM_TABLE__"))
            {
                stmt.AddParamIfFound("%%TABLENAME%%", tblnm);
                using (var reader = stmt.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        tableProcessingFunction(reader);
                    }
                    // Release the reader resource
                    reader.Close();
                }
            }
            mLogger.LogInfo(String.Format("Loading {0} data complete", actionString));
        }
        /// <summary>
        /// Gets the override entries from the database
        /// </summary>
        private void GetOverrideEntries()
        {
            GetValuesFromTable("t_tax_billsoft_override", "override", ref mOverrideTableMissing, AddOverrideToOverrideMap);
        }
        /// <summary>
        /// Gets the exemption entries from the database
        /// </summary>
        private void GetExemptionsEntries()
        {
            GetValuesFromTable("t_tax_billsoft_exemptions", "exemption", ref mExemptionTableMissing, PopulateExemptionsLookupTable);
        }

        /// <summary>
        /// Given a id_ancestor, this method returns all the child accounts.
        /// </summary>
        /// <exception cref="ArgumentNullException"></exception>
        /// <returns>nothing, but if accounts are found, they are added to the ExemptionsByAccount dictionary</returns>
        private void GetAllAccountsForExceptionGroup(ref BillSoftExemption e)
        {

            if (e == null) throw new ArgumentNullException("Exemption not a valid instance");
            var ids = GetAllAccountsInGroup(e.id_ancestor);
            foreach (var id in ids)
                AddToExemptionsByAccount(id, e);
        }
        /// <summary>
        /// Given a id_ancestor, this method returns all the child accounts.
        /// </summary>
        /// <returns>nothing, but if accounts are found, they are added to the ExemptionsByAccount dictionary</returns>
        private void GetAllAccountsForOverrideGroup(ref Override o)
        {
            if (o == null) throw new ArgumentNullException("Override not a valid instance");
            var ids = GetAllAccountsInGroup(o.id_ancestor);
            foreach (var id in ids)
                AddToOverrideByAccount(id, o);
        }
        /// <summary>
        /// Gets all accounts in the group designated by the parent ID
        /// </summary>
        /// <param name="parent">parent id</param>
        /// <returns></returns>
        private static IEnumerable<int> GetAllAccountsInGroup(int parent)
        {
            var list = new List<int>();
            using (var conn = ConnectionManager.CreateConnection())
            using (var stmt = conn.CreateAdapterStatement(mConstBillSoftQueryDir, "__GET_CHILD_ACCOUNTS__"))
            {
                stmt.AddParam("%%PARENTACCOUNTID%%", parent);
                using (var reader = stmt.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int id = reader.GetInt32("id_descendent");
                        if (list.Contains(id)) continue;
                        list.Add(id);
                    }
                }
            }
            return list;
        }
        #endregion // Table Manipulation and Query Methods

        #region Misc Helper Methods
        /// <summary>
        /// Logs a progress entry
        /// </summary>
        /// <param name="curCnt"></param>
        /// <param name="total"></param>
        private void DefaultReportProgress(Int64 curCnt, Int64 total)
        {
            var current = (float)curCnt;
            var percent = (int)((current / total) * 100);
            if ((percent / 10) <= mLastProgressMarker) return;
            mLastProgressMarker++;
            mLogger.LogInfo(string.Format("Tax calculations {0}% complete", percent));
        }
        /// <summary>
        /// Returns true if id is -1 or zero
        /// </summary>
        /// <param name="id">id to test</param>
        /// <returns></returns>
        private static bool IsNotSet(int id)
        {
            const int NOTSET = -1;
            return NOTSET == id || 0 == id;
        }
        /// <summary>
        /// Returns true if the ID is not -1 or zero
        /// </summary>
        /// <param name="id">id to test</param>
        /// <returns></returns>
        private static bool IsSet(int id)
        {
            return !IsNotSet(id);
        }

        /// <summary>
        /// Ensures directory exists and creates the file name 
        /// for the audit log.
        /// </summary>
        /// <param name="prefix"></param>
        /// <param name="path">directory path where the file is to be stored</param>
        /// <param name="runid">current runid to use in file name</param>
        /// <returns></returns>
        private static string PrepareLogFileDirectoryAndPath(string prefix, int runid)
        {
            return PrepareLogFileDirectoryAndPath(prefix, null, runid);
        }

        /// <summary>
        /// Ensures directory exists and creates the file name 
        /// for the audit log.
        /// </summary>
        /// <param name="prefix"></param>
        /// <param name="path">directory path where the file is to be stored</param>
        /// <param name="runid">current runid to use in file name</param>
        /// <returns></returns>
        private static string PrepareLogFileDirectoryAndPath(string prefix, string path, int runid)
        {
            if (path == null) throw new ArgumentNullException("path");
            if (!Directory.Exists(path))
            {
                if (File.Exists(path))
                    throw new DirectoryNotFoundException(String.Format("{0} exist as a file. It cannot be the log directory.", path));
                Directory.CreateDirectory(path);
            }
            return CreatePath(prefix, path, runid);
        }

        /// <summary>
        /// This method takes the path and generates a audit file name 
        /// used for this tax run
        /// </summary>
        /// <param name="prefix">prefix from configuration log</param>
        /// <param name="path">directory path where the file is to be stored</param>
        /// <param name="runid">current runid to use in file name</param>
        /// <returns></returns>
        private static string CreatePath(string prefix, string path, int runid)
        {
            // Ensure a trailing slash, and then add the filename
            if (path.Trim()[path.Trim().Length - 1] != '\\')
                path += @"\";
            return path + (prefix + runid + ".auditlog");
        }
        /// <summary>
        /// Tests for a match
        /// </summary>
        /// <param name="matchme"></param>
        /// <param name="value"></param>
        /// <returns></returns>
        private static bool TestFlag(string matchme, string value)
        {
            return matchme.ToLower().Trim() == value.ToLower().Trim();
        }
        #endregion // Mist Helper Methods

        private delegate void TableProcessor(IMTDataReader reader);
        public delegate void ReportMethod(string s);
        public delegate void ReportProgress(int nTransactionsProcessed);

        public event ReportProgress ProgressMethod;
        public event ReportMethod WarningMethod;
        public event ReportMethod InfoMethod;

        // Framework class instances
        private BillSoftConfiguration mConfig;

        private int mErrorCount;

        /// <summary>
        /// Storage Containers for internal Caches
        /// </summary>
        private Dictionary<int, List<BillSoftExemption>> mExemptionsByAccount;

        private bool mExemptionTableMissing = false;

        /// <summary>
        /// Organization for overrides
        /// Note: ID -1 is for all non account specific overrrides
        /// </summary>
        private Dictionary<int, List<Override>> mOverridesByAccount;
        private bool mOverrideTableMissing;

        private string mInTbl = String.Empty;

        private TaxManagerVendorInputTableReader mInputReader;
        private Boolean mIsAuditingNeeded;
        private TaxManagerBatchDbTableWriter mOutputDetailWriter;
        private int mGlobalDetailId = 1;
        /// <summary>
        /// Computation progress marker for reporting
        /// </summary>
        private int mLastProgressMarker;

        private string mOutTbl = String.Empty;
        private TaxManagerBatchDbTableWriter mOutputWriter;

        /// <summary>
        /// Product Code cache (mapper)
        /// </summary>
        private ProductCodeMapper mPCMapper;

        //--------------------------------------------------
        // Passed in parameters
        //--------------------------------------------------
        private int mRunId = -1;
        private EZTaxSession mSession;
        private Boolean mTaxDetailsNeeded;

        // When the number of errors exceeds this value, throw an exception
        private int mMaximumNumberOfErrors;

    }
}
