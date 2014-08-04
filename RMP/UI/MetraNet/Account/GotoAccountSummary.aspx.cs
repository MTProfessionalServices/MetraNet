using System;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
public partial class GotoAccountSummary : MTPage
{
  public Account ActiveAccount
  {
    get
    {
      return UI.Subscriber.SelectedAccount; 
    }
  }

  public InternalView Internal
  {
    get { return Utils.GetProperty(ActiveAccount, "Internal") as InternalView; }
    set { Internal = value; }
  }  

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!Page.IsPostBack)
    {
      //Response.Redirect("/MetraNet/Account/AccountLandingPage.aspx");
      string summaryPage = ActiveAccount.AccountType.ToUpper() + "_SUMMARYPAGE";
      if(UI.DictionaryManager.Exist(summaryPage))
      {
        Response.Redirect(UI.DictionaryManager[summaryPage].ToString());
      }
      else
      {
        Response.Redirect(UI.DictionaryManager["DEFAULT_SUMMARYPAGE"].ToString());
      }
    }
  }
  
}
