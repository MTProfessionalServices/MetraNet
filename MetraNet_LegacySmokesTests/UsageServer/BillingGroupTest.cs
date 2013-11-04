using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using MetraTech.Accounts.Type;
using MetraTech.DataAccess;
using MetraTech.DataAccess.MaterializedViews;
using MetraTech.Interop.COMMeter;
using MetraTech.Interop.MTCalendar;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.NameID;
using MetraTech.Metering.DatabaseMetering;
using MetraTech.Test;
using MetraTech.TestCommon;
using NUnit.Framework;
using Coll = MetraTech.Interop.GenericCollection;
using Auth = MetraTech.Interop.MTAuth;
using YAAC = MetraTech.Interop.MTYAAC;

namespace MetraTech.UsageServer.Test
{
  //
  // To run the this test fixture:
  // nunit-console /fixture:MetraTech.UsageServer.Test.BillingGroupTest /assembly:O:\debug\bin\MetraTech.UsageServer.Test.dll
  //
  /// <summary>
  ///   Billing group tests.
  /// </summary>
  [TestFixture]
  [Category("NoAutoRun")]
  public class BillingGroupTest
  {
    private static Util _util;

    public delegate void UtilDelegate(object[] parameters);

    [TestFixtureSetUp]
    public void Initialize()
    {
      _util = Util.Instance;
    }

    /// <summary>
    ///   The given ArrayList contains IBillingGroup objects.
    ///   Check that the following billing groups are present:
    ///   - North America (3 accounts)
    ///   - South America (3 accounts)
    ///   - Europe        (3 accounts)
    /// </summary>
    /// <param name="billingGroups"></param>
    private static void CheckBillingGroups(Hashtable billingGroups)
    {
      var billingGroup = (IBillingGroup) billingGroups[Util.NorthAmericaBillingGroupName];
      CheckBillingGroup(billingGroup, Util.NorthAmericaBillingGroupName, _util.UsAccountIds);

      billingGroup = (IBillingGroup) billingGroups[Util.SouthAmericaBillingGroupName];
      CheckBillingGroup(billingGroup, Util.SouthAmericaBillingGroupName, _util.BrazilAccountIds);

      billingGroup = (IBillingGroup) billingGroups[Util.EuropeBillingGroupName];
      CheckBillingGroup(billingGroup, Util.EuropeBillingGroupName, _util.UkAccountIds);
    }

    /// <summary>
    ///   Check the following:
    ///   1) The given billing group has the given expectedName
    ///   2) The given billing group has the same accounts as expected accounts
    /// </summary>
    /// <param name="billingGroup"></param>
    /// <param name="expectedName"></param>
    /// <param name="expectedAccounts">account id's</param>
    private static void CheckBillingGroup(IBillingGroup billingGroup,
                                          string expectedName,
                                          ArrayList expectedAccounts)
    {
      Assert.AreNotEqual(null, billingGroup, "Null billing group!");
      Assert.AreEqual(expectedName, billingGroup.Name, "Billing group name mismatch!");
      CheckBillingGroupAccounts(billingGroup, expectedAccounts);
    }

    /// <summary>
    ///   Forward to CheckBillingGroup with IBillingGroup
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <param name="expectedName"></param>
    /// <param name="expectedAccounts"></param>
    private static void CheckBillingGroup(int billingGroupId,
                                          string expectedName,
                                          ArrayList expectedAccounts)
    {
      var billingGroup =
        _util.BillingGroupManager.GetBillingGroup(billingGroupId);
      CheckBillingGroup(billingGroup, expectedName, expectedAccounts);
    }

    /// <summary>
    ///   If isPresent is true, return an error if any of the account id's in accountIds
    ///   are not members of the given billingGroupId.
    ///   If isPresent is false, return an error if any of the account id's in accountIds
    ///   are members of the given billingGroupId.
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <param name="accountIds"></param>
    /// <param name="isPresent"></param>
    private static void CheckBillingGroupAccountMembership(int billingGroupId,
                                                           ArrayList accountIds,
                                                           bool isPresent)
    {
      if (isPresent)
      {
        foreach (int accountId in accountIds)
        {
          // Error if we don't find the accountId
          Assert.IsTrue(accountIds.Contains(accountId),
                        String.Format("Expect to find account [{0}] in billing group [{1}]",
                                      accountId, billingGroupId));
        }
      }
      else
      {
        foreach (int accountId in accountIds)
        {
          // Error if we find the accountId
          Assert.IsTrue(!accountIds.Contains(accountId),
                        String.Format("Did not expect to find account [{0}] in billing group [{1}]",
                                      accountId, billingGroupId));
        }
      }
    }

    /// <summary>
    ///   Check that the accounts in the given billing group match
    ///   the accounts in the given ArrayList of account ids.
    /// </summary>
    /// <param name="billingGroup"></param>
    /// <param name="accountIds"></param>
    private static void CheckBillingGroupAccounts(IBillingGroup billingGroup,
                                                  ArrayList accountIds)
    {
      // Get the billing group accounts
      var rowset =
        _util.BillingGroupManager.
              GetBillingGroupMembersRowset(billingGroup.BillingGroupID, null);

      Assert.AreEqual(accountIds.Count, rowset.RecordCount,
                      "Mismatch in billing group accounts!");

      while (!Convert.ToBoolean(rowset.EOF))
      {
        var accountId = (int) rowset.Value["AccountID"];

        Assert.IsTrue
          (accountIds.Contains(accountId),
           String.Format("Unexpected account [{0}] in billing group [{1}]",
                         accountId, billingGroup.Name));

        rowset.MoveNext();
      }
    }

    /// <summary>
    ///   Return true if the materialization for the given materializationId
    ///   has status specified by materializationStatus in t_billgroup_materialization
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="materializationStatus"></param>
    /// <returns></returns>
    private static bool CheckMaterializationStatus(int materializationId,
                                                   MaterializationStatus materializationStatus)
    {
      var match = false;

      var billingGroupManager = new BillingGroupManager();
      var materialization =
        billingGroupManager.GetMaterialization(materializationId);

      if (materialization.MaterializationStatus == materializationStatus)
      {
        match = true;
      }

      return match;
    }

    /// <summary>
    ///   Create a materialization with the given type
    ///   and return the materialization id.
    /// </summary>
    /// <returns></returns>
    private static int CreateMaterialization(MaterializationType materializationType,
                                             out int intervalId)
    {
      // Get an interval for materialization
      intervalId = _util.GetIntervalForFullMaterialization();

      // Create a materialization
      var materializationId =
        _util.BillingGroupManager.
              CreateMaterialization(intervalId,
                                    _util.UserId,
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
    private static void UpdateMaterializationFromProgressToFailed(int materializationId)
    {
      // Check that the materialization has a status of InProgress
      Assert.IsTrue(CheckMaterializationStatus(materializationId,
                                               MaterializationStatus.InProgress),
                    "Expected 'InProgress' materialization!");

      // Clean up the materialization
      _util.BillingGroupManager.
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
    ///   Create temporary billing groups and return the interval id and
    ///   materialization id generated.
    ///   If a UtilDelegate is provided, then invoke it 'numOfTimesToInvokeDelegate'
    ///   times either before or after creating billing groups based on
    ///   'callDelegateBeforeCreatingBillingGroups'.
    ///   The delegate parameters are provided in 'parameters'.
    ///   Each delegate method expected the first two parameters to
    ///   be the interval id and the materialization id respectively.
    ///   Perform validation if 'doValidation' is true.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="materializationId"></param>
    /// <param name="callDelegateBeforeCreatingBillingGroups"></param>
    /// <param name="utilDelegate"></param>
    /// <param name="numOfTimesToInvokeDelegate"></param>
    /// <param name="parameters"></param>
    /// <param name="doValidation"></param>
    private static void CreateTemporaryBillingGroups(out int intervalId,
                                                     out int materializationId,
                                                     bool callDelegateBeforeCreatingBillingGroups,
                                                     UtilDelegate utilDelegate,
                                                     int numOfTimesToInvokeDelegate,
                                                     object[] parameters,
                                                     bool doValidation)
    {
      var billingGroupManager = _util.BillingGroupManager;

      // Create a materialization id
      materializationId =
        CreateMaterialization(MaterializationType.Full, out intervalId);

      var delegateParameters = new object[parameters.Length + 2];
      delegateParameters[0] = intervalId;
      delegateParameters[1] = materializationId;

      for (var i = 0; i < parameters.Length; i++)
      {
        delegateParameters[i + 2] = parameters[i];
      }

      var delegateCalled = false;
      if (callDelegateBeforeCreatingBillingGroups && utilDelegate != null)
      {
        for (var i = 0; i < numOfTimesToInvokeDelegate; i++)
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
        for (var i = 0; i < numOfTimesToInvokeDelegate; i++)
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
    ///   Return IBillingGroup's for the given interval
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    private static ArrayList GetBillingGroups(int intervalId)
    {
      IBillingGroupFilter filter = new BillingGroupFilter();
      filter.IntervalId = intervalId;

      return _util.BillingGroupManager.GetBillingGroups(filter);
    }

    /// <summary>
    ///   Return the billing group with the given billingGroupId
    ///   Return null if it is not found.
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <returns></returns>
    private static IBillingGroup GetBillingGroup(int billingGroupId)
    {
      IBillingGroup billingGroup = null;

      IBillingGroupFilter filter = new BillingGroupFilter();
      filter.BillingGroupId = billingGroupId;

      var billingGroups =
        _util.BillingGroupManager.GetBillingGroups(filter);

      if (billingGroups.Count == 1)
      {
        billingGroup = (IBillingGroup) billingGroups[0];
      }

      return billingGroup;
    }

    /// <summary>
    ///   Return the billing group with the given billingGroupName and
    ///   the given interval id
    ///   Return null if it is not found.
    /// </summary>
    /// <param name="billingGroupName"></param>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    private static IBillingGroup GetBillingGroup(string billingGroupName, int intervalId)
    {
      IBillingGroupFilter filter = new BillingGroupFilter();
      filter.IntervalId = intervalId;
      filter.BillingGroupName = billingGroupName;

      var billingGroups =
        _util.BillingGroupManager.GetBillingGroups(filter);

      Assert.AreEqual(1, billingGroups.Count);

      return (IBillingGroup) billingGroups[0];
    }


    private int GetPullListIntervalId()
    {
      return
        ((IBillingGroup) _billingGroupsForIntervalBeforePullListCreation[0]).IntervalID;
    }

    private int GetUserDefinedGroupIntervalId()
    {
      return
        ((IBillingGroup) _billingGroupsForIntervalBeforeUserDefinedGroupCreation[0]).IntervalID;
    }

    /// <summary>
    ///   Return true if the given billingGroupId exists
    ///   in billingGroups.
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <param name="billingGroups"></param>
    /// <returns></returns>
    private static bool CheckBillingGroupExists(int billingGroupId,
                                                IEnumerable billingGroups)
    {
      if (billingGroups == null) throw new ArgumentNullException("billingGroups");
      return billingGroups.Cast<IBillingGroup>().Any(billingGroup => billingGroup.BillingGroupID == billingGroupId);
    }

    /// <summary>
    ///   Return true if the given billingGroupName exists
    ///   in billingGroups.
    /// </summary>
    /// <param name="billingGroupName"></param>
    /// <param name="billingGroups"></param>
    /// <returns></returns>
    private static bool CheckBillingGroupExists(string billingGroupName,
                                                IEnumerable billingGroups)
    {
      if (billingGroups == null) throw new ArgumentNullException("billingGroups");
      return billingGroups.Cast<IBillingGroup>().Any(billingGroup => billingGroup.Name.Equals(billingGroupName));
    }

    /// <summary>
    ///   Create billing groups with the out-of-the-box assignment query
    ///   and soft close each of them
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="hardClosePreviousIntervals"></param>
    /// <returns></returns>
    private ArrayList CreateAndSoftCloseBillingGroups(out int intervalId,
                                                      bool hardClosePreviousIntervals)
    {
      // Get an interval for materialization
      intervalId = _util.GetIntervalForFullMaterialization();

      return CreateAndSoftCloseBillingGroups(intervalId, hardClosePreviousIntervals);
    }

    /// <summary>
    ///   Create billing groups with the out-of-the-box assignment query
    ///   and soft close each of them for the given interval id.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="hardClosePreviousIntervals"></param>
    /// <returns></returns>
    private ArrayList CreateAndSoftCloseBillingGroups(int intervalId,
                                                      bool hardClosePreviousIntervals)
    {
      var billingGroups = CreateBillingGroupsWithAssignmentQuery(intervalId);
      SoftCloseInterval(billingGroups);

      if (hardClosePreviousIntervals)
      {
        // Make sure that all previous intervals are hard closed
        _util.UpdatePreviousIntervalsToHardClosed(intervalId);
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
      // Get an interval for materialization
      intervalId = _util.GetIntervalForFullMaterialization();

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
      // Get the usage interval
      var usageInterval =
        _util.UsageIntervalManager.GetUsageInterval(intervalId);
      // Check that usage interval has not been materialized
      Assert.AreEqual(false, usageInterval.HasBeenMaterialized,
                      "Expected non-materialized interval");

      // Create billing groups using the default assignment query 
      _util.BillingGroupManager.MaterializeBillingGroups(intervalId, _util.UserId, false);

      // Get the billing groups
      var billingGroups = GetBillingGroups(intervalId);

      // Expect 3 rows
      Assert.AreEqual(Util.NumBillingGroups, billingGroups.Count,
                      "Number of billing groups mismatch");

      // Map billing group name <--> IBillingGroup
      var billingGroupsTable = new Hashtable();

      foreach (IBillingGroup billingGroup in billingGroups)
      {
        billingGroupsTable.Add(billingGroup.Name, billingGroup);
      }

      //Expect: 1) Billing group called 'North America'; 
      //        2) Billing group called 'South America'.
      //        3) Billing group called 'Europe'.

      CheckBillingGroups(billingGroupsTable);

      // Check that there are no unassigned accounts for the interval
      AssertNoUnassignedAccounts(intervalId);

      return billingGroups;
    }

    /// <summary>
    ///   Create accounts and return the usernames for the
    ///   accounts created
    /// </summary>
    /// <param name="numAccounts"></param>
    /// <param name="isPayer"></param>
    /// <param name="timeZoneId"></param>
    /// <param name="pricelist"></param>
    /// <returns></returns>
    private static ArrayList CreateAccounts(int numAccounts,
                                            bool isPayer,
                                            int timeZoneId = -1,
                                            string pricelist = null)
    {
      var accountIds = new ArrayList();

      for (var i = 0; i < numAccounts; i++)
      {
        accountIds.Add(_util.CreateAccount(_util.GetUserName(), isPayer, timeZoneId, pricelist));
      }

      // Make sure _util knows that extra accounts have been added
      if (isPayer)
      {
        _util.AddToUsAccountIds(accountIds);
        _util.AddToPayerAccountIds(accountIds);
      }
      else
      {
        _util.AddToPayeeAccountIds(accountIds);
      }

      Assert.AreEqual(numAccounts, accountIds.Count,
                      "Mismatch in the number of new accounts created");

      return accountIds;
    }

    // Check that there are no unassigned accounts (open and hard closed)
    // for this interval
    private static void AssertNoUnassignedAccounts(int intervalId)
    {
      var usageInterval =
        _util.UsageIntervalManager.GetUsageInterval(intervalId);

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
    private static void CheckAdapterInstances(ArrayList billingGroups,
                                              ArrayList recurringEventDataList)
    {
      foreach (IBillingGroup billingGroup in billingGroups)
      {
        CheckAdapterInstances(billingGroup.IntervalID,
                              billingGroup.BillingGroupID,
                              recurringEventDataList);
      }
    }

    /// <summary>
    ///   For each recurring event specified in recurringEventDataList
    ///   check that the expected status matches the status in the database.
    /// </summary>
    /// <param name="intervalId">will be ignored if it's -1</param>
    /// <param name="billingGroupId">will be ignored if it's -1</param>
    /// <param name="recurringEventDataList">Array of RecurringEventData items</param>
    private static void CheckAdapterInstances(int intervalId,
                                              int billingGroupId,
                                              ArrayList recurringEventDataList)
    {
      if (intervalId == -1 && billingGroupId == -1)
      {
        Assert.Fail("Must provide either intervalId or billingGroupId");
      }

      // Get the recurring event instances, this will contain
      // interval only adapters as well.
      var recurringEventInstances =
        GetRecurringEventInstances(intervalId, billingGroupId);

      var adapters = new Dictionary<int?, Dictionary<string, RecurringEventInstanceStatus>>();

      foreach (RecurringEventInstance recurringEventInstance in recurringEventInstances)
      {
        if (!adapters.ContainsKey(recurringEventInstance.IdBillgroup))
        {
          adapters.Add(recurringEventInstance.IdBillgroup, new Dictionary<string, RecurringEventInstanceStatus>());
        }

        // Store eventName <--> RecurringEventInstanceStatus from the db
        adapters[recurringEventInstance.IdBillgroup].Add(recurringEventInstance.EventName,
                                                         recurringEventInstance.RecurringEventInstanceStatus);
      }

      // Check that each of the recurring events in recurringEventDataList
      // are present in the database and that their statuses match
      foreach (RecurringEventData recurringEventData in recurringEventDataList)
      {
        var bFound = false;

        foreach (var kvp in adapters)
        {
          if (kvp.Value.ContainsKey(recurringEventData.RecurringEvent.Name))
          {
            bFound = true;

            Assert.AreEqual
              (recurringEventData.ExpectedStatus,
               kvp.Value[recurringEventData.RecurringEvent.Name],
               String.Format("Mismatched adapter status for event {0} in the interval {1} for billgroup {2}",
                             recurringEventData.RecurringEvent.Name,
                             intervalId,
                             kvp.Key));
          }
        }

        Assert.AreEqual(
          bFound,
          true,
          string.Format("Adapter status not found for event {0} in the interval {1}",
                        recurringEventData.RecurringEvent.Name
                        , intervalId));
      }
    }

    /// <summary>
    ///   Check that pull list has been created with the same set of adapters
    ///   as the original billing group.
    /// </summary>
    /// <param name="pullList"></param>
    /// <param name="parentBillingGroup"></param>
    private static void CheckAdapterInstancesForPullList(IBillingGroup pullList,
                                                         IBillingGroup parentBillingGroup)
    {
      // Get the instances for the pull list
      var pullListInstances = GetRecurringEventInstances(pullList);

      // Get the instances for the parent
      var parentInstances = GetRecurringEventInstances(parentBillingGroup);

      foreach (RecurringEventInstance recurringEventInstance in pullListInstances)
      {
        Assert.AreEqual(true, parentInstances.Contains(recurringEventInstance),
                        "Missing adapter instance from pull list");
      }
    }

    /// <summary>
    ///   Check that there are adapter instances for the given billingGroup
    ///   with the following properties:
    ///   1) There is a row for each adapter for which tx_type != 'Scheduled'
    ///   2) If the allRunSuccessfully flag is true then all adapters must
    ///   have a status of 'Succeeded'
    ///   3) If the allRunSuccessfully flag is false then the following must
    ///   be true:
    ///   - _StartRoot adapter instance has a tx_status of 'Succeeded'
    ///   - _EndRoot adapter instance has a tx_status of 'ReadyToRun'
    ///   - All other adapter instances have a tx_status of 'NotYetRun'
    /// </summary>
    /// <param name="aBillingGroup"></param>
    /// <param name="allRunSuccessfully"></param>
    private static void CheckAdapterInstances(IBillingGroup aBillingGroup,
                                              bool allRunSuccessfully)
    {
      // refresh the billing group
      var billingGroup = GetBillingGroup(aBillingGroup.BillingGroupID);

      // Get the instances for this billing group
      var recurringEventInstances = GetRecurringEventInstances(billingGroup);

      // Check that the roots exist
      // CheckRoots(recurringEventInstances, allRunSuccessfully);

      var totalAdapterCount = 0;
      var succeededAdapterCount = 0;
      var failedAdapterCount = 0;
      var notYetRunAdapterCount = 0;
      var failedAdapterInstances = new ArrayList();

      foreach (
        var recurringEventInstance in from RecurringEventInstance recurringEventInstance in recurringEventInstances
                                      where
                                        String.Compare(recurringEventInstance.EventType, Util.Root,
                                                       StringComparison.OrdinalIgnoreCase) != 0
                                        &&
                                        String.Compare(recurringEventInstance.EventType, Util.checkpoint,
                                                       StringComparison.OrdinalIgnoreCase) != 0
                                      where billingGroup.MaterializationType != MaterializationType.PullList ||
                                            recurringEventInstance.BillingGroupSupportType !=
                                            BillingGroupSupportType.BillingGroup
                                      select recurringEventInstance)
      {
        totalAdapterCount++;
        if (recurringEventInstance.RecurringEventInstanceStatus ==
            RecurringEventInstanceStatus.Succeeded)
        {
          succeededAdapterCount++;
        }

        if (recurringEventInstance.RecurringEventInstanceStatus ==
            RecurringEventInstanceStatus.Failed)
        {
          failedAdapterCount++;
          failedAdapterInstances.Add(recurringEventInstance);
        }
        if (recurringEventInstance.RecurringEventInstanceStatus ==
            RecurringEventInstanceStatus.NotYetRun)
        {
          notYetRunAdapterCount++;
        }
      }

      if (allRunSuccessfully)
      {
        if (failedAdapterInstances.Count > 0)
        {
          var errorMessage = new StringBuilder();
          foreach (RecurringEventInstance recurringEventInstance in failedAdapterInstances)
          {
            errorMessage.Append
              (String.Format("Adapter Instance '{0}:{1}' failed!\n",
                             recurringEventInstance.IdInstance,
                             recurringEventInstance.EventName));
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
    ///   Soft closes all the billing groups in the given interval.
    /// </summary>
    /// <param name="billingGroups"></param>
    private void SoftCloseInterval(ArrayList billingGroups)
    {
      foreach (IBillingGroup billingGroup in billingGroups)
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
      _util.BillingGroupManager.
            SoftCloseBillingGroup(billingGroupId);

      // Refresh billing group
      var billingGroup =
        GetBillingGroup(billingGroupId);

      Assert.AreEqual(BillingGroupStatus.SoftClosed,
                      billingGroup.Status,
                      "'SoftCloseBillingGroup' - Mismatch in billing group status");

      // Check adapter instances
      CheckAdapterInstances(billingGroup, false);
    }

    /// <summary>
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
                 Util.NumberOfSessions);
    }

    /// <summary>
    /// </summary>
    /// <param name="accountIds"></param>
    /// <param name="intervalId"></param>
    /// <param name="expectUsageInInterval"></param>
    /// <param name="dateTimeProperty"></param>
    /// <param name="serviceDef"></param>
    /// <param name="numberOfSessions"></param>
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
    ///   Meter usage (testservice) for each account in accountIds
    ///   and for the given intervalId.
    ///   The usage has a pipeline date (determines t_acc_usage.dt_session)
    ///   set to one day after the interval start date.
    ///   This ensures that the usage will fall in the interval specified.
    ///   If checkFailedTransactions is true
    ///   - we expect all the sessions metered to fail
    ///   - verify that the sessions have failed
    /// </summary>
    /// <param name="accountIds"></param>
    /// <param name="intervalId"></param>
    /// <param name="intervalIdSpecialProperty">
    ///   Metered as _IntervalID property.
    ///   Not used if it's -1.
    /// </param>
    /// <param name="checkFailedTransactions"></param>
    /// <param name="dateTimeProperty"></param>
    /// <param name="serviceDef"></param>
    /// <param name="numberOfSessions"></param>
    private static void MeterUsage(ArrayList accountIds, int intervalId, int intervalIdSpecialProperty,
                                   bool checkFailedTransactions, DateTime dateTimeProperty, string serviceDef,
                                   int numberOfSessions)
    {
      // Delete existing usage
      Util.DeleteUsage(accountIds, intervalId);

      IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();

        // Set the time for metering the account so that
        // it falls into the given intervalId
        var usageIntervalManager = new UsageIntervalManager();
        var usageInterval = usageIntervalManager.GetUsageInterval(intervalId);

        var pipelineDate = usageInterval.StartDate.AddDays(1);

        var batches = new ArrayList();
        IBatch batch = null;
        foreach (int accountId in accountIds)
        {
          var accountName = Util.GetAccountName(accountId);
          try
          {
            if (serviceDef == null)
            {
              batch = TestLibrary.CreateAndSubmitSessions(sdk, numberOfSessions,
                                                          pipelineDate, accountName,
                                                          intervalIdSpecialProperty,
                                                          dateTimeProperty);
            }
            else if (String.Compare(serviceDef, "metratech.com\testpi", StringComparison.OrdinalIgnoreCase) == 0)
            {
              batch =
                TestLibrary.CreateAndSubmitTestPISessions(sdk, numberOfSessions, accountName,
                                                          intervalIdSpecialProperty, dateTimeProperty);
            }
            if (batch != null)
            {
              var batchAccountData = new BatchAccountData {BatchUid = batch.UID, AccountId = accountId};
              batches.Add(batchAccountData);
            }
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
    }

    /// <summary>
    ///   Verify that each of the transactions identified by BatchAccountData
    ///   in batches have failed.
    /// </summary>
    /// <param name="batches">list of BatchAccountData items</param>
    /// <param name="payerAccountIds"></param>
    private static void VerifyFailedTransactions(ArrayList batches,
                                                 ArrayList payerAccountIds)
    {
      var commaSeparatedIds = Util.GetCommaSeparatedIds(payerAccountIds);

      // batchUid <--> batchUid
      var failedBatches = new Hashtable();
      // batchUid <--> ArrayList of account id's
      var failedBatchAccounts = new Hashtable();

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        // retrieves data from t_failed_transaction for each of the payerAccountIds
        using (var stmt =
          conn.CreatePreparedStatement(
            "SELECT id_PossiblePayerID, " +
            "       tx_Batch_Encoded " +
            "FROM t_failed_transaction " +
            "WHERE id_PossiblePayerID " +
            "IN ( " + commaSeparatedIds + " )"))
        {
          using (var reader = stmt.ExecuteReader())
          {
            while (reader.Read())
            {
              var payerId = reader.GetInt32(0);
              var batchUid = reader.GetString(1);

              // Store the failed batch uid's
              if (!failedBatches.ContainsKey(batchUid))
              {
                failedBatches.Add(batchUid, batchUid);
              }

              // Store the account id's for each failed batch uid
              var accounts = (ArrayList) failedBatchAccounts[batchUid];
              if (accounts == null)
              {
                accounts = new ArrayList {payerId};
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
      foreach (BatchAccountData batchAccountData in batches)
      {
        var failedBatchUid = (string) failedBatches[batchAccountData.BatchUid];
        Assert.AreEqual(batchAccountData.BatchUid,
                        failedBatchUid,
                        "Mismatch in batch UID!");
      }

      // Check that each batch has the right number of accounts
      foreach (ArrayList batchAccounts in failedBatchAccounts.Values)
      {
        Assert.AreEqual(Util.NumberOfSessions,
                        batchAccounts.Count,
                        "Mismatch in batch accounts!");
      }
    }

    /// <summary>
    ///   Verify that there is usage associated with each of
    ///   the accounts in the given accountIds and the given intervalId.
    ///   If 'exists' is false, then verify that there is no usage
    ///   for each of the account in the given accountIds and
    ///   the given intervalId.
    /// </summary>
    /// <param name="accountIds"></param>
    /// <param name="intervalId"></param>
    /// <param name="exists"></param>
    /// <param name="numberOfSessions"></param>
    private static void VerifyUsage(IEnumerable accountIds, int intervalId, bool exists,
                                    int numberOfSessions = Util.NumberOfSessions)
    {
      if (accountIds == null) throw new ArgumentNullException("accountIds");
      foreach (int accountId in accountIds)
      {
        Util.VerifyUsage(accountId, intervalId, exists, numberOfSessions);
      }
    }

    /// <summary>
    ///   Return an IMTCollection based on the id's passed in.
    /// </summary>
    /// <param name="ids"></param>
    /// <returns></returns>
    private static Coll.IMTCollection GetCollection(IEnumerable ids)
    {
      Coll.IMTCollection collection = new Coll.MTCollectionClass();
      foreach (int id in ids)
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
    private static void VerifyBillingGroupStatus(int intervalId, BillingGroupStatus status)
    {
      var billingGroups = GetBillingGroups(intervalId);
      foreach (IBillingGroup billingGroup in billingGroups)
      {
        Assert.AreEqual(status, billingGroup.Status,
                        "Mismatched billing group status");
      }
    }

    /// <summary>
    ///   Verify that the interval has the given status.
    ///   If the status is 'H', verify that all the billing groups
    ///   are hard closed and that all the unassigned accounts are
    ///   hard closed.
    /// </summary>
    /// <param name="status">one of 'O', 'H' or 'B'</param>
    /// <param name="intervalId" />
    private static void VerifyIntervalStatus(int intervalId, UsageIntervalStatus status)
    {
      if (status != UsageIntervalStatus.Open &&
          status != UsageIntervalStatus.HardClosed &&
          status != UsageIntervalStatus.Blocked)
      {
        Assert.Fail("Invalid interval status '{0}'", status);
      }

      var usageInterval = _util.UsageIntervalManager.GetUsageInterval(intervalId);

      Assert.IsNotNull(usageInterval,
                       String.Format("'VerifyIntervalStatus' - Unable to find IUsageInterval for interval '{0}'",
                                     intervalId));

      Assert.AreEqual(status, usageInterval.Status, "'VerifyIntervalStatus' - mismatched status!");

      // If the status is 'HardClosed', then ensure that all the billing groups
      // are hard closed and all unassigned accounts are hard closed.
      if (status == UsageIntervalStatus.HardClosed)
      {
        var billingGroups = GetBillingGroups(intervalId);
        foreach (IBillingGroup billingGroup in billingGroups)
        {
          Assert.AreEqual(BillingGroupStatus.HardClosed, billingGroup.Status,
                          "Mismatched billing group status");
        }

        CheckAllUnassignedAccountsStatus(intervalId,
                                         UnassignedAccountStatus.HardClosed);
      }
    }

    /// <summary>
    ///   Submit, execute/reverse, and check adapter status based on the data
    ///   specified in recurringEventDataList.
    ///   If billingGroupId is -1 it will not be used.
    ///   If intervalId is -1 it will not be used.
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <param name="intervalId"></param>
    /// <param name="recurringEventDataList"></param>
    /// <param name="ignoreDependencies"></param>
    private static void ExecuteAdapters(int intervalId,
                                        int billingGroupId,
                                        ArrayList recurringEventDataList,
                                        bool ignoreDependencies)
    {
      if (intervalId == -1 && billingGroupId == -1)
      {
        Assert.Fail("Must provide either intervalId or billingGroupId");
      }

      foreach (RecurringEventData recurringEventData in recurringEventDataList)
      {
        if (recurringEventData.Submit)
        {
          SubmitEvent(recurringEventData.RecurringEvent.Name,
                      intervalId,
                      billingGroupId,
                      recurringEventData.RecurringEvent.Type,
                      recurringEventData.Execute,
                      ignoreDependencies);
        }
      }


      int executions;
      int executionFailures;
      int reversals;
      int reversalFailures;

      // Process the events
      _util.Client.ProcessEvents(out executions, out executionFailures,
                                 out reversals, out reversalFailures);

      // Check that the adapters have the expected status
      CheckAdapterInstances(intervalId, billingGroupId, recurringEventDataList);
    }

    /// <summary>
    ///   Execute/Reverse the given adapter. Check that after execution/reversal
    ///   the status of the adapter matches expectedStatus
    /// </summary>
    private static void ExecuteAdapter(int intervalId,
                                       int billingGroupId,
                                       string adapterClassName,
                                       bool execute,
                                       bool ignoreDependencies,
                                       RecurringEventInstanceStatus expectedStatus)
    {
      // Create RecurringEventData
      var recurringEventData = new RecurringEventData
        {
          RecurringEvent = _util.GetRecurringEventFromClassNameAndProgId(adapterClassName),
          Submit = true,
          Execute = execute,
          ExpectedStatus = expectedStatus
        };

      var recurringEventDataList = new ArrayList {recurringEventData};
      ExecuteAdapters(intervalId, billingGroupId, recurringEventDataList, ignoreDependencies);
    }

    /// <summary>
    ///   Execute all the adapters for the given billingGroup and
    ///   check that they have all succeeded.
    /// </summary>
    /// <param name="billingGroup"></param>
    private static void ExecuteAdapters(IBillingGroup billingGroup)
    {
      // Submit the EndOfPeriod instances for execution
      SubmitEvents(billingGroup.BillingGroupID,
                   billingGroup.IntervalID,
                   new[] {RecurringEventInstanceStatus.NotYetRun},
                   RecurringEventType.EndOfPeriod,
                   true);

      // Submit the Checkpoint instances for execution
      SubmitEvents(billingGroup.BillingGroupID,
                   billingGroup.IntervalID,
                   new[] {RecurringEventInstanceStatus.NotYetRun},
                   RecurringEventType.Checkpoint,
                   true);

      int executions;
      int executionFailures;
      int reversals;
      int reversalFailures;

      _util.Client.ProcessEvents(out executions, out executionFailures,
                                 out reversals, out reversalFailures);

      // Check that all the adapter instances have been run successfully
      CheckAdapterInstances(billingGroup, true);
    }

    /// <summary>
    ///   Once for each interval
    /// </summary>
    private static void ExecuteScheduledEvents(int intervalId)
    {
      IRecurringEventInstanceFilter filter = new RecurringEventInstanceFilter();
      filter.UsageIntervalID = intervalId;
      filter.AddEventTypeCriteria(RecurringEventType.Scheduled);

      // applies the instance filter
      filter.Apply();

      // Submit
      foreach (int instanceId in filter)
      {
        _util.Client.SubmitEventForExecution(instanceId, AdapterComment);
      }

      int executions;
      int executionFailures;
      int reversals;
      int reversalFailures;

      _util.Client.ProcessEvents(out executions, out executionFailures,
                                 out reversals, out reversalFailures);

      var scheduledInstances = GetScheduledRecurringEventInstance();

      foreach (RecurringEventInstance recurringEventInstance in scheduledInstances)
      {
        Assert.AreNotEqual(RecurringEventInstanceStatus.Failed,
                           recurringEventInstance.RecurringEventInstanceStatus,
                           String.Format("Scheduled adapter instance '{0}:{1}' failed!",
                                         recurringEventInstance.IdInstance,
                                         recurringEventInstance.EventName));
      }
    }

    /// <summary>
    ///   Submit the given event for the given intervalId for execution or reversal
    ///   based on isExecution.
    ///   If intervalId is -1 it will not be used.
    ///   If billingGroupId is -1 it will not be used.
    /// </summary>
    /// <param name="eventName"></param>
    /// <param name="intervalId"></param>
    /// <param name="billingGroupId"></param>
    /// <param name="recurringEventType"></param>
    /// <param name="isExecution"></param>
    /// <param name="ignoreDependencies"></param>
    private static void SubmitEvent(string eventName,
                                    int intervalId,
                                    int billingGroupId,
                                    RecurringEventType recurringEventType,
                                    bool isExecution,
                                    bool ignoreDependencies)
    {
      // Retrieve the adapter instance id's for this billing group
      var filter = new RecurringEventInstanceFilter {EventName = eventName};
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
      foreach (int instanceId in filter)
      {
        if (isExecution)
        {
          _util.Client.
                SubmitEventForExecution(instanceId, ignoreDependencies, AdapterComment);
        }
        else
        {
          _util.Client.
                SubmitEventForReversal(instanceId, ignoreDependencies, AdapterComment);
        }
      }
    }

    /// <summary>
    ///   Submit instances for the given billingGroup
    ///   - Checkpoints if isCheckpoint is true otherwise
    ///   EndOfPeriod's and Scheduled
    ///   - execution if isExecution is true otherwise reversal
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <param name="intervalId"></param>
    /// <param name="statuses"></param>
    /// <param name="eventType"></param>
    /// <param name="isExecution"></param>
    private static void SubmitEvents(int billingGroupId,
                                     int intervalId,
                                     IEnumerable<RecurringEventInstanceStatus> statuses,
                                     RecurringEventType eventType,
                                     bool isExecution)
    {
      // Retrieve the adapter instance id's for this billing group
      var filter = new RecurringEventInstanceFilter();

      if (billingGroupId != -1)
      {
        filter.BillingGroupID = billingGroupId;
      }

      if (intervalId != -1)
      {
        filter.UsageIntervalID = intervalId;
      }

      var ignoreDependencies = false;

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
            Assert.Fail("Incorrect RecurringEventType specified - {0}", eventType.ToString());
            break;
          }
      }

      // Set the status
      if (statuses != null)
      {
        foreach (var status in statuses)
        {
          filter.AddStatusCriteria(status);
        }
      }

      // applies the instance filter
      filter.Apply();

      // Submit
      foreach (int instanceId in filter)
      {
        if (isExecution)
        {
          _util.Client.SubmitEventForExecution(instanceId, ignoreDependencies, AdapterComment);
        }
        else
        {
          _util.Client.SubmitEventForReversal(instanceId, ignoreDependencies, AdapterComment);
        }
      }
    }

    /// <summary>
    ///   Return a rowset containing the recurring event instances for the given
    ///   billing group.
    /// </summary>
    /// <param name="billingGroup"></param>
    /// <returns></returns>
    private static ArrayList GetRecurringEventInstances(IBillingGroup billingGroup)
    {
      return GetRecurringEventInstances(billingGroup.IntervalID, billingGroup.BillingGroupID);
    }

    /// <summary>
    ///   Get the list of scheduled recurring event instances.
    /// </summary>
    /// <returns></returns>
    private static ArrayList GetScheduledRecurringEventInstance()
    {
      var recurringEventInstances = new ArrayList();

      IRecurringEventInstanceFilter recurringEventInstanceFilter =
        new RecurringEventInstanceFilter();

      var rowset =
        recurringEventInstanceFilter.GetScheduledRowset();

      while (!Convert.ToBoolean(rowset.EOF))
      {
        var recurringEventInstance = new RecurringEventInstance
          {
            IdInstance = (int) rowset.Value["InstanceID"],
            IdEvent = (int) rowset.Value["EventID"],
            EventName = (string) rowset.Value["EventName"],
            EventType = (string) rowset.Value["EventType"],
            RecurringEventInstanceStatus = (RecurringEventInstanceStatus)
                                           Enum.Parse(typeof (RecurringEventInstanceStatus),
                                                      (string) rowset.Value["Status"])
          };

        if (rowset.Value["LastRunStatus"] != DBNull.Value)
        {
          recurringEventInstance.LastRunStatus =
            (string) rowset.Value["LastRunStatus"];
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
    ///   Illegal to pass -1 for both intervalId and billingGroupId.
    /// </summary>
    /// <returns></returns>
    private static ArrayList GetRecurringEventInstances(int intervalId, int billingGroupId)
    {
      if (intervalId == -1 && billingGroupId == -1)
      {
        Assert.Fail("Must provide either billingGroupId or intervalId");
      }

      var recurringEventInstances = new ArrayList();

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

      var rowset =
        recurringEventInstanceFilter.GetEndOfPeriodRowset(true, true, true);

      while (!Convert.ToBoolean(rowset.EOF))
      {
        // Get the billing group support type
        var billingGroupSupportType =
          (BillingGroupSupportType)
          Enum.Parse(typeof (BillingGroupSupportType),
                     (string) rowset.Value["BillGroupSupportType"]);

        // If this is a search for Interval adapters (ie. billingGroupId = -1)
        // then ignore the non-interval adapters.
        if (billingGroupSupportType != BillingGroupSupportType.Interval &&
            billingGroupId == -1)
        {
          // next row
          rowset.MoveNext();
          continue;
        }

        var recurringEventInstance = new RecurringEventInstance
          {
            IdInstance = (int) rowset.Value["InstanceID"],
            IdEvent = (int) rowset.Value["EventID"],
            EventName = (string) rowset.Value["EventName"],
            EventType = (string) rowset.Value["EventType"],
            IdInterval = (int) rowset.Value["ArgIntervalID"]
          };
        var id_billgroup = rowset.Value["BillGroupID"];
        if (id_billgroup.GetType() != typeof (DBNull))
        {
          recurringEventInstance.IdBillgroup = (int) id_billgroup;
        }
        else
        {
          recurringEventInstance.IdBillgroup = -1;
        }

        recurringEventInstance.RecurringEventInstanceStatus =
          (RecurringEventInstanceStatus)
          Enum.Parse(typeof (RecurringEventInstanceStatus),
                     (string) rowset.Value["Status"]);

        if (rowset.Value["LastRunStatus"] != DBNull.Value)
        {
          recurringEventInstance.LastRunStatus =
            (string) rowset.Value["LastRunStatus"];
        }

        // Set the billing group support type
        recurringEventInstance.BillingGroupSupportType = billingGroupSupportType;

        recurringEventInstances.Add(recurringEventInstance);
        rowset.MoveNext();
      }

      return recurringEventInstances;
    }

    /// <summary>
    ///   Check that all unassigned accounts for the given interval have
    ///   the given status
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="status"></param>
    private static void CheckAllUnassignedAccountsStatus(int intervalId, UnassignedAccountStatus status)
    {
      // Get the count of all unassigned accounts
      IUnassignedAccountsFilter filter = new UnassignedAccountsFilter();
      filter.IntervalId = intervalId;
      filter.Status = UnassignedAccountStatus.All;

      var rowset = _util.BillingGroupManager.GetUnassignedAccountsForIntervalAsRowset(filter);

      var totalUnassignedAccounts = rowset.RecordCount;

      // Get the count of unassigned accounts with the given status
      filter.ClearCriteria();
      filter.IntervalId = intervalId;
      filter.Status = status;

      rowset = _util.BillingGroupManager.GetUnassignedAccountsForIntervalAsRowset(filter);

      var unassignedAccounts = rowset.RecordCount;

      Assert.AreEqual(totalUnassignedAccounts, unassignedAccounts,
                      String.Format("Mismatched unassigned accounts with '{0}'",
                                    status.ToString()));
    }

    /// <summary>
    ///   Create and return a pull list with the given name
    ///   based on the given parentBillingGroup.
    ///   If pullListMembers is non-null, then it will be used.
    ///   Else
    ///   If pullOneAccount is true then only one account will be pulled out
    ///   of the parentBillingGroup otherwise all but one of the accounts
    ///   will be pulled out of the parentBillingGroup.
    /// </summary>
    /// <param name="parentBillingGroup"></param>
    /// <param name="pullListName"></param>
    /// <param name="accountsForPullList"></param>
    /// <param name="pullOneAccount"></param>
    /// <returns></returns>
    private static IBillingGroup CreatePullList(IBillingGroup parentBillingGroup,
                                                string pullListName,
                                                ArrayList accountsForPullList,
                                                bool pullOneAccount)
    {
      // Get the members of the billing group
      var parentMembers =
        _util.BillingGroupManager.
              GetBillingGroupMembers(parentBillingGroup.BillingGroupID);

      ArrayList pullListMembers;

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

      var pullListAccounts = Util.GetCommaSeparatedIds(pullListMembers);

      bool needsExtraAccounts;
      const string pullListDescription = "Testing billing groups";

      // Start creating a pull list
      var materializationId =
        _util.BillingGroupManager.
              StartChildGroupCreationFromAccounts(pullListName,
                                                  pullListDescription,
                                                  parentBillingGroup.BillingGroupID,
                                                  pullListAccounts,
                                                  out needsExtraAccounts,
                                                  _util.UserId);

      // Get the extra accounts which may have been added to satisfy constraints
      var rowset =
        _util.BillingGroupManager.GetNecessaryChildGroupAccounts(materializationId);
      Assert.IsTrue(rowset.RecordCount == 0,
                    "Expected 0 accounts from 'GetNecessaryChildGroupAccounts'");

      // Complete pull list creation
      _util.BillingGroupManager.FinishChildGroupCreation(materializationId);

      // Check that new pull list exists
      rowset =
        _util.BillingGroupManager.
              GetDescendantBillingGroupsRowset(parentBillingGroup.BillingGroupID);

      var foundPullList = false;
      var pullListId = 0;
      while (!Convert.ToBoolean(rowset.EOF))
      {
        var dbPullListName = (string) rowset.Value["Name"];
        var dbPullListDescription = (string) rowset.Value["Description"];
        pullListId = (int) rowset.Value["BillingGroupID"];

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
      var pullList = GetBillingGroup(pullListId);
      CheckAdapterInstancesForPullList(pullList, parentBillingGroup);

      return pullList;
    }

    /// <summary>
    ///   1) Setup an adapter chain of the following type:
    ///   - Adapter A (Account or BillingGroup)
    ///   - Adapter B (Interval)
    ///   - HardCloseCheckpoint HCC
    ///   (B) is dependent on (A).
    ///   (HCC) is dependent on (B) and (A).
    ///   2) Get an interval with 3 billing groups (BG1, BG2, BG3).
    ///   3) Soft close each billing group.
    ///   Creates the following adapter instances:
    ///   BG1-A,
    ///   BG1-HCC,
    ///   BG2-A,
    ///   BG2-HCC,
    ///   BG3-A,
    ///   BG3-HCC
    ///   B - associated with the interval and not any billing group.
    ///   4) Execute adapters for BG1
    ///   BG1-A should be 'Succeeded'
    ///   5) Execute B - should be 'ReadyToRun'
    ///   6) Execute adapters for BG2
    ///   BG2-A should be 'Succeeded'
    ///   7) Execute B - should be 'ReadyToRun'
    ///   8) Execute adapters for BG3
    ///   BG3-A should be 'Succeeded'
    ///   B should be 'Succeeded' because its dependencies have been satisfied
    ///   9) If [hardCloseInterval] is true:
    ///   - Submit BG1-HCC, BG2-HCC, BG3-HCC
    ///   - Verify that the interval is hard closed. This will also verify that
    ///   the billing groups are hard closed.
    ///   Else
    ///   - Verify that the interval is open.
    ///   - Verify that the billing groups are soft closed.
    /// </summary>
    /// <param name="fileName"></param>
    /// <param name="hardCloseInterval"></param>
    /// <returns>interval Id</returns>
    private int TestIntervalAdapterExecutionInternal(string fileName,
                                                     bool hardCloseInterval)
    {
      // Prepare t_recevent
      _util.SetupAdapterDependencies(Util.TestDir + fileName);

      // Create and soft close billing groups
      int intervalId;
      var billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);
      var lastBillingGroup = false;

      // Execute the appropriate recurring events and check their status
      for (var i = 0; i < billingGroups.Count; i++)
      {
        var billingGroup = (IBillingGroup) billingGroups[i];

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
    ///   1) Run TestIntervalAdapterExecutionInternal
    ///   2) Attempt to reverse the Account/BillingGroup adapters for each billing group.
    ///   This should not succeed because the interval adapter has
    ///   not been reversed.
    ///   Check that the status of the Account/BillingGroup adapters are ReadyToReverse.
    ///   3) Reverse the interval adapter. This should succeed.
    ///   Check that the status of the interval adapter is NotYetRun.
    ///   This should cause the Account/BillingGroup adapters to be reversed as well.
    ///   4) Check the status of the Account/BillingGroup adapters are NotYetRun
    /// </summary>
    /// <returns>interval id</returns>
    private void TestIntervalAdapterReversalInternal(string fileName)
    {
      // Execute the adapters first
      var intervalId = TestIntervalAdapterExecutionInternal(fileName, false);

      // Get the billing groups for the interval
      var billingGroups = GetBillingGroups(intervalId);

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
    }

    /// <summary>
    ///   1) Setup an adapter chain of the following type:
    ///   - Adapter A (Interval)
    ///   - Adapter B (Interval)
    ///   - HardCloseCheckpoint HCC
    ///   (B) is dependent on (A).
    ///   (HCC) is dependent on (B) and (A).
    ///   2) Get an interval with 3 billing groups (BG1, BG2, BG3).
    ///   3) Soft close each billing group.
    ///   Creates the following adapter instances:
    ///   BG1-HCC,
    ///   BG2-HCC,
    ///   BG3-HCC,
    ///   A - associated with the interval and not any billing group.
    ///   B - associated with the interval and not any billing group.
    ///   4) Execute B - should be 'ReadyToRun'
    ///   5) Execute A - should be 'Succeeded'.
    ///   This should cause B to become 'Succeeded'.
    ///   6) If [hardCloseInterval] is true:
    ///   - Submit BG1-HCC, BG2-HCC, BG3-HCC
    ///   - Verify that the interval is hard closed. This will also verify that
    ///   the billing groups are hard closed.
    ///   Else
    ///   - Verify that the interval is open.
    ///   - Verify that the billing groups are soft closed.
    /// </summary>
    /// <param name="fileName"></param>
    /// <param name="hardCloseInterval"></param>
    /// <returns>interval id</returns>
    private int TestIntervalIntervalExecutionInternal(string fileName, bool hardCloseInterval)
    {
      // Prepare t_recevent
      _util.SetupAdapterDependencies(Util.TestDir + fileName);

      // Create and soft close billing groups
      int intervalId;
      var billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);

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
    ///   1) Run TestIntervalIntervalExecutionInternal
    ///   2) Reverse A. Should not succeed. Expect 'ReadyToReverse'.
    ///   3) Reverse B. Should succeed. Expect 'NotYetRun'.
    ///   Also A should be reversed. Expect 'NotYetRun'.
    /// </summary>
    /// <returns>interval id</returns>
    private void TestIntervalIntervalReversalInternal(string fileName)
    {
      // Execute the adapters first
      var intervalId = TestIntervalIntervalExecutionInternal(fileName, false);

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
    }

    /// <summary>
    ///   1) Setup an adapter chain of the following type:
    ///   - Adapter A (Account)
    ///   - Adapter B (BillingGroup)
    ///   - HardCloseCheckpoint HCC
    ///   (B) is dependent on (A).
    ///   (HCC) is dependent on (B) and (A).
    ///   2) Get an interval with 3 billing groups (BG1, BG2, BG3).
    ///   3) Soft close each billing group.
    ///   Creates the following adapter instances:
    ///   BG1-A,
    ///   BG1-B,
    ///   BG1-HCC,
    ///   BG2-A,
    ///   BG2-B,
    ///   BG2-HCC,
    ///   BG3-A,
    ///   BG3-B,
    ///   BG3-HCC
    ///   4) Execute BG1-B. Should not succeed. Expect 'ReadyToRun'.
    ///   5) Execute BG2-B. Should not succeed. Expect 'ReadyToRun'.
    ///   6) Execute BG3-B. Should not succeed. Expect 'ReadyToRun'.
    ///   5) Execute BG1-A. Should succeed. Expect 'Succeeded'.
    ///   BG1-B should succeed as well. Expect 'Succeeded'.
    ///   6) Execute BG2-A. Should succeed. Expect 'Succeeded'.
    ///   BG2-B should succeed as well. Expect 'Succeeded'.
    ///   7) Execute BG3-A. Should succeed. Expect 'Succeeded'.
    ///   BG3-B should succeed as well. Expect 'Succeeded'.
    ///   8) If [hardCloseInterval] is true:
    ///   - Submit BG1-HCC, BG2-HCC, BG3-HCC
    ///   - Verify that the interval is hard closed. This will also verify that
    ///   the billing groups are hard closed.
    ///   Else
    ///   - Verify that the interval is open.
    ///   - Verify that the billing groups are soft closed.
    /// </summary>
    /// <returns>interval Id</returns>
    private int TestBillingGroupAdapterExecutionInternal(string fileName,
                                                         bool hardCloseInterval)
    {
      int intervalId;

      // Prepare t_recevent= 0
      _util.SetupAdapterDependencies(Util.TestDir + fileName);

      // Create and soft close billing groups
      var billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);

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
    ///   1) Run TestBillingGroupAdapterExecutionInternal
    ///   2) Reverse A for each billing group. Should not succeed. Expect 'ReadyToReverse'.
    ///   3) Reverse B for each billing group. Should succeed. Expect 'NotYetRun'.
    ///   The A's for each billing group should also succeed. Expect 'NotYetRun'.
    /// </summary>
    /// <returns></returns>
    private void TestBillingGroupAdapterReversalInternal(string fileName)
    {
      // Execute the adapters first
      var intervalId = TestBillingGroupAdapterExecutionInternal(fileName, false);

      // Get the billing groups for the interval
      var billingGroups = GetBillingGroups(intervalId);

      // Reverse A for each billing group. Should not succeed. Expect 'ReadyToReverse'.
      ExecuteAdapters(billingGroups,
                      BillingGroupReversalData.GetDataExpectingReadyToReverse());

      // Reverse B for each billing group. Should succeed. Expect 'NotYetRun'.
      // The A's for each billing group should also succeed. Expect 'NotYetRun'.
      ExecuteAdapters(billingGroups,
                      BillingGroupReversalData.GetDataExpectingNotYetRun());
    }

    /// <summary>
    ///   1) Setup an adapter chain of the following type:
    ///   - Adapter A (Interval)
    ///   - Adapter B (BillingGroup)
    ///   - HardCloseCheckpoint HCC
    ///   (B) is dependent on (A).
    ///   (HCC) is dependent on (B) and (A).
    ///   2) Get an interval with 3 billing groups (BG1, BG2, BG3).
    ///   3) Soft close each billing group.
    ///   Creates the following adapter instances:
    ///   BG1-B,
    ///   BG1-HCC,
    ///   BG2-B,
    ///   BG2-HCC,
    ///   BG3-B,
    ///   BG3-HCC
    ///   A - associated with the interval and not any billing group.
    ///   4) Execute BG1-B. Should not succeed. Expect 'ReadyToRun'.
    ///   5) Execute BG2-B. Should not succeed. Expect 'ReadyToRun'.
    ///   6) Execute BG3-B. Should not succeed. Expect 'ReadyToRun'.
    ///   5) Execute A. Should succeed. Expect 'Succeeded'.
    ///   BG1-B should succeed as well. Expect 'Succeeded'.
    ///   BG2-B should succeed as well. Expect 'Succeeded'.
    ///   BG3-B should succeed as well. Expect 'Succeeded'.
    ///   8) If [hardCloseInterval] is true:
    ///   - Submit BG1-HCC, BG2-HCC, BG3-HCC
    ///   - Verify that the interval is hard closed. This will also verify that
    ///   the billing groups are hard closed.
    ///   Else
    ///   - Verify that the interval is open.
    ///   - Verify that the billing groups are soft closed.
    /// </summary>
    /// <param name="fileName"></param>
    /// <param name="hardCloseInterval"></param>
    /// <returns>interval Id</returns>
    private int TestBillingGroupIntervalExecutionInternal(string fileName,
                                                          bool hardCloseInterval)
    {
      // Prepare t_recevent
      _util.SetupAdapterDependencies(Util.TestDir + fileName);

      // Create and soft close billing groups
      int intervalId;
      var billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);

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
    ///   1) Run TestBillingGroupIntervalExecutionInternal
    ///   2) Reverse A. Should not succeed. Expect 'ReadyToReverse'.
    ///   3) Reverse B for all billing groups. Should succeed. Expect 'NotYetRun'.
    ///   A should also succeed. Expect 'NotYetRun'.
    /// </summary>
    /// <returns>interval id</returns>
    private void TestBillingGroupIntervalReversalInternal(string fileName)
    {
      // Execute the adapters first
      var intervalId = TestBillingGroupIntervalExecutionInternal(fileName, false);

      // Get the billing groups for the interval
      var billingGroups = GetBillingGroups(intervalId);

      // Reverse A. Should not succeed. Expect 'ReadyToReverse'.
      ExecuteAdapters(intervalId, -1,
                      BillingGroupIntervalReversalData.GetIntervalDataExpectingReadyToReverse(),
                      false);

      var lastBillingGroup = false;

      // Execute the B for each billing group. A should become NotYetRun
      // only when B for the last billing group has been reversed.
      for (var i = 0; i < billingGroups.Count; i++)
      {
        var billingGroup = (IBillingGroup) billingGroups[i];

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
      foreach (IBillingGroup billingGroup in billingGroups)
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
    /// <param name="billingGroups"></param>
    /// <param name="hardCloseInterval"></param>
    private static void CompleteProcessing(ArrayList billingGroups, bool hardCloseInterval)
    {
      var intervalId = ((IBillingGroup) billingGroups[0]).IntervalID;
      if (hardCloseInterval)
      {
        foreach (IBillingGroup billingGroup in billingGroups)
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
    ///   Backout usage associated with the given interval and the given accounts.
    ///   If the resubmit flag is true, usage will be resubmitted otherwise it
    ///   will be deleted.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="accountIds"></param>
    /// <param name="resubmit"></param>
    private static void BackoutUsage(int intervalId, ArrayList accountIds, bool resubmit)
    {
      IBillingGroupWriter billingGroupWriter = new BillingGroupWriter();

      var commaSeparatedAccounts = Util.GetCommaSeparatedIds(accountIds);

      billingGroupWriter.
        BackoutUsage(_util.BillingGroupManager,
                     intervalId,
                     commaSeparatedAccounts,
                     _util.SessionContext,
                     false,
                     resubmit);
    }

    /// <summary>
    ///   1) Create billing groups
    ///   2) Pick one billing group (BG1) for testing.
    ///   3) Meter usage to accounts for BG1 with the time associated
    ///   with the current interval.
    ///   4) Soft close billing group.
    ///   5) If hardCloseBillingGroup is true, hard close the billing group
    ///   6) Attempt to backout usage
    ///   5) Verify that the usage got backed out if hardCloseBillingGroup is false
    ///   Verify that the usage did not get backed out if hardCloseBillingGroup is true
    /// </summary>
    /// <param name="hardCloseBillingGroup"></param>
    private void TestBackout(bool hardCloseBillingGroup)
    {
      // Create billing groups for a non-materialized interval 
      int intervalId;
      var billingGroups =
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Pick the first billing group 
      var billingGroup = (IBillingGroup) billingGroups[0];
      var accounts = _util.BillingGroupManager.GetBillingGroupMembers(billingGroup.BillingGroupID);

      // Meter usage to the billing group accounts with the time associated
      // with the current interval and verify that the usage did land
      // in the given interval
      MeterUsage(accounts, intervalId, true);

      // Soft close the billing group
      SoftCloseBillingGroup(billingGroup.BillingGroupID);

      var usageExists = false;
      if (hardCloseBillingGroup)
      {
        // Hard close the billing group
        _util.BillingGroupManager.HardCloseBillingGroup(billingGroup.BillingGroupID);
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
    /// <param name="exists"></param>
    private static void CheckInvoices(int intervalId, ArrayList accounts, bool exists)
    {
      var commaSeparatedAccounts =
        Util.GetCommaSeparatedIds(accounts);

      // Get the account id's for the given interval and given accounts
      var query =
        String.Format("Select id_acc as accountid from t_invoice " +
                      "where id_interval = '{0}' and id_acc in ({1})",
                      intervalId, commaSeparatedAccounts);

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (var stmt = conn.CreateStatement(query))
        {
          using (var reader = stmt.ExecuteReader())
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
                Assert.Fail("Invoices found for interval and accounts where none were expected");
              }
            }
          }
        }
      }
    }

    /// <summary>
    ///   Preconditions:
    ///   1) The product offering 'Calendar_CL_PO' has been created by running:
    ///   pcimportexport -ipo -file "T:\QA\FunctionalTests\Usage\USAGE_CALENDAR\xml\CALENDAR_CodeLookUp_PO.xml" -username "su" -password "su123"
    ///   2) The pricelist 'Calendar_CL_PL' corresponding to 'Calendar_CL_PO' exists.
    ///   3) 'Calendar_CL_PO' has the following calendar codes (peak, off-peak ...):
    ///   12:00 AM - 03:14:59 AM = Off-peak
    ///   03:15 AM - 05:44:59 AM = Holiday
    ///   05:45 AM - 07:59:59 AM = Off-peak
    ///   08:00 AM - 07:59:59 PM = Peak
    ///   08:00 PM - 08:59:59 PM = Off-peak
    ///   09:00 PM - 11:29:59 PM = Weekend
    ///   11:30 PM - 11:59:59 PM = Off-peak
    ///   Test:
    ///   1) Clear t_pv_testpi for the given interval.
    ///   2) Create an account with the given globalTimeZoneId (from Global.xml)and
    ///   and the given pricelist name ('Calendar_CL_PL').
    ///   3) Meter one testpi session for the account with the given gmtTime
    ///   and the given intervalId.
    ///   4) Check that there is one data row in t_pv_testpi for the given interval
    ///   - Check that it has the given enumDataTimeZoneId
    ///   - Check that it has the given expectedCalendarCode
    /// </summary>
    /// <param name="timeZoneTestData"></param>
    private bool TestCalendarCodeForTimeZone(TimeZoneTestData timeZoneTestData)
    {
      // Clear t_pv_testpi for the given interval
      _util.DeleteTestPi();

      // Create an account
      var accountIds =
        CreateAccounts(1,
                       true,
                       timeZoneTestData.MetraTechTimeZoneId,
                       timeZoneTestData.PriceListName);

      // Meter usage
      MeterUsage(accountIds,
                 timeZoneTestData.IntervalId,
                 false,
                 timeZoneTestData.GmtTime,
                 "metratech.com\testpi",
                 1);

      // Check t_pv_testpi
      return
        _util.CheckPvTestPi(timeZoneTestData.EnumDataTimeZoneId,
                            timeZoneTestData.CalendarCode);
      //     String.Format("Could not find time zone '{0}' and " +
      //                   "calendar code '{1}'", globalTimeZoneId, expectedCalendarCode.ToString());
    }

    /// <summary>
    ///   Return a list of TimeZoneTestData objects based on the given timeZone.
    ///   Each object specifies a time data field and the
    ///   expected calendar code (Peak, Off-peak ...)
    ///   'Calendar_CL_PO' has the following calendar codes (peak, off-peak ...):
    ///   12:00 AM - 03:14:59 AM = Off-peak
    ///   03:15 AM - 05:44:59 AM = Holiday
    ///   05:45 AM - 07:59:59 AM = Off-peak
    ///   08:00 AM - 07:59:59 PM = Peak
    ///   08:00 PM - 08:59:59 PM = Off-peak
    ///   09:00 PM - 11:29:59 PM = Weekend
    ///   11:30 PM - 11:59:59 PM = Off-peak
    /// </summary>
    /// <returns></returns>
    private ArrayList GetTimeZoneTestData
      (CalendarTimeZoneData.CalendarCodeDataTable calendarCodeData,
       string windowsTimeZoneName,
       int metraTechTimeZoneId,
       bool useWindowsTimeZone)
    {
      var timeZoneTestDataList = new ArrayList();

      foreach (CalendarTimeZoneData.CalendarCodeRow calendarCodeRow in 
        calendarCodeData.Rows)
      {
        foreach (var timeSpanRow in
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
    /// <returns></returns>
    private static TimeZoneTestData GetTimeZoneTestData
      (CalendarTimeZoneData.TimeSpanRow timeSpanRow,
       CalendarTimeZoneData.CalendarCodeRow calendarCodeRow,
       string windowsTimeZoneName,
       int metraTechTimeZoneId,
       bool useWindowsTimeZone,
       bool getStart)
    {
      // Create a TimeZoneTestData for the start time
      var timeZoneTestData = new TimeZoneTestData {WindowsTimeZoneName = windowsTimeZoneName};

      // Retrieve the hours, minutes and seconds
      var year = DateTime.Now.Year;
      var month = DateTime.Now.Month;
      var day = DateTime.Now.Day;

      int hour;
      int minute;
      int second;

      if (getStart)
      {
        hour =
          Convert.ToInt32(
            (timeSpanRow.GetStartRows()[0]).hour);
        minute =
          Convert.ToInt32(
            (timeSpanRow.GetStartRows()[0]).minute);
        second =
          Convert.ToInt32(
            (timeSpanRow.GetStartRows()[0]).second);
      }
      else
      {
        hour =
          Convert.ToInt32(
            (timeSpanRow.GetEndRows()[0]).hour);
        minute =
          Convert.ToInt32(
            (timeSpanRow.GetEndRows()[0]).minute);
        second =
          Convert.ToInt32(
            (timeSpanRow.GetEndRows()[0]).second);
      }

      // Calculate GMT based on the time zone passed in
      var testDate = new DateTime(year, month, day, hour, minute, second);

      if (useWindowsTimeZone)
      {
        // Use the Windows Time Zone information to convert to GMT
        timeZoneTestData.GmtTime =
          TimeZoneInformation.ToUniversalTime(windowsTimeZoneName, testDate);
      }
      else
      {
        const string dateFormat = "yyyy-MM-ddTHH:mm:ssZ";

        IMTUserCalendar calendar = new MTUserCalendarClass();
        timeZoneTestData.GmtTime =
          DateTime.FromOADate(
            (double) calendar.LocalTimeToGMT(testDate.ToString(dateFormat),
                                             metraTechTimeZoneId));
      }

      // Set the calendar code enum
      timeZoneTestData.CalendarCode =
        (CalendarCodeEnum) Enum.Parse(typeof (CalendarCodeEnum), calendarCodeRow.name);

      // Set the original time
      timeZoneTestData.OriginalTime = testDate;

      return timeZoneTestData;
    }

    /// <summary>
    ///   Return the time zone ids specified in
    ///   R:\extensions\Core\config\enumtype\Global\Global.xml.
    ///   Use the dataset (mt_config) auto-generated from Global.xsd in Global.cs
    /// </summary>
    /// <returns>
    ///   metraTech time zone id --  metraTech time zone enum
    /// </returns>
    private Hashtable GetTimeZoneIds()
    {
      var timeZoneIds = new Hashtable();

      var dataSet = new mt_config();
      dataSet.ReadXml(@"R:\extensions\Core\config\enumtype\Global\Global.xml");

      var enumDataTable =
        (mt_config._enumDataTable) dataSet.Tables["enum"];

      foreach (mt_config._enumRow row in enumDataTable.Rows)
      {
        if (row.name == "TimeZoneID")
        {
          foreach (var row1 in row.GetentriesRows())
          {
            foreach (var eRow in row1.GetentryRows())
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
    ///   Hard close an interval with no payer accounts.
    ///   Check that the interval is hard closed.
    ///   Return the interval id.
    /// </summary>
    /// <returns></returns>
    public int HardCloseInterval()
    {
      // Get an interval without payers
      var intervalId = _util.GetIntervalWithoutPayers();
      int hardClosedBillingGroups;
      _util.Client.HardCloseUsageInterval(intervalId, false, out hardClosedBillingGroups);

      VerifyIntervalStatus(intervalId, UsageIntervalStatus.HardClosed);

      return intervalId;
    }

    public class TimeZoneRowSorter : IComparer
    {
      // Calls CaseInsensitiveComparer.Compare with the parameters reversed.
      int IComparer.Compare(Object x, Object y)
      {
        var xRow = (xmlconfig.timezoneRow) x;
        var yRow = (xmlconfig.timezoneRow) y;

        return (xRow.id_timezone.CompareTo(yRow.id_timezone));
      }
    }

    // Store IBillingGroup <--> ArrayList of member account id's
    private ArrayList _billingGroupsForIntervalBeforePullListCreation;
    private ArrayList _billingGroupsForIntervalBeforeUserDefinedGroupCreation;

    private int _testPullListId;
    private int _testParentBillingGroupId;
    private int _testUserDefinedBillingGroupId;


    private const string AdapterComment = "Billing group test";

    /// <summary>
    ///   Provides checkpoint data common to all execution dependency tests.
    /// </summary>
    private static class CheckpointData
    {
      /// <summary>
      ///   Return the data pertaining to hard close checkpoints.
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetCheckpointData()
      {
        var data = new ArrayList();

        // Submit and execute "HardCloseCheckpoint". Expect 'Succeeded'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.HardCloseCheckpointName),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.EndRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private static class IntervalAccountExecutionData
    {
      /// <summary>
      ///   Return the recurring events which need to be executed or
      ///   reversed along with the recurring events which do not need
      ///   to be submitted but whose status needs to be checked.
      ///   If lastBillingGroup is true, then don't submit the interval
      ///   adapter and expect it to be succeeded because all its dependencies
      ///   will have been satisfied.
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetRecurringEventData(bool lastBillingGroup)
      {
        var data = new ArrayList();

        // Submit and execute "A". Expect 'Succeeded'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // If it's not the last billing group, 
        // submit and execute "B". Expect 'ReadyToRun'.
        // Otherwise, do not submit "B". Expect 'Succeeded'
        recurringEventData = new RecurringEventData {RecurringEvent = _util.GetRecurringEvent("B")};
        if (lastBillingGroup)
        {
          recurringEventData.Submit = false;
          recurringEventData.Execute = false;
          recurringEventData.ExpectedStatus = RecurringEventInstanceStatus.Succeeded;
        }
        else
        {
          recurringEventData.Submit = true;
          recurringEventData.Execute = true;
          recurringEventData.ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun;
        }

        data.Add(recurringEventData);

        // Do not submit "_StartRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.StartRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.EndRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private static class IntervalAccountReversalData
    {
      /// <summary>
      /// </summary>
      /// <returns></returns>
      public static ArrayList GetDataForReversingAccountAdapterExpectingReadyToReverse()
      {
        var data = new ArrayList();

        // Submit and reverse "A". Expect 'ReadyToReverse'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = true,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToReverse
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns></returns>
      public static ArrayList GetDataForAccountAdapterExpectingNotYetRun()
      {
        var data = new ArrayList();

        // Submit and reverse "A". Expect 'NotYetRun'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.NotYetRun
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns></returns>
      public static ArrayList GetDataForReversingIntervalAdapterExpectingNotYetRun()
      {
        var data = new ArrayList();

        // Submit and reverse "B". Expect 'NotYetRun'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = true,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.NotYetRun
          };
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private static class IntervalIntervalExecutionData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingReadyToRun()
      {
        var data = new ArrayList();

        // Submit and execute "B". Expect 'ReadyToRun'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingSucceeded()
      {
        var data = new ArrayList();

        // Submit "A". Expect 'Succeeded'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // Do not submit "B". Expect 'Succeeded'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = false,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private static class IntervalIntervalReversalData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingReadyToReverse()
      {
        var data = new ArrayList();

        // Submit "A" for reversal. Expect 'ReadyToReverse'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = true,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToReverse
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingNotYetRun()
      {
        var data = new ArrayList();

        // Submit "B" for reversal. Expect 'NotYetRun'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = true,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.NotYetRun
          };
        data.Add(recurringEventData);

        // Do not submit "A". Expect 'NotYetRun'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.NotYetRun
          };
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private static class BillingGroupExecutionData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingReadyToRun()
      {
        var data = new ArrayList();

        // Submit "B" for execution. Expect 'ReadyToRun'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        // Do not submit "_StartRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.StartRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.EndRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingSucceeded()
      {
        var data = new ArrayList();

        // Submit "A" for execution. Expect 'Succeeded'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // Do not submit "B" for execution. Expect 'Succeeded'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = false,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private static class BillingGroupReversalData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingReadyToReverse()
      {
        var data = new ArrayList();

        // Submit "A" for reversal. Expect 'ReadyToReverse'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = true,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToReverse
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingNotYetRun()
      {
        var data = new ArrayList();

        // Submit "B" for reversal. Expect 'NotYetRun'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = true,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.NotYetRun
          };
        data.Add(recurringEventData);

        // Do not submit "A" for execution. Expect 'NotYetRun'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.NotYetRun
          };
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.EndRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private static class BillingGroupIntervalReversalData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingReadyToReverse(bool lastBillingGroup)
      {
        var data = new ArrayList();

        // Submit "B" for reversal. Expect 'NotYetRun'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = true,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.NotYetRun
          };
        data.Add(recurringEventData);

        // A should be 'ReadyToReverse' if lastBillingGroup is false.
        // Otherwise it should be 'NotYetRun'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = false,
            Execute = false,
            ExpectedStatus =
              lastBillingGroup ? RecurringEventInstanceStatus.NotYetRun : RecurringEventInstanceStatus.ReadyToReverse
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingReadyToReverse()
      {
        var data = new ArrayList();

        // Submit "A" for reversal. Expect 'ReadyToReverse'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = true,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToReverse
          };
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private static class BillingGroupIntervalExecutionData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataExpectingReadyToRun()
      {
        var data = new ArrayList();

        // Submit "B" for execution. Expect 'ReadyToRun'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        // Do not submit "_StartRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.StartRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.EndRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetIntervalDataExpectingSucceeded()
      {
        var data = new ArrayList();

        // Submit "A" for execution. Expect 'Succeeded'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetBillingGroupDataExpectingSucceeded()
      {
        var data = new ArrayList();

        // Do not submit "B". Expect 'Succeeded'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        return data;
      }
    }

    /// <summary>
    ///   Provides data related to the corresponding test.
    /// </summary>
    private static class BillingGroupAdapterWithPullListData
    {
      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataForParentBillingGroup()
      {
        var data = new ArrayList();

        // Submit "A" for execution. Expect 'Succeeded'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // Submit "B" for execution. Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        // Do not submit "_StartRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.StartRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.EndRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataForBillingGroupExpectReadyToRun()
      {
        var data = new ArrayList();

        // Do not submit "B". Expect 'ReadyToRun'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataForBillingGroupExpectSucceeded()
      {
        var data = new ArrayList();

        // Do not submit "B". Expect 'ReadyToRun'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("B"),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        return data;
      }

      /// <summary>
      /// </summary>
      /// <returns>ArrayList</returns>
      public static ArrayList GetDataForPullList()
      {
        var data = new ArrayList();

        // Submit "A" for execution. Expect 'Succeeded'
        var recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent("A"),
            Submit = true,
            Execute = true,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // Do not submit "_StartRoot". Expect 'Succeeded'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.StartRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.Succeeded
          };
        data.Add(recurringEventData);

        // Do not submit "_EndRoot". Expect 'ReadyToRun'
        recurringEventData = new RecurringEventData
          {
            RecurringEvent = _util.GetRecurringEvent(Util.EndRootName),
            Submit = false,
            Execute = false,
            ExpectedStatus = RecurringEventInstanceStatus.ReadyToRun
          };
        data.Add(recurringEventData);

        return data;
      }
    }

    private class TimeZoneTestData
    {
      public CalendarCodeEnum CalendarCode;
      public int EnumDataTimeZoneId;
      public string EnumTimeZoneName;
      public DateTime GmtTime;
      public int IntervalId;
      public int MetraTechTimeZoneId;
      public DateTime OriginalTime;
      public string PriceListName;
      public string WindowsTimeZoneName;
    }

    private class RecurringEventData
    {
      public bool Execute; // false indicates reverse
      public RecurringEventInstanceStatus ExpectedStatus;
      public IRecurringEvent RecurringEvent;
      public bool Submit; // false indicates do not submit
    }

    private class BatchAccountData
    {
      public int AccountId;
      public string BatchUid;
    }

    private class RecurringEventInstance
    {
      public BillingGroupSupportType BillingGroupSupportType;
      public string EventName;
      public string EventType;
      public int IdBillgroup;
      public int IdEvent;
      public int IdInstance;
      public int IdInterval;
      public string LastRunStatus;
      public RecurringEventInstanceStatus RecurringEventInstanceStatus;

      /// <summary>
      ///   Override equals
      /// </summary>
      /// <param name="o"></param>
      /// <returns></returns>
      public override bool Equals(object o)
      {
        var recurringEventInstance = o as RecurringEventInstance;
        if (recurringEventInstance == null)
        {
          return false; // not a compatible type 
        }

        // Everything except id_instance must be the same
        if (IdEvent == recurringEventInstance.IdEvent &&
            IdInterval == recurringEventInstance.IdInterval &&
            RecurringEventInstanceStatus == recurringEventInstance.RecurringEventInstanceStatus &&
            LastRunStatus == recurringEventInstance.LastRunStatus &&
            BillingGroupSupportType == recurringEventInstance.BillingGroupSupportType)
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
        return IdInstance;
      }
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Interval with both paying and non-paying accounts
    ///   PostConditions:  (to be ASSERTED)
    ///   1) One billing group created for the interval.
    ///   2) Billing group has expected name.
    ///   3) The billing group contains expected number of accounts.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T01TestCreateBillingGroupWithoutAssignmentQuery()
    {
      // Get an interval for materialization
      var intervalId = _util.GetIntervalForFullMaterialization();

      // Create billing groups using the default assignment query 
      _util.BillingGroupManager.MaterializeBillingGroups(intervalId, _util.UserId, true);

      // Check the results
      var rowset = _util.BillingGroupManager.GetBillingGroupsRowset(intervalId, true);

      // Expect only one row
      Assert.AreEqual(1, rowset.RecordCount, "Number of billing groups mismatch");

      // Billing group name must be same as billingGroupManager.DefaultBillingGroupName
      Assert.AreEqual(_util.BillingGroupManager.DefaultBillingGroupName, rowset.Value["Name"],
                      "Billing group name mismatch");

      // Number of accounts in the billing group must be the same as the number
      // of paying accounts in the interval.
      Assert.AreEqual(_util.BillingGroupAccountIds.Count,
                      Convert.ToInt32(rowset.Value["MemberCount"]),
                      "Number of accounts in billing group mismatch");

      // The paying account id's for the interval must match the members
      // of the billing group
      IBillingGroup billingGroup =
        new UsageServer.BillingGroup((int) rowset.Value["BillingGroupID"]);
      billingGroup.Name = (string) rowset.Value["Name"];

      CheckBillingGroupAccounts(billingGroup, _util.BillingGroupAccountIds);

      // Check that there are no unassigned accounts for the interval
      AssertNoUnassignedAccounts(intervalId);
    }

    /// <summary>
    ///   Post conditions:
    ///   1) Billing group called 'North America'.
    ///   2) Billing group called 'South America'.
    ///   3) Billing group called 'Europe'.
    /// </summary>
    //[Test]
    //public void T02TestCreateBillingGroupWithAssignmentQuery()
    //{
    //  // This test is implemented in the CreateBillingGroupsWithAssignmentQuery method
    //  // that is called in many tests below
    //}

    /// <summary>
    ///   Create a pull list.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T03TestCreatePullList()
    {
      // Create and soft close billing groups
      int intervalId;
      // Store data for use by TestRematerialization
      _billingGroupsForIntervalBeforePullListCreation =
        CreateAndSoftCloseBillingGroups(out intervalId, true);

      var parentBillingGroup =
        (IBillingGroup) _billingGroupsForIntervalBeforePullListCreation[0];

      // Store data for use by TestRematerialization
      _testParentBillingGroupId = parentBillingGroup.BillingGroupID;

      // Create a pull list
      var pullList = CreatePullList(parentBillingGroup, "Test pull list", null, false);

      // Store data for use by TestRematerialization
      _testPullListId = pullList.BillingGroupID;
    }

    /// <summary>
    ///   1) Create billing groups.
    ///   2) From one of the billing groups (BG1) do the following:
    ///   a) Create a pull list (P1)
    ///   b) Create another pull list (P2)
    ///   c) Soft close (P2). Check adapter instances are created correctly.
    ///   d) Soft close (BG1). Check adapter instances are created correctly.
    ///   e) Soft close (P1). Check adapter instances are created correctly.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T04TestCreatePullListVariation1()
    {
      // Create billing groups
      int intervalId;
      var billingGroups = CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Get the parent billing group (BG1)
      var bg1 = (IBillingGroup) billingGroups[0];
      // Create a pull list (P1)
      var p1 = CreatePullList(bg1, "P1", null, true);
      // Create a pull list (P2)
      var p2 = CreatePullList(bg1, "P2", null, true);
      // Soft close (P2). This checks adapter instances as well.
      SoftCloseBillingGroup(p2.BillingGroupID);
      // Soft close (BG1). This checks adapter instances as well.
      SoftCloseBillingGroup(bg1.BillingGroupID);
      // Soft close (P1). This checks adapter instances as well.
      SoftCloseBillingGroup(p1.BillingGroupID);
    }

    /// <summary>
    ///   Get an interval which has billing groups.
    ///   Meter some accounts to that interval.
    ///   Check that the new accounts fall into the unassigned category.
    ///   Create a user defined billing group with all the unassigned accounts.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T05TestCreateUserDefinedBillingGroup()
    {
      // Create billing groups for a non-materialized interval and store
      // data so that we can ensure that the system reverts to this set 
      // once rematerialization happens in a subsequent test
      int intervalId;
      _billingGroupsForIntervalBeforeUserDefinedGroupCreation =
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Meter 3 new accounts 
      var newAccounts =
        CreateAccounts(Util.NumberOfNewAccountsForUserDefinedGroup, true);

      // Refresh the usage interval
      var usageInterval =
        _util.UsageIntervalManager.GetUsageInterval(intervalId);

      // Check that there are 3 open unassigned accounts
      Assert.AreEqual(Util.NumberOfNewAccountsForUserDefinedGroup,
                      usageInterval.OpenUnassignedAccountsCount,
                      "Mismatch in number of open unassigned accounts!");

      // Create an user defined billing group
      _util.BillingGroupManager.
            CreateUserDefinedBillingGroupFromAllUnassignedAccounts
        (intervalId,
         _util.UserId,
         Util.UserDefinedGroupName,
         Util.UserDefinedGroupDescription);

      // Look for the user defined billing group in the interval
      var billingGroups = GetBillingGroups(intervalId);
      Assert.AreEqual(true,
                      CheckBillingGroupExists(Util.UserDefinedGroupName, billingGroups),
                      "User defined billing group not found!");

      // store the id
      var testUserDefinedBillingGroup =
        GetBillingGroup(Util.UserDefinedGroupName, intervalId);

      Assert.AreNotEqual(null, testUserDefinedBillingGroup,
                         "Could not find user defined billing group!");

      // Check that the user defined billing group is well formed
      CheckBillingGroup(testUserDefinedBillingGroup,
                        Util.UserDefinedGroupName,
                        newAccounts);
      // store the billing group id
      _testUserDefinedBillingGroupId = testUserDefinedBillingGroup.BillingGroupID;
    }

    /// <summary>
    ///   Preconditions: The following tests must have run for this test to succeed.
    ///   1) TestCreatePullListForOpenBillingGroupWithNoAdapters
    ///   2) TestCreateUserDefinedBillingGroup
    ///   At this stage we've created one pull list and one user defined
    ///   billing group. Both should be open and in different intervals.
    ///   By rematerializing both intervals the pull list
    ///   and the user defined billing group should both disappear.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T06TestRematerialization()
    {


      // Before rematerializing, open the parent billing group and
      // the pull list created in the TestCreatePullList test
      _util.BillingGroupManager.
            OpenBillingGroup(_testParentBillingGroupId, false, false);
      _util.BillingGroupManager.
            OpenBillingGroup(_testPullListId, false, false);

      // Rematerialize the interval for which a pull list has been created
      var intervalId = GetPullListIntervalId();
      _util.BillingGroupManager.
            MaterializeBillingGroups(intervalId, _util.UserId);

      // Check that the pull list has gone away
      var billingGroups = GetBillingGroups(intervalId);

      Assert.AreEqual(_billingGroupsForIntervalBeforePullListCreation.Count,
                      billingGroups.Count,
                      "Expected the pull list to be deleted during rematerialization!");

      Assert.AreEqual(false,
                      CheckBillingGroupExists(_testPullListId, billingGroups),
                      "Expected the pull list to be deleted during rematerialization!");

      // Rematerialize the interval for which a user defined billing group has been created
      intervalId = GetUserDefinedGroupIntervalId();
      _util.BillingGroupManager.MaterializeBillingGroups(intervalId, _util.UserId);

      // Check that the user defined billing group has gone away
      billingGroups = GetBillingGroups(intervalId);

      Assert.AreEqual(_billingGroupsForIntervalBeforeUserDefinedGroupCreation.Count,
                      billingGroups.Count,
                      "Expected the user defined billing group to be deleted " +
                      "during rematerialization!");

      Assert.AreEqual(false,
                      CheckBillingGroupExists(_testUserDefinedBillingGroupId,
                                              billingGroups),
                      "Expected the user defined billing group to be " +
                      "deleted during rematerialization!");
    }

    /// <summary>
    ///   Soft closes a billing group.
    ///   Check that the right number of adapter instances get generated.
    /// </summary>
    //[Test]
    //public void T07TestSoftCloseBillingGroups()
    //{
    //  // This test just calls the SoftCloseInterval method
    //  // As the method is called by other tests, for instance, 
    //  // by the T03TestCreatePullList test, it is not  neccessary
    //  // to test it in a separate test
    //}

    /// <summary>
    ///   1) Create billing groups
    ///   2) Soft close them
    ///   3) Meter new accounts
    ///   4) Meter usage for those new accounts
    ///   5) Verify usage has been received
    ///   6) Hard close unassigned accounts
    ///   7) Check that usage for those accounts have been bounced to
    ///   the next open interval.
    ///   8) Verify that accounts have a status of hard closed
    ///   in t_acc_usage_interval for the old interval id.
    ///   9) Verify that the accounts have a status of open
    ///   in t_acc_usage_interval for the new interval id.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T08TestHardCloseOfUnassignedAccounts()
    {
      // Create billing groups for a non-materialized interval
      int intervalId;
      var billingGroups = CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Soft close the billing groups
      SoftCloseInterval(billingGroups);

      // Meter new accounts
      var accounts = CreateAccounts(Util.NumberOfNewAccountsToBeHardClosed, true);

      // Meter new usage for the accounts and verify that it landed in the given interval
      MeterUsage(accounts, intervalId, true);

      // Hard close unassigned accounts
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext =
        loginContext.Login("su", "system_user", "su123");

      _util.BillingGroupManager.
            SetAccountStatusToHardClosedForInterval(GetCollection(accounts),
                                                    intervalId,
                                                    true,
                                                    sessionContext);

      // should probably poll t_message every few secs instead of arbitrary sleep
      Thread.Sleep(5000*3);

      // Verify that the usage has been bounced to the next open interval
      var nextIntervalId = _util.GetNextOpenInterval(intervalId);
      VerifyUsage(accounts, nextIntervalId, true);

      // Check that the status of the accounts are hard closed in the
      // old interval
      _util.VerifyAccountStatus(accounts, intervalId, "H");

      // Check that the status of the accounts are open in the
      // new interval
      _util.VerifyAccountStatus(accounts, nextIntervalId, "O");
    }

    /// <summary>
    ///   1) Create billing groups
    ///   2) Meter usage to existing accounts with the time associated
    ///   with the current interval.
    ///   3) Validate that the usage does land in the current interval.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T09TestUsageIntervalResolutionForOpenBillingGroup()
    {
      // Create billing groups for a non-materialized interval
      int intervalId;
      CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Meter usage to US accounts with the time associated
      // with the current interval and verify that the usage did land
      // in the given interval

      MeterUsage(_util.UkAccountIds, intervalId, true);
    }

    /// <summary>
    ///   1) Create billing groups
    ///   2) Soft close them
    ///   3) Meter usage to existing accounts with the time associated
    ///   with the current interval.
    ///   4) Validate that the usage does not land in the current interval.
    ///   5) Validate that the usage lands in the next open interval.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T10TestUsageIntervalResolutionForSoftClosedBillingGroup()
    {
      // Create billing groups for a non-materialized interval
      int intervalId;
      var billingGroups = CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Soft close the billing groups
      SoftCloseInterval(billingGroups);

      // Meter usage to US accounts with the time associated
      // with the current interval and verify that the usage did not land
      // in the given interval

      MeterUsage(_util.UkAccountIds, intervalId, false);

      // Verify that the usage did land in the next open interval
      var nextIntervalId = _util.GetNextOpenInterval(intervalId);
      VerifyUsage(_util.UkAccountIds, nextIntervalId, true);
    }

    /// <summary>
    ///   1) Create billing groups
    ///   2) Soft close them, execute adapters and hard close the interval.
    ///   3) Meter usage to existing accounts with the time associated
    ///   with the current interval.
    ///   4) Validate that the usage does not land in the current interval.
    ///   5) Validate that the usage lands in the next open interval.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T11TestUsageIntervalResolutionForHardClosedBillingGroup()
    {
      // Create billing groups, soft close them, run adapters and
      // get the interval id. The interval will be hard closed.
      var intervalId =
        TestIntervalAdapterExecutionInternal(Util.IntervalAccountAdapterFileName, true);

      // Meter usage to US accounts with the time associated
      // with the current interval and verify that the usage did not land
      // in the given interval
      MeterUsage(_util.UkAccountIds, intervalId, false);

      // Verify that the usage did land in the next open interval
      var nextIntervalId = _util.GetNextOpenInterval(intervalId);
      VerifyUsage(_util.UkAccountIds, nextIntervalId, true);
    }

    /// <summary>
    ///   1) Create billing groups
    ///   2) Block the interval. Verify that the interval is blocked.
    ///   3) Meter usage to existing accounts with the time associated
    ///   with the current interval.
    ///   4) Validate that the usage does land in the current interval.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T13TestUsageIntervalResolutionForBlockedInterval()
    {
      // Create billing groups for a non-materialized interval
      int intervalId;
      CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Block the interval
      _util.BillingGroupManager.SetIntervalAsBlockedForNewAccounts(intervalId);
      VerifyIntervalStatus(intervalId, UsageIntervalStatus.Blocked);

      // Meter usage to US accounts with the time associated
      // with the current interval and verify that the usage did land
      // in the given interval
      MeterUsage(_util.UkAccountIds, intervalId, true);
    }

    /// <summary>
    ///   1) Create billing groups
    ///   2) Soft close each billing group
    ///   3) Execute adapters for each billing group
    ///   4) Verify that each adapter has succeeded
    ///   5) Verify that the billing group status is hard closed.
    ///   6) Verify that the interval status is hard closed.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    [Ignore]
    public void T15TestAdapterExecution()
    {
      // Reset the events
      _util.SetupAdapterDependencies(null);

      // Create and soft close billing groups
      int intervalId;
      var billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);

      // Instantiate scheduled events
      _util.Client.InstantiateScheduledEvents();
      // Execute the scheduled events
      ExecuteScheduledEvents(intervalId);

      foreach (IBillingGroup billingGroup in billingGroups)
      {
        // Execute adapters. 
        // The system hard closes the billing group once all adapters have executed.
        ExecuteAdapters(billingGroup);
      }

      // Check that the interval is hard closed
      VerifyIntervalStatus(intervalId, UsageIntervalStatus.HardClosed);
    }

    /// <summary>
    ///   [See Bug: CR 13067]
    ///   1) Create billing groups
    ///   2) Meter usage to accounts for one billing group. Verify usage exists.
    ///   3) Soft close the billing group
    ///   4) Execute invoice adapter for the billing group and
    ///   verify that it succeeded
    ///   5) Check that invoices have been generated in t_invoice
    ///   6) Backout usage. Verify usage has been backed out.
    ///   7) Reverse invoice adapter for the billing group.
    ///   Verify that adapter reversed successfully.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T16TestInvoiceAdapterReversalWithBackout()
    {
      // Reset the events
      _util.SetupAdapterDependencies(null);

      // Create billing groups for a non-materialized interval 
      int intervalId;
      var billingGroups =
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Pick the first billing group 
      var billingGroup = (IBillingGroup) billingGroups[0];
      var accounts =
        _util.BillingGroupManager.GetBillingGroupMembers(billingGroup.BillingGroupID);

      // Meter usage to the billing group accounts with the time associated
      // with the current interval and verify that the usage did land
      // in the given interval
      MeterUsage(accounts, intervalId, true);

      // Force materialized views to update.
      var mvm = new Manager();
      mvm.Initialize();
      mvm.UpdateAllDeferredMaterializedViews();

      // Soft close the billing group
      SoftCloseBillingGroup(billingGroup.BillingGroupID);

      // Execute the invoice adapter, ignore dependencies
      ExecuteAdapter(intervalId, billingGroup.BillingGroupID,
                     Util.InvoiceAdapterClassName,
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
                     Util.InvoiceAdapterClassName,
                     false, // execute
                     true, // ignoreDependencies 
                     RecurringEventInstanceStatus.NotYetRun);

      // Check invoices have been deleted
      CheckInvoices(intervalId, accounts, false);
    }

    /// <summary>
    ///   [See Bug: CR 13129]
    ///   1) Create two accounts A and B - weekly billing cycle
    ///   2) Meter usage to A and B
    ///   3) Generate a billing group and run the invoice adapter.
    ///   4) This will generate two invoices for A and B
    ///   5) Make B payer for A and make A non-billable
    ///   6) Generate billing groups for the next open interval
    ///   7) Run the payer change adapter.
    ///   8) In MetraView you will see that A has bill for current interval,
    ///   while B has previous usage plus a debit for A’s previous usage.
    ///   Payer Change Adapter creates a credit record for A and debit record for B.
    ///   9) Now reverse the Payer Change Adapter.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T17TestPayerChangeAdapter()
    {
      // Reset the events
      _util.SetupAdapterDependencies(null);

      // Create two accounts 
      var accountIds = CreateAccounts(2, true);
      Assert.AreEqual(2, accountIds.Count, "Expected 2 accounts to have been created");

      var account1 = (int) accountIds[0];
      var account2 = (int) accountIds[1]; // future payee

      // Get an interval that has not been materialized
      var intervalId = _util.GetIntervalForFullMaterialization();
      var usageInterval = _util.UsageIntervalManager.GetUsageInterval(intervalId);

      // Meter usage to the accounts for the interval
      MeterUsage(accountIds, intervalId, true);

      // Force materialized views to update.
      var mvm = new Manager();
      mvm.Initialize();
      mvm.UpdateAllDeferredMaterializedViews();

      // Create and soft close billing groups for the interval
      var billingGroups = CreateAndSoftCloseBillingGroups(intervalId, true);

      // The two new accounts will be in the North America billing group because
      // they were created as US accounts
      var northAmericaBillingGroup =
        billingGroups.Cast<IBillingGroup>()
                     .FirstOrDefault(billingGroup => billingGroup.Name.Equals(Util.NorthAmericaBillingGroupName));

      // Check that we have a North America billing group
      Assert.IsNotNull(northAmericaBillingGroup, "Expected to find a 'North America' billing group");
      // Check that we have account1 and account2 in the billing group
      CheckBillingGroupAccountMembership(northAmericaBillingGroup.BillingGroupID, accountIds, true);

      // Execute the Invoice adapter for North America billing group, ignore dependencies
      ExecuteAdapter(intervalId,
                     northAmericaBillingGroup.BillingGroupID,
                     Util.InvoiceAdapterClassName,
                     true, // execute
                     true, // ignoreDependencies
                     RecurringEventInstanceStatus.Succeeded);

      // Check invoice generation
      CheckInvoices(intervalId, accountIds, true);

      // Make account2 a payee account and make account1 its payer
      _util.MoveAccountFromPayerToPayee(account2, usageInterval.StartDate, account1);

      // Get the next open interval
      var nextIntervalId = _util.GetNextOpenInterval(intervalId);

      // Create and soft close billing groups for the next interval
      billingGroups = CreateAndSoftCloseBillingGroups(nextIntervalId, true);

      // Get the North America billing group. This time it should have account1 but not account2
      northAmericaBillingGroup =
        billingGroups.Cast<IBillingGroup>()
                     .FirstOrDefault(billingGroup => billingGroup.Name.Equals(Util.NorthAmericaBillingGroupName));

      // Check that we have a North America billing group
      Assert.IsNotNull(northAmericaBillingGroup, "Expected to find a 'North America' billing group");
      // Check that we have still have account1 and account2 in the billing group
      CheckBillingGroupAccountMembership(northAmericaBillingGroup.BillingGroupID, accountIds, true);

      // Execute the Payer Change adapter for North America, ignore dependencies
      ExecuteAdapter(nextIntervalId,
                     northAmericaBillingGroup.BillingGroupID,
                     Util.PayerChangeAdapterClassName,
                     true, // execute
                     true, // ignoreDependencies
                     RecurringEventInstanceStatus.Succeeded);

      // Verify that the payment redirection did happen
      _util.VerifyPaymentRedirection(account1, account2, nextIntervalId, true);

      // Execute the Invoice adapter for North America billing group, ignore dependencies
      ExecuteAdapter(nextIntervalId,
                     northAmericaBillingGroup.BillingGroupID,
                     Util.InvoiceAdapterClassName,
                     true, // execute
                     true, // ignoreDependencies
                     RecurringEventInstanceStatus.Succeeded);

      // Check invoice generation
      CheckInvoices(nextIntervalId, accountIds, true);

      // Reverse the payer change adapter for North America, ignore dependencies
      ExecuteAdapter(nextIntervalId,
                     northAmericaBillingGroup.BillingGroupID,
                     Util.PayerChangeAdapterClassName,
                     false, // reverse
                     true, // ignoreDependencies
                     RecurringEventInstanceStatus.NotYetRun);

      // Verify that there is no payment redirection
      _util.VerifyPaymentRedirection(account1, account2, nextIntervalId, false);
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestIntervalAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T18TestIntervalAccountExecution()
    {
      try
      {
        // Location specified by Util.testDir
        TestIntervalAdapterExecutionInternal(Util.IntervalAccountAdapterFileName, true);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestIntervalAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T19TestIntervalAccountReversal()
    {
      try
      {
        TestIntervalAdapterReversalInternal(Util.IntervalAccountAdapterFileName);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestIntervalAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T20TestIntervalBillingGroupExecution()
    {
      try
      {
        TestIntervalAdapterExecutionInternal
          (Util.IntervalBillingGroupAdapterFileName, true);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestIntervalAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T21TestIntervalBillingGroupReversal()
    {
      try
      {
        TestIntervalAdapterReversalInternal(Util.IntervalBillingGroupAdapterFileName);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestIntervalIntervalExecutionInternal
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T22TestIntervalIntervalExecution()
    {
      try
      {
        TestIntervalIntervalExecutionInternal
          (Util.IntervalIntervalAdapterFileName, true);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestIntervalIntervalReversalInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T22TestIntervalIntervalReversal()
    {
      try
      {
        TestIntervalIntervalReversalInternal
          (Util.IntervalIntervalAdapterFileName);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T23TestBillingGroupAccountExecution()
    {
      try
      {
        // Location specified by Util.testDir
        TestBillingGroupAdapterExecutionInternal
          (Util.BillingGroupAccountAdapterFileName, true);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T24TestBillingGroupAccountReversal()
    {
      try
      {
        TestBillingGroupAdapterReversalInternal
          (Util.BillingGroupAccountAdapterFileName);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T25TestBillingGroupBillingGroupExecution()
    {
      try
      {
        // Location specified by Util.testDir
        TestBillingGroupAdapterExecutionInternal
          (Util.BillingGroupBillingGroupAdapterFileName, true);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T26TestBillingGroupBillingGroupReversal()
    {
      try
      {
        TestBillingGroupAdapterReversalInternal
          (Util.BillingGroupBillingGroupAdapterFileName);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T27TestBillingGroupIntervalExecution()
    {
      try
      {
        // Location specified by Util.testDir
        TestBillingGroupIntervalExecutionInternal
          (Util.BillingGroupIntervalAdapterFileName, true);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupIntervalReversalInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T28TestBillingGroupIntervalReversal()
    {
      try
      {
        TestBillingGroupIntervalReversalInternal
          (Util.BillingGroupIntervalAdapterFileName);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   1) Setup an adapter chain of the following type:
    ///   - Adapter A (Account)
    ///   - Adapter B (BillingGroup)
    ///   (B) is dependent on (A)
    ///   (A) is an account-only adapter and (B) is a BillingGroup adapter
    ///   2) Get an interval with 3 billing groups (BG1, BG2, BG3).
    ///   3) Soft close each billing group. Each billing group has an
    ///   instance of (A) and an instance of (B).
    ///   4) Create a pull list (P1) from BG1.
    ///   (P1) has an instance of (A) but not of (B).
    ///   This is verified during pull list creation.
    ///   5) Create another pull list (P2) from (P1).
    ///   (P2) has an instance of (A) but not of (B).
    ///   6) Execute adapters for BG1
    ///   BG1-A - should succeed
    ///   BG1-B - should not succeed (until P1-A and P2-A have executed successfully)
    ///   8) Execute adapters for P1
    ///   P1-A - should succeed
    ///   9) Execute adapters for BG1
    ///   BG1-B - should not succeed (until P1-A and P2-A have executed successfully)
    ///   10) Execute adapters for P2
    ///   P2-A - should succeed
    ///   BG1-B - should succeed because its dependencies are satisfied
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T29TestBillingGroupAdapterWithPullList()
    {
      try
      {
        const string p1Name = "P1";
        const string p2Name = "P2";

        // Prepare t_recevent
        _util.SetupAdapterDependencies
          (Util.TestDir + Util.BillingGroupAccountAdapterFileName);

        // Create and soft close billing groups
        int intervalId;
        var billingGroups = CreateAndSoftCloseBillingGroups(out intervalId, true);

        // Let the first billing group be the parent billing group
        var bg1 = (IBillingGroup) billingGroups[0];

        // Create a pull list from the first billing group
        var p1 = CreatePullList(bg1, p1Name, null, false);
        // Create a pull list from p1
        var p2 = CreatePullList(p1, p2Name, null, false);

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
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T30TestAccountAccountExecution()
    {
      try
      {
        // Location specified by Util.testDir
        TestBillingGroupAdapterExecutionInternal
          (Util.AccountAccountAdapterFileName, true);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T31TestAccountAccountReversal()
    {
      try
      {
        TestBillingGroupAdapterReversalInternal
          (Util.AccountAccountAdapterFileName);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T32TestAccountBillingGroupExecution()
    {
      try
      {
        // Location specified by Util.testDir
        TestBillingGroupAdapterExecutionInternal
          (Util.AccountBillingGroupAdapterFileName, true);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupAdapterReversalInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T33TestAccountBillingGroupReversal()
    {
      try
      {
        TestBillingGroupAdapterReversalInternal
          (Util.AccountBillingGroupAdapterFileName);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupAdapterExecutionInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T34TestAccountIntervalExecution()
    {
      try
      {
        // Location specified by Util.testDir
        TestBillingGroupIntervalExecutionInternal
          (Util.AccountIntervalAdapterFileName, true);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for the method:
    ///   TestBillingGroupIntervalReversalInternal
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T35TestAccountIntervalReversal()
    {
      try
      {
        TestBillingGroupIntervalReversalInternal
          (Util.AccountIntervalAdapterFileName);
      }
      finally
      {
        // Reset the events
        _util.SetupAdapterDependencies(null);
      }
    }

    /// <summary>
    ///   See comments for TestBackout.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T36TestBackoutFailureForHardCloseAccounts()
    {
      TestBackout(true);
    }

    /// <summary>
    ///   See comments for TestBackout.
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    public void T37TestBackoutSuccessForSoftClosedAccounts()
    {
      TestBackout(false);
    }

    /// <summary>
    ///   Test the __GET_EOP_EVENT_INSTANCES_FOR_DISPLAY__ query.
    ///   1) Use the adapter hierarchy specified in bg_eop_query_test.xml
    ///   - Adapter A (Account)
    ///   - Adapter B (Account)
    ///   - Adapter C (BillingGroup)
    ///   - Adapter D (Account)
    ///   - Adapter E (Account)
    ///   - Adapter F (BillingGroup)
    ///   - Adapter G (Interval)
    ///   The order of the adapters specifies the dependencies.
    ///   2) Start with three billing groups - BG1, BG2, BG3.
    ///   3) Soft close BG1.
    ///   4) Check the presence and order of the adapter instances.
    ///   5) Create a pull list P1 from BG1.
    ///   6) Do the check in step(4).
    ///   7) Create a pull list from P2 from P1
    ///   8) Do the check in step(4).
    ///   9) Run the query for BG2. Check that no adapter instances exist.
    ///   10) Repeat steps 3,4,5,6,7,8 for BG2.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    [Ignore]
    //TODO Figure out whether to remove the test or implement one 
    public void T38TestEndOfPeriodQuery()
    {
    }

    /// <summary>
    ///   1) Get an interval with no paying accounts but with payee accounts.
    ///   2) Create billing groups for this interval.
    ///   3) Check that MaterializingIntervalWithoutPayersException is thrown.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T39TestCreateMaterializationForIntervalWithNoPayingAccounts()
    {
      // Get an interval for materialization
      var intervalId = _util.GetIntervalWithoutPayers();

      // Create billing groups  
      ExceptionAssert.Expected<MaterializingIntervalWithoutPayersException>(
        () => _util.BillingGroupManager.CreateMaterialization(intervalId, _util.UserId));
    }

    /// <summary>
    ///   1) Get a hard closed interval.
    ///   2) Create billing groups for this interval.
    ///   3) Check that MaterializingHardClosedIntervalException is thrown.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T40TestCreateMaterializationForHardClosedInterval()
    {
      // Get a hard closed interval
      var intervalId = _util.GetHardClosedInterval();
      // Create billing groups  
      ExceptionAssert.Expected<MaterializingHardClosedIntervalException>(
        () => _util.BillingGroupManager.MaterializeBillingGroups(intervalId, _util.UserId));
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Entry in t_recevent_inst for adapter with a status
    ///   of 'Running'
    ///   PostConditions:
    ///   1) MaterializingWhileAdapterProcessingException is thrown
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T41TestCreateMaterializationWhileAdapterInstanceRunning()
    {
      // Get an interval for materialization
      var intervalId = _util.GetIntervalForFullMaterialization();

      // Create a dummy adapter instance row
      _util.CreateDummyAdapterRow(new object[] {intervalId, "Running"});

      // Create billing groups  
      ExceptionAssert.Expected<MaterializingWhileAdapterProcessingException>(
        () => _util.BillingGroupManager.CreateMaterialization(intervalId, _util.UserId));

      // Delete the dummy adapter instance row created earlier
      _util.DeleteDummyAdapterRow("Running");
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Entry in t_billgroup_materialization with a status
    ///   of 'InProgress'
    ///   PostConditions:
    ///   1) MaterializationInProgressException is thrown
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T42TestCreateMaterializationWhileAnotherIsInProgress()
    {
      // Get an interval for materialization
      var intervalId = _util.GetIntervalForFullMaterialization();

      // Create a dummy materialization row
      var materializationId =
        Util.CreateMaterializationRow(intervalId,
                                      MaterializationStatus.InProgress,
                                      MaterializationType.Full,
                                      _util.UserId);

      // Create billing groups  
      ExceptionAssert.Expected<MaterializationInProgressException>(
        () => _util.BillingGroupManager.CreateMaterialization(intervalId, _util.UserId));

      // Delete the dummy adapter materialization row created earlier
      _util.DeleteDummyMaterializationRow(materializationId);
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Entry in t_billgroup_materialization with a status
    ///   of 'Full'
    ///   PostConditions:
    ///   1) RepeatFullMaterializationException is thrown
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T43TestRepeatFullMaterialization()
    {
      // Get an interval for materialization
      var intervalId = _util.GetIntervalForFullMaterialization();

      // Create a dummy materialization row
      var materializationId =
        Util.CreateMaterializationRow(intervalId,
                                      MaterializationStatus.Succeeded,
                                      MaterializationType.Full,
                                      _util.UserId);
      // Create billing groups   
      ExceptionAssert.Expected<RepeatFullMaterializationException>(() =>
                                                                   _util.BillingGroupManager.
                                                                         CreateMaterialization(intervalId,
                                                                                               _util.UserId,
                                                                                               MetraTime.Now,
                                                                                               null,
                                                                                               MaterializationType
                                                                                                 .Full.ToString()));

      // Delete the dummy adapter materialization row created earlier
      _util.DeleteDummyMaterializationRow(materializationId);
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Create an entry in t_billgroup_constraint_tmp for one
    ///   of the paying accounts
    ///   PostConditions:
    ///   1) DuplicateAccountsInConstraintGroupsException is thrown
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T44TestDuplicateAccountsInBillGroupConstraint()
    {
      var materializationId = 0;
      UtilDelegate utilDelegate =
        _util.CreateDummyBillGroupConstraintTmpRow;

      var parameters = new object[]
        {
          (int) _util.PayerAccountIds[0],
          (int) _util.PayerAccountIds[0]
        };

      // Create billing groups  
      int intervalId;
      ExceptionAssert.Expected<DuplicateAccountsInConstraintGroupsException>(() =>
                                                                             CreateTemporaryBillingGroups(
                                                                               out intervalId,
                                                                               out materializationId,
                                                                               true,
                                                                               utilDelegate,
                                                                               2,
                                                                               parameters,
                                                                               false));
      UpdateMaterializationFromProgressToFailed(materializationId);
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Create an entry in t_billgroup_constraint_tmp for one
    ///   of the non-paying accounts
    ///   PostConditions:
    ///   1) NonPayerAccountsInConstraintGroupsException is thrown
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T45TestNonPayerAccountInBillGroupConstraint()
    {
      UtilDelegate utilDelegate =
        _util.CreateDummyBillGroupConstraintTmpRow;

      const int nonPayingAccountId = 1;

      var parameters = new object[]
        {
          nonPayingAccountId,
          nonPayingAccountId
        };

      var materializationId = 0;
      // Create billing groups  
      int intervalId;
      ExceptionAssert.Expected<NonPayerAccountsInConstraintGroupsException>(() =>
                                                                            CreateTemporaryBillingGroups(
                                                                              out intervalId,
                                                                              out materializationId,
                                                                              true,
                                                                              utilDelegate,
                                                                              1,
                                                                              parameters,
                                                                              false));
      UpdateMaterializationFromProgressToFailed(materializationId);
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Create an entry in t_billgroup_constraint_tmp for which
    ///   the id_group does not match the id_acc
    ///   PostConditions:
    ///   1) IncorrectConstraintGroupIdException is thrown
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T46TestIncorrectGroupIdInBillGroupConstraint()
    {
      UtilDelegate utilDelegate =
        _util.CreateDummyBillGroupConstraintTmpRow;

      var parameters = new object[]
        {
          (int) _util.PayerAccountIds[0],
          (int) _util.PayerAccountIds[1]
        };
      var materializationId = 0;

      // Create billing groups  
      int intervalId;
      ExceptionAssert.Expected<IncorrectConstraintGroupIdException>(() =>
                                                                    CreateTemporaryBillingGroups(out intervalId,
                                                                                                 out materializationId,
                                                                                                 true,
                                                                                                 utilDelegate,
                                                                                                 1,
                                                                                                 parameters,
                                                                                                 false));
      UpdateMaterializationFromProgressToFailed(materializationId);
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Create a duplicate entry in t_billgroup_source_acc
    ///   Postconditions:
    ///   1) DuplicateAccountsInBillgroupSourceAccException
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T47TestDuplicateAccountsInBillGroupSourceAcc()
    {
      var materializationId = 0;

      UtilDelegate utilDelegate =
        _util.CreateDummyBillGroupSourceAccRow;

      var parameters = new object[] {(int) _util.PayerAccountIds[0]};

      int intervalId;
      ExceptionAssert.Expected<DuplicateAccountsInBillgroupSourceAccException>(() =>
                                                                               CreateTemporaryBillingGroups(
                                                                                 out intervalId,
                                                                                 out materializationId,
                                                                                 false,
                                                                                 utilDelegate,
                                                                                 1,
                                                                                 parameters,
                                                                                 true));
      UpdateMaterializationFromProgressToFailed(materializationId);
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Create a duplicate entry in t_billgroup_member_tmp
    ///   Postconditions:
    ///   1) DuplicateAccountsInBillgroupMemberTmpException
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T48TestDuplicateAccountsInBillGroupMemberTmp()
    {
      var materializationId = 0;

      var utilDelegate =
        new UtilDelegate(_util.CreateDummyBillGroupMemberTmpRow);

      var parameters = new object[]
        {
          "Dummy billgroup name for unit testing",
          (int) _util.PayerAccountIds[0]
        };

      int intervalId;
      ExceptionAssert.Expected<DuplicateAccountsInBillgroupMemberTmpException>(
        () =>
        CreateTemporaryBillingGroups(out intervalId, out materializationId, false, utilDelegate, 1, parameters, true));

      UpdateMaterializationFromProgressToFailed(materializationId);
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Remove an entry from t_billgroup_member_tmp
    ///   Postconditions:
    ///   1) MissingAccountsFromBillgroupMemberTmpException
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T49TestMissingAccountsFromBillgroupMemberTmp()
    {
      var materializationId = 0;

      var utilDelegate =
        new UtilDelegate(_util.DeleteBillGroupMemberTmpRow);

      var parameters = new object[] {(int) _util.PayerAccountIds[0]};

      int intervalId;
      ExceptionAssert.Expected<MissingAccountsFromBillgroupMemberTmpException>(
        () => CreateTemporaryBillingGroups(out intervalId,
                                           out materializationId,
                                           false,
                                           utilDelegate,
                                           1,
                                           parameters,
                                           true));
      UpdateMaterializationFromProgressToFailed(materializationId);
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Remove accounts for a billing group from t_billgroup_member_tmp
    ///   Postconditions:
    ///   1) EmptyBillingGroupInTmpException
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T50TestEmptyBillingGroupInTmp()
    {
      var materializationId = 0;

      UtilDelegate utilDelegate =
        _util.DeleteAccountsForBillGroup;

      var commaSeparatedAccountIds =
        Util.GetCommaSeparatedIds(_util.UkAccountIds);

      var parameters = new object[] {commaSeparatedAccountIds};

      int intervalId;
      ExceptionAssert.Expected<EmptyBillingGroupInTmpException>(() => CreateTemporaryBillingGroups(out intervalId,
                                                                                                   out
                                                                                                     materializationId,
                                                                                                   false,
                                                                                                   utilDelegate,
                                                                                                   1,
                                                                                                   parameters,
                                                                                                   true));
      UpdateMaterializationFromProgressToFailed(materializationId);
    }

    /// <summary>
    ///   Preconditions:
    ///   1) Add a row in t_billgroup_member to with the same
    ///   billing group name as an existing row.
    ///   Postconditions:
    ///   1) DuplicateBillingGroupNamesInBillGroupTmpException
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T51TestDuplicateBillingGroupNamesInBillGroupTmp()
    {
      var materializationId = 0;

      UtilDelegate utilDelegate =
        _util.CreateDummyBillGroupTmpRow;

      var parameters = new object[] {Util.NorthAmericaBillingGroupName};

      int intervalId;
      ExceptionAssert.Expected<DuplicateBillingGroupNamesInBillGroupTmpException>(
        () => CreateTemporaryBillingGroups(out intervalId,
                                           out materializationId,
                                           false,
                                           utilDelegate,
                                           1,
                                           parameters,
                                           true));
      UpdateMaterializationFromProgressToFailed(materializationId);
    }

    /// <summary>
    ///   Create a pull list with no accounts.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T52TestCreatePullListWithNoAccounts()
    {
      // Create billing groups for a non-materialized interval 
      int intervalId;
      var billingGroups =
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Pick the first billing group as the parent
      var parentBillingGroup = (IBillingGroup) billingGroups[0];

      const string pullListAccounts = "    ";

      bool needsExtraAccounts;

      // Start creating a pull list
      ExceptionAssert.Expected<UnableToParseAccountsException>(() => _util.BillingGroupManager.
                                                                           StartChildGroupCreationFromAccounts(
                                                                             Util.TestPullListName,
                                                                             Util.TestPullListDescr,
                                                                             parentBillingGroup.BillingGroupID,
                                                                             pullListAccounts,
                                                                             out needsExtraAccounts,
                                                                             _util.UserId));
    }

    /// <summary>
    ///   Create a pull list with all parent accounts.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T53TestCreatePullListFromAllParentAccounts()
    {
      // Create billing groups for a non-materialized interval 
      int intervalId;
      var billingGroups =
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Pick the first billing group as the parent
      var parentBillingGroup = (IBillingGroup) billingGroups[0];

      // Get the parent account id's
      var parentMembers =
        _util.BillingGroupManager.GetBillingGroupMembers(parentBillingGroup.BillingGroupID);

      ExceptionAssert.Expected<CreatingPullListWithAllParentMembersException>(
        () => CreatePullList(parentBillingGroup, Util.TestPullListName, parentMembers, false));
    }

    /// <summary>
    ///   Create a pull list with non parent accounts.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T54TestCreatePullListFromNonParentAccounts()
    {
      // Create billing groups for a non-materialized interval 
      int intervalId;
      var billingGroups =
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Pick the first billing group as the parent
      var parentBillingGroup = (IBillingGroup) billingGroups[0];
      var nonParentBillingGroup = (IBillingGroup) billingGroups[1];

      // Get the non parent account id's
      var nonParentMembers =
        _util.BillingGroupManager.
             GetBillingGroupMembers(nonParentBillingGroup.BillingGroupID);

      ExceptionAssert.Expected<CreatingPullListWithNonParentMembersException>(
        () => CreatePullList(parentBillingGroup, Util.TestPullListName, nonParentMembers, false));
    }

    /// <summary>
    ///   Create a pull list with duplicate accounts.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T55TestCreatePullListFromDuplicateAccounts()
    {
      // Create billing groups for a non-materialized interval 
      int intervalId;
      var billingGroups =
        CreateBillingGroupsWithAssignmentQuery(out intervalId);

      // Pick the first billing group as the parent
      var parentBillingGroup = (IBillingGroup) billingGroups[0];

      // Get the parent account id's
      var pullListMembers =
        _util.BillingGroupManager.
              GetBillingGroupMembers(parentBillingGroup.BillingGroupID);

      // Create a duplicate
      pullListMembers.Add((int) pullListMembers[0]);

      ExceptionAssert.Expected<CreatingPullListWithDuplicateAccountsException>(
        () => CreatePullList(parentBillingGroup, Util.TestPullListName, pullListMembers, false));
    }

    /// <summary>
    ///   1) Get an interval with payer accounts.
    ///   2) Hard close the interval.
    ///   3) Check that UnableToHardCloseIntervalException is thrown.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T56TestHardCloseIntervalWithNonHardClosedPayerAccounts()
    {
      // Get an interval for materialization
      var intervalId = _util.GetIntervalForFullMaterialization();

      // Create billing groups  
      ExceptionAssert.Expected<UnableToHardCloseIntervalException>(
        () => _util.BillingGroupManager.HardCloseInterval(intervalId, false));
    }

    /// <summary>
    ///   1) Import 'Calendar_CL_PO' product offering if necessary:
    ///   pcimportexport -ipo -file "T:\QA\FunctionalTests\Usage\USAGE_CALENDAR\xml\CALENDAR_CodeLookUp_PO.xml" -username "su" -password "su123"
    ///   2) 'Calendar_CL_PO' has the following calendar codes (peak, off-peak ...):
    ///   12:00 AM - 03:14:59 AM = Off-peak
    ///   03:15 AM - 05:44:59 AM = Holiday
    ///   05:45 AM - 07:59:59 AM = Off-peak
    ///   08:00 AM - 07:59:59 PM = Peak
    ///   08:00 PM - 08:59:59 PM = Off-peak
    ///   09:00 PM - 11:29:59 PM = Weekend
    ///   11:30 PM - 11:59:59 PM = Off-peak
    ///   3) Import T:\Development\Core\UsageServer\TimeZoneTest.xml
    ///   This contains the time periods. This must match the time periods
    ///   specified in Step(2).
    ///   4) Import T:\Development\Core\UsageServer\timezone.xml
    ///   This contains the mapping of Windows time zone names to
    ///   the MetraTech time zone id
    ///   (specified in R:\config\timezone\Timezones.xml)
    ///   5) Import R:\
    ///   5) For each time zone obtained in Step(4):
    ///   (a) Get a list of TimeZoneTestData objects - one for each
    ///   time point specified in Step(2).
    ///   (b) Each TimeZoneTestData object obtained in 5(a) contains
    ///   two items:
    ///   - the GMT time for its corresponding time point based on
    ///   the Windows time zone.
    ///   - the expected calendar code (Peak, Off-Peak ...)
    ///   6) For each TimeZoneTestData object obtained in Step(5) do the following:
    ///   (a) Clear t_pv_testpi for the given interval.
    ///   (b) Create an account with the given MetraTech time zone id and
    ///   and the given pricelist name ('Calendar_CL_PL').
    ///   (c) Meter one testpi session for the account with the given gmtTime
    ///   and the given intervalId.
    ///   (d) Check that there is one data row in t_pv_testpi for the given interval
    ///   - Check that it has the given enumDataTimeZoneId
    ///   (obtained by converting the 'tx_timezone_info' in
    ///   R:\config\PresServer\timezone.xml to id_enum_data
    ///   in t_enum_data)
    ///   - Check that it has the given expectedCalendarCode
    /// </summary>
    [Test]
    [Category("Slow")]
    [Category("Billing")]
    [Ignore]
    public void T57TestCalendarCodeLookup()
    {
      const string calendarName = "Calendar_CL_PO";
      const string pricelistName = "Calendar_CL_PL";
      const string fileName =
        @"T:\QA\FunctionalTests\Usage\USAGE_CALENDAR\xml\CALENDAR_CodeLookUp_PO.xml";

      // If the calendar does not exist then run pcimportexport and import it.
      if (!Util.CheckProductOfferingExists(calendarName))
      {
        var pcImportWrapper = new PCImportWrapper();
        pcImportWrapper.ImportProductOffering(fileName, "");
      }

      // Load calendar/timezone XML data into the dataset
      var calendarDataSet = new CalendarTimeZoneData();
      calendarDataSet.ReadXml(Util.TestDir + Util.TimeZoneDataFileName);

      // Load timezone data from T:\Development\Core\UsageServer\ModifiedTimezone.xml
      var timeZoneDataSet = new xmlconfig();
      timeZoneDataSet.ReadXml(Util.TestDir + Util.TimeZoneMappingFileName);

      // Get the interval id
      var intervalId = _util.GetIntervalForFullMaterialization();

      // Get the mapping of metratech time zone ids to their enum values.
      // Specified in R:\extensions\Core\config\enumtype\Global\Global.xml
      var metraTechTimeZoneIds = GetTimeZoneIds();

      // Get the items in T:\Development\Core\UsageServer\ModifiedTimezone.xml
      // that match metraTechTimeZoneIds
      var timeZoneRowsMap = new Hashtable();
      foreach (xmlconfig.timezoneRow tmpTimeZoneRow in timeZoneDataSet.timezone)
      {
        if (metraTechTimeZoneIds.ContainsKey(Convert.ToInt32(tmpTimeZoneRow.id_timezone)))
        {
          timeZoneRowsMap.Add(tmpTimeZoneRow.nm_timezone, tmpTimeZoneRow);
        }
      }

      // If there are any time zones specified in 
      // T:\Development\Core\UsageServer\TimeZoneTest.xml
      // then test only those, otherwise test all the timezones in metraTechTimeZoneIds
      var timeZoneRows = new ArrayList();

      if (calendarDataSet.TimeZone.Rows.Count > 0)
      {
        foreach (CalendarTimeZoneData.TimeZoneRow timeZoneRow in calendarDataSet.TimeZone.Rows)
        {
          var xmlConfigTzRow = (xmlconfig.timezoneRow) timeZoneRowsMap[timeZoneRow.windowsName];
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

      const string enumDataPrefix = @"Global/TimeZoneID/";
      IMTNameID nameId = new MTNameID();

      var failedTimeZones = new ArrayList();

      foreach (xmlconfig.timezoneRow timeZoneRow in timeZoneRows)
      {
        // Retrieve test data given the calendar info and windows time zone
        var timeZoneTestDataList =
          GetTimeZoneTestData(calendarDataSet.CalendarCode,
                              timeZoneRow.nm_timezone,
                              Convert.ToInt32(timeZoneRow.id_timezone),
                              timeZoneRow.useWindowsTimeZone);

        // Retrieve the id_enum_data
        var enumTimeZoneName =
          (string) metraTechTimeZoneIds[Convert.ToInt32(timeZoneRow.id_timezone)];
        var enumDataTimeZoneId =
          nameId.GetNameID(enumDataPrefix + enumTimeZoneName);

        foreach (TimeZoneTestData timeZoneTestData in timeZoneTestDataList)
        {
          timeZoneTestData.MetraTechTimeZoneId = Convert.ToInt32(timeZoneRow.id_timezone);
          timeZoneTestData.EnumDataTimeZoneId = enumDataTimeZoneId;
          timeZoneTestData.EnumTimeZoneName = enumTimeZoneName;
          timeZoneTestData.IntervalId = intervalId;
          timeZoneTestData.PriceListName = pricelistName;

          if (TestCalendarCodeForTimeZone(timeZoneTestData)) continue;
          failedTimeZones.Add(timeZoneTestData);
          break;
        }
      }
    }

    /// <summary>
    ///   See CR 13509
    ///   1) Create and soft close billing groups for a given interval.
    ///   2) Set the status of the interval to 'blocked'.
    ///   3) Create an account with the same cycle as the interval.
    ///   4) Make sure that there are no interval mappings for the account in t_acc_usage_interval
    ///   for the blocked interval.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T58TestCreateAccountForBlockedInterval()
    {
      // Create and soft close billing groups
      var intervalId = _util.GetIntervalForFullMaterialization();

      // Block the interval.
      _util.BillingGroupManager.SetIntervalAsBlockedForNewAccounts(intervalId);
      VerifyIntervalStatus(intervalId, UsageIntervalStatus.Blocked);

      // Create an account
      var accounts = CreateAccounts(1, true);

      // Check that no interval mapping exists for the account in t_acc_usage_interval
      var accountId = (int) accounts[0];
      var mappingExists = _util.CheckAccountIntervalMapping(accountId, intervalId);
      Assert.IsFalse(mappingExists,
                     String.Format("Found interval mapping for account '{0}' and interval '{1}' " +
                                   "even though the interval is blocked", accountId, intervalId));
    }

    /// <summary>
    ///   See CR 13509
    ///   1) Hard Close an interval.
    ///   2) Create an account with the same cycle as the interval.
    ///   3) Make sure that the account is created in the 'Hard Closed' state.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T59TestCreateAccountForHardClosedInterval()
    {
      // Create and soft close billing groups
      var intervalId = HardCloseInterval();

      // Create an account
      var accounts = CreateAccounts(1, true);

      // Check that the account status is 'H'
      _util.VerifyAccountStatus(accounts, intervalId, "H");
    }


    /// <summary>
    ///   See CR 12867
    ///   1) Create an account (A1).
    ///   2) Create an account template for this account (T).
    ///   3) Subscribe the template to the 'Simple Product Offering'
    ///   4) Create an account (A2) with its parent set to (A1).
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    [Ignore]
    public void T60TestAccountSubscriptionErrorMessage()
    {
      var accountIds = CreateAccounts(1, true);
      Assert.AreEqual(1, accountIds.Count, "Expected one account");

      var originalAccountName = Util.GetAccountName((int) accountIds[0]);

      // If the "AudioConference Product Offering USD" found at
      // (T:\Development\Core\UsageServer\Audio-Adj-USD.xml) does not exist, then import it.
      const string fileName = @"T:\Development\Core\UsageServer\Audio-Adj-USD.xml";

      // If the product offering does not exist then run pcimportexport and import it.
      const string productOfferingName = "AudioConference Product Offering USD";
      if (!Util.CheckProductOfferingExists(productOfferingName))
      {
        var pcImportWrapper = new PCImportWrapper();
        pcImportWrapper.ImportProductOffering(fileName, "");
      }

      // Create the sessionContext
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      var sessionContext = (YAAC.IMTSessionContext) loginContext.Login("su", "system_user", "su123");


      // Create an account catalog
      var accCatalog = new YAAC.MTAccountCatalog();
      accCatalog.Init(sessionContext);

      // Create an account template 
      var departmentYaac = accCatalog.GetAccountByName(originalAccountName, "mt", null);
      IAccountTypeManager accountTypeManager = new AccountTypeManager();
      var accountType =
        accountTypeManager.GetAccountTypeByName
          ((IMTSessionContext) sessionContext, Util.AccountType);
      Assert.IsNotNull(accountType);

      var accTemplate = departmentYaac.GetAccountTemplate(DateTime.Now, accountType.ID);

      // Create the product catalog and retrieve the product offering
      IMTProductCatalog productCatalog = new MTProductCatalog();
      productCatalog.SetSessionContext
        ((IMTSessionContext) sessionContext);
      IMTProductOffering productOffering =
        productCatalog.GetProductOfferingByName(productOfferingName);
      // Remove account type
      productOffering.RemoveSubscribableAccountType(accountType.ID);

      // Set template properties
      accTemplate.Name = "Test Template for CR 12867";
      var subscriptions = accTemplate.Subscriptions;
      var subscription = subscriptions.AddSubscription();
      subscription.ProductOfferingID = productOffering.ID;
      subscription.StartDate = DateTime.Now;
      subscription.EndDate = DateTime.Now.AddDays(200);
      accTemplate.Save(null);

      // Create an account with the parent as the first account
      _util.CreateAccount(_util.GetUserName(), true, originalAccountName, true);
    }

    /// <summary>
    ///   Hard close an interval with no payer accounts.
    ///   Check that the interval is hard closed.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T61TestHardClosingInterval()
    {
      HardCloseInterval();
    }

    /// <summary>
    ///   Hard close an interval overriding the creation of billing groups.
    ///   Check that the interval is hard closed.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T62TestHardClosingIntervalWithoutBillingGroups()
    {
      var intervalId = _util.GetIntervalForFullMaterialization();

      _util.BillingGroupManager.HardCloseInterval(intervalId, true);

      VerifyIntervalStatus(intervalId, UsageIntervalStatus.HardClosed);
    }

    /// <summary>
    ///   Hard close an interval overriding the creation of billing groups.
    ///   Check that the interval is hard closed.
    /// </summary>
    [Test]
    [Category("Fast")]
    [Category("Billing")]
    public void T63TestHardClosingIntervalWithBillingGroups()
    {
      var intervalId = _util.GetIntervalForFullMaterialization();
      _util.BillingGroupManager.MaterializeBillingGroups(intervalId, _util.UserId);
      // Get the billing groups
      var billingGroups = GetBillingGroups(intervalId);
      SoftCloseInterval(billingGroups);

      _util.BillingGroupManager.HardCloseInterval(intervalId, true);

      VerifyIntervalStatus(intervalId, UsageIntervalStatus.HardClosed);
    }
  }
}