using System;
using System.Globalization;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;

public partial class Payments_ACHUpdate : MTPage
{
  private Guid PIID
  {
    get
    {
      var sPIID = Request.QueryString["piid"];
      if (String.IsNullOrEmpty(sPIID))
      {
        return new Guid();
      }

      try
      {
        return new Guid(sPIID);
      }
      catch
      {
        return new Guid();
      }
    }
  }

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

  protected int GetTotalCards()
  {
    RecurringPaymentsServiceClient client = null;
    try
    {
      client = new RecurringPaymentsServiceClient();

      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      if (UI.Subscriber.SelectedAccount._AccountID != null)
      {
        var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        var cardList = new MTList<MetraPaymentMethod>();
        client.GetPaymentMethodSummaries(acct, ref cardList);
        client.Close();
        return cardList.TotalRows;
      }
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      if (client != null) client.Abort();
    }
    return 0;
  }

  protected void PopulatePriority()
  {
    var totalCards = GetTotalCards();

    for (var i = 1; i <= totalCards; i++)
    {
      var item = i.ToString(CultureInfo.InvariantCulture);
      ddPriority.Items.Add(new ListItem(item, item));
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    //Validate input
    if (String.IsNullOrEmpty(Request.QueryString["piid"]))
    {
      SetError(Resources.ErrorMessages.ERROR_ACH_LOAD);
      Logger.LogError("Unable to load ACH info: empty PIID");
      return;
    }

    if (IsPostBack) return;
    //populate priorities
    PopulatePriority();

    try
    {
      LoadPaymentMethod();
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_ACH_LOAD);
      Logger.LogError(ex.Message);
      return;
    }

    if (!MTDataBinder1.DataBind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

    //load current priority
    LoadPriority();
  }

  protected void LoadPriority()
  {
    var priority = 0;

    if (ACHCard.Priority.HasValue)
    {
      priority = ACHCard.Priority.Value;
    }

    ddPriority.SelectedValue = priority.ToString(CultureInfo.InvariantCulture);
  }

  protected void LoadPaymentMethod()
  {
    try
    {
      var client = InitRecurringPaymentsServiceClient();

      if (UI.Subscriber.SelectedAccount._AccountID != null)
      {
        var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);

        MetraPaymentMethod tmpCC;
        client.GetPaymentMethodDetail(acct, PIID, out tmpCC);

        ACHCard = (ACHPaymentMethod) tmpCC;
        tbAccountType.Text = ExtensionMethods.GetLocalizedBankAccountType(ACHCard.AccountType.ToString());
      }
      client.Close();
    }
    catch (Exception e)
    {
      Logger.LogException("An unexpected error occurred", e);
      throw;
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {

    if (!MTDataBinder1.Unbind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

    if (ACHCard.Priority == null) return;
    var oldPriority = ACHCard.Priority.Value;
    ACHCard.Priority = Int32.Parse(ddPriority.SelectedValue);

    try
    {
      var client = InitRecurringPaymentsServiceClient();

      if (UI.Subscriber.SelectedAccount._AccountID != null)
      {
        var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        client.UpdatePaymentMethod(acct, PIID, ACHCard);

        if (ACHCard.Priority.Value != oldPriority)
        {
          client.UpdatePriority(acct, PIID, ACHCard.Priority.Value);
        }
      }

      Response.Redirect("CreditCardList.aspx", false);
      client.Close();
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_ACH_UPDATE);
      Logger.LogError(ex.Message);
      throw;
    }
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

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("CreditCardList.aspx");
  }
}