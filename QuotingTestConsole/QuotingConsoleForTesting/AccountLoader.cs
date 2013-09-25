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

    public static KeyValuePair<int, string> GetAccountInfo(Account account)
    {
      Debug.Assert(account._AccountID != null, "Error: AccountID is null.");

      return new KeyValuePair<int, string>(account._AccountID.Value, String.Format("{0}\t{1}\t{2}",
                                                                             account._AccountID,
                                                                             account.UserName,
                                                                             account.AccountType));
    }
  }
}
