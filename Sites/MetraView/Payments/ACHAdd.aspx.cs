using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.Billing;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using System.ServiceModel;

public partial class Payments_ACHAdd : MTPage
{
  public ACHPaymentMethod ACHCard
  {
    get {
      if (ViewState["ACHCard"] == null)
      {
        ViewState["ACHCard"] = new ACHPaymentMethod();
      }
      return ViewState["ACHCard"] as ACHPaymentMethod; 
    }
    set { ViewState["ACHCard"] = value; }
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
    if(cardList.TotalRows > 0)
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
      //populate priorities
      PopulatePriority();

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }

      //set country default to USA
      ddCountry.SelectedValue = PaymentMethodCountry.USA.ToString();

      PopulatePaymentData();
     PrepopulateSubscriberInformation();
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

  private void PrepopulateSubscriberInformation()
  {
    try
    {
      var billManger = new BillManager(UI);
      InvoiceReport invoiceReport = billManger.GetInvoiceReport(true);

      if (invoiceReport!= null)
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
    catch(Exception ex)
    {
      SetError(ex.Message);
      this.Logger.LogError(ex.Message);
    }

  }

  private bool PayNow
  {
    get
    {
      return !String.IsNullOrEmpty(Request.QueryString["pay"]);
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {

    if (!this.MTDataBinder1.Unbind())
    {
      this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
    }

      try
      {
           AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
           ACHCard.AccountType = radChecking.Checked ? BankAccountType.Checking : BankAccountType.Savings;
           ACHCard.Priority = Int32.Parse(ddPriority.SelectedValue);

           Guid paymentInstrumentID;
           var metraPayManger = new MetraPayManager(UI);
           paymentInstrumentID = metraPayManger.AddPaymentMethod(acct, (MetraPaymentMethod)ACHCard);
       
          if (!PayNow)
          {
            Response.Redirect("ViewPaymentMethods.aspx", false);
          }
          else
          {
            MetraPayManager.MakePaymentData paymentData = (MetraPayManager.MakePaymentData)Session["MakePaymentData"];
            paymentData.PaymentInstrumentId = paymentInstrumentID.ToString();
            paymentData.Number = ACHCard.AccountNumber;
            paymentData.Type = ACHCard.AccountType.ToString();
            Session["MakePaymentData"] = paymentData;
            Response.Redirect("ReviewPayment.aspx", false);
          }

      }
      catch (Exception ex)
      {
          SetError(Resources.ErrorMessages.ERROR_ACH_ADD);
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
  
}
