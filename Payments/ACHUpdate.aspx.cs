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
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using System.ServiceModel;


public partial class Payments_ACHUpdate : MTPage
{
  private Guid PIID
  {
    get
    {
      String sPIID = Request.QueryString["piid"];
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
          return 0;
          throw;
      }      
  }

  protected void PopulatePriority()
  {
    int totalCards = GetTotalCards();

    for (int i = 1; i <= totalCards; i++)
    {
      ddPriority.Items.Add(new ListItem(i.ToString(), i.ToString()));
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

    if (!IsPostBack)
    {
      //populate priorities
      PopulatePriority();

      try
      {
        LoadPaymentMethod();
      }
      catch(Exception ex)
      {
        SetError(Resources.ErrorMessages.ERROR_ACH_LOAD);
        Logger.LogError(ex.Message);
        return;
      }

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }
      
      //load current priority
      LoadPriority();

    }
  }

  protected void LoadPriority()
  {
    int priority = 0;

    if (ACHCard.Priority.HasValue)
    {
      priority = ACHCard.Priority.Value;
    }

    ddPriority.SelectedValue = priority.ToString();
  }
  

  protected void LoadPaymentMethod()
  {
    RecurringPaymentsServiceClient client = null;

    try
    {
        client = new RecurringPaymentsServiceClient();

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);

        MetraPaymentMethod tmpCC;
        client.GetPaymentMethodDetail(acct, PIID, out tmpCC);

        ACHCard = (ACHPaymentMethod)tmpCC;
        BankAccountType AcctType = (BankAccountType)ACHCard.AccountType;
        object localResourceObject = null;
        switch (AcctType)
        {
          case BankAccountType.Checking:
            localResourceObject = GetLocalResourceObject("CheckingText");
            break;
          case BankAccountType.Savings:
            localResourceObject = GetLocalResourceObject("SavingsText");
            break;
        }
        tbAccountType.Text = localResourceObject != null ? localResourceObject.ToString() : ACHCard.AccountType.ToString();

        client.Close();
    }
    catch (Exception e)
    {
      Logger.LogException("An unexpected error occurred", e);
      client.Abort();
      throw;
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {

      if (!this.MTDataBinder1.Unbind())
      {
          this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }
    

      int oldPriority =  ACHCard.Priority.Value;
      ACHCard.Priority = Int32.Parse(ddPriority.SelectedValue);

      RecurringPaymentsServiceClient client = null;
      try
      {
          client = new RecurringPaymentsServiceClient();

          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

          AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
          client.UpdatePaymentMethod(acct, PIID, ACHCard);

          if (ACHCard.Priority.Value != oldPriority)
          {
              client.UpdatePriority(acct, PIID, ACHCard.Priority.Value);
          }

          Response.Redirect("CreditCardList.aspx", false);
          client.Close();
      }
      catch (Exception ex)
      {
          SetError(Resources.ErrorMessages.ERROR_ACH_UPDATE);
          Logger.LogError(ex.Message);
          client.Abort();
          throw;
      }

  }
  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("CreditCardList.aspx");
  }
}
