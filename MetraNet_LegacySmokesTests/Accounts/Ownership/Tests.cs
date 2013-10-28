using System.Collections;
using System.Collections.Generic;
using MetraTech.TestCommon;
using System;
using System.Runtime.InteropServices;
using NUnit.Framework;
using YAAC = MetraTech.Interop.MTYAAC;
using RS = MetraTech.Interop.Rowset;
using MetraTech.Interop.MTAuth;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;

namespace MetraTech.Accounts.Ownership.Test
{
  //
  // To run the this test fixture:
  // nunit-console /fixture:MetraTech.Accounts.Ownership.Tests /assembly:O:\debug\bin\MetraTech.Accounts.Ownership.Test.dll
  //
  [Category("NoAutoRun")]
  [TestFixture]
  [ComVisible(false)]
  public class Tests
  {
    private Util _util;
    private int _dougSalesAccountId;
    private int _scottSalesAccountId;
    private int _metraTechAccountId;
    private int _servicesAccountId;
    private string _dougSalesUserName;
    private string _scottSalesUserName;
    private IMTSessionContext _suSessionContext;
    private IMTSessionContext _dougSalesSessionContext;

    #region Test Initialization and Cleanup

    /// <summary>
    ///   Initialize data for ownership tests.
    /// </summary>
    [TestFixtureSetUp]
    public void Setup()
    {
      _util = Util.Instance;
      var user = _util.AccountsList["DougSales"];
      var dougAccountId = user._AccountID;
      if (dougAccountId != null)
        _dougSalesAccountId = (int)dougAccountId;
      _dougSalesUserName = user.UserName;

      user = _util.AccountsList["ScottSales"];
      var scottAccountId = user._AccountID;
      if (scottAccountId != null)
        _scottSalesAccountId = (int)scottAccountId;
      _scottSalesUserName = user.UserName;
      
      user = _util.AccountsList["MetraTech"];
      var metraTechAccountId = user._AccountID;
      if (metraTechAccountId != null)
        _metraTechAccountId = (int)metraTechAccountId;
      
      user = _util.AccountsList["Services"];
      var servisesAccountId = user._AccountID;
      if (servisesAccountId != null)
        _servicesAccountId = (int)servisesAccountId;

      _suSessionContext = MetraTech.Test.Common.Utils.LoginAsSU();
      _dougSalesSessionContext = Util.Login(_dougSalesUserName, "system_user", "123");
    }

    /// <summary>
    /// Restore system to state prior the test run.  This currently does nothing.
    /// </summary>
    [TestFixtureTearDown]
    public void TearDown()
    {
      // Do nothing
    }

    #endregion

    /// <summary>
    /// Tests Creation of ownersip manager from YAAC object
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T01TestCreateOwnershipManager()
    {
      Util.CreateOwnershipManager(_dougSalesAccountId, _suSessionContext);
      // TODO assert
    }

    /// <summary>
    /// Create ownership relationship, fetch it back as rowset and
    /// verify correctness
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T02TestCreateOwnerships()
    {
      TruncateOwnershipTable();
      CreateOwnerships();
    }
    
    /// <summary>
    /// Create ownership relationships by incapable user
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T03TestCreateOwnershipAccessDenied()
    {
      var mgr = Util.CreateOwnershipManager(_dougSalesAccountId, _dougSalesSessionContext);
      var assoc = mgr.CreateAssociationAsOwner();

      ExceptionAssert.Expected<COMException>(() => mgr.AddOwnership(assoc),
        "Access Denied: Required Capability: 'Manage Sales Force Hierarchies': (WRITE, /) ");
    }

    /// <summary>
    /// Delete ownership relationships by incapable user
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T04TestRemoveOwnershipAccessDenied()
    {
      var mgr = Util.CreateOwnershipManager(_dougSalesAccountId, _dougSalesSessionContext);
      var assoc = mgr.CreateAssociationAsOwner();

      ExceptionAssert.Expected<COMException>(() => mgr.RemoveOwnership(assoc),
        "Access Denied: Required Capability: 'Manage Sales Force Hierarchies': (WRITE, /) ");
    }

    /// <summary>
    /// Create ownership relationships in batch
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T05TestCreateOwnershipBatch()
    {
      var mgr = Util.CreateOwnershipManager(_scottSalesAccountId, _suSessionContext);
      var assocs = GetAssociations(mgr);
      var rowset = mgr.AddOwnershipBatch(assocs, null);
      //TODO Assert rowset
    }

    /// <summary>
    /// Create ownership relationships in batch by incapable user
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T06TestCreateOwnershipBatchAccessDenied()
    {
      var mgr = Util.CreateOwnershipManager(_scottSalesAccountId, _dougSalesSessionContext);
      var assocs = GetAssociations(mgr);
      ExceptionAssert.Expected<COMException>(() => mgr.AddOwnershipBatch(assocs, null),
        "Access Denied: Required Capability: 'Manage Sales Force Hierarchies': (WRITE, /) ");
    }

    /// <summary>
    /// Remove ownership relationships in batch
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T07TestRemoveOwnershipBatch()
    {
      var mgr = Util.CreateOwnershipManager(_scottSalesAccountId, _suSessionContext);
      var assocs = GetAssociations(mgr);
      mgr.RemoveOwnershipBatch(assocs, null);
      //TODO Assert rowset

    }

    /// <summary>
    /// Remove ownership relationships in batch by incapable user
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T08TestRemoveOwnershipBatchAccessDenied()
    {
      var mgr = Util.CreateOwnershipManager(_scottSalesAccountId, _dougSalesSessionContext);
      var assocs = GetAssociations(mgr);
      ExceptionAssert.Expected<COMException>(() => mgr.RemoveOwnershipBatch(assocs, null),
        String.Format("Access Denied: Required Capability: 'Manage Sales Force Hierarchies': (WRITE, /) "));
    }

    /// <summary>
    /// Fetch accounts owned by Scott
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T09TestViewOwnedAccounts()
    {
      var mgr = Util.CreateOwnershipManager(_scottSalesAccountId, _suSessionContext);
      TruncateOwnershipTable();
      CreateOwnership(_scottSalesAccountId, _metraTechAccountId);
      var owned = mgr.GetOwnedAccountsAsRowset(MetraTime.Now);
      CheckRowset(owned, _scottSalesAccountId, _metraTechAccountId);
    }

    /// <summary>
    /// Fetch accounts owned by Scott
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T10TestViewOwnedAccountsAccessDenied()
    {
      // todo CheckReadManageSFH(ctx); igrore other code
      var mgr = Util.CreateOwnershipManager(_scottSalesAccountId, _dougSalesSessionContext);
      ExceptionAssert.Expected<COMException>(() => mgr.GetOwnedAccountsAsRowset(MetraTime.Now),
        String.Format("Access Denied: Required Capability: 'Manage Sales Force Hierarchies': (READ, /) "));
    }

    /// <summary>
    /// Fetch relationship create in the previous test from
    /// an owned account perspective
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T11TestViewOwners()
    {
      var mgr = Util.CreateOwnershipManager(_metraTechAccountId, _suSessionContext);
      TruncateOwnershipTable();
      CreateOwnership(_scottSalesAccountId, _metraTechAccountId);
      var owner = mgr.GetOwnerAccountsAsRowset(MetraTime.Now);
      CheckRowset(owner, _scottSalesAccountId, _metraTechAccountId);
    }

    /// <summary>
    /// Fetch relationship by incapable user
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T12TestViewOwnersAccessDenied()
    {
      var mgr = Util.CreateOwnershipManager(_metraTechAccountId, _dougSalesSessionContext);
      ExceptionAssert.Expected<COMException>(() => mgr.GetOwnerAccountsAsRowset(MetraTime.Now),
        String.Format("Access Denied: Required Capability: 'Manage Sales Force Hierarchies': (READ, /) "));
    }

    /// <summary>
    /// Fetch all ownwerhips, while being logged in as SU
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T13TestViewOwnedAccountsHierarchicalAsSU()
    {
      TruncateOwnershipTable();
      CreateOwnership(_scottSalesAccountId, _metraTechAccountId);
      CreateOwnership(_dougSalesAccountId, _servicesAccountId);

      var mgr = Util.CreateOwnershipManager(_scottSalesAccountId, _suSessionContext);

      //check out the results
      //as of now, the only account owning MetraTech is Doug
      var owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.Direct);
      CheckRowset(owned, _scottSalesAccountId, _metraTechAccountId);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.DirectDescendents);
      CheckRowset(owned, _scottSalesAccountId, _metraTechAccountId);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);
      CheckRowset(owned, _scottSalesAccountId, _metraTechAccountId);
      
      //Remove Scott's ownership to MetraTech
      RemoveOwnership(_scottSalesAccountId, _metraTechAccountId);
      CheckOwnedCountAfterRemove(mgr);
      
      //Reinitialize Mgr as Doug and examine the same
      mgr = Util.CreateOwnershipManager(_dougSalesAccountId, _suSessionContext);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);
      CheckRowset(owned, _dougSalesAccountId, _servicesAccountId);
      
      //Remove Doug -> Services ownership
      RemoveOwnership(_dougSalesAccountId, _servicesAccountId);
      CheckOwnedCountAfterRemove(mgr);
    }

    /// <summary>
    /// Fetch all ownwerhips, while being logged in corresponding users
    /// </summary>
    [Test]
    [Category("Fast")]
    public void T14TestViewOwnedAccountsHierarchical()
    {
      SetCapabilities(_scottSalesAccountId);
      var scottctx = Util.Login(_scottSalesUserName, "system_user", "123");
      
      CreateOwnership(_scottSalesAccountId, _metraTechAccountId);
      var mgr = Util.CreateOwnershipManager(scottctx.AccountID, scottctx);

      //Scott has a capability to see his own owned accounts
      var owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.Direct);
      //todo assert values in owned
      Assert.AreEqual(1, owned.RecordCount);

      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.DirectDescendents);
      //same number of rows as with Direct hint, because no one directly under Scott owns anything
      Assert.AreEqual(1, owned.RecordCount);

      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);
      //Scott has a capability to see his own owned accounts, so
      //we should still get only one row
      Assert.AreEqual(1, owned.RecordCount);
    }

    /// <summary>
    /// Test batch operation using AccountCatalog
    /// </summary>
    [Test]
    [Category("Slow")]
    public void T15TestBatchCreateOwnershipWithAccountCatalog()
    {
      var cat = PrepareCatalog();
      var assocs = PrepareAssociations();
      var rowset = (IMTSQLRowset) cat.BatchCreateOrUpdateOwnerhip(assocs, null, System.Reflection.Missing.Value);
      // TODO Assert
    }

    /// <summary>
    /// Test batch remove ownerhip operation using AccountCatalog
    /// </summary>
    /// 
    [Test]
    [Category("Slow")]
    public void T16TestBatchRemoveOwnershipWithAccountCatalog()
    {
      var cat = PrepareCatalog();
      var assocs = PrepareAssociations();
      var rowset = (IMTSQLRowset) cat.BatchDeleteOwnerhip(assocs, null, System.Reflection.Missing.Value);
      // TODO Assert
    }

    #region Private methods

    private static void CheckOwnedCountAfterRemove(IOwnershipMgr mgr)
    {
      var owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.Direct);
      Assert.AreEqual(0, owned.RecordCount);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.DirectDescendents);
      Assert.AreEqual(0, owned.RecordCount);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);
      Assert.AreEqual(0, owned.RecordCount);
    }

    private static IMTCollection GetAssociations(IOwnershipMgr mgr)
    {
      var accounts = Util.GetAccountsForBatchOwnership();
      var assocs = (IMTCollection) new Coll.MTCollectionClass();
      var i = 0;
      while (Convert.ToBoolean(accounts.EOF) == false)
      {
        var owned = (int) accounts.Value["id_acc"];
        var assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = i++;
        assoc.StartDate = MetraTime.Now.AddMinutes(-1);
        assoc.EndDate = MetraTime.Max;
        assocs.Add(assoc);
        accounts.MoveNext();
      }
      return assocs;
    }

    private static IOwnershipAssociation GetAssociacion(IMTSQLRowset owned, int owner, ref int i)
    {
      IOwnershipAssociation assoc = new OwnershipAssociation();
      var ownedid = (int) owned.Value["id_acc"];
      assoc.OwnerAccount = owner;
      assoc.OwnedAccount = ownedid;
      assoc.RelationType = "Account Executive";
      if (i > 100) i = 0;
      assoc.PercentOwnership = i++;
      assoc.StartDate = MetraTime.Now.AddMinutes(-1);
      assoc.EndDate = MetraTime.Max;
      return assoc;
    }

    /// <summary>
    /// Remove ownership relationship, verify removals
    /// </summary>
    private void RemoveOwnership(int idOwner, int idOwned)
    {
      var mgr = Util.CreateOwnershipManager(idOwner, _suSessionContext);
      var assoc = mgr.CreateAssociationAsOwner();
      Assert.AreEqual(assoc.OwnerAccount, idOwner);
      assoc.OwnedAccount = idOwned;
      assoc.StartDate = MetraTime.Now.AddMinutes(-1);
      assoc.EndDate = MetraTime.Max;
      mgr.RemoveOwnership(assoc);
    }

    private void CreateOwnership(int idOwner, int idOwned)
    {
      var mgr = Util.CreateOwnershipManager(idOwner, _suSessionContext);
      var assoc = mgr.CreateAssociationAsOwner();
      Assert.AreEqual(assoc.OwnerAccount, idOwner);
      assoc.OwnedAccount = idOwned;
      assoc.RelationType = "Account Executive";
      assoc.PercentOwnership = 100;
      assoc.StartDate = MetraTime.Now.AddMinutes(-1);
      assoc.EndDate = MetraTime.Max;
      mgr.AddOwnership(assoc);
    }

    /// <summary>
    /// Setup ownership relationships
    /// </summary>
    private void CreateOwnerships()
    {
      CreateOwnership(_scottSalesAccountId, _metraTechAccountId);
      CreateOwnership(_dougSalesAccountId, _servicesAccountId);
    }

    private static void CheckRowset(IMTSQLRowset owned, int idOwner, int idOwned)
    {
      Assert.AreEqual(1, owned.RecordCount);
      owned.MoveFirst();
      var owneracc = (int) owned.Value["id_owner"];
      Assert.AreEqual(idOwner, owneracc);
      var ownedacc = (int) owned.Value["id_owned"];
      Assert.AreEqual(idOwned, ownedacc);
      
      //var ownerName = (string)owned.Value["OwnerName"];
      //var ownedName = (string)owned.Value["OwnedName"];
      //var rel = (int)owned.Value["id_relation_type"];
      //var percent = (int)owned.Value["n_percent"];
      //var relation = (string)owned.Value["RelationType"];
      //var name = (string) owned.Value["hierarchyname"];
    }

    private static void TruncateOwnershipTable()
    {
      var rs = (IMTSQLRowset) new RS.MTSQLRowsetClass();
      rs.Init(@"Queries\AccHierarchies");
      rs.SetQueryString("delete from t_acc_ownership");
      rs.ExecuteDisconnected();
    }

    private YAAC.MTAccountCatalogClass PrepareCatalog()
    {
      var cat = new YAAC.MTAccountCatalogClass();
      cat.Init((Interop.MTYAAC.IMTSessionContext)_suSessionContext);
      return cat;
    }

    private static YAAC.IMTCollection PrepareAssociations()
    {
      var owned = Util.GetAccountsForBatchOwnership();
      var owners = Util.GetCSRs();
      var assocs = (YAAC.IMTCollection) new Coll.MTCollectionClass();
      var i = 0;
      var alo = false;

      while (Convert.ToBoolean(owners.EOF) == false)
      {
        var owner = (int) owners.Value["id_acc"];
        while (Convert.ToBoolean(owned.EOF) == false)
        {
          alo = true;
          var assoc = GetAssociacion(owned, owner, ref i);
          assocs.Add(assoc);
          owned.MoveNext();
        }
        if (alo)
          owned.MoveFirst();
        owners.MoveNext();
      }
      return assocs;
    }

    /// <summary>
    /// Tests Manage Owned Accounts capability
    /// </summary>
    private void SetCapabilities(int accountId)
    {
      IMTSecurity sec = new MTSecurityClass();
      YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
      cat.Init((Interop.MTYAAC.IMTSessionContext) _suSessionContext);

      var scott = sec.GetAccountByID((MTSessionContext)_suSessionContext, accountId, MetraTime.Now);

      var scottMoa = sec.GetCapabilityTypeByName("Manage Owned Accounts").CreateInstance();
      scottMoa.GetAtomicEnumCapability().SetParameter("WRITE");
      scottMoa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);

      //only give Scott, Doug and Bagha capability to view their directly owned accounts
      scott.GetActivePolicy((MTSessionContext)_suSessionContext).AddCapability(scottMoa);
      scott.GetActivePolicy((MTSessionContext)_suSessionContext).Save();
    }

    #endregion


  }
}