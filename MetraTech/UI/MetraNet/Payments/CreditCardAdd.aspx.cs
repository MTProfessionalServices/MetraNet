using System;
using System.IO;
using System.Text;
using System.Linq;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
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

  protected void PopulatePriority()
  {
    int totalCards = GetTotalCards() + 1;

    for (int i = 1; i <= totalCards; i++)
    {
      ddPriority.Items.Add(new ListItem(i.ToString(), i.ToString()));
    }
  }

  protected int GetTotalCards()
  {
    RecurringPaymentsServiceClient client = null;

    try
    {
      client = new RecurringPaymentsServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      MTList<MetraPaymentMethod> cardList = new MTList<MetraPaymentMethod>();
      client.GetPaymentMethodSummaries(acct, ref cardList);
      client.Close();
      return cardList.TotalRows;
    }

    catch (Exception ex)
    {
      this.Logger.LogError(ex.Message);
      client.Abort();
      throw;
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();
      string configFile = Path.Combine(rcd.ExtensionDir, @"PaymentSvr\config\Gateway\Gateway.xml");
      if (!File.Exists(configFile))
        return;

      MTXmlDocument doc = new MTXmlDocument();
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
      //populate priorities
      PopulatePriority();

      //populate months
      for (int i = 1; i <= 12; i++)
      {
        String month = (i < 10) ? "0" + i.ToString() : i.ToString();
        ddExpMonth.Items.Add(month);
      }

      //populate years
      int curYear = DateTime.Today.Year;
      for (int i = 0; i <= 20; i++)
      {
        ddExpYear.Items.Add((curYear + i).ToString());
      }

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }

      //set country default to USA
      ddCountry.SelectedValue = PaymentMethodCountry.USA.ToString();

      GetIsoCode();
      Response.AppendHeader("Access-Control-Allow-Origin", "*");
    }
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
    CreditCard.AccountNumber = paymentInstrumentId.Value;
    CreditCard.SafeAccountNumber = tbCCNumber.Text;
    
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
}