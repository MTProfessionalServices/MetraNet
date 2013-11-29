using System;
using System.Collections.Generic;
using MetraTech.DataAccess;
using MetraTech.DomainModel.BaseTypes;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.Accounts.Type.Test;
using Rowset = MetraTech.Interop.Rowset;
using NUnit.Framework;
using YAAC = MetraTech.Interop.MTYAAC;
using RS = MetraTech.Interop.Rowset;
using MetraTech.Interop.MTAuth;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;

namespace MetraTech.Accounts.Ownership.Test
{
  
  /// <summary>
  /// Provides functionality that is common to all ownership unit tests.
  /// </summary>
  public sealed class Util
  {
    public static Util Instance
    {
      get
      {
        return _instance;
      }
    }

    public Dictionary<string, Account> AccountsList { get; private set; }

    private static readonly ConnectionInfo ConnInfo = new ConnectionInfo("NetMeter");
    private static readonly Util _instance = new Util();
    private readonly TestCreateUpdateAccounts _accountCreator;
    private readonly DateTime _startDate;

    #region Public Methods

    public static IMTSessionContext Login(string name, string ns, string password)
    {
      // sets the SU session context on the client
      IMTLoginContext loginContext = new MTLoginContextClass();
      return loginContext.Login(name, ns, password);
    }
    
    public static IMTYAAC GetAccountAsResource(string name, string ns, IMTSessionContext ctx)
    {
      YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
      cat.Init((Interop.MTYAAC.IMTSessionContext) ctx);
      return (IMTYAAC) cat.GetAccountByName(name, ns, MetraTime.Now);
    }

    public static IOwnershipMgr CreateOwnershipManager(int idAcc, IMTSessionContext ctx)
    {
      var acc = (IMTYAAC) new YAAC.MTYAACClass();
      acc.InitAsSecuredResource(idAcc, (MTSessionContext) ctx, MetraTime.Now);
      var mgr = (IOwnershipMgr) acc.GetOwnershipMgr();
      Assert.IsNotNull(mgr);
      return mgr;
    }

    public static IMTSQLRowset GetAccountsForBatchOwnership()
    {
      var accounts = (IMTSQLRowset) new RS.MTSQLRowsetClass();
      accounts.Init(@"Queries\AccHierarchies");

      if (ConnInfo.IsSqlServer)
      {
        accounts.SetQueryString(@"SELECT TOP 500 name.id_acc FROM vw_hierarchyname name " +
                                " INNER JOIN t_account acc on acc.id_acc = name.id_acc INNER JOIN t_account_type atype on atype.id_type = acc.id_type WHERE atype.name = 'CORESUBSCRIBER'");
      }
      else
      {
        accounts.SetQueryString(@"select id_acc from (select name.id_acc from  vw_hierarchyname name " +
                                " INNER JOIN t_account acc on acc.id_acc = name.id_acc " +
                                " INNER JOIN t_account_type atype on atype.id_type = acc.id_type " +
                                " WHERE upper(atype.name) = 'CORESUBSCRIBER' " +
                                " order by name.id_acc) " +
                                " where rownum <= 500 ");
      }

      accounts.ExecuteDisconnected();
      return accounts;
    }

    public static IMTSQLRowset GetNonSubscribers()
    {
      var accounts = (IMTSQLRowset) new RS.MTSQLRowsetClass();
      accounts.Init(@"Queries\AccHierarchies");
      if (ConnInfo.IsSqlServer)
      {
        accounts.SetQueryString(
          @"SELECT TOP 5 id_acc FROM t_account acc INNER JOIN t_account_type atype on atype.id_type = acc.id_type WHERE atype.name = 'CORESUBSCRIBER'");
      }
      else
      {
        accounts.SetQueryString(
          @"SELECT id_acc from ( select id_acc from t_account acc inner join t_account_type atype on atype.id_type = acc.id_type where upper(atype.name) = 'CORESUBSCRIBER' " +
          " order by acc.id_acc) where rownum <= 5");
      }
      accounts.ExecuteDisconnected();
      return accounts;
    }

    public static IMTSQLRowset GetCSRs()
    {
      var accounts = (IMTSQLRowset) new RS.MTSQLRowsetClass();
      accounts.Init(@"Queries\AccHierarchies");
      if (ConnInfo.IsSqlServer)
      {
        accounts.SetQueryString(@"SELECT TOP 50 acc.id_acc FROM t_account acc " +
                                " INNER JOIN t_account_mapper map on acc.id_acc = map.id_acc INNER JOIN t_account_type atype on atype.id_type = acc.id_type WHERE atype.name = 'SYSTEMACCOUNT'");
      }
      else
      {
        accounts.SetQueryString(@"select id_acc from (SELECT acc.id_acc FROM t_account acc " +
                                " INNER JOIN t_account_mapper map on acc.id_acc = map.id_acc INNER JOIN t_account_type atype on atype.id_type = acc.id_type WHERE UPPER(atype.name) = 'SYSTEMACCOUNT' order by acc.id_acc) where rownum <= 50");
      }
      accounts.ExecuteDisconnected();
      return accounts;
    }

    #endregion

    #region Private Methods

    private Util()
    {
      AccountsList = new Dictionary<string, Account>();
      _startDate = new DateTime(2000, 6, 1);
      _accountCreator = new TestCreateUpdateAccounts();
      InitializeAccounts();
    }

    private void InitializeAccounts()
    {
      // MetraTech accounts 
      var corporateAccountUserName = CreateAndCollectAccount("MetraTech", "", "CorporateAccount");
      var departmentUserName = CreateAndCollectAccount("Services", corporateAccountUserName, "DepartmentAccount");
      CreateAndCollectAccount("Ned", departmentUserName, "CoreSubscriber");

      // Sales Force accounts
      corporateAccountUserName = CreateAndCollectAccount("SalesForce", "", "SystemAccount");
      CreateAndCollectAccount("ScottSales", corporateAccountUserName, "SystemAccount");
      departmentUserName = CreateAndCollectAccount("WorldWideSales", corporateAccountUserName, "SystemAccount");
      CreateAndCollectAccount("DougSales", departmentUserName, "SystemAccount");
    }

    private string CreateAndCollectAccount(string userName, string departmentUserName, string accountType)
    {
      var accountUserName = userName + DateTime.Now.Ticks;
      var accountId = CreateAccount(accountUserName, departmentUserName, accountType);
      var account = new Account {_AccountID = accountId, UserName = accountUserName};
      AccountsList.Add(userName, account);
      return accountUserName;
    }

    /// <summary>
    ///    Create a specified number of billable and non-billable accounts based
    ///    on the given accountSpecification.
    ///    Meter them.
    ///    Return the intervals mapped to the billable accounts created.
    /// </summary>
    /// <summary>
    ///    Create accounts based on accountSpecification.
    ///    If 'isPayer' is true, then create only billable accounts, otherwise
    ///    create only non billable accounts.
    ///    
    ///    Return the list of account names created.
    /// </summary>
    /// <summary>
    ///   Create an account 
    ///   Return the account id.
    /// </summary>
    /// <param name="accountUserName"></param>
    /// <param name="ancestorUserName"></param>
    /// <param name="accountType"></param>
    private int CreateAccount(string accountUserName, string ancestorUserName, string accountType)
    {
      _accountCreator.YetAnotherCreateAccount
        (accountUserName,
          "USD",
          "Weekly",
          accountType,
          "MetraTech",
          true,
          "", // payer
          ancestorUserName, // ancestor
          accountType.ToUpper() == "SYSTEMACCOUNT"
            ? @"metratech.com/systemaccountcreation"
            : @"metratech.com/accountcreation",
          7,
          _startDate,
          "USA",
          -1,
          null,
          false);

      return GetAccountId(accountUserName, accountType.ToUpper() == "SYSTEMACCOUNT" ? "system_user" : "MT");
    }

    /// <summary>
    ///   Return the account id for the given user name. 
    ///   Return Int32.MinValue if the account is not found.
    /// </summary>
    /// <param name="username"></param>
    /// <param name="accountNamespace"></param>
    /// <returns>account id or Int32.MinValue if it's not found</returns>
    private int GetAccountId(string username, string accountNamespace)
    {
      var accountId = Int32.MinValue;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(@"Queries\UsageServer\Test");
      rowset.SetQueryTag("__GET_ACCOUNT_ID_USG_TEST__");

      rowset.AddParam("%%USER_NAME%%", username, true);
      rowset.AddParam("%%NAMESPACE%%", accountNamespace, true);
      rowset.Execute();

      if (rowset.RecordCount == 1)
      {
        accountId = (int)rowset.Value["id_acc"];
      }

      return accountId;
    }


    #endregion
  }
}