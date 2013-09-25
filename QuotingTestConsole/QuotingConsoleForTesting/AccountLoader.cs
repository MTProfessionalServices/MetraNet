// -----------------------------------------------------------------------
// <copyright file="AccountLoader.cs" company="Microsoft">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

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

      throw new NotImplementedException();
      //return new List<Account>(0);
    }

    public static string GetAccountString(Account account)
    {
      return account.ToString();
    }
  }
}
