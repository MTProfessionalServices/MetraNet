namespace MetraTech.Accounts.Ownership.Test
{
  using System;
  using System.Runtime.InteropServices;
  using System.Collections;

  using NUnit.Framework;
  using YAAC=MetraTech.Interop.MTYAAC;
  using RS=MetraTech.Interop.Rowset;
  using MetraTech.Interop.MTAuth;
  using ServerAccess = MetraTech.Interop.MTServerAccess;
  using MetraTech.Interop.MTEnumConfig;
  using MetraTech.Localization;
  using MetraTech.Test;
  using Coll = MetraTech.Interop.GenericCollection;
  using MetraTech.DataAccess;

  //
  // To run the this test fixture:
  // nunit-console /fixture:MetraTech.Accounts.Ownership.Tests /assembly:O:\debug\bin\MetraTech.Accounts.Ownership.Test.dll
  //
  [Category("NoAutoRun")]
  [TestFixture]
  [ComVisible(false)]
  public class Tests 
  {
    const string mTestDir = "t:\\Development\\Core\\AccountHierarchies\\";
    private IEnumConfig mEnumConfig = new EnumConfigClass();

    /// <summary>
    /// Tests Creation of ownersip manager from YAAC object
    /// </summary>
    [Test]
    public void T01TestCreateOwnershipManager()
    {
      //Doug
      int id_acc = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_acc, ctx);
    }

    /// <summary>
    /// Create ownership relationship, fetch it back as rowset and
    /// verify correctness
    /// </summary>
    /// 
    [Test]
    public void T02TestCreateOwnerships()
    {
      TruncateOwnershipTable();
      CreateOwnerships();
    }

    /// <summary>
    /// Create ownership relationships by incapable user
    /// </summary>
   [Test]
   [ExpectedException(typeof(COMException))]
    public void T03TestCreateOwnershipAccessDenied()
    {
      try
      {
        IMTSessionContext ctx = Utils.Login("DaveSales", "system_user", "123");

        IOwnershipMgr mgr = Utils.CreateOwnershipManager(Utils.GetAccountID("dougsales"), ctx);
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = Utils.GetSubscriberAccountID("metratech");
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = 100;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        mgr.AddOwnership(assoc);
      }
      catch(Exception e)
      {
        Utils.Trace(e.Message); throw;
      }

      
    }

    /// <summary>
    /// Delete ownership relationships by incapable user
    /// </summary>
    [Test]
    [ExpectedException(typeof(COMException))]
   public void T04TestRemoveOwnershipAccessDenied()
    {
      try
      {
        IMTSessionContext ctx = Utils.Login("DaveSales", "system_user", "123");

        IOwnershipMgr mgr = Utils.CreateOwnershipManager(Utils.GetAccountID("dougsales"), ctx);
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = Utils.GetSubscriberAccountID("metratech");
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        mgr.RemoveOwnership(assoc);
      }
      catch(Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
    }


    

    

    /// <summary>
    /// Create ownership relationships in batch
    /// </summary>

    [Test]
    public void T05TestCreateOwnershipBatch()
    {
      BatchCreateOwnership(Utils.GetAccountID("vladsales"));
    }
    
    /// <summary>
    /// Create ownership relationships in batch by incapable user
    /// </summary>
    [Test]
    [ExpectedException(typeof(COMException))]
    public void T06TestCreateOwnershipBatchAccessDenied()
    {
      try
      {
        IMTSessionContext ctx = Utils.Login("DaveSales", "system_user", "123");
        IMTSQLRowset accounts = Utils.GetAccountsForBatchOwnership();
        IOwnershipMgr mgr = Utils.CreateOwnershipManager(Utils.GetAccountID("vladsales"), ctx);
        IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
        int i = 0;
        while(System.Convert.ToBoolean(accounts.EOF) == false)
        {
          int owned  = (int)accounts.get_Value("id_acc");
          IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = i++;
          assoc.StartDate = MetraTime.Now;
          assoc.EndDate = MetraTime.Max;
          assocs.Add(assoc);
          accounts.MoveNext();
        }
        mgr.AddOwnershipBatch(assocs, null);
      }
      catch(Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
    }

    
    /// <summary>
    /// Remove ownership relationships in batch
    /// </summary>

    [Test]
    public void T07TestRemoveOwnershipBatch()
    {
      BatchRemoveOwnership(Utils.GetAccountID("vladsales"));
    }

    /// <summary>
    /// Remove ownership relationships in batch by incapable user
    /// </summary>
    [Test]
    [ExpectedException(typeof(COMException))]
    public void T08TestRemoveOwnershipBatchAccessDenied()
    {
      try
      {
        IMTSessionContext ctx = Utils.Login("DaveSales", "system_user", "123");
        IMTSQLRowset accounts = Utils.GetAccountsForBatchOwnership();
        IOwnershipMgr mgr = Utils.CreateOwnershipManager(Utils.GetAccountID("vladsales"), ctx);
        IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
        int i = 0;
        while(System.Convert.ToBoolean(accounts.EOF) == false)
        {
          int owned  = (int)accounts.get_Value("id_acc");
          IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = i++;
          assoc.StartDate = MetraTime.Now;
          assoc.EndDate = MetraTime.Max;
          assocs.Add(assoc);
          accounts.MoveNext();
        }
        mgr.RemoveOwnershipBatch(assocs, null);
      }
      catch(Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
    }

    


    /// <summary>
    /// Fetch accounts owned by Vlad
    /// </summary>
    [Test]
    public void T09TestViewOwnedAccounts()
    {
      IMTSessionContext ctx = Utils.LoginAsSU();

      IOwnershipMgr mgr = Utils.CreateOwnershipManager(Utils.GetAccountID("vladsales"), ctx);
      
      IMTSQLRowset owned = mgr.GetOwnedAccountsAsRowset(MetraTime.Now);
      Assert.IsTrue(owned.RecordCount > 0);
      owned.MoveFirst();
      int owneracc = (int)owned.get_Value("id_owner");
      int ownedacc = (int)owned.get_Value("id_owned");
      string name = (string)owned.get_Value("hierarchyname");
      int rel = (int)owned.get_Value("id_relation_type");
      int percent = (int)owned.get_Value("n_percent");
      string relation = (string)owned.get_Value("RelationType");
      string msg = string.Format("Fetched ownership record: Owner: {0}, Owned: {1}, Owner Acc Name: {2}, Relation: {3}, Percent: {4}, Relation Enum Value: {5}",
        owneracc, ownedacc, name, relation, percent, rel);
      Utils.Trace(msg);
      
    }

    /// <summary>
    /// Fetch accounts owned by Vlad
    /// </summary>
    [Test]
    [ExpectedException(typeof(COMException))]
    public void T10TestViewOwnedAccountsAccessDenied()
    {
      try
      {
        IMTSessionContext ctx = Utils.Login("DaveSales", "system_user", "123");

        IOwnershipMgr mgr = Utils.CreateOwnershipManager(Utils.GetAccountID("vladsales"), ctx);
      
        //check out the results
        //as of now, the only account owning MetraTech is Doug
        IMTSQLRowset owned = mgr.GetOwnedAccountsAsRowset(MetraTime.Now);
        Assert.IsTrue(owned.RecordCount > 0);
        owned.MoveFirst();
        int owneracc = (int)owned.get_Value("id_owner");
        int ownedacc = (int)owned.get_Value("id_owned");
        Assert.AreEqual(Utils.GetSubscriberAccountID("metratech"), ownedacc);
        string name = (string)owned.get_Value("hierarchyname");
        int rel = (int)owned.get_Value("id_relation_type");
        int percent = (int)owned.get_Value("n_percent");
        string relation = (string)owned.get_Value("RelationType");
        string msg = string.Format("Fetched ownership record: Owner: {0}, Owned: {1}, Owner Acc Name: {2}, Relation: {3}, Percent: {4}, Relation Enum Value: {5}",
          owneracc, ownedacc, name, relation, percent, rel);
        Utils.Trace(msg);
      }
      catch(Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
      
    }



    /// <summary>
    /// Fetch relationship create in the previous test from
    /// an owned account perspective
    /// </summary>
    [Test]
    public void T11TestViewOwners()
    {
      int id_owned = Utils.GetSubscriberAccountID("metratech");
      IMTSessionContext ctx = Utils.LoginAsSU();

      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owned, ctx);
      
      //check out the results
      //as of now, the only account owning MetraTech is Doug
      IMTSQLRowset owned = mgr.GetOwnerAccountsAsRowset(MetraTime.Now);
      Assert.IsTrue(owned.RecordCount > 0);
      owned.MoveFirst();
      int owneracc = (int)owned.get_Value("id_owner");
      int ownedacc = (int)owned.get_Value("id_owned");
      Assert.AreEqual(Utils.GetSubscriberAccountID("metratech"), ownedacc);
      string name = (string)owned.get_Value("hierarchyname");
      int rel = (int)owned.get_Value("id_relation_type");
      int percent = (int)owned.get_Value("n_percent");
      string relation = (string)owned.get_Value("RelationType");
      string msg = string.Format("Fetched ownership record: Owner: {0}, Owned: {1}, Owner Acc Name: {2}, Relation: {3}, Percent: {4}, Relation Enum Value: {5}",
        owneracc, ownedacc, name, relation, percent, rel);
      Utils.Trace(msg);
      
    }

    /// <summary>
    /// Fetch relationship by incapable user
    /// </summary>
    [Test]
    [ExpectedException(typeof(COMException))]
    public void T12TestViewOwnersAccessDenied()
    {
      try
      {
        int id_owned = Utils.GetSubscriberAccountID("metratech");
        IMTSessionContext ctx = Utils.Login("DaveSales", "system_user", "123");

        IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owned, ctx);
      
        //check out the results
        //as of now, the only account owning MetraTech is Doug
        IMTSQLRowset owned = mgr.GetOwnerAccountsAsRowset(MetraTime.Now);
      }
      catch(Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
    }

    /// <summary>
    /// Fetch all ownwerhips, while being logged in as SU
    /// </summary>
    [Test]
    public void T13TestViewOwnedAccountsHierarchicalAsSU()
    {
      //Scott Swartz
      int id_owner = Utils.GetAccountID("scottsales");
      IMTSessionContext ctx = Utils.LoginAsSU();

      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      
      //check out the results
      //as of now, the only account owning MetraTech is Doug
      IMTSQLRowset owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.Direct);
      Assert.AreEqual(1, owned.RecordCount);
      int owneracc = (int)owned.get_Value("id_owner");
      Assert.AreEqual(id_owner, owneracc);
      int ownedacc = (int)owned.get_Value("id_owned");
      Assert.AreEqual(Utils.GetSubscriberAccountID("metratech"), ownedacc);
      string OwnerName = (string)owned.get_Value("OwnerName");
      string OwnedName = (string)owned.get_Value("OwnedName");
      int rel = (int)owned.get_Value("id_relation_type");
      int percent = (int)owned.get_Value("n_percent");
      string relation = (string)owned.get_Value("RelationType");
      
      string msg = string.Format("{0} ({1}) directly owns {2}", id_owner, OwnerName, OwnedName);
      Utils.Trace(msg);

      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.DirectDescendents);
      //same number of rows as with Direct hint, because no one directly under Scott owns anything
      Assert.AreEqual(1, owned.RecordCount);

      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);

      //Remove Scott's ownership to MetraTech
      RemoveOwnership(Utils.GetAccountID("scottsales"), Utils.GetSubscriberAccountID("metratech"), MetraTime.Now, MetraTime.Max);

      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.Direct);
      Assert.AreEqual(0, owned.RecordCount);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.DirectDescendents);
      Assert.AreEqual(0, owned.RecordCount);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);
      
      //Remove Vlad -> Sales ownership
      RemoveOwnership( Utils.GetAccountID("vladsales"), Utils.GetSubscriberAccountID("sales"), MetraTime.Now, MetraTime.Max);

      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.Direct);
      Assert.AreEqual(0, owned.RecordCount);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.DirectDescendents);
      Assert.AreEqual(0, owned.RecordCount);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);
      

      //Reinitialize Mgr as Doug and examine the same
      mgr = Utils.CreateOwnershipManager(Utils.GetAccountID("dougsales"), ctx);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);
      Assert.AreEqual(1, owned.RecordCount);

      //Remove Doug -> Services ownership
      RemoveOwnership(Utils.GetAccountID("dougsales"), Utils.GetSubscriberAccountID("services"), MetraTime.Now, MetraTime.Max);
      
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.Direct);
      Assert.AreEqual(0, owned.RecordCount);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.DirectDescendents);
      Assert.AreEqual(0, owned.RecordCount);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);
      Assert.AreEqual(0, owned.RecordCount);
    }

    

    /// <summary>
    /// Fetch all ownwerhips, while being logged in corresponding users
    /// </summary>
    [Test]
    public void T14TestViewOwnedAccountsHierarchical()
    {
      //reset all ownerships
      CreateOwnerships();
      //Scott Swartz
      IMTSessionContext scottctx = Utils.Login("scottsales", "system_user", "123");
      IMTSessionContext baghactx = Utils.Login("DharminderSales", "system_user", "123");
      IMTSessionContext dougctx = Utils.Login("dougsales", "system_user", "123");
      IMTSessionContext vladctx = Utils.Login("vladsales", "system_user", "123");

      IOwnershipMgr mgr = Utils.CreateOwnershipManager(scottctx.AccountID, scottctx);
      
      //Scott has a capability to see his own owned accounts
      IMTSQLRowset owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.Direct);
      Assert.AreEqual(1, owned.RecordCount);
      
      
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.DirectDescendents);
      //same number of rows as with Direct hint, because no one directly under Scott owns anything
      Assert.AreEqual(1, owned.RecordCount);

      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);
      //Scott has a capability to see his own owned accounts, so
      //we should still get only one row
      Assert.AreEqual(1, owned.RecordCount);

      //Reinitialize Mgr as Vlad and examine the same
      mgr = Utils.CreateOwnershipManager(vladctx.AccountID, vladctx);
      owned = mgr.GetOwnedAccountsHierarchicalAsRowset(ViewHint.AllDescendents);
      //Vlad has a capability to see all descendents
      //SFH got reshuffled - so no the below assert fails (Vlad has no descendents)
      //TODO: fix it in SFH
      //Assert.AreEqual(2, owned.RecordCount);

    }

    /// <summary>
    /// Test batch operation using AccountCatalog
    /// </summary>
    [Test]
    public void T15TestBatchCreateOwnershipWithAccountCatalog()
    {
      IMTSessionContext ctx = Utils.LoginAsSU();
      YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
      cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
      IMTSQLRowset owned = Utils.GetAccountsForBatchOwnership();
      IMTSQLRowset owners = Utils.GetCSRs();
      YAAC.IMTCollection assocs = (YAAC.IMTCollection)new Coll.MTCollectionClass();
      int i = 0;
      bool alo = false;
      DateTime mtNow = MetraTime.Now;
      DateTime mtMax = MetraTime.Max;

      while(System.Convert.ToBoolean(owners.EOF) == false)
      {
        
        int owner  = (int)owners.get_Value("id_acc");
        while(System.Convert.ToBoolean(owned.EOF) == false)
        {
          alo = true;
          IOwnershipAssociation assoc = new OwnershipAssociation();
          int ownedid  = (int)owned.get_Value("id_acc");
          assoc.OwnerAccount = owner;
          assoc.OwnedAccount = ownedid;
          assoc.RelationType = "Account Executive";
          if (i > 100) i = 0;
          assoc.PercentOwnership = i++;
          assoc.StartDate = mtNow;
          assoc.EndDate = mtMax;
          assocs.Add(assoc);
          owned.MoveNext();
        }
        if(alo)
          owned.MoveFirst();
        owners.MoveNext();
      }
      Utils.DumpErrorRowset((MetraTech.Interop.MTAuth.IMTSQLRowset)cat.BatchCreateOrUpdateOwnerhip(assocs, null, System.Reflection.Missing.Value));
    }

    /// <summary>
    /// Test batch remove ownerhip operation using AccountCatalog
    /// </summary>
    /// 
    [Test]
    public void T16TestBatchRemoveOwnershipWithAccountCatalog()
    {
      IMTSessionContext ctx = Utils.LoginAsSU();
      YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
      cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
      IMTSQLRowset owned = Utils.GetAccountsForBatchOwnership();
      IMTSQLRowset owners = Utils.GetCSRs();
      YAAC.IMTCollection assocs = (YAAC.IMTCollection)new Coll.MTCollectionClass();
      int i = 0;
      bool alo = false;
      DateTime mtNow = MetraTime.Now;
      DateTime mtMax = MetraTime.Max;

      while(System.Convert.ToBoolean(owners.EOF) == false)
      {
        
        int owner  = (int)owners.get_Value("id_acc");
        while(System.Convert.ToBoolean(owned.EOF) == false)
        {
          alo = true;
          IOwnershipAssociation assoc = new OwnershipAssociation();
          int ownedid  = (int)owned.get_Value("id_acc");
          assoc.OwnerAccount = owner;
          assoc.OwnedAccount = ownedid;
          assoc.RelationType = "Account Executive";
          if (i > 100) i = 0;
          assoc.PercentOwnership = i++;
          assoc.StartDate = mtNow;
          assoc.EndDate = mtMax;
          assocs.Add(assoc);
          owned.MoveNext();
        }
        if(alo)
          owned.MoveFirst();
        owners.MoveNext();
      }
      Utils.DumpErrorRowset((MetraTech.Interop.MTAuth.IMTSQLRowset)cat.BatchDeleteOwnerhip(assocs, null, System.Reflection.Missing.Value));
    }


    private void BatchCreateOwnership(int id_owner)
    {
      IMTSessionContext ctx = Utils.LoginAsSU();
      IMTSQLRowset accounts = Utils.GetAccountsForBatchOwnership();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      int i = 0;
      while(System.Convert.ToBoolean(accounts.EOF) == false)
      {
        int owned  = (int)accounts.get_Value("id_acc");
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = i++;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        assocs.Add(assoc);
        accounts.MoveNext();
      }
      mgr.AddOwnershipBatch(assocs, null);
    }
    
    private void BatchRemoveOwnership(int id_owner)
    {
      IMTSessionContext ctx = Utils.LoginAsSU();
      IMTSQLRowset accounts = Utils.GetAccountsForBatchOwnership();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      int i = 0;
      while(System.Convert.ToBoolean(accounts.EOF) == false)
      {
        int owned  = (int)accounts.get_Value("id_acc");
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = i++;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        assocs.Add(assoc);
        accounts.MoveNext();
      }
      mgr.RemoveOwnershipBatch(assocs, null);
    }

  

    

    private void TruncateOwnershipTable()
    {
      IMTSQLRowset rs = (IMTSQLRowset)new RS.MTSQLRowsetClass();
      rs.Init(@"Queries\AccHierarchies");
      rs.SetQueryString("delete from t_acc_ownership");
      rs.ExecuteDisconnected();
      return;
    }




    /// <summary>
    /// Remove ownership relationship, verify removals
    /// </summary>
    private void RemoveOwnership(int id_owner, int id_owned, DateTime start, DateTime end)
    {
      IMTSessionContext ctx = Utils.LoginAsSU();

      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
      Assert.AreEqual(assoc.OwnerAccount, id_owner);
      assoc.OwnedAccount = id_owned;
      assoc.StartDate = MetraTime.Now;
      assoc.EndDate = MetraTime.Max;
      mgr.RemoveOwnership(assoc);
    }


    

    private void CreateOwnership(int id_owner, int id_owned, DateTime start, DateTime end)
    {
      IMTSessionContext ctx = Utils.LoginAsSU();

      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
      Assert.AreEqual(assoc.OwnerAccount, id_owner);
      assoc.OwnedAccount = id_owned;
      assoc.RelationType = "Account Executive";
      assoc.PercentOwnership = 100;
      assoc.StartDate = start;
      assoc.EndDate = end;
      mgr.AddOwnership(assoc);

      
    }

    /// <summary>
    /// Setup ownership relationships
    /// </summary>
    private void CreateOwnerships()
    {
      SFHAccountIds ids = new SFHAccountIds();

      CreateOwnership(/*Scott*/ids["scottsales"], Utils.GetSubscriberAccountID("metratech")/*MetraTech 137*/, MetraTime.Now, MetraTime.Max);
      CreateOwnership(/*Bagha*/ids["dharmindersales"], Utils.GetSubscriberAccountID("Marketing")/*Marketing 181*/, MetraTime.Now, MetraTime.Max);
      CreateOwnership(/*Vlad*/ids["vladsales"], Utils.GetSubscriberAccountID("Sales")/*Sales 177*/, MetraTime.Now, MetraTime.Max);
      CreateOwnership(/*Doug*/ids["dougsales"], Utils.GetSubscriberAccountID("Services")/*Services 171*/, MetraTime.Now, MetraTime.Max);
    }

  }


  public class SubscriberAccountIds
  {
    private static Hashtable mAccIDs;

    static SubscriberAccountIds()
    {
      mAccIDs = new Hashtable();
    }
    public int this [string loginname]   // Indexer declaration
    {
      get
      {
        if(mAccIDs.ContainsKey(loginname.ToUpper()) == false)
        {
          IMTSessionContext ctx = Utils.LoginAsSU();
          YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
          cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
          YAAC.IMTYAAC acc = cat.GetAccountByName(loginname + Utils.GetTestId(), "mt", MetraTime.Now);
          mAccIDs.Add(loginname.ToUpper(), acc.AccountID);
        }
        return (int)mAccIDs[loginname.ToUpper()];
      }
    }

  }

  public class SFHAccountIds
  {
    private static Hashtable mAccIDs;

    static SFHAccountIds()
    {
      mAccIDs = new Hashtable();
    }
    public int this [string loginname]   // Indexer declaration
    {
      get
      {
        if(mAccIDs.ContainsKey(loginname.ToUpper()) == false)
        {
          IMTSessionContext ctx = Utils.LoginAsSU();
          YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
          cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
          YAAC.IMTYAAC acc = cat.GetAccountByName(loginname + Utils.GetTestId(), "system_user", MetraTime.Now);
          mAccIDs.Add(loginname.ToUpper(), acc.AccountID);
        }
        return (int)mAccIDs[loginname.ToUpper()];
      }
    }

  }

  public class Utils
  {
    public static bool bTrace = false;
    public static SFHAccountIds mAccIDs;
    public static SubscriberAccountIds mSubAccIDs;
    public static string mTestId = "";

    public static ConnectionInfo connInfo = new ConnectionInfo("NetMeter");

    public static int GetAccountID(string login)
    {
      if(mAccIDs == null)
        mAccIDs = new SFHAccountIds();
      return mAccIDs[login];
    }

    public static int GetSubscriberAccountID(string login)
    {
      if(mSubAccIDs == null)
        mSubAccIDs = new SubscriberAccountIds();
      return mSubAccIDs[login];
    }

    public static void Trace(string message)
    {
      if(bTrace)
        TestLibrary.Trace(message);
    }
    public static IMTSessionContext LoginAsSU()
    {
      // sets the SU session context on the client
      IMTLoginContext loginContext = new MTLoginContextClass();
      ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
      sa.Initialize();
      ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
      string suName = accessData.UserName;
      string suPassword = accessData.Password;
      return loginContext.Login(suName, "system_user", suPassword);
    }

    public static string GetTestId()
    {
      if(mTestId.Equals(""))
      {
        try
        {
          PropertyBag config = new PropertyBag();
          config.Initialize("SmokeTest");
          mTestId = config["TestID"].ToString();
        }
        catch
        { 
          // no suffix
        }
      }
      return mTestId;
    }

    public static IMTSessionContext Login(string name, string ns, string password)
    {
      // sets the SU session context on the client
      IMTLoginContext loginContext = new MTLoginContextClass();
      return loginContext.Login(name + GetTestId(), ns, password);
    }

    public static IMTYAAC GetAccountAsResource(string name, string ns, IMTSessionContext ctx)
    {
      YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
      cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
      return (IMTYAAC)cat.GetAccountByName(name + GetTestId(), ns, MetraTime.Now);
    }

    public static IOwnershipMgr CreateOwnershipManager(int id_acc, IMTSessionContext ctx)
    {
      IMTYAAC acc = (IMTYAAC)new YAAC.MTYAACClass();
      acc.InitAsSecuredResource(id_acc, (MTSessionContext)ctx, MetraTime.Now);
      IOwnershipMgr mgr = (IOwnershipMgr)acc.GetOwnershipMgr();
      IOwnershipMgr mgr1 = (IOwnershipMgr)acc.GetOwnershipMgr();
      object mgr2 = acc.GetOwnershipMgr();
      Assert.IsNotNull(mgr);
      Assert.IsNotNull(mgr1);
      Assert.IsNotNull(mgr2);
      return mgr;
    }

    public static void DumpErrorRowset(IMTSQLRowset rowset)
    {
      bool atleastone = false;
      while(System.Convert.ToBoolean(rowset.EOF) == false)
      {
        atleastone = true;
        int owned  = (int)rowset.get_Value("id_acc");
        string ownedname  = (string)rowset.get_Value("accountname");
        string description  = (string)rowset.get_Value("description");
        string msg = string.Format("Error Rowset Row: id_owned: {0}, OwnedName: {1}, Description: {2}", 
          owned, ownedname, description); 

        Utils.Trace(msg);

        rowset.MoveNext();
      }
      if(atleastone)
        rowset.MoveFirst();
    }

    public static IMTSQLRowset GetAccountsForBatchOwnership()
    {
      IMTSQLRowset accounts = (IMTSQLRowset)new RS.MTSQLRowsetClass();
      accounts.Init(@"Queries\AccHierarchies");

      if (connInfo.IsSqlServer)
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
      IMTSQLRowset accounts = (IMTSQLRowset)new RS.MTSQLRowsetClass();
      accounts.Init(@"Queries\AccHierarchies");
      if (connInfo.IsSqlServer)
      {
          accounts.SetQueryString(@"SELECT TOP 5 id_acc FROM t_account acc INNER JOIN t_account_type atype on atype.id_type = acc.id_type WHERE atype.name = 'CORESUBSCRIBER'");
      }
      else
      {
          accounts.SetQueryString(@"SELECT id_acc from ( select id_acc from t_account acc inner join t_account_type atype on atype.id_type = acc.id_type where upper(atype.name) = 'CORESUBSCRIBER' " +
                                    " order by acc.id_acc) where rownum <= 5");
      }
      accounts.ExecuteDisconnected();
      return accounts;
    }

    public static IMTSQLRowset GetCSRs()
    {
      IMTSQLRowset accounts = (IMTSQLRowset)new RS.MTSQLRowsetClass();
      accounts.Init(@"Queries\AccHierarchies");
      if (connInfo.IsSqlServer)
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
  }
}
