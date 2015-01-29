using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Auth.Capabilities;
using MetraTech.Core.CreditNotes;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.CreditNotes;
using MetraTech.DataAccess;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.UI.Common;
using RCD = MetraTech.Interop.RCD;

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

  private bool _creditNotesEnabled;
  private readonly RCD.IMTRcd _rcd = new RCD.MTRcd();
  
    protected void Page_Load(object sender, EventArgs e)
    {
      var client = new CreditNoteServiceClient();
      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      string reportingDir = Path.Combine(_rcd.ExtensionDir, "Reporting");
      if (Directory.Exists(reportingDir)) // check if Reporting extension exists
      {
        CreditNotePDFConfiguration config = null;
        client.GetCreditNoteConfigurationObject(ref config);
        _creditNotesEnabled = config.creditNotesEnabled;
      }

      if (!Page.IsPostBack)
        {
            adjAmountFld.DecimalSeparator
              = adjAmountFldTaxFederal.DecimalSeparator
                = adjAmountFldTaxState.DecimalSeparator
                = adjAmountFldTaxCounty.DecimalSeparator
                = adjAmountFldTaxLocal.DecimalSeparator
                = adjAmountFldTaxOther.DecimalSeparator
                = System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyDecimalSeparator;
            adjAmountFld.DecimalPrecision
               = adjAmountFldTaxFederal.DecimalPrecision
                = adjAmountFldTaxState.DecimalPrecision
                = adjAmountFldTaxCounty.DecimalPrecision
                = adjAmountFldTaxLocal.DecimalPrecision
                = adjAmountFldTaxOther.DecimalPrecision
              = Convert.ToString(System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyDecimalDigits);

            string maxAdjAmount = String.Format("{0} {1}", GetLocalResourceObject("TEXT_MAX_AUTHORIZED_AMOUNT"), GetLocalResourceObject("TEXT_UNLIMITED"));
            if (!UI.SessionContext.SecurityContext.IsSuperUser())
            {
                maxAdjAmount = GetMaxCapabilityAmount();
            }

            lblMaxAmount.Text = String.Format("{0} {1}", maxAdjAmount, ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).Currency);

          if (_creditNotesEnabled)
          {
            generateEnableControlsJS();
            PopulateCreditNotesTemplateTypes();
          }
          else
            CreditNotesPanelDiv.Attributes.Add("style", "display: none;");
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
            var itemText = String.Format("{0} " + GetLocalResourceObject("TEXT_THROUGH") + " {1}", interval.StartDate.ToShortDateString(), interval.EndDate.Date.ToShortDateString());
            var item = new ListItem {Text = itemText, Value = Convert.ToString(interval.ID)};
            ddBillingPeriod.Items.Add(item);
        }

        ddReasonCode.EnumSpace = "metratech.com";
        ddReasonCode.EnumType = "SubscriberCreditAccountRequestReason";
        var enumType = EnumHelper.GetGeneratedEnumType("metratech.com", "SubscriberCreditAccountRequestReason", Path.GetDirectoryName(new Uri(GetType().Assembly.CodeBase).AbsolutePath));

        if (enumType != null)
        {
            List<MetraTech.DomainModel.BaseTypes.EnumData> enums = BaseObject.GetEnumData(enumType);

            foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enums)
            {

                var itm = new ListItem(enumData.DisplayName /*localized*/, enumData.EnumInstance.ToString());
                ddReasonCode.Items.Add(itm);
            }
        }
    }

    private void PopulateCreditNotesTemplateTypes()
    {
        CreditNoteServiceClient client = null;

        try
        {
            client = new CreditNoteServiceClient();

            if (client.ClientCredentials != null)
            {
                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            LanguageCode? languageCode = ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).Language;

            var items = new MTList<CreditNoteTmpl>();
            client.GetCreditNoteTemplates(ref items, Convert.ToInt32(EnumHelper.GetValueByEnum(languageCode, 1)));
            if (items.Items.Count == 0)
            {
                items = new MTList<CreditNoteTmpl>();
                client.GetCreditNoteTemplates(ref items, Convert.ToInt32(EnumHelper.GetValueByEnum(LanguageCode.US, 1)));
            }

            foreach (var item in items.Items)
            {
                ddTemplateTypes.Items.Add(new ListItem(item.TemplateName, Convert.ToString(item.CreditNoteTemplateID)));
            }
        }
        catch (Exception ex)
        {
            Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
            throw;
        }
        finally
        {
            if (client != null)
            {
                client.Abort();
            }
        }
    }

    private void generateEnableControlsJS()
    {
        cbIssueCreditNote.Listeners = @"{ 'check' : this.enableControls, scope: this }";
        String scriptString = "<script language=\"javascript\" type=\"text/javascript\">\n";
        scriptString += "function enableControls() {\n";
        scriptString += "var dd = Ext.getCmp('" + ddTemplateTypes.ClientID + "');\n";
        scriptString += "var tb = Ext.getCmp('" + CommentTextBox.ClientID + "');\n";
        scriptString += "var cb = Ext.getCmp('" + cbIssueCreditNote.ClientID + "');\n";
        scriptString += "if (cb.checked)\n";
        scriptString += "{\n";
        scriptString += "dd.enable();\n";
        scriptString += "tb.enable();\n";
        scriptString += "} else {\n";
        scriptString += "dd.disable();\n";
        scriptString += "tb.disable();\n";
        scriptString += "}\n";
        scriptString += "}\n";
        scriptString += "</script>";

        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "enableControls", scriptString);
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

        var errorBuilder = new StringBuilder();

        decimal? adjAmount, taxFederal, taxState, taxCounty, taxLocal, taxOther, totalAmount;
        totalAmount = null;

        var errorOccurred = !ConvertToDecimal(adjAmountFld.Text, adjAmountFld.Label, errorBuilder, out adjAmount);

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
                long ticks = DateTime.UtcNow.Ticks;
                row["MiscAdjustmentID"] = ticks;
                if (_creditNotesEnabled && cbIssueCreditNote.Checked)
                {
                    row["IssueCreditNote"] = true;
                    row["CreditNoteTemplateId"] = ddTemplateTypes.SelectedValue;
                    row["CreditNoteComment"] = CommentTextBox.Text;
                }
                else
                {
                    row["IssueCreditNote"] = false;
                }

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

                // Issue the credit note if requested in the UI and if the Account Credit was metered successfully without needed approval first
                if (_creditNotesEnabled && IsAllowedCreate(totalAmount ?? 0) && cbIssueCreditNote.Checked)
                {
                    // get the account credit just metered
                    long sessionID = GetAccountCreditJustMetered(UI.Subscriber.SelectedAccount._AccountID.Value, ticks);

                    // Creating a credit note only if sessionid is non null
                    if (sessionID != -1)
                    {
                      CreateCreditNote(sessionID, Int32.Parse(ddTemplateTypes.SelectedValue), CommentTextBox.Text);
                    }
                    else
                    {
                        Logger.LogError("Failed to find Misc. Adjustment just created. Credit Note cannot be generated for AccountID " + UI.Subscriber.SelectedAccount._AccountID.Value);
                    }
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
                if (_creditNotesEnabled && cbIssueCreditNote.Checked)
                {
                    ConfirmMessage(String.Format("{0}", GetLocalResourceObject("TEXT_CREATED_TITLE")),
                                   String.Format("{0} {1}", GetLocalResourceObject("TEXT_CREATED"), GetLocalResourceObject("TEXT_CREDIT_NOTE_CREATED")));
                }
                else
                {
                    ConfirmMessage(String.Format("{0}", GetLocalResourceObject("TEXT_CREATED_TITLE")),
                                   String.Format("{0}", GetLocalResourceObject("TEXT_CREATED")));
                }
            }
            else
            {
                if (_creditNotesEnabled && cbIssueCreditNote.Checked)
                {
                    ConfirmMessage(String.Format("{0}", GetLocalResourceObject("TEXT_PENDING_TITLE")),
                                   String.Format("{0} {1}", GetLocalResourceObject("TEXT_PENDING"), GetLocalResourceObject("TEXT_CREDIT_NOTE_PENDING")));
                }
                else
                {
                    ConfirmMessage(String.Format("{0}", GetLocalResourceObject("TEXT_PENDING_TITLE")),
                                   String.Format("{0}", GetLocalResourceObject("TEXT_PENDING")));
                }
            }
        }
    }

    private void CreateCreditNote(long sessionId, int creditNoteTemplateID, string creditNoteDescription)
    {
        CreditNoteServiceClient client = null;
        try
        {
            client = new CreditNoteServiceClient();
            if (client.ClientCredentials != null)
            {
                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            Logger.LogDebug("Creating a Credit Note for AccountCredit with sessionid: {0}, AccountID: {1},  creditNoteTemplateID: {2}, creditNoteDescription: {3}",
                            sessionId, UI.Subscriber.SelectedAccount._AccountID.Value, creditNoteTemplateID, creditNoteDescription);
            
            client.CreateCreditNote(new List<Tuple<long, CreditNoteAdjustmentType>> { new Tuple<long,CreditNoteAdjustmentType>(sessionId, CreditNoteAdjustmentType.MiscAdjustment) }, UI.Subscriber.SelectedAccount._AccountID.Value,
                                    UI.SessionContext.ToXML(), creditNoteTemplateID, creditNoteDescription);
        }
        catch (Exception ex)
        {
            Logger.LogException("Failed in CreateCreditNote. An unknown exception occurred. Please check system logs.", ex);
            throw;
        }
        finally
        {
            if (client != null)
            {
                client.Abort();
            }
        }
    }

    /// <summary>
    /// Look up the SessionID for a metered AccountCredit
    /// </summary>
    /// <param name="accountID">The AccountID product view property of the approved AccountCredit transaction to search for</param>
    /// <param name="miscAdjustmentID">The miscAdjustmentID product view property of the approved AccountCredit transaction to search for</param>
    /// <returns>SessionID of the AccountCredit if found. Returns -1 if not found.</returns>
    private long GetAccountCreditJustMetered(int accountID, long miscAdjustmentID)
    {
        long sessionID = -1;
        AdjustmentsServiceClient client = null;

        try
        {
            client = new AdjustmentsServiceClient();

            if (client.ClientCredentials != null)
            {
                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            client.GetAccountCreditSessionID(accountID, miscAdjustmentID, out sessionID);

            if (sessionID <= 0)
            {
                throw new Exception(
                  "Could not find exact match for the miscellaneous adjustment just metered, so no credit note docuement will be issued if one was requested.");
            }
        }
        catch (MASBasicException masBasicEx)
        {
            Logger.LogError("Error retrieving Miscellaneous Adjustment SessionID: " + masBasicEx.Message);
            Logger.LogError("Error retrieving Miscellaneous Adjustment SessionID: " + masBasicEx.StackTrace);
        }
        catch (Exception ex)
        {
            Logger.LogError("Error retrieving Miscellaneous Adjustment: " + ex.Message);
            Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
        }
        finally
        {
            if (client != null)
            {
                client.Abort();
            }
        }
        return sessionID;
    }

    private static decimal? CalcTotalAmount(decimal? adjAmount, decimal? taxFederal, decimal? taxState, decimal? taxCounty,
                                            decimal? taxLocal, decimal? taxOther)
    {
        decimal? totalAmount = null;

        if (adjAmount == null
            && taxFederal == null
            && taxState == null
            && taxCounty == null
            && taxLocal == null
            && taxOther == null)
            totalAmount = null;
        else
        {
            adjAmount = adjAmount ?? 0;
            taxFederal = taxFederal ?? 0;
            taxState = taxState ?? 0;
            taxCounty = taxCounty ?? 0;
            taxLocal = taxLocal ?? 0;
            taxOther = taxOther ?? 0;

            totalAmount = adjAmount + taxFederal + taxState + taxCounty + taxLocal + taxOther;
        }


        return totalAmount;
    }

    private bool IsAllowedCreate(decimal totalAmount)
    {
      var allowed = true;
      if (!UI.SessionContext.SecurityContext.IsSuperUser())
      {
        var conditions = GetMaxCapabilityAmount().Split(';');
        for (var i = 0; allowed && i < conditions.Length; i++)
        {
          Func<decimal, decimal, bool> expression;
          string[] data = conditions[i].Trim().Split(' ');
          string op = data[data.Length - 3];
          switch (op)
          {
            case "=":
              expression = (x, y) => x == y;
              break;
            case "<>":
            case "!=":
              expression = (x, y) => x != y;
              break;
            case ">":
              expression = (x, y) => x > y;
              break;
            case ">=":
              expression = (x, y) => x >= y;
              break;
            case "<":
              expression = (x, y) => x < y;
              break;
            case "<=":
              expression = (x, y) => x <= y;
              break;
            default:
              expression = (x, y) => false;
              break;
          }
          allowed = expression(totalAmount, Convert.ToDecimal(data[data.Length - 2]));
        }
      }

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
                var cv = view as ContactView;
                if (cv != null && cv.ContactType == MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.ContactType.Bill_To)
                {
                    contactView = cv;
                    foundView = true;
                    break;
                }
            }

            if (foundView)
            {
                break;
            }
        }

        return contactView;
    }

    private string GetMaxCapabilityAmount()
    {
      string amount = "";
      string concop = "";
      var capabilites = UI.SessionContext.SecurityContext.GetCapabilitiesOfType("Apply Adjustments");

      foreach (ApplyAdjustmentsCapability cap in capabilites)
      {
        decimal authAmount = Convert.ToDecimal(cap.GetAtomicDecimalCapability().GetParameter().Value);
        string display = authAmount.ToString(MetraTech.UI.Common.Constants.NUMERIC_FORMAT_STRING_DECIMAL_MIN_TWO_DECIMAL_PLACES);
        amount = amount + concop +
           String.Format(" {0} {1} {2} {3}", GetLocalResourceObject("TEXT_MAX_AUTHORIZED_AMOUNT"),
                         cap.GetAtomicDecimalCapability().GetParameter().Test,
           display,
                         ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).Currency);
        concop = "; ";
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
        ids = ids.Trim(new[] { ',' });

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