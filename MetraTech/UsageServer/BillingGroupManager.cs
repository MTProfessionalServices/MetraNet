using System;
using System.Collections;
using System.Text;
using System.Text.RegularExpressions;
using System.Runtime.InteropServices;
using System.EnterpriseServices;

using MetraTech;
using MetraTech.DataAccess;
using MetraTech.Xml;
using Rowset = MetraTech.Interop.Rowset;
using Coll = MetraTech.Interop.GenericCollection;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;
using MetraTech.Interop.MTBillingReRun;
using Auth = MetraTech.Interop.MTAuth;

namespace MetraTech.UsageServer
{
  /// <summary>
	/// Summary description for BillingGroupManager.
	/// </summary>
  [ComVisible(false)]
  public class BillingGroupManager
  {
    #region Public Methods
    public BillingGroupManager()
    {
      mLogger = new Logger("[UsageServer]");
      defaultBillingGroupName = "Default";

      SetupDefaultQueryStrings();
    }

    /// <summary>
    ///    Set the tx_interval_status of all expired intervals to 'B'.
    /// </summary>
    /// <returns>number of intervals blocked</returns>
    public int BlockExpiredIntervals()
    {
      mLogger.LogDebug("Blocking non materialized expired intervals");
      int count = 0;

      try 
      {
          using (IMTConnection conn =
                  ConnectionManager.CreateConnection(mUsageServerQueryPath))
          {
              using (IMTCallableStatement stmt =
                conn.CreateCallableStatement("UpdExpiredIntervalsToBlocked"))
              {

                  stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTime.Now);
                  stmt.AddOutputParam("n_count", MTParameterType.Integer);

                  int rc = stmt.ExecuteNonQuery();

                  count = (int)stmt.GetOutputValue("n_count");
              }
          }

        mLogger.LogDebug("Blocked {0} expired intervals for which billing groups have not been created", count);
      }
      catch(Exception e) 
      {
        // Swallow exception because this is called from the billingserver service.
        mLogger.LogFatal
          ("Error while blocking expired intervals for which billing groups have not been created! : " + e.Message);
      }


      return count;
    }

    /// <summary>
    ///    Hard close those intervals which don't have paying accounts. 
    ///    
    ///    This is required during automatic processing of intervals. If there
    ///    are no paying accounts in the interval then no billing groups are
    ///    created and hence the framework cannot transition the interval to 
    ///    hard closed.
    /// </summary>
    /// <returns>number of intervals hard closed</returns>
    public int HardCloseExpiredIntervalsWithNoPayingAccounts()
    {
      mLogger.LogDebug("Hard closing non-materialized expired intervals with no paying accounts");
      
      int count = 0;

      try 
      {
          using (IMTConnection conn =
                  ConnectionManager.CreateConnection(mUsageServerQueryPath))
          {
              using (IMTCallableStatement stmt =
                conn.CreateCallableStatement("HardCloseExpiredIntervals_npa"))
              {

                  stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTime.Now);
                  stmt.AddOutputParam("n_count", MTParameterType.Integer);

                  int rc = stmt.ExecuteNonQuery();

                  count = (int)stmt.GetOutputValue("n_count");
              }
          }

        mLogger.LogDebug("Hard closed {0} non-materialized expired intervals with no paying accounts", count);
      }
      catch(Exception e) 
      {
        // Swallow exception because this is called from the billingserver service.
        mLogger.LogFatal
          ("Error while hard closing non-materialized expired intervals with no paying accounts! : " + e.Message);
      }

      return count;
    }

    /// <summary>
    ///    Materialize/Rematerialize all expired intervals.
    /// </summary>
    /// <param name="userId"></param>
    /// <returns>number of intervals materialized</returns>
    public int MaterializeBillingGroups(int userId)
    {
			return MaterializeBillingGroups(userId, false);
		}

    public int MaterializeBillingGroups(int userId, bool pretend)
    {
      int numberIntervals = 0;
      int intervalId = 0;

      try
      {
          // Get all the expired intervals
          mLogger.LogDebug("Materializing billing groups for all expired intervals");

          using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
          {
              using (IMTAdapterStatement stmt =
                conn.CreateAdapterStatement(mUsageServerQueryPath, "__GET_UNMATERIALIZED_EXPIRED_INTERVALS__"))
              {

                  using (IMTDataReader reader = stmt.ExecuteReader())
                  {
                      while (reader.Read())
                      {
                          numberIntervals++;

                          if (!pretend)
                          {
                              intervalId = reader.GetInt32("IntervalID");

                              try
                              {
                                  MaterializeBillingGroups(intervalId, userId);
                              }
                              catch (Exception e)
                              {
                                  // Swallow exception because 
                                  // we want to continue materializing the other intervals
                                  mLogger.LogError
                                    (String.Format
                                    ("Error occurred while materializing interval '{0}':", intervalId) + e.Message);
                              }
                          }
                      }
                  }
              }
          }
      }
      catch (Exception e)
      {
          // Swallow exception because this is called from the billingserver service.
          mLogger.LogFatal
            ("Error occurred while materializing all expired intervals! : " + e.Message);
      }

      return numberIntervals;
    }

    /// <summary>
    ///    Create billing groups for the given interval. If there is no
    ///    assignment query, the system will use the default query which
    ///    will put all accounts into one billing group.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="userId"></param>
    /// <returns>materialization id</returns>
    public int MaterializeBillingGroups(int intervalId, int userId) 
    {
      return MaterializeBillingGroups(intervalId, userId, false);
    }

    /// <summary>
    ///    Create billing groups for the given interval. Use the default
    ///    assignment query.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="userId"></param>
    /// <returns>materialization id</returns>
    public int MaterializeBillingGroups(int intervalId, 
                                        int userId, 
                                        bool useDefaultQuery) 
    {
      return MaterializeBillingGroups(intervalId, userId, useDefaultQuery, 
                                      null, null, null, null);
    }

    /// <summary>
    ///    Create billing groups for the given interval. Use the given
    ///    assignment query. All the query path/query tag parameters must be
    ///    provided.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="userId"></param>
    /// <returns>materialization id</returns>
    public int MaterializeBillingGroups(int intervalId, 
                                        int userId, 
                                        string assignmentQueryPath,
                                        string assignmentQueryTag,
                                        string descriptionQueryPath,
                                        string descriptionQueryTag) 
    {
      return MaterializeBillingGroups(intervalId, 
                                      userId, 
                                      false, 
                                      assignmentQueryPath,
                                      assignmentQueryTag,
                                      descriptionQueryPath,
                                      descriptionQueryTag);
    }


    /// <summary>
    ///   Create billing groups for the given interval. 
    ///   
    ///   If the useDefaultQuery parameter is 'true', then the system will 
    ///   ignore the assignment query and use the default query 
    ///   to create billing groups.
    ///   
    ///   If the assignmentQueryPath is provided, then the system will
    ///   ignore the standard assignment query and use the one provided.
    ///   
    ///   It is necessary to provide all the query path/query tag parameters 
    ///   if one is provided.   
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="userId"></param>
    /// <returns>materialization id</returns>
    public int MaterializeBillingGroups(int intervalId, 
                                        int userId,
                                        bool useDefault,
                                        string assignmentQueryPath,
                                        string assignmentQueryTag,
                                        string descriptionQueryPath,
                                        string descriptionQueryTag) 
    {
      // Check if this is interval has been fully materialized
      bool isRematerialization = false;

      // Create a materialization id
      int materializationId =
        CreateMaterialization(intervalId, userId, out isRematerialization);
 
      try 
      {
        // Create and validate billing group data in the temporary tables
        CreateTemporaryBillingGroups(intervalId, 
                                     materializationId,
                                     useDefault,
                                     assignmentQueryPath,
                                     assignmentQueryTag,
                                     descriptionQueryPath,
                                     descriptionQueryTag);

        // Validate billing group assignments
       ValidateBillingGroupAssignments(intervalId, materializationId);

        // Copy billing group data from temporary tables to system tables
        // Update the materialization in t_billgroup_materialization to 'Succeeded'
        // Delete data from temporary tables
        if (!isRematerialization)
        {
          CompleteMaterialization(intervalId, 
                                  materializationId, 
                                  MetraTech.MetraTime.Now);
        }
        else 
        {
          CompleteReMaterialization(intervalId, 
                                    materializationId, 
                                    MetraTech.MetraTime.Now);
        }
      }
      catch(Exception e)
      {
        mLogger.LogError(String.Format("Billgroup materialization error: {0}", e.StackTrace));
        // Abort materialization
        CleanupMaterialization(materializationId, 
                               MetraTech.MetraTime.Now,
                               MaterializationStatus.Failed,
                               e.Message);
        throw e;
      }

      return materializationId;
    }

    /// <summary>
    ///    Create a materialization record based on the given intervalId and
    ///    the given userId.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="userId"></param>
    /// <returns></returns>
    public int CreateMaterialization(int intervalId, int userId)
    {
      bool isRematerialization;
      return CreateMaterialization(intervalId, userId, out isRematerialization);
    }

    /// <summary>
    ///    Create a materialization record based on the given intervalId and
    ///    the given userId. If a 'Full' materialization has already occurred
    ///    for this interval then this will create a 'Rematerialization' entry,
    ///    otherwise it will create a 'Full' materialization entry.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="userId"></param>
    /// <returns></returns>
    public int CreateMaterialization(int intervalId, int userId, out bool isRematerialization)
    {
      isRematerialization = HasBeenFullyMaterialized(intervalId);

      string materializationType = String.Empty;
      if (isRematerialization) 
      {
        materializationType = MaterializationType.Rematerialization.ToString();
      }
      else 
      {
        materializationType = MaterializationType.Full.ToString();
      }

      // Create a materialization id
      int materializationId =       
        CreateMaterialization(intervalId, 
                              userId, 
                              MetraTech.MetraTime.Now,
                              null,
                              materializationType);

      return materializationId;
    }

    /// <summary>
    ///    Create and validate billing group data in the temporary tables by
    ///    running one of the following:
    ///      - the default assignment query (based on useDefault)
    ///      - the provided assignment query (if assignmentQueryPath is non-null)
    ///      - the assignment query specified in the config file (if assignmentQueryPath is null)
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="materializationId"></param>
    /// <param name="useDefault"></param>
    /// <param name="assignmentQueryPath"></param>
    /// <param name="assignmentQueryTag"></param>
    /// <param name="descriptionQueryPath"></param>
    /// <param name="descriptionQueryTag"></param>
    public void CreateTemporaryBillingGroups(int intervalId,
                                             int materializationId,
                                             bool useDefault,
                                             string assignmentQueryPath,
                                             string assignmentQueryTag,
                                             string descriptionQueryPath,
                                             string descriptionQueryTag)
    {
      // Populate t_billgroup_source_acc with payers for the given interval 
      PreparePayingAccounts(materializationId, intervalId);

      // Create billing group constraints only if we're not going to use the default query.
      if (useDefault == false)
      {
        CreateBillingGroupConstraints(materializationId, intervalId);
      }

      // Create temporary billing group assignments based on 
      // <BillingGroups>/<RecurringBillingGroups>/<AssignmentQuery> and
      // <BillingGroups>/<RecurringBillingGroups>/<DescriptionQuery>
      // in the configuration file
      CreateTempBillingGroupAssignments(materializationId, 
                                        intervalId, 
                                        useDefault,
                                        assignmentQueryPath,
                                        assignmentQueryTag,
                                        descriptionQueryPath,
                                        descriptionQueryTag);

    }

    /// <summary>
    ///    The first of a three-step pull list creation process. The three steps are:
    ///    
    ///    1) StartChildGroupCreation
    ///         a) Creates the pull list in the temporary tables.
    ///         b) Allows adapters to pull in additional accounts from
    ///            the parent billing group.
    ///         c) Ensures that the adapters pull in accounts that belong
    ///            to the parent billing group only.
    ///         d) Ensures that the parent billing group does not become empty.
    ///            
    ///    2) GetNecessaryChildGroupAccounts
    ///         a) Returns the list of new accounts that got added to the
    ///            billing group due to adapter constraints (Step 1b)
    ///    
    ///    ----------------------------------------------------------------------------
    ///    User approval (From UI): 
    ///    
    ///    If there are any accounts returned in Step (2) then
    ///    the user must manually approve (or abort - UI calls AbortChildGroupCreation)
    ///    the accounts before proceeding to the next step. 
    ///    
    ///    If there are no accounts returned in Step(2), the UI automatically
    ///    calls Step(3).
    ///    ----------------------------------------------------------------------------
    ///    
    ///    3) FinishChildGroupCreation
    ///       a) Copy data from temporary billing group tables to 
    ///          permanent billing group tables.
    ///       b) Fix up data for parent billing group.
    ///       c) Deep copy all the adapter instance data for the parent billing group
    ///          to the child billing group.
    ///       d) Call 'SplitReverseState' on adapters to touch up any 
    ///          internal reversal state they kept track of to aid in a custom reverse. 
    ///          This is only done on Succeeded or Failed instances that 
    ///          are associated with an adapter that implements a custom reverse mode
    ///            
    /// </summary>
    /// <param name="name">name of the new billing group</param>
    /// <param name="description">description for the new billing group</param>
    /// <param name="parentBillingGroupID">the billing group from which the 
    ///                                    new one is being created</param>
    /// <param name="accounts">comma separated list of account identifiers</param>
    /// <param name="needsExtraAccounts">true, if additional accounts need to be 
    ///                                  moved from the parent billing group to 
    ///                                  the new billing group</param>
    /// <returns>materialization id</returns>
    public int StartChildGroupCreationFromAccounts(string name, 
      string description, 
      int parentBillingGroupId, 
      string accounts, 
      out bool needsExtraAccounts,
      int userId)
    {
      needsExtraAccounts = false;
      int materializationId = -1;

      // Check accounts
      if (accounts == null || accounts.Length == 0) 
      {
        throw new UsageServerException
          ("Must specify at least one account in order to create a pull list!");
      }

      string commaSeparatedAccounts = ParseAccounts(accounts);

      // Get the usage interval (via IBillingGroup) 
      // associated with the parentBillingGroupID
      IBillingGroup parentBillingGroup = GetBillingGroup(parentBillingGroupId);

      // Create a materialization id
      materializationId =       
        CreateMaterialization(parentBillingGroup.IntervalID, 
        userId, 
        MetraTech.MetraTime.Now,
        parentBillingGroup.BillingGroupID,
        MaterializationType.PullList.ToString());

      try 
      {
        // Validate accounts and insert row(s) into t_billgroup_tmp and
        // t_billgroup_member_tmp
        CreateTempPullListAssignments(materializationId, 
                                      name, 
                                      description, 
                                      parentBillingGroup, 
                                      commaSeparatedAccounts);

        // Add extra accounts from the parent to satisfy adapter constraints
        // These constraints were calculated and stored in 
        // t_billgroup_constraint during the last materialization
        SatisfyConstraintsForPullList(materializationId, 
                                      parentBillingGroup,
                                      name);

        // Validate that all pulled accounts belong to the parent billing group
        // CheckNonParentAccounts(materializationId, parentBillingGroup, name);
       
        // Validate that the parent billing group is not going to be empty
        CheckEmptyParentBillingGroup(materializationId, parentBillingGroupId);
      }
      catch(Exception e) 
      {
        // Abort billing group creation
        CleanupMaterialization(materializationId, 
          MetraTech.MetraTime.Now,
          MaterializationStatus.Failed,
          e.Message);

        throw e;
      }

      return materializationId;
    }

    /// <summary>
    ///   Returns the list of additional accounts which are required to
    ///   complete this pull list.
    /// </summary>
    /// <param name="materializationID"></param>
    /// <returns>
    ///   DisplayName
    ///   UserName
    ///   Namespace
    ///   AccountID
    ///   
    ///   Sort on:  DisplayName ASC
    /// </returns>
    public Rowset.IMTSQLRowset GetNecessaryChildGroupAccounts(int materializationId)
    {
      // Check that the materializationId corresponds to an 'InProgress' 'PullList' 
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(mUsageServerQueryPath);
      rowset.SetQueryTag("__GET_MATERIALIZATION__");

      rowset.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
      rowset.Execute();
  
      // If the materializatioId does not correspond to a 'PullList' or
      // is not 'InProgress', then throw an error
      if ((string)rowset.get_Value("MaterializationType") != 
            MaterializationType.PullList.ToString() 
          ||
          (string)rowset.get_Value("MaterializationStatus") != 
            MaterializationStatus.InProgress.ToString())
      {
        throw new UsageServerException
          (String.Format
          ("'GetNecessaryChildGroupAccounts' called with incorrect materializationId '{0}'!", 
             materializationId));
      }
      
      // Do the actual query
      rowset.Clear();
      rowset.SetQueryTag("__GET_NECESSARY_CHILD_GROUP_ACCOUNTS__");
      rowset.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);

      rowset.Execute();

      return rowset;
    }

    /// <summary>
    ///  a) Copy data from temporary billing group tables to 
    ///      permanent billing group tables.
    ///  b) Fix up data for parent billing group.
    ///  c) Deep copy all the adapter instance data for the parent billing group
    ///     to the child billing group.
    ///  d) Call 'SplitReverseState' on adapters to touch up any 
    ///     internal reversal state they kept track of to aid in a custom reverse. 
    ///     This is only done on Succeeded or Failed instances that 
    ///     are associated with an adapter that implements a custom reverse mode
    /// </summary>
    /// <param name="materializationID"></param>
    /// <returns>BillingGroupID</returns>
    public int FinishChildGroupCreation(int materializationId)
    {
      mLogger.LogDebug("Finishing child group creation for materialization {0}...", 
        materializationId);

      int billingGroupId;
      BillingGroupWriter billingGroupWriter = new BillingGroupWriter();

      try 
      {
        billingGroupId = 
          billingGroupWriter.FinishChildGroupCreation(this, materializationId);

        // Clean up materialization as succeeded
        CleanupMaterialization(materializationId, 
          MetraTech.MetraTime.Now,
          MaterializationStatus.Succeeded,
          String.Empty);
      }
      catch(Exception e) 
      {
        // Clean up materialization 
        CleanupMaterialization(materializationId, 
          MetraTech.MetraTime.Now,
          MaterializationStatus.Failed,
          e.Message);

        throw new UsageServerException
          (String.Format("An exception with the following message " +
          "was thrown during child group creation " +
          "for materialization {0} : " +
          e.Message, materializationId), true);
      }

      mLogger.LogDebug("Finished child group creation for materialization {0}...", 
        materializationId);

      return billingGroupId;
    }

    /// <summary>
    ///   Called between StartChildGroupCreation and FinishChildGroupCreation. 
    /// </summary>
    /// <param name="materializationId"></param>
    public void AbortChildGroupCreation(int materializationId)
    {
      CleanupMaterialization(materializationId, 
        MetraTech.MetraTime.Now,
        MaterializationStatus.Aborted,
        null);
    }

    /// <summary>
    ///    Creates a user defined billing from all the unassigned accounts
    ///    in the given interval. If there are no unassigned accounts, then
    ///    no billing group is created.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="name"></param>
    /// <param name="description"></param>
    /// <returns>materialization Id</returns>
    public int CreateUserDefinedBillingGroupFromAllUnassignedAccounts(int intervalId, 
      int userId,
      string name, 
      string description)
    {
      return CreateUserDefinedBillingGroup(intervalId, userId, name, description, null);
    }

    public int CreateUserDefinedBillingGroupFromAccounts(int intervalId, 
      int userId,
      string name, 
      string description, 
      string accounts)
    {
      // Check accounts
      if (accounts == null || accounts.Length == 0) 
      {
        throw new UsageServerException
          ("Need one or more 'return' separated list of account id's to create a pull list!");
      }

      string commaSeparatedAccounts = ParseAccounts(accounts);

      return CreateUserDefinedBillingGroup(intervalId, 
        userId, 
        name, 
        description, 
        commaSeparatedAccounts);
    }

    /// <summary>
    ///   Return billing group data for the given interval. 
    ///   If allBillingGroups is 'false', then only non pull list billing groups
    ///   will be returned, otherwise all billing groups will be returned.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns>
    ///   BillingGroupID
    ///   Name
    ///   Description
    ///   Status
    ///   MemberCount
    ///   AdapterCount
    ///   AdapterSucceededCount
    ///   AdapterFailedCount
    ///   HasChildren
    ///   
    ///   Sorted by:  Name ASC
    /// </returns>
    public Rowset.IMTSQLRowset GetBillingGroupsRowset(int intervalId,
      bool allBillingGroups) 
    {
      BillingGroupFilter billingGroupFilter = new BillingGroupFilter();
      billingGroupFilter.IntervalId = intervalId;
      billingGroupFilter.BillingGroupOrder = BillingGroupOrder.Name;

      if (!allBillingGroups)
      {
        billingGroupFilter.NonPullList = true;
      }

      return GetBillingGroupsRowset(intervalId, billingGroupFilter.GetWhereClause(),
        billingGroupFilter.GetOrderByClause());
    }

    /// <summary>
    ///    Return a list of IBillingGroup objects based on the filter specification.
    /// </summary>
    /// <param name="filter"></param>
    /// <returns></returns>
    public ArrayList GetBillingGroups(IBillingGroupFilter filter)
    {
      ArrayList billingGroups = new ArrayList();
      Rowset.IMTSQLRowset rowset = 
        GetBillingGroupsRowset(filter);

      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        billingGroups.Add(BillingGroup.GetBillingGroup(rowset));
        rowset.MoveNext();
      }

      return billingGroups;
    }

    /// <summary>
    ///   Return billing group data for the given filter. 
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns>
    ///   BillingGroupID
    ///   Name
    ///   Description
    ///   Status
    ///   MemberCount
    ///   AdapterCount
    ///   AdapterSucceededCount
    ///   AdapterFailedCount
    ///   HasChildren
    ///   
    ///   Sorted by:  Name ASC
    /// </returns>
    public Rowset.IMTSQLRowset GetBillingGroupsRowset(IBillingGroupFilter filter) 
    {
      return GetBillingGroupsRowset(filter.IntervalId, filter.GetWhereClause(), filter.GetOrderByClause());
    }

    /// <summary>
    ///   Return materialization data for the given materialization id.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns>
    ///   MaterializationID
    ///   AccountID
    ///   DisplayName
    ///   UserName
    ///   Namespace
    ///   StartDate
    ///   EndDate
    ///   ParentBillingGroupID
    ///   IntervalID
    ///   MaterializationStatus
    ///   FailureReason
    ///   MaterializationType 
    /// </returns>
    public IMaterialization GetMaterialization(int materializationId) 
    {
      IMaterialization materialization = null;

      // Get all the expired intervals
      mLogger.LogDebug(String.Format
        ("Retrieving materialization object for materialization id '{0}'.", materializationId));

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mUsageServerQueryPath, "__GET_MATERIALIZATION__"))
          {
              stmt.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  int count = 0;
                  while (reader.Read())
                  {
                      count++;
                      // Error if we've found more than one row
                      if (count > 1)
                      {
                          throw new UsageServerException
                            (String.Format("Duplicate materialization id '{0}' found!", materializationId));
                      }

                      // Create the materialization object
                      materialization = new Materialization(reader.GetInt32("MaterializationID"));
                      materialization.AccountID = reader.GetInt32("AccountID");
                      materialization.DisplayName = reader.GetString("DisplayName");
                      materialization.UserName = reader.GetString("UserName");
                      materialization.Namespace = reader.GetString("Namespace");
                      if (!reader.IsDBNull("StartDate"))
                      {
                          materialization.StartDate = reader.GetDateTime("StartDate");
                      }
                      if (!reader.IsDBNull("EndDate"))
                      {
                          materialization.EndDate = reader.GetDateTime("EndDate");
                      }
                      if (!reader.IsDBNull("ParentBillingGroupID"))
                      {
                          materialization.ParentBillingGroupID = reader.GetInt32("ParentBillingGroupID");
                      }

                      materialization.IntervalID = reader.GetInt32("IntervalID");

                      string rawStatus = reader.GetString("MaterializationStatus");
                      materialization.MaterializationStatus =
                        Materialization.ParseMaterializationStatus(rawStatus);

                      if (!reader.IsDBNull("FailureReason"))
                      {
                          materialization.FailureReason = reader.GetString("FailureReason");
                      }

                      string rawType = reader.GetString("MaterializationType");
                      materialization.MaterializationType =
                        Materialization.ParseMaterializationType(rawType);
                  }
              }
          }
      }

      return materialization;
    }

    /// <summary>
    ///    Return the list of account id's for the given billingGroupId
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <returns></returns>
    public ArrayList GetBillingGroupMembers(int billingGroupId)
    {
      ArrayList accounts = new ArrayList();

      Rowset.IMTSQLRowset rowset = GetBillingGroupMembersRowset(billingGroupId, null);

      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        accounts.Add((int)rowset.get_Value("AccountID"));
        rowset.MoveNext();
      }

      return accounts;
    }

    /// <summary>
    ///    Return the member accounts for the given billingGroupId
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <param name="filter"></param>
    /// <returns>
    ///   DisplayName
    ///   UserName
    ///   Namespace
    ///   AccountID
    ///
    ///   Sort on:  DisplayName ASC
    /// </returns>
    public Rowset.IMTSQLRowset GetBillingGroupMembersRowset(int billingGroupId, 
      Rowset.IMTDataFilter filter)
    {
      // !TODO modify this to use filter
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(mUsageServerQueryPath);
      rowset.SetQueryTag("__GET_BILLING_GROUP_MEMBERS__");

      rowset.AddParam("%%ID_BILLGROUP%%", billingGroupId, true);

      rowset.Execute();

      return rowset;
    }
    /// <summary>
    ///   Return an IBillingGroup for the given billingGroupId
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <returns></returns>
    public IBillingGroup GetBillingGroup(int billingGroupId)
    {
      BillingGroupFilter billingGroupFilter = new BillingGroupFilter();
      billingGroupFilter.BillingGroupId = billingGroupId;

      int intervalId = GetIntervalIdForBillingGroup(billingGroupId); 
      Rowset.IMTSQLRowset rowset =
        GetBillingGroupsRowset(intervalId, 
                               billingGroupFilter.GetWhereClause(),
        billingGroupFilter.GetOrderByClause());

      if (rowset.RecordCount > 1) 
      {
        throw new UsageServerException
          (String.Format("Duplicate billing group id '{0}' found!", billingGroupId));
      }

      return BillingGroup.GetBillingGroup(rowset);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="parentBillingGroupID"></param>
    /// <returns>
    ///   BillingGroupID
    ///   Name
    ///   Description
    ///   Status
    ///   MemberCount
    ///   AdapterCount
    ///   AdapterSucceededCount
    ///   AdapterFailedCount
    ///   HasChildren
    ///   ParentBillingGroupID
    ///   ParentBillingGroupName
    ///   
    ///   Sorted by:  Name ASC
    /// </returns>
    public Rowset.IMTSQLRowset GetDescendantBillingGroupsRowset(int parentBillingGroupID)
    {
      BillingGroupFilter billingGroupFilter = new BillingGroupFilter();
      int intervalId = GetIntervalIdForBillingGroup(parentBillingGroupID);
      return GetBillingGroupsRowset(intervalId, 
                                    billingGroupFilter.GetDescendantsWhereClause(parentBillingGroupID),
        billingGroupFilter.GetOrderByClause());
    }

    /// <summary>
    ///   For the given interval return the latest materialization id 
    ///   which had reassignment failures in t_billgroup_member_history.
    /// </summary>
    /// <param name="intervalID"></param>
    /// <returns>valid materialization id or -1 if none exist</returns>
    public int GetLastMaterializationIDWithReassignmentWarnings(int intervalId)
    {
      int materializationId = -1;

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath,
                                        "__GET_LAST_MATERIALIZATION_ID_WITH_REASSIGNMENT_WARNINGS__"))
          {
              stmt.AddParam("%%ID_INTERVAL%%", intervalId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      materializationId = reader.GetInt32("id_materialization");
                      break;
                  }
              }
          }
      }

      return materializationId;
    }

    /// <summary>
    ///    Returns a rowset with reassignment failures found 
    ///    during a rematerialization.
    /// </summary>
    /// <param name="materializationId"></param>
    /// <returns>
    ///    AccountID
    ///    DisplayName
    ///    UserName
    ///    Namespace
    ///    Description
    /// </returns>
    public Rowset.IMTSQLRowset GetMaterializationReassignmentWarnings(int materializationId)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(mUsageServerQueryPath);
      rowset.SetQueryTag("__GET_MATERIALIZATION_REASSIGNMENT_WARNINGS__");

      rowset.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
      rowset.Execute();

      return rowset;
    }
    /// <summary>
    ///    Manually soft closes the given billing group. 
    ///    The billing group must be in the 'Open' status.
    /// </summary>
    /// <param name="billingGroupID"></param>
    /// <returns>True if successfully closed</returns>
    public bool SoftCloseBillingGroup(int billingGroupId)
    {
      bool softClosed = true;
      int status = (int)SoftCloseBillingGroupsMsg.Success;
      int count = 0;

      mLogger.LogDebug("Soft closing billing group {0}...", billingGroupId);

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("SoftCloseBillingGroups"))
          {
              stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTime.Now);
              stmt.AddParam("id_billgroup", MTParameterType.Integer, billingGroupId);
              stmt.AddParam("id_interval", MTParameterType.Integer, null);
              stmt.AddParam("pretend", MTParameterType.Integer, 0);
              stmt.AddOutputParam("n_count", MTParameterType.Integer);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              using (IMTDataReader reader = stmt.ExecuteReader()) { };

              status = (int)stmt.GetOutputValue("status");
              count = (int)stmt.GetOutputValue("n_count");
          }

        switch(status) 
        {
          case (int)SoftCloseBillingGroupsMsg.Success: 
          {
            mLogger.LogDebug
              ("Successfully soft closed billing group '{0}'...", billingGroupId);
            
            if (count != 1) 
            {
              softClosed = false;
            } 

            break;
          }
          case (int)SoftCloseBillingGroupsMsg.IntervalAndBillingGroup: 
          {
            throw new UsageServerException
              (String.Format("Cannot specify both interval and billing group " +
              "during soft close!"), true);
          }
          default: 
          {
            throw new UsageServerException
              (String.Format("An unknown error occurred during soft close of " +
              "billing group '{0}'!", billingGroupId), true);
          }
        }
      }
			
      return softClosed;
    }

    /// <summary>
    ///    
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <param name="ignoreDependencies"></param>
    /// <param name="pretend"></param>
    /// <returns></returns>
    public bool OpenBillingGroup(int billingGroupId, bool ignoreDependencies, bool pretend)
    {
      return OpenBillingGroup(billingGroupId, ignoreDependencies, pretend, true);
    }

    /// <summary>
    ///    Manually opens the given billing group. 
    ///    The billing group must be in the 'SoftClosed' status.
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <param name="ignoreDependencies"></param>
    /// <param name="pretend">If this is true, the state of the billing group remains unchanged</param>
    /// <returns>true if the billing group can be opened or was opened, false otherwise</returns>
    public bool OpenBillingGroup(int billingGroupId, 
                                 bool ignoreDependencies, 
                                 bool pretend,
                                 bool throwExceptionsOnError)
    {
      int status = (int)OpenBillingGroupMsg.Success;
      int ignoreDepsParam = 0;
      int pretendParam = 0;
      bool logMessage = true;
      bool canOpen = false;

      if (pretend) 
      {
        logMessage = false;
      }

      if (ignoreDependencies) 
      {
        ignoreDepsParam = 1;
      }

      if (pretend) 
      {
        pretendParam = 1;
      }

      if (logMessage) 
      {
        mLogger.LogDebug("Opening billing group {0}...", billingGroupId);
      }

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("OpenBillingGroup"))
          {
              stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTime.Now);
              stmt.AddParam("id_billgroup", MTParameterType.Integer, billingGroupId);
              stmt.AddParam("ignoreDeps", MTParameterType.Integer, ignoreDepsParam);
              stmt.AddParam("pretend", MTParameterType.Integer, pretendParam);


              stmt.AddOutputParam("status", MTParameterType.Integer);

              int rc = stmt.ExecuteNonQuery();

              status = (int)stmt.GetOutputValue("status");
          }

        switch(status) 
        {
          case (int)OpenBillingGroupMsg.Success: 
          {
            if (logMessage)
            {
              mLogger.LogDebug
                ("Successfully opened billing group '{0}'...", billingGroupId);
            }
            canOpen = true;
            break;
          }
          case (int)OpenBillingGroupMsg.UnknownBillGroup: 
          {
            string msg = String.Format("Cannot find billing group {0}!", billingGroupId);
            if (throwExceptionsOnError)
            {
              throw new UsageServerException(msg, logMessage);
            }
            else 
            {
              mLogger.LogDebug(msg);
            }
            break;
          }
          case (int)OpenBillingGroupMsg.BillGroupNotSoftClosed: 
          {
            string msg = String.Format("The billing group {0} has not been soft closed!", billingGroupId);
            if (throwExceptionsOnError) 
            {
              throw new UsageServerException(msg, logMessage);
            }
            else 
            {
              mLogger.LogDebug(msg);
            }
            break;
          }
          case (int)OpenBillingGroupMsg.StartRootNotFound: 
          {
            string msg = String.Format("Unable to find _StartRoot instance for billing group {0}!", billingGroupId);
            if (throwExceptionsOnError)
            {
              throw new UsageServerException(msg, logMessage);
            }
            else 
            {
              mLogger.LogDebug(msg);
            }
            break;
          }
          case (int)OpenBillingGroupMsg.DependentInstancesNotReversed: 
          {
            string msg = 
              String.Format("Not all instances, which depend on the billing group {0}," +
                            "have been reversed successfully!", billingGroupId);

            if (throwExceptionsOnError) 
            {
              throw new UsageServerException(msg, logMessage);
            }
            else 
            {
              mLogger.LogDebug(msg);
            }
            break;
            
          }
          case (int)OpenBillingGroupMsg.UnableToUpdateBillGroupStatus: 
          {
            string msg = String.Format("Could not update billing group status to 'C'");

            if (throwExceptionsOnError) 
            {
              throw new UsageServerException(msg, logMessage);
            }
            else 
            {
              mLogger.LogDebug(msg);
            }
            break;
          }
          default: 
          {
            string msg = 
              String.Format("An unknown error occurred while trying to open " +
                            "billing group '{0}'!", billingGroupId);

            if (throwExceptionsOnError) 
            {
              throw new UsageServerException(msg, logMessage);
            }
            else 
            {
              mLogger.LogDebug(msg);
            }
            break;
          }
        }
      }

      return canOpen;
    }

    /// <summary>
    ///    Manually hard closes the given billing group. 
    ///    The billing group must be in the 'SoftClosed' status.
    /// </summary>
    /// <param name="billingGroupId"></param>
    public void HardCloseBillingGroup(int billingGroupId)
    {
      int status = (int)HardCloseBillingGroupMsg.Success;
    
      mLogger.LogDebug("Hard closing billing group {0}...", billingGroupId);

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("HardCloseBillingGroup"))
          {
              stmt.AddParam("id_billgroup", MTParameterType.Integer, billingGroupId);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              int rc = stmt.ExecuteNonQuery();


              status = (int)stmt.GetOutputValue("status");
          }

        switch(status) 
        {
          case (int)HardCloseBillingGroupMsg.Success: 
          {
            mLogger.LogDebug
              ("Successfully hard closed billing group '{0}'...", billingGroupId);
          
            break;
          }
          case (int)HardCloseBillingGroupMsg.UnknownBillGroup: 
          {
            throw new UsageServerException
              (String.Format("Cannot find billing group {0}!", billingGroupId), true);
          }
          case (int)HardCloseBillingGroupMsg.BillGroupHardClosed: 
          {
            //Unclear why it is an error if the billgroup has previously been hard closed but leaving as is for the time being.
            //Understandable if the API changed to not throw an error if the billing group was already hard closed but appears
            //this is not an issue in production and test systems can work around it.
            throw new UsageServerException
              (String.Format("HardCloseBillingGroup: The billing group {0} has previously been hard closed!", billingGroupId), true);
          }
          case (int)HardCloseBillingGroupMsg.NonHardClosedUnassignedAccounts: 
          {
            throw new UsageServerException
              (String.Format("Cannot hard close billing group {0} because it is " +
              "the last billing group being hard closed and there are " +
              "unassigned accounts for the interval which are not " +
              "hard closed!", billingGroupId), true);
          }
          case (int)HardCloseBillingGroupMsg.UnableToUpdateBillGroupStatus: 
          {
            throw new UsageServerException
              (String.Format("Could not update billing group status to 'H'"), true);
          }
          default: 
          {
            throw new UsageServerException
              (String.Format("An unknown error occurred while trying to hard close " +
              "billing group '{0}'!", billingGroupId), true);
          }
        }
      }
    }

    /// <summary>
    ///    Manually hard closes the given interval. 
    ///    All of the paying accounts in the interval must have their status
    ///    set to 'H' in t_acc_usage_interval.
    /// </summary>
    /// <param name="billingGroupId"></param>
    public void HardCloseInterval(int intervalId, bool ignoreBillingGroups)
    {
      int status = (int)HardCloseIntervalMsg.Success;
      mLogger.LogDebug("Hard closing interval {0}...", intervalId);

      int ignoreBillingGroupsParam = 0;
      if (ignoreBillingGroups)
      {
        ignoreBillingGroupsParam = 1;
      }

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpdIntervalStatusToHardClosed"))
          {
              stmt.AddParam("id_interval", MTParameterType.Integer, intervalId);
              stmt.AddParam("ignoreBillingGroups", MTParameterType.Integer, ignoreBillingGroupsParam);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              int rc = stmt.ExecuteNonQuery();


              status = (int)stmt.GetOutputValue("status");
          }

        switch(status) 
        {
          case (int)HardCloseIntervalMsg.Success: 
          {
            mLogger.LogDebug
              ("Successfully hard closed interval '{0}'...", intervalId);
          
            break;
          }
          case (int)HardCloseIntervalMsg.OpenPayerAccounts: 
          {
            throw new UnableToHardCloseIntervalException(intervalId);
          }
          default: 
          {
            throw new UsageServerException
              (String.Format("An unknown error occurred while trying to hard close " +
                             "interval '{0}'!", intervalId), true);
          }
        }
      }
    }

    /// <summary>
    /// Manually re-opens as many billing groups as possible for the given usage interval.
    /// The billing groups must be in the soft-closed (C) status.
    /// 
    /// Returns the number of billing groups successfully opened.
    /// </summary>
    public void OpenUsageInterval(int intervalId, 
                                  bool ignoreDependencies, 
                                  bool pretend,
                                  out int numBillingGroups,
                                  out int numBillingGroupsOpened)
    {
      int billingGroupsOpened = 0;

      // Get the billing groups for this interval
      Rowset.IMTSQLRowset rowset = GetBillingGroupsRowset(intervalId, true);
      numBillingGroups = rowset.RecordCount;

      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        int billingGroupId = (int)rowset.get_Value("BillingGroupID");

        // Call OpenBillingGroup and force it not to throw exceptions
        if (OpenBillingGroup(billingGroupId, ignoreDependencies, pretend, false)) 
        {
          billingGroupsOpened++;
        }
        
        rowset.MoveNext();
      }

      numBillingGroupsOpened = billingGroupsOpened;
    }

    /// <summary>
    /// Manually hard closes as many billing groups as possible for the given usage interval.
    /// The billing groups must not already be hard closed.
    /// 
    /// </summary>
    public void HardCloseUsageInterval(int intervalId,
                                       bool ignoreBillingGroups,
                                       out int numBillingGroups,
                                       out int numBillingGroupsHardClosed)
    {
      int billingGroupsHardClosed = 0;
      numBillingGroups = 0;
      numBillingGroupsHardClosed = 0;

      // Get the billing groups for this interval
      Rowset.IMTSQLRowset rowset = GetBillingGroupsRowset(intervalId, true);
      numBillingGroups = rowset.RecordCount;

      // If there are no billing groups then hard close the interval and return
      if (numBillingGroups == 0) 
      {
        try 
        {
          HardCloseInterval(intervalId, ignoreBillingGroups);
        }
        catch(Exception e) 
        {
          mLogger.LogError(e.Message);
        }

        return;
      }

      // Try to hard close each billing group
      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        int billingGroupId = (int)rowset.get_Value("BillingGroupID");

        try 
        {
          HardCloseBillingGroup(billingGroupId);
        }
        catch (Exception) 
        {
          // Swallow exception
          // !TODO Yes this is kludgy - A better way to keep track of which billing
          //       groups have been hard closed is to modify the SQL (HardCloseBillingGroup)
          //       to take an interval and explicitly return the number of billing
          //       groups successfully hard closed.
          billingGroupsHardClosed--;
        }

        billingGroupsHardClosed++;

        rowset.MoveNext();
      }

      numBillingGroupsHardClosed = billingGroupsHardClosed;
    }

    /// <summary>
    /// Hard close all intervals which have an end date before the given dateTime.
    /// 
    /// Update the status of accounts in t_acc_usage_interval to 'H' and 
    /// set the interval status in t_usage_interval to 'H'.
    /// </summary>
    /// <returns>The count of intervals that are hard closed.</returns>
    public int HardCloseUsageIntervals(DateTime dateTime)
    {
      int count = 0;

      return count;
    }

    /// <summary>
    ///    Manually soft closes all open billing groups for
    ///    the given interval. 
    /// </summary>
    /// <param name="billingGroupID"></param>
    /// <returns>True if successfully closed</returns>
    public bool SoftCloseBillingGroups(int intervalId)
    {
      bool softClosed = true;
      int status = (int)SoftCloseBillingGroupsMsg.Success;
      int count = 0;

      mLogger.LogDebug("Soft closing billing groups for interval {0}...", 
        intervalId);

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("SoftCloseBillingGroups"))
          {
              stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTime.Now);
              stmt.AddParam("id_billgroup", MTParameterType.Integer, null);
              stmt.AddParam("id_interval", MTParameterType.Integer, intervalId);
              stmt.AddParam("pretend", MTParameterType.Integer, 0);
              stmt.AddOutputParam("n_count", MTParameterType.Integer);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              using (IMTDataReader reader = stmt.ExecuteReader()) { };

              status = (int)stmt.GetOutputValue("status");
              count = (int)stmt.GetOutputValue("n_count");
          }

        switch(status) 
        {
          case (int)SoftCloseBillingGroupsMsg.Success: 
          {
            mLogger.LogDebug
              ("Successfully soft closed '{0}' " +
              "billing groups for interval '{1}'...", count, intervalId);
            
            if (count == 0) 
            {
              softClosed = false;
            } 

            break;
          }
          case (int)SoftCloseBillingGroupsMsg.IntervalAndBillingGroup: 
          {
            throw new UsageServerException
              (String.Format("Cannot specify both interval and billing group " +
              "during soft close!"), true);
          }
          default: 
          {
            throw new UsageServerException
              (String.Format("An unknown error occurred during soft close of " +
              "interval '{0}'!", intervalId), true);
          }
        }
      }
			
      return softClosed;
    }

    /// <summary>
    ///    Manually soft closes all open billing groups for
    ///    all valid intervals. 
    /// </summary>
    /// <param name="billingGroupID"></param>
    /// <returns>True if successfully closed</returns>
    public ArrayList SoftCloseBillingGroups(bool pretend)
    {
      int status = 0;
      int count = 0;
      ArrayList billingGroups = null;

      if (pretend)
        mLogger.LogDebug("Pretending to soft close billing groups...");
      else
        mLogger.LogDebug("Soft closing billing groups...");

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("SoftCloseBillingGroups"))
          {
              stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTime.Now);
              stmt.AddParam("id_billgroup", MTParameterType.Integer, null);
              stmt.AddParam("id_interval", MTParameterType.Integer, null);
              stmt.AddParam("pretend", MTParameterType.Integer, pretend ? 1 : 0);
              stmt.AddOutputParam("n_count", MTParameterType.Integer);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  billingGroups = BillingGroup.Load(reader);
                  if (!pretend)
                  {
                      foreach (IBillingGroup billingGroup in billingGroups)
                      {
                          mLogger.LogDebug
                            ("Billing Group {0} was soft-closed", billingGroup.BillingGroupID);
                      }
                  }
              }

              status = (int)stmt.GetOutputValue("status");
              count = (int)stmt.GetOutputValue("n_count");
          }

        switch(status) 
        {
          case (int)SoftCloseBillingGroupsMsg.Success: 
          {
            mLogger.LogDebug
              ("Successfully soft closed '{0}' " +
              "billing groups for all valid intervals...", count);
            
            break;
          }
          case (int)SoftCloseBillingGroupsMsg.IntervalAndBillingGroup: 
          {
            throw new UsageServerException
              (String.Format("Cannot specify both interval and billing group " +
              "during soft close!"), true);
          }
          default: 
          {
            throw new UsageServerException
              (String.Format("An unknown error occurred during soft close!"), true);
          }
        }
      }
			
      return billingGroups;
    }

    /// <summary>
    /// Returns the unassigned accounts for the given interval.
    /// 
    /// If 'Status' is not specified on the given filter, 
    /// all unassigned accounts for the interval will be retrieved. 
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="filter"></param>
    /// <returns>
    /// accountId, 
    /// displayName,
    /// nm_space,
    /// nm_login, 
    /// status
    /// 
    /// Sorted by:  displayName ASC
    /// </returns>
    public Rowset.IMTSQLRowset 
      GetUnassignedAccountsForIntervalAsRowset(IUnassignedAccountsFilter filter)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(mUsageServerQueryPath);
      rowset.SetQueryTag("__GET_UNASSIGNED_ACCOUNTS_FOR_INTERVAL__");

      rowset.AddParam("%%WHERE_CLAUSE%%", filter.GetWhereClause(), true);
      rowset.AddParam("%%ORDER_BY_CLAUSE%%", filter.GetOrderByClause(), true);

      rowset.Execute();

      return rowset;
    }

    /// <summary>
    ///   Find the billing group id for the given account and
    ///   given interval. 
    /// </summary>
    /// <param name="accountID"></param>
    /// <returns>BillingGroupID or -1 if none found.</returns>
    public int FindBillingGroupIDByMember(int accountId, int intervalId)
    {
      int billingGroupId = -1;

      using(IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__FIND_BILLING_GROUP_ID_BY_ACCOUNT_ID__"))
          {

              stmt.AddParam("%%ID_ACCOUNT%%", accountId, true);
              stmt.AddParam("%%ID_INTERVAL%%", intervalId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  int count = 0;
                  while (reader.Read())
                  {
                      count++;
                      // Error if we've found more than one row
                      if (count > 1)
                      {
                          throw new UsageServerException
                            (String.Format("The account '{0}' occurrs more than once for the " +
                            "interval '{1}' in t_billgroup_member!", accountId, intervalId), true);
                      }

                      if (!reader.IsDBNull("BillingGroupID"))
                      {
                          billingGroupId = reader.GetInt32("BillingGroupID");
                      }
                  }
              }
          }
      }
      
      return billingGroupId;
    }

    /// <summary>
    ///   Find the billing group id for the given username/namespace and
    ///   the given interval. 
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="nameSpace"></param>
    /// <returns>BillingGroupID or -1 if none found.</returns>
    public int FindBillingGroupIDByMember(string userName, string nameSpace, int intervalId)
    {
      int billingGroupId = -1;

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__FIND_BILLING_GROUP_ID_BY_USERNAME_NAMESPACE__"))
          {

              stmt.AddParam("%%USERNAME%%", EncodeValue(userName), true);
              stmt.AddParam("%%NAMESPACE%%", EncodeValue(nameSpace), true);
              stmt.AddParam("%%ID_INTERVAL%%", intervalId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  int count = 0;
                  while (reader.Read())
                  {
                      count++;
                      // Error if we've found more than one row
                      if (count > 1)
                      {
                          throw new UsageServerException
                            (String.Format("The account '{0}/{1}' occurs more than once for the " +
                            "interval '{2}' in t_billgroup_member!",
                            userName, nameSpace, intervalId), true);
                      }

                      if (!reader.IsDBNull("BillingGroupID"))
                      {
                          billingGroupId = reader.GetInt32("BillingGroupID");
                      }
                  }
              }
          }
      }

      return billingGroupId;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="accounts">a collection of int's</param>
    /// <param name="intervalId"></param>
    /// <param name="backoutAndResubmitUsage"></param>
    /// <returns>
    ///   AccountId
    ///   ErrorMessage
    /// </returns>
    public Rowset.IMTSQLRowset 
      SetAccountStatusToHardClosedForInterval(Coll.IMTCollection accounts, 
      int intervalId, 
      bool backoutAndResubmitUsage,
      Auth.IMTSessionContext sessionContext)
    {
      Rowset.IMTSQLRowset accountsWithUsageRowset = null;

      if (accounts.Count == 0) 
      {
        throw new UsageServerException
          (String.Format("No accounts passed in!", true));
      }

      mLogger.LogDebug("Setting status of unassigned accounts to hard closed");

      // Convert accounts into a string of comma separated accounts.
      string commaSeparatedAccounts = GetCommaSeparatedAccounts(accounts);

      // Pass in a comma separated list of accounts to the UpdateUnassignedAccounts
      // stored proc. This will update t_acc_usage_interval.tx_status to 'H' for 
      // those accounts which don't have usage. 
      // The accounts which have usage are returned.
      accountsWithUsageRowset = 
        UpdateUnassignedAccountsToHardClosed(commaSeparatedAccounts, intervalId, true, true);
    
      // If the backoutAndResubmitUsage flag is false, we're done
      if (!backoutAndResubmitUsage) 
      {
        return accountsWithUsageRowset;
      }
    
      // Attempt to back out and resubmit usage 
      if (accountsWithUsageRowset.RecordCount > 0)
      {
        mLogger.LogDebug
          ("Attempting to back out and resubmit usage for unassigned accounts");

        IBillingGroupWriter billingGroupWriter = new BillingGroupWriter();

        commaSeparatedAccounts = GetCommaSeparatedAccounts(accountsWithUsageRowset);

        billingGroupWriter.BackoutUsage
          (this, intervalId, commaSeparatedAccounts, sessionContext, true, true);

        mLogger.LogDebug
          ("Successfully backed out and resubmitted usage for unassigned accounts");

      }

      // If we're here, then the back out and resubmit succeeded
      // Return an empty rowset
      return CreateGUIRowset(null);
    }

    /// <summary>
    ///   Once this method is called, no interval mappings will be created
    ///   for new accounts for this interval. 
    ///   Note: There is no API to undo this operation.
    /// </summary>
    /// <param name="intervalId"></param>
    public void SetIntervalAsBlockedForNewAccounts(int intervalId)
    {
      mLogger.LogDebug
        ("Setting interval status to 'Blocked' for Interval {0}...", intervalId);

      using (IMTConnection conn =
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt =
            conn.CreateCallableStatement("UpdIntervalBlockedForNewAccts"))
          {

              stmt.AddParam("id_interval", MTParameterType.Integer, intervalId);
              stmt.ExecuteNonQuery();
          }
      }
    }

    /// <summary>
    ///   Return the value of <BillingGroups>\<AllowPullList> in usageserver.xml 
    /// </summary>
    /// <returns></returns>
    public bool AllowPullLists()
    {
      bool allowPullLists = false;

      MTXmlDocument doc = new MTXmlDocument();
      doc.LoadConfigFile(UsageServerCommon.UsageServerConfigFile);

      string path = "/xmlconfig/BillingGroups/AllowPullLists";

      if (doc.SingleNodeExists(path) != null)
      {
        allowPullLists = doc.GetNodeValueAsBool(path);
      }

      return allowPullLists;
    }

    /// <summary>
    ///   Set the ignoredeps status of the EndRoot event (in t_recevent_inst) for the given billingGroupId to 'Y'.
    /// </summary>
    /// <param name="billingGroupId"></param>
    public void IgnoreEndRootDependenciesForBillingGroup(int billingGroupId)
    {
      mLogger.LogDebug
        ("Setting ignoredeps status to 'Y' for BillingGroup {0}...", billingGroupId);

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__IGNORE_END_ROOT_DEPS_FOR_BILLGROUP__"))
          {

              stmt.AddParam("%%ID_BILLGROUP%%", billingGroupId);

              stmt.ExecuteNonQuery();
          }
      }
    }

    /// <summary>
    ///   Set the ignoredeps status of all the EndRoot events (in t_recevent_inst) for the given intervalId to 'Y'.
    /// </summary>
    /// <param name="intervalId"></param>
    public void IgnoreEndRootDependenciesForInterval(int intervalId)
    {
      mLogger.LogDebug
        ("Setting ignoredeps status to 'Y' for Interval {0}...", intervalId);

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__IGNORE_END_ROOT_DEPS_FOR_INTERVAL__"))
          {

              stmt.AddParam("%%ID_INTERVAL%%", intervalId);

              stmt.ExecuteNonQuery();
          }
      }
    }

    #endregion

    #region Static Methods
    
    #endregion

    #region Properties
    public string DefaultBillingGroupName 
    {
      get 
      {
        return defaultBillingGroupName;
      }
    }
    #endregion

    #region Internal Methods
    /// <summary>
    /// 
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="time"></param>
    /// <param name="materializationStatus"></param>
    /// <param name="failureReason"></param>
    public void CleanupMaterialization(int materializationId,
                                       DateTime time,
                                       MaterializationStatus materializationStatus,
                                       string failureReason)
    {
      int status = (int)CleanupMaterializationMsg.Success;
      string modifiedFailureReason = "'" + failureReason.Replace("'", "''") + "'";
      
      mLogger.LogDebug("Cleaning up billing group creation for materialization {0}...", 
        materializationId);

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt =
            conn.CreateCallableStatement("CleanupMaterialization"))
          {
              stmt.AddParam("id_materialization", MTParameterType.Integer, materializationId);
              stmt.AddParam("dt_end", MTParameterType.DateTime, time);
              stmt.AddParam("tx_status", MTParameterType.String, materializationStatus.ToString());
              stmt.AddParam("tx_failure_reason", MTParameterType.String, modifiedFailureReason);

              stmt.AddOutputParam("status", MTParameterType.Integer);
              stmt.ExecuteNonQuery();

              status = (int)stmt.GetOutputValue("status");
          }

        switch(status) 
        {
          case (int)CleanupMaterializationMsg.Success: 
          {
            mLogger.LogDebug
              ("Successfully cleaned up billing group creation for materialization {0}...", 
              materializationId);
    
            break;
          }
          default: 
          {
            throw new UsageServerException
              ("Aborting billing group creation due to an unknown error", true);
          }
        }
      }
    }

    /// <summary>
    ///    Deep copies adapter instance data.
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="childBillingGroupId"></param>
    /// <param name="parentBillingGroupId"></param>
    /// <returns>Hashtable mapping [eventId --> AdapterRunData]</returns>
    internal Hashtable CopyAdapterInstances(int materializationId,
      out int childBillingGroupId,
      out int parentBillingGroupId)
    {
      Hashtable adapterRunDataMap = new Hashtable();

      childBillingGroupId = -1;
      parentBillingGroupId = -1;
     
      int status = (int)CopyAdapterInstancesMsg.Success;

      mLogger.LogDebug("Creating recurring event instance data for materialization {0}...", 
        materializationId);

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt =
            conn.CreateCallableStatement("CopyAdapterInstances"))
          {

              stmt.AddParam("id_materialization", MTParameterType.Integer, materializationId);
              stmt.AddOutputParam("status", MTParameterType.Integer);
              stmt.AddOutputParam("id_billgroup_parent", MTParameterType.Integer);
              stmt.AddOutputParam("id_billgroup_child", MTParameterType.Integer);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  AdapterRunData adapterRunData = null;

                  while (reader.Read())
                  {
                      // Create AdapterRunData
                      adapterRunData = new AdapterRunData();
                      adapterRunData.eventId = reader.GetInt32("id_event");
                      if (!reader.IsDBNull("id_run_parent"))
                      {
                          adapterRunData.parentRunId = reader.GetInt32("id_run_parent");
                      }
                      else
                      {
                          adapterRunData.parentRunId = -1;
                      }
                      if (!reader.IsDBNull("id_run_child"))
                      {
                          adapterRunData.childRunId = reader.GetInt32("id_run_child");
                      }
                      else
                      {
                          adapterRunData.childRunId = -1;
                      }

                      adapterRunDataMap.Add(adapterRunData.eventId, adapterRunData);
                  }
              }

              status = (int)stmt.GetOutputValue("status");
              parentBillingGroupId = (int)stmt.GetOutputValue("id_billgroup_parent");
              childBillingGroupId = (int)stmt.GetOutputValue("id_billgroup_child");
          }

        CheckCopyAdapterInstanceStatus(status, materializationId);
      }

      return adapterRunDataMap;
    }

    /// <summary>
    ///    For each adapter which supports billing groups and supports
    ///    custom reverse, call its SplitReversalState
    /// </summary>
    /// <param name="materializationId"></param>
    internal void RunAdapterSplitReverseState(int materializationId,
      int parentBillingGroupId,
      int childBillingGroupId,
      Hashtable adapterRunDataMap)
    {
      mLogger.LogDebug("Executing RunAdapterSplitReverseState for materialization {0}...", 
        materializationId);

      // Get the interval id
      int intervalId = GetIntervalId(materializationId);

      // Get adapters which support billing group constraints
      ArrayList adapterDataList = 
        GetAdapterInstances(intervalId, adapterInstancesWithCustomReverse);

      AdapterRunData adapterRunData = null;
      string configFile = "";

      try 
      {
        foreach(AdapterData adapterData in adapterDataList)
        {
          // Retrieve the correct adapter run
          adapterRunData = (AdapterRunData)adapterRunDataMap[adapterData.eventId];
          
          // Call SplitReverseState if there is a valid adapterRunData and 
          // a valid parentRunId
          if (adapterRunData != null &&
            adapterRunData.parentRunId != (int)AdapterExecution.HasNotRun)
          {
            // builds the absolute file name to the adapter's config file
            configFile = 
              AdapterManager.GetAbsoluteConfigFile(adapterData.extensionName, 
              adapterData.configFileName, 
              adapterData.isLegacy);

            // Initialize the adapter 
            adapterData.recurringEventAdapter.Initialize(adapterData.eventName, 
              configFile, 
              AdapterManager.GetSuperUserContext(), 
              true);

            // Call SplitReverseState
            adapterData.recurringEventAdapter.
              SplitReverseState(adapterRunData.parentRunId,
              parentBillingGroupId,
              adapterRunData.childRunId,
              childBillingGroupId);
          }
        }
      }
      catch(Exception e) 
      {
        throw new UsageServerException("Adapter SplitReverseState failed with " +
          "the following exception", e);
      }
    }

    /// <summary>
    ///    1) Delete child group accounts for parent billing group from t_billgroup_member
    ///    2) Update t_billgroup_member_history to reflect the deletion
    ///    3) Insert child billing group data into t_billgroup from t_billgroup_tmp
    ///    4) Insert child billing group data into t_billgroup_member
    ///    5) Update t_billgroup_member_history to reflect the addition
    ///    6) Delete data from t_billgroup_tmp
    ///    7) Delete data from t_billgroup_member_tmp
    ///    8) Update t_billgroup_materialization
    /// </summary>
    /// <param name="materializationId"></param>
    internal void CompleteChildGroupCreation(int materializationId) 
    {
      int status = (int)CompleteChildGroupCreationMsg.Success;

      mLogger.LogDebug("Completing child group creation for materialization {0}...", 
        materializationId);

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt =
            conn.CreateCallableStatement("CompleteChildGroupCreation"))
          {

              stmt.AddParam("id_materialization", MTParameterType.Integer, materializationId);
              stmt.AddParam("dt_end", MTParameterType.DateTime, MetraTech.MetraTime.Now);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              int rc = stmt.ExecuteNonQuery();

              status = (int)stmt.GetOutputValue("status");
          }

        switch(status) 
        {
          case (int)CompleteChildGroupCreationMsg.Success: 
          {
            mLogger.LogDebug
              ("Successfully completed child group creation for materialization {0}...", 
              materializationId);
    
            break;
          }
          case (int)CompleteChildGroupCreationMsg.NullParentBillingGroup: 
          {
            throw new UsageServerException
              (String.Format("The parent billing group is NULL"), true);
          }
          default: 
          {
            throw new UsageServerException
              ("Completing child group creation failed with an unknown error", true);
          }
        }
      }
    }

    public IMTIdentificationFilter GetBillingRerunFilter(IMTBillingReRun rerun, 
                                                         string accountId,
                                                         int intervalId)
    {
      IMTIdentificationFilter filter = rerun.CreateFilter();
      filter.AccountConditions = 
        (MetraTech.Interop.MTBillingReRun.IMTDataFilter) new Rowset.MTDataFilterClass();

      filter.AccountConditions.Add("_AccountID", "=", Convert.ToInt32(accountId));   
      filter.IntervalID = intervalId;

      return filter;
    }

    public IMTBillingReRun SetupBillingReRun(string comment, 
                                             Auth.IMTSessionContext sessionContext)
    {
      IMTBillingReRun rerun = new MetraTech.Pipeline.ReRun.Client();

      // joins the webservice call into the current COM+ transaction
      rerun.TransactionID = GetTransactionCookieFromContext();

      rerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext) sessionContext);
  			
      rerun.Setup(comment);

      return rerun;
    }

    public string GetTransactionCookieFromContext()
    {
      ITransaction contextTxn = (ITransaction) ContextUtil.Transaction;

      PipelineTransaction.IMTTransaction txnWrapper = 
        new PipelineTransaction.CMTTransactionClass();

      // false means no ownership, otherwise 
      // it'll rollback when MTTransaction object is destroyed
      txnWrapper.SetTransaction(contextTxn, false);

      PipelineTransaction.IMTWhereaboutsManager whereAbouts = 
        new PipelineTransaction.CMTWhereaboutsManagerClass();
      string cookie = whereAbouts.GetLocalWhereabouts();

      return txnWrapper.Export(cookie);
    }

    public void DeleteTempBillingRerunAccountsTable()
    {
      using(IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__DELETE_TEMP_ACCOUNTS_TABLE_FOR_BILLING_RERUN__"))
          {

              int rc = stmt.ExecuteNonQuery();
          }
      }
    }

    public void CreateAndPopulateTempBillingRerunAccountsTable(string commaSeparatedAccounts) 
    {
      int status = (int)PopulateTempAccountsTableMsg.Success;

      mLogger.LogDebug("Populating temporary billing rerun accounts table...");

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt =
            conn.CreateCallableStatement("CreateAndPopulateTempAccts"))
          {

              stmt.AddParam("accountArray", MTParameterType.String, commaSeparatedAccounts);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              stmt.ExecuteNonQuery();

              status = (int)stmt.GetOutputValue("status");
          }

        switch(status) 
        {
          case (int)PopulateTempAccountsTableMsg.Success: 
          {
            mLogger.LogDebug
              ("Successfully populated temporary billing rerun accounts table...");
    
            break;
          }
          default: 
          {
            throw new UsageServerException
              (String.Format("Populating temporary billing rerun accounts " +
              "table failed with an unknown error"), true);
          }
        }
      }
    }

    internal void RunIdentifyAccountUsageForBillingRerun(IMTBillingReRun billingRerun, 
      int intervalId)
    {
      string innerJoinClause = 
        "inner join " + mBillingRerunAccountsTableName +
        " acc on acc.id_acc = au.id_acc ";

      string whereClause = 
        " and au.id_usage_interval = " + intervalId;

      using (IMTConnection conn = ConnectionManager.CreateConnection("queries\\BillingRerun"))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement("queries\\BillingRerun", "__IDENTIFY_ACC_USAGE2__"))
          {

              stmt.AddParam("%%STATE%%", "I");
              stmt.AddParam("%%TABLE_NAME%%", billingRerun.TableName, true);
              stmt.AddParam("%%JOIN_CLAUSE%%", innerJoinClause, true);
              stmt.AddParam("%%WHERE_CLAUSE%%", whereClause, true);

              int rc = stmt.ExecuteNonQuery();
          }
      }
    }

    #endregion

    #region Private Methods

    private bool UseDefaultQuery()
    { 
    // ESR-2811 / port ESR-2811 from 6.0.3 
    // if the tag <BillingGroups></BillingGroups> does not exist the "Bill Group Materialization" will not be run 
    // accounts will end up in the default billgroup if the tag exists then "billgroup Materialization" will be run.
      MTXmlDocument doc = new MTXmlDocument();
      doc.LoadConfigFile(mConfigFile);

      if (doc.SingleNodeExists("/xmlconfig/BillingGroups") == null)
      {
        return true;
      }

      return false;
    }

    /// <summary>
    ///   Return billing group data for the given whereClause.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns>
    ///   BillingGroupID
    ///   Name
    ///   Description
    ///   Status
    ///   MemberCount
    ///   AdapterCount
    ///   AdapterSucceededCount
    ///   AdapterFailedCount
    ///   HasChildren
    ///   
    ///   Sorted by:  Name ASC
    /// </returns>
    private Rowset.IMTSQLRowset GetBillingGroupsRowset(int intervalId, string whereClause, string orderByClause) 
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(mUsageServerQueryPath);
      rowset.SetQueryTag("__GET_BILLING_GROUPS__");
      string optionalBillingGroupWhereClause = "";
      if (intervalId != BillingGroupFilter.invalidIntervalId)
      {
        optionalBillingGroupWhereClause = " WHERE id_usage_interval = " + intervalId + " ";
      }

      rowset.AddParam("%%OPTIONAL_BILLING_GROUP_WHERE_CLAUSE%%", optionalBillingGroupWhereClause, true);
      rowset.AddParam("%%OPTIONAL_WHERE_CLAUSE%%", whereClause, true);
      rowset.AddParam("%%OPTIONAL_ORDER_BY_CLAUSE%%", orderByClause, true);
      if (isOracle)
        rowset.AddParam("%%LOCK%%", " "); // for Oracle
      else 
        rowset.AddParam("%%LOCK%%", "with (nolock)"); // for SQL

      rowset.Execute();

      return rowset;
    }

    private int CreateUserDefinedBillingGroup(int intervalId, 
                                              int userId,
                                              string name, 
                                              string description, 
                                              string accounts)
    {
      int materializationId = -1;

      // Create a materialization id
      materializationId =       
        CreateMaterialization(intervalId, 
                              userId, 
                              MetraTech.MetraTime.Now,
                              null,
                              MaterializationType.UserDefined.ToString());

      try 
      {
        // Create temporary billing group assignments 
        // from all the unassigned accounts
        StartUserDefinedGroupCreation(materializationId,
                                      name,
                                      description,
                                      accounts);

        // Run each adapter to validate that the mappings in the 
        // t_billgroup_member_tmp table do not violate 
        // adapter billing group constraints. 
        // If any constraint is not satisfied, the materialization 
        // will fail with a descriptive error message. 
        // CheckAdapterConstraints(intervalId, materializationId, name);

        // Copy billing group data from temporary tables to system tables
        // Update the materialization in t_billgroup_materialization to 'Succeeded'
        // Delete data from temporary tables
        CompleteMaterialization(intervalId, 
                                materializationId, 
                                MetraTech.MetraTime.Now);
      }
      catch(Exception e) 
      {
        // Abort materialization
        CleanupMaterialization(materializationId, 
          MetraTech.MetraTime.Now,
          MaterializationStatus.Failed,
          e.Message);

        throw e;
      }

      return materializationId;
    }

    /// <summary>
    ///    Create a row in t_billgroup_materialization with a status
    ///    of 'InProgress'. Throws an exception if a materialization is
    ///    in progress for the given interval.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="userId"></param>
    /// <param name="startDate"></param>
    /// <param name="parentBillingGroupId"></param>
    /// <param name="materializationType"></param>
    /// <param name="materializationId"></param>
    /// <returns>materialization id</returns>
    public int CreateMaterialization(int intervalId,
                                     int userId,
                                     DateTime startDate,
                                     object parentBillingGroupId,
                                     string materializationType) 
    {
      mLogger.LogDebug
        ("Creating Materialization Id For Interval {0}...", intervalId);

      int status = (int)CreateBillGroupMaterializationMsg.Success;
      int materializationId = 0;

      using (IMTConnection conn =
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt =
            conn.CreateCallableStatement("CreateBillGroupMaterialization"))
          {

              stmt.AddParam("id_user_acc", MTParameterType.Integer, userId);
              stmt.AddParam("dt_start", MTParameterType.DateTime, startDate);
              stmt.AddParam("id_parent_billgroup", MTParameterType.Integer, parentBillingGroupId);
              stmt.AddParam("id_usage_interval", MTParameterType.Integer, intervalId);
              stmt.AddParam("tx_type", MTParameterType.String, materializationType);
              stmt.AddOutputParam("id_materialization", MTParameterType.Integer);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              stmt.ExecuteNonQuery();

              status = (int)stmt.GetOutputValue("status");
              materializationId = (int)stmt.GetOutputValue("id_materialization");
          }
      }

      switch(status) 
      {
        case (int)CreateBillGroupMaterializationMsg.Success: 
        {
          mLogger.LogDebug
            ("Successfully created materialization id '{0}' for interval {1}...", 
            materializationId,
            intervalId);
          break;
        }
        case (int)CreateBillGroupMaterializationMsg.IntervalHardClosed: 
        {
          throw new MaterializingHardClosedIntervalException(intervalId);
        }
        case (int)CreateBillGroupMaterializationMsg.ErrorWithCleanup: 
        {
          throw new UsageServerException
            (String.Format("Could not create materialization id for interval '{0}' " +
                           "because the " +
                           "[CleanupMaterialization] stored procedure did not execute successfully",
                           intervalId), false);
        }
        case (int)CreateBillGroupMaterializationMsg.NoPayingAccounts: 
        {
          throw new MaterializingIntervalWithoutPayersException(intervalId, LogLevel.Warning);
        }
        case (int)CreateBillGroupMaterializationMsg.AdapterProcessing: 
        {
          throw new MaterializingWhileAdapterProcessingException(intervalId);
        }
        case (int)CreateBillGroupMaterializationMsg.IntervalOnlyAdapterExecution: 
        {
          throw new UsageServerException
            (String.Format("Cannot recreate billing groups or create user defined groups for interval '{0}' " +
            "until all interval-only adapters have been reversed!", intervalId), true);
        }
        case (int)CreateBillGroupMaterializationMsg.MaterializationInProgress: 
        {
          throw new MaterializationInProgressException(intervalId);
        }
        case (int)CreateBillGroupMaterializationMsg.RepeatFullMaterialization: 
        {
          throw new RepeatFullMaterializationException(intervalId);
        }
//        case (int)CreateBillGroupMaterializationMsg.ParentBillingGroupNotSoftClosed: 
//        {
//          throw new ParentBillingGroupNotSoftClosedException(intervalId);
//        }
          
        default: 
        {
          throw new UsageServerException
            (String.Format("A materialization id for interval '{0}' " +
            "submitted by user '{1}' " +
            "could not be created for an unknown reason!",
            intervalId, 
            userId), true);
        }
      }

      return materializationId;
    }

    /// <summary>
    ///    Poulate the t_billgroup_source_acc with all the paying accounts
    ///    for the given interval. 
    ///    Map the accounts to the given materialization id.
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="intervalId"></param>
    private void PreparePayingAccounts(int materializationId, int intervalId) 
    {
      mLogger.LogDebug("Preparing paying accounts for " +
        "interval '{0}' and materialization '{1}'",
        intervalId, materializationId);

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__PREPARE_PAYING_ACCOUNTS__"))
          {

              stmt.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
              stmt.AddParam("%%ID_INTERVAL%%", intervalId, true);

              int rc = stmt.ExecuteNonQuery();
          }
      }
    }

    /// <summary>
    ///    Execute the given assignment and description queries.
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="intervalId"></param>
    /// <param name="assignmentQueryPath"></param>
    /// <param name="assignmentQueryTag"></param>
    /// <param name="descriptionQueryPath"></param>
    /// <param name="descriptionQueryTag"></param>
    private void ExecuteAssignmentQuery(int materializationId,
                                        int intervalId,
                                        string assignmentQueryPath,
                                        string assignmentQueryTag,
                                        string descriptionQueryPath,
                                        string descriptionQueryTag)
    {
      try 
      {
        // Execute assignment query
        mLogger.LogDebug("Executing assignment query for materialization '{0}'", materializationId);

        using (IMTConnection conn = ConnectionManager.CreateConnection(assignmentQueryPath))
        {
            using (IMTAdapterStatement stmt =
              conn.CreateAdapterStatement(assignmentQueryPath, assignmentQueryTag))
            {

                stmt.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);

                int rc = stmt.ExecuteNonQuery();
            }
        }

        // Execute description query
        mLogger.LogDebug("Executing description query for " +
          "materialization '{0}'", materializationId);

        using (IMTConnection conn = ConnectionManager.CreateConnection(descriptionQueryPath))
        {
            using (IMTAdapterStatement stmt =
              conn.CreateAdapterStatement(descriptionQueryPath, descriptionQueryTag))
            {

                stmt.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);

                int rc = stmt.ExecuteNonQuery();
            }
        }
      }
      catch (Exception e) 
      {
        throw new BillingGroupAssignmentException(e);
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="materializationId"></param>
    private void CreateTempBillingGroupAssignments(int materializationId,
                                                   int intervalId,
                                                   bool useDefaultQuery,
                                                   string assignmentQueryPath,
                                                   string assignmentQueryTag,
                                                   string descriptionQueryPath,
                                                   string descriptionQueryTag) 
    {
      mLogger.LogDebug("Creating temporary billing group assignments for " +
                       "materialization '{0}'", 
                       materializationId);

      // Use the assignment query if it's provided
      if (assignmentQueryPath != null && assignmentQueryPath != String.Empty) 
      {
        ExecuteAssignmentQuery(materializationId,
                               intervalId,
                               assignmentQueryPath,
                               assignmentQueryTag,
                               descriptionQueryPath,
                               descriptionQueryTag);

        return;
      }

      string assignmentQueryPathLocal;
      string assignmentQueryTagLocal;
      string descriptionQueryPathLocal;
      string descriptionQueryTagLocal;

      // Get the query paths and tags
      GetQueryData(materializationId,
                   useDefaultQuery,
                   out assignmentQueryPathLocal, 
                   out assignmentQueryTagLocal,
                   out descriptionQueryPathLocal,
                   out descriptionQueryTagLocal);

      // Executing assignment query
      mLogger.LogDebug("Executing assignment query for " +
        "materialization '{0}'", materializationId);

      // If the default query is asked for or the assignment query
      // could not be found then execute the default query
      if (useDefaultQuery || assignmentQueryPathLocal == String.Empty) 
      {
        // Execute the default queries
        try 
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(assignmentQueryTagLocal))
                {
                    stmt.ExecuteNonQuery();
                }

                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(descriptionQueryTagLocal))
                {
                    stmt.ExecuteNonQuery();
                }
            }
        }
        catch(Exception e) 
        {
          throw new BillingGroupAssignmentException(e);
        }
      }
      else
      {
        ExecuteAssignmentQuery(materializationId,
                               intervalId,
                               assignmentQueryPathLocal,
                               assignmentQueryTagLocal,
                               descriptionQueryPathLocal,
                               descriptionQueryTagLocal);

      }
    }

    /// <summary>
    ///    Pass through to ValidateBillingGroupAssignments
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="materializationId"></param>
    public void ValidateBillingGroupAssignments(int intervalId,
                                                int materializationId)
    {
      int numBillingGroups;
      ValidateBillingGroupAssignments(intervalId, materializationId, out numBillingGroups);
    }

    /// <summary>
    ///  Validate the following for the given materialization:
    ///  1) The accounts in t_billgroup_source_acc are not repeated
    ///  2) The accounts in t_billgroup_member_tmp are 
    ///     not repeated i.e. each account is matched to exactly 
    ///     one billing group name. 
    ///  3) All accounts in t_billgroup_source_acc are present in t_billgroup_member_tmp
    ///  4) Each billing group has atleast one account. 
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="numBillingGroups">return the number of billing groups created</param>
    public void ValidateBillingGroupAssignments(int intervalId,
                                                int materializationId, 
                                                out int numBillingGroups) 
    {
      mLogger.LogDebug
        ("Validating billing group assignments for materialization {0}...", 
        materializationId);

      int status = (int)ValidateBillGroupAssignmentsMsg.Success;

      using (IMTConnection conn =
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt =
            conn.CreateCallableStatement("ValidateBillGroupAssignments"))
          {

              stmt.AddParam("id_materialization", MTParameterType.Integer, materializationId);
              stmt.AddOutputParam("billingGroupsCount", MTParameterType.Integer);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              stmt.ExecuteNonQuery();

              numBillingGroups = (int)stmt.GetOutputValue("billingGroupsCount");
              status = (int)stmt.GetOutputValue("status");
          }
      }

      switch(status) 
      {
        case (int)ValidateBillGroupAssignmentsMsg.Success: 
        {
          mLogger.LogDebug
            ("Successfully validated billing group assignments for " +
            "materialization '{0}'...", materializationId);
          break;
        }
        case (int)ValidateBillGroupAssignmentsMsg.DuplicateAccountsInBillgroupSourceAcc: 
        {
          throw new DuplicateAccountsInBillgroupSourceAccException(intervalId);
        }
        case (int)ValidateBillGroupAssignmentsMsg.DuplicateAccountsInBillgroupMemberTmp: 
        {
          throw new DuplicateAccountsInBillgroupMemberTmpException(intervalId);
        }
        case (int)ValidateBillGroupAssignmentsMsg.MissingAccounts: 
        {
          throw new MissingAccountsFromBillgroupMemberTmpException(intervalId);
        }
        case (int)ValidateBillGroupAssignmentsMsg.EmptyBillingGroup: 
        {
          throw new EmptyBillingGroupInTmpException(intervalId);
        }
        case (int)ValidateBillGroupAssignmentsMsg.DuplicateBillingGroupNamesInBillGroupTmp: 
        {
          throw new DuplicateBillingGroupNamesInBillGroupTmpException(intervalId);
        }
        default: 
        {
          throw new BillingGroupAssignmentValidationFailedException
            (String.Format("Unknown error occurred " +
            "while attempting to validate billing group assignments " +
            "for interval '{0}'!",
            intervalId));
        }
      }
    }

    /// <summary>
    ///    Return the query paths and tags for the assignment query.
    ///    Default query tags are returned if either of the following is true:
    ///      - useDefaultQuery is true
    ///      - the config file does not contain billing group query tags
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="useDefaultQuery"></param>
    /// <param name="assignmentQueryPath"></param>
    /// <param name="assignmentQueryTag"></param>
    /// <param name="descriptionQueryPath"></param>
    /// <param name="descriptionQueryTag"></param>
    private void GetQueryData(int materializationId,
                              bool useDefaultQuery,
                              out string assignmentQueryPath,
                              out string assignmentQueryTag,
                              out string descriptionQueryPath,
                              out string descriptionQueryTag) 
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.LoadConfigFile(mConfigFile);

      assignmentQueryPath = String.Empty;
      assignmentQueryTag = String.Empty;
      descriptionQueryPath = String.Empty;
      descriptionQueryTag = String.Empty;

      // If there is no /xmlconfig/BillingGroups section in the configuration
      // file, then return assignment and description query which
      // creates one billing group with all the accounts in it
      if (doc.SingleNodeExists("/xmlconfig/BillingGroups") == null || useDefaultQuery) 
      {
        assignmentQueryTag = GetDefaultAssignmentQuery(materializationId);
        descriptionQueryTag = GetDefaultDescriptionQuery(materializationId);
        return;
      }

      // Get the path to the assignment query
      assignmentQueryPath = 
        doc.GetNodeValueAsString
        ("/xmlconfig/BillingGroups/RecurringBillingGroups/" +
        "AssignmentQuery/QueryPath", assignmentQueryPath);

      mLogger.LogDebug("Assignment Query Path : {0} ", assignmentQueryPath);

      // Get the assignment query tag
      assignmentQueryTag = 
        doc.GetNodeValueAsString
        ("/xmlconfig/BillingGroups/RecurringBillingGroups/" +
        "AssignmentQuery/QueryTag", assignmentQueryTag);

      mLogger.LogDebug("Assignment Query Tag : {0} ", assignmentQueryTag);

      // Get the path to the description query
      descriptionQueryPath = 
        doc.GetNodeValueAsString
        ("/xmlconfig/BillingGroups/RecurringBillingGroups/" +
        "DescriptionQuery/QueryPath", descriptionQueryPath);

      mLogger.LogDebug("Description Query Path : {0} ", descriptionQueryPath);

      // Get the description query tag
      descriptionQueryTag = 
        doc.GetNodeValueAsString
        ("/xmlconfig/BillingGroups/RecurringBillingGroups/" +
        "DescriptionQuery/QueryTag", descriptionQueryTag);

      mLogger.LogDebug("Description Query Tag : {0} ", descriptionQueryTag);
    }

    /// <summary>
    ///   Run each adapter to validate that the mappings in the 
    ///   t_billgroup_member_tmp table do not violate 
    ///   adapter billing group constraints. 
    ///   
    ///   If any constraint is not satisfied, the materialization 
    ///   will fail with a descriptive error message. 
    ///   An SI will need to be notified to correct the faulty assignment query 
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    private void CheckAdapterConstraints(int intervalId, 
      int materializationId,
      string billingGroupName) 
    {
      mLogger.LogDebug("Checking Adapter Constraints for " +
        "materialization '{0}'", materializationId);

      ArrayList adapterDataList = 
        GetAdapterInstances(intervalId, adapterInstancesWithBillingGroupConstraints);

      foreach(AdapterData adapterData in adapterDataList)
      {
        // If CreateBillingGroupConstraints adds any accounts
        // to the billing group then throw an exception.

        // If the actual call to SatisfyBillingGroupConstraints (in CheckSatisfyBillingGroupConstraints)
        // throws an exception it's caught, wrapped in a CreateBillingGroupConstraintsException
        // and rethrown.
        if (CheckCreateBillingGroupConstraints(intervalId, materializationId))
        {
          throw new CreateBillingGroupConstraintsException(adapterData.eventName, null);
        }
      }
    }

    /// <summary>
    /// 1) Copy billing group data from temporary tables to system tables.
    /// 2) Update the materialization in 
    ///    t_billgroup_materialization to 'Succeeded'
    /// 3) Delete data from temporary tables.
    /// </summary>
    /// <param name="materializationId"></param>
    private void CompleteMaterialization(int intervalId,
      int materializationId, 
      DateTime endDate) 
    {
      mLogger.LogDebug("Creating billing groups for interval '{0}'...", intervalId);

      int status = (int)CompleteMaterializationMsg.Success;

      using (IMTConnection conn =
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt =
            conn.CreateCallableStatement("CompleteMaterialization"))
          {

              stmt.AddParam("id_materialization", MTParameterType.Integer, materializationId);
              stmt.AddParam("dt_end", MTParameterType.DateTime, endDate);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              stmt.ExecuteNonQuery();

              status = (int)stmt.GetOutputValue("status");
          }
      }

      switch(status) 
      {
        case (int)CompleteMaterializationMsg.Success: 
        {
          mLogger.LogDebug
            ("Successfully creating billing groups for interval {0}", intervalId);
          break;
        }
        case (int)CompleteMaterializationMsg.EmptyBillingGroup: 
        {
          throw new UsageServerException
            (String.Format("Could not create billing groups for interval '{0}' " +
                           "because one or more billing groups " +
                           "would not have any accounts!", intervalId), false);
        }
        case (int)CompleteMaterializationMsg.ErrorWithCleanup: 
        {
          throw new UsageServerException
            (String.Format("Could not create billing groups for interval '{0}' " +
                           "because the " +
                           "[CleanupMaterialization] stored procedure did not execute successfully",
                            intervalId), false);
        }
        case (int)CompleteMaterializationMsg.ErrorWithRefreshBillingGroupConstraints:
        {
          throw new UsageServerException
            (String.Format("Billing group re-creation for interval '{0}' " +
            "failed because the " +
            "[RefreshBillingGroupConstraints] stored procedure " +
            "did not execute successfully", intervalId), false);
        }
        default: 
        {
          throw new UsageServerException
            (String.Format("Could not create billing groups for interval '{0}' " +
                           "due to an unknown reason ", intervalId), false);
        }
      }
    }

    /// <summary>
    /// 1) Attempts to move unassigned accounts in the interval
    ///    to new or open billing groups.
    /// 2) Attempts to move accounts from open pull lists to open billing groups.
    ///    Deletes the pull lists if it becomes empty.
    /// 3) Attempts to move accounts from open user defined billing groups
    ///    to open billing groups. Deletes the user defined group if it becomes empty.
    /// 4) Records account movement into and out of Soft Closed/Hard Closed
    ///    billing groups - without actually making the moves. 
    /// 5) Copy billing group data from temporary tables to system tables.
    /// 6) Update the materialization in 
    ///    t_billgroup_materialization to 'Succeeded'
    /// 7) Delete data from temporary tables.
    /// </summary>
    /// <param name="materializationId"></param>
    private void CompleteReMaterialization(int intervalId,
      int materializationId, 
      DateTime endDate) 
    {
      mLogger.LogDebug
        ("Completing re-creation of billing groups for interval '{0}'...", intervalId);

      int status = (int)CompleteReMaterializationMsg.Success;

      using (IMTConnection conn =
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt =
            conn.CreateCallableStatement("CompleteReMaterialization"))
          {

              stmt.AddParam("id_materialization", MTParameterType.Integer, materializationId);
              stmt.AddParam("dt_end", MTParameterType.DateTime, endDate);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              stmt.ExecuteNonQuery();

              status = (int)stmt.GetOutputValue("status");
          }
      }

      switch(status) 
      {
        case (int)CompleteReMaterializationMsg.Success: 
        {
          mLogger.LogDebug
            ("Successfully recreated billing groups for interval '{0}'...", intervalId);
          break;
        }
        case (int)CompleteReMaterializationMsg.Failed: 
        {
          throw new CompleteMaterializationException(intervalId);
        }
        case (int)CompleteReMaterializationMsg.EmptyBillingGroup: 
        {
          throw new UsageServerException
            (String.Format("Billing group re-creation for interval '{0}' failed because " +
                           "one or more billing groups will be created with no accounts!",
                           intervalId), false);
        }
        case (int)CompleteMaterializationMsg.ErrorWithRefreshBillingGroupConstraints: 
        {
          throw new UsageServerException
            (String.Format("Billing group re-creation for interval '{0}' " +
            "failed because the " +
            "[RefreshBillingGroupConstraints] stored procedure " +
            "did not execute successfully", intervalId), false);
        }
        case (int)CompleteMaterializationMsg.ErrorWithCleanup: 
        {
          throw new UsageServerException
            (String.Format("Billing group re-creation for interval '{0}' " +
                           "failed because the " +
                           "[CleanupMaterialization] stored procedure " +
                           "did not execute successfully", intervalId), false);
        }
        default: 
        {
          throw new UsageServerException
            (String.Format("Billing group re-creation for interval '{0}' " +
                           "failed with an unknown reason!", intervalId), false);
        }
      }
    }

    /// <summary>
    ///    Create temporary pull list data in t_billgroup_tmp and t_billgroup_member_tmp
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="name"></param>
    /// <param name="description"></param>
    /// <param name="parentBillingGroupId"></param>
    /// <param name="accounts">comma separated list of accout id's</param>
    private void CreateTempPullListAssignments(int materializationId, 
      string name, 
      string description, 
      IBillingGroup parentBillingGroup, 
      string accounts) 
    {
      mLogger.LogDebug
        ("Creating temporary pull list for materialization '{0}'...", materializationId);

      int status = (int)StartChildGroupCreationMsg.Success;

      try 
      {
          using (IMTConnection conn =
                  ConnectionManager.CreateConnection(mUsageServerQueryPath))
          {
              using (IMTCallableStatement stmt =
                conn.CreateCallableStatement("StartChildGroupCreation"))
              {

                  stmt.AddParam("id_materialization", MTParameterType.Integer, materializationId);
                  stmt.AddParam("tx_name", MTParameterType.WideString, name);
                  stmt.AddParam("tx_description", MTParameterType.WideString, description);
                  stmt.AddParam("id_parent_billgroup",
                    MTParameterType.Integer,
                    parentBillingGroup.BillingGroupID);
                  stmt.AddParam("accountArray", MTParameterType.String, accounts);
                  stmt.AddOutputParam("status", MTParameterType.Integer);

                  stmt.ExecuteNonQuery();

                  status = (int)stmt.GetOutputValue("status");
              }
          }
      }
      catch(Exception e) 
      {
        throw new UsageServerException
          (String.Format("Pull list '{0}' could not be created " +
          "for the parent billing group '{1}' " +
          "with the following reason: " + e.Message, 
          name, parentBillingGroup.BillingGroupID), true); 
      }

      switch(status) 
      {
        case (int)StartChildGroupCreationMsg.Success: 
        {
          mLogger.LogDebug
            ("Successfully created temporary pull list '{0}' for materialization '{1}'", 
            name, materializationId);
          break;
        }
        case (int)StartChildGroupCreationMsg.NoAccounts: 
        {
          throw new CreatingPullListsWithNoAccountsException(name, LogLevel.Warning);
        }
        case (int)StartChildGroupCreationMsg.DuplicateAccounts: 
        {
          throw new CreatingPullListWithDuplicateAccountsException(name, LogLevel.Warning);
        }
        case (int)StartChildGroupCreationMsg.NonParentBillingGroupMember: 
        {
          throw new CreatingPullListWithNonParentMembersException(name, LogLevel.Warning);
        }
        case (int)StartChildGroupCreationMsg.AllBillingGroupMembers: 
        {
          throw new CreatingPullListWithAllParentMembersException(name, LogLevel.Warning);
        }
        default: 
        {
          throw new UsageServerException
            (String.Format("Temporary pull list '{0}' for parent billing group '{0}' " +
            "could not be created for an unknown reason!",
            name, parentBillingGroup.BillingGroupID), true);
        }
      }
    }

    /// <summary>
    ///   Create temporary billing group assignments based on unassigned accounts.
    ///   If the accounts parameter is null, then the billing group assignments
    ///   are based on all unassigned accounts for the interval associated with
    ///   the given materializationId.
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="name"></param>
    /// <param name="description"></param>
    /// <param name="accounts"></param>
    private void StartUserDefinedGroupCreation(int materializationId,
      string name, 
      string description, 
      string accounts) 
    {
      mLogger.LogDebug
        ("Creating user defined billing group for materialization '{0}'...", 
        materializationId);

      int status = (int)StartUserDefinedGroupCreationMsg.Success;

      try 
      {
          using (IMTConnection conn =
                  ConnectionManager.CreateConnection(mUsageServerQueryPath))
          {
              using (IMTCallableStatement stmt =
                conn.CreateCallableStatement("StartUserDefinedGroupCreation"))
              {

                  stmt.AddParam("id_materialization", MTParameterType.Integer, materializationId);
                  stmt.AddParam("tx_name", MTParameterType.WideString, name);
                  stmt.AddParam("tx_description", MTParameterType.WideString, description);
                  stmt.AddParam("accountArray", MTParameterType.String, accounts);
                  stmt.AddOutputParam("status", MTParameterType.Integer);

                  stmt.ExecuteNonQuery();

                  status = (int)stmt.GetOutputValue("status");
              }
          }
      }
      catch(Exception e) 
      {
        throw new UsageServerException
          (String.Format("User defined billing group '{0}' failed to be created with the following message " +
                         e.Message, name), true); 
      }

      switch(status) 
      {
        case (int)StartUserDefinedGroupCreationMsg.Success: 
        {
          mLogger.LogDebug
            ("Successfully created user defined billing group '{0}' for materialization '{1}'", 
            name, materializationId);
          break;
        }
        case (int)StartUserDefinedGroupCreationMsg.NoFullMaterialization: 
        {
          throw new UsageServerException
            (String.Format("User defined billing group '{0}' cannot be created " +
            "until billing group assignment query has been run!", name), false);
        }
        case (int)StartUserDefinedGroupCreationMsg.IntervalOnlyAdapterExecution: 
        {
          throw new UsageServerException
            (String.Format("User defined billing group '{0}' cannot be created " +
            "until all interval-only adapters have been reversed!", name), false);
        }
        case (int)StartUserDefinedGroupCreationMsg.NoUnassignedAccounts: 
        {
          throw new UsageServerException
            (String.Format("User defined billing group '{0}' cannot be created " +
            "because there are no unassigned accounts for the interval!", name), false);
        }
        case (int)StartUserDefinedGroupCreationMsg.NoAccountsPassedIn: 
        {
          throw new UsageServerException
            (String.Format("User defined billing group '{0}' cannot be created " +
            "because no unassigned accounts were specified!", name), false);
        }
        case (int)StartUserDefinedGroupCreationMsg.DuplicateAccounts: 
        {
          throw new UsageServerException
            (String.Format("User defined billing group '{0}' cannot be created " +
            "because duplicate input accounts were specified!", name), false);
        }
        case (int)StartUserDefinedGroupCreationMsg.NonUnassignedAccountsPassedIn: 
        {
          throw new UsageServerException
            (String.Format("User defined billing group '{0}' cannot be created " +
            "because one or more input accounts do not belong to " +
            "the list of unassigned accounts!", name), false);
        }
      // CR 14312
      case (int)StartUserDefinedGroupCreationMsg.DuplicateBillingGroupName:
        {
          throw new UsageServerException
            (String.Format("User defined billing group '{0}' cannot be created " +
            "because a billing group with the same name already exists. " +
            "Please provide a different billing group name!", name), false);
        }
        default: 
        {
          throw new UsageServerException
            (String.Format("User defined billing group '{0}' " +
            "could not be created for an unknown reason!",
                           name), false);
        }
      }
    }

    

    /// <summary>
    ///   For those adapters which have billing group constraints,
    ///     1) Invoke each adapter’s CreateBillingGroupConstraints 
    ///        method at least once
    ///     2) If an adapter adds accounts (returns true),  
    ///        execute the CreateBillingGroupConstraints method 
    ///        on all other adapters except for this one again.
    ///     3) Repeat (2) until all adapters return false for 
    ///        CreateBillingGroupConstraints
    /// </summary>
    /// <param name="materializationId"></param>
    private void QueryAdapters(int materializationId, int intervalId, string billingGroupName)
    {
      // Get the list of valid adapter instances
      ArrayList adapterDataList = 
        GetAdapterInstances(intervalId, adapterInstancesWithBillingGroupConstraints);
      
      ArrayList runnableAdapters = adapterDataList;

      while (runnableAdapters.Count > 0) 
      {
        foreach(AdapterData adapterData in runnableAdapters) 
        {
          // if this adapter adds accounts to the pull list
          // then force all the other adapters except this one to run again
          if (CheckCreateBillingGroupConstraints(intervalId, materializationId))
          {
            MakeAdaptersRunnable(adapterData.eventId, adapterDataList);
          }

          adapterData.canRun = false;
        }

        runnableAdapters = GetRunnableAdapters(adapterDataList);
      }
    }

    /// <summary>
    ///    Get those AdapterData's from adapterDataList which have their
    ///    canRun set to 'true'
    /// </summary>
    /// <param name="adapterDataList"></param>
    /// <returns></returns>
    private ArrayList GetRunnableAdapters(ArrayList adapterDataList) 
    {
      ArrayList adapters = new ArrayList();

      foreach(AdapterData adapterData in adapterDataList) 
      {
        if (adapterData.canRun == true) 
        {
          adapters.Add(adapterData);
        }
      }
      
      return adapters;
    }

    /// <summary>
    ///    Set the CanRun status to 'true' for all the adapters in adapterDataList
    ///    except for the one with the given eventId.
    /// </summary>
    /// <param name="eventId"></param>
    /// <param name="adapterDataList"></param>
    private void MakeAdaptersRunnable(int eventId, ArrayList adapterDataList) 
    {
      foreach(AdapterData adapterData in adapterDataList)
      {
        if (adapterData.eventId != eventId) 
        {
          adapterData.canRun = true;
        }
      }
    }

    /// <summary>
    ///    Returns adapter instances which are billing group aware and
    ///    have billing group constraints.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns>ArrayList of AdapterData</returns>
    private ArrayList GetAdapterInstances(int intervalId,
      string optionalWhereClause) 
    {
      mLogger.LogDebug("Retrieving billing group aware adapter instances " + 
        "for the interval '{0}'", intervalId);

      ArrayList adapterInstances = new ArrayList();

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mUsageServerQueryPath, "__GET_EOP_REC_EVENTS__"))
          {
              stmt.AddParam("%%ID_INTERVAL%%", intervalId, true);
              stmt.AddParam("%%OPTIONAL_WHERE_CLAUSE%%", optionalWhereClause, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  string adapterClassName;
                  IRecurringEventAdapter2 recurringEventAdapter;
                  AdapterData adapterData;
                  bool isLegacyAdapter;

                  while (reader.Read())
                  {
                      if (reader.IsDBNull("ClassName"))
                      {
                          throw new UsageServerException("Unable to find adapter class name");
                      }

                      adapterClassName = reader.GetString("ClassName");
                      recurringEventAdapter =
                            AdapterManager.CreateAdapterInstance(adapterClassName, out isLegacyAdapter);

                      if (!isLegacyAdapter)
                      {
                          adapterData = new AdapterData();
                          adapterData.recurringEventAdapter = recurringEventAdapter;
                          adapterData.isLegacy = isLegacyAdapter;
                          if (!reader.IsDBNull("ExtensionName"))
                          {
                              adapterData.extensionName = reader.GetString("ExtensionName");
                          }
                          if (!reader.IsDBNull("ConfigFileName"))
                          {
                              adapterData.configFileName = reader.GetString("ConfigFileName");
                          }
                          adapterData.eventId = reader.GetInt32("EventID");
                          adapterData.eventName = reader.GetString("EventName");
                          adapterData.adapterClassName = adapterClassName;
                          adapterData.canRun = true;

                          adapterInstances.Add(adapterData);
                      }
                  }
              }
          }
      }

      return adapterInstances;
    }

    /// <summary>
    ///    Returns the adapter names for those adapters which 
    ///    failed to satisfy the billing group constraints 
    ///    for the billing group assignments in t_billgroup_member_tmp 
    ///    for the given id_materialization
    /// </summary>
    /// <param name="materializationId"></param>
    /// <returns>ArrayList of adapter names</returns>
    private ArrayList GetFailedBillingGroupConstraintsAdapters(int materializationId) 
    {
      ArrayList adapterNames = new ArrayList();

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath,
                                        "__GET_ADAPTERS_WHICH_FAILED_TO_SATISFY_BILLING_GROUP_CONSTRAINTS__"))
          {
              stmt.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  adapterNames.Add(reader.GetString("AdapterName"));
              }

          }
      }

      return adapterNames;
    }

    /// <summary>
    ///    During creation of pull lists, adapters are given the option
    ///    of satisfying their billing group constraints by adding accounts from
    ///    the original billing group to the pull list being created.
    ///    
    ///    If the adapter misbehaves and adds accounts (in the temporary table)
    ///    to the pull list, that do not come from the original billing group,
    ///    then this method will log the following for each offending adapter:
    ///    - the name of the adapter (or 'Unknown' if the adapter hasn't filled in the event id)
    ///    - the account id it's trying to pull in
    ///    - the number of times it's trying to pull in the same account id
    ///    
    ///    An exception is thrown, if there are any adapters that adds accounts to the 
    ///    pull list which do not belong to the parent billing group. 
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="parentBillingGroupId"></param>
    private void CheckNonParentAccounts(int materializationId, 
                                        IBillingGroup parentBillingGroup,
                                        string pullListName)
    {
      int count = 0;

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mUsageServerQueryPath, "__GET_NON_PARENT_ACCOUNTS__"))
          {
              stmt.AddParam("%%ID_PARENT_BILLGROUP%%", parentBillingGroup.BillingGroupID, true);
              stmt.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  count++;
                  int accountId = reader.GetInt32("AccountID");
                  mLogger.LogError(
                    String.Format("Account {0} does not belong to the original billing group {1}",
                                  accountId, parentBillingGroup.Name));
              }
          }
      }

      if (count > 0) 
      {
        throw new UsageServerException
          (String.Format
            ("One or more accounts which do not belong to the " +
             "original billing group '{0}' were found while creating pull list '{1}'. " +
             "See log for details",
             parentBillingGroup.Name, pullListName));
      }
    }

    private void CheckCopyAdapterInstanceStatus(int status, 
      int materializationId)
    {
      switch(status) 
      {
        case (int)CopyAdapterInstancesMsg.Success: 
        {
          mLogger.LogDebug
            ("Successfully created recurring event instance data for materialization '{0}'...", 
            materializationId);
    
          break;
        }
        case (int)CopyAdapterInstancesMsg.NullParentBillingGroup: 
        {
          throw new UsageServerException
            (String.Format("The parent billing group is NULL"), true);
        }
        case (int)CopyAdapterInstancesMsg.NonPullList: 
        {
          throw new UsageServerException
            (String.Format("Expected a pull list"), true);
        }
        case (int)CopyAdapterInstancesMsg.NotInProgress: 
        {
          throw new UsageServerException
            (String.Format("Expected billing group creation to be in 'InProgress'"), true);
        }
        case (int)CopyAdapterInstancesMsg.NoBillingGroupIdInTmp: 
        {
          throw new UsageServerException
            (String.Format("Billing group id not found in t_billgroup_tmp "), true);
        }
        case (int)CopyAdapterInstancesMsg.NoInstancesToCopy: 
        {
          mLogger.LogDebug("No instance data to be copied for pull list ...");
    
          break;
        }
        default: 
        {
          throw new UsageServerException
            (String.Format
            ("Recurring event instance data creation failed with an unknown error"), true);
        }
      }
    }

    

    private int GetIntervalId(int materializationId)
    {
      int intervalId = -1;

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__GET_USAGE_INTERVAL_FOR_MATERIALIZATION__"))
          {
              stmt.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  int count = 0;
                  while (reader.Read())
                  {
                      count++;
                      // Error if we've found more than one row
                      if (count > 1)
                      {
                          throw new UsageServerException
                            (String.Format
                            ("Could not get usage interval for materialization '{0}'",
                            materializationId), true);
                      }

                      intervalId = reader.GetInt32("UsageIntervalID");
                  }
              }
          }
      }

      return intervalId;
    }

    private void CheckEmptyParentBillingGroup(int materializationId, 
      int parentBillingGroupId)
    {
      string emptyGroup = String.Empty;

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__CHECK_EMPTY_PARENT_BILLING_GROUP__"))
          {
              stmt.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
              stmt.AddParam("%%ID_PARENT_BILLGROUP%%", parentBillingGroupId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  int count = 0;
                  while (reader.Read())
                  {
                      // Error if we've found more than one row
                      if (count > 1)
                      {
                          throw new UsageServerException
                            (String.Format("The query __CHECK_EMPTY_PARENT_BILLING_GROUP__ returned more than one row."));
                      }

                      emptyGroup = reader.GetString("EmptyParentBillGroup");
                  }
              }
          }
      }

      if (emptyGroup.Equals("Y")) 
      {
        throw new UsageServerException
          ("The accounts in the original billing group cannot be split because " +
           "of system constraints such as group subscriptions", LogLevel.Warning); 
      }
    }

    /// <summary>
    ///   Return true if a materialization is in progress for
    ///   the given intervalId.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    private bool IsMaterializationInProgress(int intervalId,
      out string userId,
      out DateTime startTime,
      out string materializationType) 
    {
      bool inProgress = false;

      userId = "";
      startTime = DateTime.Now;
      materializationType = "";

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__GET_MATERIALIZATION_IN_PROGRESS__"))
          {

              stmt.AddParam("%%ID_INTERVAL%%", intervalId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      inProgress = true;
                      userId = Convert.ToString(reader.GetInt32("id_user_acc"));
                      startTime = reader.GetDateTime("dt_start");
                      materializationType = reader.GetString("tx_type");
                      break;
                  }
              }
          }
      }

      return inProgress;
    }

    /// <summary>
    ///   Return true if a full materialization has been done for the
    ///   given intervalId.
    /// </summary>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    public bool HasBeenFullyMaterialized(int intervalId) 
    {
      bool hasBeenFullyMaterialized = false;

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__GET_FULL_MATERIALIZATION__"))
          {
              stmt.AddParam("%%ID_INTERVAL%%", intervalId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  int count = 0;
                  while (reader.Read())
                  {
                      count++;
                      // Error if we've found more than one row
                      if (count > 1)
                      {
                          throw new UsageServerException
                            (String.Format("The interval '{0}' has more than one 'Full' materialization!", intervalId));
                      }

                      hasBeenFullyMaterialized = true;
                  }
              }
          }
      }

      return hasBeenFullyMaterialized;
    }

    private string GetDefaultAssignmentQuery(int materializationId) 
    {
      return defaultAssignmentQuery.Replace("%%ID_MATERIALIZATION%%", 
        Convert.ToString(materializationId));
    }

    private string GetDefaultDescriptionQuery(int materializationId) 
    {
      return defaultDescriptionQuery.Replace("%%ID_MATERIALIZATION%%", 
        Convert.ToString(materializationId));
    }

    /// <summary>
    ///    1) Each line is separated by "\r\n".
    ///    2) An account line can be one of the following:
    ///       a) A blank line
    ///       b) One or more comma/space separated integers  
    ///       c) A line ending with (123) where 123 is the account id
    ///       d) A line with a username,namespace pair !TODO
    ///       
    /// </summary>
    /// <param name="accounts"></param>
    /// <returns>ArrayList of account identifiers as integers</returns>
    private string ParseAccounts(string accounts) 
    {
      StringBuilder commaSeparatedAccounts = new StringBuilder();
     
      string[] accountLines = newLineRegex.Split(accounts); 
      ArrayList nonBlankLines = new ArrayList();
      Match match = null;

      // Filter out the lines which are blank
      foreach(string accountLine in accountLines) 
      {
        match = blankLineRegex.Match(accountLine);
        if (!match.Success) 
        {
          nonBlankLines.Add(accountLine);
        }
      }

      AccountLineParser accountLineParser = new AccountLineParser();
      ArrayList accountList = new ArrayList();
      ArrayList errorList = new ArrayList();

      // Parse each of the lines
      foreach(string accountLine in nonBlankLines)
      {
        ArrayList parsedAccounts = accountLineParser.ParseLine(accountLine);
        if (parsedAccounts.Contains(Int32.MinValue)) 
        {
          errorList.Add(accountLine);
        }
        else 
        {
          accountList.AddRange(parsedAccounts);
        }
      }
      
      if (errorList.Count > 0) 
      {
        StringBuilder errorAccounts = new StringBuilder();
        bool firstAccount = true;
        foreach(string errorAccount in errorList) 
        {
          if (firstAccount) 
          {
            errorAccounts.Append(errorAccount);
            firstAccount = false;
          }
          else 
          {
            errorAccounts.Append("\n");
            errorAccounts.Append(errorAccount);
          }
        }
        throw new UsageServerException(
          String.Format("The following accounts could not be found! : " + 
                        errorAccounts.ToString()), true);
      }

      if (accountList.Count == 0) 
      {
        throw new UnableToParseAccountsException(accounts);
      }

      for (int i = 0; i < accountList.Count; i++) 
      {
        if (i != 0) 
        {
          commaSeparatedAccounts.Append(",");
        }

        commaSeparatedAccounts.Append(accountList[i]);
      }

      return commaSeparatedAccounts.ToString();
    }

    /// <summary>
    ///    
    /// </summary>
    /// <param name="accounts">contains int's</param>
    /// <returns></returns>
    private string GetCommaSeparatedAccounts(Coll.IMTCollection accounts)
    {
      StringBuilder commaSeparatedAccounts = new StringBuilder();

      int count = 0;
      foreach (string account in accounts) 
      {
        if (count != 0) 
        {
          commaSeparatedAccounts.Append(",");
        }

        commaSeparatedAccounts.Append(Convert.ToInt32(account));
        count++;
      }
      
      return commaSeparatedAccounts.ToString();
    }

    /// <summary>
    ///    
    /// </summary>
    /// <param name="rowset">Column:AccountID</param>
    /// <returns></returns>
    private string GetCommaSeparatedAccounts(Rowset.IMTSQLRowset rowset)
    {
      StringBuilder commaSeparatedAccounts = new StringBuilder();
      rowset.MoveFirst();

      int count = 0;
      while (!System.Convert.ToBoolean(rowset.EOF))
      {
        if (count != 0) 
        {
          commaSeparatedAccounts.Append(",");
        }

        commaSeparatedAccounts.Append((int)rowset.get_Value("AccountID"));
        count++;

        rowset.MoveNext();
      }
      return commaSeparatedAccounts.ToString();
    }

    /// <summary>
    ///    Updates the state of those accounts in commaSeparatedAccounts which 
    ///    don't have usage to hard closed. 
    ///    Returns the list of accounts in commaSeparatedAccounts which have usage.
    /// </summary>
    /// <param name="commaSeparatedAccounts"></param>
    /// <param name="intervalId"></param>
    /// <returns></returns>
    public Rowset.IMTSQLRowset UpdateUnassignedAccountsToHardClosed
      (string commaSeparatedAccounts, int intervalId, bool checkUsage, bool isTransactional)
    {
      Rowset.IMTSQLRowset rowset = null;

      int status = (int)UpdateUnassignedAccountsMsg.Success;
    
      mLogger.LogDebug
        ("Updating unassigned accounts " +
        "with no usage to hard closed for interval '{0}'...", intervalId);
  
      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpdateUnassignedAccounts"))
          {
              stmt.AddParam("accountArray", MTParameterType.String, commaSeparatedAccounts);
              stmt.AddParam("id_interval", MTParameterType.Integer, intervalId);
              stmt.AddParam("state", MTParameterType.String, "H");
              stmt.AddParam("checkUsage", MTParameterType.Integer, checkUsage ? 1 : 0);
              stmt.AddParam("isTransactional", MTParameterType.Integer, isTransactional ? 1 : 0);
              stmt.AddOutputParam("status", MTParameterType.Integer);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  if (checkUsage)
                  {
                      rowset = CreateGUIRowset(reader);
                  }
              }

              status = (int)stmt.GetOutputValue("status");
          }

        switch(status) 
        {
          case (int)UpdateUnassignedAccountsMsg.Success: 
          {
            mLogger.LogDebug
              ("Successfully updated unassigned accounts " +
              "with no usage to hard closed for interval '{0}'...", intervalId);
            
            break;
          }
          case (int)UpdateUnassignedAccountsMsg.NoAccountsInAccountArray: 
          {
            throw new UsageServerException
              (String.Format("No accounts specified!"), true);
          }
          case (int)UpdateUnassignedAccountsMsg.DuplicateAccountsInAccountArray: 
          {
            throw new UsageServerException
              (String.Format("Duplicate accounts specified!"), true);
          }
          case (int)UpdateUnassignedAccountsMsg.AccountsAreNotUnassignedAccounts: 
          {
            throw new UsageServerException
              (String.Format("One or more specified accounts are not unassigned accounts!"), true);
          }
          case (int)UpdateUnassignedAccountsMsg.AccountsAlreadyInStateSpecified: 
          {
            throw new UsageServerException
              (String.Format("One or more specified accounts are already hard closed!"), true);
          }
          default: 
          {
            throw new UsageServerException
              (String.Format("An unknown error occurred while updating unassigned accounts " +
              "with no usage to hard closed for interval '{0}'...", intervalId), true);
          }
        }
      }

      return rowset;
    }

    /// <summary>
    ///   1) Creates a rowset with the following columns:
    ///      AccountID, ErrorMessage
    ///   2) Populates the rowset using the given IMTDataReader
    /// </summary>
    /// <param name="reader">Can be null</param>
    /// <returns></returns>
    private Rowset.IMTSQLRowset CreateGUIRowset(IMTDataReader reader)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      
      // initializes the rowset
      rowset.InitDisconnected();
      rowset.AddColumnDefinition("AccountID", "int32", 6);
      rowset.AddColumnDefinition("ErrorMessage", "string", 80);
      rowset.OpenDisconnected();

      if (reader != null) 
      {
        while (reader.Read())
        {
          rowset.AddRow();
          rowset.AddColumnData("AccountID", reader.GetInt32("id_acc"));
          rowset.AddColumnData("ErrorMessage", "Account has usage!");
        }
      }
      return rowset;
    }

    /// <summary>
    ///    Calls CreateBillingGroupConstraints on the given adapter.
    ///    Returns true if the adapter added any accounts to the
    ///    given billing group.
    /// </summary>
    /// <param name="adapter"></param>
    /// <returns></returns>
    private bool CheckCreateBillingGroupConstraints(int intervalId,
                                                    int materializationId)
    {
      throw new NotImplementedException("CheckCreateBillingGroupConstraints not implemented!");
//      bool addedAccounts = false;
//
//      // Get the number of accounts before making the call to 
//      // CreateBillingGroupConstraints
//      int numAccountsBefore = 
//        GetNumberOfBillingGroupAccountsFromTempTable(materializationId, billingGroupName);
//
//      try 
//      {
//        // Call CreateBillingGroupConstraints
//        adapterData.recurringEventAdapter.CreateBillingGroupConstraints(intervalId, 
//                                                                        materializationId);
//      }
//      catch (Exception e) 
//      {
//        throw new CreateBillingGroupConstraintsException(adapterData.eventName, e);
//      }
//
//      // Get the number of accounts after making the call to 
//      // CreateBillingGroupConstraints
//      int numAccountsAfter = 
//        GetNumberOfBillingGroupAccountsFromTempTable(materializationId, billingGroupName);
//
//      if (numAccountsBefore != numAccountsAfter) 
//      {
//        addedAccounts = true;
//      }
//
//      return addedAccounts;
    }
    
    /// <summary>
    ///    Return the number of accounts for the given billingGroup and
    ///    materializationId from t_billgroup_member_tmp
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="billingGroupName"></param>
    /// <returns></returns>
    private int GetNumberOfBillingGroupAccountsFromTempTable(int materializationId,
      string billingGroupName)
    {
      int numAccounts = 0;

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath,
                                        "__GET_NUMBER_OF_ACCOUNTS_FOR_BILLING_GROUP_FROM_TEMP_TABLE__"))
          {
              stmt.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);
              stmt.AddParam("%%TX_NAME%%", billingGroupName, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      numAccounts = reader.GetInt32("NumAccounts");
                      break;
                  }
              }
          }
      }

      return numAccounts;
    }

    /// <summary>
    ///    Return the number of accounts for the given billingGroup and
    ///    materializationId from t_billgroup_member_tmp
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="billingGroupName"></param>
    /// <returns></returns>
    private string GetBillingGroupNameFromTempTable(int materializationId)
    {
      string billingGroupName = String.Empty;

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__GET_BILLING_GROUP_NAME_FROM_TEMP_TABLE__"))
          {
              stmt.AddParam("%%ID_MATERIALIZATION%%", materializationId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      billingGroupName = reader.GetString("tx_name");
                      break;
                  }
              }
          }
      }
      
      if (billingGroupName.Length == 0) 
      {
        throw new UsageServerException
          (String.Format("Unable to find billing group name from temporary table!"), true);
      }

      return billingGroupName;
    }


    private void SetupDefaultQueryStrings()
    {
			defaultAssignmentQuery = 
				"INSERT INTO t_billgroup_member_tmp (id_materialization, id_acc, tx_name) " +
				"SELECT %%ID_MATERIALIZATION%%, acc.id_acc, '" + defaultBillingGroupName + "' " +
				"FROM t_billgroup_source_acc acc " +
				"WHERE acc.id_materialization = %%ID_MATERIALIZATION%%";

			// Default billing group description query
      defaultDescriptionQuery = string.Format(
        @"INSERT INTO t_billgroup_tmp ({0} id_materialization, tx_name, tx_description) "
        + "values ({1} %%ID_MATERIALIZATION%%, '{2}', 'Default billing group')",
        isOracle ? "id_billgroup, " : "",
        isOracle ? "seq_t_billgroup_tmp.nextval, " : "",
        defaultBillingGroupName);
	  
			adapterInstancesWithBillingGroupConstraints = 
				" r.tx_billgroup_support != 'Interval' AND r.b_has_billgroup_constraints = 'Y' AND r.dt_deactivated IS NULL AND ";

			adapterInstancesWithCustomReverse = 
				" r.tx_billgroup_support != 'Interval' AND r.tx_reverse_mode = 'Custom' AND ";
    }

    /// <summary>
    ///    1) Allow the adapters to create groups of accounts in 
    ///    t_billgroup_constraint_tmp. 
    ///    
    ///    2) Fills in missing payers. 
    ///    If a payer is not found in any constraint group after all 
    ///    adapters have run, the framework will create a constraint groups 
    ///    of one for the missing payers. 
    ///    If any of the accounts in t_billgroup_source_acc do not exist
    ///    in t_billgroup_constraint_tmp after the adapters have created
    ///    their constraint groups, then create one group per account for
    ///    the remaining accounts.
    ///    
    ///    3) Validates constraint groups are named correctly. 
    ///    The id_group must be any one of the account IDs in the constraint group.
    ///    This avoids false coalescing later on.
    ///    
    ///    4) Prunes (just to be 'regular') and coalesces constraint groups. 
    ///    If constraint groups intersect, they will be coalesced into 
    ///    larger groups containing a union of the intersecting groups. 
    ///    Worst case, all groups will coalesce into one supergroup 
    ///    representing every payer in the interval. 
    ///    By the end of this process, there will be one row for 
    ///    every payer and every payer will belong to exactly one constraint group.
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="intervalId"></param>
    private void CreateBillingGroupConstraints(int materializationId, int intervalId)
    {
      if (UseDefaultQuery())
      {
        return;
      }

      mLogger.LogDebug("Creating billing group constraints for " +
                       "materialization '{0}'", materializationId);

      // Get the list of adapters which have billing group constraints
      ArrayList adapterDataList = 
        GetAdapterInstances(intervalId, adapterInstancesWithBillingGroupConstraints);

      // Allow each adapter to create billing group constraints in 
      // t_billgroup_constraint_tmp
      foreach(AdapterData adapterData in adapterDataList)
      {
        try 
        {
					mLogger.LogDebug("Creating billing group constraints for event: '{0}'", adapterData.eventName);
          adapterData.recurringEventAdapter.CreateBillingGroupConstraints(intervalId, 
                                                                          materializationId);
        }
        catch (Exception e) 
        {
          throw new CreateBillingGroupConstraintsException(adapterData.eventName, e);
        }
      }
 
      // Validate and complete the constraints
      CompleteBillingGroupConstraints(materializationId, intervalId);
    }

    /// <summary>
    ///    Items 2, 3 and 4 from CreateBillingGroupConstraints
    /// </summary>
    /// <param name="materializationId"></param>
    private void CompleteBillingGroupConstraints(int materializationId, int intervalId)
    {
      mLogger.LogDebug
        ("Completing creation of billing group constraints for materialization '{0}'...", 
          materializationId);

      int status = (int)CompleteBillingGroupConstraintsMsg.Success;

      try 
      {
          using (IMTConnection conn =
                  ConnectionManager.CreateConnection(mUsageServerQueryPath))
          {
              using (IMTCallableStatement stmt =
                conn.CreateCallableStatement("CompleteBillGroupConstraints"))
              {

                  stmt.AddParam("id_materialization", MTParameterType.Integer, materializationId);
                  stmt.AddOutputParam("status", MTParameterType.Integer);

                  stmt.ExecuteNonQuery();

                  status = (int)stmt.GetOutputValue("status");
              }
          }
      }
      catch(Exception e) 
      {
        throw new UsageServerException
          (String.Format("Constraint groups could not be created " +
                         "for interval '{0}' " +
                         "with the following reason: " + e.Message, 
                         intervalId), true); 
      }

      switch(status) 
      {
        case (int)CompleteBillingGroupConstraintsMsg.Success: 
        {
          mLogger.LogDebug
            ("Successfully completed creation of billing group constraints for interval '{0}'", 
             intervalId);
          break;
        }
        case (int)CompleteBillingGroupConstraintsMsg.NonPayerAccounts: 
        {
          throw new NonPayerAccountsInConstraintGroupsException(intervalId);
        }
        case (int)CompleteBillingGroupConstraintsMsg.IncorrectConstraintGroupId: 
        {
          throw new IncorrectConstraintGroupIdException(intervalId);
        }
        case (int)CompleteBillingGroupConstraintsMsg.DuplicateAccountsInConstraintGroups: 
        {
          throw new DuplicateAccountsInConstraintGroupsException(intervalId);
        }
        default: 
        {
          throw new UsageServerException
            (String.Format("Constraint groups could not be created " +
                           "for interval '{0}' " +
                           "due to an unknown reason.", intervalId), false); 
        }
      }
    }

    /// <summary>
    ///    Add extra accounts to the t_billgroup_member_tmp table
    ///    in order to satisfy grouping constraints specified in 
    ///    the t_billgroup_constraint table.
    ///    
    ///    For the given id_materialization, the t_billgroup_member_tmp table
    ///    contains the mapping of the pull list name to the accounts specified by the user.
    ///    
    ///    For each of the user specified accounts 
    ///        - get the group which it belongs to 
    ///        - get those accounts in the group which do not belong to the set of user specified accounts
    ///        - add those accounts into t_billgroup_member_tmp if they don't exist.
    ///          (new accounts are added with the b_extra flag set to 1)
    /// </summary>
    /// <param name="materializationId"></param>
    /// <param name="parentBillingGroupId"></param>
    private void SatisfyConstraintsForPullList(int materializationId, 
                                               IBillingGroup parentBillingGroup,
                                               string pullListName)
    {
      mLogger.LogDebug
        ("Trying to satisfy constraints for pull list '{0}'...", pullListName);

      int status = (int)SatisfyConstraintsForPullListMsg.Success;

      try 
      {
          using (IMTConnection conn =
                  ConnectionManager.CreateConnection(mUsageServerQueryPath))
          {
              using (IMTCallableStatement stmt =
                conn.CreateCallableStatement("SatisfyConstraintsForPullList"))
              {

                  stmt.AddParam("id_materialization", MTParameterType.Integer, materializationId);
                  stmt.AddParam("id_parent_billgroup", MTParameterType.Integer, parentBillingGroup.BillingGroupID);

                  stmt.AddOutputParam("status", MTParameterType.Integer);

                  stmt.ExecuteNonQuery();

                  status = (int)stmt.GetOutputValue("status");
              }
          }
      }
      catch(Exception e) 
      {
        throw new UsageServerException
          (String.Format("Unable to satisfy constraints for pull list '{0}' " +
                         "with the following reason: " + e.Message, 
                         pullListName), true); 
      }

      switch(status) 
      {
        case (int)SatisfyConstraintsForPullListMsg.Success: 
        {
          mLogger.LogDebug
            ("Successfully satisfied constraints for pull list '{0}'", pullListName);
          break;
        }
        case (int)SatisfyConstraintsForPullListMsg.NonParentBillingGroupMember: 
        {
          throw new UsageServerException
            (String.Format("One or more accounts needed to satisfy " +
                           "constraints for pull list '{0}' do not belong " +
                           "to the parent billing group '{1}'!", 
                           pullListName, parentBillingGroup.Name), false);
        }
        case (int)SatisfyConstraintsForPullListMsg.NullParentBillingGroup: 
        {
          throw new UsageServerException
            (String.Format("During the process of satisfying constraints " +
                           "for pull list '{0}' the parent billing group '{1}' is " +
                           "becoming empty!", 
                           pullListName, parentBillingGroup.Name), false);
        }
        default: 
        {
          throw new UsageServerException
            (String.Format("Constraint groups could not be created " +
                           "due to an unknown reason."), false); 
        }
      }
    }

    /// <summary>
    ///   Return the interval id for the given billing group id. If the billing group id is
    ///   not found, return BillingGroupFilter.invalidIntervalId (-1).
    /// </summary>
    /// <param name="billingGroupId"></param>
    /// <returns></returns>
    private int GetIntervalIdForBillingGroup(int billingGroupId) 
    {
      int intervalId = BillingGroupFilter.invalidIntervalId;

      using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(mUsageServerQueryPath, "__GET_INTERVAL_ID_FOR_BILLING_GROUP__"))
          {
              stmt.AddParam("%%ID_BILLGROUP%%", billingGroupId, true);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      intervalId = reader.GetInt32("id_usage_interval");
                      break;
                  }
              }
          }
      }

      return intervalId;
    }

    #endregion

    #region Private Classes
    private class AdapterData 
    {
      public IRecurringEventAdapter2 recurringEventAdapter;
      public bool isLegacy;
      public string extensionName;
      public string configFileName;
      public int eventId;
      public string eventName;
      public string adapterClassName;
      public bool canRun;
    }

    private class AdapterRunData 
    {
      public int eventId;
      public int parentRunId;
      public int childRunId;
    }

    private class AccountLineParser 
    {
      public ArrayList ParseLine(string line)
      {
        string trimmedLine = line.Trim();

        ArrayList accounts = null;

        if (parser1.Match(trimmedLine)) 
        {
          accounts = parser1.Parse(trimmedLine);
        }
        else if (parser2.Match(trimmedLine)) 
        {
          accounts = parser2.Parse(trimmedLine);
        }
        else if (parser3.Match(trimmedLine)) 
        {
          accounts = parser3.Parse(trimmedLine);
        }
        else 
        {
          throw new UsageServerException
            (String.Format("Unable to parse account: '{0}'", trimmedLine), false);
        }

        return accounts;
      }

      // The parser classes
      private SpaceAndCommaSeparatedAccountParser parser1 = 
        new SpaceAndCommaSeparatedAccountParser();
      private EndOfLineWithBracketAccountParser parser2 = 
        new EndOfLineWithBracketAccountParser();
      private UserNameCommaNamespaceAccountParser parser3 = 
        new UserNameCommaNamespaceAccountParser();
    }

    interface IAccountParser 
    {
      bool Match(string line);
      ArrayList Parse(string line);
    }

    private class SpaceAndCommaSeparatedAccountParser : IAccountParser
    {
      public bool Match(string line) 
      {
        return integersWithSpacesAndCommas.Match(line).Success;
      }

      public ArrayList Parse(string line)
      {
        ArrayList accountList = new ArrayList();
        line = line.Replace(",", " ");
        string[] accounts = line.Split(' ');
        foreach(string account in accounts) 
        {
          if (account.Length > 0) 
          {
            accountList.Add(Int32.Parse(account));
          }
        }

        return accountList;
      }

      private Regex integersWithSpacesAndCommas = new Regex("^[\\s*,\\d\\s+]+$");
    }

    private class EndOfLineWithBracketAccountParser : IAccountParser
    {
      public bool Match(string line) 
      {
        return positiveIntegerWithBracketsRegex.Match(line).Success;
      }

      public ArrayList Parse(string line)
      {
        ArrayList accountList = new ArrayList();
        
        Match match = positiveIntegerWithBracketsRegex.Match(line);
        if (match.Success) 
        {
          accountList.Add(Int32.Parse(match.Groups["accountId"].ToString()));
        }

        return accountList;
      }

      private Regex positiveIntegerWithBracketsRegex = 
        new Regex("\\((?<accountId>\\d+)\\)$");
    }

    /// <summary>
    ///    Matches username,namespace 
    /// </summary>
    private class UserNameCommaNamespaceAccountParser : IAccountParser
    {
      public bool Match(string line) 
      {
        string username;
        string nmspace;

        return GetUserNameAndNameSpace(line, out username, out nmspace);
      }

      public ArrayList Parse(string line)
      {
        ArrayList accountList = new ArrayList();
        
        string username;
        string nmspace;

        GetUserNameAndNameSpace(line, out username, out nmspace);
        accountList.Add(GetAccountId(username, nmspace));

        return accountList;
      }

      /// <summary>
      ///    If the line is of the form username\namespace then
      ///    retrieve the username and namespace and return true.
      ///    Otherwise return false.
      /// </summary>
      /// <param name="line"></param>
      /// <param name="username"></param>
      /// <param name="nmspace"></param>
      /// <returns></returns>
      private bool GetUserNameAndNameSpace(string line, 
                                           out string username,
                                           out string nmspace) 
      {
        username = String.Empty;
        nmspace = String.Empty;

        // split on '\'
        string[] parts1 = line.Split('\\');
        
        // expect exactly two parts (username and namespace)
        if (parts1.Length != 2) 
        {
          // try splitting on '/'
          string[] parts2 = line.Split('/');
          if (parts2.Length != 2) 
          {
            return false;
          }
          else 
          {
            username = parts2[0];
            nmspace = parts2[1];
          }
        }
        else 
        {
          username = parts1[0];
          nmspace = parts1[1];
        }

        return true;
      }

      /// <summary>
      ///   Get the account id for the given username and namespace. 
      ///   Return Int32.MinValue if the account is not found.
      /// </summary>
      /// <param name="username"></param>
      /// <param name="nmspace"></param>
      /// <returns></returns>
      private int GetAccountId(string username, string nmspace) 
      {
        int accountId = Int32.MinValue;

        using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mUsageServerQueryPath, "__GET_ACCOUNT_ID_USG__"))
            {
                stmt.AddParam("%%USERNAME%%", username, true);
                stmt.AddParam("%%NAMESPACE%%", nmspace, true);

                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        accountId = reader.GetInt32("id_acc");
                        break;
                    }
                }
            }
        }
        
        return accountId;
      }
    }

      /// <summary>
      /// Doubles single quotes in a value to use it in SQL statement.
      /// </summary>
      /// <param name="value"></param>
      /// <returns></returns>
      private static string EncodeValue(string value)
      {
          return !string.IsNullOrEmpty(value) ? value.Replace("'", "''") : value;
      }

    #endregion

    #region Data
    private Logger mLogger;
		private string defaultAssignmentQuery;
    private string defaultDescriptionQuery;
    private string adapterInstancesWithBillingGroupConstraints;
    private string adapterInstancesWithCustomReverse;

    private const string mConfigFile = UsageServerCommon.UsageServerConfigFile;
    private const string mUsageServerQueryPath = @"Queries\UsageServer";
    private const string mBillingRerunAccountsTableName = @"tmp_billing_rerun_accounts";
  
    // Errors returned by the CompleteMaterialization stored proc   
    private enum CompleteMaterializationMsg
    {
      Success = 0,
      Failed = -1,
      EmptyBillingGroup = -2,
      ErrorWithRefreshBillingGroupConstraints = -3,
      ErrorWithCleanup = -4
    }

    // Errors returned by the CompleteReMaterialization stored proc   
    private enum CompleteReMaterializationMsg 
    {
      Success = 0,
      Failed = -1,
      EmptyBillingGroup = -2,
      ErrorWithRefreshBillingGroupConstraints = -3,
      ErrorWithCleanup = -4
    }

    // Errors returned by the ValidateBillGroupAssignments stored proc
    private enum ValidateBillGroupAssignmentsMsg 
    {
      Success = 0,
      UnknownError = -1,
      DuplicateAccountsInBillgroupSourceAcc = -2,
      DuplicateAccountsInBillgroupMemberTmp = -3,
      MissingAccounts = -4,
      EmptyBillingGroup = -5,
      DuplicateBillingGroupNamesInBillGroupTmp = -6
    }

    // Errors returned by the CreateBillGroupMaterialization stored proc
    private enum CreateBillGroupMaterializationMsg
    {
      Success = 0,
      UnknownError = -1,
      ErrorWithCleanup = -2,
      IntervalHardClosed = -3,
      NoPayingAccounts = -4,
      IntervalOnlyAdapterExecution = -5,
      AdapterProcessing = -6,
      RepeatFullMaterialization = -7,
      MaterializationInProgress = -8
    }

    // Errors returned by the SoftCloseBillingGroups stored proc
    private enum SoftCloseBillingGroupsMsg
    {
      Success = 0,
      UnknownError = -1,
      IntervalAndBillingGroup = -2
    }

    // Errors returned by the OpenBillingGroup stored proc
    private enum OpenBillingGroupMsg
    {
      Success = 0,
      UnknownError = -1,
      UnknownBillGroup = -2,
      BillGroupNotSoftClosed = -3,
      StartRootNotFound = -4,
      DependentInstancesNotReversed = -5,
      UnableToUpdateBillGroupStatus = -6
    }

    // Errors returned by the HardCloseBillingGroup stored proc
    private enum HardCloseBillingGroupMsg
    {
      Success = 0,
      UnknownError = -1,
      UnknownBillGroup = -2,
      BillGroupHardClosed = -3,
      NonHardClosedUnassignedAccounts = -4,
      UnableToUpdateBillGroupStatus = -5
    }

    // Errors returned by the HardCloseIntervalMsg stored proc
    private enum HardCloseIntervalMsg
    {
      Success = 0,
      UnknownError = -1,
      OpenPayerAccounts = -2
    }

    // Errors returned by the StartChildGroupCreation stored proc
    private enum StartChildGroupCreationMsg
    {
      Success = 0,
      UnknownError = -1,
      NoAccounts = -2,
      DuplicateAccounts = -3,
      NonParentBillingGroupMember = -4,
      AllBillingGroupMembers = -5
    }

    // Errors returned by the CopyAdapterInstances stored proc
    private enum CopyAdapterInstancesMsg
    {
      Success = 0,
      UnknownError = -1,
      NullParentBillingGroup = -2,
      NonPullList = -3,
      NotInProgress = -4,
      NoBillingGroupIdInTmp = -5,
      NoInstancesToCopy = -6
    }

    // Errors returned by the CompleteChildGroupCreation stored proc
    private enum CompleteChildGroupCreationMsg
    {
      Success = 0,
      UnknownError = -1,
      NullParentBillingGroup = -2
    }

    // Errors returned by the CleanupMaterialization stored proc
    private enum CleanupMaterializationMsg
    {
      Success = 0,
      UnknownError = -1
    }
  
    // Errors returned by the StartChildGroupCreation stored proc
    private enum StartUserDefinedGroupCreationMsg
    {
      Success = 0,
      UnknownError = -1,
      NoFullMaterialization = -2,
      IntervalOnlyAdapterExecution = -3,
      NoUnassignedAccounts = -4,
      NoAccountsPassedIn = -5,
      DuplicateAccounts = -6,
      NonUnassignedAccountsPassedIn = -7,
      DuplicateBillingGroupName = -8
    }

    // Errors returned by the UpdateUnassignedAccounts stored proc
    private enum UpdateUnassignedAccountsMsg
    {
      Success = 0,
      UnknownError = -1,
      NoAccountsInAccountArray = -2,
      DuplicateAccountsInAccountArray = -3,
      AccountsAreNotUnassignedAccounts = -4,
      AccountsAlreadyInStateSpecified = -5
    }

    // Errors returned by the PopulateTempAccountsTable stored proc
    private enum PopulateTempAccountsTableMsg
    {
      Success = 0,
      UnknownError = -1
    }

    // Errors returned by the CompleteBillingGroupConstraints stored proc 
    private enum CompleteBillingGroupConstraintsMsg
    {
      Success = 0,
      UnknownError = -1,
      NonPayerAccounts = -2,
      IncorrectConstraintGroupId = -3,
      DuplicateAccountsInConstraintGroups = -4
    }

    private enum SatisfyConstraintsForPullListMsg
    {
      Success = 0,
      UnknownError = -1,
      NonParentBillingGroupMember = -2,
      NullParentBillingGroup = -3
    }

    private enum AdapterExecution 
    {
      HasNotRun = -1
    }
    
    private string defaultBillingGroupName;

    private Regex newLineRegex = new Regex("\\r\\n");
    private Regex blankLineRegex = new Regex("^\\s*$");
    private bool isOracle = new ConnectionInfo("NetMeter").IsOracle;
    
    #endregion

  }
}
