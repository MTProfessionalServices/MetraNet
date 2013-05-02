using System;
using MetraTech.Account.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;


public partial class GoPaperless: MTAccountPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    Session["ActiveMenu"] = "InvoiceMethod";
 
    if (!IsPostBack)
    {
      Account = UI.Subscriber.SelectedAccount;
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
      
      try
      {
        InternalView internalView = (InternalView)Account.GetInternalView();
        internalView.InvoiceMethod = MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.InvoiceMethod.None;

        var update = new AccountCreation_UpdateAccount_Client();
        update.In_Account = Account;
        update.UserName = UI.User.UserName;
        update.Password = UI.User.SessionPassword;
        update.Invoke();

        UI.Subscriber.SelectedAccount = Account;
        Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString(), false);
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
