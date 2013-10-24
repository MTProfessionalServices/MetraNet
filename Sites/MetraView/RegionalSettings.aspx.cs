using System;
using MetraTech.Account.ClientProxies;
using MetraTech.UI.Common;

public partial class RegionalSettings: MTAccountPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    Session["ActiveMenu"] = "RegionalSettings";
 
    if (!IsPostBack)
    {
      Account = UI.Subscriber.SelectedAccount;
      ddTimeZone.SelectedValue = SiteConfig.Profile.Timezone.ToString();
      
      
      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }

    }
  }

  /// <summary>
  /// Update the account information
  /// </summary>
  /// <param name="sender"></param>
  /// <param name="e"></param>
  protected void btnOK_Click(object sender, EventArgs e)
  {
    Page.Validate();
    if (Page.IsValid)
    {
      MTDataBinder1.Unbind();
      
      SiteConfig.Profile.Timezone = Internal.TimezoneID;

      try
      {
        var update = new AccountCreation_UpdateAccount_Client();
        update.In_Account = Account;
        update.UserName = UI.User.UserName;
        update.Password = UI.User.SessionPassword;
        update.In_LoadTime = ApplicationTime;
        update.Invoke();

        UI.Subscriber.SelectedAccount = Account;
        Response.Redirect(UI.DictionaryManager["AccountInfoSuccessPage"].ToString(), false);
      }
      catch (Exception ex)
      {
        Session[Constants.ERROR] = Resources.ErrorMessages.ERROR_UPDATING_ACCOUNT;
        Logger.LogError(ex.Message);
      }
  
    }
  }

  /// <summary>
  /// Cancel the page and return to the default page (Usually the dashboard)
  /// </summary>
  /// <param name="sender"></param>
  /// <param name="e"></param>
  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString());
  }

}
