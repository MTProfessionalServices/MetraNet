using System;
using System.Globalization;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.Core.Services.ClientProxies;
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

  const string Checking = "Checking";
  const string Savings = "Savings";


  protected void Page_Load(object sender, EventArgs e)
  {
    if (IsPostBack) return;
    //populate priorities
    PopulatePriority();
    PopulateAccountType();

    if (!MTDataBinder1.DataBind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

    //set country default to USA
    ddCountry.SelectedValue = PaymentMethodCountry.USA.ToString();
  }

  protected void PopulatePriority()
  {
    var totalCards = GetTotalCards() + 1;

    for (var i = 1; i <= totalCards; i++)
    {
      var item = i.ToString(CultureInfo.InvariantCulture);
      ddPriority.Items.Add(new ListItem(item, item));
    }
  }

  protected void PopulateAccountType()
  {
    var checkingLocalized = GetLocalResourceObject(Checking);
    var savingLocalized = GetLocalResourceObject(Savings);
    if (checkingLocalized == null || savingLocalized == null)
      return;

    var checkItem = new ListItem
      {
        Text = checkingLocalized.ToString(),
        Value = Checking
      };
    var savItem = new ListItem
      {
        Text = savingLocalized.ToString(),
        Value = Savings
      };
    ddAccountType.Items.Add(checkItem);
    ddAccountType.Items.Add(savItem);
  }

  protected int GetTotalCards()
  {
    try
    {
      var client = InitRecurringPaymentsServiceClient();

      if (UI.Subscriber.SelectedAccount._AccountID != null)
      {
        var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        var cardList = new MTList<MetraPaymentMethod>();
        client.GetPaymentMethodSummaries(acct, ref cardList);
        client.Close();
        return cardList.TotalRows;
      }
      return 0;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw;
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (!MTDataBinder1.Unbind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }
    
    try
    {
      var client = InitRecurringPaymentsServiceClient();

      switch (ddAccountType.SelectedValue)
      {
        case Checking:
          ACHCard.AccountType = BankAccountType.Checking;
          break;

        case Savings:
          ACHCard.AccountType = BankAccountType.Savings;
          break;
      }

      ACHCard.Priority = Int32.Parse(ddPriority.SelectedValue);
      if (UI.Subscriber.SelectedAccount._AccountID != null)
      {
        var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        Guid paymentInstrumentID;
        client.AddPaymentMethod(acct, ACHCard, out paymentInstrumentID);
      }
      Response.Redirect("CreditCardList.aspx", false);
      client.Close();
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_ACH_ADD);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("CreditCardList.aspx");
  }

  private RecurringPaymentsServiceClient InitRecurringPaymentsServiceClient()
  {
    var client = new RecurringPaymentsServiceClient();

    if (client.ClientCredentials != null)
    {
      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
    }
    return client;
  }
}