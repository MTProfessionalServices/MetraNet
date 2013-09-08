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

using System.Reflection;
using MetraTech.DataAccess;
using MetraTech.Domain.Quoting;

namespace MetraTech.Quoting.Charge
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    ///  Recurring charges for Quote
    /// </summary>
    public class ReccurringCharge : BaseCharge
    {
        public ReccurringCharge(QuotingConfiguration configuration, IChargeMetering metering, ILogger log) 
            : base(configuration, metering, log)
        {
        }

        public override ChargeType ChargeType
        {
            get { return ChargeType.RecurringCharge; }
        }

        public override ChargeData Add(IMTServicedConnection transacConnection, QuoteRequest quoteRequest)
        {
            ChargeData reccuringCharge = ChargeData.CreateInstance(this.ChargeType, Metering.InitBatch());

            using (new Debug.Diagnostics.HighResolutionTimer(MethodInfo.GetCurrentMethod().Name))
            {
                Log.LogDebug("Preparing Recurring Charges...");

                using (var conn = ConnectionManager.CreateConnection())
                {
                    using (var stmt = conn.CreateCallableStatement(Config.RecurringChargeStoredProcedureQueryTag)
                        )
                    {
                        stmt.AddParam("v_id_interval", MTParameterType.Integer, ChargeMetering.GetUsageInterval(Config, quoteRequest));
                        stmt.AddParam("v_id_billgroup", MTParameterType.Integer, 0); //reserved for future
                        stmt.AddParam("v_id_run", MTParameterType.Integer, 0); //reserved for future
                        stmt.AddParam("v_id_accounts", MTParameterType.String, string.Join(",", quoteRequest.Accounts));
                        stmt.AddParam("v_id_batch", MTParameterType.String, reccuringCharge.IdBatch);
                        stmt.AddParam("v_n_batch_size", MTParameterType.Integer, Config.MeteringSessionSetSize);
                        stmt.AddParam("v_run_date", MTParameterType.DateTime, MetraTime.Now);
                        //todo: Clarify parameter sense
                        stmt.AddOutputParam("p_count", MTParameterType.Integer);
                        stmt.ExecuteNonQuery();
                        reccuringCharge.CountMeteredRecords = (int)stmt.GetOutputValue("p_count");
                    }
                }

                Metering.MeterRecodrs(reccuringCharge);

                Log.LogDebug("Done Preparing Recurring Charges");
            }

            return reccuringCharge;
        }
    }
}
