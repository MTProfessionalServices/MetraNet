using System;
using System.Globalization;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;

public partial class Payments_ACHAdd : MTPage
{
  public ACHPaymentMethod ACHCard
  {
    get
    {
      if (ViewState["ACHCard"] == null)
      {
        ViewState["ACHCard"] = new ACHPaymentMethod();
      }
      return ViewState["ACHCard"] as ACHPaymentMethod;
    }
    set { ViewState["ACHCard"] = value; }
  }

  private bool PayNow
  {
    get { return !String.IsNullOrEmpty(Request.QueryString["pay"]); }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (IsPostBack) return;
    //populate priorities
    PopulatePriority();

    if (!MTDataBinder1.DataBind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

    //set country default to USA
    ddCountry.SelectedValue = PaymentMethodCountry.USA.ToString();

    PopulatePaymentData();
    PrepopulateSubscriberInformation();
  }
  
  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (!MTDataBinder1.Unbind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

    try
    {
      if (UI.Subscriber.SelectedAccount._AccountID == null) return;
      var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      ACHCard.AccountType = radChecking.Checked ? BankAccountType.Checking : BankAccountType.Savings;
      ACHCard.Priority = Int32.Parse(ddPriority.SelectedValue);

      var metraPayManger = new MetraPayManager(UI);
      var paymentInstrumentId = metraPayManger.AddPaymentMethod(acct, ACHCard);

      if (!PayNow)
      {
        Response.Redirect("ViewPaymentMethods.aspx", false);
      }
      else
      {
        var paymentData = (MetraPayManager.MakePaymentData) Session["MakePaymentData"];
        paymentData.PaymentInstrumentId = paymentInstrumentId.ToString();
        paymentData.Number = ACHCard.AccountNumber;
        paymentData.Type = ACHCard.AccountType.ToString();
        Session["MakePaymentData"] = paymentData;
        Response.Redirect("ReviewPayment.aspx", false);
      }
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_ACH_ADD);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(PayNow ? "MakePayment.aspx" : "ViewPaymentMethods.aspx");
  }

  #region Private methods

  protected void PopulatePriority()
  {
    var totalCards = GetTotalCards() + 1;

    for (var i = 1; i <= totalCards; i++)
    {
      var item = i.ToString(CultureInfo.InvariantCulture);
      ddPriority.Items.Add(new ListItem(item, item));
    }
  }

  protected int GetTotalCards()
  {
    var metraPayManger = new MetraPayManager(UI);
    var cardList = metraPayManger.GetPaymentMethodSummaries();
    return cardList.TotalRows > 0 ? cardList.TotalRows : 0;
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

  private void PrepopulateSubscriberInformation()
  {
    try
    {
      var billManger = new BillManager(UI);
      var invoiceReport = billManger.GetInvoiceReport(true);

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
    catch (Exception ex)
    {
      SetError(ex.Message);
      Logger.LogError(ex.Message);
    }
  }

  #endregion
}