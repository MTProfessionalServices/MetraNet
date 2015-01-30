using System;
using System.Globalization;
using System.IO;
using System.Text;
using System.Linq;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.Core.Services.ClientProxies;
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
    set
    {
      ViewState["CreditCard"] = value;
    }
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

  protected string CreditCardTypeErrorMessage { get { return (string) GetLocalResourceObject("CreditCardTypeError"); } }

  protected void PopulatePriority()
  {
    var totalCards = GetTotalCards() + 1;

    for (var i = 1; i <= totalCards; i++)
    {
      ddPriority.Items.Add(new ListItem(i.ToString(CultureInfo.CurrentCulture), i.ToString(CultureInfo.CurrentCulture)));
    }
  }

  protected int GetTotalCards()
  {
    var client = new RecurringPaymentsServiceClient();
    try
    {
      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      var cardList = new MTList<MetraPaymentMethod>();
      client.GetPaymentMethodSummaries(acct, ref cardList);
      client.Close();
      return cardList.TotalRows;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      client.Abort();
      throw;
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (IsPostBack) return;
    
    MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();
    var configFile = Path.Combine(rcd.ExtensionDir, @"PaymentSvr\config\Gateway\Gateway.xml");
    if (!File.Exists(configFile))
      return;

    var doc = new MTXmlDocument();
    doc.Load(configFile);
    UsePaymentBroker = false;
    if (doc.GetNodeValueAsBool("/configuration/usePaymentBroker", false))
    {
      UsePaymentBroker = true;
      PaymentBrokerAddress = doc.GetNodeValueAsString("/configuration/paymentBrokerAddress", "dummy");
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
      var month = (i < 10) ? "0" + i.ToString(CultureInfo.CurrentCulture) : i.ToString(CultureInfo.CurrentCulture);
      ddExpMonth.Items.Add(month);
    }
    
    //populate years
    var curYear = DateTime.Today.Year;
    for (var i = 0; i <= 20; i++)
    {
      ddExpYear.Items.Add((curYear + i).ToString(CultureInfo.CurrentCulture));
    }

    if (!MTDataBinder1.DataBind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

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
    CreditCard.AccountNumber = UsePaymentBroker == true ? paymentInstrumentId.Value : tbCCNumber.Text;
    CreditCard.SafeAccountNumber = UsePaymentBroker == true ? tbCCNumber.Text : string.Empty;
    
    var client = new RecurringPaymentsServiceClient();
    try
    {
      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      Guid instrumentId;
      client.AddPaymentMethod(acct, CreditCard, out instrumentId);
      Response.Redirect("CreditCardList.aspx", false);
      client.Close();
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_CC_ADD);
      Logger.LogError(ex.Message);
      client.Abort();
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("CreditCardList.aspx");
  }

  private void GetIsoCode()
  {
    var sb = new StringBuilder();
    sb.Append("<script>");
    sb.Append("function GetIsoCode(countryName){");
    foreach (var val in Enum.GetValues(typeof (PaymentMethodCountry)).Cast<PaymentMethodCountry>())
    {
      sb.Append("if (countryName == '" + val.ToString() + "') return '" +
                MetraTech.DomainModel.Enums.EnumHelper.GetValueByEnum(val) + "';");
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
}