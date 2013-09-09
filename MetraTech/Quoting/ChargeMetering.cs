// -----------------------------------------------------------------------
// <copyright file="ILogger.cs" company="MetraTech">
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

namespace MetraTech.Quoting
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// TODO: Update summary.
    /// </summary>
    public class ChargeMetering : IChargeMetering
    {
        private readonly QuotingConfiguration _config;
        private readonly ILogger _log;
        private readonly Interop.MeterRowset.MeterRowset _rowSet;

        public ChargeMetering(QuotingConfiguration configuration, ILogger logger)
        {
            _config = configuration;
            _log = logger;

            _rowSet = new Interop.MeterRowset.MeterRowsetClass();
        }

       /// <summary>
        /// Lookups the usage interval to use for this quote
       /// </summary>
       /// <param name="config"></param>
       /// <param name="quoteRequest"></param>
       /// <returns></returns>
        public static Int32 GetUsageInterval(QuotingConfiguration config, QuoteRequest quoteRequest)
        {
          Int32 idUsageInterval;

          using (var conn = ConnectionManager.CreateConnection())
          {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(config.QuotingQueryFolder,
                                                                     config.GetUsageIntervalIdForQuotingQueryTag))
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


        #region IChargeMetering Members


        public string InitBatch()
        {
            _rowSet.InitSDK(_config.RecurringChargeServerToMeterTo);
            return _rowSet.GenerateBatchID();
        }

        /// <summary>
        /// Meter records in Pipeline
        /// </summary>
        /// <param name="chargeData"><see cref="ChargeData"/></param>
        /// <exception cref="ChargeMeteringException"></exception>
        /// <exception cref="Exception"></exception>
        public void MeterRecodrs(ChargeData chargeData)
        {
            if (chargeData.CountMeteredRecords > 0)
            {
                _log.LogDebug(
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
                _log.LogDebug(String.Format("No {0} for this quote", chargeData.ChargeType));
            }
        }

        #endregion

        private bool ValidatChargeData(ChargeData charge, out string errorMessage)
        {
            errorMessage = String.Empty;

            if (charge.ChargeType == ChargeType.None)
            {
                errorMessage = String.Format("The {0} shoudl contain ChargeType, currently ChargeType = {1}.",
                                              typeof (ChargeData), charge.ChargeType);
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
                using (
                    IMTAdapterStatement stmt = conn.CreateAdapterStatement(_config.QuotingQueryFolder,
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

    public  class ChargeMeteringException : Exception
    {
        public ChargeMeteringException(string errorMessage) 
            : base(errorMessage){} 
    }
}
