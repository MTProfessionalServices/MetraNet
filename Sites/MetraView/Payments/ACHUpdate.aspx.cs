using System;
using System.Globalization;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
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

  protected void Page_Load(object sender, EventArgs e)
  {
    //Validate input
    if (String.IsNullOrEmpty(Request.QueryString["piid"]))
    {
      SetError(Resources.ErrorMessages.ERROR_ACH_LOAD);
      Logger.LogError("Unable to load ACH Card: empty PIID");
      return;
    }

    if (IsPostBack) return;
    //populate priorities
    PopulatePriority();
    try
    {
      //Load payment method
      if (UI.Subscriber.SelectedAccount._AccountID != null)
      {
        var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        var metraPayManger = new MetraPayManager(UI);
        var tmpACH = metraPayManger.GetPaymentMethodDetail(acct, PIID);
        ACHCard = (ACHPaymentMethod)tmpACH;
      }
      tbAccountType.Text = ExtensionMethods.GetLocalizedBankAccountType(ACHCard.AccountType.ToString());
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

  protected int GetTotalCards()
  {
    var metraPayManger = new MetraPayManager(UI);
    var cardList = metraPayManger.GetPaymentMethodSummaries();
    return cardList.TotalRows > 0 ? cardList.TotalRows : 0;
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

  protected void LoadPriority()
  {
    var priority = 0;

    if (ACHCard.Priority.HasValue)
    {
      priority = ACHCard.Priority.Value;
    }

    ddPriority.SelectedValue = priority.ToString(CultureInfo.InvariantCulture);
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
      if (UI.Subscriber.SelectedAccount._AccountID != null)
      {
        var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        var metraPayManger = new MetraPayManager(UI);
        metraPayManger.UpdatePaymentMethod(acct, PIID, ACHCard, oldPriority);
      }

      Response.Redirect("ViewPaymentMethods.aspx", false);
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_ACH_UPDATE);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("ViewPaymentMethods.aspx");
  }
}