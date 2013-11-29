using MetraTech.Auth.Capabilities;
using MetraTech.TestCommon;
using System.Collections;
using System;
using System.Runtime.InteropServices;
using NUnit.Framework;
using YAAC = MetraTech.Interop.MTYAAC;
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
    public class ErrorHandlingTests
    {
      private Util _util;
      private int _idOwned;
      private int _idOwner;
      private IOwnershipMgr _mgr;

      #region Test Initialization and Cleanup

      /// <summary>
      ///   Initialize data for ownership tests.
      /// </summary>
      [TestFixtureSetUp]
      public void Setup()
      {
        _util = Util.Instance;
        var ownerAccountId = _util.AccountsList["DougSales"]._AccountID;
        if (ownerAccountId != null)
          _idOwner = (int)ownerAccountId;

        var ownedAccountId = _util.AccountsList["MetraTech"]._AccountID;
        if (ownedAccountId != null)
          _idOwned = (int)ownedAccountId;

        var ctx = MetraTech.Test.Common.Utils.LoginAsSU();
        _mgr = Util.CreateOwnershipManager(_idOwner, ctx);
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
      /// 
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T01TestInvalidAuthCheck()
      {
        IMTSecurity sec = new MTSecurityClass();
        var mah = sec.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance();
        mah.GetAtomicEnumCapability().SetParameter("WRITE");
        mah.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);

        var moa = sec.GetCapabilityTypeByName("Manage Owned Accounts").CreateInstance();
        moa.GetAtomicEnumCapability().SetParameter("WRITE");
        moa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);
        ExceptionAssert.Expected<CapabilityException>(() => moa.Implies(mah, true),
          "Actor Account Property is not initialized. Perhaps you are calling Implies() on the capability object instead of calling CheckAccess() on SecurityContext");
      }

      /// <summary>
      /// Negative test - don't set start date
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T02TestNotSetStartDate()
      {
        var assoc = _mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = _idOwned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = 100;
        assoc.EndDate = MetraTime.Max;
        ExceptionAssert.Expected<COMException>(() => _mgr.AddOwnership(assoc), "Relationship Start Date has to be set");
      }

      /// <summary>
      /// Negative test - don't set end date
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T03TestNotSetEndDate()
      {
        var assoc = _mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = _idOwned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = 100;
        assoc.StartDate = MetraTime.Now;
        ExceptionAssert.Expected<COMException>(() => _mgr.AddOwnership(assoc), "Relationship End Date has to be set");
      }

      /// <summary>
      /// Negative test - don't set percent
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T04TestNotSetPercent()
      {
        var assoc = _mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = _idOwned;
        assoc.RelationType = "Account Executive";
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        ExceptionAssert.Expected<COMException>(() => _mgr.AddOwnership(assoc), "Ownership percentage has to be a value between 0 and 100");
      }

      /// <summary>
      /// Negative test - don't set relation type
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T05TestNotSetRelationType()
      {
        var assoc = _mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = _idOwned;
        assoc.PercentOwnership = 100;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        ExceptionAssert.Expected<OwnershipException>(() => _mgr.AddOwnership(assoc), "Relation Type has to be set");
      }

      /// <summary>
      /// Negative test - set own self
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T06TestOwnSelf()
      {
        var assoc = _mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = _idOwned;
        assoc.RelationType = "Account Executive";
        assoc.OwnerAccount = assoc.OwnedAccount;
        assoc.PercentOwnership = 100;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        ExceptionAssert.Expected<OwnershipException>(() => _mgr.AddOwnership(assoc), "Account can not own itself");
      }

      /// <summary>
      /// Negative test - set invalid percent
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T07TestSetInvalidPercent()
      {
        var assoc = _mgr.CreateAssociationAsOwner();
        assoc.OwnedAccount = _idOwned;
        assoc.RelationType = "Account Executive";
        assoc.PercentOwnership = 101;
        assoc.StartDate = MetraTime.Now;
        assoc.EndDate = MetraTime.Max;
        ExceptionAssert.Expected<COMException>(() => _mgr.AddOwnership(assoc), "Ownership percentage has to be a value between 0 and 100");
      }

      /// <summary>
      /// Negative test: covers invalid use of YAAC object
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T08TestCreateOwnershipManagerWithNullContext()
      {
        ExceptionAssert.Expected<NullReferenceException>(() => Util.CreateOwnershipManager(111, null),
          "Object reference not set to an instance of an object.");
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
      [Test]
      [Category("Fast")]
      public void T09TestCreateOwnershipBatchErrorMix()
      {
        var assocs = (IMTCollection)new Coll.MTCollectionClass();
        var i = 0;
        var errs = 0;
        var bNotASub = false;
        var rowset = Util.GetAccountsForBatchOwnership();
        while (Convert.ToBoolean(rowset.EOF) == false)
        {
          var owned = (int)rowset.Value["id_acc"];
          var assoc = _mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = 90;
          assoc.StartDate = MetraTime.Now;
          assoc.EndDate = MetraTime.Max;
          if (i % 17 == 0)
          {
            //MT_OWNED_ACCOUNT_NOT_SUBSCRIBER
            //make sure we don't attempt to perform a batch op twice on the
            //same owner/ownee pair
            if (bNotASub == false)
            {
              assoc.OwnedAccount = 129;
              bNotASub = true;
              errs++;
            }
          }
          else if (i % 15 == 0)
          {
            //MT_OWNERSHIP_START_DATE_AFTER_END_DATE = 0xE2FF0050; (-486604720)
            assoc.StartDate = MetraTime.Now.AddDays(5);
            assoc.EndDate = MetraTime.Now.AddDays(4);
            errs++;
          }
          else if (i % 13 == 0)
          {
            //MT_OWNERSHIP_START_DATE_NOT_SET = 0xE2FF0054; (-486604716)
            assoc.StartDate = DateTime.MinValue;
            errs++;
          }
          else if (i % 11 == 0)
          {
            //MT_OWNERSHIP_END_DATE_NOT_SET = 0xE2FF0055; (-486604715)
            assoc.EndDate = DateTime.MinValue;
            errs++;
          }
          else if (i % 9 == 0)
          {
            //MT_OWNERSHIP_PERCENT_OUT_OF_RANGE = 0xE2FF0051; (-486604719)
            assoc.PercentOwnership = 101;
            errs++;
          }
          else if (i % 7 == 0)
          {
            //MT_CAN_NOT_OWN_SELF = 0xE2FF0053; (-486604717)
            assoc.OwnerAccount = owned;
            errs++;
          }
          else if (i % 5 == 0)
          {
            //-515899365 = KIOSK_ERR_ACCOUNT_NOT_FOUND
            assoc.OwnedAccount = i * 10000;
            errs++;
          }
          else if (i % 3 == 0)
          {
            //-2147483607 = E_FAIL (when relationship enum value does not exist in t_enum_data table)
            ((OwnershipAssociation)assoc).RelationTypeID = -100;
            errs++;
          }

          i++;

          assocs.Add(assoc);
          rowset.MoveNext();
        }

        var errrs = _mgr.AddOwnershipBatch(assocs, null);
        Assert.IsTrue(errrs.RecordCount > 0);
        Assert.AreEqual(errs, errrs.RecordCount);
      }

      /// <summary>
      /// Negative test: Create ownership relationships where start date is after end date
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T10TestCreateOwnershipBatchForInvalidDateCombination()
      {
        var assocs = (IMTCollection)new Coll.MTCollectionClass();
        var rowset = Util.GetAccountsForBatchOwnership();
        while (Convert.ToBoolean(rowset.EOF) == false)
        {
          var owned = (int)rowset.Value["id_acc"];
          var assoc = _mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = 0;
          assoc.StartDate = MetraTime.Now.AddDays(5);
          assoc.EndDate = MetraTime.Now.AddDays(4);
          assocs.Add(assoc);
          rowset.MoveNext();
        }

        var errs = _mgr.AddOwnershipBatch(assocs, null);
        Assert.IsTrue(errs.RecordCount > 0);
        while (Convert.ToBoolean(errs.EOF) == false)
        {
          var desc = (string)errs.Value["description"];
          Assert.AreEqual("Account ownership Start Date has to be before End Date\r\n", desc);
          errs.MoveNext();
        }
      }

      /// <summary>
      /// Negative test: Create ownership relationships where percent is greater than 100
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T11TestCreateOwnershipBatchForInvalidPercentGreaterThan100()
      {
        var assocs = (IMTCollection)new Coll.MTCollectionClass();
        var rowset = Util.GetAccountsForBatchOwnership();
        while (Convert.ToBoolean(rowset.EOF) == false)
        {
          var owned = (int)rowset.Value["id_acc"];
          var assoc = _mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = 101;
          assoc.StartDate = MetraTime.Now;
          assoc.EndDate = MetraTime.Max;
          assocs.Add(assoc);
          rowset.MoveNext();
        }

        var errs = _mgr.AddOwnershipBatch(assocs, null);
        Assert.IsTrue(errs.RecordCount > 0);
        while (Convert.ToBoolean(errs.EOF) == false)
        {
          var desc = (string)errs.Value["description"];
          Assert.AreEqual("Account ownership percentage has to be a value between 0 and 100\r\n", desc);
          errs.MoveNext();
        }
      }

      /// <summary>
      /// Negative test: Create ownership relationships where percent is greater less than 0
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T12TestCreateOwnershipBatchForInvalidPercentLessThan0()
      {
        var assocs = (IMTCollection)new Coll.MTCollectionClass();
        var rowset = Util.GetAccountsForBatchOwnership();
        while (Convert.ToBoolean(rowset.EOF) == false)
        {
          var owned = (int)rowset.Value["id_acc"];
          var assoc = _mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = -1;
          assoc.StartDate = MetraTime.Now;
          assoc.EndDate = MetraTime.Max;
          assocs.Add(assoc);
          rowset.MoveNext();
        }

        var errs = _mgr.AddOwnershipBatch(assocs, null);
        Assert.IsTrue(errs.RecordCount > 0);
        while (Convert.ToBoolean(errs.EOF) == false)
        {
          var desc = (string)errs.Value["description"];
          Assert.AreEqual("Account ownership percentage has to be a value between 0 and 100\r\n", desc);
          errs.MoveNext();
        }
      }

      /// <summary>
      /// Negative test: Create ownership relationships in batch for non-existing accounts
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T13TestCreateOwnershipBatchForNonExistingOwnedAccounts()
      {
        var assocs = (IMTCollection)new Coll.MTCollectionClass();
        var bogusaccounts = new ArrayList {2000000, 2000001, 2000002, 2000003, 2000004};

        for (var i = 0; i < bogusaccounts.Count; i++)
        {
          var owned = (int)bogusaccounts[i];
          var assoc = _mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = i;
          assoc.StartDate = MetraTime.Now;
          assoc.EndDate = MetraTime.Max;
          assocs.Add(assoc);
        }
        var errs = _mgr.AddOwnershipBatch(assocs, null);
        Assert.AreEqual(5, errs.RecordCount);
        while (Convert.ToBoolean(errs.EOF) == false)
        {
          var desc = (string)errs.Value["description"];
          Assert.AreEqual("The account was not found in the database.\r\n", desc);
          errs.MoveNext();
        }
      }

      /// <summary>
      /// Negative test: Create ownership relationships for non subscribers
      /// </summary>
      [Test]
      [Ignore]
      [Category("Fast")]
      public void T14TestCreateOwnershipBatchForNonSubscribers()
      {
        var assocs = (IMTCollection)new Coll.MTCollectionClass();
        var rowset = Util.GetNonSubscribers();
        while (Convert.ToBoolean(rowset.EOF) == false)
        {
          var owned = (int)rowset.Value["id_acc"];
          var assoc = _mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = 0;
          assoc.StartDate = MetraTime.Now;
          assoc.EndDate = MetraTime.Max;
          assocs.Add(assoc);
          rowset.MoveNext();
        }

        var errs = _mgr.AddOwnershipBatch(assocs, null);
        Assert.AreEqual(5, errs.RecordCount);
        while (Convert.ToBoolean(errs.EOF) == false)
        {
          var desc = (string)errs.Value["description"];
          Assert.AreEqual("Owned account must be a subscriber\r\n", desc);
          errs.MoveNext();
        }
      }
      
      /// <summary>
      /// Negative test: Create ownership relationships where end date is not set
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T15TestCreateOwnershipBatchForNotSetEndDate()
      {
        var assocs = (IMTCollection)new Coll.MTCollectionClass();
        var rowset = Util.GetAccountsForBatchOwnership();
        while (Convert.ToBoolean(rowset.EOF) == false)
        {
          var owned = (int)rowset.Value["id_acc"];
          var assoc = _mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = 0;
          assoc.StartDate = MetraTime.Now;
          //assoc.EndDate = MetraTime.Now.AddDays(4);
          assocs.Add(assoc);
          rowset.MoveNext();
        }

        var errs = _mgr.AddOwnershipBatch(assocs, null);
        Assert.IsTrue(errs.RecordCount > 0);
        while (Convert.ToBoolean(errs.EOF) == false)
        {
          var desc = (string)errs.Value["description"];
          Assert.AreEqual("Account ownership End Date not set\r\n", desc);
          errs.MoveNext();
        }
      }

      /// <summary>
      /// Negative test: Create ownership relationships where start date is not set
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T16TestCreateOwnershipBatchForNotSetStartDate()
      {
        var assocs = (IMTCollection)new Coll.MTCollectionClass();
        var rowset = Util.GetAccountsForBatchOwnership();
        while (Convert.ToBoolean(rowset.EOF) == false)
        {
          var owned = (int)rowset.Value["id_acc"];
          var assoc = _mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = 0;
          //assoc.StartDate = MetraTime.Now.AddDays(5);
          assoc.EndDate = MetraTime.Now.AddDays(4);
          assocs.Add(assoc);
          rowset.MoveNext();
        }

        var errs = _mgr.AddOwnershipBatch(assocs, null);
        Assert.IsTrue(errs.RecordCount > 0);
        while (Convert.ToBoolean(errs.EOF) == false)
        {
          var desc = (string)errs.Value["description"];
          Assert.AreEqual("Account ownership Start Date not set\r\n", desc);
          errs.MoveNext();
        }
      }

      /// <summary>
      /// Negative test: Create ownership relationships for the same owner/owned combination
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T17TestCreateOwnershipBatchForSameOwnerOwnedCombination()
      {
        var assocs = (IMTCollection)new Coll.MTCollectionClass();
        var rowset = Util.GetNonSubscribers();
        var owned = (int)rowset.Value["id_acc"];
        for (var i = 0; i < 6; i++)
        {
          var assoc = _mgr.CreateAssociationAsOwner();
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = 90;
          assoc.StartDate = MetraTime.Now;
          assoc.EndDate = MetraTime.Max;
          assocs.Add(assoc);
        }

        _mgr.AddOwnershipBatch(assocs, null);
      }

      /// <summary>
      /// Negative test: Create ownership relationships where account owns self
      /// </summary>
      [Test]
      [Category("Fast")]
      public void T18TestCreateOwnershipBatchForSelfOwnership()
      {
        var assocs = (IMTCollection)new Coll.MTCollectionClass();
        var rowset = Util.GetAccountsForBatchOwnership();
        while (Convert.ToBoolean(rowset.EOF) == false)
        {
          var owned = (int)rowset.Value["id_acc"];
          var assoc = _mgr.CreateAssociationAsOwner();
          assoc.OwnerAccount = owned;
          assoc.OwnedAccount = owned;
          assoc.RelationType = "Account Executive";
          assoc.PercentOwnership = 0;
          assoc.StartDate = MetraTime.Now;
          assoc.EndDate = MetraTime.Max;
          assocs.Add(assoc);
          rowset.MoveNext();
        }

        var errs = _mgr.AddOwnershipBatch(assocs, null);
        Assert.IsTrue(errs.RecordCount > 0);
        while (Convert.ToBoolean(errs.EOF) == false)
        {
          var desc = (string)errs.Value["description"];
          Assert.AreEqual("Account can not own itself\r\n", desc);
          errs.MoveNext();
        }
      }

      #region Private methods

      #endregion
    }
}