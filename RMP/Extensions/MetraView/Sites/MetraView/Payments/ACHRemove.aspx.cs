using System;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.ActivityServices.Common;

public partial class Payments_ACHRemove : MTPage
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
    set
    {
      ViewState["ACHCard"] = value;
    }
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

    if (Page.IsPostBack) return;
    try
    {
      var acct = UI.Subscriber.SelectedAccount._AccountID == null
                   ? null
                   : new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      var metraPayManger = new MetraPayManager(UI);
      var tmpACH = metraPayManger.GetPaymentMethodDetail(acct, PIID);
      ACHCard = (ACHPaymentMethod) tmpACH;
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_ACH_LOAD);
      Logger.LogError(ex.Message);
    }

    if (!MTDataBinder1.DataBind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      var acct = UI.Subscriber.SelectedAccount._AccountID == null
                   ? null
                   : new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      var metraPayManger = new MetraPayManager(UI);
      metraPayManger.DeletePaymentMethod(acct, PIID);
      Response.Redirect("ViewPaymentMethods.aspx", false);
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_ACH_REMOVE);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("ViewPaymentMethods.aspx");
  }
}