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
using System.ServiceModel;

public partial class Payments_CreditCardUpdate : MTPage
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
      SetError(Resources.ErrorMessages.ERROR_CC_LOAD);
      Logger.LogError("Unable to load Credit Card: empty PIID");
      return;
    }

    if (!IsPostBack)
    {
      //populate priorities
      PopulatePriority();

      for (int i = 1; i <= 12; i++)
      {
        String month = (i < 10) ? "0" + i.ToString() : i.ToString();
        ddExpMonth.Items.Add(month);
      }

      int curYear = DateTime.Today.Year;
      for (int i = 0; i <= 20; i++)
      {
        ddExpYear.Items.Add((curYear + i).ToString());
      }

      try
      {
        LoadPaymentMethod();
      }
      catch(Exception ex)
      {
        SetError(Resources.ErrorMessages.ERROR_CC_LOAD);
        Logger.LogError(ex.Message);
        return;
      }

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }

      //populate exp month and year
      LoadExpDate();
      
      //load current priority
      LoadPriority();

    }
  }

  protected void LoadPriority()
  {
    int priority = 0;

    if (CreditCard.Priority.HasValue)
    {
      priority = CreditCard.Priority.Value;
    }

    ddPriority.SelectedValue = priority.ToString();
  }

  protected void LoadExpDate()
  {
    if (String.IsNullOrEmpty(CreditCard.ExpirationDate))
    {
      return;
    }

    string expMonth;
    string expYear;

    CreditCard.GetExpirationDate(out expMonth, out expYear);

    ddExpMonth.SelectedValue = expMonth;
    ddExpYear.SelectedValue = expYear;
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

        CreditCard = (CreditCardPaymentMethod)tmpCC;
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
      CreditCard.ExpirationDate = ddExpMonth.SelectedValue + "/" + ddExpYear.SelectedValue;
      CreditCard.ExpirationDateFormat = MTExpDateFormat.MT_MM_slash_YYYY;

      int oldPriority = CreditCard.Priority.Value;
      CreditCard.Priority = Int32.Parse(ddPriority.SelectedValue);

      RecurringPaymentsServiceClient client = null;
      try
      {
          client = new RecurringPaymentsServiceClient();

          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

          AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
          client.UpdatePaymentMethod(acct, PIID, CreditCard);

          if (CreditCard.Priority.Value != oldPriority)
          {
              client.UpdatePriority(acct, PIID, CreditCard.Priority.Value);
          }

          Response.Redirect("CreditCardList.aspx", false);
          client.Close();
      }
      catch (Exception ex)
      {
          SetError(Resources.ErrorMessages.ERROR_CC_UPDATE);
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
