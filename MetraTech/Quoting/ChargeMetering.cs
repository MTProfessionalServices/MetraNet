// -----------------------------------------------------------------------
// <copyright file="ChargeMetering.cs" company="MetraTech">
// **************************************************************************
// Copyright 2011 by MetraTech
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
//
// $Header$
// 
// ***************************************************************************/
// </copyright>
// -----------------------------------------------------------------------

using MetraTech.DataAccess;
using MetraTech.Domain.Quoting;
using MetraTech.Interop.MTBillingReRun;
using MetraTech.Pipeline;
using MetraTech.Quoting.Charge;
using MetraTech.UsageServer;
using BillingReRunClient = MetraTech.Pipeline.ReRun;

namespace MetraTech.Quoting
{
    using System;
    using System.Collections.Generic;
    using System.Linq;

    /// <summary>
    /// Metering
    /// </summary>
    public class ChargeMetering : IChargeMetering
    {
        private readonly QuotingConfiguration _config;
        private readonly IList<ICharge> _charges;
        private readonly Interop.MeterRowset.MeterRowset _rowSet;

        public ChargeMetering(QuotingConfiguration configuration, IList<ICharge> charges, ILogger logger)
        {
            _config = configuration;
            _charges = charges;
            Log = logger;

            _rowSet = new Interop.MeterRowset.MeterRowsetClass();
        }


        #region IChargeMetering Members

        public ILogger Log { get; private set; }

        /// <summary>
        /// Adds charges to DB
        /// </summary>
        /// <param name="quoteRequest"></param>
        /// <returns>IList<<see cref="ChargeData"/>></returns>
        /// <exception cref="AddChargeMeteringException">The exception contains charges which should be cleanuped</exception>
        public IList<ChargeData> AddCharges(QuoteRequest quoteRequest)
        {
            IList<ChargeData> chargeList = new List<ChargeData>();

            //need for the exception info
            ICharge currentCharge = null;
            int usageInterval = GetUsageInterval(quoteRequest);

            try
            {
                foreach (ICharge charge in _charges)
                {
                    currentCharge = charge;

                    _rowSet.InitSDK(_config.RecurringChargeServerToMeterTo);

                    ChargeData chargeData = charge.Add(quoteRequest
                                                    , _rowSet.GenerateBatchID()
                                                    , usageInterval);
                    chargeList.Add(chargeData);
                    MeterRecodrs(chargeData);
                }
            }
            catch (Exception ex)
            {
                throw new AddChargeMeteringException(chargeList
                    , String.Format("Error while adding charge with type={0} to DB.", currentCharge.ChargeType), ex);
            }


            return chargeList;
        }

        /// <summary>
        /// Lookups the usage interval to use for this quote
        /// </summary>
        /// <param name="quoteRequest"></param>
        /// <returns>Usage inerval</returns>
        public int GetUsageInterval(QuoteRequest quoteRequest)
        {
            int idUsageInterval;

            using (var conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(_config.QuotingQueryFolder,
                                                                         _config.GetUsageIntervalIdForQuotingQueryTag))
                {
                    stmt.AddParam("%%EFFECTIVE_DATE%%", quoteRequest.EffectiveDate);

                    stmt.AddParam("%%ACCOUNT_ID%%", quoteRequest.Accounts[0]);

                    using (IMTDataReader rowset = stmt.ExecuteReader())
                    {
                        if (rowset.Read())
                        {
                            idUsageInterval = rowset.GetInt32("UsageIntervalId");
                            string usageIntervalState = rowset.GetString("UsageIntervalState");
                            DateTime usageIntervalStart = rowset.GetDateTime("UsageIntervalStart");
                            DateTime usageIntervalEnd = rowset.GetDateTime("UsageIntervalEnd");

                            //Perhaps in the future this can be resolved by obtaining the next open interval and using that for the quote
                            if (string.Compare(usageIntervalState, "O", true) != 0)
                            {
                                throw new Exception(
                                  string.Format(
                                    "The interval {0} running from {1} to {2}, currently has a state of '{3}' and cannot be used for quoting. Please select an effective date other than {4}",
                                    idUsageInterval, usageIntervalStart, usageIntervalEnd, usageIntervalState, quoteRequest.EffectiveDate));
                            }

                            //Hopefully this limitation can be removed or automatically resolved in the future
                            if (rowset.IsDBNull("NextUsageIntervalId"))
                            {
                                throw new Exception(
                                  string.Format(
                                    "It is a current limitation of quoting recurring charge generation that the 'next' usage interval exists. For the interval {0} running from {1} to {2}, no usage interval exists for the next cycle starting {3}. Please create this usage interval.",
                                    idUsageInterval, usageIntervalStart, usageIntervalEnd, usageIntervalEnd.AddSeconds(1)));
                            }

                        }
                        else
                        {
                            throw new Exception(
                              string.Format(
                                "Usage interval to use for quoting not found for effective date of {0} and account {1}. Please create this usage interval or use a different effective date.",
                                quoteRequest.EffectiveDate, quoteRequest.Accounts[0]));
                        }

                    }
                }
            }

            return idUsageInterval;
        }


        /// <summary>
        /// Meter records in Pipeline
        /// </summary>
        /// <param name="chargeData"><see cref="ChargeData"/></param>
        /// <exception cref="ChargeMeteringException"></exception>
        /// <exception cref="Exception"></exception>
        protected void MeterRecodrs(ChargeData chargeData)
        {
            if (chargeData.CountMeteredRecords > 0)
            {
                Log.LogDebug(
                    String.Format("Metered {0} records to {1} with Batch ID={2} and waiting for pipeline to process",
                                  chargeData.CountMeteredRecords, chargeData.ChargeType, chargeData.IdBatch));

                string errorMessage;
                if (!ValidatChargeData(chargeData, out errorMessage))
                    throw new ChargeMeteringException(errorMessage);

                _rowSet.WaitForCommit(chargeData.CountMeteredRecords, 120);

                // Check for error during pipeline processing
                if (_rowSet.CommittedErrorCount > 0)
                {
                    errorMessage =
                        String.Format(@"'{0}' {1} sessions failed during pipeline processing.
                          Pipeline Errors: 
                          {2}",
                                      _rowSet.CommittedErrorCount
                                      , chargeData.ChargeType
                                      , RetrievePipelineErrorDetailsMessage(chargeData.IdBatch));

                    throw new ChargeMeteringException(errorMessage);
                }
            }
            else
            {
                Log.LogDebug(String.Format("No {0} for this quote", chargeData.ChargeType));
            }
        }

        public void CleanupUsageData(int idQuote, IEnumerable<ChargeData> charges)
        {
            Log.LogInfo("Reversing {0} batch(es) associated with this quote", charges.Count());

            IMTBillingReRun rerun = new BillingReRunClient.Client();
            var sessionContext = AdapterManager.GetSuperUserContext(); // log in as super user
            rerun.Login((Interop.MTBillingReRun.IMTSessionContext)sessionContext);
            var comment = String.Format("Quoting functionality; Reversing work associated with QuoteId {0}",
                                        idQuote);
            rerun.Setup(comment);

            var pipeline = new PipelineManager();
            try
            {
                // pauses all pipelines so identify isn't chasing a moving target
                pipeline.PauseAllProcessing();

                // identify all batches (ideally we could do this in one call to Identify)
                // instead of doing individual billing reruns per batch (CR12581)
                foreach (ChargeData charge in charges)
                {
                    Log.LogDebug("Backingout batch with id {0} associated with this quote", charge.IdBatch);

                    IMTIdentificationFilter filter = rerun.CreateFilter();
                    filter.BatchID = charge.IdBatch;

                    // filters on the billing group ID if the billing group ID is set on the context
                    // NOTE: it won't be set for scheduled or EOP interval-only adapters)

                    // filters on the interval ID if the interval ID is set on the context
                    // NOTE: it won't be set for scheduled adapters).  This is important for
                    // performance when partitioning is enabled.

                    filter.IsIdentifySuspendedTransactions = true;
                    filter.IsIdentifyPendingTransactions = true;
                    filter.SuspendedInterval = 0;

                    rerun.Identify(filter, comment);
                }

                rerun.Analyze(comment);
                rerun.BackoutDelete(comment);
                rerun.Abandon(comment);
            }
            finally
            {
                // always resume processing no matter what!
                pipeline.ResumeAllProcessing();
            }

            Log.LogDebug("Completed backing out batches associated with the quote");

        }

        #endregion

        private bool ValidatChargeData(ChargeData charge, out string errorMessage)
        {
            errorMessage = String.Empty;

            if (charge.ChargeType == ChargeType.None)
            {
                errorMessage = String.Format("The {0} shoudl contain ChargeType, currently ChargeType = {1}.",
                                              typeof(ChargeData), charge.ChargeType);
            }

            if (String.IsNullOrEmpty(charge.IdBatch))
            {
                errorMessage = String.Format("{0}{1}The IdBatch is empty. Firstly run metering then add charges.",
                                              errorMessage, Environment.NewLine);
            }

            return String.IsNullOrEmpty(errorMessage);
        }

        /// <summary>
        /// Helper method to retrieve detailed error messages for any failures
        /// that occured in the pipeline
        /// </summary>
        /// <param name="batchIdEncoded">metered batch id to retrieve errors for</param>
        /// <returns></returns>
        private string RetrievePipelineErrorDetailsMessage(string batchIdEncoded)
        {
            //select tx_StageName, tx_Plugin, tx_ErrorMessage from t_failed_transaction where tx_Batch_Encoded = 'Csj8TlVRaiFpU0YM/f93+w=='

            MTStringBuilder sb = new MTStringBuilder();

            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(_config.QuotingQueryFolder,
                                                                           "__GET_PIPELINE_ERRORS_FOR_BATCH__"))
                {
                    stmt.AddParam("%%STRING_BATCH_ID%%", batchIdEncoded);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            sb.Append(string.Format("Stage[{0}] Plugin[{1}] Error[{2}]" + System.Environment.NewLine,
                                                    reader.GetString("tx_StageName"),
                                                    reader.GetString("tx_Plugin"),
                                                    reader.GetString("tx_ErrorMessage")));
                        }
                    }
                }
            }

            return sb.ToString();
        }
    }
}
