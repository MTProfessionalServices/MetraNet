// -----------------------------------------------------------------------
// <copyright file="NonReccurringCharge.cs" company="MetraTech">
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

  /// <summary>
  /// NonRecurring charges for Quote
  /// </summary>
  public class NonReccuringCharge : BaseCharge
  {
    public NonReccuringCharge(QuotingConfiguration configuration, ILogger log)
      : base(configuration, log)
    {
    }

    public override ChargeType ChargeType
    {
      get { return ChargeType.NonRecurringCharge; }
    }

    public override ChargeData Add(IMTServicedConnection transacConnection, QuoteRequest quoteRequest, string batchId, int usageInterval)
    {
      ChargeData nonReccuringCharge = ChargeData.CreateInstance(this.ChargeType
          , batchId);

      using (new Debug.Diagnostics.HighResolutionTimer(MethodInfo.GetCurrentMethod().Name))
      {
        Log.LogDebug("Insert Non-Recurring Charges to DB... ");


        using (var stmt = transacConnection.CreateCallableStatement(Config.NonRecurringChargeStoredProcedureQueryTag))
        {
          //ToDo: Get start and end date according to billing cycle
          var dateTime = MetraTime.Now;
          var firstDayOfTheMonth = new DateTime(dateTime.Year, dateTime.Month, 1);
          var firstDayOfTheNextMonth = firstDayOfTheMonth.AddMonths(1);

          stmt.AddParam("dt_start", MTParameterType.DateTime, firstDayOfTheMonth);
          stmt.AddParam("dt_end", MTParameterType.DateTime, firstDayOfTheNextMonth);
          stmt.AddParam("v_id_interval", MTParameterType.Integer, usageInterval);
          stmt.AddParam("v_id_accounts", MTParameterType.String, string.Join(",", quoteRequest.Accounts));
          stmt.AddParam("v_id_batch", MTParameterType.String, nonReccuringCharge.IdBatch);
          stmt.AddParam("v_n_batch_size", MTParameterType.Integer, Config.MeteringSessionSetSize);
          stmt.AddParam("v_run_date", MTParameterType.DateTime, dateTime);
          stmt.AddParam("v_is_group_sub", MTParameterType.Integer,
                            Convert.ToInt32(quoteRequest.SubscriptionParameters.IsGroupSubscription));
          stmt.AddOutputParam("p_count", MTParameterType.Integer);
          stmt.ExecuteNonQuery();
          nonReccuringCharge.CountMeteredRecords = (int)stmt.GetOutputValue("p_count");
        }

        Log.LogDebug("Non-Recurring Charges have already added to DB.");
      }

      return nonReccuringCharge;
    }
  }
}
