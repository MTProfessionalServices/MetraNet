using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Globalization;
using System.Reflection;
using System.Text;

using NUnit.Framework;

using MetraTech;
using MetraTech.DataAccess;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.Test;
using MetraTech.Test.Common;
using MetraTech.Interop.COMMeter;
using MetraTech.Accounts.Type.Test;
using MetraTech.UsageServer;
using Rowset = MetraTech.Interop.Rowset;
using MetraTech.Interop.NameID;

namespace MetraTech.UsageServer.Test
{
  #region Enums
  public enum CalendarCodeEnum
  {
    Peak,
    OffPeak,
    Holiday,
    Weekend
  }

  public enum PartitionTypes
  {
      [StringValue("Weekly")]
      Weekly,
      [StringValue("Semi-Monthly")]
      SemiMonthly,
      [StringValue("Monthly")]
      Monthly,
      [StringValue("Quarterly")]
      Quarterly
  }
  #endregion

	/// <summary>
	///    Provides functionality that is common to all billing groups unit tests.
	/// </summary>
  public class Util
  {
    #region Public Static Methods
    public static Util GetUtil()
    {
      // Support multithreaded applications through 
      // 'Double checked locking' pattern which (once 
      // the instance exists) avoids locking each 
      // time the method is invoked 
      if (instance == null)
      {
        lock (syncLock)
        {
          if (instance == null)
          {
            instance = new Util();
          }
        }
      }

      return instance;
    }
    #endregion

    #region Public Methods
 
    public void Log(string message) 
    {
      TestLibrary.Trace(message);
      logger.LogDebug(message);
    }

    public void LogError(string message) 
    {
      TestLibrary.Trace(message);
      logger.LogError(message);
    }

    public void Initialize()
    {
      connectionInfo = new ConnectionInfo("NetMeter");
      logger = new Logger("[BillingGroupTest]");
      billingGroupManager = new BillingGroupManager();
      usageIntervalManager = new UsageIntervalManager();
      startDate = new DateTime(2000, 6, 1);
      endDate = DateTime.Now; // new DateTime(2001, 12, 1);
      accountCreator = new TestCreateUpdateAccounts();
      accountCounter = 1;
      corporateAccountUserName = String.Empty;
      recurringEventMap = new Hashtable();
      InitializeAccounts();
      SetupClient();
      SetupRecurringEvents();
    }

    /// <summary>
    ///   Get an interval with paying accounts 
    ///   that has not been materialized and that is
    ///   not hard closed.
    /// </summary>
    /// <returns></returns>
    public int GetIntervalForFullMaterialization() 
    { 
      // Restrict intervals to the right date
      IUsageIntervalFilter filter = GetUsageIntervalFilter();
      filter.HasBeenMaterialized = false;
      filter.HasOpenUnassignedAccounts = true;
      filter.Status = UsageIntervalStatus.Active;

      ArrayList intervals = filter.GetIntervals();

      Assert.IsTrue(intervals.Count > 0, 
        "Could not find an interval to create user defined billing group");

      return ((IUsageInterval)intervals[0]).IntervalID;
      
    }

    public IUsageIntervalFilter GetUsageIntervalFilter()
    {
      IUsageIntervalTimeSpan usageIntervaTimeSpan = new UsageIntervalTimeSpan();
      usageIntervaTimeSpan.StartDate = startDate;
      usageIntervaTimeSpan.EndDate = endDate;
      usageIntervaTimeSpan.StartDateInclusive = true;

      IUsageIntervalFilter usageIntervalFilter = new UsageIntervalFilter();
      usageIntervalFilter.UsageIntervalTimeSpan = usageIntervaTimeSpan;

      return usageIntervalFilter;
    }

    /// <summary>
    ///   Get an interval without any paying accounts that is
    ///   not hard closed.
    /// </summary>
    /// <returns></returns>
    public int GetIntervalWithoutPayers() 
    { 
      int intervalId = Int32.MinValue;
    
      // See if there's an interval without payers
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__GET_INTERVAL_WITHOUT_PAYERS__");

      rowset.AddParam("%%INTERVAL_LIST%%", 
        GetCommaSeparatedIds(this.availableIntervals), 
        true);

      logger.LogInfo("Executing Query [Util.GetUsageIntervalFilter]: -----------------------------------");
      logger.LogInfo(rowset.GetQueryString());
      rowset.Execute();
      

      if (rowset.RecordCount == 1) 
      {
        intervalId = (int)rowset.get_Value("id_interval");
        return intervalId;
      }

      // We didn't find an interval without payers. 
      // Get an interval with payers and delete the payers from t_acc_usage_interval
      intervalId = GetIntervalForFullMaterialization();

      // Make sure that it's a valid interval id
      Assert.AreNotEqual(Int32.MinValue, intervalId, 
        "No interval found for materialization");
            
      rowset.Clear();

      // Delete the paying account mappings for the interval
      rowset.SetQueryTag("__DELETE_PAYERS__");

      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.Execute();

      // Assert if the interval is not found 
      Assert.AreNotEqual(Int32.MinValue, intervalId, 
        "Could not find an interval without any payers!"); 

      return intervalId;
    }

    /// <summary>
    ///   Get an interval that has paying accounts and is hard closed.
    /// </summary>
    /// <returns></returns>
    public int GetHardClosedInterval() 
    { 
      int intervalId = Int32.MinValue;
    
      // See if there's an interval without payers
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__GET_HARD_CLOSED_INTERVAL__");

      rowset.AddParam("%%INTERVAL_LIST%%", 
        GetCommaSeparatedIds(this.availableIntervals), 
        true);
      rowset.Execute();

      if (rowset.RecordCount == 1) 
      {
        intervalId = (int)rowset.get_Value("id_interval");
        return intervalId;
      }

      // We didn't find a hard closed interval.
      // Get an interval with payers and update the status
      // of all payers to 'H' and the interval status to 'H'
      intervalId = GetIntervalForFullMaterialization();

      // Make sure that it's a valid interval id
      Assert.AreNotEqual(Int32.MinValue, intervalId, 
        "No interval found for materialization");
            
      rowset.Clear();

      // Hard close the paying accounts for the interval
      rowset.SetQueryTag("__HARD_CLOSE_PAYING_ACCOUNTS_FOR_INTERVAL__");
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.Execute();

      Assert.AreNotEqual(Int32.MinValue, intervalId, 
        "Could not find a hard closed interval!"); 

      return intervalId;
    }

    /// <summary>
    ///    Get a billing group that has more than one account.
    /// </summary>
    /// <returns></returns>
    public IBillingGroup GetBillingGroup(BillingGroupStatus billingGroupStatus,
      bool noAdapters,
      bool nonPullList)
    {
      IBillingGroup billingGroup = null;

      IBillingGroupFilter filter = new BillingGroupFilter();
      filter.MoreThanOneAccount = true;
      filter.Status = billingGroupStatus.ToString();
      filter.NoAdapters = noAdapters;   
      filter.NonPullList = nonPullList;
   
      Rowset.IMTSQLRowset rowset =
        billingGroupManager.GetBillingGroupsRowset(filter);

      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        billingGroup =
          billingGroupManager.GetBillingGroup((int)rowset.get_Value("BillingGroupID"));
        break;
      }


      Assert.IsTrue(billingGroup != null, "Could not find a billing group!"); 

      return billingGroup;
    }

    /// <summary>
    ///    Create a dummy row in t_recevent_inst for an end of period adapter
    ///    for the given interval id
    /// </summary>
    /// <param name="intervalId"></param>
    public int CreateDummyAdapterRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 2, 
        "CreateDummyAdapterRow called with incorrect number of parameter");

      int intervalId = (int)parameters[0];
      string status = (string)parameters[1];

      int instanceId = Int32.MinValue;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__CREATE_DUMMY_ADAPTER_ROW__");
      rowset.AddParam("%%EVENT_NAME%%", "AggregateCharges", true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.AddParam("%%STATUS%%", status, true);

      rowset.Execute();

      //rowset.Clear();

      //rowset.SetQueryTag("__GET_MAX_ADAPTER_INSTANCE_ID__");
      //rowset.Execute();

      //if (rowset.RecordCount == 1) 
      //{
      //  instanceId = (int)rowset.get_Value("id_instance");
      //}

      //Assert.AreNotEqual(Int32.MinValue, instanceId, 
      //  "Could not create a dummy adapter instance!"); 

      return instanceId;
    }

    /// <summary>
    ///    Create a dummy row in t_billgroup_materialization for the
    ///    given interval and the given status.
    /// 
    ///    Return the materialization id.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="status"></param>
    /// <returns></returns>
    public static int CreateMaterializationRow
      (int intervalId,
       MaterializationStatus materializationStatus,
       MaterializationType materializationType,
       int userAccountId)
    {
      int materializationId = Int32.MinValue;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);

      rowset.SetQueryTag("__CREATE_DUMMY_MATERIALIZATION_ROW__");

      rowset.AddParam("%%USERID%%", userAccountId, true);
      rowset.AddParam("%%DT_START%%", MetraTime.Now, true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.AddParam("%%STATUS%%", materializationStatus.ToString(), true);
      rowset.AddParam("%%TYPE%%", materializationType.ToString(), true);

      rowset.Execute();

      using (IMTConnection conn = ConnectionManager.CreateConnection(queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(queryPath, "__GET_MAX_MATERIALIZATION_ID__"))
          {

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  if (reader.Read())
                  {
                      materializationId = reader.GetInt32("id_materialization");
                  }
              }
          }
      }


      // Assert if the materialization is not created 
      Assert.AreNotEqual(Int32.MinValue, materializationId,
        "Could not create a dummy materialization!");

      return materializationId;
    }

    public static int GetMaxBillGroupId()
    {
      int maxBillGroupId = 0;

      using (IMTConnection conn = ConnectionManager.CreateConnection(queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(queryPath, "__GET_MAX_BILLGROUP_ID__"))
          {

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  if (reader.Read())
                  {
                      maxBillGroupId = reader.GetInt32("id_billgroup");
                  }
              }
          }
      }

      return maxBillGroupId;
    }
    /// <summary>
    ///   Create a row in t_billgroup_source_acc.
    ///   Parameters expected:
    ///     [0] = interval id
    ///     [1] = materialization id
    ///     [2] = account id
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="accountId"></param>
    public void CreateDummyBillGroupSourceAccRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 3, 
        "CreateDummyBillGroupSourceAccRow called with incorrect number of parameters");

      int materializationId = (int)parameters[1];
      int accountId = (int)parameters[2];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__CREATE_DUMMY_BILLGROUP_SOURCE_ACC_ROW__");
      rowset.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
      rowset.AddParam("%%ID_ACC%%", accountId, true);
     
      rowset.Execute();
    }

    /// <summary>
    ///   Create a row in t_billgroup_constraint_tmp.
    ///    Parameters expected:
    ///     [0] = interval id
    ///     [1] = materialization id
    ///     [2] = group id
    ///     [3] = account id
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="accountId"></param>
    public void CreateDummyBillGroupConstraintTmpRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 4, 
        "CreateDummyBillGroupConstraintTmpRow called with incorrect number of parameters");

      int intervalId = (int)parameters[0];
      int groupId = (int)parameters[2];
      int accountId = (int)parameters[3];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__CREATE_DUMMY_BILLGROUP_CONSTRAINT_TMP_ROW__");
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.AddParam("%%ID_GROUP%%", groupId, true);
      rowset.AddParam("%%ID_ACC%%", accountId, true);
     
      rowset.Execute();
    }

    /// <summary>
    ///   Create a row in t_billgroup_source_acc.
    ///   Parameters expected:
    ///     [0] = interval id
    ///     [1] = materialization id
    ///     [2] = billgroupName
    ///     [3] = accountId
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="accountId"></param>
    public void CreateDummyBillGroupMemberTmpRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 4, 
        "CreateDummyBillGroupMemberTmpRow called with incorrect number of parameters");

      int materializationId = (int)parameters[1];
      string billgroupName = (string)parameters[2];
      int accountId = (int)parameters[3];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__CREATE_DUMMY_BILLGROUP_MEMBER_TMP_ROW__");
      rowset.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
      rowset.AddParam("%%TX_NAME%%", billgroupName, true);
      rowset.AddParam("%%ID_ACC%%", accountId, true);
     
      rowset.Execute();
    }

    /// <summary>
    ///   Create a row in t_billgroup_source_acc.
    ///   Parameters expected:
    ///     [0] = interval id
    ///     [1] = materialization id
    ///     [2] = billgroupName
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="accountId"></param>
    public void CreateDummyBillGroupTmpRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 3, 
        "CreateDummyBillGroupTmpRow called with incorrect number of parameters");

      int materializationId = (int)parameters[1];
      string billgroupName = (string)parameters[2];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__CREATE_DUMMY_BILLGROUP_TMP_ROW__");
      rowset.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
      rowset.AddParam("%%TX_NAME%%", billgroupName, true);
     
      rowset.Execute();
    }

    
    /// <summary>
    ///   Create a row in t_billgroup_source_acc.
    ///   Parameters expected:
    ///     [0] = interval id
    ///     [1] = materialization id
    ///     [2] = paying accountId
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="accountId"></param>
    public void DeleteBillGroupMemberTmpRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 3, 
        "DeleteBillGroupMemberTmpRow called with incorrect number of parameters");

      int materializationId = (int)parameters[1];
      int accountId = (int)parameters[2];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__DELETE_BILLGROUP_MEMBER_TMP_ROW__");
      rowset.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
      rowset.AddParam("%%ID_ACC%%", accountId, true);
     
      rowset.Execute();
    }

    /// <summary>
    ///   Create a row in t_billgroup_source_acc.
    ///   Parameters expected:
    ///     [0] = interval id
    ///     [1] = materialization id
    ///     [2] = comma separated string of account id's
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="accountId"></param>
    public void DeleteAccountsForBillGroup(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 3, 
        "DeleteAccountsForBillGroup called with incorrect number of parameters");

      int materializationId = (int)parameters[1];
      string accountIds = (string)parameters[2];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__DELETE_ACCOUNTS_FOR_BILLGROUP__");
      rowset.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
      rowset.AddParam("%%ACCOUNT_LIST%%", accountIds, true);
     
      rowset.Execute();
    }
    /// <summary>
    ///    Delete the row in t_recevent_inst which was created with 
    ///    CreateDummyAdapterRow
    /// </summary>
    /// <param name="intervalId"></param>
    public void DeleteDummyAdapterRow(int instanceId)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__DELETE_DUMMY_ADAPTER_ROW__");
      rowset.AddParam("%%ID_INSTANCE%%", instanceId, true);
     
      rowset.Execute();
    }

    /// <summary>
    ///    Delete the row in t_recevent_inst which was created with 
    ///    CreateDummyAdapterRow by specifying the status
    /// </summary>
    /// <param name="intervalId"></param>
    public void DeleteDummyAdapterRow(string status)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__DELETE_DUMMY_ADAPTER_ROWS__");
      rowset.AddParam("%%STATUS%%", status, true);

      rowset.Execute();
    }

    /// <summary>
    ///    Delete the row in t_billgroup_materialization which was created with 
    ///    CreateDummyMaterializationRow
    /// </summary>
    /// <param name="intervalId"></param>
    public void DeleteDummyMaterializationRow(int materializationId)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__DELETE_DUMMY_MATERIALIZATION_ROW__");
      rowset.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
     
      rowset.Execute();
    }

    /// <summary>
    ///    Get the next open interval id.
    /// </summary>
    /// <param name="intervalId"></param>
    public int GetNextOpenInterval(int intervalId)
    {
      int nextIntervalId = 0;

      IUsageInterval usageInterval = 
        UsageIntervalManager.GetUsageInterval(intervalId);

      DateTime startDate = usageInterval.StartDate.AddDays(7);
      DateTime endDate = usageInterval.EndDate.AddDays(7);

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__GET_INTERVAL__");
      rowset.AddParam("%%DT_START%%", startDate, true);
      rowset.AddParam("%%DT_END%%", endDate, true);
     
      rowset.Execute();

      Assert.AreEqual(1, rowset.RecordCount, "'GetNextOpenInterval' - rowset count mismatch");

      nextIntervalId = (int)rowset.get_Value("id_interval");

      Assert.AreNotEqual(0, nextIntervalId, "'GetNextOpenInterval' - invalid interval");

      return nextIntervalId;
    }

    /// <summary>
    ///   Verify that the each of the accounts in accounts have
    ///   the given status in t_acc_usage_interval.
    /// </summary>
    /// <param name="accounts"></param>
    /// <param name="status"></param>
    public void VerifyAccountStatus(ArrayList accounts, int intervalId, string status)
    {
      string accountIds = GetCommaSeparatedIds(accounts);

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__GET_ACCOUNT_STATUS__");
      rowset.AddParam("%%ACCOUNT_LIST%%", accountIds, true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
     
      rowset.Execute();

      Assert.AreEqual(1, rowset.RecordCount, 
        "'VerifyAccountStatus' rowset count mismatch");

      string foundStatus = (string)rowset.get_Value("tx_status");

      Assert.AreEqual(status.ToUpper(), foundStatus.ToUpper(),
        "'VerifyAccountStatus' - mismatched status");

    }

    /// <summary>
    ///   Delete usage for each of the accounts in 'accounts' and
    ///   the given interval.
    /// </summary>
    /// <param name="accounts"></param>
    /// <param name="status"></param>
    public static void DeleteUsage(ArrayList accounts, int intervalId)
    {
      string accountIds = GetCommaSeparatedIds(accounts);

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__DELETE_USAGE__");
      rowset.AddParam("%%ACCOUNT_LIST%%", accountIds, true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
     
      rowset.Execute();
    }

    /// <summary>
    ///   Update the status of intervals to hard closed for those
    ///   intervals which have a start date earlier than the given date.
    /// </summary>
    /// <param name="date"></param>
    public void UpdatePreviousIntervalsToHardClosed(int intervalId)
    {
      IUsageInterval usageInterval = 
        UsageIntervalManager.GetUsageInterval(intervalId);

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__UPDATE_PREVIOUS_INTERVAL_STATUS_TO_HARD_CLOSED__");
      rowset.AddParam("%%DT_START%%", usageInterval.StartDate, true);
    
      rowset.Execute();
    }

    public static string GetCommaSeparatedIds(List<int> idList)
    {
      return GetCommaSeparatedIds(new ArrayList(idList));
    }

    /// <summary>
    ///   Given an ArrayList of id's (integers), get a comma separated string
    ///   of the corresponding id's.
    /// </summary>
    /// <param name="accountNames"></param>
    /// <returns></returns>
    public static string GetCommaSeparatedIds(ArrayList idList) 
    {
      StringBuilder commaSeparatedString = new StringBuilder();

      bool firstId = true;

      foreach(int id in idList) 
      {
        if (firstId) 
        {
          commaSeparatedString.Append(id);
          firstId = false;
        }
        else 
        {
          commaSeparatedString.Append(",");
          commaSeparatedString.Append(id);
        }
      }

      return commaSeparatedString.ToString();
    }

    public void AddToUsAccountIds(ArrayList extraAccounts) 
    {
      usAccounts.AddRange(extraAccounts);
    }

    public void AddToPayeeAccountIds(ArrayList extraAccounts) 
    {
      payeeAccountIds.AddRange(extraAccounts);
    }

    public void AddToPayerAccountIds(ArrayList extraAccounts) 
    {
      payerAccountIds.AddRange(extraAccounts);
    }

    public IRecurringEvent GetRecurringEvent(string eventName) 
    {
      IRecurringEvent recurringEvent = (IRecurringEvent)recurringEventMap[eventName];
      Assert.AreNotEqual(null, recurringEvent, 
        String.Format("Recurring event '{0}' not found", eventName));
      return recurringEvent;
    }

    /// <summary>
    ///   Return the recurring event for the given classNameAndProgId.
    ///   The classNameAndProgId value must match the tx_class_name column in t_recevent.
    /// </summary>
    /// <param name="classNameAndProgId"></param>
    /// <returns></returns>
    public IRecurringEvent GetRecurringEventFromClassNameAndProgId(string classNameAndProgId)
    {
      IRecurringEvent recurringEvent = null;
      foreach(IRecurringEvent tmpRecurringEvent in recurringEventMap.Values)
      {
        if (String.Compare(classNameAndProgId, tmpRecurringEvent.ClassName, true) == 0)
        {
          recurringEvent = tmpRecurringEvent;
          break;
        }
      }
      Assert.AreNotEqual(null, recurringEvent, 
        String.Format("Recurring event '{0}' not found", classNameAndProgId));
      return recurringEvent;
    }
    /// <summary>
    ///    1) Synchronize db with the given recurring events file or
    ///       do the default synchronization ie. synchronize across all 
    ///       recurring_events.xml files in R:\extensions
    ///    2) Update dt_activated on the events
    ///    3) Refresh event Hashtable
    /// </summary>
    /// <param name="fileName"></param>
    public void SetupAdapterDependencies(string fileName)
    {
      

      // Synchronize config file
      ArrayList addedEvents, removedEvents, modifiedEvents;
      if (fileName == null || fileName == String.Empty) 
      {
        Client.Synchronize(out addedEvents, out removedEvents, out modifiedEvents);
      }
      else 
      {
        Client.Synchronize(fileName, out addedEvents, out removedEvents, out modifiedEvents);
      }

      // Reset event dates
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__RESET_EVENT_DATES__");
      rowset.AddParam("%%START_DATE%%", startDate, true);
      rowset.Execute(); 

      // Refresh event Hashtable
      SetupRecurringEvents();
    }

    /// <summary>
    ///   Return true if the given calendarName exists in the database.
    /// </summary>
    /// <param name="calendarName"></param>
    /// <returns></returns>
    public static bool CheckProductOfferingExists(string productOfferingName) 
    {
      bool offeringExists = false;
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__GET_PRODUCT_OFFERING_NAME__");

      rowset.AddParam("%%PRODUCT_OFFERING_NAME%%", productOfferingName, true);
      rowset.Execute();

      if (rowset.RecordCount == 1) 
      {
        offeringExists = true;
      }

      return offeringExists;
    }

    /// <summary>
    ///    
    /// </summary>
    /// <param name="intervalId"></param>
    public void DeleteTestPI()
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__DELETE_PV_TESTPI__");
      // rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
     
      rowset.Execute();
    }

    public bool CheckPvTestPI(int timeZoneId, CalendarCodeEnum calendarCodeEnum) 
    {
      bool foundRow = false;
      int calendarCodeId = GetCalendarCodeId(calendarCodeEnum);

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__CHECK_PV_TESTPI__");
      rowset.AddParam("%%TIME_ZONE_ID%%", timeZoneId, true);
      rowset.AddParam("%%CALENDAR_CODE_ID%%", calendarCodeId, true);
     
      rowset.Execute();

      if (rowset.RecordCount == 1) 
      {
        foundRow = true;
      }

      return foundRow;
    }
    
    /// <summary>
    ///   Return true if there is an interval mapping for the given account and the given interval
    ///   in t_acc_usage_interval. 
    /// </summary>
    /// <param name="accountId"></param>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    public bool CheckAccountIntervalMapping(int accountId, int intervalId)
    {
      bool mappingExists = false;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__CHECK_ACCOUNT_INTERVAL_MAPPING__");
      rowset.AddParam("%%ID_ACC%%", accountId, true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
     
      rowset.Execute();

      if (rowset.RecordCount > 0) 
      {
        mappingExists = true;
      }
      
      return mappingExists;
    }

    /// <summary>
    ///   Return the calendar code id from t_enum_data for the given calendarCodeEnum
    ///   eg. metratech.com/calendar/CalendarCode/Holiday = 814
    /// </summary>
    /// <param name="calendarCodeEnum"></param>
    /// <returns></returns>
    public int GetCalendarCodeId(CalendarCodeEnum calendarCodeEnum) 
    {
      string prefix = @"metratech.com/calendar/CalendarCode/";
      string suffix = calendarCodeEnum.ToString();

      if (calendarCodeEnum == CalendarCodeEnum.OffPeak) 
      {
        suffix = "Off-Peak";
      }

      IMTNameID nameId = new MTNameID();
      return nameId.GetNameID(prefix + suffix);
    }

    #endregion

    #region Properties
    public Client Client
    {
      get 
      {
        return client;
      }
    }

    public Auth.IMTSessionContext SessionContext
    {
      get 
      {
        return sessionContext;
      }
    }

    public BillingGroupManager BillingGroupManager
    {
      get 
      {
        return billingGroupManager;
      }
    }

    public UsageIntervalManager UsageIntervalManager
    {
      get 
      {
        return usageIntervalManager;
      }
    }

    public int UserId 
    {
      get 
      {
        return userId;
      }
    }

    public DateTime StartDate
    {
      get 
      {
        return startDate;
      }
    }

    public DateTime EndDate
    {
      get 
      {
        return endDate;
      }
    }

    public ArrayList PayerAccountIds 
    {
      get 
      {
        return (ArrayList)payerAccountIds.Clone();
      }
    }

    public ArrayList PayeeAccountIds 
    {
      get 
      {
        return (ArrayList)payeeAccountIds.Clone();
      }
    }

    public ArrayList UsAccountIds 
    {
      get 
      {
        return (ArrayList)usAccounts.Clone();
      }
    }

    public ArrayList UkAccountIds 
    {
      get 
      {
        return (ArrayList)ukAccounts.Clone();
      }
    }

    public ArrayList BrazilAccountIds 
    {
      get 
      {
        return (ArrayList)brazilAccounts.Clone();
      }
    }

    public string CorporateAccountUserName
    {
      get 
      {
        return corporateAccountUserName;
      }
    }
    public TestCreateUpdateAccounts AccountCreator
    {
      get 
      {
        return accountCreator;
      }
    }

    public Logger Logger
    {
      get 
      {
        return logger;
      }
    }

    public bool IsOracle
    {
      get 
      {
        return connectionInfo.DatabaseType == DBType.Oracle;
      }
    }

    public ArrayList BillingGroupAccountIds
    {
      get 
      {
        ArrayList billingGroupAccountIds = new ArrayList();
        billingGroupAccountIds.AddRange(payerAccountIds);
        billingGroupAccountIds.AddRange(payeeAccountIds);
        return billingGroupAccountIds;
      }
    }

    #endregion

    #region Protected Methods
      protected Util()
		{
      Initialize();
		}
    #endregion

    #region Private Methods
    private void SetupClient()
    {
      client = new Client();
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      sessionContext = loginContext.Login("su", "system_user", "su123");
      client.SessionContext = sessionContext;
    }

    /// <summary>
    ///   Create a Hashtable mapping event id to IRecurringEvent 
    /// </summary>
    private void SetupRecurringEvents()
    {
      recurringEventMap.Clear();
      RecurringEventManager manager = new RecurringEventManager();
      recurringEventMap = manager.LoadEventsFromDB();
    }

    private void InitializeAccounts() 
    {
      ClearData();

      logger.LogDebug("Creating accounts for billing group testing...");

      // Create the corporate account
      corporateAccountUserName = GetUserName();
      CreateCorporateAccount(corporateAccountUserName);

//      AccountSpecification accountSpecification = new AccountSpecification();
//      accountSpecification.usernamePrefix = "BlGrpTest";
//      accountSpecification.accountType = "DepartmentAccount";
//      accountSpecification.usageCycleType = "weekly";
//      accountSpecification.startDate = startDate;
//      accountSpecification.numberOfBillableAccounts = 
//        Util.numberOfPayerAccounts - 1;  // one paying account has already been created
//      accountSpecification.numberOfNonBillableAccounts = Util.numberOfPayeeAccounts;
//      accountSpecification.corporateAccountName = corpAccountUserName;

      // Create accounts and collect results
      CreateAccounts(corporateAccountUserName,
                     out availableIntervals, 
                     out payerAccountIds,
                     out payeeAccountIds);

      Assert.IsTrue(availableIntervals.Count > 0, "Expected one or more intervals");
      Assert.IsTrue(Util.numberOfPayerAccounts == payerAccountIds.Count, "Number of payer accounts mismatched");
      Assert.IsTrue(Util.numberOfPayeeAccounts == payeeAccountIds.Count, "Number of payee accounts mismatched");


      // Set the country codes on the paying accounts 
      SetCountryCodes();

      logger.LogDebug("Created {0} billable and {1} non-billable accounts which " +
                      "were mapped to {2} intervals.", 
                      payerAccountIds.Count,
                      payeeAccountIds.Count,
                      availableIntervals.Count);
    }

    /// <summary>
    ///    Set one third of the accounts to 'USA'.
    ///        one third of the accounts to 'UK'.
    ///        one third of the accounts to 'Brazil'.
    ///    
    /// </summary>
    private void SetCountryCodes() 
    {
      int accountId = 0;

      ukAccounts = new ArrayList();
      brazilAccounts = new ArrayList();
      usAccounts = new ArrayList();

      // total number of accounts
      int numAccountsPerGroup = payerAccountIds.Count / 3;

      // Set 'UK'
      for (int i = 0; i < numAccountsPerGroup; i++) 
      {
        accountId = (int)payerAccountIds[i];
        SetCountryCode(accountId, Util.ukCountryName);
        ukAccounts.Add(accountId);
      }

      // Set 'Brazil'
      for (int i = numAccountsPerGroup; i < (2 * numAccountsPerGroup); i++) 
      {
        accountId = (int)payerAccountIds[i];
        SetCountryCode(accountId, Util.brazilCountryName);
        brazilAccounts.Add(accountId);
      }

      for (int i = 2 * numAccountsPerGroup; i < payerAccountIds.Count; i++) 
      {
        usAccounts.Add((int)payerAccountIds[i]);
      }

      usAccounts.AddRange(payeeAccountIds);
    }

    /// <summary>
    ///   Move the given accountId from the payer list to the payee list.
    /// </summary>
    /// <param name="accountId"></param>
    public void MoveAccountFromPayerToPayee(int accountToUpdate, 
                                            DateTime dateOfChange,
                                            int payerId)
    {
      // Create a NameValueCollection and populate it with the following properties
      // payerID, payment_startdate, billable
      NameValueCollection propertyBag = new NameValueCollection();
      propertyBag["payerID"] = Convert.ToString(payerId);
      propertyBag["payment_startdate"] = dateOfChange.ToString();
      propertyBag["billable"] = "F";
      propertyBag["accounttype"] = Util.accountType;
      propertyBag["operation"] = "update";
      propertyBag["actiontype"] = "Both";
      propertyBag["name_space"] = Util.accountNamespace;
	  
      // Update the account. 
      // Change its status. 
      // Change its payer. 
      // Specify its payment start date.
      accountCreator.UpdateAccount("metratech.com/accountcreation",
                                    GetAccountName(accountToUpdate),
                                    propertyBag);

      if (payerAccountIds.Contains(accountToUpdate))
      {
        payerAccountIds.Remove(accountToUpdate);
      }
      else 
      {
        Assert.Fail("Unable to locate account id in the list of paying accounts");
      }

      payeeAccountIds.Add(accountToUpdate);
    }
    /// <summary>
    ///    Set the country code for the given account id and the given country name.
    /// </summary>
    /// <param name="accountId"></param>
    /// <param name="countryCode"></param>
    private void SetCountryCode(int accountId, string countryName) 
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__SET_COUNTRY_CODE__");

      rowset.AddParam("%%COUNTRY_NAME%%", countryName, true);
      rowset.AddParam("%%ID_ACC%%", accountId, true);

      rowset.Execute();
    }

    /// <summary>
    ///    Create a specified number of billable and non-billable accounts based
    ///    on the given accountSpecification.
    ///    Meter them.
    ///    Return the intervals mapped to the billable accounts created.
    /// </summary>
    public void CreateAccounts(string parentAccountUserName,
                               out ArrayList intervals,
                               out ArrayList payerAccountIds,
                               out ArrayList payeeAccountIds) 
    {
       
      // Create billable accounts
      this.payerUserNames = CreateAccount(true);
      // Convert payerUserNames to payer account id's
      payerAccountIds = ConvertUserNameToAccountId(payerUserNames);
      
      // Add the corporate account 
      int corporateAccountId = GetAccountId(parentAccountUserName);

      payerAccountIds.Add(corporateAccountId);
      payerUserNames.Add(parentAccountUserName);

      // Create non billable accounts
      this.payeeUserNames = CreateAccount(false);
      // Convert payeeUserNames to payee account id's
      payeeAccountIds = ConvertUserNameToAccountId(payeeUserNames);

      // Create a comma separated string of the payer and payee account id's
      string accounts = 
        GetCommaSeparatedIds(payerAccountIds) + "," + 
        GetCommaSeparatedIds(payeeAccountIds);

      int numAccounts = payerAccountIds.Count + payeeAccountIds.Count;

      intervals = GetIntervals(accounts, numAccounts);
    }

    /// <summary>
    ///    Create a corporate account with the given name.
    /// </summary>
    /// <returns></returns>
    private void CreateCorporateAccount(string accountName)
    {
      accountCreator.YetAnotherCreateAccount
        (accountName,
         "USD",                               
         Util.cycleType,
         "CorporateAccount",
         "TestCorporation",
         true, 
         "", 
         "", 
         @"metratech.com/accountcreation",
         Util.dayOfMonthOrWeek, 
         startDate,
         countryName,
         -1,
         null,
         false);
    }

    /// <summary>
    ///    Create accounts based on accountSpecification.
    ///    If 'isPayer' is true, then create only billable accounts, otherwise
    ///    create only non billable accounts.
    ///    
    ///    Return the list of account names created.
    /// </summary>
    /// <param name="accountSpecification"></param>
    /// <param name="isPayer"></param>
    private ArrayList CreateAccount(bool isPayer) 
    {
      int count = 0;
      string username = String.Empty;
      ArrayList usernames = new ArrayList();

      if (isPayer)
      {
        count = Util.numberOfPayerAccounts - 1; // we've already created a corporate acc 
      }
      else 
      {
        count = Util.numberOfPayeeAccounts;
      }

      for (int i = 0; i < count; i++) 
      {
        username = GetUserName();

        // Create the account
        CreateAccount(username, isPayer);
        usernames.Add(username);
      }

      return usernames;
    }

    /// <summary>
    ///   Create an account with the given username and billability(!)
    ///   Return the account id.
    /// </summary>
    /// <param name="accountUserName"></param>
    /// <param name="isPayer"></param>
    public int CreateAccount(string accountUserName,
                             bool isPayer)
    {
      string payerAccount = String.Empty;
      if (!isPayer)
      {
        payerAccount = corporateAccountUserName;
      }
   
      accountCreator.YetAnotherCreateAccount
        (accountUserName,
        "USD",                               
        Util.cycleType,
        accountType,
        "TestCorporation",
        isPayer, 
        payerAccount, // payer
        corporateAccountUserName, // ancestor
        @"metratech.com/accountcreation",
        Util.dayOfMonthOrWeek, 
        startDate,
        countryName,
        -1,
        null,
        false);

      return GetAccountId(accountUserName);
    }

    /// <summary>
    ///   Create an account with the given username, billability(!), ancestorAccount.
    ///   If applyTemplates is true, then the ancestors account template will be applied to this account.
    ///   
    ///   Return the account id.
    /// </summary>
    /// <param name="accountUserName"></param>
    /// <param name="isPayer"></param>
    public int CreateAccount(string accountUserName,
                             bool isPayer,
                             string ancestorAccount,
                             bool applyTemplates)
    {
      string payerAccount = String.Empty;
      if (!isPayer)
      {
        payerAccount = ancestorAccount;
      }
   
      accountCreator.YetAnotherCreateAccount
        (accountUserName,
        "USD",                               
        Util.cycleType,
        accountType,
        "TestCorporation",
        isPayer, 
        payerAccount, // payer
        ancestorAccount, // ancestor
        @"metratech.com/accountcreation",
        Util.dayOfMonthOrWeek, 
        startDate,
        countryName,
        -1,
        null,
        applyTemplates);

      return GetAccountId(accountUserName);
    }

    /// <summary>
    ///   Create an account with the given username, billability(!), timeZoneId and pricelist.
    ///   Return the account id.
    /// </summary>
    /// <param name="accountUserName"></param>
    /// <param name="isPayer"></param>
    public int CreateAccount(string accountUserName,
                             bool isPayer,
                             int timeZoneId,
                             string pricelist)
    {
      string payerAccount = String.Empty;
      if (!isPayer)
      {
        payerAccount = corporateAccountUserName;
      }
   
      accountCreator.YetAnotherCreateAccount
        (accountUserName,
        "USD",                               
        Util.cycleType,
        accountType,
        "TestCorporation",
        isPayer, 
        payerAccount, // payer
        corporateAccountUserName, // ancestor
        @"metratech.com/accountcreation",
        Util.dayOfMonthOrWeek, 
        startDate,
        countryName,
        timeZoneId,
        pricelist,
        false);

      return GetAccountId(accountUserName);
    }

    /// <summary>
    ///    Return a user name based on the prefix and counter of the form:
    ///    prefix_1_Wednesday_May_16_2001_3:02:15_AM
    /// </summary>
    /// <param name="prefix"></param>
    /// <param name="counter"></param>
    /// <returns></returns>
    public string GetUserName() 
    {
      DateTime now = MetraTime.Now;
      return userNamePrefix + "_" + 
             accountCounter++ + "_" + 
             now.ToString("s", DateTimeFormatInfo.InvariantInfo);
    }

    /// <summary>
    ///    Return the list of intervals which have account mappings for 
    ///    only those account id's specified in 'commaSeparatedAccountIds'. 
    /// </summary>
    /// <param name="username"></param>
    /// <returns>list of interval id's</returns>
    private ArrayList GetIntervals(string commaSeparatedAccountIds, int numAccounts)
    {
      ArrayList intervals = new ArrayList();

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__GET_INTERVALS_FOR_BILLING_GROUP_TESTS__");

      rowset.AddParam("%%COMMA_SEPARATED_ACCOUNT_IDS%%", commaSeparatedAccountIds, true);
      rowset.AddParam("%%NUMBER_OF_ACCOUNTS%%", numAccounts, true);

      rowset.Execute();
     
      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        intervals.Add((int)rowset.get_Value("id_usage_interval"));
        rowset.MoveNext();
      }

      return intervals;
    }

    

    /// <summary>
    ///   Return the account id for the given user name. 
    ///   Return Int32.MinValue if the account is not found.
    /// </summary>
    /// <param name="username"></param>
    /// <returns>account id or Int32.MinValue if it's not found</returns>
    public int GetAccountId(string username)
    {
      int accountId = Int32.MinValue;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__GET_ACCOUNT_ID_USG_TEST__");

      rowset.AddParam("%%USER_NAME%%", username, true);
	  rowset.AddParam("%%NAMESPACE%%", Util.accountNamespace, true);
      rowset.Execute();

      if (rowset.RecordCount == 1) 
      {
        accountId = (int)rowset.get_Value("id_acc");
      }

      return accountId;
    }

    public static string GetAccountName(int accountId)
    {
      string accountName = String.Empty;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__GET_ACCOUNT_NAME__");

      rowset.AddParam("%%ID_ACC%%", accountId, true);
	  rowset.AddParam("%%NAMESPACE%%", Util.accountNamespace, true);
      rowset.Execute();

      if (rowset.RecordCount == 1) 
      {
        accountName = (string)rowset.get_Value("nm_login");
      }

      return accountName;
    }
 
    /// <summary>
    ///    Return the list of account names for the given list of account ids.
    /// </summary>
    /// <param name="accountIds"></param>
    /// <returns></returns>
    public ArrayList GetAccountNames(ArrayList accountIds) 
    {
      ArrayList accountNames = new ArrayList();

      foreach(int accountId in accountIds) 
      {
        accountNames.Add(GetAccountName(accountId));
      }
      return accountNames;
    }

    /// <summary>
    ///   Verify that there are 'numberOfSessions' rows of usage
    ///   in t_acc_usage for the given accountId and intervalId.
    ///   
    ///   If 'exists' is false, then verify that there is no usage
    ///   for the given accountId and intervalId
    /// </summary>
    /// <param name="accountId"></param>
    /// <param name="intervalId"></param>
    public static void VerifyUsage(int accountId, 
                            int intervalId, 
                            bool exists,
                            int numberOfSessions) 
    {
      int numUsage = 0;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__VERIFY_USAGE__");

      rowset.AddParam("%%ID_ACC%%", accountId, true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.Execute();

      Assert.AreEqual(1, rowset.RecordCount, 
                      "'VerifyUsage' - mismatch in record count");
     
      numUsage = Convert.ToInt32(rowset.get_Value("numUsage"));
      
      if (exists)
      {
        Assert.AreEqual(numberOfSessions, numUsage,
                        "'VerifyUsage' - Mismatch in number of usage items");
      }
      else 
      {
        Assert.AreEqual(0, numUsage,
                        "'VerifyUsage' - Mismatch in number of usage items");
      }
    }

    /// <summary>
    ///   Verify that usage for payeeAccountId has moved to payerAccountId.
    ///   1) Get the rows in t_acc_usage which have an id_view of 
    ///      'metratech.com/AccountCredit' for the given interval.
    ///   2) Check that the payer account id has a positive (or zero) amount.
    ///   3) Check that the payee account has a negative (or zero) amount.
    /// </summary>
    /// <param name="payerAccountId"></param>
    /// <param name="payeeAccountId"></param>
    /// <param name="id_interval"></param>
    public void VerifyPaymentRedirection(int payerAccountId,
                                         int payeeAccountId,
                                         int intervalId,
                                         bool exists)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__GET_ACCOUNTS__");

      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.Execute();
      
      // Positive case. Check that the accounts exist. 
      // Check that the amounts are positive/negative depending on payer/payee.
      if (exists)
      {
        Assert.AreEqual(2, rowset.RecordCount, "Mismatch in record count for positive case");
        int dbAccountId1 = (int)rowset.get_Value("id_acc");
        decimal dbAmount1 = (decimal)rowset.get_Value("amount");

        rowset.MoveNext();
        int dbAccountId2 = (int)rowset.get_Value("id_acc");
        decimal dbAmount2 = (decimal)rowset.get_Value("amount");

        if (dbAccountId1 == payerAccountId) 
        {
          Assert.IsTrue(dbAmount1 >= 0, "Expected positive or zero amount for payer");
          Assert.AreEqual(dbAccountId2, payeeAccountId, "Payees don't match");
          Assert.IsTrue(dbAmount2 <= 0, "Expected negative or zero amount for payee");
        }
        else if (dbAccountId1 == payeeAccountId)
        {
          Assert.IsTrue(dbAmount1 <= 0, "Expected negative or zero amount for payee");
          Assert.AreEqual(dbAccountId2, payerAccountId, "Payers don't match");
          Assert.IsTrue(dbAmount2 >= 0, "Expected positive or zero amount for payer");
        }
        else 
        {
          Assert.Fail("Account in database does not match payer or payee");
        }
      }
      else 
      {
        Assert.AreEqual(0, rowset.RecordCount, "Mismatch in record count for negative case");
      }
    }

    /// <summary>
    ///   Get the number of rows in t_acc_usage for the given intervalId
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    public int GetUsageCount(int intervalId) 
    {
      int numRows = 0;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);
      rowset.SetQueryTag("__GET_USAGE_COUNT__");

      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.Execute();

      numRows = (int)rowset.get_Value("UsageCount");

      return numRows;
    }
    /// <summary>
    ///    Return a list of account id's corresponding to the list of
    ///    user names in userNames.
    /// </summary>
    /// <param name="userNames"></param>
    /// <returns></returns>
    private ArrayList ConvertUserNameToAccountId(ArrayList usernames) 
    {
      ArrayList accountIds = new ArrayList();
      int accountId;

      foreach(string username in usernames) 
      {
        accountId = GetAccountId(username);
        // Assert if the username is not found 
        Assert.AreNotEqual(Int32.MinValue, accountId, 
                            String.Format("The username {0} was not found " +
                                          "in the database", username));
        accountIds.Add(accountId);
      }

      return accountIds;
    }

    /// <summary>
    ///    Clear data 
    /// </summary>
    private void ClearData() 
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(queryPath);

      // Clear out adapter data from t_recevent_inst ...
      rowset.SetQueryTag("__CLEAR_ADAPTER_DATA__");
      rowset.AddParam("%%ADAPTER_WHERE_CLAUSE%%", GetAdapterWhereClause(), true);
      logger.LogInfo("Executing Query [Util.ClearData 1]: -----------------------------------");
      logger.LogInfo(rowset.GetQueryString());
      rowset.Execute();
      

      // Reset event dates
      rowset.Clear();
      rowset.SetQueryTag("__RESET_EVENT_DATES__");
      rowset.AddParam("%%START_DATE%%", startDate, true);
      logger.LogInfo("Executing Query [Util.ClearData 2]: -----------------------------------");
      logger.LogInfo(rowset.GetQueryString());
      rowset.Execute();
      

      // Clear out billing group data from t_billgroup... and 
      // account data from t_acc_usage_interval ...
      rowset.Clear();
      rowset.SetQueryTag("__CLEAR_BILLGROUP_AND_ACCOUNT_DATA__");
      rowset.AddParam("%%USAGE_PREDICATE%%", GetUsageWhereClause(), true);
      rowset.AddParam("%%BILLING_GROUP_PREDICATE%%", GetBillingGroupWhereClause(), true);
      logger.LogInfo("Executing Query [Util.ClearData 3]: -----------------------------------");
      logger.LogInfo(rowset.GetQueryString());
      rowset.Execute();
      

      // Clear out invoice data from t_invoice and t_invoice_range
      rowset.Clear();
      rowset.SetQueryTag("__CLEAR_INVOICE_DATA__");
      rowset.AddParam("%%USAGE_PREDICATE%%", GetUsageWhereClause(), true);
      logger.LogInfo("Executing Query [Util.ClearData 4]: -----------------------------------");
      logger.LogInfo(rowset.GetQueryString());
      rowset.Execute();
      

      // Reset all relevant intervals to 'Open'
      rowset.Clear();
      rowset.SetQueryTag("__RESET_INTERVAL_STATUS__");
      rowset.AddParam("%%USAGE_PREDICATE%%", GetUsageWhereClause(), true);
      logger.LogInfo("Executing Query [Util.ClearData 5]: -----------------------------------");
      logger.LogInfo(rowset.GetQueryString());
      rowset.Execute();
      
      
    }

    private string GetUsageWhereClause() 
    {
      return String.Format("ui.dt_start >= {0} AND " + 
                           "ui.dt_start < {1} AND " +
                           "uct.tx_desc = '{2}' AND " +
                           "uc.day_of_week = {3} ",
                           GetDBDateString(startDate), 
                           GetDBDateString(endDate),
                           Util.cycleType,
                           Util.dayOfMonthOrWeek);
    }

    private string GetBillingGroupWhereClause() 
    {
      return String.Format("ui.dt_start >= {0} AND ui.dt_start < {1} ", 
                           GetDBDateString(startDate), 
                           GetDBDateString(endDate));
    }

    private string GetAdapterWhereClause() 
    {
      return String.Format("WHERE ( " +
                           "        ui.dt_start >= {0} AND " +
                           "        ui.dt_start < {1} " + 
                           "      ) " +
                           "      OR " +
                           "      ( " +
                           "        ri.dt_arg_start >= {2} AND " +
                           "        ri.dt_arg_start < {3} " +
                           "       ) ", 
                           GetDBDateString(startDate), 
                           GetDBDateString(endDate),
                           GetDBDateString(startDate), 
                           GetDBDateString(endDate));
    }

    private string GetDBDateString(DateTime date)
    {
      string dateString = date.ToString("yyyy'-'MM'-'dd");

      if (IsOracle)
      {
        dateString = "to_date('" + dateString + "', 'YYYY-MM-DD')";
      }
      else 
      {
        dateString = "'" + dateString + "'";
      }
     
      return dateString;
    }
    #endregion

    #region Data
    // The following three must match the billing group names created
    // by the out-of-the-box assignment query.
    public const string europeBillingGroupName = "Europe";
    public const string northAmericaBillingGroupName = "North America";
    public const string southAmericaBillingGroupName = "South America";
    public const int numBillingGroups = 3;
    public const int numberOfNewAccountsForUserDefinedGroup = 3;
    public const int numberOfNewAccountsToBeHardClosed = 3;
    public const int numberOfSessions = 3;
	public const string accountNamespace = "MT";
    public const string testDir = "T:\\Development\\Core\\UsageServer\\";
    public const string originalRecurringEventFile = "R:\\config\\UsageServer\\recurring_events.xml";
    public const string hardCloseCheckpointName = "HardCloseCheckpoint";
    public const string testPullListName = "Test pull list";
    public const string testPullListDescr = "Testing pull list creation";
    public const string userDefinedGroupName = "Test user defined group";
    public const string userDefinedGroupDescription = "Test user defined group description";
    public const string startRootName = "_StartRoot";
    public const string endRootName = "_EndRoot";
    public const string root = "Root";
    public const string checkpoint = "Checkpoint";
    public const string invoiceAdapterClassName = 
      "MetraTech.UsageServer.Adapters.InvoiceAdapter,MetraTech.UsageServer.Adapters";
    public const string payerChangeAdapterClassName = 
      "MetraTech.AR.Adapters.PayerChangeAdapter,MetraTech.AR.Adapters";

        
    public const string intervalAccountAdapterFileName = "bg_interval_account_adapter_dependency_test.xml";
    public const string intervalBillingGroupAdapterFileName = "bg_interval_billing_group_adapter_dependency_test.xml";
    public const string intervalIntervalAdapterFileName = "bg_interval_interval_adapter_dependency_test.xml";
    
    public const string billingGroupAccountAdapterFileName = "bg_billing_group_account_adapter_dependency_test.xml";
    public const string billingGroupBillingGroupAdapterFileName = "bg_billing_group_billing_group_adapter_dependency_test.xml";
    public const string billingGroupIntervalAdapterFileName = "bg_billing_group_interval_adapter_dependency_test.xml";

    public const string accountAccountAdapterFileName = "bg_account_account_adapter_dependency_test.xml";
    public const string accountBillingGroupAdapterFileName = "bg_account_billing_group_adapter_dependency_test.xml";
    public const string accountIntervalAdapterFileName = "bg_account_interval_adapter_dependency_test.xml";

    public const string accountType = "DepartmentAccount";

    public const string timeZoneDataFileName = "TimeZoneTest.xml";
    public const string timeZoneMappingFileName = "ModifiedTimezone.xml";

    private static Util instance;
    private Auth.IMTSessionContext sessionContext;
    private BillingGroupManager billingGroupManager;
    private UsageIntervalManager usageIntervalManager;
    private Client client;
    private Logger logger;
    TestCreateUpdateAccounts accountCreator;

    // eventName <--> IRecurringEvent
    private Hashtable recurringEventMap;
    private ArrayList availableIntervals;
    private ArrayList payerAccountIds;
    private ArrayList payeeAccountIds;
    private ArrayList payerUserNames;
    private ArrayList payeeUserNames;
    private ArrayList ukAccounts;
    private ArrayList brazilAccounts;
    private ArrayList usAccounts;
    private DateTime startDate; 
    private DateTime endDate;
    private int accountCounter;
    private string corporateAccountUserName;
    private const string userNamePrefix = "BlGrpTest";
    private const string cycleType = "Weekly";
    public const string dailyCycleType = "Daily";
    private const int dayOfMonthOrWeek = 7;
    private const string countryName = "USA";
    private const string corporateAccountName = "BillGroupTestCorp";
    public const string queryPath = @"Queries\UsageServer\Test";
    private const string ukCountryName = "Global/CountryName/United Kingdom";
    private const string brazilCountryName = "Global/CountryName/Brazil";
    private int userId = 123;
    private const int numberOfPayerAccounts = 9;
    private const int numberOfPayeeAccounts = 3;

    // Lock synchronization object 
    private static object syncLock = new object();
    private ConnectionInfo connectionInfo;

    #region Time Zones
    public const int tz_Asia_Kabul = 1;
    #endregion
    
    #endregion
	}

  static class PartitionTypeEnum
  {
      public static string GetStringValue(this Enum value)
      {
          string output = null;
          Type type = value.GetType();

          FieldInfo fi = type.GetField(value.ToString());
          StringValue[] attrs =
              fi.GetCustomAttributes(typeof(StringValue),
                                      false) as StringValue[];
          if (attrs.Length > 0)
          {
              output = attrs[0].Value;
          }

          return output;
      }
  }

  public class StringValue : System.Attribute
  {
      private string _value;

      public StringValue(string value)
      {
          _value = value;
      }

      public string Value
      {
          get { return _value; }
      }
  }
}