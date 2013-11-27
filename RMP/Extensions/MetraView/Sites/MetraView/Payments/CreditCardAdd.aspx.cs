using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.IO;
using System.Text;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.Xml;
using System.ServiceModel;
using RCD = MetraTech.Interop.RCD;

public partial class Payments_CreditCardAdd : MTPage
{
  public CreditCardPaymentMethod CreditCard
  {
    get {
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
    var metraPayManger = new MetraPayManager(UI);
    MTList<MetraPaymentMethod> cardList = new MTList<MetraPaymentMethod>();
    cardList = metraPayManger.GetPaymentMethodSummaries();
    if (cardList.TotalRows > 0)
    {
      return cardList.TotalRows;
    }
    else
    {
      return 0;
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

          PopulatePaymentData();

          PrepopulateSubscriberInformation();
          GetIsoCode();
          Response.AppendHeader("Access-Control-Allow-Origin", "*");
      }
  }

  private void PrepopulateSubscriberInformation()
  {
    var billManager = new BillManager(UI);
    InvoiceReport invoiceReport = billManager.GetInvoiceReport(true);
    if (invoiceReport != null)
    {
      InvoiceAccount invoiceAccount = invoiceReport.InvoiceHeader.PayeeAccount;
      if (invoiceAccount != null)
      {
        tbFirstName.Text = invoiceAccount.FirstName;
        tbMiddleInitial.Text = invoiceAccount.MiddleInitial;
        tbLastName.Text = invoiceAccount.LastName;
        tbAddress.Text = invoiceAccount.Address1;
        tbAddress2.Text = invoiceAccount.Address2;
        tbCity.Text = invoiceAccount.City;
        tbState.Text = invoiceAccount.State;
        tbZipCode.Text = invoiceAccount.Zip;
      }
    }

  }

  private bool PayNow
  {
    get {
      return !String.IsNullOrEmpty(Request.QueryString["pay"]);
    }
  }

  private void PopulatePaymentData()
  {
    if (PayNow)
    {
      divPaymentData.Visible = true;
      MetraPayManager.MakePaymentData paymentData = (MetraPayManager.MakePaymentData)Session["MakePaymentData"];
      lcAmount.Text = paymentData.Amount.ToString();
      lcMethod.Text = paymentData.Method;
      //btnOK.Text = "Make a Payment";
    }
    else
    {
      divPaymentData.Visible = false;
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {

    if (!this.MTDataBinder1.Unbind())
    {
      this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
    }
    CreditCard.ExpirationDate = ddExpMonth.SelectedValue + "/" + ddExpYear.SelectedValue;
    CreditCard.ExpirationDateFormat = MTExpDateFormat.MT_MM_slash_YYYY;
    CreditCard.Priority = Int32.Parse(ddPriority.SelectedValue);
    //CreditCard.AccountNumber = tbCCNumber.Text.Replace("-", "");
    CreditCard.AccountNumber = tbCCNumber.Text;
    CreditCard.SafeAccountNumber = tbCCSafeNumber.Text;
    try
    {
      AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      Guid paymentInstrumentID;
      
      var metraPayManger = new MetraPayManager(UI);
      paymentInstrumentID = metraPayManger.AddPaymentMethod(acct, (MetraPaymentMethod)CreditCard);

      if (!PayNow)
      {
        Response.Redirect("ViewPaymentMethods.aspx", false);
        
      }
      else
      {
        //call my page this way - Response.Redirect("CreditCardAdd.aspx?pay=true");
        MetraPayManager.MakePaymentData paymentData = (MetraPayManager.MakePaymentData) Session["MakePaymentData"];
        paymentData.PaymentInstrumentId = paymentInstrumentID.ToString();
        paymentData.Number = CreditCard.AccountNumber;
        paymentData.Type = CreditCard.CreditCardTypeValueDisplayName;
        Session["MakePaymentData"] = paymentData;
        Response.Redirect("ReviewPayment.aspx", false);

        //PaymentConfirmationData confirmationData = metraPayManger.MakePayment(paymentData);
        //Session["PaymentConfirmationData"] = confirmationData;
        //Session["MakePaymentData"] = null; //clear it so nobody pays more than once
        //Response.Redirect("PayFinal.aspx");
        ////Response.Redirect("PayFinal.aspx?piid=" + paymentInstrumentID, false);
      }

    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_CC_ADD);
      this.Logger.LogError(ex.Message);
    }
  }
  protected void btnCancel_Click(object sender, EventArgs e)
  {
    if (PayNow)
    {
      Response.Redirect("MakePayment.aspx");
    }
    else
    {
      Response.Redirect("ViewPaymentMethods.aspx");
    }
  }
  private void GetIsoCode()
  {
      var sb = new StringBuilder();
      sb.Append("<script>");
      sb.Append("function GetIsoCode(countryName){");
      foreach (var val in Enum.GetValues(typeof(PaymentMethodCountry)).Cast<PaymentMethodCountry>())
      {
          sb.Append("if (countryName == '" + val.ToString() + "') return '" + MetraTech.DomainModel.Enums.EnumHelper.GetValueByEnum(val) + "';");
      }
      sb.Append("}");
      sb.Append("</script>");

      ClientScript.RegisterStartupScript(GetType(), "GetIsoCode", sb.ToString());
  }
}
