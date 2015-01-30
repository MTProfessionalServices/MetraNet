using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web;
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

public partial class NonStandardCharges_IssueNonStandardCharge :  MTPage
{
  public PipelineMeteringHelperCache cache
  {
    get
    {
      if (HttpContext.Current.Application["NonStandardChargePipelineMeteringHelperCache"] == null)
      {
        HttpContext.Current.Application.Lock();
        HttpContext.Current.Application["NonStandardChargePipelineMeteringHelperCache"] = new PipelineMeteringHelperCache("metratech.com/NonStandardCharge");
        HttpContext.Current.Application.UnLock();
      }
      return HttpContext.Current.Application["NonStandardChargePipelineMeteringHelperCache"] as PipelineMeteringHelperCache;
    }
  }

    protected void Page_Load(object sender, EventArgs e)
    {
      if (!Page.IsPostBack)
      {
        string maxAdjAmount = String.Format("{0} {1}", GetLocalResourceObject("TEXT_MAX_AUTHORIZED_AMOUNT"),
                                            GetLocalResourceObject("TEXT_UNLIMITED"));
        if (UI.SessionContext.SecurityContext.GetCapabilitiesOfType("Manage NonStandardCharges").Count == 0)
        {
          if (!UI.SessionContext.SecurityContext.IsSuperUser())
          {
            maxAdjAmount = GetMaxCapabilityAmount();
            /*lblMaxAmount.Text = String.Format("{0} {1}", maxAdjAmount,
                                              ((InternalView) UI.Subscriber.SelectedAccount.GetInternalView()).Currency);*/
          }
        }

        lblMaxAmount.Text = String.Format("{0} {1}", maxAdjAmount,
                                          ((InternalView) UI.Subscriber.SelectedAccount.GetInternalView()).Currency);
      }

      ddReasonCode.EnumSpace = "metratech.com/NonStandardCharge";
      ddReasonCode.EnumType = "NonStandardChargeReason";
      var enumType = MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType("metratech.com/NonStandardCharge", "NonStandardChargeReason", Path.GetDirectoryName(new Uri(this.GetType().Assembly.CodeBase).AbsolutePath));

      if (enumType != null)
      {
        List<MetraTech.DomainModel.BaseTypes.EnumData> enums = BaseObject.GetEnumData(enumType);

        foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enums)
        {
          ListItem itm = new ListItem(enumData.DisplayName /*localized*/, enumData.EnumInstance.ToString());
          ddReasonCode.Items.Add(itm);
        }
      }

      ddAdditionalCode.EnumSpace = "metratech.com/NonStandardCharge";
      ddReasonCode.EnumType = "AdditionalCode";

      var additionalEnumCodes = MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType("metratech.com/NonStandardCharge", "AdditionalCode", Path.GetDirectoryName(new Uri(this.GetType().Assembly.CodeBase).AbsolutePath));
      if (additionalEnumCodes != null)
      {
        List<MetraTech.DomainModel.BaseTypes.EnumData> enums = BaseObject.GetEnumData(additionalEnumCodes);

        foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enums)
        {
          ListItem itm = new ListItem(enumData.DisplayName, enumData.EnumInstance.ToString());
          ddAdditionalCode.Items.Add(itm);
        }
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
    }

    protected void btnOK_Click(object sender, EventArgs e)
    {
      PipelineMeteringHelper helper = null;      
      bool errorOccurred = false;
      bool allowed = false;
      

      decimal chargeAmount = 0.0M;
      decimal additionalRate = 1.0M;
      int quantity = 1;
      decimal rate = 1.0M;

      if (!String.IsNullOrEmpty(tbRate3.Text))
        additionalRate = Convert.ToDecimal(tbRate3.Text);

      if (!String.IsNullOrEmpty(tbQuantity.Text))
        quantity = Convert.ToInt32(tbQuantity.Text);
      
       if (!string.IsNullOrEmpty(tbRate.Text))
         rate = System.Convert.ToDecimal(tbRate.Text);

      chargeAmount = additionalRate * quantity * rate;
      try
      {  
        cache.PoolSize = 30;
        cache.PollingInterval = 0;
        helper = cache.GetMeteringHelper();

        // Create instance of data row for root service definition, row is already added to internal store
        DataRow row = helper.CreateRowForServiceDef("metratech.com/NonStandardCharge");
        row["_AccountID"] = UI.Subscriber.SelectedAccount._AccountID;
        row["NumUnits"] = quantity;
        row["Rate"] = rate;
        row["AdditionalRate"] = additionalRate;
        row["IssuerAccountId"] = UI.User.AccountId;
        row["AccountName"] = null;
        row["AccountNameSpace"] = null;
        row["GLCode"] = tbGLCode.Text;
        row["GuideIntervalID"] = ddBillingPeriod.SelectedValue;
        row["IssueTime"] = MetraTime.Now;
        row["Description"] = taDescription.Text;
        object o = Enum.Parse(typeof (MetraTech.DomainModel.Enums.Core.Metratech_com_NonStandardCharge.NonStandardChargeReason), ddReasonCode.SelectedValue, true);
        row["ReasonCode"] = EnumHelper.GetDbValueByEnum(o);
        row["_Currency"] = ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).Currency;
        object code = Enum.Parse(typeof(MetraTech.DomainModel.Enums.Core.Metratech_com_NonStandardCharge.AdditionalCode), ddAdditionalCode.SelectedValue, true);
        if (code == null)
          row["AdditionalCode"] = null;
        else
          row["AdditionalCode"] = EnumHelper.GetDbValueByEnum(code);

        row["Status"] = "P";
        row["InternalChargeId"] = -1;
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
        Session[MetraTech.UI.Common.Constants.ERROR] = exp.Message.ToString();
      }
      finally
      {
        cache.Release(helper);
      }

      if (!errorOccurred)
      {
        if ((!UI.SessionContext.SecurityContext.IsSuperUser()) && (UI.SessionContext.SecurityContext.GetCapabilitiesOfType("Manage NonStandardCharges")).Count == 0)
        {
          string max = GetMaxCapabilityAmount();
          string[] data = max.Split(' ');
          int last = data.Length - 1;

          // Build expression to have the DataTable evaluation based on the adjustment amount allowed
          var comparisonSymbol = data[last - 1];
          var maxCapAmountValue = Decimal.Parse(data[last]);
          string expr = String.Format(CultureInfo.InvariantCulture, "{0}{1}{2}", chargeAmount, comparisonSymbol, maxCapAmountValue);
          DataTable dataTable = new DataTable();
          dataTable.Columns.Add("col1", typeof(bool), expr);
          dataTable.Rows.Add(new object[] { });
          object result = dataTable.Rows[0][0];
          allowed = System.Convert.ToBoolean(result);
        }
        else
          allowed = true;

        if (!allowed)
        {
          ConfirmMessage(String.Format("{0}", GetLocalResourceObject("TEXT_PENDING_TITLE")),
                         String.Format("{0}", GetLocalResourceObject("TEXT_PENDING")));
        }
        else
        {
          ConfirmMessage(String.Format("{0}", GetLocalResourceObject("TEXT_CREATED_TITLE")),
                         String.Format("{0}", GetLocalResourceObject("TEXT_CREATED")));
        }       
      }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
    }

  private string GetMaxCapabilityAmount()
  {
    string amount = "-1";
    IMTSecurity security = new MTSecurityClass();
    var capabilites = UI.SessionContext.SecurityContext.GetCapabilitiesOfType("Apply NonStandardCharges");

    foreach (ApplyNonStandardChargesCapability cap in capabilites)
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