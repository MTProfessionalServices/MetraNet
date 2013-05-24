using System;
using System.Collections.Generic;
using System.Text;

using System.Data;
using MetraTech.DomainModel.Common;
using MetraTech.UI.Tools;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuth;
using MetraTech.Security;

namespace MetraTech.UI.Common
{

  public class ActiveSubscriber
  {
    /// <summary>
    /// Gets or sets the ticket.
    /// </summary>
    /// <value>The ticket.</value>
    /// <remarks></remarks>
    private static string Ticket { get; set; }

    /// <summary>
    /// Session Context for the active subscriber
    /// </summary>
    private IMTSessionContext sessionContext;
    public IMTSessionContext SessionContext
    {
      get { return sessionContext; }
      set { sessionContext = value; }
    }

    /// <summary>
    /// Determines whether sessionContext is dirty and needs to be reloaded or not.
    /// </summary>
    /// <param name="username">The username.</param>
    /// <param name="mtNamespace">The mt namespace.</param>
    /// <returns><c>true</c> if [is session context dirty] [the specified username]; otherwise, <c>false</c>.</returns>
    /// <remarks></remarks>
    private bool IsSessionContextDirty(string username, string mtNamespace)
    {
      try
      {
        Auth auth = new Auth();
        auth.Initialize(username, mtNamespace);

        object tmpSessionContext = null;
        MetraTech.Security.LoginStatus status = auth.LoginWithTicket(Ticket, ref tmpSessionContext);
        IMTSessionContext newSessionContext = tmpSessionContext as IMTSessionContext;

        if (newSessionContext != null)
          return (!(newSessionContext.SecurityContext.ToXML().Equals(SessionContext.SecurityContext.ToXML())));

        return false;
      }
      catch (Exception ex)
      {
        Utils.CommonLogger.LogException("Caught exception when trying to check if sessionContext was dirty or not", ex);
      }
      return false;
    }

    private Account mSelectedAccount = null;
    public Account SelectedAccount
    {
      get
      {
        if (mSelectedAccount != null && IsSessionContextDirty(mSelectedAccount.UserName, mSelectedAccount.Name_Space))
          OpenAccount(mSelectedAccount.UserName, mSelectedAccount.Name_Space);

        return mSelectedAccount;
      }
      set { 
        mSelectedAccount = value;

        if(mSelectedAccount != null)
          OpenAccount(mSelectedAccount.UserName, mSelectedAccount.Name_Space);
    }
    }
    
    public void CloseAccount()
    {
      SelectedAccount = null;

      SessionContext = null;
    }

    public void OpenAccount(string username, string name_space)
    {
      try
      {
        Auth auth = new Auth();
        if (SessionContext != null)
        {
          auth.Initialize(username, name_space, SessionContext.LoggedInAs, SessionContext.ApplicationName);
        }
        else
        {
          auth.Initialize(username, name_space);
        }

        string ticket = auth.CreateTicket();

        object tmp = null;
        MetraTech.Security.LoginStatus status = auth.LoginWithTicket(ticket, ref tmp);
        IMTSessionContext context = tmp as IMTSessionContext;

        Ticket = ticket;
        SessionContext = context;
      }
      catch (Exception ex)
      {
        Utils.CommonLogger.LogException("Caught exception when trying to open Account.", ex);
      }
    }

    public string this[string key]
    {
      get 
      {
        object o = null;
        try
        {
          if(mSelectedAccount != null)
          {
            o = Utils.GetPropertyEx(mSelectedAccount, key);
          }
        }
        catch(Exception exp)
        {
          Utils.CommonLogger.LogException("Could not find key in Active Subscriber: " + key, exp);
        }

        if (o == null)
        {
          return "";
        }
        else
        {
          return o.ToString();
        }
      }
    }
  }

}
