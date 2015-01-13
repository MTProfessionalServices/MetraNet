using System;
using System.Globalization;
using System.IO;
using System.Text;
using System.Linq;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.Xml;

public partial class Payments_CreditCardAdd : MTPage
{
  public CreditCardPaymentMethod CreditCard
  {
    get
    {
      if (ViewState["CreditCard"] == null)
      {
        ViewState["CreditCard"] = new CreditCardPaymentMethod();
      }
      return ViewState["CreditCard"] as CreditCardPaymentMethod;
    }
    set { ViewState["CreditCard"] = value; }
  }

  protected bool? UsePaymentBroker
  {
    get { return ViewState["UsePaymentBroker"] as bool?; }
    set { ViewState["UsePaymentBroker"] = value; }
  }

  protected string PaymentBrokerAddress
  {
    get { return ViewState["PaymentBrokerAddress"] as string; }
    set { ViewState["PaymentBrokerAddress"] = value; }
  }

  private bool PayNow
  {
    get { return !String.IsNullOrEmpty(Request.QueryString["pay"]); }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (IsPostBack) return;
    var rcd = new MetraTech.Interop.RCD.MTRcd();
    var configFile = Path.Combine(rcd.ExtensionDir, @"PaymentSvr\config\Gateway\Gateway.xml");
    if (!File.Exists(configFile))
      return;

    var doc = new MTXmlDocument();
    doc.Load(configFile);
    if (doc.GetNodeValueAsBool("/configuration/usePaymentBroker", false))
    {
      UsePaymentBroker = true;
      PaymentBrokerAddress = doc.GetNodeValueAsString("/configuration/paymentBrokerAddress", "dummy");
    }
    else
    {
      UsePaymentBroker = false;
    }

    var contactView = GetContactView();
    tbEmail.Text = contactView.Email;
    CreditCard.FirstName = contactView.FirstName;
    CreditCard.MiddleName = contactView.MiddleInitial;
    CreditCard.LastName = contactView.LastName;
    CreditCard.Street = contactView.Address1;
    CreditCard.Street2 = contactView.Address2;
    CreditCard.ZipCode = contactView.Zip;
    CreditCard.State = contactView.State;
    CreditCard.City = contactView.City;

    //set country default to USA
    var country = contactView.Country.ToString();
    CreditCard.Country = string.IsNullOrEmpty(country)
      ? PaymentMethodCountry.USA
      : (PaymentMethodCountry)Enum.Parse(typeof(PaymentMethodCountry), country);

    //populate priorities
    PopulatePriority();

    //populate months
    for (var i = 1; i <= 12; i++)
    {
      var monthNumStr = i.ToString(CultureInfo.InvariantCulture);
      var month = (i < 10) ? "0" + monthNumStr : monthNumStr;
      ddExpMonth.Items.Add(month);
    }

    //populate years
    var curYear = DateTime.Today.Year;
    for (var i = 0; i <= 20; i++)
    {
      ddExpYear.Items.Add((curYear + i).ToString(CultureInfo.InvariantCulture));
    }

    if (!MTDataBinder1.DataBind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

    PopulatePaymentData();
    PrepopulateSubscriberInformation();
    GetIsoCode();
    Response.AppendHeader("Access-Control-Allow-Origin", "*");
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (!MTDataBinder1.Unbind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }
    CreditCard.ExpirationDate = ddExpMonth.SelectedValue + "/" + ddExpYear.SelectedValue;
    CreditCard.ExpirationDateFormat = MTExpDateFormat.MT_MM_slash_YYYY;
    CreditCard.Priority = Int32.Parse(ddPriority.SelectedValue);
    CreditCard.AccountNumber = tbCCNumber.Text;
    CreditCard.SafeAccountNumber = tbCCSafeNumber.Text;
    try
    {
      if (UI.Subscriber.SelectedAccount._AccountID == null) return;
      var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);

      var metraPayManger = new MetraPayManager(UI);
      var paymentInstrumentId = metraPayManger.AddPaymentMethod(acct, CreditCard);

      if (!PayNow)
      {
        Response.Redirect("ViewPaymentMethods.aspx", false);
      }
      else
      {
        //call my page this way - Response.Redirect("CreditCardAdd.aspx?pay=true");
        var paymentData = (MetraPayManager.MakePaymentData) Session["MakePaymentData"];
        paymentData.PaymentInstrumentId = paymentInstrumentId.ToString();
        paymentData.Number = CreditCard.AccountNumber;
        paymentData.Type = CreditCard.CreditCardTypeValueDisplayName;
        Session["MakePaymentData"] = paymentData;
        Response.Redirect("ReviewPayment.aspx", false);
      }
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_CC_ADD);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(PayNow ? "MakePayment.aspx" : "ViewPaymentMethods.aspx");
  }

  #region Private methods

  private void PopulatePriority()
  {
    var totalCards = GetTotalCards() + 1;
    for (var i = 1; i <= totalCards; i++)
    {
      var item = i.ToString(CultureInfo.InvariantCulture);
      ddPriority.Items.Add(new ListItem(item, item));
    }
  }

  private int GetTotalCards()
  {
    var metraPayManger = new MetraPayManager(UI);
    var cardList = metraPayManger.GetPaymentMethodSummaries();
    return cardList.TotalRows > 0 ? cardList.TotalRows : 0;
  }

  private void PrepopulateSubscriberInformation()
  {
    var billManager = new BillManager(UI);
    var invoiceReport = billManager.GetInvoiceReport(true);
    if (invoiceReport == null) return;
    var invoiceAccount = invoiceReport.InvoiceHeader.PayeeAccount;
    if (invoiceAccount == null) return;
    tbFirstName.Text = invoiceAccount.FirstName;
    tbMiddleInitial.Text = invoiceAccount.MiddleInitial;
    tbLastName.Text = invoiceAccount.LastName;
    tbAddress.Text = invoiceAccount.Address1;
    tbAddress2.Text = invoiceAccount.Address2;
    tbCity.Text = invoiceAccount.City;
    tbState.Text = invoiceAccount.State;
    tbZipCode.Text = invoiceAccount.Zip;
  }

  private void PopulatePaymentData()
  {
    if (PayNow)
    {
      divPaymentData.Visible = true;
      var paymentData = (MetraPayManager.MakePaymentData)Session["MakePaymentData"];
      lcAmount.Text = paymentData.Amount.ToString();
      lcMethod.Text = paymentData.Method;
    }
    else
    {
      divPaymentData.Visible = false;
    }
  }

  private void GetIsoCode()
  {
    var sb = new StringBuilder();
    sb.Append("<script>");
    sb.Append("function GetIsoCode(countryName){");
    foreach (var val in Enum.GetValues(typeof(PaymentMethodCountry)).Cast<PaymentMethodCountry>())
    {
      sb.Append(String.Format("if (countryName == '{0}') return '{1}';", val, MetraTech.DomainModel.Enums.EnumHelper.GetValueByEnum(val)));
    }
    sb.Append("}");
    sb.Append("</script>");

    ClientScript.RegisterStartupScript(GetType(), "GetIsoCode", sb.ToString());
  }

  private ContactView GetContactView()
  {
    ContactView contactView = null;
    var viewDictionary = UI.Subscriber.SelectedAccount.GetViews();
    foreach (var views in viewDictionary.Values)
      foreach (MetraTech.DomainModel.BaseTypes.View view in views)
      {
        var cv = view as ContactView;
        if (cv != null && cv.ContactType == MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.ContactType.Bill_To)
        {
          contactView = cv;
          return contactView;
        }
      }
    return contactView;
  }

  #endregion
}