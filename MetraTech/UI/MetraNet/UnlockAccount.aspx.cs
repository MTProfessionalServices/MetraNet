using System;
using MetraTech.UI.Common;
using UIConstants = MetraTech.UI.Common.Constants;
using MetraTech.Security;
using MetraTech.DataAccess;
using MetraTech.Interop.MetraTime;

public partial class UnlockAccount : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      if(UI.Subscriber.SelectedAccount != null)
      {
        Auth auth = new Auth();
        auth.Initialize(UI.Subscriber.SelectedAccount.UserName, UI.Subscriber.SelectedAccount.Name_Space);

        if (auth.Credentials.LastLoginDate == MetraTech.MetraTime.Max)
        {
          lblMessage.Text += Resources.ErrorMessages.ERROR_NEVER_LOGGED;
        }
        else
        {
          lblMessage.Text += String.Format(Resources.ErrorMessages.ERROR_LAST_LOGIN,
                                             auth.Credentials.UserName,
                                             auth.Credentials.LastLoginDate,
                                             auth.Credentials.NumberOfFailuresSinceLogin);
        }

        if(auth.Credentials.NumberOfFailuresSinceLogin > PasswordConfig.GetInstance().LoginAttemptsAllowed)
        {
          lblMessage.Text += String.Format(Resources.ErrorMessages.ERROR_TEMP_LOCK, PasswordConfig.GetInstance().LoginAttemptsAllowed, PasswordConfig.GetInstance().MinutesBeforeAutoResetPassword);
        }

        if (auth.CheckIfAccountIsDormant())
        {
          lblMessage.Text += Resources.ErrorMessages.ERROR_ACCOUNT_DORMANT;
        }
      }
      else
      {
        Session[UIConstants.ERROR] = Resources.ErrorMessages.ERROR_SUBSCRIBER_NULL;
      }
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
  }

  // LOCK ACCOUNT
  protected void btnLock_Click(object sender, EventArgs e)
  {
    string url = null;

    try
    {
      Auth auth = new Auth();
      auth.Initialize(UI.Subscriber.SelectedAccount.UserName, UI.Subscriber.SelectedAccount.Name_Space);
      if (auth.LockAccount(UI.SessionContext))
      {
        // Account lock successful
        url = UI.DictionaryManager["DashboardPage"].ToString();
      }
      else
      {
        Session[UIConstants.ERROR] = Resources.ErrorMessages.ERROR_UNABLE_TO_UNLOCK_ACCOUNT;
      }
    }
    catch (Exception exp)
    {
      Session[UIConstants.ERROR] = exp.Message;
    }

    if(!String.IsNullOrEmpty(url))
    {
      Response.Redirect(url);  // we redirect outside of exception
    }
  }

  // UNLOCK ACCOUNT
  protected void btnUnLock_Click(object sender, EventArgs e)
  {
    string url = null;
    try
    {
      Auth auth = new Auth();
      auth.Initialize(UI.Subscriber.SelectedAccount.UserName, UI.Subscriber.SelectedAccount.Name_Space);
      if (auth.UnlockAccount(UI.SessionContext))
      {
        // Account unlock successful
        url = UI.DictionaryManager["DashboardPage"].ToString();
      }
      else
      {
        Session[UIConstants.ERROR] = Resources.ErrorMessages.ERROR_UNABLE_TO_UNLOCK_ACCOUNT;
      }
    }
    catch (Exception exp)
    {
      Session[UIConstants.ERROR] = exp.Message;
    }

    if (!String.IsNullOrEmpty(url))
    {
      Response.Redirect(url);  // we redirect outside of exception
    }
  }
}