﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Auth.Capabilities;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DataAccess;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.MTAuth;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.Tools;
using MetraTech.Security.Crypto;
public partial class Adjustments_IssueMiscellaneousAdjustment : MTPage
{
    //[NonSerialized]
    public PipelineMeteringHelperCache cache
    {
        get
        {
            if (HttpContext.Current.Application["AccountCreditPipelineMeteringHelperCache"] == null)
            {
                HttpContext.Current.Application.Lock();
                HttpContext.Current.Application["AccountCreditPipelineMeteringHelperCache"] = new PipelineMeteringHelperCache("metratech.com/AccountCredit");
                HttpContext.Current.Application.UnLock();
            }
            return HttpContext.Current.Application["AccountCreditPipelineMeteringHelperCache"] as PipelineMeteringHelperCache;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            adjAmountFld.DecimalSeparator
              = adjAmountFldTaxFederal.DecimalSeparator
                = adjAmountFldTaxState.DecimalSeparator
                = adjAmountFldTaxCounty.DecimalSeparator
                = adjAmountFldTaxLocal.DecimalSeparator
                = adjAmountFldTaxOther.DecimalSeparator
                =  System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyDecimalSeparator;
            adjAmountFld.DecimalPrecision
               = adjAmountFldTaxFederal.DecimalPrecision
                = adjAmountFldTaxState.DecimalPrecision
                = adjAmountFldTaxCounty.DecimalPrecision
                = adjAmountFldTaxLocal.DecimalPrecision
                = adjAmountFldTaxOther.DecimalPrecision
              = System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyDecimalDigits.ToString();

            string maxAdjAmount = String.Format("{0} {1}", GetLocalResourceObject("TEXT_MAX_AUTHORIZED_AMOUNT"), GetLocalResourceObject("TEXT_UNLIMITED"));
            if (!UI.SessionContext.SecurityContext.IsSuperUser())
            {
                maxAdjAmount = GetMaxCapabilityAmount();
            }

            lblMaxAmount.Text = String.Format("{0} {1}", maxAdjAmount, ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).Currency);
        }


        var accountIntervalsClient = new UsageHistoryService_GetAccountIntervals_Client
        {
            UserName = UI.User.UserName,
            Password = UI.User.SessionPassword
        };

        if (UI.Subscriber.SelectedAccount._AccountID != null)
            accountIntervalsClient.In_accountID = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID);
        accountIntervalsClient.Invoke();
        var returnIntervals = accountIntervalsClient.Out_acctIntervals;
        foreach (MetraTech.DomainModel.Billing.Interval interval in returnIntervals)
        {
            ListItem item = new ListItem();
            item.Text = String.Format("{0} " + GetLocalResourceObject("TEXT_THROUGH").ToString() + " {1}", interval.StartDate.ToShortDateString(), interval.EndDate.Date.ToShortDateString());
            item.Value = interval.ID.ToString(); ;
            ddBillingPeriod.Items.Add(item);
        }

        MTDropDown d = new MTDropDown();
        ddReasonCode.EnumSpace = "metratech.com";
        ddReasonCode.EnumType = "SubscriberCreditAccountRequestReason";
        var enumType = MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType("metratech.com", "SubscriberCreditAccountRequestReason", Path.GetDirectoryName(new Uri(this.GetType().Assembly.CodeBase).AbsolutePath));

        if (enumType != null)
        {
            List<MetraTech.DomainModel.BaseTypes.EnumData> enums = BaseObject.GetEnumData(enumType);

            foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enums)
            {

                ListItem itm = new ListItem(enumData.DisplayName /*localized*/, enumData.EnumInstance.ToString());
                ddReasonCode.Items.Add(itm);
            }
        }
    }

  private bool ConvertToDecimal(string valForConversion, string fieldName, StringBuilder errorBuilder, out decimal? convertedVal)
  {
    bool result = true;
    convertedVal = null;
    try
    {
      if (!String.IsNullOrEmpty(valForConversion))
        convertedVal = Convert.ToDecimal(valForConversion);
    }
    catch (Exception)
    {
      errorBuilder.AppendLine(
        String.Format("Unable to convert value '{0}' of '{1}' field to decimal. Please, set decimal value.",
                      valForConversion, fieldName));
      result = false;
    }

    return result;
  }

  protected void btnOK_Click(object sender, EventArgs e)
    {
        PipelineMeteringHelper helper = null;
        
        StringBuilder errorBuilder = new StringBuilder();

        decimal? adjAmount, taxFederal, taxState, taxCounty, taxLocal, taxOther, totalAmount;
        totalAmount = null;
        
        bool errorOccurred = !ConvertToDecimal(adjAmountFld.Text, adjAmountFld.Label, errorBuilder, out adjAmount);

        if (!ConvertToDecimal(adjAmountFldTaxFederal.Text, adjAmountFldTaxFederal.Label, errorBuilder, out taxFederal))
          errorOccurred = true;

        if (!ConvertToDecimal(adjAmountFldTaxState.Text, adjAmountFldTaxState.Label, errorBuilder, out taxState))
          errorOccurred = true;

        if (!ConvertToDecimal(adjAmountFldTaxCounty.Text, adjAmountFldTaxCounty.Label, errorBuilder, out taxCounty))
          errorOccurred = true;

        if (!ConvertToDecimal(adjAmountFldTaxLocal.Text, adjAmountFldTaxLocal.Label, errorBuilder, out taxLocal))
          errorOccurred = true;

        if (!ConvertToDecimal(adjAmountFldTaxOther.Text, adjAmountFldTaxOther.Label, errorBuilder, out taxOther))
          errorOccurred = true;

        if (!errorOccurred)
        {
          totalAmount = CalcTotalAmount(adjAmount, taxFederal, taxState, taxCounty, taxLocal, taxOther);
          try
          {
              cache.PoolSize = 30;
              cache.PollingInterval = 0;
              helper = cache.GetMeteringHelper();

              // Create instance of data row for root service definition, row is already added to internal store
              DataRow row = helper.CreateRowForServiceDef("metratech.com/AccountCredit");
              row["CreditTime"] = MetraTime.Now;
              row["Status"] = MetraTech.DomainModel.Enums.Core.Metratech_com.SubscriberCreditAccountRequestStatus.APPROVED;
              row["RequestID"] = -1; // legacy code - -1 signifies there is no credit request
              row["_AccountID"] = UI.Subscriber.SelectedAccount._AccountID;
              row["_Currency"] = ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).Currency;
              row["EmailNotification"] = "N";
              string emailId = GetContactView().Email;
              if (String.IsNullOrEmpty(emailId))
                  row["EMailAddress"] = "";
              else
                  row["EMailAddress"] = emailId;
              row["EmailText"] = null;
              row["Issuer"] = UI.User.AccountId;
              object o = Enum.Parse(
                typeof(MetraTech.DomainModel.Enums.Core.Metratech_com.SubscriberCreditAccountRequestReason),
                ddReasonCode.SelectedValue, true);
              row["Reason"] = EnumHelper.GetDbValueByEnum(o);
              row["Other"] = "Other";

              if (String.IsNullOrEmpty(adjSubscriberDescriptionTextBox.Text))
                  row["InvoiceComment"] = GetLocalResourceObject("TEXT_MISCELLANEOUS_ADJUSTMENT");   
              else
                  row["InvoiceComment"] = adjSubscriberDescriptionTextBox.Text;
 
              row["InternalComment"] = adjDescriptionTextBox.Text;
              row["AccountingCode"] = null;
              row["ReturnCode"] = 0; // Legacy
              row["ContentionSessionID"] = "-"; // Legacy from 1.2
              if (totalAmount.HasValue) row["RequestAmount"] = -totalAmount;
              if (totalAmount.HasValue) row["CreditAmount"] = -totalAmount;
              row["GuideIntervalID"] = ddBillingPeriod.SelectedValue;
              row["ResolveWithAccountIDFlag"] = true;
              if (adjAmount.HasValue) row["_Amount"] = -adjAmount;
              if (taxFederal.HasValue) row["_FedTax"] = -taxFederal;
              if (taxState.HasValue) row["_StateTax"] = -taxState;
              if (taxCounty.HasValue) row["_CountyTax"] = -taxCounty;
              if (taxLocal.HasValue) row["_LocalTax"] = -taxLocal;
              if (taxOther.HasValue) row["_OtherTax"] = -taxOther;
              row["IgnorePaymentRedirection"] = 0;
              DataSet messages = helper.Meter(UI.User.SessionContext);
              helper.WaitForMessagesToComplete(messages, -1);

              DataTable dt = helper.GetMessageDetails(null);
              DataRow[] errorRows = dt.Select("ErrorMessage is not null");
              if (errorRows.Length != 0)
              {
                  var error = new StringBuilder();
                  // CORE-6182 Security: /MetraNet/MetraOffer/AmpGui/EditAccountGroup.aspx page is vulnerable to Cross-Site Scripting 
                  // Removed insecure formatting
                  //string errorMsg = String.Format("{0} <br/><br/>", GetLocalResourceObject("TEXT_PROCESSING_ERROR"));
                  string errorMsg = String.Format("{0} {1}{1}", GetLocalResourceObject("TEXT_PROCESSING_ERROR"), Environment.NewLine);
                  error.Append(errorMsg);

                  //ErrorMessage
                  //error.Append("<ul>");
                  error.Append(Environment.NewLine);
                  foreach (var errorRow in errorRows)
                  {
                      //error.Append("<li>");
                      error.Append(errorRow["ErrorMessage"]);
                      //error.Append("</li>");
                      error.Append(Environment.NewLine);
                  }
                  //error.Append("</ul>");
                  error.Append(Environment.NewLine);

                  CleanFailedTransactions(errorRows);
                  throw new MASBasicException(error.ToString());
              }
          }
          catch (Exception exp)
          {
              errorOccurred = true;
              SetError(exp.Message);
          }
          finally
          {
              cache.Release(helper);
          }
        }
        else
        {
          SetErrorValidation(errorBuilder.ToString());
        }

        if (!errorOccurred)
        {
          if (IsAllowedCreate(totalAmount ?? 0))
            {
              ConfirmMessage(String.Format("{0}", GetLocalResourceObject("TEXT_CREATED_TITLE")),
                               String.Format("{0}", GetLocalResourceObject("TEXT_CREATED")));
            }
            else
            {
              ConfirmMessage(String.Format("{0}", GetLocalResourceObject("TEXT_PENDING_TITLE")),
                               String.Format("{0}", GetLocalResourceObject("TEXT_PENDING")));
            }
        }
    }

  

  private static decimal? CalcTotalAmount(decimal? adjAmount, decimal? taxFederal, decimal? taxState, decimal? taxCounty,
                                          decimal? taxLocal, decimal? taxOther)
  {
    decimal? totalAmount = null;

    if (! (adjAmount == null
      && taxFederal == null
      && taxState == null
      && taxCounty == null
      && taxLocal == null
      && taxOther == null))
      totalAmount = adjAmount ?? 0 + taxFederal ?? 0 + taxState ?? 0 + taxCounty ?? 0 + taxLocal ?? 0 + taxOther ?? 0;

    return totalAmount;
  }

  private bool IsAllowedCreate(decimal totalAmount)
  {
    bool allowed = false;
    if (!UI.SessionContext.SecurityContext.IsSuperUser())
    {
      string max = GetMaxCapabilityAmount();
      string[] data = max.Split(' ');
      int last = data.Length - 1;
      // Build expression to have the DataTable evaluation based on the adjustment amount allowed
      // != not supported and needs to be passed as <>
      string op = data[last - 1];
      if (op.Equals("!="))
        op = "<>";
      string expr = String.Format("{0}{1}{2}", totalAmount, op, data[last]);
      DataTable dataTable = new DataTable();
      dataTable.Columns.Add("col1", typeof (bool), expr);
      dataTable.Rows.Add(new object[] {});
      object result = dataTable.Rows[0][0];
      allowed = System.Convert.ToBoolean(result);
    }
    else
      allowed = true;

    return allowed;
  }

  protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
    }

    private ContactView GetContactView()
    {
        ContactView contactView = null;
        bool foundView = false;

        Dictionary<string, List<MetraTech.DomainModel.BaseTypes.View>> viewDictionary = UI.Subscriber.SelectedAccount.GetViews();
        foreach (List<MetraTech.DomainModel.BaseTypes.View> views in viewDictionary.Values)
        {
            foreach (MetraTech.DomainModel.BaseTypes.View view in views)
            {
                ContactView cv = view as ContactView;
                if (cv != null && cv.ContactType == MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.ContactType.Bill_To)
                {
                    contactView = cv;
                    foundView = true;
                    break;
                }

                if (foundView == true)
                {
                    break;
                }
            }

            if (foundView == true)
            {
                break;
            }
        }

        return contactView;
    }

    private string GetMaxCapabilityAmount()
    {
        string amount = "-1";
        IMTSecurity security = new MTSecurityClass();
        var capabilites = UI.SessionContext.SecurityContext.GetCapabilitiesOfType("Apply Adjustments");

        foreach (ApplyAdjustmentsCapability cap in capabilites)
        {
            decimal authAmount = System.Convert.ToDecimal(cap.GetAtomicDecimalCapability().GetParameter().Value);
            string display = authAmount.ToString(MetraTech.UI.Common.Constants.NUMERIC_FORMAT_STRING_DECIMAL_MIN_TWO_DECIMAL_PLACES);
            amount = String.Format(" {0} {1} {2} {3}", GetLocalResourceObject("TEXT_MAX_AUTHORIZED_AMOUNT"), cap.GetAtomicEnumCapability().GetParameter().Value, cap.GetAtomicDecimalCapability().GetParameter().Test, display);
        }

        return amount;

    }

    // TODO: Need to move this to a library
    private void CleanFailedTransactions(DataRow[] errorRows)
    {
        string rawQuery = @"update t_failed_transaction set State='D' where id_failed_transaction in ({0})";

        string ids = "";
        foreach (var error in errorRows)
        {
            ids += error["FailureId"] + ",";
        }
        ids = ids.Trim(new char[] { ',' });

        rawQuery = String.Format(rawQuery, ids);

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(rawQuery))
            {
                prepStmt.ExecuteNonQuery();
            }
        }
    }

}