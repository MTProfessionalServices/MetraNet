using System;
using System.IO;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using System.Text.RegularExpressions;
using RCD = MetraTech.Interop.RCD;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.Xml;
using MetraTech;

public partial class Payments_MakePayment : MTPage
{
  private static string _mGatewayName;

  public InvoiceReport InvoiceReport
  {
    get { return ViewState["InvoiceReport"] as InvoiceReport; }
    set { ViewState["InvoiceReport"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    SelectGateway();
    if (IsPostBack) return;
    PopulateTotalAmount();
    PopulatePaymentMethodDropDown();
    rcTotalAmountDue.Checked = true;

    dpSchedulePaymentDate.MinValue = MetraTime.Now.AddDays(1).ToUserDateString(UI);
    rcPayNow.Checked = true;
    if (ddPaymentMethod.Items.Count > 0)
    {
      rcExistingPaymentMethod.Checked = true;
    }
    else
    {
      rcAddCreditCard.Checked = true;
      // if there is no existing payment method - disable the controls to avoid confusion
      rcExistingPaymentMethod.Enabled = false;
      ddPaymentMethod.Enabled = false;
    }
  }

  [Serializable]
  private struct ShortPaymentMethodInfo
  {
    public MetraPayManager.PaymentMethodType MethodType; // credit card or ACH
    public string Type; // account type (checking/saving) or credit card type (visa/MasterCard)
    public string Number; //account number of credit card number
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(Request.ApplicationPath + "/Bill.aspx");
  }

  protected void btnNext_Click(object sender, EventArgs e)
  {
    try
    {
      var paymentData = new MetraPayManager.MakePaymentData();
      var billManager = new BillManager(UI);
      var paymentInformation = billManager.PaymentInformation;

      paymentData.Amount = 0;
      if (rcTotalAmountDue.Checked)
      {
        if (paymentInformation != null)
        {
          paymentData.Amount = paymentInformation.AmountDue;
        }

        if (paymentData.Amount <= 0)
        {
          throw new Exception((string) GetLocalResourceObject("TEXT_NO_PAYMENT_IS_DUE"));
        }
      }
      else
      {
        var amt = tbOtherAmount.Text;
        if (string.IsNullOrEmpty(amt))
        {
          throw new Exception((string) GetLocalResourceObject("TEXT_PAYMENT_AMOUNT_MUST_BE_POSITIVE"));
        }

        paymentData.Amount = Decimal.Parse(amt);

        if (paymentData.Amount <= 0)
        {
          throw new Exception((string) GetLocalResourceObject("TEXT_PAYMENT_AMOUNT_MUST_BE_POSITIVE"));
        }
      }

      paymentData.PaymentInstrumentId = null;
      if (rcExistingPaymentMethod.Checked)
      {
        if (ddPaymentMethod.SelectedValue == null)
        {
          throw new Exception((string) GetLocalResourceObject("TEXT_SELECT_PAYMENT_METHOD"));
        }
        paymentData.PaymentInstrumentId = ddPaymentMethod.SelectedValue;
        // Restore Method, Number and Type assosicated with paymentMethod info.
        // it was gingerly saved when populating ddPaymentMethod drop down with items
        var shortPaymentMethodInfoList = (Dictionary<string, ShortPaymentMethodInfo>) ViewState["ShortPaymentInfoList"];
        var i = shortPaymentMethodInfoList[ddPaymentMethod.SelectedValue];
        paymentData.MethodType = i.MethodType;
        switch (i.MethodType)
        {
          case MetraPayManager.PaymentMethodType.CreditCard:
            paymentData.Method = (string) GetLocalResourceObject("CreditDebitCard");
            break;
          case MetraPayManager.PaymentMethodType.ACH:
            paymentData.Method = (string) GetLocalResourceObject("CheckingSavingsAccount");
            break;
          case MetraPayManager.PaymentMethodType.Unknown:
            paymentData.Method = (string) GetLocalResourceObject("UnknownText");
            break;
        }
        paymentData.Number = i.Number;
        paymentData.Type = i.Type;
      }
      paymentData.PayNow = rcPayNow.Checked;
      if (!paymentData.PayNow)
      {
        if (!DateTime.TryParse(dpSchedulePaymentDate.Text, out paymentData.SchedulePaymentDate))
        {
          throw new Exception((string) GetLocalResourceObject("TEXT_INVALID_SCHEDULED_DATE"));
        }
        paymentData.SchedulePaymentDate = paymentData.SchedulePaymentDate.FromUserDateToUtc(UI);
        if (paymentData.SchedulePaymentDate.Date <= MetraTime.Now.Date)
        {
          throw new Exception((string) GetLocalResourceObject("TEXT_INVALID_SCHEDULED_DATE"));
        }
      }
      else
      {
        paymentData.SchedulePaymentDate = MetraTime.Now;
      }

      paymentData.Currency = paymentInformation != null ? paymentInformation.Currency : ((InternalView) UI.Subscriber.SelectedAccount.GetInternalView()).Currency;
      //TODO: Need to use InvoiceDate, but it is not working without invoice
      //paymentData.InvoiceDate = invoiceReport.InvoiceHeader.IntervalEndDate;
      //paymentData.InvoiceDate = invoiceReport.InvoiceHeader.InvoiceDate;
      paymentData.InvoiceDate = MetraTime.Now;
      if (rcAddCreditCard.Checked)
      {
        paymentData.Method = (string) GetLocalResourceObject("CreditDebitCard");
        paymentData.MethodType = MetraPayManager.PaymentMethodType.CreditCard;
        Session["MakePaymentData"] = paymentData;

        Response.Redirect(_mGatewayName + "CreditCardAdd.aspx?pay=true", false);
      }
      else if (rcAddACHAccount.Checked)
      {
        paymentData.Method = (string) GetLocalResourceObject("CheckingSavingsAccount");
        paymentData.MethodType = MetraPayManager.PaymentMethodType.ACH;
        Session["MakePaymentData"] = paymentData;
        Response.Redirect("ACHAdd.aspx?pay=true", false);
      }
      else if (rcExistingPaymentMethod.Checked)
      {
        Session["MakePaymentData"] = paymentData;
        Response.Redirect("ReviewPayment.aspx", false);
      }

    }
    catch (Exception ex)
    {
      SetError(string.Format("{0}: {1}", GetGlobalResourceObject("ErrorMessages", "ERROR"), ex.Message));
      Logger.LogError(ex.Message);
    }
  }

  #region Private methods

  private void PopulatePaymentMethodDropDown()
  {
    var billManager = new MetraPayManager(UI);
    var paymentMethods = billManager.GetPaymentMethodSummaries();
    var shortPaymentMethodInfoList = new Dictionary<string, ShortPaymentMethodInfo>();
    var priority = int.MaxValue;
    string priorityPaymentInstrumentId = null;
    foreach (var pm in paymentMethods.Items)
    {
      string info = null;
      if (pm is CreditCardPaymentMethod)
      {
        var ccpm = pm as CreditCardPaymentMethod;
        // remove *** from the account number
        var lastFourDigits = Regex.Replace(ccpm.AccountNumber, @"\**", "");
        var format = (string)GetLocalResourceObject("MSGFormat.CreditCard");
        if (format != null) info = string.Format(format, ccpm.CreditCardTypeValueDisplayName, lastFourDigits);
        var shortPaymentMethodInfo = new ShortPaymentMethodInfo
        {
          MethodType = MetraPayManager.PaymentMethodType.CreditCard,
          Type = ccpm.CreditCardTypeValueDisplayName,
          Number = ccpm.AccountNumber
        };
        shortPaymentMethodInfoList.Add(pm.PaymentInstrumentIDString, shortPaymentMethodInfo);
      }
      else if (pm is ACHPaymentMethod)
      {
        var achpm = pm as ACHPaymentMethod;
        // remove *** from the account number
        var lastFourDigits = Regex.Replace(achpm.AccountNumber, @"\**", "");
        var format = (string)GetLocalResourceObject("MSGFormat.ACH");
        if (format != null) info = string.Format(format, ExtensionMethods.GetLocalizedBankAccountType(achpm.AccountType.ToString()), lastFourDigits);
        var shortPaymentMethodInfo = new ShortPaymentMethodInfo
        {
          MethodType = MetraPayManager.PaymentMethodType.ACH,
          Type = achpm.AccountType.ToString(),
          Number = achpm.AccountNumber
        };
        shortPaymentMethodInfoList.Add(pm.PaymentInstrumentIDString, shortPaymentMethodInfo);
      }
      if (info == null) continue;
      ddPaymentMethod.Items.Add(new ListItem(info, pm.PaymentInstrumentIDString));
      // save the payment instrument id with lowest priority, select it by default
      if (!pm.Priority.HasValue || pm.Priority.Value >= priority) continue;
      priority = pm.Priority.Value;
      priorityPaymentInstrumentId = pm.PaymentInstrumentIDString;
    }
    // Save ShortPaymentInfoList so that this information can be passed to confirmation page
    ViewState["ShortPaymentInfoList"] = shortPaymentMethodInfoList;
    // select the item with the highest priority in the drop down.
    if (priorityPaymentInstrumentId != null)
    {
      var li = ddPaymentMethod.Items.FindByValue(priorityPaymentInstrumentId);
      if (li != null) li.Selected = true;
    }

    divExistingMethods.Visible = paymentMethods.Items.Count != 0;
  }

  private void PopulateTotalAmount()
  {
    var billManager = new BillManager(UI);
    var paymentInformation = billManager.PaymentInformation;

    var amountDueDecimal = paymentInformation.AmountDue;
    var amountDueString = string.Empty;

    if (amountDueDecimal <= 0)
    {
      rcTotalAmountDue.Visible = false;
      rcTotalAmountDue.Style.Add("display", "none");
      rcOtherAmount.Checked = true;
    }
    else
    {
      rcTotalAmountDue.Visible = true;
      rcTotalAmountDue.Checked = true;
      amountDueString = paymentInformation.AmountDueAsString;
    }

    rcTotalAmountDue.BoxLabel = amountDueString;

    var format = (string)GetLocalResourceObject("rcTotalAmountDue.BoxLabel");
    if (paymentInformation != null && format != null)
    {
      rcTotalAmountDue.BoxLabel = string.Format(format, paymentInformation.AmountDue > 0 ? paymentInformation.AmountDueAsString : 0M.ToDisplayAmount(UI));
    }

    // CORE-5494 Use appropriate currency symbol after "Pay this Amount".
    var iv = (InternalView)(UI.Subscriber.SelectedAccount.GetInternalView());
    var langcode = iv.Language ?? LanguageCode.US;
    var curr = iv.Currency;
    var zeroAmtWithCurrencySymbol = billManager.GetLocaleTranslator(langcode).GetCurrency(0, curr);

    // Find the currency symbol itself.
    if (zeroAmtWithCurrencySymbol[0] != '0')
    {
      // Currency symbol is at beginning of string.
      var indexFirstZero = zeroAmtWithCurrencySymbol.IndexOf('0');
      var currencySymbol = zeroAmtWithCurrencySymbol.Substring(0, indexFirstZero);
      rcOtherAmount.BoxLabel = string.Format("{0}, {1}", GetLocalResourceObject("rcOtherAmount.BoxLabel"),
                                             currencySymbol);
      lbTrailingCurrencySymbol.Text = String.Empty;
    }
    else
    {
      // Currency symbol is at end of string.
      var indexLastZero = zeroAmtWithCurrencySymbol.LastIndexOf('0');
      var currencySymbol = zeroAmtWithCurrencySymbol.Substring(indexLastZero + 1);
      rcOtherAmount.BoxLabel = string.Format("{0}", GetLocalResourceObject("rcOtherAmount.BoxLabel"));
      lbTrailingCurrencySymbol.Text = currencySymbol;
    }
  }

  /// <summary>
  /// This is a placeholder for a real gateway selection algorithm if we ever get into a situation
  /// where we need to choose gateways based on some sort of criteria.
  /// </summary>
  /// <returns></returns>
// ReSharper disable UnusedMethodReturnValue.Local
  private static string SelectGateway()
// ReSharper restore UnusedMethodReturnValue.Local
  {
    if (_mGatewayName == null)
    {
      try
      {
        RCD.IMTRcd rcd = new RCD.MTRcd();
        var configFile = Path.Combine(rcd.ExtensionDir, "PaymentSvr\\config\\Gateway\\Gateway.xml");
        var doc = new MTXmlDocument();
        doc.Load(configFile);

        _mGatewayName = doc.GetNodeValueAsString("/configuration/name", "");
      }
      catch
      {
        _mGatewayName = "";
      }
    }
    return _mGatewayName;
  }

  #endregion
}