using System;
using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using System.IO;
using System.Xml.Serialization;

using MetraTech.DataAccess;
using MetraTech.UsageServer;

namespace MetraTech.UsageServer.Test
{
  public interface IAdapterTest
  {
    void CleanData(Interval interval);
    void InitializeData(Interval interval);
    bool ValidateExecution(Interval interval, BillingGroup billingGroup, out string errors);
    bool ValidateReversal(Interval interval, BillingGroup billingGroup, out string errors);
  }

  public class AdapterTestManager
  {
    #region Public Static Methods

    public static AdapterTestConfig GetAdapterTestConfig(string configFile)
    {
      AdapterTestConfig adapterTestConfig = null;

      using (FileStream fileStream = new FileStream(configFile, FileMode.Open))
      {
        XmlSerializer serializer = new XmlSerializer(typeof(AdapterTestConfig));
        adapterTestConfig = (AdapterTestConfig)serializer.Deserialize(fileStream);
      }

      return adapterTestConfig;
    }

    public static void RunTests(AdapterTestConfig adapterTestConfig, out string errors)
    {
      // Validate config
      string error;

      if (!ValidateConfiguration(adapterTestConfig, out error))
      {
        errors = "Configuration Errors: " + Environment.NewLine + error;
        return;
      }

      Initialize(adapterTestConfig, out errors);

      ProcessAdapters(adapterTestConfig, out errors);
    }

    public static bool ValidateConfiguration(AdapterTestConfig adapterTestConfig, out string errors)
    {
      bool isValid = true;
      StringBuilder errorBuilder = new StringBuilder();
      string error = String.Empty;

      if (adapterTestConfig.Intervals == null)
      {
        errors = String.Format("No intervals specified in the configuration");
        Logger.LogError(error);
        return false;
      }

      if (adapterTestConfig.Adapters == null)
      {
        errors = String.Format("No adapters specified in the configuration");
        Logger.LogError(error);
        return false;
      }

      // Intervals exist
      List<int> missingIds = VerifyIntervals(adapterTestConfig.GetCommaSeparatedIntervalIds());
      if (missingIds.Count > 0)
      {
        error = String.Format("The following intervals were not found in the database: '{0}'",
                              AdapterTestConfig.GetCommaSeparatedIds(missingIds));
        Logger.LogError(error);
        errorBuilder.AppendLine(error);
        isValid = false;
      }

      // Duplicate intervals
      List<int> duplicateIntervals = adapterTestConfig.GetDuplicateIntervals();
      if (duplicateIntervals.Count > 0)
      {
        error = String.Format("The following intervals were repeated in the configuration: '{0}'",
                              AdapterTestConfig.GetCommaSeparatedIds(duplicateIntervals));
        Logger.LogError(error);
        errorBuilder.AppendLine(error);
        isValid = false;
      }

      // Accounts exist
      missingIds = VerifyAccounts(adapterTestConfig.GetCommaSeparatedAccountIds());
      if (missingIds.Count > 0)
      {
        error = String.Format("The following accounts were not found in the database: '{0}'",
                              AdapterTestConfig.GetCommaSeparatedIds(missingIds));
        Logger.LogError(error);
        errorBuilder.AppendLine(error);
        isValid = false;
      }

      foreach (Interval interval in adapterTestConfig.Intervals)
      {
        if (interval.BillingGroups == null || interval.BillingGroups.Length == 0)
        {
          break;
        }

        // duplicate billing group names
        List<string> duplicateBillingGroupNames = interval.GetDuplicateBillingGroupNames();
        if (duplicateBillingGroupNames.Count > 0)
        {
          string billingGroupNames = String.Empty;
          foreach (string billingGroupName in duplicateBillingGroupNames)
          {
            billingGroupNames += billingGroupName + ",";
          }
          error = String.Format("The following billing group names '{0}' were repeated for interval '{1}'",
                                billingGroupNames, interval.Id);
          Logger.LogError(error);
          errorBuilder.AppendLine(error);
          isValid = false;
        }

        
        foreach (BillingGroup billingGroup in interval.BillingGroups)
        {
          // Billing group must have atleast one account
          if (billingGroup.Accounts == null || billingGroup.Accounts.Length == 0)
          {
            error = String.Format("Must specify one or more accounts for billing group '{0}' for interval '{1}'",
                                   billingGroup.Name, interval.Id);
            Logger.LogError(error);
            errorBuilder.AppendLine(error);
            isValid = false;
          }
        }

        // Accounts must be unique across the billing groups
        List<int> duplicateAccounts = interval.GetDuplicateAccountsAcrossBillingGroups();
        if (duplicateAccounts.Count > 0)
        {
          error = String.Format("The following accounts '{0}' are repeated for interval '{1}'",
                                 AdapterTestConfig.GetCommaSeparatedIds(duplicateAccounts), interval.Id);
          Logger.LogError(error);
          errorBuilder.AppendLine(error);
          isValid = false;
        }

        // Account/Interval mapping exists
        missingIds =
          VerifyAccountIntervalMappings(interval.Id, interval.GetCommaSeparatedAccountIds());

        if (missingIds.Count > 0)
        {
          error = String.Format("The following account/interval mappings were not found for accounts '{0}' and interval '{1}'",
                                AdapterTestConfig.GetCommaSeparatedIds(missingIds), interval.Id);
          Logger.LogError(error);
          errorBuilder.AppendLine(error);
          isValid = false;
        }
      }

      foreach (Adapter adapter in adapterTestConfig.Adapters)
      {
        
        if (adapter.Intervals != null)
        {
          foreach (Interval interval in adapter.Intervals)
          {
            // Check that the intervals specifed, exist
            Interval actualInterval = adapterTestConfig.GetInterval(interval.Id);
            if (actualInterval == null)
            {
              error = String.Format("The interval '{0}' for adapter '{1}' has not been specified in the config file.",
                                    interval.Id, adapter.Name);
              Logger.LogError(error);
              errorBuilder.AppendLine(error);
              isValid = false;
            }
            else
            {
              // Check that the billing groups exist
              if (interval.BillingGroups != null)
              {
                foreach (BillingGroup billingGroup in interval.BillingGroups)
                {
                  if (!actualInterval.HasBillingGroup(billingGroup.Name))
                  {
                    error = String.Format("The billing group '{0}' for interval '{1}' for adapter '{2}' has not been specified in the config file.",
                                           billingGroup.Name, interval.Id, adapter.Name);
                    Logger.LogError(error);
                    errorBuilder.AppendLine(error);
                    isValid = false;
                  }
                }
              }
            }
          }
        }
      }

      errors = errorBuilder.ToString();
      return isValid;
    }

    /// <summary>
    ///  (1) Clear data from usm tables for the specified intervals. 
    ///  (2) Clear data from billing group tables for the specified intervals.
    ///  (3) Update t_acc_usage_interval.tx_status to ‘O’ for all specified accounts.
    ///  (4) Update t_usage_interval.tx_interval_status to ‘O’ for all specified intervals
    ///  (5) Create billing group data
    ///  (6) Sync events
    ///  (7) Reset event start dates to 01-01-2001
    /// </summary>
    /// <param name="adapterTestConfig"></param>
    public static void Initialize(AdapterTestConfig adapterTestConfig, out string errors)
    {
      errors = String.Empty;

      List<int> intervals = adapterTestConfig.GetIntervals();

      // (1) Clear usm data
      ClearUsageServerData(intervals);

      // (2) Clear billing group data
      ClearBillingGroupData(intervals);

      // (3) Update t_acc_usage_interval.tx_status to ‘O’ for all specified accounts.
      UpdateAccountStatus(adapterTestConfig.Intervals);

      // (4) Update t_usage_interval.tx_interval_status to ‘O’ for all specified intervals
      UpdateIntervalStatus(intervals);

      // (5) Create billing group data
      CreateBillingGroupData(adapterTestConfig.Intervals, adapterTestConfig.UserId);

      // (6) Sync events
      ArrayList addedEvents, removedEvents, modifiedEvents;
      Client client = new Client();
      client.Synchronize(out addedEvents, out removedEvents, out modifiedEvents);

      // (7) Update event dates to 01-01-2001
      ResetEventDates(new DateTime(2001, 1, 1));
    }

    

    /// <summary>
    ///   Create billing group data for the given intervals/billing groups/accounts
    /// </summary>
    /// <param name="intervals"></param>
    public static void CreateBillingGroupData(Interval[] intervals, int userId)
    {
      foreach (Interval interval in intervals)
      {
        // Proceed only if billing groups have been specified
        if (interval.BillingGroups != null && interval.BillingGroups.Length > 0)
        {
          // Create a row in t_billgroup_materialization
          interval.MaterializationId = 
            Util.CreateMaterializationRow(interval.Id,
                                          MaterializationStatus.Succeeded,
                                          MaterializationType.Full,
                                          userId);

          foreach (BillingGroup billingGroup in interval.BillingGroups)
          {
            // Create a row in t_billgroup
            int billGroupId = Util.GetMaxBillGroupId() + 1;
            CreateBillGroupRow(billGroupId, billingGroup.Name, billingGroup.Description, interval.Id);
            billingGroup.Id = billGroupId;
            
            // Create rows in t_billgroup_member
            foreach (Account account in billingGroup.Accounts)
            {
              CreateBillGroupMemberRow(billGroupId, account.Id, interval.MaterializationId);
            }
          }
        }
      }
    }

    public static void ProcessAdapters(AdapterTestConfig adapterTestConfig, out string errors)
    {
      errors = String.Empty;
      StringBuilder errorBuilder = new StringBuilder();
      string error = String.Empty;

      // Get the events from t_recevent
      RecurringEventManager manager = new RecurringEventManager();
      Hashtable recurringEvents = manager.LoadEventsFromDB();

      foreach (Adapter adapter in adapterTestConfig.Adapters)
      {
        if (adapter.Ignore == true)
        {
          error = String.Format(String.Format("Ignoring adapter '{0}'", adapter.Name));
          Logger.LogError(error);
          errorBuilder.AppendLine(error);
          continue;
        }

        // Get the event
        RecurringEvent recurringEvent = recurringEvents[adapter.Name] as RecurringEvent;
        if (recurringEvent == null)
        {
          error = String.Format("Unable to find recurring event '{0}' from t_recevent", adapter.Name);
          Logger.LogError(error);
          errorBuilder.AppendLine(error);
          continue;
        }

        if (adapter.Intervals == null || adapter.Intervals.Length == 0)
        {
          error = String.Format("No intervals/billing groups specified for adapter '{0}'", adapter.Name);
          Logger.LogError(error);
          errorBuilder.AppendLine(error);
          continue;
        }

        ProcessAdapter(adapter, recurringEvent, adapterTestConfig, out error);

        if (!String.IsNullOrEmpty(error))
        {
          errorBuilder.AppendLine(error);
          Logger.LogError(error);
        }
      }

      errors = errorBuilder.ToString();
    }

    public static void ProcessAdapter(Adapter adapter,
                                      RecurringEvent recurringEvent,
                                      AdapterTestConfig adapterTestConfig,
                                      out string errors)
    {
      string error = String.Empty;
      StringBuilder errorBuilder = new StringBuilder();

      Type testType;
      IAdapterTest adapterTest = GetTestClassInstance(adapter, out testType);

      if (adapterTest == null || testType == null)
      {
        errors = String.Format("Unable to create test class instance for adapter '{0}'", adapter.Name);
        Logger.LogError(errors);
        return;
      }

      foreach (Interval interval in adapter.Intervals)
      {
        Interval completeInterval = adapterTestConfig.GetInterval(interval.Id);

        // clean and initialize 
        adapterTest.CleanData(completeInterval);
        adapterTest.InitializeData(completeInterval);
        
        // test adapter
        TestAdapter(adapter, completeInterval, recurringEvent, adapterTest, out error);
        if (!String.IsNullOrEmpty(error))
        {
          errorBuilder.AppendLine(error);
        }
      }

      errors = errorBuilder.ToString();
    }

    public static void TestAdapter(Adapter adapter, 
                                   Interval interval, 
                                   RecurringEvent recurringEvent,
                                   IAdapterTest adapterTest,
                                   out string errors)
    {
      string error = String.Empty;
      StringBuilder errorBuilder = new StringBuilder();

      // If the adapter is account/billing group then expect to find billing group[s] for each interval
      if (recurringEvent.BillingGroupSupport == BillingGroupSupportType.Account ||
          recurringEvent.BillingGroupSupport == BillingGroupSupportType.BillingGroup)
      {
        if (interval.BillingGroups == null || interval.BillingGroups.Length == 0)
        {
          errors = 
            (String.Format
              ("Unable to process adapter '{0}' for interval '{1}' because no billing group was specified",
               adapter.Name, interval.Id));
          Logger.LogError(errors);
           
          return;
        }

        foreach (BillingGroup billingGroup in interval.BillingGroups)
        {
          TestAdapterForBillingGroup(adapter, interval, billingGroup, recurringEvent, adapterTest, out error);
          if (!String.IsNullOrEmpty(error))
          {
            errorBuilder.AppendLine(error);
          }
        }
      }

      errors = errorBuilder.ToString();
    }

    public static void TestAdapterForBillingGroup(Adapter adapter,
                                                  Interval interval,
                                                  BillingGroup billingGroup,
                                                  RecurringEvent recurringEvent,
                                                  IAdapterTest adapterTest,
                                                  out string error)
    {
      // Update the tx_status for the billing group accounts in t_acc_usage_interval as 'C'
      UpdateAccountStatus(billingGroup.GetCommaSeparatedAccountIds(), interval.Id);

      // Insert a row in t_recevent_inst
      int instanceId = CreateAdapterInstanceRow(recurringEvent.EventID, interval.Id, billingGroup.Id);

      // RecurringEventManager.AcquireInstance
      RecurringEventManager recurringEventManager = new RecurringEventManager();
      int runId = recurringEventManager.AcquireInstance(instanceId, RecurringEventAction.Execute, -1);

      //If runId is negative, we couldn't acquire the instance
      if (runId < 0)
      {
        Logger.LogError("Unable to acquire instance for running: '{0}' result was '{1}'", recurringEvent.Name, runId);
      }

      // Create RecurringEventRunContext
      RecurringEventRunContext context = new RecurringEventRunContext();
      context.UsageIntervalID = interval.Id;
      context.BillingGroupID = billingGroup.Id;
      context.EventType = RecurringEventType.EndOfPeriod;
      context.RunID = runId;

      // Create AdapterInstance
      Logger.LogDebug("Creating instance of the '{0}' adapter with class name '{1}'",
                       recurringEvent.Name, recurringEvent.ClassName);
      bool isLegacyAdapter;
      IRecurringEventAdapter2 adapterInstance =
        AdapterManager.CreateAdapterInstance(recurringEvent.ClassName, out isLegacyAdapter);

      // Get config file
      string configFile =
        AdapterManager.GetAbsoluteConfigFile(recurringEvent.ExtensionName,
                                             recurringEvent.ConfigFileName,
                                             isLegacyAdapter);

      // Initialize
      Logger.LogDebug("Initializing the '{0}' adapter with configuration file '{1}'", recurringEvent.Name, configFile);
      adapterInstance.Initialize(recurringEvent.Name, configFile, AdapterManager.GetSuperUserContext(), false);

      // Execute
      Logger.LogDebug("Executing the '{0}' adapter for interval '{1}' and billing group '{2}'",
                      recurringEvent.Name, interval.Id, billingGroup.Name);
      adapterInstance.Execute(context);

      // Validate execution
      if (adapterTest.ValidateExecution(interval, billingGroup, out error))
      {
        Logger.LogDebug("Validated execution of adapter '{0}' for interval '{1}' and billing group '{2}'",
                         recurringEvent.Name, interval.Id, billingGroup.Name);
      }
      else
      {
        Logger.LogError("Unable to validate execution of adapter '{0}' for interval '{1}' and billing group '{2}'. Error: '{3}'",
                         recurringEvent.Name, interval.Id, billingGroup.Name, error);
      }

      // Reverse 
      if (recurringEvent.Reversibility == ReverseMode.Auto ||
          recurringEvent.Reversibility == ReverseMode.Custom)
      {
        if (adapter.Reverse && String.IsNullOrEmpty(error))
        {
          context.RunIDToReverse = context.RunID;
          adapterInstance.Reverse(context);

          // Validate reversal
          if (adapterTest.ValidateReversal(interval, billingGroup, out error))
          {
            Logger.LogDebug("Validated reversal of adapter '{0}' for interval '{1}' and billing group '{2}'",
                             recurringEvent.Name, interval.Id, billingGroup.Name);
          }
          else
          {
            Logger.LogError("Unable to validate reversal of adapter '{0}' for interval '{1}' and billing group '{2}'. Error: '{3}'",
                             recurringEvent.Name, interval.Id, billingGroup.Name, error);
          }
        }
      }

      // Shutdown adapter
      adapterInstance.Shutdown();
    }

    public static void SetupAdapterData(object testInstance, Interval interval)
    {
      // clean
      MethodInfo methodInfo = GetMethodInfo(testInstance.GetType(), AdapterTestManager.CleanDataMethod);
      Debug.Assert(methodInfo != null);

      methodInfo.Invoke(testInstance, new object[] { interval });

      // initialize
      methodInfo = GetMethodInfo(testInstance.GetType(), AdapterTestManager.InitializeDataMethod);
      Debug.Assert(methodInfo != null);

      methodInfo.Invoke(testInstance, new object[] { interval });
    }

    public static bool ValidateAdapterExecution(object testInstance, Interval interval, out string errorMessage)
    {
      errorMessage = String.Empty;

      // validate
      MethodInfo methodInfo = GetMethodInfo(testInstance.GetType(), AdapterTestManager.ValidateExecutionMethod);
      Debug.Assert(methodInfo != null);

      object[] parameters = new object[2];
      parameters[0] = interval;
      bool isValid = (bool)methodInfo.Invoke(testInstance, parameters);
      errorMessage = (string)parameters[1];

      return isValid;
    }

    public static MethodInfo GetMethodInfo(Type objectType, string methodName)
    {
      MethodInfo methodInfo = null;

      foreach (MethodInfo loopMethodInfo in objectType.GetMethods())
      {
        if (loopMethodInfo.Name.Equals(methodName, StringComparison.InvariantCultureIgnoreCase))
        {
          methodInfo = loopMethodInfo;
          break;
        }
      }

      return methodInfo;
    }

    public static IAdapterTest GetTestClassInstance(Adapter adapter, out Type testType)
    {
      IAdapterTest testInstance = null;
      testType = null;

      string[] classInfo = adapter.TestClass.Split(',');
      if (classInfo.Length != 2)
      {
        Logger.LogError
          (String.Format
            ("The testClass specification '{0}' for adapter '{1}' is not valid.", adapter.TestClass, adapter.Name));

        return testInstance;
      }

      string testClassName = classInfo[0];
      string assemblyName = classInfo[1];

      // Load the assembly
      Assembly assembly = Assembly.Load(new AssemblyName(assemblyName));
      if (assembly == null)
      {
        Logger.LogError
          (String.Format
            ("Unable to load assembly '{0}' for adapter '{2}'", assemblyName, adapter.Name));

        return testInstance;
      }

      // Create the type
      testType = assembly.GetType(testClassName);

      if (testType == null)
      {
        Logger.LogError
          (String.Format
            ("Unable to create type '{0}' from assembly '{1}' for adapter '{2}'", testClassName, assemblyName, adapter.Name));

        return testInstance;
      }

      testInstance = Activator.CreateInstance(testType) as IAdapterTest;
      if (testInstance == null)
      {
        Logger.LogError
          (String.Format
            ("Unable to create instance of type '{0}' from assembly '{1}' for adapter '{2}'", testClassName, assemblyName, adapter.Name));

        return testInstance;
      }

      return testInstance;
    }

    #region SQL Methods
    public static void ClearUsageServerData(List<int> intervals)
    {
      string intervalList = Util.GetCommaSeparatedIds(intervals);

      Logger.LogInfo(String.Format("Clearing usage server data for intervals '{0}'", intervalList));

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__CLEAR_ADAPTER_DATA_2__"))
          {

              stmt.AddParam("%%INTERVALS%%", intervalList, true);

              stmt.ExecuteNonQuery();
          }
      }
    }

    public static void ClearBillingGroupData(List<int> intervals)
    {
      string intervalList = Util.GetCommaSeparatedIds(intervals);

      Logger.LogInfo(String.Format("Clearing billing group data for intervals '{0}'", intervals));

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__CLEAR_BILLGROUP_DATA__"))
          {

              stmt.AddParam("%%INTERVALS%%", intervalList, true);

              stmt.ExecuteNonQuery();
          }
      }
    }

    /// <summary>
    ///    Update t_acc_usage_interval.tx_status to ‘O’ for all specified accounts
    /// </summary>
    /// <param name="intervals"></param>
    public static void UpdateAccountStatus(Interval[] intervals)
    {
      Logger.LogInfo(String.Format("Setting account status to '0'"));

      foreach (Interval interval in intervals)
      {
        foreach (BillingGroup billingGroup in interval.BillingGroups)
        {
          foreach (Account account in billingGroup.Accounts)
          {
            // TODO Very inefficient
              using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
              {
                  using (IMTAdapterStatement stmt =
                    conn.CreateAdapterStatement(Util.queryPath, "__UPDATE_ACCOUNT_INTERVAL_STATUS__"))
                  {

                      stmt.AddParam("%%ID_INTERVAL%%", interval.Id, true);
                      stmt.AddParam("%%ID_ACC%%", account.Id, true);

                      stmt.ExecuteNonQuery();
                  }
              }
          }
        }
      }
    }

    public static void UpdateIntervalStatus(List<int> intervals)
    {
      string intervalList = Util.GetCommaSeparatedIds(intervals);

      Logger.LogInfo(String.Format("Updating status to 'O' for intervals '{0}'", intervals));

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__UPDATE_INTERVAL_STATUS__"))
          {

              stmt.AddParam("%%INTERVALS%%", intervalList, true);

              stmt.ExecuteNonQuery();
          }
      }
    }

    public static void CreateBillGroupRow(int billgroupId, string name, string description, int intervalId)
    {
      Logger.LogInfo(String.Format("Creating billing group with name '{0}' and id '{1}' for interval '{2}'", 
                                   name, billgroupId, intervalId));

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__CREATE_BILLGROUP_ROW__"))
          {

              stmt.AddParam("%%ID_BILLGROUP%%", billgroupId, true);
              stmt.AddParam("%%NAME%%", name, true);
              stmt.AddParam("%%DESCRIPTION%%", description, true);
              stmt.AddParam("%%ID_USAGE_INTERVAL%%", intervalId, true);

              stmt.ExecuteNonQuery();

          }
      }
    }

    public static void CreateBillGroupMemberRow(int id_billgroup, int id_acc, int id_materialization)
    {
      Logger.LogInfo(String.Format("Creating billing group member '{0}' for billing group '{1}'",
                                   id_acc, id_billgroup));

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__CREATE_BILLGROUP_MEMBER_ROW__"))
          {

              stmt.AddParam("%%ID_BILLGROUP%%", id_billgroup, true);
              stmt.AddParam("%%ID_ACC%%", id_acc, true);
              stmt.AddParam("%%ID_MATERIALIZATION%%", id_materialization, true);

              stmt.ExecuteNonQuery();

          }
      }
    }

    public static void ResetEventDates(DateTime date)
    {
      Logger.LogInfo(String.Format("Resetting event dates in t_recevent to '{0}'", date));

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__RESET_EVENT_DATES__"))
          {

              stmt.AddParam("%%START_DATE%%", date, true);

              stmt.ExecuteNonQuery();

          }
      }
    }

    /// <summary>
    ///   Return the instance id.
    /// </summary>
    /// <param name="id_event"></param>
    /// <param name="id_interval"></param>
    /// <param name="id_billgroup"></param>
    /// <returns></returns>
    public static int CreateAdapterInstanceRow(int id_event, 
                                               int id_interval, 
                                               int id_billgroup)
    {
      Logger.LogInfo(String.Format("Creating adapter instance for event '{0}', interval '{1}', billing group '{2}'",
                                   id_event, id_interval, id_billgroup));

      int instanceId = Int32.MinValue;

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__CREATE_ADAPTER_INSTANCE_ROW__"))
          {

              stmt.AddParam("%%ID_EVENT%%", id_event, true);
              stmt.AddParam("%%ID_INTERVAL%%", id_interval, true);
              stmt.AddParam("%%ID_BILLGROUP%%", id_billgroup, true);

              stmt.ExecuteNonQuery();
          }

          using (IMTAdapterStatement stmt1 =
              conn.CreateAdapterStatement(Util.queryPath, "__GET_MAX_ADAPTER_INSTANCE_ID__"))
          {
              using (IMTDataReader reader = stmt1.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      instanceId = reader.GetInt32("id_instance");
                  }
              }
          }
      }

      return instanceId;

    }

    public static void UpdateAccountStatus(string commaSeparatedAccountIds, int intervalId)
    {
      Logger.LogInfo(String.Format("Updating status of accounts in t_acc_usage_interval '{0}' to 'C' for interval '{1}'", 
                                   commaSeparatedAccountIds, intervalId));

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__UPDATE_ACCOUNT_STATUS__"))
          {

              stmt.AddParam("%%ID_INTERVAL%%", intervalId, true);
              stmt.AddParam("%%ACCOUNT_IDS%%", commaSeparatedAccountIds, true);

              stmt.ExecuteNonQuery();
          }
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="commaSeparatedIntervalIds"></param>
    /// <returns></returns>
    public static List<int> VerifyIntervals(string commaSeparatedIntervalIds)
    {
      Logger.LogInfo(String.Format("Verifying intervals '{0}'", commaSeparatedIntervalIds));

      List<int> invalidIntervals = new List<int>();

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__VERIFY_INTERVALS__"))
          {

              stmt.AddParam("%%INTERVAL_IDS%%", commaSeparatedIntervalIds, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      invalidIntervals.Add(reader.GetInt32("id_interval"));
                  }
              }
          }
      }

      return invalidIntervals;

    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="commaSeparatedIntervalIds"></param>
    /// <returns></returns>
    public static List<int> VerifyAccounts(string commaSeparatedAccountIds)
    {
      Logger.LogInfo(String.Format("Verifying accounts '{0}'", commaSeparatedAccountIds));

      List<int> invalidAccounts = new List<int>();

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__VERIFY_ACCOUNTS__"))
          {

              stmt.AddParam("%%ACCOUNT_IDS%%", commaSeparatedAccountIds, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      invalidAccounts.Add(reader.GetInt32("id_acc"));
                  }
              }
          }
      }

      return invalidAccounts;

    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="commaSeparatedIntervalIds"></param>
    /// <returns></returns>
    public static List<int> VerifyAccountIntervalMappings(int intervalId, string commaSeparatedAccountIds)
    {
      Logger.LogInfo(String.Format("Verifying account/interval mappings for accounts '{0}' and interval '{1}'", 
                                   commaSeparatedAccountIds, intervalId));

      List<int> invalidAccounts = new List<int>();

      using (IMTConnection conn = ConnectionManager.CreateConnection(Util.queryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(Util.queryPath, "__VERIFY_ACCOUNT_INTERVAL_MAPPING__"))
          {

              stmt.AddParam("%%ACCOUNT_IDS%%", commaSeparatedAccountIds, true);
              stmt.AddParam("%%ID_INTERVAL%%", intervalId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      invalidAccounts.Add(reader.GetInt32("id_acc"));
                  }
              }
          }
      }

      return invalidAccounts;

    }
    #endregion

    #endregion

    #region Data
    public static Logger Logger = new Logger("[AdapterTest]");
    private const string CleanDataMethod = "CleanData";
    private const string InitializeDataMethod = "InitializeData";
    private const string ValidateExecutionMethod = "ValidateExecution";
    private const string ValidateReversalMethod = "ValidateReversal";

    #endregion
  }
  
   [XmlRoot("adapterTestConfig")]
  public class AdapterTestConfig
  {
    [XmlElement(ElementName = "userId", Type = typeof(int))]
    public int UserId;

    [XmlElement(ElementName = "interval", Type = typeof(Interval))]
    public Interval[] Intervals;

    [XmlElement(ElementName = "adapter", Type = typeof(Adapter))]
    public Adapter[] Adapters;

    /// <summary>
    ///   Return the specified list of intervals
    /// </summary>
    /// <returns></returns>
    public List<int> GetIntervals()
    {
      List<int> intervals = new List<int>();

      foreach (Interval interval in Intervals)
      {
        intervals.Add(interval.Id);
      }

      return intervals;
    }

    public List<int> GetDuplicateIntervals()
    {
      List<int> duplicates = new List<int>();
      Dictionary<int, int> dictionary = new Dictionary<int, int>();

      foreach (Interval interval in Intervals)
      {
        if (dictionary.ContainsKey(interval.Id))
        {
          duplicates.Add(interval.Id);
        }
        else
        {
          dictionary.Add(interval.Id, 0);
        }
      }

      return duplicates;
    }

    /// <summary>
    ///   Return the specified list of accounts
    /// </summary>
    /// <returns></returns>
    public List<int> GetAccounts()
    {
      List<int> accounts = new List<int>();
    
      foreach (Interval interval in Intervals)
      {
        if (interval.BillingGroups != null)
        {
          foreach (BillingGroup billingGroup in interval.BillingGroups)
          {
            if (billingGroup.Accounts != null)
            {
              foreach (Account account in billingGroup.Accounts)
              {
                accounts.Add(account.Id);
              }
            }
          }
        }
      }

      return accounts;
    }

    public string GetCommaSeparatedAccountIds()
    {
      return AdapterTestConfig.GetCommaSeparatedIds(GetAccounts());
    }

    public string GetCommaSeparatedIntervalIds()
    {
      return AdapterTestConfig.GetCommaSeparatedIds(GetIntervals());
    }

    public BillingGroup GetBillingGroup(int intervalId, string billingGroupName)
    {
      BillingGroup billingGroup = null;

      foreach (Interval interval in Intervals)
      {
        if (interval.Id == intervalId)
        {
          foreach (BillingGroup loopBillingGroup in interval.BillingGroups)
          {
            if (loopBillingGroup.Name.Equals(billingGroupName, StringComparison.InvariantCultureIgnoreCase))
            {
              billingGroup = loopBillingGroup;
              break;
            }
          }

          if (billingGroup != null)
          {
            break;
          }
        }
      }

      return billingGroup;
    }

    public Interval GetInterval(int intervalId)
    {
      Interval interval = null;

      foreach (Interval loopInterval in Intervals)
      {
        if (loopInterval.Id == intervalId)
        {
          interval = loopInterval;
          break;
        }
      }
      return interval;
    }

    /// <summary>
    ///   
    /// </summary>
    /// <returns></returns>
    public List<string> Validate()
    {
      List<string> errors = new List<string>();

      // Check intervals exist


      // Check accounts exist


      // Check 
      return errors;
    }

    public static string GetCommaSeparatedIds(List<int> ids)
    {
      StringBuilder commaSeparatedString = new StringBuilder();

      bool firstId = true;

      foreach (int id in ids)
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
  }

  [Serializable]
  [XmlRoot("interval")]
  public class Interval
  {
    [XmlAttribute("id")]
    public int Id;

    [XmlElement(ElementName = "billingGroup", Type = typeof(BillingGroup))]
    public BillingGroup[] BillingGroups;

    public int MaterializationId;

    public List<int> GetAccounts()
    {
      List<int> accounts = new List<int>();

      if (BillingGroups != null)
      {
        foreach (BillingGroup billingGroup in BillingGroups)
        {
          if (billingGroup.Accounts != null)
          {
            foreach (Account account in billingGroup.Accounts)
            {
              accounts.Add(account.Id);
            }
          }
        }
      }
      return accounts;
    }

    public List<int> GetBillingGroupIds()
    {
      List<int> ids = new List<int>();

      foreach (BillingGroup billingGroup in BillingGroups)
      {
        ids.Add(billingGroup.Id);
      }

      return ids;
    }

    public bool HasBillingGroup(string name)
    {
      bool hasBillingGroup = false;

      if (BillingGroups != null)
      {
        foreach (BillingGroup billingGroup in BillingGroups)
        {
          if (billingGroup.Name == name)
          {
            hasBillingGroup = true;
            break;
          }
        }
      }
      return hasBillingGroup;
    }

    public string GetCommaSeparatedAccountIds()
    {
      return AdapterTestConfig.GetCommaSeparatedIds(GetAccounts());
    }

    public string GetCommaSeparatedBillGroupIds()
    {
      return AdapterTestConfig.GetCommaSeparatedIds(GetBillingGroupIds());
    }

    public List<string> GetDuplicateBillingGroupNames()
    {
      List<string> duplicates = new List<string>();
      Dictionary<string, int> dictionary = new Dictionary<string, int>();

      foreach (BillingGroup billingGroup in BillingGroups)
      {
        if (dictionary.ContainsKey(billingGroup.Name))
        {
          duplicates.Add(billingGroup.Name);
        }
        else
        {
          dictionary.Add(billingGroup.Name, 0);
        }
      }

      return duplicates; 
    }

    public List<int> GetDuplicateAccountsAcrossBillingGroups()
    {
      List<int> duplicates = new List<int>();
      Dictionary<int, int> dictionary = new Dictionary<int, int>();

      foreach (BillingGroup billingGroup in BillingGroups)
      {
        if (billingGroup.Accounts != null)
        {
          foreach (Account account in billingGroup.Accounts)
          {
            if (dictionary.ContainsKey(account.Id))
            {
              duplicates.Add(account.Id);
            }
            else
            {
              dictionary.Add(account.Id, 0);
            }
          }
        }
      }

      return duplicates;
    }
  }

  [Serializable]
  [XmlRoot("BillingGroup")]
  public class BillingGroup
  {
    [XmlAttribute("name")]
    public string Name;

    [XmlAttribute("description")]
    public string Description;

    public int Id;

    [XmlElement(ElementName = "account", Type = typeof(Account))]
    public Account[] Accounts;

    public List<int> GetAccounts()
    {
      List<int> accounts = new List<int>();

      foreach (Account account in Accounts)
      {
        accounts.Add(account.Id);
      }

      return accounts;
    }

    public string GetCommaSeparatedAccountIds()
    {
      return AdapterTestConfig.GetCommaSeparatedIds(GetAccounts());
    }

    public List<int> GetDuplicateAccounts()
    {
      List<int> duplicates = new List<int>();
      Dictionary<int, int> dictionary = new Dictionary<int, int>();

      foreach (Account account in Accounts)
      {
        if (dictionary.ContainsKey(account.Id))
        {
          duplicates.Add(account.Id);
        }
        else
        {
          dictionary.Add(account.Id, 0);
        }
      }

      return duplicates;
    }
  }

  [Serializable]
  [XmlRoot("account")]
  public class Account
  {
    [XmlAttribute("id")]
    public int Id;
  }

  [Serializable]
  [XmlRoot("adapter")]
  public class Adapter
  {
    [XmlAttribute("name")]
    public string Name;

    [XmlAttribute("testClass")]
    public string TestClass;
    
    [XmlAttribute("ignore")]
    public bool Ignore;

    [XmlAttribute("reverse")]
    public bool Reverse;

    [XmlElement(ElementName = "interval", Type = typeof(Interval))]
    public Interval[] Intervals;
  }


}
