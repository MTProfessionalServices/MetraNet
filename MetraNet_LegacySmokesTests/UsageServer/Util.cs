using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text;
using NUnit.Framework;
using MetraTech.DataAccess;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.Accounts.Type.Test;
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
    #region Public Methods

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
      usageIntervaTimeSpan.StartDate = _startDate;
      usageIntervaTimeSpan.EndDate = _endDate;
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
      int intervalId;
    
      // See if there's an interval without payers
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__GET_INTERVAL_WITHOUT_PAYERS__");

      rowset.AddParam("%%INTERVAL_LIST%%", 
        GetCommaSeparatedIds(_availableIntervals), 
        true);

      rowset.Execute();
      

      if (rowset.RecordCount == 1) 
      {
        intervalId = (int)rowset.Value["id_interval"];
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
      int intervalId;
    
      // See if there's an interval without payers
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__GET_HARD_CLOSED_INTERVAL__");

      rowset.AddParam("%%INTERVAL_LIST%%", 
        GetCommaSeparatedIds(_availableIntervals), 
        true);
      rowset.Execute();

      if (rowset.RecordCount == 1) 
      {
        intervalId = (int)rowset.Value["id_interval"];
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
        _billingGroupManager.GetBillingGroupsRowset(filter);

      while (!Convert.ToBoolean(rowset.EOF))
      {
        billingGroup =
          _billingGroupManager.GetBillingGroup((int)rowset.Value["BillingGroupID"]);
        break;
      }


      Assert.IsTrue(billingGroup != null, "Could not find a billing group!"); 

      return billingGroup;
    }

	  /// <summary>
	  ///    Create a dummy row in t_recevent_inst for an end of period adapter
	  ///    for the given interval id
	  /// </summary>
	  /// <param name="parameters"></param>
	  public void CreateDummyAdapterRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 2, 
        "CreateDummyAdapterRow called with incorrect number of parameter");

      var intervalId = (int)parameters[0];
      var status = (string)parameters[1];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__CREATE_DUMMY_ADAPTER_ROW__");
      rowset.AddParam("%%EVENT_NAME%%", "AggregateCharges", true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.AddParam("%%STATUS%%", status, true);
      rowset.Execute();
    }

    /// <summary>
    ///    Create a dummy row in t_billgroup_materialization for the
    ///    given interval and the given status.
    /// 
    ///    Return the materialization id.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="materializationStatus"></param>
    /// <param name="materializationType"></param>
    /// <param name="userAccountId"></param>
    /// <returns></returns>
    public static int CreateMaterializationRow
      (int intervalId,
       MaterializationStatus materializationStatus,
       MaterializationType materializationType,
       int userAccountId)
    {
      var materializationId = Int32.MinValue;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);

      rowset.SetQueryTag("__CREATE_DUMMY_MATERIALIZATION_ROW__");

      rowset.AddParam("%%USERID%%", userAccountId, true);
      rowset.AddParam("%%DT_START%%", MetraTime.Now, true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.AddParam("%%STATUS%%", materializationStatus.ToString(), true);
      rowset.AddParam("%%TYPE%%", materializationType.ToString(), true);

      rowset.Execute();

      using (IMTConnection conn = ConnectionManager.CreateConnection(QueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(QueryPath, "__GET_MAX_MATERIALIZATION_ID__"))
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

      using (IMTConnection conn = ConnectionManager.CreateConnection(QueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(QueryPath, "__GET_MAX_BILLGROUP_ID__"))
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
    /// <param name="parameters"></param>
    public void CreateDummyBillGroupSourceAccRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 3, 
        "CreateDummyBillGroupSourceAccRow called with incorrect number of parameters");

      var materializationId = (int)parameters[1];
      var accountId = (int)parameters[2];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
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
    /// <param name="parameters"></param>
    public void CreateDummyBillGroupConstraintTmpRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 4, 
        "CreateDummyBillGroupConstraintTmpRow called with incorrect number of parameters");

      var intervalId = (int)parameters[0];
      var groupId = (int)parameters[2];
      var accountId = (int)parameters[3];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
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
    /// <param name="parameters"></param>
    public void CreateDummyBillGroupMemberTmpRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 4, 
        "CreateDummyBillGroupMemberTmpRow called with incorrect number of parameters");

      var materializationId = (int)parameters[1];
      var billgroupName = (string)parameters[2];
      var accountId = (int)parameters[3];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
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
    /// <param name="parameters"></param>
    public void CreateDummyBillGroupTmpRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 3, 
        "CreateDummyBillGroupTmpRow called with incorrect number of parameters");

      var materializationId = (int)parameters[1];
      var billgroupName = (string)parameters[2];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
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
    /// <param name="parameters"></param>
    public void DeleteBillGroupMemberTmpRow(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 3, 
        "DeleteBillGroupMemberTmpRow called with incorrect number of parameters");

      var materializationId = (int)parameters[1];
      var accountId = (int)parameters[2];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
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
    /// <param name="parameters"></param>
    public void DeleteAccountsForBillGroup(object[] parameters)
    {
      Assert.IsTrue(parameters.Length == 3, 
        "DeleteAccountsForBillGroup called with incorrect number of parameters");

      var materializationId = (int)parameters[1];
      var accountIds = (string)parameters[2];

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__DELETE_ACCOUNTS_FOR_BILLGROUP__");
      rowset.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
      rowset.AddParam("%%ACCOUNT_LIST%%", accountIds, true);
     
      rowset.Execute();
    }
    /// <summary>
    ///    Delete the row in t_recevent_inst which was created with 
    ///    CreateDummyAdapterRow
    /// </summary>
    /// <param name="instanceId"></param>
    public void DeleteDummyAdapterRow(int instanceId)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__DELETE_DUMMY_ADAPTER_ROW__");
      rowset.AddParam("%%ID_INSTANCE%%", instanceId, true);
     
      rowset.Execute();
    }

    /// <summary>
    ///    Delete the row in t_recevent_inst which was created with 
    ///    CreateDummyAdapterRow by specifying the status
    /// </summary>
    /// <param name="status"></param>
    public void DeleteDummyAdapterRow(string status)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__DELETE_DUMMY_ADAPTER_ROWS__");
      rowset.AddParam("%%STATUS%%", status, true);

      rowset.Execute();
    }

    /// <summary>
    ///    Delete the row in t_billgroup_materialization which was created with 
    ///    CreateDummyMaterializationRow
    /// </summary>
    /// <param name="materializationId"></param>
    public void DeleteDummyMaterializationRow(int materializationId)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
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
      var usageInterval = UsageIntervalManager.GetUsageInterval(intervalId);

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__GET_INTERVAL__");
      rowset.AddParam("%%DT_START%%", usageInterval.StartDate.AddDays(7), true);
      rowset.AddParam("%%DT_END%%", usageInterval.EndDate.AddDays(7), true);
     
      rowset.Execute();

      Assert.AreEqual(1, rowset.RecordCount, "'GetNextOpenInterval' - rowset count mismatch");

      var nextIntervalId = (int)rowset.Value["id_interval"];

      Assert.AreNotEqual(0, nextIntervalId, "'GetNextOpenInterval' - invalid interval");

      return nextIntervalId;
    }

	  /// <summary>
	  ///   Verify that the each of the accounts in accounts have
	  ///   the given status in t_acc_usage_interval.
	  /// </summary>
	  /// <param name="accounts"></param>
	  /// <param name="intervalId"></param>
	  /// <param name="status"></param>
	  public void VerifyAccountStatus(ArrayList accounts, int intervalId, string status)
    {
      var accountIds = GetCommaSeparatedIds(accounts);

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__GET_ACCOUNT_STATUS__");
      rowset.AddParam("%%ACCOUNT_LIST%%", accountIds, true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
     
      rowset.Execute();

      Assert.AreEqual(1, rowset.RecordCount, 
        "'VerifyAccountStatus' rowset count mismatch");

      var foundStatus = (string)rowset.Value["tx_status"];

      Assert.AreEqual(status.ToUpper(), foundStatus.ToUpper(),
        "'VerifyAccountStatus' - mismatched status");
    }

    /// <summary>
    ///   Delete usage for each of the accounts in 'accounts' and
    ///   the given interval.
    /// </summary>
    /// <param name="accounts"></param>
    /// <param name="intervalId"></param>
    public static void DeleteUsage(ArrayList accounts, int intervalId)
    {
      string accountIds = GetCommaSeparatedIds(accounts);

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__DELETE_USAGE__");
      rowset.AddParam("%%ACCOUNT_LIST%%", accountIds, true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
     
      rowset.Execute();
    }

    /// <summary>
    ///   Update the status of intervals to hard closed for those
    ///   intervals which have a start date earlier than the given date.
    /// </summary>
    /// <param name="intervalId"></param>
    public void UpdatePreviousIntervalsToHardClosed(int intervalId)
    {
      IUsageInterval usageInterval = 
        UsageIntervalManager.GetUsageInterval(intervalId);

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
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
    /// <param name="idList"></param>
    /// <returns></returns>
    public static string GetCommaSeparatedIds(ArrayList idList) 
    {
      var commaSeparatedString = new StringBuilder();
      var firstId = true;

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
      _usAccounts.AddRange(extraAccounts);
    }

    public void AddToPayeeAccountIds(ArrayList extraAccounts) 
    {
      _payeeAccountIds.AddRange(extraAccounts);
    }

    public void AddToPayerAccountIds(ArrayList extraAccounts) 
    {
      _payerAccountIds.AddRange(extraAccounts);
    }

    public IRecurringEvent GetRecurringEvent(string eventName) 
    {
      var recurringEvent = (IRecurringEvent)_recurringEventMap[eventName];
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
      var recurringEvent =
        _recurringEventMap.Values.Cast<IRecurringEvent>()
                         .FirstOrDefault(
                           tmpRecurringEvent =>
                           String.Compare(classNameAndProgId, tmpRecurringEvent.ClassName,
                                          StringComparison.OrdinalIgnoreCase) == 0);
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
      if (string.IsNullOrEmpty(fileName)) 
      {
        Client.Synchronize(out addedEvents, out removedEvents, out modifiedEvents);
      }
      else 
      {
        Client.Synchronize(fileName, out addedEvents, out removedEvents, out modifiedEvents);
      }

      // Reset event dates
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__RESET_EVENT_DATES__");
      rowset.AddParam("%%START_DATE%%", _startDate, true);
      rowset.Execute(); 

      // Refresh event Hashtable
      SetupRecurringEvents();
    }

    /// <summary>
    ///   Return true if the given calendarName exists in the database.
    /// </summary>
    /// <param name="productOfferingName"></param>
    /// <returns></returns>
    public static bool CheckProductOfferingExists(string productOfferingName) 
    {
      var offeringExists = false;
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__GET_PRODUCT_OFFERING_NAME__");

      rowset.AddParam("%%PRODUCT_OFFERING_NAME%%", productOfferingName, true);
      rowset.Execute();

      if (rowset.RecordCount == 1) 
      {
        offeringExists = true;
      }

      return offeringExists;
    }

    public void DeleteTestPi()
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__DELETE_PV_TESTPI__");
      rowset.Execute();
    }

    public bool CheckPvTestPi(int timeZoneId, CalendarCodeEnum calendarCodeEnum) 
    {
      var foundRow = false;
      var calendarCodeId = GetCalendarCodeId(calendarCodeEnum);

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
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
      var mappingExists = false;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
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
      const string prefix = @"metratech.com/calendar/CalendarCode/";
      var suffix = calendarCodeEnum.ToString();

      if (calendarCodeEnum == CalendarCodeEnum.OffPeak) 
      {
        suffix = "Off-Peak";
      }

      IMTNameID nameId = new MTNameID();
      return nameId.GetNameID(prefix + suffix);
    }

    #endregion

    #region Properties
	  public static Util Instance
	  {
      get { return _instance; }
	  }

    public Client Client
    {
      get 
      {
        return _client;
      }
    }

    public Auth.IMTSessionContext SessionContext
    {
      get 
      {
        return _sessionContext;
      }
    }

    public BillingGroupManager BillingGroupManager
    {
      get 
      {
        return _billingGroupManager;
      }
    }

    public UsageIntervalManager UsageIntervalManager
    {
      get 
      {
        return _usageIntervalManager;
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
        return _startDate;
      }
    }

    public DateTime EndDate
    {
      get 
      {
        return _endDate;
      }
    }

    public ArrayList PayerAccountIds 
    {
      get 
      {
        return (ArrayList)_payerAccountIds.Clone();
      }
    }

    public ArrayList PayeeAccountIds 
    {
      get 
      {
        return (ArrayList)_payeeAccountIds.Clone();
      }
    }

    public ArrayList UsAccountIds 
    {
      get 
      {
        return (ArrayList)_usAccounts.Clone();
      }
    }

    public ArrayList UkAccountIds 
    {
      get 
      {
        return (ArrayList)_ukAccounts.Clone();
      }
    }

    public ArrayList BrazilAccountIds 
    {
      get 
      {
        return (ArrayList)_brazilAccounts.Clone();
      }
    }

    public string CorporateAccountUserName
    {
      get 
      {
        return _corporateAccountUserName;
      }
    }
    public TestCreateUpdateAccounts AccountCreator
    {
      get 
      {
        return _accountCreator;
      }
    }

    public bool IsOracle
    {
      get 
      {
        return _connectionInfo.DatabaseType == DBType.Oracle;
      }
    }

    public ArrayList BillingGroupAccountIds
    {
      get 
      {
        var billingGroupAccountIds = new ArrayList();
        billingGroupAccountIds.AddRange(_payerAccountIds);
        billingGroupAccountIds.AddRange(_payeeAccountIds);
        return billingGroupAccountIds;
      }
    }

    #endregion

	  #region Private Methods

	  private Util()
	  {
	    _connectionInfo = new ConnectionInfo("NetMeter");
	    _billingGroupManager = new BillingGroupManager();
	    _usageIntervalManager = new UsageIntervalManager();
	    _startDate = new DateTime(2000, 6, 1);
	    _endDate = DateTime.Now; // new DateTime(2001, 12, 1);
	    _accountCreator = new TestCreateUpdateAccounts();
	    _accountCounter = 1;
	    _corporateAccountUserName = String.Empty;
	    _recurringEventMap = new Hashtable();
	    InitializeAccounts();
	    SetupClient();
	    SetupRecurringEvents();
	  }
    
    private void SetupClient()
    {
      _client = new Client();
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      _sessionContext = loginContext.Login("su", "system_user", "su123");
      _client.SessionContext = _sessionContext;
    }

    /// <summary>
    ///   Create a Hashtable mapping event id to IRecurringEvent 
    /// </summary>
    private void SetupRecurringEvents()
    {
      _recurringEventMap.Clear();
      var manager = new RecurringEventManager();
      _recurringEventMap = manager.LoadEventsFromDB();
    }

    private void InitializeAccounts() 
    {
      ClearData();

      // Create the corporate account
      _corporateAccountUserName = GetUserName();
      CreateCorporateAccount(_corporateAccountUserName);

      // Create accounts and collect results
      CreateAccounts(_corporateAccountUserName,
                     out _availableIntervals, 
                     out _payerAccountIds,
                     out _payeeAccountIds);

      Assert.IsTrue(_availableIntervals.Count > 0, "Expected one or more intervals");
      Assert.IsTrue(NumberOfPayerAccounts == _payerAccountIds.Count, "Number of payer accounts mismatched");
      Assert.IsTrue(NumberOfPayeeAccounts == _payeeAccountIds.Count, "Number of payee accounts mismatched");


      // Set the country codes on the paying accounts 
      SetCountryCodes();
    }

    /// <summary>
    ///    Set one third of the accounts to 'USA'.
    ///        one third of the accounts to 'UK'.
    ///        one third of the accounts to 'Brazil'.
    ///    
    /// </summary>
    private void SetCountryCodes() 
    {
      int accountId;
      _ukAccounts = new ArrayList();
      _brazilAccounts = new ArrayList();
      _usAccounts = new ArrayList();

      // total number of accounts
      var numAccountsPerGroup = _payerAccountIds.Count / 3;

      // Set 'UK'
      for (var i = 0; i < numAccountsPerGroup; i++) 
      {
        accountId = (int)_payerAccountIds[i];
        SetCountryCode(accountId, UkCountryName);
        _ukAccounts.Add(accountId);
      }

      // Set 'Brazil'
      for (int i = numAccountsPerGroup; i < (2 * numAccountsPerGroup); i++) 
      {
        accountId = (int)_payerAccountIds[i];
        SetCountryCode(accountId, BrazilCountryName);
        _brazilAccounts.Add(accountId);
      }

      for (int i = 2 * numAccountsPerGroup; i < _payerAccountIds.Count; i++) 
      {
        _usAccounts.Add((int)_payerAccountIds[i]);
      }

      _usAccounts.AddRange(_payeeAccountIds);
    }

    /// <summary>
    ///   Move the given accountId from the payer list to the payee list.
    /// </summary>
    /// <param name="accountToUpdate"></param>
    /// <param name="dateOfChange"></param>
    /// <param name="payerId"></param>
    public void MoveAccountFromPayerToPayee(int accountToUpdate, 
                                            DateTime dateOfChange,
                                            int payerId)
    {
      // Create a NameValueCollection and populate it with the following properties
      // payerID, payment_startdate, billable
      var propertyBag = new NameValueCollection();
      propertyBag["payerID"] = Convert.ToString(payerId);
      propertyBag["payment_startdate"] = dateOfChange.ToString(CultureInfo.InvariantCulture);
      propertyBag["billable"] = "F";
      propertyBag["accounttype"] = AccountType;
      propertyBag["operation"] = "update";
      propertyBag["actiontype"] = "Both";
      propertyBag["name_space"] = AccountNamespace;
	  
      // Update the account. 
      // Change its status. 
      // Change its payer. 
      // Specify its payment start date.
      _accountCreator.UpdateAccount("metratech.com/accountcreation",
                                    GetAccountName(accountToUpdate),
                                    propertyBag);

      if (_payerAccountIds.Contains(accountToUpdate))
      {
        _payerAccountIds.Remove(accountToUpdate);
      }
      else 
      {
        Assert.Fail("Unable to locate account id in the list of paying accounts");
      }

      _payeeAccountIds.Add(accountToUpdate);
    }
    /// <summary>
    ///    Set the country code for the given account id and the given country name.
    /// </summary>
    /// <param name="accountId"></param>
    /// <param name="countryName"></param>
    private static void SetCountryCode(int accountId, string countryName) 
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
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
      _payerUserNames = CreateAccount(true);
      // Convert payerUserNames to payer account id's
      payerAccountIds = ConvertUserNameToAccountId(_payerUserNames);
      
      // Add the corporate account 
      int corporateAccountId = GetAccountId(parentAccountUserName);

      payerAccountIds.Add(corporateAccountId);
      _payerUserNames.Add(parentAccountUserName);

      // Create non billable accounts
      _payeeUserNames = CreateAccount(false);
      // Convert payeeUserNames to payee account id's
      payeeAccountIds = ConvertUserNameToAccountId(_payeeUserNames);

      // Create a comma separated string of the payer and payee account id's
      var accounts = 
        GetCommaSeparatedIds(payerAccountIds) + "," + 
        GetCommaSeparatedIds(payeeAccountIds);

      var numAccounts = payerAccountIds.Count + payeeAccountIds.Count;

      intervals = GetIntervals(accounts, numAccounts);
    }

    /// <summary>
    ///    Create a corporate account with the given name.
    /// </summary>
    /// <returns></returns>
    private void CreateCorporateAccount(string accountName)
    {
      _accountCreator.YetAnotherCreateAccount
        (accountName,
         "USD",                               
         CycleType,
         "CorporateAccount",
         "TestCorporation",
         true, 
         "", 
         "", 
         @"metratech.com/accountcreation",
         DayOfMonthOrWeek, 
         _startDate,
         CountryName,
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
    /// <param name="isPayer"></param>
    private ArrayList CreateAccount(bool isPayer) 
    {
      int count;
      var usernames = new ArrayList();

      if (isPayer)
      {
        count = NumberOfPayerAccounts - 1; // we've already created a corporate acc 
      }
      else 
      {
        count = NumberOfPayeeAccounts;
      }

      for (int i = 0; i < count; i++) 
      {
        var username = GetUserName();

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
        payerAccount = _corporateAccountUserName;
      }
   
      _accountCreator.YetAnotherCreateAccount
        (accountUserName,
        "USD",                               
        CycleType,
        AccountType,
        "TestCorporation",
        isPayer, 
        payerAccount, // payer
        _corporateAccountUserName, // ancestor
        @"metratech.com/accountcreation",
        DayOfMonthOrWeek, 
        _startDate,
        CountryName,
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
    /// <param name="ancestorAccount"></param>
    /// <param name="applyTemplates"></param>
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
   
      _accountCreator.YetAnotherCreateAccount
        (accountUserName,
        "USD",                               
        CycleType,
        AccountType,
        "TestCorporation",
        isPayer, 
        payerAccount, // payer
        ancestorAccount, // ancestor
        @"metratech.com/accountcreation",
        DayOfMonthOrWeek, 
        _startDate,
        CountryName,
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
    /// <param name="timeZoneId"></param>
    /// <param name="pricelist"></param>
    public int CreateAccount(string accountUserName,
                             bool isPayer,
                             int timeZoneId,
                             string pricelist)
    {
      string payerAccount = String.Empty;
      if (!isPayer)
      {
        payerAccount = _corporateAccountUserName;
      }
   
      _accountCreator.YetAnotherCreateAccount
        (accountUserName,
        "USD",                               
        CycleType,
        AccountType,
        "TestCorporation",
        isPayer, 
        payerAccount, // payer
        _corporateAccountUserName, // ancestor
        @"metratech.com/accountcreation",
        DayOfMonthOrWeek, 
        _startDate,
        CountryName,
        timeZoneId,
        pricelist,
        false);

      return GetAccountId(accountUserName);
    }

    /// <summary>
    ///    Return a user name based on the prefix and counter of the form:
    ///    prefix_1_Wednesday_May_16_2001_3:02:15_AM
    /// </summary>
    /// <returns></returns>
    public string GetUserName() 
    {
      return UserNamePrefix + "_" + 
             _accountCounter++ + "_" +
             MetraTime.Now.ToString("s", DateTimeFormatInfo.InvariantInfo);
    }

    /// <summary>
    ///    Return the list of intervals which have account mappings for 
    ///    only those account id's specified in 'commaSeparatedAccountIds'. 
    /// </summary>
    /// <param name="commaSeparatedAccountIds"></param>
    /// <param name="numAccounts"></param>
    /// <returns>list of interval id's</returns>
    private static ArrayList GetIntervals(string commaSeparatedAccountIds, int numAccounts)
    {
      var intervals = new ArrayList();

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__GET_INTERVALS_FOR_BILLING_GROUP_TESTS__");

      rowset.AddParam("%%COMMA_SEPARATED_ACCOUNT_IDS%%", commaSeparatedAccountIds, true);
      rowset.AddParam("%%NUMBER_OF_ACCOUNTS%%", numAccounts, true);

      rowset.Execute();
     
      while (!Convert.ToBoolean(rowset.EOF))
      {
        intervals.Add((int)rowset.Value["id_usage_interval"]);
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
	    var accountId = Int32.MinValue;

	    Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
	    rowset.Init(QueryPath);
	    rowset.SetQueryTag("__GET_ACCOUNT_ID_USG_TEST__");

	    rowset.AddParam("%%USER_NAME%%", username, true);
	    rowset.AddParam("%%NAMESPACE%%", AccountNamespace, true);
	    rowset.Execute();

	    if (rowset.RecordCount == 1)
	    {
	      accountId = (int) rowset.Value["id_acc"];
	    }

	    return accountId;
	  }

	  public static string GetAccountName(int accountId)
    {
      var accountName = String.Empty;

      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__GET_ACCOUNT_NAME__");

      rowset.AddParam("%%ID_ACC%%", accountId, true);
	  rowset.AddParam("%%NAMESPACE%%", AccountNamespace, true);
      rowset.Execute();

      if (rowset.RecordCount == 1) 
      {
        accountName = (string)rowset.Value["nm_login"];
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
      var accountNames = new ArrayList();

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
    /// <param name="exists"></param>
    /// <param name="numberOfSessions"></param>
    public static void VerifyUsage(int accountId, 
                            int intervalId, 
                            bool exists,
                            int numberOfSessions) 
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__VERIFY_USAGE__");

      rowset.AddParam("%%ID_ACC%%", accountId, true);
      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.Execute();

      Assert.AreEqual(1, rowset.RecordCount, 
                      "'VerifyUsage' - mismatch in record count");
     
      var numUsage = Convert.ToInt32(rowset.Value["numUsage"]);

      Assert.AreEqual(exists ? numberOfSessions : 0, numUsage,
                      "'VerifyUsage' - Mismatch in number of usage items");
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
    /// <param name="intervalId"></param>
    /// <param name="exists"></param>
    public void VerifyPaymentRedirection(int payerAccountId,
                                         int payeeAccountId,
                                         int intervalId,
                                         bool exists)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__GET_ACCOUNTS__");

      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.Execute();
      
      // Positive case. Check that the accounts exist. 
      // Check that the amounts are positive/negative depending on payer/payee.
      if (exists)
      {
        Assert.AreEqual(2, rowset.RecordCount, "Mismatch in record count for positive case");
        var dbAccountId1 = (int)rowset.Value["id_acc"];
        var dbAmount1 = (decimal)rowset.Value["amount"];

        rowset.MoveNext();
        var dbAccountId2 = (int)rowset.Value["id_acc"];
        var dbAmount2 = (decimal)rowset.Value["amount"];

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
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(QueryPath);
      rowset.SetQueryTag("__GET_USAGE_COUNT__");

      rowset.AddParam("%%ID_INTERVAL%%", intervalId, true);
      rowset.Execute();

      return (int)rowset.Value["UsageCount"];
    }
    /// <summary>
    ///    Return a list of account id's corresponding to the list of
    ///    user names in userNames.
    /// </summary>
    /// <param name="usernames"></param>
    /// <returns></returns>
    private ArrayList ConvertUserNameToAccountId(ArrayList usernames) 
    {
      var accountIds = new ArrayList();

      foreach(string username in usernames) 
      {
        var accountId = GetAccountId(username);
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
      rowset.Init(QueryPath);

      // Clear out adapter data from t_recevent_inst ...
      rowset.SetQueryTag("__CLEAR_ADAPTER_DATA__");
      rowset.AddParam("%%ADAPTER_WHERE_CLAUSE%%", GetAdapterWhereClause(), true);
      rowset.Execute();
      

      // Reset event dates
      rowset.Clear();
      rowset.SetQueryTag("__RESET_EVENT_DATES__");
      rowset.AddParam("%%START_DATE%%", _startDate, true);
      rowset.Execute();
      

      // Clear out billing group data from t_billgroup... and 
      // account data from t_acc_usage_interval ...
      rowset.Clear();
      rowset.SetQueryTag("__CLEAR_BILLGROUP_AND_ACCOUNT_DATA__");
      rowset.AddParam("%%USAGE_PREDICATE%%", GetUsageWhereClause(), true);
      rowset.AddParam("%%BILLING_GROUP_PREDICATE%%", GetBillingGroupWhereClause(), true);
      rowset.Execute();
      

      // Clear out invoice data from t_invoice and t_invoice_range
      rowset.Clear();
      rowset.SetQueryTag("__CLEAR_INVOICE_DATA__");
      rowset.AddParam("%%USAGE_PREDICATE%%", GetUsageWhereClause(), true);
      rowset.Execute();
      

      // Reset all relevant intervals to 'Open'
      rowset.Clear();
      rowset.SetQueryTag("__RESET_INTERVAL_STATUS__");
      rowset.AddParam("%%USAGE_PREDICATE%%", GetUsageWhereClause(), true);
      rowset.Execute();
    }

    private string GetUsageWhereClause() 
    {
      return String.Format("ui.dt_start >= {0} AND " + 
                           "ui.dt_start < {1} AND " +
                           "uct.tx_desc = '{2}' AND " +
                           "uc.day_of_week = {3} ",
                           GetDBDateString(_startDate), 
                           GetDBDateString(_endDate),
                           CycleType,
                           DayOfMonthOrWeek);
    }

    private string GetBillingGroupWhereClause() 
    {
      return String.Format("ui.dt_start >= {0} AND ui.dt_start < {1} ", 
                           GetDBDateString(_startDate), 
                           GetDBDateString(_endDate));
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
                           GetDBDateString(_startDate), 
                           GetDBDateString(_endDate),
                           GetDBDateString(_startDate), 
                           GetDBDateString(_endDate));
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
    public const string EuropeBillingGroupName = "Europe";
    public const string NorthAmericaBillingGroupName = "North America";
    public const string SouthAmericaBillingGroupName = "South America";
    public const int NumBillingGroups = 3;
    public const int NumberOfNewAccountsForUserDefinedGroup = 3;
    public const int NumberOfNewAccountsToBeHardClosed = 3;
    public const int NumberOfSessions = 3;
	  public const string AccountNamespace = "MT";
    public const string TestDir = "T:\\Development\\Core\\UsageServer\\";
    public const string OriginalRecurringEventFile = "R:\\config\\UsageServer\\recurring_events.xml";
    public const string HardCloseCheckpointName = "HardCloseCheckpoint";
    public const string TestPullListName = "Test pull list";
    public const string TestPullListDescr = "Testing pull list creation";
    public const string UserDefinedGroupName = "Test user defined group";
    public const string UserDefinedGroupDescription = "Test user defined group description";
    public const string StartRootName = "_StartRoot";
    public const string EndRootName = "_EndRoot";
    public const string Root = "Root";
    public const string checkpoint = "Checkpoint";
    public const string InvoiceAdapterClassName = 
      "MetraTech.UsageServer.Adapters.InvoiceAdapter,MetraTech.UsageServer.Adapters";
    public const string PayerChangeAdapterClassName = 
      "MetraTech.AR.Adapters.PayerChangeAdapter,MetraTech.AR.Adapters";

        
    public const string IntervalAccountAdapterFileName = "bg_interval_account_adapter_dependency_test.xml";
    public const string IntervalBillingGroupAdapterFileName = "bg_interval_billing_group_adapter_dependency_test.xml";
    public const string IntervalIntervalAdapterFileName = "bg_interval_interval_adapter_dependency_test.xml";
    
    public const string BillingGroupAccountAdapterFileName = "bg_billing_group_account_adapter_dependency_test.xml";
    public const string BillingGroupBillingGroupAdapterFileName = "bg_billing_group_billing_group_adapter_dependency_test.xml";
    public const string BillingGroupIntervalAdapterFileName = "bg_billing_group_interval_adapter_dependency_test.xml";

    public const string AccountAccountAdapterFileName = "bg_account_account_adapter_dependency_test.xml";
    public const string AccountBillingGroupAdapterFileName = "bg_account_billing_group_adapter_dependency_test.xml";
    public const string AccountIntervalAdapterFileName = "bg_account_interval_adapter_dependency_test.xml";

    public const string AccountType = "DepartmentAccount";

    public const string TimeZoneDataFileName = "TimeZoneTest.xml";
    public const string TimeZoneMappingFileName = "ModifiedTimezone.xml";

    private static readonly Util _instance = new Util();
    private Auth.IMTSessionContext _sessionContext;
    private readonly BillingGroupManager _billingGroupManager;
    private readonly UsageIntervalManager _usageIntervalManager;
    private Client _client;
    readonly TestCreateUpdateAccounts _accountCreator;

    // eventName <--> IRecurringEvent
    private Hashtable _recurringEventMap;
    private ArrayList _availableIntervals;
    private ArrayList _payerAccountIds;
    private ArrayList _payeeAccountIds;
    private ArrayList _payerUserNames;
    private ArrayList _payeeUserNames;
    private ArrayList _ukAccounts;
    private ArrayList _brazilAccounts;
    private ArrayList _usAccounts;
    private readonly DateTime _startDate;
    private readonly DateTime _endDate;
    private int _accountCounter;
    private string _corporateAccountUserName;
    private const string UserNamePrefix = "BlGrpTest";
    private const string CycleType = "Weekly";
    public const string DailyCycleType = "Daily";
    private const int DayOfMonthOrWeek = 7;
    private const string CountryName = "USA";
	  public const string QueryPath = @"Queries\UsageServer\Test";
    private const string UkCountryName = "Global/CountryName/United Kingdom";
    private const string BrazilCountryName = "Global/CountryName/Brazil";
	  private const int userId = 123;
	  private const int NumberOfPayerAccounts = 9;
    private const int NumberOfPayeeAccounts = 3;

    private readonly ConnectionInfo _connectionInfo;

    #region Time Zones
    public const int TzAsiaKabul = 1;
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
          var attrs =
              fi.GetCustomAttributes(typeof(StringValue),
                                      false) as StringValue[];
          if (attrs != null && attrs.Length > 0)
          {
              output = attrs[0].Value;
          }

          return output;
      }
  }

  public class StringValue : Attribute
  {
      private readonly string _value;

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