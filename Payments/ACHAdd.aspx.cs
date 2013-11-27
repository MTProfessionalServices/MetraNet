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

  protected void PopulateAccountType()
  {

    ListItem checkItem = new ListItem();
    checkItem.Text = GetLocalResourceObject("Checking").ToString();
    checkItem.Value = GetLocalResourceObject("Checking").ToString();
    ddAccountType.Items.Add(checkItem);

    ListItem savItem = new ListItem();
    savItem.Text = GetLocalResourceObject("Savings").ToString();
    savItem.Value = GetLocalResourceObject("Savings").ToString();
    ddAccountType.Items.Add(savItem);
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
      //populate priorities
      PopulatePriority();
      PopulateAccountType();

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }

      //set country default to USA
      ddCountry.SelectedValue = PaymentMethodCountry.USA.ToString();
    }
  }
  protected void btnOK_Click(object sender, EventArgs e)
  {

    if (!this.MTDataBinder1.Unbind())
    {
      this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
    }
    
      RecurringPaymentsServiceClient client = null;

      try
      {
          client = new RecurringPaymentsServiceClient();

          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

          switch (ddAccountType.SelectedValue)
          {
            case "Checking":
              ACHCard.AccountType = BankAccountType.Checking;
              break;

            case "Savings":
              ACHCard.AccountType = BankAccountType.Savings;
              break;
          }

          ACHCard.Priority = Int32.Parse(ddPriority.SelectedValue);
          Guid paymentInstrumentID;
          AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
          client.AddPaymentMethod(acct, ACHCard, out paymentInstrumentID);
          Response.Redirect("CreditCardList.aspx", false);
          client.Close();
      }
      catch (Exception ex)
      {
          SetError(Resources.ErrorMessages.ERROR_ACH_ADD);
          this.Logger.LogError(ex.Message);
          client.Abort();
      }
  }
  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("CreditCardList.aspx");
  }
}
