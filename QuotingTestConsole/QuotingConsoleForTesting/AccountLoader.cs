// -----------------------------------------------------------------------
// <copyright file="AccountLoader.cs" company="Microsoft">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

using System.Diagnostics;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;

namespace QuotingConsoleForTesting
{
  using System;
  using System.Collections.Generic;
  using System.Linq;
  using System.Text;

  /// <summary>
  /// TODO: Update summary.
  /// </summary>
  public class AccountLoader
  {
    public static List<Account> GetAccounts()
    {
      AccountServiceClient acs = null;
      var accounts = new MTList<Account>();
      try
      {
        acs = new AccountServiceClient();
        acs.ClientCredentials.UserName.UserName = "su";
        acs.ClientCredentials.UserName.Password = "su123";
        acs.GetAccountList(DateTime.Now, ref accounts, false);
      }
      finally
      {
        if (acs != null)
        {
          if (acs.State == CommunicationState.Opened)
          {
            acs.Close();
          }
          else
          {
            acs.Abort();
          }
        }
      }

      return accounts.Items;
    }

    public static KeyValuePair<int, string> GetAccountListBoxItem(Account account)
    {
      Debug.Assert(account._AccountID != null, "Error: AccountID is null.");
      var tabs = "";
      if (account.UserName.Length < 8)
      {
        tabs = "\t\t\t";
      }
      else if (account.UserName.Length < 16)
      {
        tabs = "\t\t";
      }
      else if (account.UserName.Length < 32)
      {
        tabs = "\t";
      }

      var formattedDisplayString = String.Format("{0}\t{1}{2}{3}",
                                                 account._AccountID,
                                                 account.UserName,
                                                 tabs,
                                                 account.AccountType);

      return new KeyValuePair<int, string>(account._AccountID.Value, formattedDisplayString);
    }


  }
}
