using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using MetraTech.DataAccess;

namespace MetraTech.UsageServer.Test
{
  public class InvoiceAdapterTest : IAdapterTest
  {
    /// <summary>
    ///   Clean any invoice adapter specific data for 
    ///   the given interval/billing groups/accounts.
    /// </summary>
    /// <param name="intervals"></param>
    public void CleanData(Interval interval)
    {
      AdapterTestManager.Logger.LogInfo(String.Format("Cleaning invoice data for interval '{0}'", interval.Id));

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__DELETE_INVOICES__"))
          {

              stmt.AddParam("%%ID_INTERVAL%%", interval.Id, true);
              stmt.AddParam("%%ACCOUNT_IDS%%", interval.GetCommaSeparatedAccountIds(), true);

              stmt.ExecuteNonQuery();
          }

          using (IMTAdapterStatement stmt1 =
            conn.CreateAdapterStatement(Util.queryPath, "__DELETE_INVOICE_RANGE__"))
          {

              stmt1.AddParam("%%ID_INTERVAL%%", interval.Id, true);
              stmt1.AddParam("%%BILLGROUP_IDS%%", interval.GetCommaSeparatedBillGroupIds(), true);

              stmt1.ExecuteNonQuery();
          }
      }
    }


    /// <summary>
    ///   Setup any invoice adapter specific data for 
    ///   the given interval/billing groups/accounts.
    /// </summary>
    /// <param name="intervals"></param>
    public void InitializeData(Interval interval)
    {
      BillingGroupTest billingGroupTest = new BillingGroupTest();
      ArrayList accounts = new ArrayList(interval.GetAccounts());
      billingGroupTest.MeterUsage(accounts, interval.Id, true);
    }


    /// <summary>
    ///   Validate the execution of the invoice adapter for 
    ///   the given interval and billing group.
    /// 
    ///   Returns false if validation fails.
    /// </summary>
    /// <param name="intervals"></param>
    public bool ValidateExecution(Interval interval, 
                                  BillingGroup billingGroup,
                                  out string errors)
    {
      return Validate(interval, billingGroup, out errors, RecurringEventAction.Execute);
    }

    /// <summary>
    ///   Validate the reversal of the invoice adapter for 
    ///   the given interval and billing group.
    /// 
    ///   Returns false if validation fails.
    /// </summary>
    /// <param name="intervals"></param>
    public bool ValidateReversal(Interval interval, 
                                 BillingGroup billingGroup, 
                                 out string errors)
    {
      return Validate(interval, billingGroup, out errors, RecurringEventAction.Reverse);
    }


    private bool Validate(Interval interval,
                          BillingGroup billingGroup,
                          out string errors,
                          RecurringEventAction recurringEventAction)
    {
      bool validExecution = true;
      string error = String.Empty;
      StringBuilder errorBuilder = new StringBuilder();

      // Ensure that each of the accounts in billingGroup has an entry in t_invoice
      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          foreach (Account account in billingGroup.Accounts)
          {
              using (IMTAdapterStatement stmt =
                conn.CreateAdapterStatement(Util.queryPath, "__VERIFY_INVOICE__"))
              {

                  stmt.AddParam("%%ID_INTERVAL%%", interval.Id, true);
                  stmt.AddParam("%%ID_ACC%%", account.Id, true);

                  using (IMTDataReader reader = stmt.ExecuteReader())
                  {
                      reader.Read();

                      int count = reader.GetInt32("numInvoice");
                      error = String.Empty;

                      if (recurringEventAction == RecurringEventAction.Execute && count != 1)
                      {
                          error = String.Format("Unable to find invoice for interval '{0}' and account '{1}' after adapter execution",
                                                 interval.Id, account.Id);
                      }
                      else if (recurringEventAction == RecurringEventAction.Reverse && count != 0)
                      {
                          error = String.Format("Found invoice for interval '{0}' and account '{1}' after adapter reversal",
                                                 interval.Id, account.Id);
                      }

                      if (!String.IsNullOrEmpty(error))
                      {
                          errorBuilder.AppendLine(error);
                          AdapterTestManager.Logger.LogError(error);
                          validExecution = false;
                      }
                  }
              }
          }
      }

      errors = errorBuilder.ToString();
      return validExecution;
    }
  }
}
