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

public partial class Payments_ACHRemove : MTPage
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

  protected void Page_Load(object sender, EventArgs e)
  {
    //Validate input
    if (String.IsNullOrEmpty(Request.QueryString["piid"]))
    {
      SetError(Resources.ErrorMessages.ERROR_ACH_LOAD);
      Logger.LogError("Error loading ACH info: empty PIID");
      return;
    }

    if (!Page.IsPostBack)
    {
      try
      {
        LoadPaymentMethod();
      }
      catch(Exception ex)
      {
        SetError(Resources.ErrorMessages.ERROR_ACH_LOAD);
        Logger.LogError(ex.Message);
      }

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }
    }
  }
  protected void btnOK_Click(object sender, EventArgs e)
  {

      RecurringPaymentsServiceClient client = null;
      try
      {
          client = new RecurringPaymentsServiceClient();
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

          AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
          client.DeletePaymentMethod(acct, PIID);
          Response.Redirect("CreditCardList.aspx", false);
          client.Close();
      }
      catch (Exception ex)
      {
          SetError(Resources.ErrorMessages.ERROR_ACH_REMOVE);
          Logger.LogError(ex.Message);
          client.Abort();
          throw;
      }

  }
  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("CreditCardList.aspx");
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
      client.Close();
    }
    catch (Exception e)
    {
      Logger.LogException("An unknown exception occurred.  Please check system logs.", e);
      client.Abort();
      throw;
    }
  }
}
