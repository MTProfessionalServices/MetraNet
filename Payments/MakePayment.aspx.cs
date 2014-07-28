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

using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.AccountTypes;
using RCD = MetraTech.Interop.RCD;
using MetraTech.Xml;
using MetraTech;


public partial class Payments_MakePayment : MTPage
{
  public enum PaymentMethodType : byte { CreditCard, ACH, Unknown };

  private static string m_gatewayName = null;
  
  public class MakePaymentData
  {
    public decimal Amount;
    public string PaymentInstrumentId;
    public bool PayNow;
    public DateTime SchedulePaymentDate;
    public string Currency;
    public DateTime InvoiceDate;
    //Need both method and method type as no easy way to check type from string
    //and no easy way to get localized value outside the Master page
    public PaymentMethodType MethodType;
    public string Method; // credit card or ACH
    public string Type;// account type (checking/saving) or credit card type (visa/MasterCard)
    public string Number;//account number of credit card number
  }

  public PaymentInfo GetPaymentInfo(int accID)
  {
    UsageHistoryServiceClient client = null;
    try
    {
      client = new UsageHistoryServiceClient();
      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      PaymentInfo paymentInfo = new PaymentInfo();
      AccountIdentifier identifier = new AccountIdentifier(accID);

      client.GetPaymentInfo(identifier, GetLanguageCode(), ref paymentInfo);

      return paymentInfo;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception(GetLocalResourceObject("TEXT_RETRIEVE_PAYMENT_ERROR").ToString(), ex);
    }
  }


  public MTList<MetraPaymentMethod> GetPaymentMethodSummaries()
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    RecurringPaymentsServiceClient client = null;

    try
    {
      client = new RecurringPaymentsServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      var cardList = new MTList<MetraPaymentMethod>();
      client.GetPaymentMethodSummaries(acct, ref cardList);

      client.Close();
      client = null;
      return cardList;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception(GetLocalResourceObject("TEXT_RETRIEVE_PAYMENT_METHODS_ERROR").ToString(), ex);
    }
    finally
    {
      if (client != null)
      {
        client.Abort();
      }
    }
  }


  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      PaymentInfo paymentInformation = GetPaymentInfo((int) UI.Subscriber.SelectedAccount._AccountID);

      PopulateTotalAmount();
      PopulatePaymentMethodDropDown();
      rcTotalAmountDue.Checked = true;

      dpSchedulePaymentDate.MinValue = MetraTime.Now.AddDays(1).ToShortDateString();
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
    public PaymentMethodType MethodType;// credit card or ACH
    public string Type;// account type (checking/saving) or credit card type (visa/MasterCard)
    public string Number;//account number of credit card number
  }

  private void PopulatePaymentMethodDropDown()
  {
    MTList<MetraPaymentMethod> paymentMethods = GetPaymentMethodSummaries();
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
        shortPaymentMethodInfo.MethodType = PaymentMethodType.CreditCard;
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
          ExtensionMethods.GetLocalizedBankAccountType(achpm.AccountType.ToString()),
          lastFourDigits);
        ShortPaymentMethodInfo shortPaymentMethodInfo = new ShortPaymentMethodInfo();
        shortPaymentMethodInfo.MethodType = PaymentMethodType.ACH;
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
    PaymentInfo paymentInformation = GetPaymentInfo((int)UI.Subscriber.SelectedAccount._AccountID);

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
        rcTotalAmountDue.BoxLabel = string.Format(format, 0M);
      }
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("/MetraNet/Welcome.aspx");
  }

  protected void btnNext_Click(object sender, EventArgs e)
  {
    try
    {
      MakePaymentData paymentData = new MakePaymentData();
      PaymentInfo paymentInformation = GetPaymentInfo(UI.SessionContext.AccountID); 

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
          case PaymentMethodType.CreditCard:
            paymentData.Method = (string)GetLocalResourceObject("CreditDebitCard");
            break;
          case PaymentMethodType.ACH:
            paymentData.Method = (string)GetLocalResourceObject("CheckingSavingsAccount");
            break;
          case PaymentMethodType.Unknown:
            paymentData.Method = (string)GetLocalResourceObject("TEXT_UNKNOWN");
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
        //paymentData.SchedulePaymentDate = paymentData.SchedulePaymentDate;//.FromUserDateToUtc(UI);
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
      paymentData.InvoiceDate = MetraTime.Now;
      if (rcAddCreditCard.Checked)
      {
        paymentData.Method = (string)GetLocalResourceObject("CreditDebitCard");
        paymentData.MethodType = PaymentMethodType.CreditCard;
        Session["MakePaymentData"] = paymentData;
        Response.Redirect(SelectGateway() + "CreditCardAdd.aspx?pay=true", false);
      }
      else if (rcAddACHAccount.Checked)
      {
        paymentData.Method = (string)GetLocalResourceObject("CheckingSavingsAccount");
        paymentData.MethodType = PaymentMethodType.ACH;
        Session["MakePaymentData"] = paymentData;
        Response.Redirect("ACHAdd.aspx?pay=true", false);
      }
      else if (rcExistingPaymentMethod.Checked)
      {
        //BillManager billManager = new BillManager(UI);
        //PaymentConfirmationData confirmationData = billManager.MakePayment(paymentData);
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

