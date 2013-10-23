using System;
using System.Collections.Generic;
using System.Text;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.UI.Tools;
using MetraTech.Core.Services.ClientProxies;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.UI.Common
{
  /// <summary>
  /// AccountLib includes a collection of usefull account related taskes used by the UI.
  /// </summary>
  public class AccountLib
  {
    /// <summary>
    /// GetFieldID returns a string in the format of firstname lastname (account id)
    /// If first and last name are null then it uses the username.
    /// </summary>
    /// <param name="accountId">ID of the account to retrieve</param>
    /// <param name="userData">This is the logged on user for service authentication</param>
    /// <param name="appTime"></param>
    /// <returns></returns>
    public static string GetFieldID(int accountId, UserData userData, DateTime appTime)
    {
      string fieldId = "";

      if (accountId.ToString() == "1")
      {
        fieldId = Resources.TEXT_ROOT_NODE; 
        return fieldId;
      }

      try
      {
        Account acc = LoadAccount(accountId, userData, appTime);
        if (acc != null)
        {
          ContactView contactView = LoadContactView(acc, ContactType.Bill_To);
          if (contactView != null)
          {
            if (String.IsNullOrEmpty(contactView.FirstName) && String.IsNullOrEmpty(contactView.LastName))
            {
              fieldId = String.Format("{0} ({1})", acc.UserName, acc._AccountID.ToString());
            }
            else
            {
              fieldId = String.Format("{0} {1} ({2})", contactView.FirstName, contactView.LastName, acc._AccountID.ToString());
            }
          }
          else
          {
            fieldId = String.Format("{0} ({1})", acc.UserName, acc._AccountID.ToString());
          }
        }
      }
      catch(Exception)
      {
        fieldId = accountId.ToString();   
      }
      return fieldId;
    }

    /// <summary>
    /// Returns the contact type specified for the given account
    /// </summary>
    /// <param name="acc"></param>
    /// <param name="contactType"></param>
    /// <returns></returns>
    public static ContactView LoadContactView(Account acc, ContactType contactType)
    {
      ContactView contactView = null;
      if (Utils.CheckingExistenceOfProperty(acc, "LDAP"))
      {
        try
        {
              foreach (ContactView v in (List<ContactView>)Utils.GetProperty(acc, "LDAP"))
          {
            if (v.ContactType == contactType)
            {
              contactView = v;
            }
          }
        }
        catch (Exception exp)
        {
          Utils.CommonLogger.LogException("Could not load contact view.", exp);
        }
      }
      return contactView;
    }

    /// <summary>
    /// Calls the service to load the account with the given id
    /// </summary>
    /// <param name="accountId">This is the ID of the account to load</param>
    /// <param name="userData">This is the logged on user for service authentication</param>
    /// <param name="appTime"></param>
    /// <returns></returns>
    public static Account LoadAccount(int accountId, UserData userData, DateTime appTime)
    {
      Account account = null;

      try
      {
        AccountService_LoadAccountWithViews_Client acc = new AccountService_LoadAccountWithViews_Client();
        acc.In_acct = new AccountIdentifier(accountId);
        acc.In_timeStamp = appTime;

        //acc.UserName = userData.UserName;
        //acc.Password = userData.SessionPassword;

        acc.UserName = userData.Ticket;
        acc.Password = String.Empty;

        acc.Invoke();

        if (acc.Out_account != null)
        {
          account = acc.Out_account;
        }
        else
        {
          Utils.CommonLogger.LogError("Could not load account with id " + accountId.ToString());
        }
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        Utils.CommonLogger.LogException("Fault exception caught in AccountLib.LoadAccount", fe);

        foreach (string msg in fe.Detail.ErrorMessages)
        {
          Utils.CommonLogger.LogError("Detail: {0}", msg);
        }
      }
      catch (Exception e)
      {
        Utils.CommonLogger.LogException("Exception caught in AccountLib.LoadAccount.  Make sure ActivityServices service is started.", e);
      }
    
      return account;
    }
  }
}
