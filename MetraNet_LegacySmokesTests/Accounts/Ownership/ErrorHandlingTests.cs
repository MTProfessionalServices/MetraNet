namespace MetraTech.Accounts.Ownership.Test
{
  using System;
  using System.Runtime.InteropServices;
  using System.Collections;

  using NUnit.Framework;
  using YAAC=MetraTech.Interop.MTYAAC;
  using MetraTech.Interop.MTAuth;
  using ServerAccess = MetraTech.Interop.MTServerAccess;
  using MetraTech.Interop.MTEnumConfig;
  using MetraTech.Localization;
  using MetraTech.Test;
  using MetraTech.Auth.Capabilities;
  using Coll =  MetraTech.Interop.GenericCollection;



  //
  // To run the this test fixture:
  // nunit-console /fixture:MetraTech.Accounts.Ownership.Tests /assembly:O:\debug\bin\MetraTech.Accounts.Ownership.Test.dll
  //
  [Category("NoAutoRun")]
  [TestFixture]
  [ComVisible(false)]
  public class ErrorHandlingTests 
  {
    const string mTestDir = "t:\\Development\\Core\\AccountHierarchies\\";


    /// <summary>
    /// Negative test: covers invalid use of YAAC object
    /// </summary>
    [ExpectedException(typeof(NullReferenceException))]
		[Test]
    public void TestCreateOwnershipManagerWithNullContext()
    {
      //Utils.bTrace = true;
      Utils.CreateOwnershipManager(111, null);
    }

    /// <summary>
    /// Negative test - don't set start date
    /// </summary>
    [ExpectedException(typeof(OwnershipException))]
		[Test]
    public void TestNotSetStartDate()
    {
      try
      {
        //Doug
        int id_owner = Utils.GetAccountID("dougsales");
        //MetraTech
        int id_owned = Utils.GetSubscriberAccountID("metratech");
        IMTSessionContext ctx = Utils.LoginAsSU();

        IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        Assert.AreEqual(assoc.OwnerAccount, id_owner);
        assoc.OwnedAccount = id_owned;
        assoc.RelationType = "Account Executive";
        assoc.EndDate = MetraTime.Max;
        assoc.PercentOwnership = 100;
        mgr.AddOwnership(assoc);
      }
      catch(Exception e)
      {
        Utils.Trace(e.Message); 
        throw;
      }
      
    }
/*
    /// <summary>
    /// Negative test - don't set end date
    /// </summary>
    [ExpectedException(typeof(OwnershipException))]
    public void TestNotSetEndDate()
    {
      try
      {
        //Doug
        int id_owner = Utils.GetAccountID("dougsales");
        //MetraTech
        int id_owned = Utils.GetSubscriberAccountID("metratech");
        IMTSessionContext ctx = Utils.LoginAsSU();

        IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        Assert.AreEqual(assoc.OwnerAccount, id_owner);
        assoc.OwnedAccount = id_owned;
        assoc.RelationType = "Account Executive";
        assoc.StartDate = MetraTime.Now;
        assoc.PercentOwnership = 100;
        mgr.AddOwnership(assoc);
      }
      catch(Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
    
      
    }

    
    /// <summary>
    /// Negative test - don't set percent
    /// </summary>
    [ExpectedException(typeof(OwnershipException))]
    public void TestNotSetPercent()
    {
      try
      {
        //Doug
        int id_owner = Utils.GetAccountID("dougsales");
        //MetraTech
        int id_owned = Utils.GetSubscriberAccountID("metratech");
        IMTSessionContext ctx = Utils.LoginAsSU();

        IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        Assert.AreEqual(assoc.OwnerAccount, id_owner);
        assoc.OwnedAccount = id_owned;
        assoc.RelationType = "Account Executive";
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
    /// Negative test - set invalid percent
    /// </summary>
    [ExpectedException(typeof(OwnershipException))]
    public void TestSetInvalidPercent()
    {
      try
      {
        //Doug
        int id_owner = Utils.GetAccountID("dougsales");
        //MetraTech
        int id_owned = Utils.GetSubscriberAccountID("metratech");
        IMTSessionContext ctx = Utils.LoginAsSU();

        IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        Assert.AreEqual(assoc.OwnerAccount, id_owner);
        assoc.OwnedAccount = id_owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = 101;
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
    /// Negative test - set own self
    /// </summary>
    [ExpectedException(typeof(OwnershipException))]
    public void TestOwnSelf()
    {
      try
      {
        //Doug
        int id_owner = Utils.GetAccountID("dougsales");
        //MetraTech
        int id_owned = Utils.GetSubscriberAccountID("metratech");
        IMTSessionContext ctx = Utils.LoginAsSU();

        IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnerAccount = id_owned;
        assoc.OwnedAccount = id_owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = 100;
        mgr.AddOwnership(assoc);
      }
      catch(Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
    
      
    }

    /// <summary>
    /// Negative test - don't set relation type
    /// </summary>
    [ExpectedException(typeof(OwnershipException))]
    public void TestNotSetRelationType()
    {
      try
      {
        //Doug
        int id_owner = Utils.GetAccountID("dougsales");
        //MetraTech
        int id_owned = Utils.GetSubscriberAccountID("metratech");
        IMTSessionContext ctx = Utils.LoginAsSU();

        IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = id_owned;
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
    [Test]
    [ExpectedException(typeof(CapabilityException))]
    public void TestInvalidAuthCheck()
    {
      try
      {
        IMTSecurity sec = new MTSecurityClass();
        IMTCompositeCapability mah = sec.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance();
        mah.GetAtomicEnumCapability().SetParameter("WRITE");
        mah.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);

        IMTCompositeCapability moa = sec.GetCapabilityTypeByName("Manage Owned Accounts").CreateInstance();
        moa.GetAtomicEnumCapability().SetParameter("WRITE");
        moa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);
        bool moa_implies_param = moa.Implies(mah, true);
      }
      catch(Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
    }

    /// <summary>
    /// Negative test: Create ownership relationships in batch for non-existing accounts
    /// </summary>
    
    public void TestCreateOwnershipBatchForNonExistingOwnedAccounts()
    {
      int id_owner = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      ArrayList bogusaccounts = new ArrayList();
      bogusaccounts.Add(2000000);
      bogusaccounts.Add(2000001);
      bogusaccounts.Add(2000002);
      bogusaccounts.Add(2000003);
      bogusaccounts.Add(2000004);
      int i = 0;

      for (i = 0; i < bogusaccounts.Count; i++)
      {
        int owned  = (int)bogusaccounts[i];
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = i;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        assocs.Add(assoc);
      }
      IMTSQLRowset errs = mgr.AddOwnershipBatch(assocs, null);
      //Utils.DumpErrorRowset(errs);
      Assert.AreEqual(5, errs.RecordCount);
      while(System.Convert.ToBoolean(errs.EOF) == false)
      {
        string desc  = (string)errs.get_Value("description");
        Assert.AreEqual("The account was not found in the database.\r\n", desc);
        errs.MoveNext();
      }
    }

    /// <summary>
    /// Negative test: Create ownership relationships for non subscribers
    /// </summary>
    
    public void TestCreateOwnershipBatchForNonSubscribers()
    {
      int id_owner = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      int i = 0;
      IMTSQLRowset rowset = Utils.GetNonSubscribers();
      while(System.Convert.ToBoolean(rowset.EOF) == false)
      {
        int owned  = (int)rowset.get_Value("id_acc");
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = i;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        assocs.Add(assoc);
        rowset.MoveNext();
      }

      IMTSQLRowset errs = mgr.AddOwnershipBatch(assocs, null);
      //Utils.DumpErrorRowset(errs);
      Assert.AreEqual(5, errs.RecordCount);
      while(System.Convert.ToBoolean(errs.EOF) == false)
      {
        string desc  = (string)errs.get_Value("description");
        Assert.AreEqual("Owned account must be a subscriber\r\n", desc);
        errs.MoveNext();
      }
    }



    /// <summary>
    /// Negative test: Create ownership relationships where start date is after end date
    /// </summary>
    
    public void TestCreateOwnershipBatchForInvalidDateCombination()
    {
      int id_owner = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      int i = 0;
      IMTSQLRowset rowset = Utils.GetAccountsForBatchOwnership();
      while(System.Convert.ToBoolean(rowset.EOF) == false)
      {
        int owned  = (int)rowset.get_Value("id_acc");
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = i;
        assoc.StartDate = MetraTime.Now.AddDays(5);
        assoc.EndDate = MetraTime.Now.AddDays(4);
        assocs.Add(assoc);
        rowset.MoveNext();
      }

      IMTSQLRowset errs = mgr.AddOwnershipBatch(assocs, null);
      Assert.IsTrue(errs.RecordCount>0);
      //Utils.DumpErrorRowset(errs);
      while(System.Convert.ToBoolean(errs.EOF) == false)
      {
        string desc  = (string)errs.get_Value("description");
        Assert.AreEqual("Account ownership Start Date has to be before End Date\r\n", desc);
        errs.MoveNext();
      }
    }

    /// <summary>
    /// Negative test: Create ownership relationships where start date is not set
    /// </summary>
    
    public void TestCreateOwnershipBatchForNotSetStartDate()
    {
      int id_owner = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      int i = 0;
      IMTSQLRowset rowset = Utils.GetAccountsForBatchOwnership();
      while(System.Convert.ToBoolean(rowset.EOF) == false)
      {
        int owned  = (int)rowset.get_Value("id_acc");
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = i;
        //assoc.StartDate = MetraTime.Now.AddDays(5);
        assoc.EndDate = MetraTime.Now.AddDays(4);
        assocs.Add(assoc);
        rowset.MoveNext();
      }

      IMTSQLRowset errs = mgr.AddOwnershipBatch(assocs, null);
      Assert.IsTrue(errs.RecordCount>0);
      //Utils.DumpErrorRowset(errs);
      while(System.Convert.ToBoolean(errs.EOF) == false)
      {
        string desc  = (string)errs.get_Value("description");
        Assert.AreEqual("Account ownership Start Date not set\r\n", desc);
        errs.MoveNext();
      }
    }

    /// <summary>
    /// Negative test: Create ownership relationships where end date is not set
    /// </summary>
    
    public void TestCreateOwnershipBatchForNotSetEndDate()
    {
      int id_owner = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      int i = 0;
      IMTSQLRowset rowset = Utils.GetAccountsForBatchOwnership();
      while(System.Convert.ToBoolean(rowset.EOF) == false)
      {
        int owned  = (int)rowset.get_Value("id_acc");
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = i;
        assoc.StartDate = MetraTime.Now;
        //assoc.EndDate = MetraTime.Now.AddDays(4);
        assocs.Add(assoc);
        rowset.MoveNext();
      }

      IMTSQLRowset errs = mgr.AddOwnershipBatch(assocs, null);
      Assert.IsTrue(errs.RecordCount>0);
      //Utils.DumpErrorRowset(errs);
      while(System.Convert.ToBoolean(errs.EOF) == false)
      {
        string desc  = (string)errs.get_Value("description");
        Assert.AreEqual("Account ownership End Date not set\r\n", desc);
        errs.MoveNext();
      }
    }

    /// <summary>
    /// Negative test: Create ownership relationships where account owns self
    /// </summary>
    
    public void TestCreateOwnershipBatchForSelfOwnership()
    {
      int id_owner = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      int i = 0;
      IMTSQLRowset rowset = Utils.GetAccountsForBatchOwnership();
      while(System.Convert.ToBoolean(rowset.EOF) == false)
      {
        int owned  = (int)rowset.get_Value("id_acc");
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnerAccount = owned;
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = i;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        assocs.Add(assoc);
        rowset.MoveNext();
      }

      IMTSQLRowset errs = mgr.AddOwnershipBatch(assocs, null);
      Assert.IsTrue(errs.RecordCount>0);
      //Utils.DumpErrorRowset(errs);
      while(System.Convert.ToBoolean(errs.EOF) == false)
      {
        string desc  = (string)errs.get_Value("description");
        Assert.AreEqual("Account can not own itself\r\n", desc);
        errs.MoveNext();
      }
    }
    /// <summary>
    /// Negative test: Create ownership relationships where percent is greater than 100
    /// </summary>
    
    public void TestCreateOwnershipBatchForInvalidPercentGreaterThan100()
    {
      int id_owner = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      IMTSQLRowset rowset = Utils.GetAccountsForBatchOwnership();
      while(System.Convert.ToBoolean(rowset.EOF) == false)
      {
        int owned  = (int)rowset.get_Value("id_acc");
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = 101;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        assocs.Add(assoc);
        rowset.MoveNext();
      }

      IMTSQLRowset errs = mgr.AddOwnershipBatch(assocs, null);
      Assert.IsTrue(errs.RecordCount>0);
      //Utils.DumpErrorRowset(errs);
      while(System.Convert.ToBoolean(errs.EOF) == false)
      {
        string desc  = (string)errs.get_Value("description");
        Assert.AreEqual("Account ownership percentage has to be a value between 0 and 100\r\n", desc);
        errs.MoveNext();
      }
    }
    /// <summary>
    /// Negative test: Create ownership relationships where percent is greater less than 0
    /// </summary>
    
    public void TestCreateOwnershipBatchForInvalidPercentLessThan0()
    {
      int id_owner = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      IMTSQLRowset rowset = Utils.GetAccountsForBatchOwnership();
      while(System.Convert.ToBoolean(rowset.EOF) == false)
      {
        int owned  = (int)rowset.get_Value("id_acc");
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = -1;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        assocs.Add(assoc);
        rowset.MoveNext();
      }

      IMTSQLRowset errs = mgr.AddOwnershipBatch(assocs, null);
      Assert.IsTrue(errs.RecordCount>0);
      //Utils.DumpErrorRowset(errs);
      while(System.Convert.ToBoolean(errs.EOF) == false)
      {
        string desc  = (string)errs.get_Value("description");
        Assert.AreEqual("Account ownership percentage has to be a value between 0 and 100\r\n", desc);
        errs.MoveNext();
      }
    }

    /// <summary>
    /// Negative test: Create ownership relationships where the errors are mixed
    /// -515899365 = KIOSK_ERR_ACCOUNT_NOT_FOUND
    /// -2147483607 = E_FAIL (when relationship enum value does not exist in t_enum_data table)
    /// MT_OWNED_ACCOUNT_NOT_SUBSCRIBER  -486604718
    /// MT_OWNERSHIP_START_DATE_AFTER_END_DATE = 0xE2FF0050; (-486604720)
    /// MT_OWNERSHIP_PERCENT_OUT_OF_RANGE = 0xE2FF0051; (-486604719)
    /// MT_CAN_NOT_OWN_SELF = 0xE2FF0053; (-486604717)
    /// MT_OWNERSHIP_START_DATE_NOT_SET = 0xE2FF0054; (-486604716)
    /// MT_OWNERSHIP_END_DATE_NOT_SET = 0xE2FF0055; (-486604715)
    /// </summary>
    
    public void TestCreateOwnershipBatchErrorMix()
    {
      int id_owner = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      int i = 0;
      int errs = 0;
      bool bNotASub = false;
      IMTSQLRowset rowset = Utils.GetAccountsForBatchOwnership();
      while(System.Convert.ToBoolean(rowset.EOF) == false)
      {
        int owned  = (int)rowset.get_Value("id_acc");
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = 90;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        if(i % 17 == 0)
        {
          //MT_OWNED_ACCOUNT_NOT_SUBSCRIBER
          //make sure we don't attempt to perform a batch op twice on the
          //same owner/ownee pair
          if(bNotASub == false)
          {
            assoc.OwnedAccount = 129;
            bNotASub = true;
            errs++;
          }
        }
        else if(i % 15 == 0)
        {
          //MT_OWNERSHIP_START_DATE_AFTER_END_DATE = 0xE2FF0050; (-486604720)
          assoc.StartDate = MetraTime.Now.AddDays(5);
          assoc.EndDate = MetraTime.Now.AddDays(4);
          errs++;
        }
        else if(i % 13 == 0)
        {
          //MT_OWNERSHIP_START_DATE_NOT_SET = 0xE2FF0054; (-486604716)
          assoc.StartDate = DateTime.MinValue;
          errs++;
        }
        else if(i % 11 == 0)
        {
          //MT_OWNERSHIP_END_DATE_NOT_SET = 0xE2FF0055; (-486604715)
          assoc.EndDate = DateTime.MinValue;
          errs++;
        }
        else if(i % 9 == 0)
        {
          //MT_OWNERSHIP_PERCENT_OUT_OF_RANGE = 0xE2FF0051; (-486604719)
          assoc.PercentOwnership = 101;
          errs++;
        }
        else if(i % 7 == 0)
        {
          //MT_CAN_NOT_OWN_SELF = 0xE2FF0053; (-486604717)
          assoc.OwnerAccount = owned;
          errs++;
        }
        else if(i % 5 == 0)
        {
          //-515899365 = KIOSK_ERR_ACCOUNT_NOT_FOUND
          assoc.OwnedAccount = i * 10000;
          errs++;
        }
        else if(i % 3 == 0)
        {
          //-2147483607 = E_FAIL (when relationship enum value does not exist in t_enum_data table)
          ((OwnershipAssociation)assoc).RelationTypeID = -100;
          errs++;
        }
        
        i++;
        
        assocs.Add(assoc);
        rowset.MoveNext();
      }

      IMTSQLRowset errrs = mgr.AddOwnershipBatch(assocs, null);
      Assert.IsTrue(errrs.RecordCount>0);
      Utils.DumpErrorRowset(errrs);
      Assert.AreEqual(errs, errrs.RecordCount);
      
    }

    /// <summary>
    /// Negative test: Create ownership relationships for the same owner/owned combination
    /// </summary>

    //[ExpectedException(typeof(OwnershipException))]
    [Ignore("ignore")]
    public void TestCreateOwnershipBatchForSameOwnerOwnedCombination()
    {
      int id_owner = Utils.GetAccountID("dougsales");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IOwnershipMgr mgr = Utils.CreateOwnershipManager(id_owner, ctx);
      IMTCollection assocs = (IMTCollection)new Coll.MTCollectionClass();
      IMTSQLRowset rowset = Utils.GetNonSubscribers();
      int owned  = (int)rowset.get_Value("id_acc");
      for(int i=0; i < 6; i++)
      {
        IOwnershipAssociation assoc = mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = owned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = 90;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        assocs.Add(assoc);
      }

      IMTSQLRowset errs = mgr.AddOwnershipBatch(assocs, null);
      
    }
*/


    
  }
}

