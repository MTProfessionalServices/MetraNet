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
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;

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
    var metraPayManger = new MetraPayManager(UI);
    MTList<MetraPaymentMethod> cardList = new MTList<MetraPaymentMethod>();
    cardList = metraPayManger.GetPaymentMethodSummaries();
    if (cardList.TotalRows > 0)
    {
      return cardList.TotalRows;
    }
    else
    {
      return 0;
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
      Logger.LogError("Unable to load ACH Card: empty PIID");
      return;
    }

    if (!IsPostBack)
    {
      //populate priorities
      PopulatePriority();
      try
      {
        //Load payment method
        AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        MetraPaymentMethod tmpACH;
        var metraPayManger = new MetraPayManager(UI);
        tmpACH = metraPayManger.GetPaymentMethodDetail(acct, PIID);
        ACHCard = (ACHPaymentMethod)tmpACH;
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
  

  

  protected void btnOK_Click(object sender, EventArgs e)
  {

      if (!this.MTDataBinder1.Unbind())
      {
          this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }
      int oldPriority = ACHCard.Priority.Value;
      ACHCard.Priority = Int32.Parse(ddPriority.SelectedValue);

      try
      {
          AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
          var metraPayManger = new MetraPayManager(UI);
          metraPayManger.UpdatePaymentMethod(acct, PIID, ACHCard, oldPriority);

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
