using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using MetraTech.UI.Common;
using System.ServiceModel;
using System.Text.RegularExpressions;
using RCD = MetraTech.Interop.RCD;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.Xml;
using MetraTech;


public partial class Payments_MakePayment : MTPage
{
  private static string m_gatewayName = null;

  public InvoiceReport invoiceReport
  {
    get { return ViewState["InvoiceReport"] as InvoiceReport; }
    set { ViewState["InvoiceReport"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    SelectGateway();
    if (!IsPostBack)
    {
      var billManager = new BillManager(UI);
      PaymentInfo paymentInformation = billManager.PaymentInformation;

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
  }

  [Serializable]
  private struct ShortPaymentMethodInfo
  {
    public MetraPayManager.PaymentMethodType MethodType;// credit card or ACH
    public string Type;// account type (checking/saving) or credit card type (visa/MasterCard)
    public string Number;//account number of credit card number
  }

  private void PopulatePaymentMethodDropDown()
  {
    var billManager = new MetraPayManager(UI);
    MTList<MetraPaymentMethod> paymentMethods = billManager.GetPaymentMethodSummaries();
    Dictionary<string, ShortPaymentMethodInfo> shortPaymentMethodInfoList = new Dictionary<string, ShortPaymentMethodInfo>();
    int priority = int.MaxValue;
    string PriorityPaymentInstrumentId = null;
    foreach (MetraPaymentMethod pm in paymentMethods.Items)
    {
      string info = null;
      if (pm is CreditCardPaymentMethod)
      {
        CreditCardPaymentMethod ccpm = pm as CreditCardPaymentMethod;
        // remove *** from the account number
        string lastFourDigits = Regex.Replace(ccpm.AccountNumber, @"\**", "");
        string format = (string)GetLocalResourceObject("MSGFormat.CreditCard");
        info = string.Format(//"{0} card ending in {1}",
          format,
          ccpm.CreditCardTypeValueDisplayName,
          lastFourDigits);
        ShortPaymentMethodInfo shortPaymentMethodInfo = new ShortPaymentMethodInfo();
        //shortPaymentMethodInfo.Method = (string)GetLocalResourceObject("CreditDebitCard");
        shortPaymentMethodInfo.MethodType = MetraPayManager.PaymentMethodType.CreditCard;
        shortPaymentMethodInfo.Type = ccpm.CreditCardTypeValueDisplayName;
        shortPaymentMethodInfo.Number = ccpm.AccountNumber;
        shortPaymentMethodInfoList.Add(pm.PaymentInstrumentIDString, shortPaymentMethodInfo);
      }
      else if (pm is ACHPaymentMethod)
      {
        ACHPaymentMethod achpm = pm as ACHPaymentMethod;
        // remove *** from the account number
        string lastFourDigits = Regex.Replace(achpm.AccountNumber, @"\**", "");
        string format = (string)GetLocalResourceObject("MSGFormat.ACH");
        info = string.Format(//"{0} account in {1}",
          format,
          achpm.AccountType.ToString(),
          lastFourDigits);
        ShortPaymentMethodInfo shortPaymentMethodInfo = new ShortPaymentMethodInfo();
        //shortPaymentMethodInfo.Method = (string)GetLocalResourceObject("CheckingSavingsAccount");
        shortPaymentMethodInfo.MethodType = MetraPayManager.PaymentMethodType.ACH;
        shortPaymentMethodInfo.Type = achpm.AccountType.ToString();
        shortPaymentMethodInfo.Number = achpm.AccountNumber;
        shortPaymentMethodInfoList.Add(pm.PaymentInstrumentIDString, shortPaymentMethodInfo);
      }
      if (info != null)
      {
        ddPaymentMethod.Items.Add(new ListItem(info, pm.PaymentInstrumentIDString));
        // save the payment instrument id with lowest priority, select it by default
        if (pm.Priority.HasValue)
        {
          if (pm.Priority.Value < priority)
          {
            priority = pm.Priority.Value;
            PriorityPaymentInstrumentId = pm.PaymentInstrumentIDString;
          }
        }
      }      
    }
    // Save ShortPaymentInfoList so that this information can be passed to confirmation page
    ViewState["ShortPaymentInfoList"] = shortPaymentMethodInfoList;
    // select the item with the highest priority in the drop down.
    if (PriorityPaymentInstrumentId != null)
    {
      ListItem li = ddPaymentMethod.Items.FindByValue(PriorityPaymentInstrumentId);
      if (li != null) li.Selected = true;
    }


    if (paymentMethods.Items.Count == 0)
    {
      divExistingMethods.Visible = false;
    }
    else { divExistingMethods.Visible = true; }
  }

  private void PopulateTotalAmount()
  {
    var billManager = new BillManager(UI);
    PaymentInfo paymentInformation = billManager.PaymentInformation;

    decimal amountDueDecimal = paymentInformation.AmountDue;
    string amountDueString = string.Empty;

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

    string format = (string)GetLocalResourceObject("rcTotalAmountDue.BoxLabel");
    if (paymentInformation != null)
    {
      if (paymentInformation.AmountDue > 0)
      {
        rcTotalAmountDue.BoxLabel = string.Format(format,  paymentInformation.AmountDueAsString);
      }
      else
      {
        rcTotalAmountDue.BoxLabel = string.Format(format, 0M.ToDisplayAmount(UI));
      }
    }

    // CORE-5494 Use appropriate currency symbol after "Pay this Amount".
    InternalView iv = (InternalView)(UI.Subscriber.SelectedAccount.GetInternalView());
    LanguageCode langcode = iv.Language ?? LanguageCode.US;
    string curr = iv.Currency;
    string zeroAmtWithCurrencySymbol = billManager.GetLocaleTranslator(langcode).GetCurrency(0, curr);

    // Find the currency symbol itself.
    if (zeroAmtWithCurrencySymbol[0] != '0')
    {
      // Currency symbol is at beginning of string.
      int indexFirstZero = zeroAmtWithCurrencySymbol.IndexOf('0');
      string currencySymbol = zeroAmtWithCurrencySymbol.Substring(0, indexFirstZero);
      rcOtherAmount.BoxLabel = string.Format("{0}, {1}", (string)GetLocalResourceObject("rcOtherAmount.BoxLabel"), currencySymbol);
      lbTrailingCurrencySymbol.Text = String.Empty;
    }
    else
    {
      // Currency symbol is at end of string.
      int indexLastZero = zeroAmtWithCurrencySymbol.LastIndexOf('0');
      string currencySymbol = zeroAmtWithCurrencySymbol.Substring(indexLastZero + 1);
      rcOtherAmount.BoxLabel = string.Format("{0}", (string)GetLocalResourceObject("rcOtherAmount.BoxLabel"));
      lbTrailingCurrencySymbol.Text = currencySymbol;
    }
  }

  protected override void OnPreRender(EventArgs e)
  {
    base.OnPreRender(e);

    //string format = (string)GetLocalResourceObject("rcTotalAmountDue.BoxLabel");
    //rcTotalAmountDue.BoxLabel = string.Format(format, invoiceReport.PreviousBalances.CurrentBalanceAsString);
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(Request.ApplicationPath + "/Bill.aspx");
  }

  protected void btnNext_Click(object sender, EventArgs e)
  {
    try
    {
      //Response.Redirect("/MetraView/");
      MetraPayManager.MakePaymentData paymentData = new MetraPayManager.MakePaymentData();
      var billManager = new BillManager(UI);
      PaymentInfo paymentInformation = billManager.PaymentInformation;

      paymentData.Amount = 0;
      if (rcTotalAmountDue.Checked)
      {
        if (paymentInformation != null)
        {
          paymentData.Amount = paymentInformation.AmountDue;
        }

        if (paymentData.Amount <= 0)
        {
          throw new Exception((string)GetLocalResourceObject("TEXT_NO_PAYMENT_IS_DUE"));
        }
      }
      else
      {
        string amt = tbOtherAmount.Text;
        if (string.IsNullOrEmpty(amt))
        {
          throw new Exception((string)GetLocalResourceObject("TEXT_PAYMENT_AMOUNT_MUST_BE_POSITIVE"));
        }

        paymentData.Amount = Decimal.Parse(amt);

        if (paymentData.Amount <= 0)
        {
          throw new Exception((string)GetLocalResourceObject("TEXT_PAYMENT_AMOUNT_MUST_BE_POSITIVE"));
        }
      }

      paymentData.PaymentInstrumentId = null;
      if (rcExistingPaymentMethod.Checked)
      {
        if (ddPaymentMethod.SelectedValue == null)
        {
          throw new Exception((string)GetLocalResourceObject("TEXT_SELECT_PAYMENT_METHOD"));
        }
        paymentData.PaymentInstrumentId = ddPaymentMethod.SelectedValue;
        // Restore Method, Number and Type assosicated with paymentMethod info.
        // it was gingerly saved when populating ddPaymentMethod drop down with items
        Dictionary<string, ShortPaymentMethodInfo> shortPaymentMethodInfoList =
          (Dictionary<string, ShortPaymentMethodInfo>)ViewState["ShortPaymentInfoList"];
        ShortPaymentMethodInfo i = shortPaymentMethodInfoList[ddPaymentMethod.SelectedValue];
        paymentData.MethodType = i.MethodType;
        switch (i.MethodType)
        {
          case MetraPayManager.PaymentMethodType.CreditCard:
            paymentData.Method = (string)GetLocalResourceObject("CreditDebitCard");
            break;
          case MetraPayManager.PaymentMethodType.ACH:
            paymentData.Method = (string)GetLocalResourceObject("CheckingSavingsAccount");
            break;
          case MetraPayManager.PaymentMethodType.Unknown:
            paymentData.Method = (string)GetLocalResourceObject("UnknownText");
            break;
          default:
            break;
        }
        paymentData.Number = i.Number;
        paymentData.Type = i.Type;
      }
      paymentData.PayNow = rcPayNow.Checked;
      if (!paymentData.PayNow)
      {
        //string scheduledData = dpSchedulePaymentDate.Text;
        //paymentData.SchedulePaymentDate = Convert.ToDateTime(scheduledData);
        //paymentData.SchedulePaymentDate = DateTime.Parse(dpSchedulePaymentDate.Text);
        if (!DateTime.TryParse(dpSchedulePaymentDate.Text, out paymentData.SchedulePaymentDate))
        {
          throw new Exception((string)GetLocalResourceObject("TEXT_INVALID_SCHEDULED_DATE"));
        }
        paymentData.SchedulePaymentDate = paymentData.SchedulePaymentDate.FromUserDateToUtc(UI);
        if (paymentData.SchedulePaymentDate.Date <= MetraTime.Now.Date)
        {
          throw new Exception((string)GetLocalResourceObject("TEXT_INVALID_SCHEDULED_DATE"));
        }
      }
      else
      {
        paymentData.SchedulePaymentDate = MetraTime.Now;
      }

      if (paymentInformation != null)
      {
        paymentData.Currency = paymentInformation.Currency;
      }
      else
      {
        paymentData.Currency = ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).Currency;
      }
      //TODO: Need to use InvoiceDate, but it is not working without invoice
      //paymentData.InvoiceDate = invoiceReport.InvoiceHeader.IntervalEndDate;
      //paymentData.InvoiceDate = invoiceReport.InvoiceHeader.InvoiceDate;
      paymentData.InvoiceDate = MetraTime.Now;
      if (rcAddCreditCard.Checked)
      {
        paymentData.Method = (string)GetLocalResourceObject("CreditDebitCard");
        paymentData.MethodType = MetraPayManager.PaymentMethodType.CreditCard;
        Session["MakePaymentData"] = paymentData;

        Response.Redirect(m_gatewayName + "CreditCardAdd.aspx?pay=true", false);
      }
      else if (rcAddACHAccount.Checked)
      {
        paymentData.Method = (string)GetLocalResourceObject("CheckingSavingsAccount");
        paymentData.MethodType = MetraPayManager.PaymentMethodType.ACH;
        Session["MakePaymentData"] = paymentData;
        Response.Redirect("ACHAdd.aspx?pay=true", false);
      }
      else if (rcExistingPaymentMethod.Checked)
      {
        //MetraPayManager metraPayManger = new MetraPayManager(UI);
        //PaymentConfirmationData confirmationData = metraPayManger.MakePayment(paymentData);
        //Session["PaymentConfirmationData"] = confirmationData;
        //Response.Redirect("PayFinal.aspx");
        Session["MakePaymentData"] = paymentData;
        Response.Redirect("ReviewPayment.aspx", false);
      }

    }
    catch (Exception ex)
    {
      SetError(string.Format("{0}: {1}", GetGlobalResourceObject("ErrorMessages","ERROR").ToString(),ex.Message));
      this.Logger.LogError(ex.Message);
    }
  }
  //This is a placeholder for a real gateway selection algorithm if we ever get into a situation
  //  where we need to choose gateways based on some sort of criteria.
  private string SelectGateway()
  {
    if (m_gatewayName == null)
    {
      try
      {
        RCD.IMTRcd rcd = new RCD.MTRcd();
        string configFile = Path.Combine(rcd.ExtensionDir, "PaymentSvr\\config\\Gateway\\Gateway.xml");
        MTXmlDocument doc = new MTXmlDocument();
        doc.Load(configFile);

        m_gatewayName = doc.GetNodeValueAsString("/configuration/name", "");
      }
      catch
      {
        m_gatewayName = "";
      }
    }
    return m_gatewayName;
  }
}

