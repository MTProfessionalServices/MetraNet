using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Data;
using System.Threading;
using System.Runtime.InteropServices;

using NUnit.Framework;

using Coll = MetraTech.Interop.GenericCollection;
using Rowset = MetraTech.Interop.Rowset;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.Interop.COMMeter;
using MetraTech.DataAccess;
using MetraTech.Test;
using MetraTech.DataAccess.MaterializedViews;
using MetraTech.Interop.NameID;
using MetraTech.Metering.DatabaseMetering;
using MetraTech.Localization;
using MetraTech.Interop.MTEnumConfig;
using MetraTech.Interop.MTCalendar;
using YAAC = MetraTech.Interop.MTYAAC;
using MTAccountType = MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using MetraTech.Accounts.Type.Test;
using MetraTech.Interop.MTProductCatalog;

namespace MetraTech.UsageServer.Test
{
	//
  // To run the this test fixture:
  // nunit-console /fixture:MetraTech.UsageServer.Test.BillingGroupTest /assembly:O:\debug\bin\MetraTech.UsageServer.Test.dll
  //
  /// <summary>
  ///    Billing group tests.
  /// </summary>
  [TestFixture]
  [Category("NoAutoRun")]
  public class BillingGroupTest
  {
    #region Delegates
    public delegate void UtilDelegate(object[] parameters);
    #endregion

    #region Billing Group Creation Tests
    /// <summary>
    ///    Preconditions:
    ///      1) Interval with both paying and non-paying accounts
    ///    
    ///    PostConditions:  (to be ASSERTED)
    ///      1) One billing group created for the interval.
    ///      2) Billing group has expected name. 
    ///      3) The billing group contains expected number of accounts.
    ///      
    /// </summary>
    [Test]
    [Category("BillingGroupCreation")]
    public void T01TestCreateBillingGroupWithoutAssignmentQuery() 
    {
      string method = "'TestCreateBillingGroupWithoutAssignmentQuery'";

      // Creates billable and non-billable accounts
      Util util = Util.GetUtil();

      util.Log("Running " + method);
    
      // Get an interval for materialization
      int intervalId = util.GetIntervalForFullMaterialization();
      
      // Create billing groups using the default assignment query 
      util.BillingGroupManager.MaterializeBillingGroups(intervalId, util.UserId, true);

      // Check the results
      Rowset.IMTSQLRowset rowset = 
        util.BillingGroupManager.GetBillingGroupsRowset(intervalId, true);

      // Expect only one row
      Assert.AreEqual(1, rowset.RecordCount, "Number of billing groups mismatch");

      // Billing group name must be same as billingGroupManager.DefaultBillingGroupName
      Assert.AreEqual(util.BillingGroupManager.DefaultBillingGroupName,
        (string)rowset.get_Value("Name"),
        "Billing group name mismatch");

      // Number of accounts in the billing group must be the same as the number
      // of paying accounts in the interval.
      Assert.AreEqual(util.BillingGroupAccountIds.Count,
        Convert.ToInt32(rowset.get_Value("MemberCount")),
        "Number of accounts in billing group mismatch");

      // The paying account id's for the interval must match the members
      // of the billing group
      IBillingGroup billingGroup = 
        new MetraTech.UsageServer.BillingGroup((int)rowset.get_Value("BillingGroupID"));
      billingGroup.Name = (string)rowset.get_Value("Name");

      CheckBillingGroupAccounts(billingGroup, util.BillingGroupAccountIds);

      // Check that there are no unassigned accounts for the interval
      AssertNoUnassignedAccounts(intervalId);

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Post conditions:
    ///      1) Billing group called 'North America'.
    ///      2) Billing group called 'South America'.
    ///      3) Billing group called 'Europe'.
    /// </summary>
    [Test]
    [Category("TestCreateBillingGroupWithAssignmentQuery")]
    public void T02TestCreateBillingGroupWithAssignmentQuery() 
    {
      string method = "'TestCreateBillingGroupWithAssignmentQuery'";
      Util.GetUtil().Log("Running " + method);
      int intervalId;
      CreateBillingGroupsWithAssignmentQuery(out intervalId);
      Util.GetUtil().Log("Finished " + method);
    }
    #endregion

    #region Pull List Creation Tests
    /// <summary>
    ///   Create a pull list.
    /// </summary>
    [Test]
    [Category("PullListCreation")]
    public void T03TestCreatePullList() 
    {
      string method = "'TestCreatePullList'";

      Util util = Util.GetUtil();

      util.Log("Running " + method);

      // Create and soft close billing groups
      int intervalId = 0;
      // Store data for use by TestRematerialization
      billingGroupsForIntervalBeforePullListCreation = 
        CreateAndSoftCloseBillingGroups(out intervalId, true);

      IBillingGroup parentBillingGroup = 
        (IBillingGroup)billingGroupsForIntervalBeforePullListCreation[0];

      // Store data for use by TestRematerialization
      testParentBillingGroupId = parentBillingGroup.BillingGroupID;
   
      // Create a pull list
      IBillingGroup pullList = CreatePullList(parentBillingGroup, "Test pull list", null, false);

      // Store data for use by TestRematerialization
      testPullListId = pullList.BillingGroupID;

      util.Log("Finished " + method);
    }

    /// <summary>
    ///   1) Create billing groups.
    ///   2) From one of the billing groups (BG1) do the following:
    ///      a) Create a pull list (P1)
    ///      b) Create another pull list (P2)
    ///      c) Soft close (P2). Check adapter instances are created correctly.
    ///      d) Soft close (BG1). Check adapter instances are created correctly.
    ///      e) Soft close (P1). Check adapter instances are created correctly.
    /// </summary>
    [Test]
    [Category("PullListCreation")]
    public void T04TestCreatePullListVariation1() 
    {
      string method = "'TestCreatePullListVariation1'";

      Util util = Util.GetUtil();
      
      util.Log("Running " + method);

      // Create billing groups
      int intervalId = 0;
      ArrayList billingGroups = 
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Get the parent billing group (BG1)
      IBillingGroup bg1 = (IBillingGroup)billingGroups[0];
      // Create a pull list (P1)
      IBillingGroup p1 = CreatePullList(bg1, "P1", null, true);
      // Create a pull list (P2)
      IBillingGroup p2 = CreatePullList(bg1, "P2", null, true);
      // Soft close (P2). This checks adapter instances as well.
      SoftCloseBillingGroup(p2.BillingGroupID);
      // Soft close (BG1). This checks adapter instances as well.
      SoftCloseBillingGroup(bg1.BillingGroupID);
      // Soft close (P1). This checks adapter instances as well.
      SoftCloseBillingGroup(p1.BillingGroupID);

      util.Log("Finished " + method);
    }
    #endregion

    #region User Defined Group Creation Tests
    /// <summary>
    ///   Get an interval which has billing groups.
    ///   Meter some accounts to that interval.
    ///   Check that the new accounts fall into the unassigned category.
    ///   Create a user defined billing group with all the unassigned accounts.
    /// </summary>
    [Test]
    [Category("UserDefinedBillingGroup")]
    public void T05TestCreateUserDefinedBillingGroup() 
    {
      string method = "'TestCreateUserDefinedBillingGroup'";

      Util util = Util.GetUtil();

      util.Log("Running " + method);
      // Create billing groups for a non-materialized interval and store
      // data so that we can ensure that the system reverts to this set 
      // once rematerialization happens in a subsequent test
      int intervalId;
      billingGroupsForIntervalBeforeUserDefinedGroupCreation = 
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Meter 3 new accounts 
      ArrayList newAccounts = 
        CreateAccounts(Util.numberOfNewAccountsForUserDefinedGroup, true);
      
      // Refresh the usage interval
      IUsageInterval usageInterval =
        util.UsageIntervalManager.GetUsageInterval(intervalId);
 
      // Check that there are 3 open unassigned accounts
      Assert.AreEqual(Util.numberOfNewAccountsForUserDefinedGroup, 
                      usageInterval.OpenUnassignedAccountsCount, 
                      "Mismatch in number of open unassigned accounts!");

      // Create an user defined billing group
      util.BillingGroupManager.
        CreateUserDefinedBillingGroupFromAllUnassignedAccounts
          (intervalId, 
           util.UserId, 
           Util.userDefinedGroupName, 
           Util.userDefinedGroupDescription);

      // Look for the user defined billing group in the interval
      ArrayList billingGroups = GetBillingGroups(intervalId);
      Assert.AreEqual(true,
                      CheckBillingGroupExists(Util.userDefinedGroupName, billingGroups),
                      "User defined billing group not found!");

      // store the id
      IBillingGroup testUserDefinedBillingGroup = 
        GetBillingGroup(Util.userDefinedGroupName, intervalId);

      Assert.AreNotEqual(null, testUserDefinedBillingGroup,
                         "Could not find user defined billing group!");

      // Check that the user defined billing group is well formed
      CheckBillingGroup(testUserDefinedBillingGroup,
                        Util.userDefinedGroupName,
                        newAccounts);
      // store the billing group id
      testUserDefinedBillingGroupId = testUserDefinedBillingGroup.BillingGroupID;

      util.Log("Finished " + method);
    }

    #endregion

    #region Billing Group Re-creation Tests
    /// <summary>
    ///   Preconditions: The following tests must have run for this test to succeed.
    ///     1) TestCreatePullListForOpenBillingGroupWithNoAdapters
    ///     2) TestCreateUserDefinedBillingGroup
    ///     
    ///   At this stage we've created one pull list and one user defined
    ///   billing group. Both should be open and in different intervals.
    ///   
    ///   By rematerializing both intervals the pull list
    ///   and the user defined billing group should both disappear.
    ///   
    /// </summary>
    [Test]
    [Category("BillingGroupRecreation")]
    public void T06TestRematerialization() 
    {
      string method = "'TestRematerialization'";

      Util util = Util.GetUtil();

      util.Log("Running " + method);
      // Before rematerializing, open the parent billing group and
      // the pull list created in the TestCreatePullList test
      util.BillingGroupManager.
        OpenBillingGroup(testParentBillingGroupId, false, false);
      util.BillingGroupManager.
        OpenBillingGroup(testPullListId, false, false);

      // Rematerialize the interval for which a pull list has been created
      int intervalId = GetPullListIntervalId();
      util.BillingGroupManager.
        MaterializeBillingGroups(intervalId, util.UserId);

      // Check that the pull list has gone away
      ArrayList billingGroups = GetBillingGroups(intervalId);

      Assert.AreEqual(billingGroupsForIntervalBeforePullListCreation.Count,
                      billingGroups.Count,
                      "Expected the pull list to be deleted during rematerialization!");

      Assert.AreEqual(false, 
                      CheckBillingGroupExists(testPullListId, billingGroups),
                      "Expected the pull list to be deleted during rematerialization!");

      // Rematerialize the interval for which a user defined billing group has been created
      intervalId = GetUserDefinedGroupIntervalId();
      util.BillingGroupManager.MaterializeBillingGroups(intervalId, util.UserId);

      // Check that the user defined billing group has gone away
      billingGroups = GetBillingGroups(intervalId);

      Assert.AreEqual(billingGroupsForIntervalBeforeUserDefinedGroupCreation.Count,
                      billingGroups.Count,
                      "Expected the user defined billing group to be deleted " +
                      "during rematerialization!");

      Assert.AreEqual(false, 
                      CheckBillingGroupExists(testUserDefinedBillingGroupId, 
                                              billingGroups),
                      "Expected the user defined billing group to be " +
                      "deleted during rematerialization!");

      util.Log("Finished " + method);
    }
    #endregion

    #region Billing Group State Change Tests
    /// <summary>
    ///    Soft closes a billing group. 
    ///    Check that the right number of adapter instances get generated.
    /// </summary>
    [Test]
    [Category("BillingGroupStateChange")]
    public void T07TestSoftCloseBillingGroups() 
    {
      string method = "'TestSoftCloseBillingGroups'";

      Util util = Util.GetUtil();

      util.Log("Running " + method);

      // Create billing groups for a non-materialized interval
      int intervalId;
      CreateBillingGroupsWithAssignmentQuery(out intervalId);

      SoftCloseInterval(intervalId);

      util.Log("Finished " + method);
    }

    #endregion

    #region Hard Closing Unassigned Accounts Tests
    /// <summary>
    ///    1) Create billing groups
    ///    2) Soft close them
    ///    3) Meter new accounts
    ///    4) Meter usage for those new accounts
    ///    5) Verify usage has been received
    ///    6) Hard close unassigned accounts
    ///    7) Check that usage for those accounts have been bounced to
    ///       the next open interval.
    ///    8) Verify that accounts have a status of hard closed 
    ///       in t_acc_usage_interval for the old interval id.
    ///    9) Verify that the accounts have a status of open
    ///       in t_acc_usage_interval for the new interval id. 
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestHardCloseOfUnassignedAccounts")]
    public void T08TestHardCloseOfUnassignedAccounts() 
    {
      string method = "'TestHardCloseOfUnassignedAccounts'";
      
      Util util = Util.GetUtil();

      util.Log("Running " + method);

      // Create billing groups for a non-materialized interval
      int intervalId;
      CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Soft close the billing groups
      SoftCloseInterval(intervalId);

      // Meter new accounts
      ArrayList accounts = 
        CreateAccounts(Util.numberOfNewAccountsToBeHardClosed, true);

      // Meter new usage for the accounts and verify that it landed in the given interval
      MeterUsage(accounts, intervalId, true);

      // Hard close unassigned accounts
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = 
        loginContext.Login("su", "system_user", "su123");

      util.BillingGroupManager.
        SetAccountStatusToHardClosedForInterval(GetCollection(accounts),
                                                intervalId,
                                                true,
                                                sessionContext);

      // should probably poll t_message every few secs instead of arbitrary sleep
      Thread.Sleep(5000*3);

      // Verify that the usage has been bounced to the next open interval
      int nextIntervalId = util.GetNextOpenInterval(intervalId);
      VerifyUsage(accounts, nextIntervalId, true);

      // Check that the status of the accounts are hard closed in the
      // old interval
      util.VerifyAccountStatus(accounts, intervalId, "H");

      // Check that the status of the accounts are open in the
      // new interval
      util.VerifyAccountStatus(accounts, nextIntervalId, "O");
                             
      util.Log("Finished " + method);             
    }

    #endregion
    
    #region Usage Interval Resolution Tests

    /// <summary>
    ///    1) Create billing groups
    ///    2) Meter usage to existing accounts with the time associated
    ///       with the current interval.
    ///    3) Validate that the usage does land in the current interval.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("UsageIntervalResolution1")]
    public void T09TestUsageIntervalResolutionForOpenBillingGroup() 
    {
      string method = "'TestUsageIntervalResolutionForOpenBillingGroup'";
      
      Util util = Util.GetUtil();

      util.Log("Running " + method);

      // Create billing groups for a non-materialized interval
      int intervalId;
      CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Meter usage to US accounts with the time associated
      // with the current interval and verify that the usage did land
      // in the given interval
      MeterUsage(util.UkAccountIds, intervalId, true);

      util.Log("Finished " + method);

    }

    /// <summary>
    ///    1) Create billing groups
    ///    2) Soft close them
    ///    3) Meter usage to existing accounts with the time associated
    ///       with the current interval.
    ///    4) Validate that the usage does not land in the current interval.
    ///    5) Validate that the usage lands in the next open interval.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("UsageIntervalResolution")]
    public void T10TestUsageIntervalResolutionForSoftClosedBillingGroup() 
    {
      string method = "'TestUsageIntervalResolutionForSoftClosedBillingGroup'";
      
      Util util = Util.GetUtil();

      util.Log("Running " + method);

      // Create billing groups for a non-materialized interval
      int intervalId;
      CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Soft close the billing groups
      SoftCloseInterval(intervalId);

      // Meter usage to US accounts with the time associated
      // with the current interval and verify that the usage did not land
      // in the given interval
      MeterUsage(util.UkAccountIds, intervalId, false);

      // Verify that the usage did land in the next open interval
      int nextIntervalId = util.GetNextOpenInterval(intervalId);
      VerifyUsage(util.UkAccountIds, nextIntervalId, true);

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    1) Create billing groups
    ///    2) Soft close them, execute adapters and hard close the interval.
    ///    3) Meter usage to existing accounts with the time associated
    ///       with the current interval.
    ///    4) Validate that the usage does not land in the current interval.
    ///    5) Validate that the usage lands in the next open interval.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestUsageIntervalResolutionForHardClosedBillingGroup")]
    public void T11TestUsageIntervalResolutionForHardClosedBillingGroup() 
    {
      string method = "'TestUsageIntervalResolutionForHardClosedBillingGroup'";
      
      Util util = Util.GetUtil();

      util.Log("Running " + method);

      // Create billing groups, soft close them, run adapters and
      // get the interval id. The interval will be hard closed.
      int intervalId = 
        TestIntervalAdapterExecutionInternal(Util.intervalAccountAdapterFileName, true);

      // Meter usage to US accounts with the time associated
      // with the current interval and verify that the usage did not land
      // in the given interval
      MeterUsage(util.UkAccountIds, intervalId, false);

      // Verify that the usage did land in the next open interval
      int nextIntervalId = util.GetNextOpenInterval(intervalId);
      VerifyUsage(util.UkAccountIds, nextIntervalId, true);

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    1) Create billing groups
    ///    2) Soft close them, execute adapters and hard close the interval.
    ///    3) Meter usage to existing accounts by specifying the special _IntervalID property
    ///    4) Validate that a failure occurs.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestUsageIntervalResolutionForHardClosedBillingGroupWithIntervalId")]
    public void T12TestUsageIntervalResolutionForHardClosedBillingGroupWithIntervalId() 
    {
      string method = "'TestUsageIntervalResolutionForHardClosedBillingGroupWithIntervalId'";
      
      Util util = Util.GetUtil();

      util.Log("Running " + method);

      // Get an interval that has not been materialized
      int intervalId = util.GetIntervalForFullMaterialization();

      // Create and soft close billing groups for the interval
      ArrayList billingGroups = CreateAndSoftCloseBillingGroups(intervalId, true);
      IBillingGroup billingGroup = (IBillingGroup)billingGroups[0];

      // HardClose the billing group
      util.BillingGroupManager.HardCloseBillingGroup(billingGroup.BillingGroupID);

      // Get the billing group accounts
      ArrayList billingGroupAccounts = util.BillingGroupManager.GetBillingGroupMembers(billingGroup.BillingGroupID);

      // Meter usage to the billing group accounts with the _IntervalID property set to intervalId.
      // This should cause an error to be thrown.
      MeterUsage(billingGroupAccounts, intervalId, intervalId, false);

      // Verify that the usage did not land in the interval specified by _IntervalID 
      VerifyUsage(billingGroupAccounts, intervalId, false);

      // Verify that the usage did not land in the next open interval 
      int nextIntervalId = util.GetNextOpenInterval(intervalId);
      VerifyUsage(billingGroupAccounts, nextIntervalId, false);

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    1) Create billing groups
    ///    2) Block the interval. Verify that the interval is blocked.
    ///    3) Meter usage to existing accounts with the time associated
    ///       with the current interval. 
    ///    4) Validate that the usage does land in the current interval.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestUsageIntervalResolutionForBlockedInterval")]
    public void T13TestUsageIntervalResolutionForBlockedInterval() 
    {
      string method = "'TestUsageIntervalResolutionForBlockedInterval'";
      
      Util util = Util.GetUtil();

      util.Log("Running " + method);

      // Create billing groups for a non-materialized interval
      int intervalId;
      CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Block the interval
      util.BillingGroupManager.SetIntervalAsBlockedForNewAccounts(intervalId);
      VerifyIntervalStatus(intervalId, UsageIntervalStatus.Blocked);

      // Meter usage to US accounts with the time associated
      // with the current interval and verify that the usage did land
      // in the given interval
      MeterUsage(util.UkAccountIds, intervalId, true);

      util.Log("Finished " + method);
    }

    /// <summary>
    ///   If the _IntervalID special property is metered and the 
    ///   payer account ID/interval ID is such so that the billing group 
    ///   the usage would fall into is hard closed, 
    ///   then the usage should fail and not bounce.
    /// 
    ///   1) Create billing groups
    ///   2) Soft close them, execute adapters and hard close the interval.
    ///   3) Meter usage to existing accounts with the time associated
    ///      with the current interval. Also meter the _IntervalID special
    ///      property such that _IntervalID is the same as current interval id.
    ///   4) Validate that the usage does land in the current interval.
    ///   5) Validate that the transactions failed.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("UsageIntervalResolution")]
    public void T14TestUsageIntervalResolutionForHardClosedInterval() 
    {
      string method = "'TestUsageIntervalResolutionForHardClosedInterval'";
      
      Util util = Util.GetUtil();

      util.Log("Running " + method);

      // Create billing groups, soft close them, run adapters and
      // get the interval id. The interval will be hard closed.
      int intervalId = 
        TestIntervalAdapterExecutionInternal(Util.intervalAccountAdapterFileName, true);

      // Meter usage to US accounts with the time associated
      // with the current interval. 
      // Validate that the sessions fail
      MeterUsage(util.UkAccountIds, intervalId, intervalId, false);

      util.Log("Finished " + method);
    }
    #endregion

    #region Adapter Execution Tests

    /// <summary>
    ///    1) Create billing groups
    ///    2) Soft close each billing group
    ///    3) Execute adapters for each billing group
    ///    4) Verify that each adapter has succeeded
    ///    5) Verify that the billing group status is hard closed.
    ///    6) Verify that the interval status is hard closed. 
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("AdapterExecution1")]
    public void T15TestAdapterExecution() 
    {
      string method = "'TestAdapterExecution'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      // Reset the events
      util.SetupAdapterDependencies(null);

      // Create and soft close billing groups
      int intervalId = 0;
      ArrayList billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);

      // Instantiate scheduled events
      util.Client.InstantiateScheduledEvents();
      // Execute the scheduled events
      ExecuteScheduledEvents(intervalId);

      foreach(IBillingGroup billingGroup in billingGroups) 
      {
        // Execute adapters. 
        // The system hard closes the billing group once all adapters have executed.
        ExecuteAdapters(billingGroup);
      }

      // Check that the interval is hard closed
      VerifyIntervalStatus(intervalId, UsageIntervalStatus.HardClosed);

      util.Log("Finished " + method);
    }

    /// <summary>
    ///   [See Bug: CR 13067]
    ///   1) Create billing groups
    ///   2) Meter usage to accounts for one billing group. Verify usage exists.
    ///   3) Soft close the billing group
    ///   4) Execute invoice adapter for the billing group and 
    ///      verify that it succeeded
    ///   5) Check that invoices have been generated in t_invoice
    ///   6) Backout usage. Verify usage has been backed out.
    ///   7) Reverse invoice adapter for the billing group. 
    ///      Verify that adapter reversed successfully.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestInvoiceAdapterReversalWithBackout")]
    // [Ignore("TestInvoiceAdapterReversalWithBackout will be enabled when invoice adapter/datamart bug is fixed.")]
    public void T16TestInvoiceAdapterReversalWithBackout() 
    {
      string method = "'TestInvoiceAdapterReversalWithBackout'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      // Reset the events
      util.SetupAdapterDependencies(null);

      // Create billing groups for a non-materialized interval 
      int intervalId;
      ArrayList billingGroups = 
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Pick the first billing group 
      IBillingGroup billingGroup = (IBillingGroup)billingGroups[0];
      ArrayList accounts = 
        util.BillingGroupManager.GetBillingGroupMembers(billingGroup.BillingGroupID);
      
      // Meter usage to the billing group accounts with the time associated
      // with the current interval and verify that the usage did land
      // in the given interval
      MeterUsage(accounts, intervalId, true);

      // Force materialized views to update.
      Manager mvm = new Manager();
      mvm.Initialize();
      mvm.UpdateAllDeferredMaterializedViews();

      // Soft close the billing group
      SoftCloseBillingGroup(billingGroup.BillingGroupID);

      // Execute the invoice adapter, ignore dependencies
      ExecuteAdapter(intervalId, billingGroup.BillingGroupID, 
                     Util.invoiceAdapterClassName, 
                     true, // execute
                     true, // ignoreDependencies
                     RecurringEventInstanceStatus.Succeeded);      
      

      // Check invoice generation
      CheckInvoices(intervalId, accounts, true);

      // Backout and delete usage
      BackoutUsage(intervalId, accounts, false);

      // Verify that usage does not exist
      VerifyUsage(accounts, intervalId, false);

      // Reverse the invoice adapter
      ExecuteAdapter(intervalId, billingGroup.BillingGroupID, 
                     Util.invoiceAdapterClassName, 
                     false, // execute
                     true,  // ignoreDependencies 
                     RecurringEventInstanceStatus.NotYetRun);      

      // Check invoices have been deleted
      CheckInvoices(intervalId, accounts, false);

      util.Log("Finished " + method);
    }

    /// <summary>
    ///   [See Bug: CR 13129]
    ///
    ///  1) Create two accounts A and B - weekly billing cycle
    ///  2) Meter usage to A and B 
    ///  3) Generate a billing group and run the invoice adapter. 
    ///  4) This will generate two invoices for A and B 
    ///  5) Make B payer for A and make A non-billable 
    ///  6) Generate billing groups for the next open interval 
    ///  7) Run the payer change adapter. 
    ///  8) In MetraView you will see that A has bill for current interval, 
    ///     while B has previous usage plus a debit for A’s previous usage.  
    ///     Payer Change Adapter creates a credit record for A and debit record for B. 
    ///  9) Now reverse the Payer Change Adapter. 
    /// </summary>
    [Test]
    [Category("TestPayerChangeAdapter")]
    // [Ignore("Ignoring TestPayerChangeAdapter temporarily.")]
    public void T17TestPayerChangeAdapter() 
    {
      string method = "'TestPayerChangeAdapter'";

      
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      // Reset the events
      util.SetupAdapterDependencies(null);

      // Create two accounts 
      ArrayList accountIds = CreateAccounts(2, true);
      Assert.AreEqual(2, accountIds.Count, "Expected 2 accounts to have been created");

      int account1 = (int)accountIds[0];
      int account2 = (int)accountIds[1]; // future payee

      // Get an interval that has not been materialized
      int intervalId = util.GetIntervalForFullMaterialization();
      IUsageInterval usageInterval = util.UsageIntervalManager.GetUsageInterval(intervalId);

      // Meter usage to the accounts for the interval
      MeterUsage(accountIds, intervalId, true);

	  // Force materialized views to update.
	  Manager mvm = new Manager();
	  mvm.Initialize();
	  mvm.UpdateAllDeferredMaterializedViews();

      // Create and soft close billing groups for the interval
      ArrayList billingGroups = CreateAndSoftCloseBillingGroups(intervalId, true);
      
      // The two new accounts will be in the North America billing group because
      // they were created as US accounts
      IBillingGroup northAmericaBillingGroup = null;
      foreach(IBillingGroup billingGroup in billingGroups) 
      {
        if (billingGroup.Name.Equals(Util.northAmericaBillingGroupName)) 
        {
          northAmericaBillingGroup = billingGroup;
          break;
        }
        }

      // Check that we have a North America billing group
      Assert.IsNotNull(northAmericaBillingGroup, "Expected to find a 'North America' billing group");
      // Check that we have account1 and account2 in the billing group
      CheckBillingGroupAccountMembership(northAmericaBillingGroup.BillingGroupID, accountIds, true);

      // Execute the Invoice adapter for North America billing group, ignore dependencies
      ExecuteAdapter(intervalId, 
                      northAmericaBillingGroup.BillingGroupID, 
                      Util.invoiceAdapterClassName, 
                      true, // execute
                      true, // ignoreDependencies
                      RecurringEventInstanceStatus.Succeeded);   

      // Check invoice generation
      CheckInvoices(intervalId, accountIds, true);

      // Make account2 a payee account and make account1 its payer
      util.MoveAccountFromPayerToPayee(account2, usageInterval.StartDate, account1);

      // Get the next open interval
      int nextIntervalId = util.GetNextOpenInterval(intervalId);

      // Create and soft close billing groups for the next interval
      billingGroups = CreateAndSoftCloseBillingGroups(nextIntervalId, true);

      // Get the North America billing group. This time it should have account1 but not account2
      northAmericaBillingGroup = null;
      foreach(IBillingGroup billingGroup in billingGroups) 
        {
        if (billingGroup.Name.Equals(Util.northAmericaBillingGroupName)) 
        {
          northAmericaBillingGroup = billingGroup;
          break;
        }
      }

      // Check that we have a North America billing group
      Assert.IsNotNull(northAmericaBillingGroup, "Expected to find a 'North America' billing group");
      // Check that we have still have account1 and account2 in the billing group
      CheckBillingGroupAccountMembership(northAmericaBillingGroup.BillingGroupID, accountIds, true);

      // Execute the Payer Change adapter for North America, ignore dependencies
      ExecuteAdapter(nextIntervalId, 
                     northAmericaBillingGroup.BillingGroupID, 
                     Util.payerChangeAdapterClassName, 
                     true, // execute
                     true, // ignoreDependencies
                     RecurringEventInstanceStatus.Succeeded);   

      // Verify that the payment redirection did happen
      util.VerifyPaymentRedirection(account1, account2, nextIntervalId, true);

      // Execute the Invoice adapter for North America billing group, ignore dependencies
      ExecuteAdapter(nextIntervalId, 
                     northAmericaBillingGroup.BillingGroupID, 
                     Util.invoiceAdapterClassName, 
                     true, // execute
                     true, // ignoreDependencies
                     RecurringEventInstanceStatus.Succeeded);   

      // Check invoice generation
      CheckInvoices(nextIntervalId, accountIds, true);

      // Reverse the payer change adapter for North America, ignore dependencies
      ExecuteAdapter(nextIntervalId, 
                     northAmericaBillingGroup.BillingGroupID, 
                     Util.payerChangeAdapterClassName, 
                     false, // reverse
                     true, // ignoreDependencies
                     RecurringEventInstanceStatus.NotYetRun); 

      // Verify that there is no payment redirection
      util.VerifyPaymentRedirection(account1, account2, nextIntervalId, false);

    }
    #endregion

    #region Adapter Dependency Tests

    #region Interval
    /// <summary>
    ///    See comments for the method:
    ///    TestIntervalAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T18TestIntervalAccountExecution() 
    {
      string method = "'TestIntervalAccountExecution'";
      Util.GetUtil().Log("Running " + method);
      try 
      {
        // Location specified by Util.testDir
        TestIntervalAdapterExecutionInternal(Util.intervalAccountAdapterFileName, true); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestIntervalAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T19TestIntervalAccountReversal() 
    {
      string method = "'TestIntervalAccountReversal'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        TestIntervalAdapterReversalInternal(Util.intervalAccountAdapterFileName);
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestIntervalAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T20TestIntervalBillingGroupExecution() 
    {
      string method = "'TestIntervalBillingGroupExecution'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        TestIntervalAdapterExecutionInternal
          (Util.intervalBillingGroupAdapterFileName, true); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestIntervalAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T21TestIntervalBillingGroupReversal() 
    {
      string method = "'TestIntervalBillingGroupReversal'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        TestIntervalAdapterReversalInternal(Util.intervalBillingGroupAdapterFileName);
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestIntervalIntervalExecutionInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T22TestIntervalIntervalExecution() 
    {
      string method = "'TestIntervalIntervalExecution'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        TestIntervalIntervalExecutionInternal
          (Util.intervalIntervalAdapterFileName, true); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestIntervalIntervalReversalInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T22TestIntervalIntervalReversal() 
    {
      string method = "'TestIntervalIntervalReversal'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        TestIntervalIntervalReversalInternal
          (Util.intervalIntervalAdapterFileName); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }
    #endregion

    #region BillingGroup

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T23TestBillingGroupAccountExecution() 
    {
      string method = "'TestBillingGroupAccountExecution'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        // Location specified by Util.testDir
        TestBillingGroupAdapterExecutionInternal
          (Util.billingGroupAccountAdapterFileName, true); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T24TestBillingGroupAccountReversal() 
    {
      string method = "'TestBillingGroupAccountReversal'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        TestBillingGroupAdapterReversalInternal
          (Util.billingGroupAccountAdapterFileName); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);

    }

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T25TestBillingGroupBillingGroupExecution() 
    {
      string method = "'TestBillingGroupBillingGroupExecution'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        // Location specified by Util.testDir
        TestBillingGroupAdapterExecutionInternal
          (Util.billingGroupBillingGroupAdapterFileName, true); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }

      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T26TestBillingGroupBillingGroupReversal() 
    {
      string method = "'TestBillingGroupBillingGroupReversal'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        TestBillingGroupAdapterReversalInternal
          (Util.billingGroupBillingGroupAdapterFileName); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T27TestBillingGroupIntervalExecution() 
    {
      string method = "'TestBillingGroupIntervalExecution'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        // Location specified by Util.testDir
        TestBillingGroupIntervalExecutionInternal
          (Util.billingGroupIntervalAdapterFileName, true); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupIntervalReversalInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T28TestBillingGroupIntervalReversal() 
    {
      string method = "'TestBillingGroupIntervalReversal'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        TestBillingGroupIntervalReversalInternal
          (Util.billingGroupIntervalAdapterFileName); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    1) Setup an adapter chain of the following type:
    ///        - Adapter A (Account)
    ///        - Adapter B (BillingGroup)
    ///       (B) is dependent on (A)
    ///       (A) is an account-only adapter and (B) is a BillingGroup adapter
    ///    2) Get an interval with 3 billing groups (BG1, BG2, BG3).
    ///    3) Soft close each billing group. Each billing group has an
    ///       instance of (A) and an instance of (B).
    ///    4) Create a pull list (P1) from BG1. 
    ///       (P1) has an instance of (A) but not of (B). 
    ///       This is verified during pull list creation.
    ///    5) Create another pull list (P2) from (P1).
    ///       (P2) has an instance of (A) but not of (B).  
    ///    6) Execute adapters for BG1
    ///        BG1-A - should succeed
    ///        BG1-B - should not succeed (until P1-A and P2-A have executed successfully)
    ///    8) Execute adapters for P1
    ///        P1-A - should succeed
    ///    9) Execute adapters for BG1
    ///        BG1-B - should not succeed (until P1-A and P2-A have executed successfully) 
    ///   10) Execute adapters for P2 
    ///        P2-A - should succeed
    ///        BG1-B - should succeed because its dependencies are satisfied
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T29TestBillingGroupAdapterWithPullList() 
    {
      string method = "'TestBillingGroupAdapterWithPullList'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      try 
      {
        string p1Name = "P1";
        string p2Name = "P2";

        // Prepare t_recevent
        util.SetupAdapterDependencies
          (Util.testDir + Util.billingGroupAccountAdapterFileName);

        // Create and soft close billing groups
        int intervalId = 0;
        ArrayList billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);

        // Let the first billing group be the parent billing group
        IBillingGroup bg1 = (IBillingGroup)billingGroups[0];

        // Create a pull list from the first billing group
        IBillingGroup p1 = CreatePullList(bg1, p1Name, null, false);
        // Create a pull list from p1
        IBillingGroup p2 = CreatePullList(p1, p2Name, null, false);
        
        // Execute BG1-A. Should succeed. Expect 'Succeeded'
        // Execute BG1-B. Should not succeed. Expect 'ReadyToRun'
        ExecuteAdapters(bg1.IntervalID, 
          bg1.BillingGroupID,
          BillingGroupAdapterWithPullListData.
          GetDataForParentBillingGroup(),
          false);
        
        // Execute P1-A. Should succeed. Expect 'Succeeded'
        ExecuteAdapters(p1.IntervalID, 
          p1.BillingGroupID,
          BillingGroupAdapterWithPullListData.GetDataForPullList(),
          false);

        // Verify that BG1-B is still 'ReadyToRun'. 
        CheckAdapterInstances(bg1.IntervalID, bg1.BillingGroupID,
          BillingGroupAdapterWithPullListData.
          GetDataForBillingGroupExpectReadyToRun());
         
        // Execute P2-A. Should succeed. Expect 'Succeeded'
        ExecuteAdapters(p2.IntervalID, 
          p2.BillingGroupID,
          BillingGroupAdapterWithPullListData.GetDataForPullList(),
          false);

        // Verify that BG1-B has changed to 'Succeeded'. 
        CheckAdapterInstances(bg1.IntervalID, 
          bg1.BillingGroupID,
          BillingGroupAdapterWithPullListData.
          GetDataForBillingGroupExpectSucceeded());
      }
      finally 
      {
        // Reset the events
        util.SetupAdapterDependencies(null);
      }

      util.Log("Finished " + method);
    }

    #endregion

    #region Account
    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T30TestAccountAccountExecution() 
    {
      string method = "'TestAccountAccountExecution'";
      Util.GetUtil().Log("Running " + method);


      try 
      {
        // Location specified by Util.testDir
        TestBillingGroupAdapterExecutionInternal
          (Util.accountAccountAdapterFileName, true); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T31TestAccountAccountReversal() 
    {
      string method = "'TestAccountAccountReversal'";
      Util.GetUtil().Log("Running " + method);


      try 
      {
        TestBillingGroupAdapterReversalInternal
          (Util.accountAccountAdapterFileName); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T32TestAccountBillingGroupExecution() 
    {
      string method = "'TestAccountBillingGroupExecution'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        // Location specified by Util.testDir
        TestBillingGroupAdapterExecutionInternal
          (Util.accountBillingGroupAdapterFileName, true); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T33TestAccountBillingGroupReversal() 
    {
      string method = "'TestAccountBillingGroupReversal'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        TestBillingGroupAdapterReversalInternal
          (Util.accountBillingGroupAdapterFileName); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T34TestAccountIntervalExecution() 
    {
      string method = "'TestAccountIntervalExecution'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        // Location specified by Util.testDir
        TestBillingGroupIntervalExecutionInternal
          (Util.accountIntervalAdapterFileName, true); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for the method:
    ///    TestBillingGroupIntervalReversalInternal
    /// </summary>
    [Test]
    [Category("AdapterDependency")]
    public void T35TestAccountIntervalReversal() 
    {
      string method = "'TestAccountIntervalReversal'";
      Util.GetUtil().Log("Running " + method);

      try 
      {
        TestBillingGroupIntervalReversalInternal
          (Util.accountIntervalAdapterFileName); 
      }
      finally 
      {
        // Reset the events
        Util.GetUtil().SetupAdapterDependencies(null);
      }
      Util.GetUtil().Log("Finished " + method);
    }
    #endregion

    #region Misc

    #endregion

    #endregion

    #region BillingRerun Tests
    /// <summary>
    ///    See comments for TestBackout.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("BillingRerun")]
    public void T36TestBackoutFailureForHardCloseAccounts() 
    {
      string method = "'TestBackoutFailureForHardCloseAccounts'";
      Util.GetUtil().Log("Running " + method);
      TestBackout(true);
      Util.GetUtil().Log("Finished " + method);
    }

    /// <summary>
    ///    See comments for TestBackout.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("BillingRerun")]
    public void T37TestBackoutSuccessForSoftClosedAccounts() 
    {
      string method = "'TestBackoutSuccessForSoftClosedAccounts'";
      Util.GetUtil().Log("Running " + method);
      TestBackout(false);
      Util.GetUtil().Log("Finished " + method);
    }
    #endregion

    #region Display Tests
    /// <summary>
    ///    Test the __GET_EOP_EVENT_INSTANCES_FOR_DISPLAY__ query.
    ///    1) Use the adapter hierarchy specified in bg_eop_query_test.xml
    ///         - Adapter A (Account)
    ///         - Adapter B (Account)
    ///         - Adapter C (BillingGroup)
    ///         - Adapter D (Account)
    ///         - Adapter E (Account)
    ///         - Adapter F (BillingGroup)
    ///         - Adapter G (Interval)
    ///       The order of the adapters specifies the dependencies.
    ///    2) Start with three billing groups - BG1, BG2, BG3.
    ///    3) Soft close BG1.
    ///    4) Check the presence and order of the adapter instances.
    ///    5) Create a pull list P1 from BG1.
    ///    6) Do the check in step(4).
    ///    7) Create a pull list from P2 from P1
    ///    8) Do the check in step(4).
    ///    9) Run the query for BG2. Check that no adapter instances exist.
    ///   10) Repeat steps 3,4,5,6,7,8 for BG2.
    /// </summary>
    [Test]
    [Category("Query")]
    public void T38TestEndOfPeriodQuery() 
    {
      string method = "'TestEndOfPeriodQuery'";
      Util.GetUtil().Log("Running " + method);

      Util.GetUtil().Log("Finished " + method);
    }
    #endregion

    #region Negative Tests

    #region Materialization Tests
    /// <summary>
    ///    1) Get an interval with no paying accounts but with payee accounts.
    ///    2) Create billing groups for this interval.
    ///    3) Check that MaterializingIntervalWithoutPayersException is thrown.
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(MaterializingIntervalWithoutPayersException))]
    public void T39TestCreateMaterializationForIntervalWithNoPayingAccounts()
    {
      string method = "'TestCreateMaterializationForIntervalWithNoPayingAccounts'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      try 
      {
        // Get an interval for materialization
        int intervalId = util.GetIntervalWithoutPayers();
 
        // Create billing groups  
        util.BillingGroupManager.CreateMaterialization(intervalId, util.UserId);
      }
      finally 
      {
        util.Log("Finished " + method);
      }
    }

    /// <summary>
    ///    1) Get a hard closed interval.
    ///    2) Create billing groups for this interval.
    ///    3) Check that MaterializingHardClosedIntervalException is thrown.
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(MaterializingHardClosedIntervalException))]
    public void T40TestCreateMaterializationForHardClosedInterval()
    {
      string method = "'TestCreateMaterializationForHardClosedInterval'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);
      
      try 
      {
        // Get a hard closed interval
        int intervalId = util.GetHardClosedInterval();
    
        // Create billing groups  
        util.BillingGroupManager.MaterializeBillingGroups(intervalId, util.UserId);
      }
      finally 
      {
        util.Log("Finished " + method);
      }
    }


    /// <summary>
    ///    Preconditions:
    ///     1) Entry in t_recevent_inst for adapter with a status
    ///        of 'Running'
    ///        
    ///    PostConditions:
    ///     1) MaterializingWhileAdapterProcessingException is thrown
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(MaterializingWhileAdapterProcessingException))]
    public void T41TestCreateMaterializationWhileAdapterInstanceRunning()
    {
      string method = "'TestCreateMaterializationWhileAdapterInstanceRunning'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      // Get an interval for materialization
      int intervalId = util.GetIntervalForFullMaterialization();
     
      // Create a dummy adapter instance row
      int instanceId = util.CreateDummyAdapterRow(new object[]{intervalId, "Running"});
     
      // Create billing groups  
      try 
      {
        util.BillingGroupManager.CreateMaterialization(intervalId, util.UserId);
      }
      finally 
      {
        // Delete the dummy adapter instance row created earlier
        util.DeleteDummyAdapterRow("Running");
      }

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Preconditions:
    ///     1) Entry in t_billgroup_materialization with a status
    ///        of 'InProgress'
    ///        
    ///    PostConditions:
    ///     1) MaterializationInProgressException is thrown
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(MaterializationInProgressException))]
    public void T42TestCreateMaterializationWhileAnotherIsInProgress()
    {
      string method = "'TestCreateMaterializationWhileAnotherIsInProgress'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      // Get an interval for materialization
      int intervalId = util.GetIntervalForFullMaterialization();
     
      // Create a dummy materialization row
      int materializationId = 
        Util.CreateMaterializationRow(intervalId, 
        MaterializationStatus.InProgress,
        MaterializationType.Full,
        util.UserId);
      
      // Create billing groups  
      try 
      {
        util.BillingGroupManager.CreateMaterialization(intervalId, util.UserId);
      }
      finally 
      {
        // Delete the dummy adapter materialization row created earlier
        util.DeleteDummyMaterializationRow(materializationId);
      }

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Preconditions:
    ///     1) Entry in t_billgroup_materialization with a status
    ///        of 'Full'
    ///        
    ///    PostConditions:
    ///     1) RepeatFullMaterializationException is thrown
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(RepeatFullMaterializationException))]
    public void T43TestRepeatFullMaterialization()
    {
      string method = "'TestRepeatFullMaterialization'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      // Get an interval for materialization
      int intervalId = util.GetIntervalForFullMaterialization();
      
      // Create a dummy materialization row
      int materializationId = 
        Util.CreateMaterializationRow(intervalId, 
        MaterializationStatus.Succeeded,
        MaterializationType.Full,
        util.UserId);
      // Create billing groups   
      try 
      {
        util.BillingGroupManager.
          CreateMaterialization(intervalId,
          util.UserId,
          MetraTime.Now,
          null,
          MaterializationType.Full.ToString());
      }
      finally 
      {
        // Delete the dummy adapter materialization row created earlier
        util.DeleteDummyMaterializationRow(materializationId);
      }

      util.Log("Finished " + method);
    }

   
    #endregion

    #region Constraint Tests
    /// <summary>
    ///    Preconditions:
    ///     1) Create an entry in t_billgroup_constraint_tmp for one 
    ///        of the paying accounts
    ///        
    ///    PostConditions:
    ///     1) DuplicateAccountsInConstraintGroupsException is thrown
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(DuplicateAccountsInConstraintGroupsException))]
    public void T44TestDuplicateAccountsInBillGroupConstraint()
    {
      string method = "'TestDuplicateAccountsInBillGroupConstraint'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      int intervalId = 0;
      int materializationId = 0;

      UtilDelegate utilDelegate = 
        new UtilDelegate(util.CreateDummyBillGroupConstraintTmpRow);

      object[] parameters = new object[] {(int)util.PayerAccountIds[0],
                                           (int)util.PayerAccountIds[0]};
      
      // Create billing groups  
      try 
      {
        CreateTemporaryBillingGroups(out intervalId,
          out materializationId,
          true,
          utilDelegate,
          2,
          parameters,
          false);

      }
      finally 
      {
        UpdateMaterializationFromProgressToFailed(materializationId);
      }

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Preconditions:
    ///     1) Create an entry in t_billgroup_constraint_tmp for one 
    ///        of the non-paying accounts
    ///        
    ///    PostConditions:
    ///     1) NonPayerAccountsInConstraintGroupsException is thrown
    /// </summary>
    [Test]
    [Category("TestNonPayerAccountInBillGroupConstraint")]
    [ExpectedException(typeof(NonPayerAccountsInConstraintGroupsException))]
    [Ignore]
    public void T45TestNonPayerAccountInBillGroupConstraint()
    {
      string method = "'TestNonPayerAccountInBillGroupConstraint'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      int intervalId = 0;
      int materializationId = 0;

      UtilDelegate utilDelegate = 
        new UtilDelegate(util.CreateDummyBillGroupConstraintTmpRow);

      object[] parameters = new object[] {(int)util.PayeeAccountIds[0],
                                          (int)util.PayeeAccountIds[0]};
      
      // Create billing groups  
      try 
      {
        
        CreateTemporaryBillingGroups(out intervalId,
          out materializationId,
          true,
          utilDelegate,
          1,
          parameters,
          false);
      }
      finally 
      {
        UpdateMaterializationFromProgressToFailed(materializationId);
      }

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Preconditions:
    ///     1) Create an entry in t_billgroup_constraint_tmp for which
    ///        the id_group does not match the id_acc
    ///        
    ///    PostConditions:
    ///     1) IncorrectConstraintGroupIdException is thrown
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(IncorrectConstraintGroupIdException))]
    public void T46TestIncorrectGroupIdInBillGroupConstraint()
    {
      string method = "'TestIncorrectGroupIdInBillGroupConstraint'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);
     
      int intervalId = 0;
      int materializationId = 0;

      UtilDelegate utilDelegate = 
        new UtilDelegate(util.CreateDummyBillGroupConstraintTmpRow);

      object[] parameters = new object[] {(int)util.PayerAccountIds[0],
                                           (int)util.PayerAccountIds[1]};
      
      // Create billing groups  
      try 
      {
        CreateTemporaryBillingGroups(out intervalId,
          out materializationId,
          true,
          utilDelegate,
          1,
          parameters,
          false);
      }
      finally
      {
        UpdateMaterializationFromProgressToFailed(materializationId);
      }

      util.Log("Finished " + method);
    }
    #endregion

    #region Validation Tests
    /// <summary>
    ///    Preconditions:
    ///     1) Create a duplicate entry in t_billgroup_source_acc
    ///     
    ///    Postconditions:
    ///     1) DuplicateAccountsInBillgroupSourceAccException
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    // [Ignore("Ignoring TestDuplicateAccountsInBillGroupSourceAcc.")]
    [ExpectedException(typeof(DuplicateAccountsInBillgroupSourceAccException))]
    public void T47TestDuplicateAccountsInBillGroupSourceAcc()
    {
      string method = "'TestDuplicateAccountsInBillGroupSourceAcc'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      int intervalId = 0;
      int materializationId = 0;

      UtilDelegate utilDelegate = 
        new UtilDelegate(util.CreateDummyBillGroupSourceAccRow);

      object[] parameters = new object[] {(int)util.PayerAccountIds[0]};

      try 
      {
        CreateTemporaryBillingGroups(out intervalId,
          out materializationId,
          false,
          utilDelegate,
          1,
          parameters,
          true);
      }
      finally 
      {
        UpdateMaterializationFromProgressToFailed(materializationId);
      }

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Preconditions:
    ///     1) Create a duplicate entry in t_billgroup_member_tmp
    ///     
    ///    Postconditions:
    ///     1) DuplicateAccountsInBillgroupMemberTmpException
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(DuplicateAccountsInBillgroupMemberTmpException))]
    public void T48TestDuplicateAccountsInBillGroupMemberTmp()
    {
      string method = "'DuplicateAccountsInBillgroupMemberTmpException'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);


      int intervalId = 0;
      int materializationId = 0;

      UtilDelegate utilDelegate = 
        new UtilDelegate(util.CreateDummyBillGroupMemberTmpRow);

      object[] parameters = new object[] {"Dummy billgroup name for unit testing",
                                           (int)util.PayerAccountIds[0]};

      try 
      {
        CreateTemporaryBillingGroups(out intervalId,
          out materializationId,
          false,
          utilDelegate,
          1,
          parameters,
          true);
      }
      finally 
      {
        UpdateMaterializationFromProgressToFailed(materializationId);
      }

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Preconditions:
    ///     1) Remove an entry from t_billgroup_member_tmp
    ///     
    ///    Postconditions:
    ///     1) MissingAccountsFromBillgroupMemberTmpException
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(MissingAccountsFromBillgroupMemberTmpException))]
    public void T49TestMissingAccountsFromBillgroupMemberTmp()
    {
      string method = "'TestMissingAccountsFromBillgroupMemberTmp'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      int intervalId = 0;
      int materializationId = 0;

      UtilDelegate utilDelegate = 
        new UtilDelegate(util.DeleteBillGroupMemberTmpRow);

      object[] parameters = new object[] {(int)util.PayerAccountIds[0]};

      try 
      {
        CreateTemporaryBillingGroups(out intervalId,
          out materializationId,
          false,
          utilDelegate,
          1,
          parameters,
          true);
      }
      finally
      {
        UpdateMaterializationFromProgressToFailed(materializationId);
      }

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Preconditions:
    ///     1) Remove accounts for a billing group from t_billgroup_member_tmp
    ///     
    ///    Postconditions:
    ///     1) EmptyBillingGroupInTmpException
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(EmptyBillingGroupInTmpException))]
    public void T50TestEmptyBillingGroupInTmp()
    {
      string method = "'EmptyBillingGroupInTmpException'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);


      int intervalId = 0;
      int materializationId = 0;

      UtilDelegate utilDelegate = 
        new UtilDelegate(util.DeleteAccountsForBillGroup);

      string commaSeparatedAccountIds = 
        Util.GetCommaSeparatedIds(util.UkAccountIds);

      object[] parameters = new object[] {commaSeparatedAccountIds};

      try 
      {
        CreateTemporaryBillingGroups(out intervalId,
          out materializationId,
          false,
          utilDelegate,
          1,
          parameters,
          true);
      }
      finally 
      {
        UpdateMaterializationFromProgressToFailed(materializationId);
      }

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Preconditions:
    ///     1) Add a row in t_billgroup_member to with the same 
    ///        billing group name as an existing row.
    ///     
    ///    Postconditions:
    ///     1) DuplicateBillingGroupNamesInBillGroupTmpException
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(DuplicateBillingGroupNamesInBillGroupTmpException))]
    public void T51TestDuplicateBillingGroupNamesInBillGroupTmp()
    {
      string method = "'TestDuplicateBillingGroupNamesInBillGroupTmp'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      int intervalId = 0;
      int materializationId = 0;

      UtilDelegate utilDelegate = 
        new UtilDelegate(util.CreateDummyBillGroupTmpRow);

      object[] parameters = new object[] {Util.northAmericaBillingGroupName};

      try 
      {
        CreateTemporaryBillingGroups(out intervalId,
          out materializationId,
          false,
          utilDelegate,
          1,
          parameters,
          true);
      }
      finally 
      {
        UpdateMaterializationFromProgressToFailed(materializationId);
      }

      util.Log("Finished " + method);
    }
    
    #endregion

    #region Pull List Tests
    /// <summary>
    ///    Create a pull list with no accounts.
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(UnableToParseAccountsException))]
    public void T52TestCreatePullListWithNoAccounts() 
    {
      string method = "'TestCreatePullListWithNoAccounts'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      try 
      {
        // Create billing groups for a non-materialized interval 
        int intervalId;
        ArrayList billingGroups = 
          CreateBillingGroupsWithAssignmentQuery(out intervalId);

        // Pick the first billing group as the parent
        IBillingGroup parentBillingGroup = (IBillingGroup)billingGroups[0];

        string pullListAccounts = "    ";
        
        bool needsExtraAccounts;

        // Start creating a pull list
        util.BillingGroupManager.
          StartChildGroupCreationFromAccounts(Util.testPullListName,
                                              Util.testPullListDescr,
                                              parentBillingGroup.BillingGroupID,
                                              pullListAccounts,
                                              out needsExtraAccounts,
                                              util.UserId);
      }
      finally 
      {
        util.Log("Finished " + method);
      }

    }

    /// <summary>
    ///    Create a pull list with all parent accounts.
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(CreatingPullListWithAllParentMembersException))]
    public void T53TestCreatePullListFromAllParentAccounts() 
    {
      string method = "'TestCreatePullListFromAllParentAccounts'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      try 
      {
        // Create billing groups for a non-materialized interval 
        int intervalId;
        ArrayList billingGroups = 
          CreateBillingGroupsWithAssignmentQuery(out intervalId);

        // Pick the first billing group as the parent
        IBillingGroup parentBillingGroup = (IBillingGroup)billingGroups[0];

        // Get the parent account id's
        ArrayList parentMembers = 
          util.BillingGroupManager.GetBillingGroupMembers(parentBillingGroup.BillingGroupID);

        CreatePullList(parentBillingGroup, Util.testPullListName, parentMembers, false);
      }
      finally 
      {
        util.Log("Finished " + method);
      }
    }

    /// <summary>
    ///    Create a pull list with non parent accounts.
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(CreatingPullListWithNonParentMembersException))]
    public void T54TestCreatePullListFromNonParentAccounts() 
    {
      string method = "'TestCreatePullListFromNonParentAccounts'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      try 
      {
        // Create billing groups for a non-materialized interval 
        int intervalId;
        ArrayList billingGroups = 
          CreateBillingGroupsWithAssignmentQuery(out intervalId);

        // Pick the first billing group as the parent
        IBillingGroup parentBillingGroup = (IBillingGroup)billingGroups[0];
        IBillingGroup nonParentBillingGroup = (IBillingGroup)billingGroups[1];

        // Get the non parent account id's
        ArrayList nonParentMembers = 
          util.BillingGroupManager.
          GetBillingGroupMembers(nonParentBillingGroup.BillingGroupID);

        CreatePullList(parentBillingGroup, Util.testPullListName, nonParentMembers, false);
      }
      finally 
      {
        util.Log("Finished " + method);
      }
    }

    /// <summary>
    ///    Create a pull list with duplicate accounts.
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(CreatingPullListWithDuplicateAccountsException))]
    public void T55TestCreatePullListFromDuplicateAccounts() 
    {
      string method = "'TestCreatePullListFromDuplicateAccounts'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      try 
      {
        // Create billing groups for a non-materialized interval 
        int intervalId;
        ArrayList billingGroups = 
          CreateBillingGroupsWithAssignmentQuery(out intervalId);

        // Pick the first billing group as the parent
        IBillingGroup parentBillingGroup = (IBillingGroup)billingGroups[0];

        // Get the parent account id's
        ArrayList pullListMembers = 
          util.BillingGroupManager.
          GetBillingGroupMembers(parentBillingGroup.BillingGroupID);
      
        // Create a duplicate
        pullListMembers.Add((int)pullListMembers[0]);

        CreatePullList(parentBillingGroup, Util.testPullListName, pullListMembers, false);
      }
      finally 
      {
        util.Log("Finished " + method);
      }
    }
    #endregion

    #region State Changes
    /// <summary>
    ///    1) Get an interval with payer accounts.
    ///    2) Hard close the interval.
    ///    3) Check that UnableToHardCloseIntervalException is thrown.
    /// </summary>
    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(UnableToHardCloseIntervalException))]
    public void T56TestHardCloseIntervalWithNonHardClosedPayerAccounts()
    {
      string method = "'TestHardCloseIntervalWithNonHardClosedPayerAccounts'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      try 
      {
        // Get an interval for materialization
        int intervalId = util.GetIntervalForFullMaterialization();
 
        // Create billing groups  
        util.BillingGroupManager.HardCloseInterval(intervalId, false);
      }
      finally 
      {
        util.Log("Finished " + method);
      }
    }
    #endregion

    #endregion

    #region Calendar Tests
    /// <summary>
    ///    1) Import 'Calendar_CL_PO' product offering if necessary:
    ///       pcimportexport -ipo -file "T:\QA\FunctionalTests\Usage\USAGE_CALENDAR\xml\CALENDAR_CodeLookUp_PO.xml" -username "su" -password "su123"
    ///    
    ///    2) 'Calendar_CL_PO' has the following calendar codes (peak, off-peak ...):
    ///          12:00 AM - 03:14:59 AM = Off-peak
    ///          03:15 AM - 05:44:59 AM = Holiday
    ///          05:45 AM - 07:59:59 AM = Off-peak
    ///          08:00 AM - 07:59:59 PM = Peak 
    ///          08:00 PM - 08:59:59 PM = Off-peak
    ///          09:00 PM - 11:29:59 PM = Weekend
    ///          11:30 PM - 11:59:59 PM = Off-peak
    ///          
    ///    3) Import T:\Development\Core\UsageServer\TimeZoneTest.xml
    ///       This contains the time periods. This must match the time periods
    ///       specified in Step(2). 
    ///       
    ///    4) Import T:\Development\Core\UsageServer\timezone.xml
    ///       This contains the mapping of Windows time zone names to
    ///       the MetraTech time zone id 
    ///       (specified in R:\config\timezone\Timezones.xml)
    ///       
    ///    5) Import R:\
    ///    5) For each time zone obtained in Step(4):
    ///         (a) Get a list of TimeZoneTestData objects - one for each
    ///             time point specified in Step(2).
    ///         (b) Each TimeZoneTestData object obtained in 5(a) contains
    ///             two items:
    ///               - the GMT time for its corresponding time point based on
    ///                 the Windows time zone. 
    ///               - the expected calendar code (Peak, Off-Peak ...)
    ///               
    ///    6) For each TimeZoneTestData object obtained in Step(5) do the following:
    ///       (a) Clear t_pv_testpi for the given interval.
    ///       (b) Create an account with the given MetraTech time zone id and 
    ///           and the given pricelist name ('Calendar_CL_PL').
    ///       (c) Meter one testpi session for the account with the given gmtTime
    ///           and the given intervalId.
    ///       (d) Check that there is one data row in t_pv_testpi for the given interval
    ///           - Check that it has the given enumDataTimeZoneId
    ///               (obtained by converting the 'tx_timezone_info' in
    ///                R:\config\PresServer\timezone.xml to id_enum_data 
    ///                in t_enum_data)
    ///           - Check that it has the given expectedCalendarCode
    ///      
    /// </summary>
    [Test]
    [Ignore("TestCalendarCodeLookup will be enabled as needed.")]
    [Category("TestCalendarCodeLookup")]
    public void T57TestCalendarCodeLookup() 
    {
      string method = "'TestCalendarCodeLookup'";
      Util util = Util.GetUtil();
      util.Log("Running " + method);

      string calendarName = "Calendar_CL_PO";
      string pricelistName = "Calendar_CL_PL";

      string fileName = 
        @"T:\QA\FunctionalTests\Usage\USAGE_CALENDAR\xml\CALENDAR_CodeLookUp_PO.xml";

      // If the calendar does not exist then run pcimportexport and import it.
      if (!Util.CheckProductOfferingExists(calendarName)) 
      {
        PCImportWrapper pcImportWrapper = new PCImportWrapper();
        pcImportWrapper.ImportProductOffering(fileName, "");
      }

      // Load calendar/timezone XML data into the dataset
      CalendarTimeZoneData calendarDataSet = new CalendarTimeZoneData();
      calendarDataSet.ReadXml(Util.testDir + Util.timeZoneDataFileName);

      // Load timezone data from T:\Development\Core\UsageServer\ModifiedTimezone.xml
      xmlconfig timeZoneDataSet = new xmlconfig();
      timeZoneDataSet.ReadXml(Util.testDir + Util.timeZoneMappingFileName);

      // Get the interval id
      int intervalId = util.GetIntervalForFullMaterialization();

      // Get the mapping of metratech time zone ids to their enum values.
      // Specified in R:\extensions\Core\config\enumtype\Global\Global.xml
      Hashtable metraTechTimeZoneIds = GetTimeZoneIds();

      // Get the items in T:\Development\Core\UsageServer\ModifiedTimezone.xml
      // that match metraTechTimeZoneIds
      Hashtable timeZoneRowsMap = new Hashtable();
      foreach(xmlconfig.timezoneRow tmpTimeZoneRow in timeZoneDataSet.timezone)
      {
        if (metraTechTimeZoneIds.ContainsKey(Convert.ToInt32(tmpTimeZoneRow.id_timezone)))
        {
          timeZoneRowsMap.Add(tmpTimeZoneRow.nm_timezone, tmpTimeZoneRow);
        }
      }

      // If there are any time zones specified in 
      // T:\Development\Core\UsageServer\TimeZoneTest.xml
      // then test only those, otherwise test all the timezones in metraTechTimeZoneIds
      ArrayList timeZoneRows = new ArrayList();
      xmlconfig.timezoneRow xmlConfigTzRow = null;

      if (calendarDataSet.TimeZone.Rows.Count > 0) 
      {
        foreach(CalendarTimeZoneData.TimeZoneRow timeZoneRow in calendarDataSet.TimeZone.Rows) 
        {
          xmlConfigTzRow = (xmlconfig.timezoneRow)timeZoneRowsMap[timeZoneRow.windowsName];
          Assert.IsNotNull(xmlConfigTzRow);
          xmlConfigTzRow.useWindowsTimeZone = timeZoneRow.useWindowsTimeZone;
          timeZoneRows.Add(xmlConfigTzRow);
        }
      }
      else 
      {
        timeZoneRows.AddRange(timeZoneRowsMap.Values);
      }

      // Sort the rows by metratech time zone id
      timeZoneRows.Sort(new TimeZoneRowSorter());

      string enumDataPrefix = @"Global/TimeZoneID/";
      IMTNameID nameId = new MTNameID();

      ArrayList failedTimeZones = new ArrayList();

      foreach(xmlconfig.timezoneRow timeZoneRow in timeZoneRows)
      {
        // Retrieve test data given the calendar info and windows time zone
        ArrayList timeZoneTestDataList = 
          GetTimeZoneTestData(calendarDataSet.CalendarCode, 
          timeZoneRow.nm_timezone,
          Convert.ToInt32(timeZoneRow.id_timezone),
          timeZoneRow.useWindowsTimeZone);

        // Retrieve the id_enum_data
        string enumTimeZoneName = 
          (string)metraTechTimeZoneIds[Convert.ToInt32(timeZoneRow.id_timezone)];
        int enumDataTimeZoneId = 
          nameId.GetNameID(enumDataPrefix + enumTimeZoneName);

        util.Log("========================================================");
        util.Log("Testing Time Zone: " + timeZoneRow.nm_timezone); 
        util.Log("[" + timeZoneRow.tx_timezone_info + "]");
        util.Log("MetraTech Id: " + timeZoneRow.id_timezone);
        util.Log("========================================================");

        foreach(TimeZoneTestData timeZoneTestData in timeZoneTestDataList) 
        {
          timeZoneTestData.metraTechTimeZoneId = Convert.ToInt32(timeZoneRow.id_timezone);
          timeZoneTestData.enumDataTimeZoneId = enumDataTimeZoneId;
          timeZoneTestData.enumTimeZoneName = enumTimeZoneName;
          timeZoneTestData.intervalId = intervalId;
          timeZoneTestData.priceListName = pricelistName;

          if (!TestCalendarCodeForTimeZone(timeZoneTestData))
          {
            util.LogError("Time Zone [" + timeZoneTestData.windowsTimeZoneName + "] Failed!"); 
            failedTimeZones.Add(timeZoneTestData);
            break;
          }
        }
      }

      if (failedTimeZones.Count > 0) 
      {
        util.LogError("********************************************************");
        util.LogError("The following time zones tests FAILED!"); 
        util.LogError("********************************************************");

        foreach(TimeZoneTestData timeZoneTestData in failedTimeZones) 
        {
          util.LogError("---------------------------------------------------------");
          util.LogError("Windows Time Zone       : " + timeZoneTestData.windowsTimeZoneName); 
          util.LogError("MetraTech Time Zone ID  : " + timeZoneTestData.metraTechTimeZoneId);
          util.LogError("MetraTech Enum          : " + timeZoneTestData.enumTimeZoneName);
          util.LogError("Original time           : " + 
            timeZoneTestData.originalTime.ToString("G", DateTimeFormatInfo.InvariantInfo));
          util.LogError("GMT Time                : " + 
            timeZoneTestData.gmtTime.ToString("G", DateTimeFormatInfo.InvariantInfo));
          util.LogError("Expected calendar code  : " + timeZoneTestData.calendarCode);

          util.LogError("---------------------------------------------------------");
        }
      }

      
      util.Log("Finished " + method);
    }
    #endregion

    #region Account Creation Tests
    /// <summary>
    /// See CR 13509
    ///   1) Create and soft close billing groups for a given interval.
    ///   2) Set the status of the interval to 'blocked'.
    ///   3) Create an account with the same cycle as the interval.
    ///   4) Make sure that there are no interval mappings for the account in t_acc_usage_interval
    ///      for the blocked interval.
    ///      
    /// </summary>
    [Test]
    [Category("TestCreateAccountForBlockedInterval")]
    public void T58TestCreateAccountForBlockedInterval() 
    {
      string method = "'TestCreateAccountForBlockedInterval'";

      // Creates billable and non-billable accounts
      Util util = Util.GetUtil();

      util.Log("Running " + method);
    
      // Create and soft close billing groups
      int intervalId = util.GetIntervalForFullMaterialization();

      // Block the interval.
      util.BillingGroupManager.SetIntervalAsBlockedForNewAccounts(intervalId);
      this.VerifyIntervalStatus(intervalId, UsageIntervalStatus.Blocked);

      // Create an account
      ArrayList accounts = CreateAccounts(1, true);

      // Check that no interval mapping exists for the account in t_acc_usage_interval
      int accountId = (int)accounts[0];
      bool mappingExists = util.CheckAccountIntervalMapping(accountId, intervalId);
      Assert.IsFalse(mappingExists, 
                     String.Format("Found interval mapping for account '{0}' and interval '{1}' " +
                                   "even though the interval is blocked", accountId, intervalId));

      util.Log("Finished " + method);
    }

    /// <summary>
    ///   See CR 13509
    ///   1) Hard Close an interval.
    ///   2) Create an account with the same cycle as the interval.
    ///   3) Make sure that the account is created in the 'Hard Closed' state.
    ///      
    /// </summary>
    [Test]
    [Category("TestCreateAccountForHardClosedInterval")]
    public void T59TestCreateAccountForHardClosedInterval() 
    {
      string method = "'TestCreateAccountForHardClosedInterval'";

      // Creates billable and non-billable accounts
      Util util = Util.GetUtil();

      util.Log("Running " + method);
    
      // Create and soft close billing groups
      int intervalId = HardCloseInterval();

      // Create an account
      ArrayList accounts = CreateAccounts(1, true);

      // Check that the account status is 'H'
      util.VerifyAccountStatus(accounts, intervalId, "H");

      util.Log("Finished " + method);
    }


    /// <summary>
    ///   See CR 12867
    ///   1) Create an account (A1).
    ///   2) Create an account template for this account (T).
    ///   3) Subscribe the template to the 'Simple Product Offering'
    ///   4) Create an account (A2) with its parent set to (A1). 
    ///      
    /// </summary>
    [Test]
    [Category("TestAccountSubscriptionErrorMessage")]
    [Ignore("TestAccountSubscriptionErrorMessage - half baked test.")]
    public void T60TestAccountSubscriptionErrorMessage()
    {
      string method = "'TestAccountSubscriptionErrorMessage'";

      // Creates billable and non-billable accounts
      Util util = Util.GetUtil();

      util.Log("Running " + method);

      ArrayList accountIds = CreateAccounts(1, true);
      Assert.AreEqual(1, accountIds.Count, "Expected one account");

      string originalAccountName = Util.GetAccountName((int)accountIds[0]);

      // If the "AudioConference Product Offering USD" found at
      // (T:\Development\Core\UsageServer\Audio-Adj-USD.xml) does not exist, then import it.
      string fileName = @"T:\Development\Core\UsageServer\Audio-Adj-USD.xml";

      // If the product offering does not exist then run pcimportexport and import it.
      string productOfferingName = "AudioConference Product Offering USD";
      if (!Util.CheckProductOfferingExists(productOfferingName)) 
      {
        PCImportWrapper pcImportWrapper = new PCImportWrapper();
        pcImportWrapper.ImportProductOffering(fileName, "");
      }

      // Create the sessionContext
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      YAAC.IMTSessionContext sessionContext = 
        (YAAC.IMTSessionContext)loginContext.Login("su", "system_user", "su123");


      // Create an account catalog
      YAAC.IMTAccountCatalog accCatalog = new YAAC.MTAccountCatalog();
      accCatalog.Init(sessionContext);

      // Create an account template 
      YAAC.MTYAAC departmentYaac = accCatalog.GetAccountByName(originalAccountName, "mt", null);
      IAccountTypeManager accountTypeManager = new AccountTypeManager();
      MTAccountType.IMTAccountType accountType = 
        accountTypeManager.GetAccountTypeByName
        ((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext, Util.accountType);
      Assert.IsNotNull(accountType);

      YAAC.MTAccountTemplate accTemplate = departmentYaac.GetAccountTemplate(DateTime.Now, accountType.ID);

      // Create the product catalog and retrieve the product offering
      IMTProductCatalog productCatalog = new MTProductCatalog();
      productCatalog.SetSessionContext
        ((MetraTech.Interop.MTProductCatalog.IMTSessionContext) sessionContext);
      IMTProductOffering productOffering = 
        productCatalog.GetProductOfferingByName(productOfferingName);
      // Remove account type
      productOffering.RemoveSubscribableAccountType(accountType.ID);

      // Set template properties
      accTemplate.Name = "Test Template for CR 12867";
      YAAC.MTAccountTemplateSubscriptions subscriptions = accTemplate.Subscriptions;
      YAAC.MTAccountTemplateSubscription subscription = subscriptions.AddSubscription();
      subscription.ProductOfferingID = productOffering.ID;
      subscription.StartDate = DateTime.Now;
      subscription.EndDate = DateTime.Now.AddDays(200);
      accTemplate.Save(null);

      // Create an account with the parent as the first account
      util.CreateAccount(util.GetUserName(), true, originalAccountName, true);

      util.Log("Finished " + method);
    }

    #endregion

    #region Must Run Last
    /// <summary>
    ///    Hard close an interval with no payer accounts.
    ///    Check that the interval is hard closed.
    /// </summary>
    [Test]
    [Category("TestHardClosingInterval")]
    public void T61TestHardClosingInterval() 
    {
      string method = "'TestHardClosingInterval'";

      Util util = Util.GetUtil();

      util.Log("Running " + method);

      HardCloseInterval();

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Hard close an interval overriding the creation of billing groups.
    ///    Check that the interval is hard closed.
    /// </summary>
    [Test]
    [Category("TestHardClosingIntervalWithoutBillingGroups")]
    [Ignore]
    public void T62TestHardClosingIntervalWithoutBillingGroups()
    {
      string method = "'TestHardClosingIntervalWithoutBillingGroups'";

      Util util = Util.GetUtil();

      util.Log("Running " + method);

      int intervalId = util.GetIntervalForFullMaterialization();

      util.BillingGroupManager.HardCloseInterval(intervalId, true);
    
      VerifyIntervalStatus(intervalId, UsageIntervalStatus.HardClosed);

      util.Log("Finished " + method);
    }

    /// <summary>
    ///    Hard close an interval overriding the creation of billing groups.
    ///    Check that the interval is hard closed.
    /// </summary>
    [Test]
    [Category("TestHardClosingIntervalWithBillingGroups")]
    [Ignore]
    public void T63TestHardClosingIntervalWithBillingGroups()
    {
      string method = "'TestHardClosingIntervalWithBillingGroups'";

      Util util = Util.GetUtil();

      util.Log("Running " + method);

      int intervalId = util.GetIntervalForFullMaterialization();
      util.BillingGroupManager.MaterializeBillingGroups(intervalId, util.UserId);

      SoftCloseInterval(intervalId);

      util.BillingGroupManager.HardCloseInterval(intervalId, true);

      VerifyIntervalStatus(intervalId, UsageIntervalStatus.HardClosed);

      util.Log("Finished " + method);
    }

    #endregion

    #region Private Methods
    /// <summary>
    ///    The given ArrayList contains IBillingGroup objects.
    ///    
    ///    Check that the following billing groups are present:
    ///      - North America (3 accounts)
    ///      - South America (3 accounts)
    ///      - Europe        (3 accounts)
    /// </summary>
    /// <param name="billingGroups"></param>
    private void CheckBillingGroups(Hashtable billingGroups)
    {
      IBillingGroup billingGroup = null;
      Util util = Util.GetUtil();

      billingGroup = (IBillingGroup)billingGroups[Util.northAmericaBillingGroupName];
      CheckBillingGroup(billingGroup, Util.northAmericaBillingGroupName, util.UsAccountIds);

      billingGroup = (IBillingGroup)billingGroups[Util.southAmericaBillingGroupName];
      CheckBillingGroup(billingGroup, Util.southAmericaBillingGroupName, util.BrazilAccountIds);

      billingGroup = (IBillingGroup)billingGroups[Util.europeBillingGroupName];
      CheckBillingGroup(billingGroup, Util.europeBillingGroupName, util.UkAccountIds);
    }

    /// <summary>
    ///    Check the following:
    ///      1) The given billing group has the given expectedName
    ///      2) The given billing group has the same accounts as expected accounts
    /// </summary>
    /// <param name="billingGroup"></param>
    /// <param name="expectedName"></param>
    /// <param name="expectedAccounts">account id's</param>
    private void CheckBillingGroup(IBillingGroup billingGroup,
                                   string expectedName,
                                   ArrayList expectedAccounts)
    {
      Assert.AreNotEqual(null, billingGroup, "Null billing group!");
      Assert.AreEqual(expectedName, billingGroup.Name, "Billing group name mismatch!");
      CheckBillingGroupAccounts(billingGroup, expectedAccounts);
    }

    /// <summary>
    ///    Forward to CheckBillingGroup with IBillingGroup
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <param name="expectedName"></param>
    /// <param name="expectedAccounts"></param>
    private void CheckBillingGroup(int billingGroupId,
                                   string expectedName,
                                   ArrayList expectedAccounts)
    {
      IBillingGroup billingGroup = 
        Util.GetUtil().BillingGroupManager.GetBillingGroup(billingGroupId);
      CheckBillingGroup(billingGroup, expectedName, expectedAccounts);
    }
    /// <summary>
    ///    Check that the accounts in the given billing group match
    ///    the given account user names.
    /// </summary>
    /// <param name="billingGroup"></param>
    /// <param name="accountIds"></param>
    private void CheckBillingGroupAccounts(IBillingGroup billingGroup, 
                                           string[] accountUserNames)
    {
      ArrayList accountIds = new ArrayList();
      foreach(string accountName in accountUserNames) 
      {
        accountIds.Add(Util.GetUtil().GetAccountId(accountName));
      }

      CheckBillingGroupAccounts(billingGroup, accountIds);
    }

    /// <summary>
    ///    If isPresent is true, return an error if any of the account id's in accountIds
    ///    are not members of the given billingGroupId.
    ///    
    ///    If isPresent is false, return an error if any of the account id's in accountIds
    ///    are members of the given billingGroupId.
    ///    
    /// </summary>
    /// <param name="billingGroup"></param>
    /// <param name="accountIds"></param>
    private void CheckBillingGroupAccountMembership(int billingGroupId,
                                                    ArrayList accountIds,
                                                    bool isPresent)
    {
      ArrayList members = 
        Util.GetUtil().BillingGroupManager.GetBillingGroupMembers(billingGroupId);

      if (isPresent) 
      {
        foreach(int accountId in accountIds) 
        {
          // Error if we don't find the accountId
          Assert.IsTrue(accountIds.Contains(accountId), 
                        String.Format("Expect to find account [{0}] in billing group [{1}]", 
                                      accountId, billingGroupId));
        }
      }
      else
      {
        foreach(int accountId in accountIds) 
        {
          // Error if we find the accountId
          Assert.IsTrue(!accountIds.Contains(accountId), 
                        String.Format("Did not expect to find account [{0}] in billing group [{1}]", 
                                      accountId, billingGroupId));
        }
      }
    }

    /// <summary>
    ///    Check that the accounts in the given billing group match
    ///    the accounts in the given ArrayList of account ids.
    /// </summary>
    /// <param name="billingGroup"></param>
    /// <param name="accountIds"></param>
    private void CheckBillingGroupAccounts(IBillingGroup billingGroup, 
                                           ArrayList accountIds)
    {
      // Get the billing group accounts
      Rowset.IMTSQLRowset rowset =
        Util.GetUtil().BillingGroupManager.
          GetBillingGroupMembersRowset(billingGroup.BillingGroupID, null);

      Assert.AreEqual(accountIds.Count, rowset.RecordCount,
                      "Mismatch in billing group accounts!");

      int accountId = 0;
      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        accountId = (int)rowset.get_Value("AccountID");

        Assert.IsTrue
          (accountIds.Contains(accountId), 
           String.Format("Unexpected account [{0}] in billing group [{1}]", 
                         accountId, billingGroup.Name));

        rowset.MoveNext();
      }
    }

    /// <summary>
    ///    Return true if the materialization for the given materializationId
    ///    has status specified by materializationStatus in t_billgroup_materialization
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="materializationStatus"></param>
    /// <returns></returns>
    private bool CheckMaterializationStatus(int materializationId,
                                            MaterializationStatus materializationStatus)
    {
      bool match = false;

      BillingGroupManager billingGroupManager = new BillingGroupManager();
      IMaterialization materialization = 
        billingGroupManager.GetMaterialization(materializationId);

      if (materialization.MaterializationStatus == materializationStatus) 
      {
        match = true;
      }
      
      return match;
    }

    /// <summary>
    ///    Create a materialization with the given type 
    ///    and return the materialization id.
    /// </summary>
    /// <returns></returns>
    private int CreateMaterialization(MaterializationType materializationType,
                                      out int intervalId)
    {
      // Get an interval for materialization
      intervalId = Util.GetUtil().GetIntervalForFullMaterialization();

      // Create a materialization
      int materializationId = 
        Util.GetUtil().BillingGroupManager.
           CreateMaterialization(intervalId,
                                 Util.GetUtil().UserId,
                                 MetraTime.Now,
                                 null,
                                 materializationType.ToString());

      return materializationId;
    }

    /// <summary>
    ///   Check that the given materialization id is 'InProgress'.
    ///   Update its status to 'Failed'
    /// </summary>
    /// <param name="materializationId"></param>
    private void UpdateMaterializationFromProgressToFailed(int materializationId)
    {
      // Check that the materialization has a status of InProgress
      Assert.IsTrue(CheckMaterializationStatus(materializationId, 
                                               MaterializationStatus.InProgress),
                                               "Expected 'InProgress' materialization!");

      // Clean up the materialization
      Util.GetUtil().BillingGroupManager.
        CleanupMaterialization(materializationId,
                               MetraTime.Now,
                               MaterializationStatus.Failed,
                               "Cleaning up unit test failure");

      // Check that the materialization has a status of Failed
      Assert.IsTrue(CheckMaterializationStatus(materializationId, 
                                               MaterializationStatus.Failed),
                                               "Expected 'Failed' materialization!");
    }
    
    /// <summary>
    ///    Create temporary billing groups and return the interval id and
    ///    materialization id generated.
    ///    If a UtilDelegate is provided, then invoke it 'numOfTimesToInvokeDelegate'
    ///    times either before or after creating billing groups based on
    ///    'callDelegateBeforeCreatingBillingGroups'.
    ///    
    ///    The delegate parameters are provided in 'parameters'.
    ///    
    ///    Each delegate method expected the first two parameters to
    ///    be the interval id and the materialization id respectively.
    ///    
    ///    Perform validation if 'doValidation' is true.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="materializationId"></param>
    private void CreateTemporaryBillingGroups(out int intervalId,
                                              out int materializationId,
                                              bool callDelegateBeforeCreatingBillingGroups,
                                              UtilDelegate utilDelegate,
                                              int numOfTimesToInvokeDelegate,
                                              object[] parameters,
                                              bool doValidation)
    {
      BillingGroupManager billingGroupManager = 
        Util.GetUtil().BillingGroupManager;

      // Create a materialization id
      materializationId = 
        CreateMaterialization(MaterializationType.Full, out intervalId);

      object[] delegateParameters = new object[parameters.Length + 2];
      delegateParameters[0] = intervalId;
      delegateParameters[1] = materializationId;

      for (int i = 0; i < parameters.Length; i++) 
      {
        delegateParameters[i+2] = parameters[i];
      }

      bool delegateCalled = false;
      if (callDelegateBeforeCreatingBillingGroups && utilDelegate != null) 
      {
        for (int i = 0; i < numOfTimesToInvokeDelegate; i++) 
        {
          utilDelegate(delegateParameters);
        }
        delegateCalled = true;
      }

      // Create billing groups  
      billingGroupManager.
        CreateTemporaryBillingGroups(intervalId,
                                     materializationId,
                                     false,
                                     null, null, null, null);

      if (delegateCalled == false && utilDelegate != null) 
      {
        for (int i = 0; i < numOfTimesToInvokeDelegate; i++) 
        {
          utilDelegate(delegateParameters);
        }
      }

      if (doValidation)
      {
        billingGroupManager.ValidateBillingGroupAssignments(intervalId, materializationId);
      }
    }

    /// <summary>
    ///    Return a hashtable with the following mapping:
    ///      IBillingGroup <--> ArrayList of member account id's
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    private Hashtable GetBillingGroupAndMemberAccounts(int intervalId)
    {
      Hashtable billingGroupsAndMembers = new Hashtable();

      IBillingGroupFilter billingGroupFilter = new BillingGroupFilter();
      billingGroupFilter.IntervalId = intervalId;

      ArrayList billingGroups = 
        Util.GetUtil().BillingGroupManager.GetBillingGroups(billingGroupFilter);

      foreach(IBillingGroup billingGroup in billingGroups) 
      {
        billingGroupsAndMembers.Add(billingGroup,
                                    Util.GetUtil().BillingGroupManager.
                                      GetBillingGroupMembers(billingGroup.BillingGroupID));
                                    
      }

      return billingGroupsAndMembers;
    }

    /// <summary>
    ///   Return IBillingGroup's for the given interval
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    private ArrayList GetBillingGroups(int intervalId) 
    {
      IBillingGroupFilter filter = new BillingGroupFilter();
      filter.IntervalId = intervalId;

      return Util.GetUtil().BillingGroupManager.GetBillingGroups(filter);
    }

    /// <summary>
    ///   Return the billing group with the given billingGroupId
    ///   
    ///   Return null if it is not found.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="billingGroupId"></param>
    /// <returns></returns>
    private IBillingGroup GetBillingGroup(int billingGroupId)
    {
      IBillingGroup billingGroup = null;

      IBillingGroupFilter filter = new BillingGroupFilter();
      filter.BillingGroupId = billingGroupId;

      ArrayList billingGroups = 
        Util.GetUtil().BillingGroupManager.GetBillingGroups(filter);

      if (billingGroups.Count == 1) 
      {
        billingGroup = (IBillingGroup)billingGroups[0];
      }

      return billingGroup;
    }

    /// <summary>
    ///   Return the billing group with the given billingGroupName and
    ///   the given interval id
    ///   
    ///   Return null if it is not found.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="billingGroupId"></param>
    /// <returns></returns>
    private IBillingGroup GetBillingGroup(string billingGroupName, int intervalId)
    {
      IBillingGroupFilter filter = new BillingGroupFilter();
      filter.IntervalId = intervalId;
      filter.BillingGroupName = billingGroupName;

      ArrayList billingGroups = 
        Util.GetUtil().BillingGroupManager.GetBillingGroups(filter);

      Assert.AreEqual(1, billingGroups.Count);

      return (IBillingGroup)billingGroups[0];
    }


    private int GetPullListIntervalId()
    {
      return 
        ((IBillingGroup)billingGroupsForIntervalBeforePullListCreation[0]).IntervalID;
    }

    private int GetUserDefinedGroupIntervalId()
    {
      return 
        ((IBillingGroup)billingGroupsForIntervalBeforeUserDefinedGroupCreation[0]).IntervalID;
    }

    /// <summary>
    ///    Return true if the given billingGroupId exists
    ///    in billingGroups.
    /// </summary>
    /// <param name="billingGroupName"></param>
    /// <param name="billingGroups"></param>
    /// <returns></returns>
    private bool CheckBillingGroupExists(int billingGroupId,
                                         ArrayList billingGroups)
    {
      bool exists = false;

      foreach(IBillingGroup billingGroup in billingGroups) 
      {
        if (billingGroup.BillingGroupID == billingGroupId) 
        {
          exists = true;
          break;
        }
      }
      return exists;
    }

    /// <summary>
    ///    Return true if the given billingGroupName exists
    ///    in billingGroups.
    /// </summary>
    /// <param name="billingGroupName"></param>
    /// <param name="billingGroups"></param>
    /// <returns></returns>
    private bool CheckBillingGroupExists(string billingGroupName,
                                         ArrayList billingGroups)
    {
      bool exists = false;

      foreach(IBillingGroup billingGroup in billingGroups) 
      {
        if (billingGroup.Name.Equals(billingGroupName)) 
        {
          exists = true;
          break;
        }
      }
      return exists;
    }

    /// <summary>
    ///    Create billing groups with the out-of-the-box assignment query
    ///    and soft close each of them
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    private ArrayList CreateAndSoftCloseBillingGroups(out int intervalId,
                                                      bool hardClosePreviousIntervals)
    {
      // Creates billable and non-billable accounts
      Util util = Util.GetUtil();
      // Get an interval for materialization
      intervalId = util.GetIntervalForFullMaterialization();

      return CreateAndSoftCloseBillingGroups(intervalId, hardClosePreviousIntervals);
    }

    /// <summary>
    ///    Create billing groups with the out-of-the-box assignment query
    ///    and soft close each of them for the given interval id.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="hardClosePreviousIntervals"></param>
    /// <returns></returns>
    private ArrayList CreateAndSoftCloseBillingGroups(int intervalId,
                                                      bool hardClosePreviousIntervals)
    {
      CreateBillingGroupsWithAssignmentQuery(intervalId);
      SoftCloseInterval(intervalId);

      ArrayList billingGroups = GetBillingGroups(intervalId);
      Assert.AreNotEqual(0, billingGroups.Count, "Incorrect billing groups count");

      if (hardClosePreviousIntervals) 
      {
        // Make sure that all previous intervals are hard closed
        Util.GetUtil().UpdatePreviousIntervalsToHardClosed(intervalId);
      }

      // Check that the interval is open
      VerifyIntervalStatus(intervalId, UsageIntervalStatus.Open);

      return billingGroups;
    }

    /// <summary>
    ///   Create billing groups with the out-of-the-box assignment query.
    /// </summary>
    /// <returns>Return a list of IBillingGroup's</returns>
    private ArrayList CreateBillingGroupsWithAssignmentQuery(out int intervalId)
    {
      // Creates billable and non-billable accounts
      Util util = Util.GetUtil();
      // Get an interval for materialization
      intervalId = util.GetIntervalForFullMaterialization();
     
      return CreateBillingGroupsWithAssignmentQuery(intervalId);
    }

    /// <summary>
    ///   Create billing groups with the out-of-the-box assignment query for
    ///   the given interval id. Validates the given interval id has not
    ///   been materialized.
    /// </summary>
    /// <returns>Return a list of IBillingGroup's</returns>
    private ArrayList CreateBillingGroupsWithAssignmentQuery(int intervalId)
    {
      Util util = Util.GetUtil();
      // Get the usage interval
      IUsageInterval usageInterval = 
        util.UsageIntervalManager.GetUsageInterval(intervalId);
      // Check that usage interval has not been materialized
      Assert.AreEqual(false, usageInterval.HasBeenMaterialized, 
                      "Expected non-materialized interval");

      // Create billing groups using the default assignment query 
      util.BillingGroupManager.MaterializeBillingGroups(intervalId, util.UserId, false);

      // Get the billing groups
      ArrayList billingGroups = GetBillingGroups(intervalId);

      // Expect 3 rows
      Assert.AreEqual(Util.numBillingGroups, billingGroups.Count, 
        "Number of billing groups mismatch");

      // Map billing group name <--> IBillingGroup
      Hashtable billingGroupsTable = new Hashtable();

      foreach(IBillingGroup billingGroup in billingGroups) 
      {
        billingGroupsTable.Add(billingGroup.Name, billingGroup);
      }

      CheckBillingGroups(billingGroupsTable);

      // Check that there are no unassigned accounts for the interval
      AssertNoUnassignedAccounts(intervalId);

      return billingGroups;
    }

    /// <summary>
    ///    Create accounts and return the usernames for the
    ///    accounts created
    /// </summary>
    /// <param name="numAccounts"></param>
    /// <returns></returns>
    private ArrayList CreateAccounts(int numAccounts, 
                                     bool isPayer) 
    {
      return CreateAccounts(numAccounts, isPayer, -1, null);                                  
    }

    /// <summary>
    ///    Create accounts and return the usernames for the
    ///    accounts created
    /// </summary>
    /// <param name="numAccounts"></param>
    /// <returns></returns>
    private ArrayList CreateAccounts(int numAccounts, 
                                     bool isPayer,
                                     int timeZoneId,
                                     string pricelist) 
    {
      ArrayList accountIds = new ArrayList();
      Util util = Util.GetUtil();

      for (int i = 0; i < numAccounts; i++)
      {
        accountIds.Add(util.CreateAccount(util.GetUserName(), isPayer, timeZoneId, pricelist));
      }

      // Make sure util knows that extra accounts have been added
      if (isPayer) 
      {
        util.AddToUsAccountIds(accountIds);
        util.AddToPayerAccountIds(accountIds);
      }
      else 
      {
        util.AddToPayeeAccountIds(accountIds);
      }
 
      Assert.AreEqual(numAccounts, accountIds.Count, 
                      "Mismatch in the number of new accounts created");

      return accountIds;
    }

    // Check that there are no unassigned accounts (open and hard closed)
    // for this interval
    private void AssertNoUnassignedAccounts(int intervalId)
    {
      IUsageInterval usageInterval = 
        Util.GetUtil().UsageIntervalManager.GetUsageInterval(intervalId);

      Assert.AreEqual(0, usageInterval.OpenUnassignedAccountsCount,
                      "Mismatch in number of open unassigned accounts!");

      Assert.AreEqual(0, usageInterval.HardClosedUnassignedAccountsCount,
                      "Mismatch in number of open unassigned accounts!");
    }

    /// <summary>
    ///   Check that the recurring events specified in recurringEventDataList
    ///   have the expected status for each billing group in billingGroups.
    /// </summary>
    /// <param name="billingGroups"></param>
    /// <param name="recurringEventDataList"></param>
    private void CheckAdapterInstances(ArrayList billingGroups,
                                       ArrayList recurringEventDataList)
    {
      foreach(IBillingGroup billingGroup in billingGroups) 
      {
        CheckAdapterInstances(billingGroup.IntervalID,
                              billingGroup.BillingGroupID,
                              recurringEventDataList);
      }
    }

    /// <summary>
    ///    For each recurring event specified in recurringEventDataList
    ///    check that the expected status matches the status in the database.
    /// </summary>
    /// <param name="intervalId">will be ignored if it's -1</param>
    /// <param name="billingGroupId">will be ignored if it's -1</param>
    /// <param name="recurringEventDataList">Array of RecurringEventData items</param>
    private void CheckAdapterInstances(int intervalId, 
                                       int billingGroupId, 
                                       ArrayList recurringEventDataList)
    {
      if (intervalId == -1 && billingGroupId == -1) 
      {
        Assert.Fail("Must provide either intervalId or billingGroupId");
      }

      // Get the recurring event instances, this will contain
      // interval only adapters as well.
      ArrayList recurringEventInstances = 
        GetRecurringEventInstances(intervalId, billingGroupId);

      Dictionary<int?, Dictionary<string, RecurringEventInstanceStatus>> adapters = new Dictionary<int?, Dictionary<string, RecurringEventInstanceStatus>>();

      foreach(RecurringEventInstance recurringEventInstance in recurringEventInstances)
      {
          if (!adapters.ContainsKey(recurringEventInstance.id_billgroup))
          {
              adapters.Add(recurringEventInstance.id_billgroup, new Dictionary<string, RecurringEventInstanceStatus>());
          }

        // Store eventName <--> RecurringEventInstanceStatus from the db
        adapters[recurringEventInstance.id_billgroup].Add(recurringEventInstance.eventName, 
                     recurringEventInstance.recurringEventInstanceStatus);
      }
    
      // Check that each of the recurring events in recurringEventDataList
      // are present in the database and that their statuses match
      foreach (RecurringEventData recurringEventData in recurringEventDataList)
      {
          bool bFound = false;

          foreach (KeyValuePair<int?, Dictionary<string, RecurringEventInstanceStatus>> kvp in adapters)
          {
              if (kvp.Value.ContainsKey(recurringEventData.recurringEvent.Name))
              {
                  bFound = true;

                  Assert.AreEqual
                    (recurringEventData.expectedStatus,
                    kvp.Value[recurringEventData.recurringEvent.Name],
                    String.Format("Mismatched adapter status for event {0} in the interval {1} for billgroup {2}",
                                  recurringEventData.recurringEvent.Name,
                                  intervalId,
                                  kvp.Key));
              }
          }

          Assert.AreEqual(
              bFound,
              true,
              string.Format("Adapter status not found for event {0} in the interval {1}",
                              recurringEventData.recurringEvent.Name
                              , intervalId));
      }
    }

    /// <summary>
    ///   Check that pull list has been created with the same set of adapters
    ///   as the original billing group.
    /// </summary>
    /// <param name="pullList"></param>
    /// <param name="parentBillingGroup"></param>
    private void CheckAdapterInstancesForPullList(IBillingGroup pullList,
                                                  IBillingGroup parentBillingGroup)
    {
      Util util = Util.GetUtil();

      // Get the instances for the pull list
      ArrayList pullListInstances = GetRecurringEventInstances(pullList);

      // Get the instances for the parent
      ArrayList parentInstances = GetRecurringEventInstances(parentBillingGroup);

      foreach(RecurringEventInstance recurringEventInstance in pullListInstances) 
      {
        Assert.AreEqual(true, parentInstances.Contains(recurringEventInstance),
                        "Missing adapter instance from pull list");
      }
    }

    /// <summary>
    ///   Check that there are adapter instances for the given billingGroup
    ///   with the following properties:
    ///     1) There is a row for each adapter for which tx_type != 'Scheduled'
    ///     2) If the allRunSuccessfully flag is true then all adapters must
    ///        have a status of 'Succeeded'
    ///        
    ///     3) If the allRunSuccessfully flag is false then the following must
    ///        be true:
    ///        - _StartRoot adapter instance has a tx_status of 'Succeeded'
    ///        - _EndRoot adapter instance has a tx_status of 'ReadyToRun'
    ///        - All other adapter instances have a tx_status of 'NotYetRun' 
    /// </summary>
    /// <param name="billingGroupId"></param>
    private void CheckAdapterInstances(IBillingGroup aBillingGroup,
                                       bool allRunSuccessfully)
    {
      // refresh the billing group
      IBillingGroup billingGroup = GetBillingGroup(aBillingGroup.BillingGroupID);

      Util util = Util.GetUtil();

      // Get the instances for this billing group
      ArrayList recurringEventInstances = GetRecurringEventInstances(billingGroup);

      // Check that the roots exist
      // CheckRoots(recurringEventInstances, allRunSuccessfully);

      int totalAdapterCount = 0;
      int succeededAdapterCount = 0;
      int failedAdapterCount = 0;
      int notYetRunAdapterCount = 0;
      ArrayList failedAdapterInstances = new ArrayList();

      foreach(RecurringEventInstance recurringEventInstance in recurringEventInstances)
      {
        // skip the roots and checkpoints
        if (String.Compare(recurringEventInstance.eventType, Util.root, true) == 0 ||
            String.Compare(recurringEventInstance.eventType, Util.checkpoint, true) == 0)
        {
          // next row
          continue;
        }

        // skip billing group adapters for pull lists because they are retrieved
        // for display purposes and don't really belong to the pull list.
        if (billingGroup.MaterializationType == 
              MaterializationType.PullList &&
            recurringEventInstance.billingGroupSupportType == 
              BillingGroupSupportType.BillingGroup)
        {
          continue;
        }


        totalAdapterCount++;
        if (recurringEventInstance.recurringEventInstanceStatus == 
            RecurringEventInstanceStatus.Succeeded) 
        {
          succeededAdapterCount++;
        }
        
        if (recurringEventInstance.recurringEventInstanceStatus == 
            RecurringEventInstanceStatus.Failed)  
        {
          failedAdapterCount++;
          failedAdapterInstances.Add(recurringEventInstance);
        }
        if (recurringEventInstance.recurringEventInstanceStatus == 
            RecurringEventInstanceStatus.NotYetRun)  
        {
          notYetRunAdapterCount++;
        }
      }

      if (allRunSuccessfully) 
      {
        if (failedAdapterInstances.Count > 0) 
        {
          StringBuilder errorMessage = new StringBuilder();
          foreach(RecurringEventInstance recurringEventInstance in failedAdapterInstances) 
          {
            errorMessage.Append
              (String.Format("Adapter Instance '{0}:{1}' failed!\n", 
                              recurringEventInstance.id_instance,
                              recurringEventInstance.eventName));
          }
          Assert.Fail(errorMessage.ToString());
        }
        else
        {
          Assert.AreEqual(totalAdapterCount, succeededAdapterCount, 
                          "Mismatch in successful adapter counts");
        }
      }
      else 
      {
        Assert.AreEqual(totalAdapterCount, notYetRunAdapterCount, 
                        "Mismatch in not yet run adapter counts");
      }

      Assert.AreEqual(billingGroup.AdapterCount + billingGroup.IntervalOnlyAdapterCount, 
                      totalAdapterCount,
                      "Mismatch in total adapter count!");
      Assert.AreEqual(billingGroup.SucceededAdapterCount, succeededAdapterCount,
                      "Mismatch in succeeded adapter count!");
      Assert.AreEqual(billingGroup.FailedAdapterCount, failedAdapterCount,
                      "Mismatch in failed adapter count!");

      // Can't have 0 adapters
      Assert.AreNotEqual(0, totalAdapterCount, "No adapters found!");
    }

    /// <summary>
    ///    Check that the expectedStatus equals the status of the adapter
    ///    specified by eventName.
    /// </summary>
    /// <param name="eventName"></param>
    /// <param name="billingGroupId"></param>
    /// <param name="intervalId"></param>
    /// <param name="expectedStatus"></param>
    private void CheckAdapterStatus(string eventName,
                                    int billingGroupId,
                                    int intervalId,
                                    RecurringEventInstanceStatus expectedStatus)
    {
      IRecurringEventInstanceFilter recurringEventInstanceFilter = 
        new RecurringEventInstanceFilter();

      if (intervalId == -1 && billingGroupId == -1) 
      {
        Assert.Fail("Must provide either billingGroupId or intervalId");
      }

      if (intervalId != -1)
      {
        recurringEventInstanceFilter.UsageIntervalID = intervalId;
      }
      if (billingGroupId != -1)
      {
        recurringEventInstanceFilter.BillingGroupID = billingGroupId;
      }
     
      recurringEventInstanceFilter.EventName = eventName;

      Rowset.IMTSQLRowset rowset = 
        recurringEventInstanceFilter.GetEndOfPeriodRowset(true, true, true);

      // Expect one instance row
      Assert.AreEqual(1, rowset.RecordCount, "Mismatch in adapter instance count!");

      Assert.AreEqual
        (expectedStatus,
        (RecurringEventInstanceStatus)Enum.
           Parse(typeof(RecurringEventInstanceStatus), 
                (string)rowset.get_Value("Status")),

         String.Format("Mismatched adapter status for '{0}'", eventName));

    }

    /// <summary>
    ///    Soft closes all the billing groups in the given interval.
    /// </summary>
    /// <param name="intervalId"></param>
    private void SoftCloseInterval(int intervalId) 
    {
      ArrayList billingGroups = GetBillingGroups(intervalId);
      Assert.AreNotEqual(0, billingGroups.Count, "Expected billing groups");

      foreach(IBillingGroup billingGroup in billingGroups) 
      {
        SoftCloseBillingGroup(billingGroup.BillingGroupID);
      }
    }

    /// <summary>
    ///   Soft close the given billing group.
    ///   Check adapter instances.
    /// </summary>
    /// <param name="billingGroupId"></param>
    private void SoftCloseBillingGroup(int billingGroupId)
    {
      // Soft close it
      Util.GetUtil().BillingGroupManager.
        SoftCloseBillingGroup(billingGroupId);

      // Refresh billing group
      IBillingGroup billingGroup = 
        GetBillingGroup(billingGroupId);

      Assert.AreEqual(BillingGroupStatus.SoftClosed,
                      billingGroup.Status,
                     "'SoftCloseBillingGroup' - Mismatch in billing group status");

      // Check adapter instances
      CheckAdapterInstances(billingGroup, false);
    }

    /// <summary>
    ///  
    /// </summary>
    /// <param name="accountIds"></param>
    /// <param name="intervalId"></param>
    /// <param name="expectUsageInInterval"></param>
    public void MeterUsage(ArrayList accountIds, 
                           int intervalId,
                           bool expectUsageInInterval)
    {
      MeterUsage(accountIds, 
                 intervalId, 
                 expectUsageInInterval, 
                 DateTime.MinValue, 
                 null,
                 Util.numberOfSessions);
    }

    /// <summary>
    /// </summary>
    /// <param name="accountNames"></param>
    /// <param name="intervalId"></param>
    private void MeterUsage(ArrayList accountIds, 
                            int intervalId,
                            bool expectUsageInInterval,
                            DateTime dateTimeProperty,
                            string serviceDef,
                            int numberOfSessions)
    {
      // Meter usage to the accounts with the time associated
      // with the current interval.
      MeterUsage(accountIds, intervalId, -1, false, 
                 dateTimeProperty, serviceDef, numberOfSessions);

      // Verify that the usage did or did not land in the current interval
      VerifyUsage(accountIds, intervalId, expectUsageInInterval);
    }

    /// <summary>
    ///    
    /// </summary>
    /// <param name="accountIds"></param>
    /// <param name="intervalId"></param>
    /// <param name="intervalIdSpecialProperty"></param>
    /// <param name="checkFailedTransactions"></param>
    /// <param name="dateTimeProperty"></param>
    /// <returns></returns>
    private ArrayList MeterUsage(ArrayList accountIds, 
                                 int intervalId,
                                 int intervalIdSpecialProperty,
                                 bool checkFailedTransactions)
    {
      return MeterUsage(accountIds, 
                        intervalId, 
                        intervalIdSpecialProperty, 
                        checkFailedTransactions,
                        DateTime.MinValue,
                        null,
                        Util.numberOfSessions);
    }
    /// <summary>
    ///   Meter usage (testservice) for each account in accountIds
    ///   and for the given intervalId. 
    ///   
    ///   The usage has a pipeline date (determines t_acc_usage.dt_session)
    ///   set to one day after the interval start date. 
    ///   This ensures that the usage will fall in the interval specified.
    ///   
    ///   If checkFailedTransactions is true
    ///    - we expect all the sessions metered to fail 
    ///    - verify that the sessions have failed
    /// </summary>
    /// <param name="accountIds"></param>
    /// <param name="intervalId"></param>
    /// <param name="intervalIdSpecialProperty">
    ///    Metered as _IntervalID property. 
    ///    Not used if it's -1.
    ///    
    /// </param>
    /// <param name="checkFailedTransactions"></param>
    private ArrayList MeterUsage(ArrayList accountIds, 
                                 int intervalId,
                                 int intervalIdSpecialProperty,
                                 bool checkFailedTransactions,
                                 DateTime dateTimeProperty,
                                 string serviceDef,
                                 int numberOfSessions)
    {
      // Util util = Util.GetUtil();

      // Delete existing usage
      Util.DeleteUsage(accountIds, intervalId);

      ArrayList batches = null;
      IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();

        // Set the time for metering the account so that
        // it falls into the given intervalId
        UsageIntervalManager usageIntervalManager = new UsageIntervalManager();
        IUsageInterval usageInterval = usageIntervalManager.GetUsageInterval(intervalId);

        DateTime pipelineDate = usageInterval.StartDate.AddDays(1);

        batches = new ArrayList();
        IBatch batch = null;
        BatchAccountData batchAccountData = null;
        string accountName = String.Empty;
        foreach (int accountId in accountIds)
        {
          accountName = Util.GetAccountName(accountId);
          try
          {
            if (serviceDef == null)
            {
              batch = TestLibrary.CreateAndSubmitSessions(sdk, numberOfSessions,
                                                          pipelineDate, accountName,
                                                          intervalIdSpecialProperty,
                                                          dateTimeProperty);
            }
            else if (String.Compare(serviceDef, "metratech.com\testpi", true) == 0)
            {
              batch =
                TestLibrary.CreateAndSubmitTestPISessions(sdk, numberOfSessions, accountName,
                                                          intervalIdSpecialProperty, dateTimeProperty);
            }
            batchAccountData = new BatchAccountData();
            batchAccountData.batchUid = batch.UID;
            batchAccountData.accountId = accountId;
            batches.Add(batchAccountData);
          }
          finally
          {
            if (batch != null)
              Marshal.ReleaseComObject(batch);
          }
        }

        if (checkFailedTransactions)
        {
          VerifyFailedTransactions(batches, accountIds);
        }
      }
      finally
      {
		if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
      return batches;
    }

    /// <summary>
    ///   Verify that each of the transactions identified by BatchAccountData 
    ///   in batches have failed.
    /// </summary>
    /// <param name="batches">list of BatchAccountData items</param>
    /// <param name="payerAccountIds"></param>
    private void VerifyFailedTransactions(ArrayList batches,
                                          ArrayList payerAccountIds)
    {
      // Util util = Util.GetUtil();
      string commaSeparatedIds = Util.GetCommaSeparatedIds(payerAccountIds);

      // batchUid <--> batchUid
      Hashtable failedBatches = new Hashtable();
      // batchUid <--> ArrayList of account id's
      Hashtable failedBatchAccounts = new Hashtable();

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          // retrieves data from t_failed_transaction for each of the payerAccountIds
          using (IMTPreparedStatement stmt =
            conn.CreatePreparedStatement(
            "SELECT id_PossiblePayerID, " +
            "       tx_Batch_Encoded " +
            "FROM t_failed_transaction " +
            "WHERE id_PossiblePayerID " +
            "IN ( " + commaSeparatedIds + " )"))
          {

              int payerId = 0;
              string batchUid = String.Empty;

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      payerId = reader.GetInt32(0);
                      batchUid = reader.GetString(1);

                      // Store the failed batch uid's
                      if (!failedBatches.ContainsKey(batchUid))
                      {
                          failedBatches.Add(batchUid, batchUid);
                      }

                      // Store the account id's for each failed batch uid
                      ArrayList accounts = (ArrayList)failedBatchAccounts[batchUid];
                      if (accounts == null)
                      {
                          accounts = new ArrayList();
                          accounts.Add(payerId);
                          failedBatchAccounts[batchUid] = accounts;
                      }
                      else
                      {
                          accounts.Add(payerId);
                      }
                  }
              }
          }
      }

      // Check that the number of batches match
      Assert.AreEqual(batches.Count, failedBatches.Count, "Mismatch in batch count!");

      // Check that the batch uid's match
      foreach(BatchAccountData batchAccountData in batches) 
      {
        string failedBatchUid = (string)failedBatches[batchAccountData.batchUid];
        Assert.AreEqual(batchAccountData.batchUid,
                        failedBatchUid,
                        "Mismatch in batch UID!");
      }

      // Check that each batch has the right number of accounts
      foreach(ArrayList batchAccounts in failedBatchAccounts.Values)
      {
        Assert.AreEqual(Util.numberOfSessions,
                        batchAccounts.Count,
                        "Mismatch in batch accounts!");
      }
    }

    /// <summary>
    ///   
    /// </summary>
    /// <param name="accountIds"></param>
    /// <param name="intervalId"></param>
    /// <param name="exists"></param>
    private void VerifyUsage(ArrayList accountIds, int intervalId, bool exists) 
    {
      VerifyUsage(accountIds, intervalId, exists, Util.numberOfSessions);
    }

    /// <summary>
    ///   Verify that there is usage associated with each of
    ///   the accounts in the given accountIds and the given intervalId.
    ///   
    ///   If 'exists' is false, then verify that there is no usage
    ///   for each of the account in the given accountIds and
    ///   the given intervalId.
    /// </summary>
    /// <param name="accountIds"></param>
    /// <param name="intervalId"></param>
    private void VerifyUsage(ArrayList accountIds, int intervalId, bool exists, int numberOfSessions)
    {
      foreach(int accountId in accountIds) 
      {
        Util.VerifyUsage(accountId, intervalId, exists, numberOfSessions);
      }
    }

    /// <summary>
    ///    Return an IMTCollection based on the id's passed in.
    /// </summary>
    /// <param name="accountIds"></param>
    /// <returns></returns>
    private Coll.IMTCollection GetCollection(ArrayList ids)
    {
      Coll.IMTCollection collection = new Coll.MTCollectionClass();
      foreach(int id in ids) 
      {
        collection.Add(Convert.ToString(id));
      }
      return collection;
    }

    /// <summary>
    ///   Verify that each of the billing groups in the given interval
    ///   have the given status.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="status"></param>
    private void VerifyBillingGroupStatus(int intervalId, BillingGroupStatus status)
    {
      ArrayList billingGroups = GetBillingGroups(intervalId);
      foreach(IBillingGroup billingGroup in billingGroups)
      {
        Assert.AreEqual(status, billingGroup.Status, 
                        "Mismatched billing group status");
      }
    }

    private void VerifyBillingGroupAccount(int billingGroupId, ArrayList accountIds) 
    {
    }

    /// <summary>
    ///    Verify that the interval has the given status.
    ///    If the status is 'H', verify that all the billing groups 
    ///    are hard closed and that all the unassigned accounts are
    ///    hard closed.
    /// </summary>
    /// <param name="status">one of 'O', 'H' or 'B'</param>
    private void VerifyIntervalStatus(int intervalId, UsageIntervalStatus status)
    {
      if (status != UsageIntervalStatus.Open &&
          status != UsageIntervalStatus.HardClosed &&
          status != UsageIntervalStatus.Blocked)
      {
        Assert.Fail(String.Format("Invalid interval status '{0}'", status));
      }

      IUsageInterval usageInterval = Util.GetUtil().UsageIntervalManager.GetUsageInterval(intervalId);

      Assert.IsNotNull(usageInterval, 
        String.Format("'VerifyIntervalStatus' - Unable to find IUsageInterval for interval '{0}'", intervalId));

      Assert.AreEqual(status, usageInterval.Status, "'VerifyIntervalStatus' - mismatched status!");

      // If the status is 'HardClosed', then ensure that all the billing groups
      // are hard closed and all unassigned accounts are hard closed.
      if (status == UsageIntervalStatus.HardClosed) 
      {
        ArrayList billingGroups = GetBillingGroups(intervalId);
        foreach(IBillingGroup billingGroup in billingGroups) 
        {
          Assert.AreEqual(BillingGroupStatus.HardClosed, billingGroup.Status,
                          "Mismatched billing group status");
        }

        CheckAllUnassignedAccountsStatus(intervalId, 
                                         UnassignedAccountStatus.HardClosed);
      }
    }

    /// <summary>
    ///    Submit, execute/reverse, and check adapter status based on the data
    ///    specified in recurringEventDataList.
    ///    
    ///    If billingGroupId is -1 it will not be used.
    ///    If intervalId is -1 it will not be used.
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <param name="intervalId"></param>
    /// <param name="recurringEventDataList"></param>
    private void ExecuteAdapters(int intervalId, 
                                 int billingGroupId,
                                 ArrayList recurringEventDataList,
                                 bool ignoreDependencies)
    {
      if (intervalId == -1 && billingGroupId == -1) 
      {
        Assert.Fail("Must provide either intervalId or billingGroupId");
      }

      foreach(RecurringEventData recurringEventData in recurringEventDataList)
      {
        if (recurringEventData.submit == true) 
        {
          SubmitEvent(recurringEventData.recurringEvent.Name,
                      intervalId,
                      billingGroupId,
                      recurringEventData.recurringEvent.Type,
                      recurringEventData.execute,
                      ignoreDependencies);
        }
      }

      
      int executions;
      int executionFailures;
      int reversals;
      int reversalFailures;

      // Process the events
      Util.GetUtil().Client.ProcessEvents(out executions, out executionFailures, 
                                          out reversals, out reversalFailures);

      // Check that the adapters have the expected status
      CheckAdapterInstances(intervalId, billingGroupId, recurringEventDataList);
    }

    /// <summary>
    ///   Execute/Reverse the given adapter. Check that after execution/reversal
    ///   the status of the adapter matches expectedStatus
    /// </summary>
    private void ExecuteAdapter(int intervalId, 
                                int billingGroupId,
                                string adapterClassName, 
                                bool execute, 
                                bool ignoreDependencies,
                                RecurringEventInstanceStatus expectedStatus)
    {
      Util util = Util.GetUtil();
      
      // Create RecurringEventData
      RecurringEventData recurringEventData = new RecurringEventData();
      recurringEventData.recurringEvent = 
        util.GetRecurringEventFromClassNameAndProgId(adapterClassName);
      recurringEventData.submit = true;
      recurringEventData.execute = execute;
      recurringEventData.expectedStatus = expectedStatus;

      ArrayList recurringEventDataList = new ArrayList();
      recurringEventDataList.Add(recurringEventData);

      ExecuteAdapters(intervalId, billingGroupId, recurringEventDataList, ignoreDependencies);
    }

    /// <summary>
    ///    Execute all the adapters for the given billingGroup and
    ///    check that they have all succeeded.
    /// </summary>
    /// <param name="billingGroup"></param>
    private void ExecuteAdapters(IBillingGroup billingGroup)
    {
      Util util = Util.GetUtil();

      // Submit the EndOfPeriod instances for execution
      SubmitEvents(billingGroup.BillingGroupID,
                   billingGroup.IntervalID,
                   new RecurringEventInstanceStatus[] {RecurringEventInstanceStatus.NotYetRun},
                   RecurringEventType.EndOfPeriod,  
                   true);

      // Submit the Checkpoint instances for execution
      SubmitEvents(billingGroup.BillingGroupID,
                   billingGroup.IntervalID,
                   new RecurringEventInstanceStatus[] {RecurringEventInstanceStatus.NotYetRun},
                   RecurringEventType.Checkpoint,  
                   true);

      int executions;
      int executionFailures;
      int reversals;
      int reversalFailures;

      util.Client.ProcessEvents(out executions, out executionFailures, 
                                out reversals, out reversalFailures);

      // Check that all the adapter instances have been run successfully
      CheckAdapterInstances(billingGroup, true);
      
    }

    /// <summary>
    ///   Once for each interval
    /// </summary>
    private void ExecuteScheduledEvents(int intervalId)
    {
      IRecurringEventInstanceFilter filter = new RecurringEventInstanceFilter();
      filter.UsageIntervalID = intervalId;
      filter.AddEventTypeCriteria(RecurringEventType.Scheduled);

      // applies the instance filter
      filter.Apply();

      // Submit
      foreach(int instanceId in filter) 
      {
        Util.GetUtil().Client.SubmitEventForExecution(instanceId, adapterComment);
      }

      int executions;
      int executionFailures;
      int reversals;
      int reversalFailures;

      Util.GetUtil().Client.ProcessEvents(out executions, out executionFailures, 
                                          out reversals, out reversalFailures);

      ArrayList scheduledInstances = GetScheduledRecurringEventInstance();

      foreach(RecurringEventInstance recurringEventInstance in scheduledInstances) 
      {
        Assert.AreNotEqual(RecurringEventInstanceStatus.Failed,
                           recurringEventInstance.recurringEventInstanceStatus,
                           String.Format("Scheduled adapter instance '{0}:{1}' failed!", 
                           recurringEventInstance.id_instance,
                           recurringEventInstance.eventName));
      }
    }

    /// <summary>
    ///   Submit the given event for the given intervalId for execution or reversal
    ///   based on isExecution.
    ///   
    ///   If intervalId is -1 it will not be used.
    ///   If billingGroupId is -1 it will not be used.
    /// </summary>
    /// <param name="eventName"></param>
    /// <param name="intervalId"></param>
    /// <param name="isExecution"></param>
    private void SubmitEvent(string eventName,
                             int intervalId,
                             int billingGroupId,
                             RecurringEventType recurringEventType,
                             bool isExecution,
                             bool ignoreDependencies)
    {
      // Retrieve the adapter instance id's for this billing group
      IRecurringEventInstanceFilter filter = new RecurringEventInstanceFilter();
      filter.EventName = eventName;
      // Set the interval id
      if (intervalId != -1)
      {
        filter.UsageIntervalID = intervalId;
      }
      // Set the billing group id
      if (billingGroupId != -1)
      {
        filter.BillingGroupID = billingGroupId;
      }

      // Set the event type
      filter.AddEventTypeCriteria(recurringEventType);

      filter.Apply();

      // Submit
      foreach(int instanceId in filter) 
      {
        if (isExecution)
        {
          Util.GetUtil().Client.
            SubmitEventForExecution(instanceId, ignoreDependencies, adapterComment);
        }
        else 
        {
          Util.GetUtil().Client.
            SubmitEventForReversal(instanceId, ignoreDependencies, adapterComment);
        }
      }
    }
    /// <summary>
    ///   Submit instances for the given billingGroup
    ///     - Checkpoints if isCheckpoint is true otherwise
    ///       EndOfPeriod's and Scheduled
    ///     - execution if isExecution is true otherwise reversal
    /// </summary>
    /// <param name="billingGroup"></param>
    /// <param name="recurringEventStatuses"></param>
    /// <param name="recurringEventTypes"></param>
    private void SubmitEvents(int billingGroupId,
                              int intervalId,
                              RecurringEventInstanceStatus[] statuses,
                              RecurringEventType eventType,
                              bool isExecution)
    {
      Util util = Util.GetUtil();

      // Retrieve the adapter instance id's for this billing group
      IRecurringEventInstanceFilter filter = new RecurringEventInstanceFilter();

      if (billingGroupId != -1)
      {
        filter.BillingGroupID = billingGroupId;
      }

      if (intervalId != -1)
      {
        filter.UsageIntervalID = intervalId;
      }

      bool ignoreDependencies = false;

      // Checkpoints or EOP's
      switch (eventType)
      {
        case RecurringEventType.Checkpoint: 
        {
          filter.AddEventTypeCriteria(RecurringEventType.Checkpoint);
          ignoreDependencies = true;
          break;
        }
        case RecurringEventType.EndOfPeriod: 
        {
          filter.AddEventTypeCriteria(RecurringEventType.EndOfPeriod);
          break;
        }
        default:
        {
          Assert.Fail
            (String.Format
              ("Incorrect RecurringEventType specified - {0}", eventType.ToString()));
          break;
        }
      }
    
      // Set the status
      if (statuses != null)
      {
        foreach(RecurringEventInstanceStatus status in statuses) 
        {
          filter.AddStatusCriteria(status);
        }
      }

      // applies the instance filter
      filter.Apply();

      // Submit
      foreach(int instanceId in filter) 
      {
        if (isExecution)
        {
          util.Client.SubmitEventForExecution(instanceId, ignoreDependencies, adapterComment);
        }
        else 
        {
          util.Client.SubmitEventForReversal(instanceId, ignoreDependencies, adapterComment);
        }
      }
    }

    /// <summary>
    ///    Check the following for the given set of adapter instances:
    ///      1) There is one _StartRoot
    ///      2) There is one _EndRoot
    ///      3) _StartRoot has a status of 'Succeeded'
    ///      4) _EndRoot has a status of 'Succeeded' if allRunSuccessfully is true
    ///         otherwise it has a status of 'ReadyToRun'
    /// </summary>
    /// <param name="enumerator"></param>
    /// <param name="allRunSuccessfully"></param>
    private void CheckRoots(ArrayList recurringEventInstances,
                            bool allRunSuccessfully)
    {
      int countStartRoot = 0;
      int countEndRoot = 0;
    
      foreach(RecurringEventInstance recurringEventInstance in recurringEventInstances)
      {
        // Make sure _StartRoot has a status of 'Succeeded'
        if (String.Compare(recurringEventInstance.eventType, Util.startRootName, true) == 0) 
        {
          Assert.AreEqual
            (RecurringEventInstanceStatus.Succeeded,
             recurringEventInstance.recurringEventInstanceStatus,
             String.Format("Mismatched adapter status for '{0}'", 
                           recurringEventInstance.eventType));

          countStartRoot++;
        }

        // Make sure _EndRoot has a status of 'Succeeded' or 'ReadyToRun'
        if (String.Compare(recurringEventInstance.eventType, Util.endRootName, true) == 0) 
        {
          if (allRunSuccessfully) 
          {
            Assert.AreEqual
              (RecurringEventInstanceStatus.Succeeded,
               recurringEventInstance.recurringEventInstanceStatus,
               String.Format("Mismatched adapter status for '{0}'", 
                             recurringEventInstance.eventType));
          }
          else 
          {
            Assert.AreEqual
              (RecurringEventInstanceStatus.ReadyToRun,
               recurringEventInstance.recurringEventInstanceStatus,
               String.Format("Mismatched adapter status for '{0}'", 
                              recurringEventInstance.eventType));
          }
          countEndRoot++;
        }
      }
    
      Assert.AreEqual(1, countStartRoot, "Incorrect number of _StartRoot's");
      Assert.AreEqual(1, countEndRoot, "Incorrect number of _EndRoot's");
    }

    /// <summary>
    ///   Return a rowset containing the recurring event instances for the given
    ///   billing group.
    /// </summary>
    /// <param name="billingGroup"></param>
    /// <returns></returns>
    private ArrayList GetRecurringEventInstances(IBillingGroup billingGroup)
    {
      return GetRecurringEventInstances(billingGroup.IntervalID, billingGroup.BillingGroupID);
    }

    /// <summary>
    ///   Get the list of scheduled recurring event instances.
    /// </summary>
    /// <returns></returns>
    private ArrayList GetScheduledRecurringEventInstance() 
    {
      ArrayList recurringEventInstances = new ArrayList();

      IRecurringEventInstanceFilter recurringEventInstanceFilter = 
        new RecurringEventInstanceFilter();

      Rowset.IMTSQLRowset rowset = 
        recurringEventInstanceFilter.GetScheduledRowset();

      RecurringEventInstance recurringEventInstance = null;

      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        recurringEventInstance = new RecurringEventInstance();
        recurringEventInstance.id_instance = (int)rowset.get_Value("InstanceID");
        recurringEventInstance.id_event = (int)rowset.get_Value("EventID");
        recurringEventInstance.eventName = (string)rowset.get_Value("EventName");
        recurringEventInstance.eventType = (string)rowset.get_Value("EventType");
        recurringEventInstance.recurringEventInstanceStatus =
          (RecurringEventInstanceStatus) 
             Enum.Parse(typeof(RecurringEventInstanceStatus), 
                        (string)rowset.get_Value("Status"));

        if (rowset.get_Value("LastRunStatus") != DBNull.Value)
        {
          recurringEventInstance.lastRunStatus = 
            (string)rowset.get_Value("LastRunStatus");
        }
     
        recurringEventInstances.Add(recurringEventInstance);
        rowset.MoveNext();
      }

      return recurringEventInstances;
    }

    /// <summary>
    ///   Return a rowset containing the recurring event instances for the given
    ///   interval id and billing group id.
    ///   If the intervalId is -1 it will not be used.
    ///   If the billingGroupId is -1 it will not be used.
    ///   
    ///   Illegal to pass -1 for both intervalId and billingGroupId.
    /// </summary>
    /// <param name="billingGroup"></param>
    /// <returns></returns>
    private ArrayList GetRecurringEventInstances(int intervalId, int billingGroupId)
    {
      if (intervalId == -1 && billingGroupId == -1) 
      {
        Assert.Fail("Must provide either billingGroupId or intervalId");
      }

      ArrayList recurringEventInstances = new ArrayList();

      IRecurringEventInstanceFilter recurringEventInstanceFilter = 
        new RecurringEventInstanceFilter();

      if (intervalId != -1) 
      {
        recurringEventInstanceFilter.UsageIntervalID = intervalId;
      }
      if (billingGroupId != -1)
      {
        recurringEventInstanceFilter.BillingGroupID = billingGroupId;
      }

      Rowset.IMTSQLRowset rowset = 
        recurringEventInstanceFilter.GetEndOfPeriodRowset(true, true, true);

      RecurringEventInstance recurringEventInstance = null;

      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        // Get the billing group support type
        BillingGroupSupportType billingGroupSupportType = 
          (BillingGroupSupportType)
            Enum.Parse(typeof(BillingGroupSupportType), 
              (string)rowset.get_Value("BillGroupSupportType"));

        // If this is a search for Interval adapters (ie. billingGroupId = -1)
        // then ignore the non-interval adapters.
        if (billingGroupSupportType != BillingGroupSupportType.Interval && 
            billingGroupId == -1)
        {
          // next row
          rowset.MoveNext();
          continue;
        }

        recurringEventInstance = new RecurringEventInstance();
        recurringEventInstance.id_instance = (int)rowset.get_Value("InstanceID");
        recurringEventInstance.id_event = (int)rowset.get_Value("EventID");
        recurringEventInstance.eventName = (string)rowset.get_Value("EventName");
        recurringEventInstance.eventType = (string)rowset.get_Value("EventType");
        recurringEventInstance.id_interval = (int)rowset.get_Value("ArgIntervalID");
        object id_billgroup = rowset.get_Value("BillGroupID");
        if (id_billgroup.GetType() != typeof(DBNull))
        {
            recurringEventInstance.id_billgroup = (int)id_billgroup;
        }
        else
        {
            recurringEventInstance.id_billgroup = -1;
        }

        recurringEventInstance.recurringEventInstanceStatus =
			   (RecurringEventInstanceStatus) 
            Enum.Parse(typeof(RecurringEventInstanceStatus), 
                       (string)rowset.get_Value("Status"));

        if (rowset.get_Value("LastRunStatus") != DBNull.Value)
        {
          recurringEventInstance.lastRunStatus = 
            (string)rowset.get_Value("LastRunStatus");
        }

        // Set the billing group support type
        recurringEventInstance.billingGroupSupportType = billingGroupSupportType;
         
        recurringEventInstances.Add(recurringEventInstance);
        rowset.MoveNext();
      }

      return recurringEventInstances;
    }

    /// <summary>
    ///    Check that all unassigned accounts for the given interval have
    ///    the given status
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="status"></param>
    private void CheckAllUnassignedAccountsStatus(int intervalId, UnassignedAccountStatus status)
    {
      Util util = Util.GetUtil();

      // Get the count of all unassigned accounts
      IUnassignedAccountsFilter filter = new UnassignedAccountsFilter();
      filter.IntervalId = intervalId;
      filter.Status = UnassignedAccountStatus.All;

      Rowset.IMTSQLRowset rowset =
        util.BillingGroupManager.GetUnassignedAccountsForIntervalAsRowset(filter);

      int totalUnassignedAccounts = rowset.RecordCount;

      // Get the count of unassigned accounts with the given status
      filter.ClearCriteria();
      filter.IntervalId = intervalId;
      filter.Status = status;
      
      rowset = 
        util.BillingGroupManager.GetUnassignedAccountsForIntervalAsRowset(filter);

      int unassignedAccounts = rowset.RecordCount;

      Assert.AreEqual(totalUnassignedAccounts, unassignedAccounts, 
                      String.Format("Mismatched unassigned accounts with '{0}'", 
                      status.ToString())); 

    }

    /// <summary>
    ///   Create and return a pull list with the given name 
    ///   based on the given parentBillingGroup.
    ///   
    ///   If pullListMembers is non-null, then it will be used.
    ///   Else
    ///   If pullOneAccount is true then only one account will be pulled out
    ///   of the parentBillingGroup otherwise all but one of the accounts 
    ///   will be pulled out of the parentBillingGroup.
    /// </summary>
    /// <param name="parentBillingGroup"></param>
    /// <param name="pullListName"></param>
    /// <param name="pullOneAccount"></param>
    /// <returns></returns>
    private IBillingGroup CreatePullList(IBillingGroup parentBillingGroup,
                                         string pullListName,
                                         ArrayList accountsForPullList,
                                         bool pullOneAccount)
    {
      Util util = Util.GetUtil();

      // Get the members of the billing group
      ArrayList parentMembers = 
        util.BillingGroupManager.
          GetBillingGroupMembers(parentBillingGroup.BillingGroupID);

      ArrayList pullListMembers = null;

      if (accountsForPullList != null) 
      {
        pullListMembers = accountsForPullList;
      }
      else 
      {
        if (pullOneAccount)
        {
          // Choose one of the parent members to create a pull list
          pullListMembers = 
            new ArrayList(parentMembers.GetRange(0, 1));
          // Reset parent members
          parentMembers.RemoveRange(0, 1);
        }
        else 
        {
          // Choose all but one of the parent members to create a pull list
          pullListMembers = 
            new ArrayList(parentMembers.GetRange(0, parentMembers.Count - 1));
          // Reset parent members
          parentMembers.RemoveRange(0, parentMembers.Count - 1);
        }
      }

      string pullListAccounts = Util.GetCommaSeparatedIds(pullListMembers);
        
      bool needsExtraAccounts;
      string pullListDescription = "Testing billing groups";

      // Start creating a pull list
      int materializationId = 
        util.BillingGroupManager.
          StartChildGroupCreationFromAccounts(pullListName,
                                              pullListDescription,
                                              parentBillingGroup.BillingGroupID,
                                              pullListAccounts,
                                              out needsExtraAccounts,
                                              util.UserId);

      // Get the extra accounts which may have been added to satisfy constraints
      Rowset.IMTSQLRowset rowset = 
        util.BillingGroupManager.GetNecessaryChildGroupAccounts(materializationId);
      Assert.IsTrue(rowset.RecordCount == 0, 
        "Expected 0 accounts from 'GetNecessaryChildGroupAccounts'");

      // Complete pull list creation
      util.BillingGroupManager.FinishChildGroupCreation(materializationId);

      // Check that new pull list exists
      rowset =
        util.BillingGroupManager.
          GetDescendantBillingGroupsRowset(parentBillingGroup.BillingGroupID);

      bool foundPullList = false;
      string dbPullListName = String.Empty;
      string dbPullListDescription = String.Empty;
      int pullListId = 0;
      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        dbPullListName = (string)rowset.get_Value("Name");
        dbPullListDescription = (string)rowset.get_Value("Description");
        pullListId = (int)rowset.get_Value("BillingGroupID");

        if (dbPullListName.Equals(pullListName) &&
            dbPullListDescription.Equals(pullListDescription)) 
        {
          foundPullList = true;
          break;
        }
        rowset.MoveNext();
      }
      
      Assert.AreNotEqual(false, foundPullList, 
                         "Did not find pull list - " + pullListName);
     
       // Check the pull list
      CheckBillingGroup(pullListId, pullListName, pullListMembers);

      // Check the parent
      CheckBillingGroup(parentBillingGroup.BillingGroupID, 
                        parentBillingGroup.Name,
                        parentMembers);


      // Check that the adapter instances are created correctly for the pull list
      IBillingGroup pullList = GetBillingGroup(pullListId);  
      CheckAdapterInstancesForPullList(pullList, parentBillingGroup);
     
      return pullList;
                
    }

    /// <summary>
    ///    1) Setup an adapter chain of the following type:
    ///         - Adapter A (Account or BillingGroup)
    ///         - Adapter B (Interval)
    ///         - HardCloseCheckpoint HCC 
    ///        (B) is dependent on (A).
    ///        (HCC) is dependent on (B) and (A).
    ///    2) Get an interval with 3 billing groups (BG1, BG2, BG3).
    ///    3) Soft close each billing group.
    ///       Creates the following adapter instances:
    ///         BG1-A, 
    ///         BG1-HCC,
    ///         BG2-A, 
    ///         BG2-HCC,
    ///         BG3-A, 
    ///         BG3-HCC
    ///         B - associated with the interval and not any billing group.
    ///    4) Execute adapters for BG1 
    ///         BG1-A should be 'Succeeded'
    ///    5) Execute B - should be 'ReadyToRun'
    ///    6) Execute adapters for BG2
    ///         BG2-A should be 'Succeeded'
    ///    7) Execute B - should be 'ReadyToRun'
    ///    8) Execute adapters for BG3 
    ///         BG3-A should be 'Succeeded'
    ///         B should be 'Succeeded' because its dependencies have been satisfied
    ///    9) If [hardCloseInterval] is true:
    ///         - Submit BG1-HCC, BG2-HCC, BG3-HCC
    ///         - Verify that the interval is hard closed. This will also verify that
    ///           the billing groups are hard closed.
    ///       Else
    ///         - Verify that the interval is open.
    ///         - Verify that the billing groups are soft closed.
    ///         
    /// </summary>
    /// <param name="hardCloseInterval"></param>
    /// <returns>interval Id</returns>
    private int TestIntervalAdapterExecutionInternal(string fileName,
                                                     bool hardCloseInterval)
    {
      int intervalId = 0;

      Util util = Util.GetUtil();

      // Prepare t_recevent
      util.SetupAdapterDependencies(Util.testDir + fileName);

      // Create and soft close billing groups
      ArrayList billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);
      bool lastBillingGroup = false;
      IBillingGroup billingGroup = null;

      // Execute the appropriate recurring events and check their status
      for (int i = 0; i < billingGroups.Count; i++)
      {
        billingGroup = (IBillingGroup)billingGroups[i];

        // The last billing group has different data than the rest
        if (i == billingGroups.Count - 1) 
        {
          lastBillingGroup = true;
        }

        ExecuteAdapters(billingGroup.IntervalID,
                        billingGroup.BillingGroupID,
                        IntervalAccountExecutionData.
                          GetRecurringEventData(lastBillingGroup),
                        false);

      }

      // Submit the checkpoints only if the interval must be hard closed
      CompleteProcessing(billingGroups, hardCloseInterval);

      return intervalId;
    }

    /// <summary>
    ///    1) Run TestIntervalAdapterExecutionInternal
    ///    2) Attempt to reverse the Account/BillingGroup adapters for each billing group. 
    ///       This should not succeed because the interval adapter has
    ///       not been reversed.
    ///       Check that the status of the Account/BillingGroup adapters are ReadyToReverse.
    ///    3) Reverse the interval adapter. This should succeed. 
    ///       Check that the status of the interval adapter is NotYetRun.
    ///       This should cause the Account/BillingGroup adapters to be reversed as well.
    ///    4) Check the status of the Account/BillingGroup adapters are NotYetRun
    /// </summary>
    /// <returns>interval id</returns>
    private int TestIntervalAdapterReversalInternal(string fileName)
    {
      Util util = Util.GetUtil();

      // Execute the adapters first
      int intervalId = TestIntervalAdapterExecutionInternal(fileName, false);

      // Get the billing groups for the interval
      ArrayList billingGroups = GetBillingGroups(intervalId);

      // Attempt to reverse the account adapters for each billing group.
      // This should not succeed.
      ExecuteAdapters
        (billingGroups,  
         IntervalAccountReversalData.
           GetDataForReversingAccountAdapterExpectingReadyToReverse());

      // Reverse the interval adapter. This should succeed and cause
      // the account adapters to be reversed as well.
      ExecuteAdapters
        (intervalId, 
        -1,
        IntervalAccountReversalData.GetDataForReversingIntervalAdapterExpectingNotYetRun(),
        false);

      // Check the status of the account adapters.
      CheckAdapterInstances
        (billingGroups, 
         IntervalAccountReversalData.GetDataForAccountAdapterExpectingNotYetRun());

      return intervalId;
    }

    /// <summary>
    ///    1) Setup an adapter chain of the following type:
    ///         - Adapter A (Interval)
    ///         - Adapter B (Interval)
    ///         - HardCloseCheckpoint HCC 
    ///        (B) is dependent on (A).
    ///        (HCC) is dependent on (B) and (A).
    ///    2) Get an interval with 3 billing groups (BG1, BG2, BG3).
    ///    3) Soft close each billing group.
    ///       Creates the following adapter instances:
    ///         BG1-HCC,
    ///         BG2-HCC,
    ///         BG3-HCC,
    ///         A - associated with the interval and not any billing group.
    ///         B - associated with the interval and not any billing group.
    ///    4) Execute B - should be 'ReadyToRun'
    ///    5) Execute A - should be 'Succeeded'.
    ///       This should cause B to become 'Succeeded'.
    ///    6) If [hardCloseInterval] is true:
    ///         - Submit BG1-HCC, BG2-HCC, BG3-HCC
    ///         - Verify that the interval is hard closed. This will also verify that
    ///           the billing groups are hard closed.
    ///       Else
    ///         - Verify that the interval is open.
    ///         - Verify that the billing groups are soft closed.
    ///       
    /// </summary>
    /// <param name="fileName"></param>
    /// <param name="hardCloseInterval"></param>
    /// <returns>interval id</returns>
    private int TestIntervalIntervalExecutionInternal(string fileName, bool hardCloseInterval)
    {
      int intervalId = 0;

      Util util = Util.GetUtil();

      // Prepare t_recevent
      util.SetupAdapterDependencies(Util.testDir + fileName);

      // Create and soft close billing groups
      ArrayList billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);

      // Execute B - should be 'ReadyToRun'
      ExecuteAdapters(intervalId,
                      -1,
                      IntervalIntervalExecutionData.GetIntervalDataExpectingReadyToRun(),
                      false);

      // Execute A - should be 'Succeeded'.
      // This should cause B to become 'Succeeded'.
      ExecuteAdapters(intervalId,
                      -1,
                      IntervalIntervalExecutionData.GetIntervalDataExpectingSucceeded(),
                      false);
    
      // Submit the checkpoints only if the interval must be hard closed
      CompleteProcessing(billingGroups, hardCloseInterval);

      return intervalId;
    }

    /// <summary>
    ///    1) Run TestIntervalIntervalExecutionInternal
    ///    2) Reverse A. Should not succeed. Expect 'ReadyToReverse'.
    ///    3) Reverse B. Should succeed. Expect 'NotYetRun'. 
    ///       Also A should be reversed. Expect 'NotYetRun'.
    /// </summary>
    /// <returns>interval id</returns>
    private int TestIntervalIntervalReversalInternal(string fileName)
    {
      Util util = Util.GetUtil();

      // Execute the adapters first
      int intervalId = TestIntervalIntervalExecutionInternal(fileName, false);

      // Reverse A. Should not succeed. Expect 'ReadyToReverse'.
      ExecuteAdapters
        (intervalId, 
         -1,
         IntervalIntervalReversalData.GetIntervalDataExpectingReadyToReverse(),
         false);

      // Reverse B. Should succeed. Expect 'NotYetRun'. 
      // Also A should be reversed. Expect 'NotYetRun'.
      ExecuteAdapters
        (intervalId, 
        -1,
        IntervalIntervalReversalData.GetIntervalDataExpectingNotYetRun(),
        false);

      return intervalId;
    }

    /// <summary>
    ///    1) Setup an adapter chain of the following type:
    ///         - Adapter A (Account)
    ///         - Adapter B (BillingGroup)
    ///         - HardCloseCheckpoint HCC 
    ///        (B) is dependent on (A).
    ///        (HCC) is dependent on (B) and (A).
    ///    2) Get an interval with 3 billing groups (BG1, BG2, BG3).
    ///    3) Soft close each billing group.
    ///       Creates the following adapter instances:
    ///         BG1-A, 
    ///         BG1-B,
    ///         BG1-HCC,
    ///         BG2-A, 
    ///         BG2-B,
    ///         BG2-HCC,
    ///         BG3-A, 
    ///         BG3-B,
    ///         BG3-HCC
    ///    4) Execute BG1-B. Should not succeed. Expect 'ReadyToRun'.
    ///    5) Execute BG2-B. Should not succeed. Expect 'ReadyToRun'.
    ///    6) Execute BG3-B. Should not succeed. Expect 'ReadyToRun'.
    ///    5) Execute BG1-A. Should succeed. Expect 'Succeeded'.
    ///       BG1-B should succeed as well. Expect 'Succeeded'.
    ///    6) Execute BG2-A. Should succeed. Expect 'Succeeded'.
    ///       BG2-B should succeed as well. Expect 'Succeeded'.
    ///    7) Execute BG3-A. Should succeed. Expect 'Succeeded'.
    ///       BG3-B should succeed as well. Expect 'Succeeded'.
    ///    8) If [hardCloseInterval] is true:
    ///         - Submit BG1-HCC, BG2-HCC, BG3-HCC
    ///         - Verify that the interval is hard closed. This will also verify that
    ///           the billing groups are hard closed.
    ///       Else
    ///         - Verify that the interval is open.
    ///         - Verify that the billing groups are soft closed.
    ///         
    /// </summary>
    /// <param name="hardCloseInterval"></param>
    /// <returns>interval Id</returns>
    private int TestBillingGroupAdapterExecutionInternal(string fileName,
                                                         bool hardCloseInterval)
    {
      int intervalId = 0;

      Util util = Util.GetUtil();

      // Prepare t_recevent
      util.SetupAdapterDependencies(Util.testDir + fileName);

      // Create and soft close billing groups
      ArrayList billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);

      // Execute all "B". Should not succeed. Expect 'ReadyToRun'.
      ExecuteAdapters(billingGroups,
                      BillingGroupExecutionData.GetDataExpectingReadyToRun());

      // Execute all "A". Should succeed. Expect 'Succeeded'.
      // All "B" should succeed as well. Expect 'Succeeded
      ExecuteAdapters(billingGroups,
                      BillingGroupExecutionData.GetDataExpectingSucceeded());

      // Submit the checkpoints only if the interval must be hard closed
      CompleteProcessing(billingGroups, hardCloseInterval);

      return intervalId;
    }

    /// <summary>
    ///    1) Run TestBillingGroupAdapterExecutionInternal
    ///    2) Reverse A for each billing group. Should not succeed. Expect 'ReadyToReverse'.
    ///    3) Reverse B for each billing group. Should succeed. Expect 'NotYetRun'.
    ///       The A's for each billing group should also succeed. Expect 'NotYetRun'.
    /// </summary>
    /// <returns>interval id</returns>
    private int TestBillingGroupAdapterReversalInternal(string fileName)
    {
      Util util = Util.GetUtil();

      // Execute the adapters first
      int intervalId = TestBillingGroupAdapterExecutionInternal(fileName, false);

      // Get the billing groups for the interval
      ArrayList billingGroups = GetBillingGroups(intervalId);

      // Reverse A for each billing group. Should not succeed. Expect 'ReadyToReverse'.
      ExecuteAdapters(billingGroups,
                      BillingGroupReversalData.GetDataExpectingReadyToReverse());

      // Reverse B for each billing group. Should succeed. Expect 'NotYetRun'.
      // The A's for each billing group should also succeed. Expect 'NotYetRun'.
      ExecuteAdapters(billingGroups,
                      BillingGroupReversalData.GetDataExpectingNotYetRun());

      return intervalId;
    }

    /// <summary>
    ///    1) Setup an adapter chain of the following type:
    ///         - Adapter A (Interval)
    ///         - Adapter B (BillingGroup)
    ///         - HardCloseCheckpoint HCC 
    ///        (B) is dependent on (A).
    ///        (HCC) is dependent on (B) and (A).
    ///    2) Get an interval with 3 billing groups (BG1, BG2, BG3).
    ///    3) Soft close each billing group.
    ///       Creates the following adapter instances:
    ///         BG1-B,
    ///         BG1-HCC,
    ///         BG2-B,
    ///         BG2-HCC,
    ///         BG3-B,
    ///         BG3-HCC
    ///         A - associated with the interval and not any billing group.
    ///    4) Execute BG1-B. Should not succeed. Expect 'ReadyToRun'.
    ///    5) Execute BG2-B. Should not succeed. Expect 'ReadyToRun'.
    ///    6) Execute BG3-B. Should not succeed. Expect 'ReadyToRun'.
    ///    5) Execute A. Should succeed. Expect 'Succeeded'.
    ///       BG1-B should succeed as well. Expect 'Succeeded'.
    ///       BG2-B should succeed as well. Expect 'Succeeded'.
    ///       BG3-B should succeed as well. Expect 'Succeeded'.
    ///    8) If [hardCloseInterval] is true:
    ///         - Submit BG1-HCC, BG2-HCC, BG3-HCC
    ///         - Verify that the interval is hard closed. This will also verify that
    ///           the billing groups are hard closed.
    ///       Else
    ///         - Verify that the interval is open.
    ///         - Verify that the billing groups are soft closed.
    ///         
    /// </summary>
    /// <param name="hardCloseInterval"></param>
    /// <returns>interval Id</returns>
    private int TestBillingGroupIntervalExecutionInternal(string fileName,
                                                          bool hardCloseInterval)
    {
      int intervalId = 0;

      Util util = Util.GetUtil();

      // Prepare t_recevent
      util.SetupAdapterDependencies(Util.testDir + fileName);

      // Create and soft close billing groups
      ArrayList billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);

      // Execute all "B". Should not succeed. Expect 'ReadyToRun'.
      ExecuteAdapters(billingGroups,
        BillingGroupIntervalExecutionData.GetDataExpectingReadyToRun());

      // Execute "A". Should succeed. Expect 'Succeeded'.
      ExecuteAdapters(intervalId, -1, 
                      BillingGroupIntervalExecutionData.GetIntervalDataExpectingSucceeded(),
                      false);
      
      // Verify that all "B" have succeeded as well. 
      CheckAdapterInstances
        (billingGroups, 
         BillingGroupIntervalExecutionData.GetBillingGroupDataExpectingSucceeded());

      // Submit the checkpoints only if the interval must be hard closed
      CompleteProcessing(billingGroups, hardCloseInterval);

      return intervalId;
    }
    
    /// <summary>
    ///    1) Run TestBillingGroupIntervalExecutionInternal
    ///    2) Reverse A. Should not succeed. Expect 'ReadyToReverse'.
    ///    3) Reverse B for all billing groups. Should succeed. Expect 'NotYetRun'.
    ///       A should also succeed. Expect 'NotYetRun'.
    /// </summary>
    /// <returns>interval id</returns>
    private int TestBillingGroupIntervalReversalInternal(string fileName)
    {
      Util util = Util.GetUtil();

      // Execute the adapters first
      int intervalId = TestBillingGroupIntervalExecutionInternal(fileName, false);

      // Get the billing groups for the interval
      ArrayList billingGroups = GetBillingGroups(intervalId);

      // Reverse A. Should not succeed. Expect 'ReadyToReverse'.
      ExecuteAdapters(intervalId, -1,
                      BillingGroupIntervalReversalData.GetIntervalDataExpectingReadyToReverse(),
                      false);

      bool lastBillingGroup = false;
      IBillingGroup billingGroup = null;

      // Execute the B for each billing group. A should become NotYetRun
      // only when B for the last billing group has been reversed.
      for (int i = 0; i < billingGroups.Count; i++)
      {
        billingGroup = (IBillingGroup)billingGroups[i];

        // The last billing group has different data than the rest
        if (i == billingGroups.Count - 1) 
        {
          lastBillingGroup = true;
        }

        ExecuteAdapters(billingGroup.IntervalID,
                        billingGroup.BillingGroupID,
                        BillingGroupIntervalReversalData.
                          GetDataExpectingReadyToReverse(lastBillingGroup),
                        false);

      }

      return intervalId;
    }

    /// <summary>
    ///   Execute the given recurring events for all the billing groups in
    ///   billingGroups.
    /// </summary>
    /// <param name="billingGroups"></param>
    /// <param name="recurringEventDataList"></param>
    private void ExecuteAdapters(ArrayList billingGroups,
                                 ArrayList recurringEventDataList) 
    {
      foreach(IBillingGroup billingGroup in billingGroups) 
      {
        ExecuteAdapters(billingGroup.IntervalID, 
                        billingGroup.BillingGroupID, 
                        recurringEventDataList,
                        false);
      }
    }

    /// <summary>
    ///   Execute the checkpoints for the given billing groups if hardCloseInterval
    ///   is true. Otherwise verify that the interval is 'Open' and that the
    ///   billing groups are all hard closed.   
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="billingGroupId"></param>
    private void CompleteProcessing(ArrayList billingGroups, bool hardCloseInterval) 
    {
      int intervalId = ((IBillingGroup)billingGroups[0]).IntervalID;
      if (hardCloseInterval)
      {
        foreach(IBillingGroup billingGroup in billingGroups)
        {
          ExecuteAdapters(billingGroup.IntervalID,
            billingGroup.BillingGroupID,
            CheckpointData.GetCheckpointData(),
            false);
        }
      
        // Check that the interval is hard closed
        VerifyIntervalStatus(intervalId, UsageIntervalStatus.HardClosed);
      }
      else 
      {
        VerifyIntervalStatus(intervalId, UsageIntervalStatus.Open);
        VerifyBillingGroupStatus(intervalId, BillingGroupStatus.SoftClosed);
      }
    }

    /// <summary>
    ///    Create one pull list from each of the billing groups in
    ///    billingGroups. 
    ///    
    ///    The namePrefix will be appended by 1, 2 etc. to create
    ///    the name of each pull list.
    ///    
    ///    Return an ArrayList of IBillingGroup items representing the pull lists.
    /// </summary>
    /// <param name="billingGroups"></param>
    /// <returns></returns>
    private ArrayList CreatePullLists(ArrayList billingGroups, string namePrefix)
    {
      ArrayList pullLists = new ArrayList();
      int count = 1;
      IBillingGroup pullList = null;

      foreach(IBillingGroup billingGroup in billingGroups)
      {
        pullList = CreatePullList(billingGroup, namePrefix + count, null, false);
        pullLists.Add(pullList);
        count++;
      }

      return pullLists;
    }

    /// <summary>
    ///   Backout usage associated with the given interval and the given accounts.
    ///   If the resubmit flag is true, usage will be resubmitted otherwise it
    ///   will be deleted.
    /// </summary>
    /// <param name="intervalId"></param>
    private void BackoutUsage(int intervalId, ArrayList accountIds, bool resubmit)
    {
      Util util = Util.GetUtil();

      IBillingGroupWriter billingGroupWriter = new BillingGroupWriter();

      string commaSeparatedAccounts = Util.GetCommaSeparatedIds(accountIds);

      billingGroupWriter.
        BackoutUsage(util.BillingGroupManager, 
                     intervalId, 
                     commaSeparatedAccounts, 
                     util.SessionContext,
                     false,
                     resubmit); 
    }

    /// <summary>
    ///    1) Create billing groups
    ///    2) Pick one billing group (BG1) for testing.
    ///    3) Meter usage to accounts for BG1 with the time associated
    ///       with the current interval.
    ///    4) Soft close billing group.
    ///    5) If hardCloseBillingGroup is true, hard close the billing group
    ///    6) Attempt to backout usage
    ///    5) Verify that the usage got backed out if hardCloseBillingGroup is false
    ///       Verify that the usage did not get backed out if hardCloseBillingGroup is true
    /// </summary>
    /// <param name="hardCloseBillingGroup"></param>
    private void TestBackout(bool hardCloseBillingGroup)
    {
      Util util = Util.GetUtil();

      // Create billing groups for a non-materialized interval 
      int intervalId;
      ArrayList billingGroups = 
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Pick the first billing group 
      IBillingGroup billingGroup = (IBillingGroup)billingGroups[0];
      ArrayList accounts = 
        util.BillingGroupManager.GetBillingGroupMembers(billingGroup.BillingGroupID);
      
      // Meter usage to the billing group accounts with the time associated
      // with the current interval and verify that the usage did land
      // in the given interval
      MeterUsage(accounts, intervalId, true);

      // Soft close the billing group
      SoftCloseBillingGroup(billingGroup.BillingGroupID);

      bool usageExists = false;
      if (hardCloseBillingGroup)
      {
        // Hard close the billing group
        util.BillingGroupManager.HardCloseBillingGroup(billingGroup.BillingGroupID);
        usageExists = true;
      }

      // Attempt to backout and delete usage
      BackoutUsage(intervalId, accounts, false);

      // Verify that usage still exists or does not exist 
      // based on hardClosedBillingGroup
      VerifyUsage(accounts, intervalId, usageExists);
    }

    /// <summary>
    ///   Check that invoices are generated for the given intervalId and
    ///   the given account id's.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="accounts"></param>
    private void CheckInvoices(int intervalId, ArrayList accounts, bool exists) 
    {
      string commaSeparatedAccounts = 
        Util.GetCommaSeparatedIds(accounts);

      // Get the account id's for the given interval and given accounts
      string query = 
        String.Format("Select id_acc as accountid from t_invoice " +
                      "where id_interval = '{0}' and id_acc in ({1})", 
                      intervalId, commaSeparatedAccounts);

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTStatement stmt = conn.CreateStatement(query))
          {
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      // We expect to find them
                      if (exists)
                      {
                          Assert.AreEqual(true, accounts.Contains(reader.GetInt32("accountid")),
                                          "Mismatched accounts");
                      }
                      else
                      {
                          // If we're here then we've found invoices when we didn't expect
                          // to find any.
                          Assert.Fail(String.Format("Invoices found for interval '{0}' " +
                                                    "and accounts '{1}' where none were expected"));
                      }
                  }
              }
          }
      }
    }


    /// <summary>
    ///    Add the given number of months to MetraTime
    /// </summary>
    /// <param name="days"></param>
    private void MoveMetraTimeForwardInMonths(int months)
    {
      MetraTech.MetraTime.Now = MetraTime.Now.AddMonths(months);
    }

    /// <summary>
    ///    Preconditions:
    ///      1) The product offering 'Calendar_CL_PO' has been created by running:
    ///         pcimportexport -ipo -file "T:\QA\FunctionalTests\Usage\USAGE_CALENDAR\xml\CALENDAR_CodeLookUp_PO.xml" -username "su" -password "su123"
    ///      2) The pricelist 'Calendar_CL_PL' corresponding to 'Calendar_CL_PO' exists.
    ///      3) 'Calendar_CL_PO' has the following calendar codes (peak, off-peak ...):
    ///          12:00 AM - 03:14:59 AM = Off-peak
    ///          03:15 AM - 05:44:59 AM = Holiday
    ///          05:45 AM - 07:59:59 AM = Off-peak
    ///          08:00 AM - 07:59:59 PM = Peak 
    ///          08:00 PM - 08:59:59 PM = Off-peak
    ///          09:00 PM - 11:29:59 PM = Weekend
    ///          11:30 PM - 11:59:59 PM = Off-peak
    ///          
    ///    Test:
    ///      1) Clear t_pv_testpi for the given interval.
    ///      2) Create an account with the given globalTimeZoneId (from Global.xml)and 
    ///         and the given pricelist name ('Calendar_CL_PL').
    ///      3) Meter one testpi session for the account with the given gmtTime
    ///         and the given intervalId.
    ///      4) Check that there is one data row in t_pv_testpi for the given interval
    ///         - Check that it has the given enumDataTimeZoneId
    ///         - Check that it has the given expectedCalendarCode
    /// </summary>
    /// <param name="timeZoneId"></param>
    private bool TestCalendarCodeForTimeZone(TimeZoneTestData timeZoneTestData) 
    {
      // Clear t_pv_testpi for the given interval
      Util util = Util.GetUtil();
      util.DeleteTestPI();

      // Create an account
      ArrayList accountIds = 
        CreateAccounts(1, 
                       true, 
                       timeZoneTestData.metraTechTimeZoneId, 
                       timeZoneTestData.priceListName);

      // Meter usage
      string testpiServiceDef = "metratech.com\testpi";
      MeterUsage(accountIds, 
                 timeZoneTestData.intervalId, 
                 false, 
                 timeZoneTestData.gmtTime, 
                 testpiServiceDef, 
                 1);

      // Check t_pv_testpi
      return
        util.CheckPvTestPI(timeZoneTestData.enumDataTimeZoneId, 
                           timeZoneTestData.calendarCode);
      //     String.Format("Could not find time zone '{0}' and " +
      //                   "calendar code '{1}'", globalTimeZoneId, expectedCalendarCode.ToString());
                         
    }

    /// <summary>
    ///    Return a list of TimeZoneTestData objects based on the given timeZone. 
    ///    Each object specifies a time data field and the 
    ///    expected calendar code (Peak, Off-peak ...)
    ///    
    ///    'Calendar_CL_PO' has the following calendar codes (peak, off-peak ...):
    ///          12:00 AM - 03:14:59 AM = Off-peak
    ///          03:15 AM - 05:44:59 AM = Holiday
    ///          05:45 AM - 07:59:59 AM = Off-peak
    ///          08:00 AM - 07:59:59 PM = Peak 
    ///          08:00 PM - 08:59:59 PM = Off-peak
    ///          09:00 PM - 11:29:59 PM = Weekend
    ///          11:30 PM - 11:59:59 PM = Off-peak
    /// </summary>
    /// <returns></returns>
    private ArrayList GetTimeZoneTestData
      (CalendarTimeZoneData.CalendarCodeDataTable calendarCodeData,
       string windowsTimeZoneName,
       int metraTechTimeZoneId,
       bool useWindowsTimeZone) 
    {
      ArrayList timeZoneTestDataList = new ArrayList();

      DateTime testDate = DateTime.MinValue;

      foreach(CalendarTimeZoneData.CalendarCodeRow calendarCodeRow in 
        calendarCodeData.Rows)
      {
        foreach(CalendarTimeZoneData.TimeSpanRow timeSpanRow in
          calendarCodeRow.GetTimeSpanRows())
        {
          // Create a TimeZoneTestData for the start time
          timeZoneTestDataList.Add
            (GetTimeZoneTestData(timeSpanRow,
                                 calendarCodeRow,
                                 windowsTimeZoneName,
                                 metraTechTimeZoneId,
                                 useWindowsTimeZone,
                                 true));

          // Create a TimeZoneTestData for the end time
          timeZoneTestDataList.Add
            (GetTimeZoneTestData(timeSpanRow,
                                 calendarCodeRow,
                                 windowsTimeZoneName,
                                 metraTechTimeZoneId,
                                 useWindowsTimeZone,
                                 false));

        }
      }

      return timeZoneTestDataList;
    }

    /// <summary>
    ///   Return the TimeZoneTestData given TimeSpanRow
    /// </summary>
    /// <param name="timeSpanRow"></param>
    /// <param name="windowsTimeZone"></param>
    /// <returns></returns>
    private TimeZoneTestData GetTimeZoneTestData
      (CalendarTimeZoneData.TimeSpanRow timeSpanRow,
       CalendarTimeZoneData.CalendarCodeRow calendarCodeRow,
       string windowsTimeZoneName,
       int metraTechTimeZoneId,
       bool useWindowsTimeZone,
       bool getStart) 
    {
      TimeZoneTestData timeZoneTestData = new TimeZoneTestData();

      // Create a TimeZoneTestData for the start time
      timeZoneTestData = new TimeZoneTestData();
      timeZoneTestData.windowsTimeZoneName = windowsTimeZoneName;

      // Retrieve the hours, minutes and seconds
      int year = DateTime.Now.Year;
      int month = DateTime.Now.Month;
      int day = DateTime.Now.Day;

      int hour = Int32.MinValue;
      int minute = Int32.MinValue;
      int second = Int32.MinValue;

      if (getStart) 
      {
        hour = 
          Convert.ToInt32(
          ((CalendarTimeZoneData.StartRow)timeSpanRow.GetStartRows()[0]).hour);
        minute = 
          Convert.ToInt32(
          ((CalendarTimeZoneData.StartRow)timeSpanRow.GetStartRows()[0]).minute);
        second = 
          Convert.ToInt32(
          ((CalendarTimeZoneData.StartRow)timeSpanRow.GetStartRows()[0]).second);
      }
      else 
      {
        hour = 
          Convert.ToInt32(
          ((CalendarTimeZoneData.EndRow)timeSpanRow.GetEndRows()[0]).hour);
        minute = 
          Convert.ToInt32(
          ((CalendarTimeZoneData.EndRow)timeSpanRow.GetEndRows()[0]).minute);
        second = 
          Convert.ToInt32(
          ((CalendarTimeZoneData.EndRow)timeSpanRow.GetEndRows()[0]).second);
      }

      // Calculate GMT based on the time zone passed in
      DateTime testDate = new DateTime(year, month, day, hour, minute, second);

      if (useWindowsTimeZone) 
      {
        // Use the Windows Time Zone information to convert to GMT
        timeZoneTestData.gmtTime = 
          TimeZoneInformation.ToUniversalTime(windowsTimeZoneName, testDate);
      }
      else 
      {
        const string dateFormat = "yyyy-MM-ddTHH:mm:ssZ";

        IMTUserCalendar calendar = new MTUserCalendarClass();
        timeZoneTestData.gmtTime = 
          DateTime.FromOADate(
          (double)calendar.LocalTimeToGMT(testDate.ToString(dateFormat), 
          metraTechTimeZoneId));
      }

      // Set the calendar code enum
      timeZoneTestData.calendarCode = 
        (CalendarCodeEnum)Enum.Parse(typeof(CalendarCodeEnum), calendarCodeRow.name);

      // Set the original time
      timeZoneTestData.originalTime = testDate;

      return timeZoneTestData;
    }

    /// <summary>
    ///   Return the time zone ids specified in 
    ///   R:\extensions\Core\config\enumtype\Global\Global.xml.
    ///   Use the dataset (mt_config) auto-generated from Global.xsd in Global.cs
    /// </summary>
    /// <returns>metraTech time zone id <-->  metraTech time zone enum</--></returns>
    private Hashtable GetTimeZoneIds() 
    {
      Hashtable timeZoneIds = new Hashtable();

      mt_config dataSet = new mt_config();
      dataSet.ReadXml(@"R:\extensions\Core\config\enumtype\Global\Global.xml");

      mt_config._enumDataTable enumDataTable = 
        (mt_config._enumDataTable)dataSet.Tables["enum"];

      foreach(mt_config._enumRow row in enumDataTable.Rows) 
      {
        if (row.name == "TimeZoneID") 
        {
          foreach(mt_config.entriesRow row1 in row.GetentriesRows())
          {
            foreach(mt_config.entryRow eRow in row1.GetentryRows()) 
            {
              // Add the metratech time zone id
              timeZoneIds.Add(Convert.ToInt32(eRow.value), eRow.name);
            }
          }
        }
      }
      
      return timeZoneIds;
    }

    /// <summary>
    ///    Hard close an interval with no payer accounts.
    ///    Check that the interval is hard closed.
    ///    Return the interval id.
    /// </summary>
    /// <returns></returns>
    public int HardCloseInterval() 
    {
      Util util = Util.GetUtil();
      // Get an interval without payers
      int intervalId = util.GetIntervalWithoutPayers();
      int hardClosedBillingGroups = 0;
      util.Client.HardCloseUsageInterval(intervalId, false, out hardClosedBillingGroups);

      VerifyIntervalStatus(intervalId, UsageIntervalStatus.HardClosed);

      return intervalId;
    }

    public class TimeZoneRowSorter : IComparer  
    {
      // Calls CaseInsensitiveComparer.Compare with the parameters reversed.
      int IComparer.Compare(Object x, Object y)  
      {
        xmlconfig.timezoneRow xRow = (xmlconfig.timezoneRow)x;
        xmlconfig.timezoneRow yRow = (xmlconfig.timezoneRow)y;

        return(xRow.id_timezone.CompareTo(yRow.id_timezone));
      }
    }


    #endregion

    #region Data
    // Store IBillingGroup <--> ArrayList of member account id's
    private ArrayList billingGroupsForIntervalBeforePullListCreation;
    private ArrayList billingGroupsForIntervalBeforeUserDefinedGroupCreation;

    private int testPullListId;
    private int testParentBillingGroupId;
    private int testUserDefinedBillingGroupId;

    
    
    private const string adapterComment = "Billing group test";
    #endregion

    #region Test Data 

    /// <summary>
    ///   Provides checkpoint data common to all execution dependency tests.
    /// </summary>
    private class CheckpointData
    {
      /// <summary>
      ///   Return the data pertaining to hard close checkpoints.
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetCheckpointData()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit and execute "HardCloseCheckpoint". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = 
          util.GetRecurringEvent(Util.hardCloseCheckpointName);
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.endRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private class IntervalAccountExecutionData
    {
      /// <summary>
      ///   Return the recurring events which need to be executed or
      ///   reversed along with the recurring events which do not need
      ///   to be submitted but whose status needs to be checked.
      ///   
      ///   If lastBillingGroup is true, then don't submit the interval 
      ///   adapter and expect it to be succeeded because all its dependencies
      ///   will have been satisfied.
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetRecurringEventData(bool lastBillingGroup)
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit and execute "A". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // If it's not the last billing group, 
        // submit and execute "B". Expect 'ReadyToRun'.
        // Otherwise, do not submit "B". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        if (lastBillingGroup) 
        {
          recurringEventData.submit = false;
          recurringEventData.execute = false;
          recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        }
        else 
        {
          recurringEventData.submit = true;
          recurringEventData.execute = true;
          recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        }
        
        data.Add(recurringEventData);

        // Do not submit "_StartRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.startRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.endRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private class IntervalAccountReversalData
    {
      /// <summary>
      ///   
      /// </summary>
      /// <returns></returns>
      public static ArrayList GetDataForReversingAccountAdapterExpectingReadyToReverse()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit and reverse "A". Expect 'ReadyToReverse'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = true;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToReverse;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// 
      /// </summary>
      /// <returns></returns>
      public static ArrayList GetDataForAccountAdapterExpectingNotYetRun()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit and reverse "A". Expect 'NotYetRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.NotYetRun;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns></returns>
      public static ArrayList GetDataForReversingIntervalAdapterExpectingNotYetRun()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit and reverse "B". Expect 'NotYetRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = true;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.NotYetRun;
        data.Add(recurringEventData);

        return data;
      }

    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private class IntervalIntervalExecutionData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingReadyToRun()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit and execute "B". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingSucceeded()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "A". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // Do not submit "B". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = false;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private class IntervalIntervalReversalData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingReadyToReverse()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "A" for reversal. Expect 'ReadyToReverse'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = true;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToReverse;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingNotYetRun()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "B" for reversal. Expect 'NotYetRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = true;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.NotYetRun;
        data.Add(recurringEventData);

        // Do not submit "A". Expect 'NotYetRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.NotYetRun;
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private class BillingGroupExecutionData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingReadyToRun()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "B" for execution. Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        // Do not submit "_StartRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.startRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.endRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingSucceeded()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "A" for execution. Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // Do not submit "B" for execution. Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = false;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private class BillingGroupReversalData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingReadyToReverse()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "A" for reversal. Expect 'ReadyToReverse'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = true;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToReverse;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingNotYetRun()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "B" for reversal. Expect 'NotYetRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = true;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.NotYetRun;
        data.Add(recurringEventData);

        // Do not submit "A" for execution. Expect 'NotYetRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.NotYetRun;
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.endRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private class BillingGroupIntervalReversalData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingReadyToReverse(bool lastBillingGroup)
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "B" for reversal. Expect 'NotYetRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = true;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.NotYetRun;
        data.Add(recurringEventData);

        // A should be 'ReadyToReverse' if lastBillingGroup is false.
        // Otherwise it should be 'NotYetRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        if (lastBillingGroup)
        {
          recurringEventData.expectedStatus = RecurringEventInstanceStatus.NotYetRun;
        }
        else 
        {
          recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToReverse;
        }
        data.Add(recurringEventData); 

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingReadyToReverse()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "A" for reversal. Expect 'ReadyToReverse'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = true;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToReverse;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingNotYetRun()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Do not submit "A". Expect 'NotYetRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.NotYetRun;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetBillingGroupDataExpectingNotYetRun()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Do not submit "B". Expect 'NotYetRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.NotYetRun;
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private class BillingGroupIntervalExecutionData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingReadyToRun()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "B" for execution. Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        // Do not submit "_StartRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.startRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.endRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingSucceeded()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "A" for execution. Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetBillingGroupDataExpectingSucceeded()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Do not submit "B". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private class BillingGroupAdapterWithPullListData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataForParentBillingGroup()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "A" for execution. Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // Submit "B" for execution. Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        // Do not submit "_StartRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.startRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.endRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataForBillingGroupExpectReadyToRun()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Do not submit "B". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataForBillingGroupExpectSucceeded()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Do not submit "B". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("B");
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataForPullList()
      {
        ArrayList data = new ArrayList();
        RecurringEventData recurringEventData = null;
        Util util = Util.GetUtil();

        // Submit "A" for execution. Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent("A");
        recurringEventData.submit = true;
        recurringEventData.execute = true;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // Do not submit "_StartRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.startRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.Succeeded;
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData();
        recurringEventData.recurringEvent = util.GetRecurringEvent(Util.endRootName);
        recurringEventData.submit = false;
        recurringEventData.execute = false;
        recurringEventData.expectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        data.Add(recurringEventData);

        return data;
      }
    }
    #endregion

    #region Helper Classes

    private class TimeZoneTestData 
    {
      public TimeZoneTestData() 
      {
      }
      public DateTime gmtTime;
      public DateTime originalTime;
      public CalendarCodeEnum calendarCode;
      public int metraTechTimeZoneId;
      public int enumDataTimeZoneId;
      public string windowsTimeZoneName;
      public string enumTimeZoneName;
      public int intervalId;
      public string priceListName;
    }

    private class RecurringEventData 
    {
      public IRecurringEvent recurringEvent;
      public bool submit;  // false indicates do not submit
      public bool execute; // false indicates reverse
      public RecurringEventInstanceStatus expectedStatus;
    }

    private class BatchAccountData
    {
      public string batchUid;
      public int accountId;
    }

    private class RecurringEventInstance
    {
      public int id_instance;
      public int id_event;
      public string eventType;
      public string eventName;
      public int id_interval;
      public int id_billgroup;
      public RecurringEventInstanceStatus recurringEventInstanceStatus;
      public string lastRunStatus;
      public BillingGroupSupportType billingGroupSupportType;

      /// <summary>
      ///   Override equals
      /// </summary>
      /// <param name="o"></param>
      /// <returns></returns>
      public override bool Equals(object o)
      {
        RecurringEventInstance recurringEventInstance = o as RecurringEventInstance;
        if (recurringEventInstance == null)
        {
          return false; // not a compatible type 
        }

        // Everything except id_instance must be the same
        if (id_event == recurringEventInstance.id_event &&
            id_interval == recurringEventInstance.id_interval &&
            recurringEventInstanceStatus == recurringEventInstance.recurringEventInstanceStatus &&
            lastRunStatus == recurringEventInstance.lastRunStatus &&
            billingGroupSupportType == recurringEventInstance.billingGroupSupportType) 
        {
          return true;
        }

        return false;
      }

      /// <summary>
      ///   Override GetHashCode
      /// </summary>
      /// <returns></returns>
      public override int GetHashCode()
      {
        return id_instance;
      }
    }
    #endregion
	}
 }
