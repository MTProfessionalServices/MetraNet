using System;
using System.Collections.Generic;
using System.Globalization;
using System.Transactions;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.QueryAdapter;
using Auth = MetraTech.Interop.MTAuth;

namespace MetraTech.Approvals
{
  public class ApprovalManagementImplementation
  {
    protected ApprovalsConfiguration Configuration;
    Auditor approvalAuditor = new Auditor();
    private static Logger mLogger = new Logger("[ApprovalImplementation]");
    private int intUniqueItemId;
    const string APPROVALSMANAGEMENT_QUERY_FOLDER = "Queries\\ApprovalFramework";
    private const string CAPABILITYNAME_VIEW = "Allow ApprovalsView";

    public ApprovalManagementImplementation(ApprovalsConfiguration configuration, Auth.IMTSessionContext sessionContext)
    {
      Configuration = configuration;
      SessionContext = sessionContext;
    }

    public ApprovalManagementImplementation(ApprovalsConfiguration configuration)
    {
      Configuration = configuration;
    }

    public ApprovalManagementImplementation()
    {
      Configuration = ApprovalsConfigurationManager.Load();
    }

    #region Repository

    /// <summary>
    /// Internal method for updating the change state in the repository.
    /// </summary>
    /// <param name="changeId">id of the change to be updated</param>
    /// <param name="newState">new state of the change</param>
    /// <param name="currentState">current state of the change for confirmation; if the currentState does not match what is in the repository, it is assumed that
    /// there is contention (something else modified the state between when we read the change and are now updating it) and an error is thrown.</param>
    protected ChangeState UpdateChangeState(int changeId, ChangeState newState, ChangeState? currentState)
    {
      int status = 0;

      //Approval Framework Required Capability Check for the account

      Change change = GetChangeById(changeId);

      VerifyUserHasPermissionToWorkWithThisChangeType(change.ChangeType);

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("ApprovalUpdateChangeState"))
          {
            stmt.AddParam("id_approval", MTParameterType.Integer, changeId);
            stmt.AddParam("newState", MTParameterType.String, newState.ToString());
            if (currentState == null)
              stmt.AddParam("expectedPreviousState", MTParameterType.String, null);
            else
              stmt.AddParam("expectedPreviousState", MTParameterType.String, currentState.ToString());

            stmt.AddParam("changeModificationDate", MTParameterType.DateTime, MetraTime.Now);
            stmt.AddOutputParam("status", MTParameterType.Integer);

            stmt.ExecuteNonQuery();

            status = (int)stmt.GetOutputValue("status");
          }
        }

        switch (status)
        {
          case 0:
            {
              mLogger.LogDebug("Updated state of change id {0} from {1} to {2}", changeId, currentState, newState);
              break;
            }
          case -1:
            {
              throw new Exception("Invalid change id");
            }
          case -2:
            {
              throw new Exception("The current state of the change does not match what was expected for the previous state. Change was updated.");
            }
          case -3:
            {
              throw new Exception("Invalid state change");
            }
          default:
            {
              throw new Exception(string.Format("Unknown error result {0} returned from ApprovalUpdateChangeState",
                                                status));
            }
        }

      }
      catch (Exception ex)
      {
        string msg = string.Format("Unable to update state of change id {0} from {1} to {2}: {3}", changeId,
                                   currentState, newState, ex.Message);
        mLogger.LogWarning(msg);
        throw new MASBasicException(msg);
      }

      return newState; //Not critical to return the state that was passed in but can use it to set/update a change object we already hold
    }

    /// <summary>
    /// Maps the change object property names to database column names.
    /// </summary>
    /// <param name="propName">Name of the prop.</param>
    /// <param name="filterVal">The filter val.</param>
    /// <param name="helper">The helper.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    protected string MapChangeObjectPropertyNamesToDatabaseColumnNames(string propName, ref object filterVal, object helper)
    {
      //SELECT id_approval, c_SubmittedDate, c_SubmitterId, c_ChangeType, c_ChangeDetails, c_ApproverId, c_ChangeModificationDate, c_ItemDisplayName, c_Comment, c_CurrentState
      //          FROM  t_approvals
      //          WHERE c_CurrentState = ''PENDING''

      switch (propName)
      {
        case "Id":
          return "id_approval";

        case "UniqueItemId":
          return "c_UniqueItemId";

        case "CurrentState":
          return "c_CurrentState";

        case "SubmittedDate":
          return "c_SubmittedDate";

        case "SubmitterId":
          return "c_SubmitterId";

        case "ChangeType":
          return "c_ChangeType";

        case "ChangeDetails":
          return "c_ChangeDetails";

        case "ApproverId":
          return "c_ApproverId";

        case "ChangeLastModifiedDate":
          return "c_ChangeLastModifiedDate";

        case "ItemDisplayName":
          return "c_ItemDisplayName";

        case "SubmitterDisplayName":
          return "SubmitterDisplayName";

        case "ApproverDisplayName":
          return "ApproverDisplayName";

        case "Comment":
          return "c_Comment";

        default:
          throw new MASBasicException("Specified field " + propName + " not not valid for filtering or sorting");
      };
    }

    /// <summary>
    /// Maps the change history object property names to database column names.
    /// </summary>
    /// <param name="propName">Name of the prop.</param>
    /// <param name="filterVal">The filter val.</param>
    /// <param name="helper">The helper.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    protected string MapChangeHistoryObjectPropertyNamesToDatabaseColumnNames(string propName, ref object filterVal, object helper)
    {
      switch (propName)
      {
        case "Id":
          return "UniqueId";

        case "User":
          return "UserId";

        case "UserDisplayName":
          return "UserDisplayName";

        case "Date":
          return "CreateDate";

        case "Event":
          return "EventId";

        case "EventDisplayName":
          return "EventDisplayName";

        case "Details":
          return "Details";

        default:
          throw new MASBasicException("Specified field " + propName + " not valid for filtering or sorting");
      };
    }

    /// <summary>
    /// Populates the change summary from reader.
    /// </summary>
    /// <param name="rdr">The Reader object</param>
    /// <param name="change">The ChangeSummary object.</param>
    /// <remarks></remarks>
    protected void PopulateChangeSummaryFromReader(IMTDataReader rdr, ref ChangeSummary change)
    {
      change.Id = rdr.GetInt32("id_approval");
      change.SubmittedDate = rdr.GetDateTime("c_SubmittedDate");
      change.SubmitterId = rdr.GetInt32("c_SubmitterId");
      change.SubmitterDisplayName = rdr.GetString("SubmitterDisplayName");
      change.ChangeType = rdr.GetString("c_ChangeType");
      change.ChangeTypeDisplayName = rdr.IsDBNull("ChangeTypeDisplayName") ? String.Empty : rdr.GetString("ChangeTypeDisplayName");
      change.ApproverId = rdr.IsDBNull("c_ApproverId") ? -1 : rdr.GetInt32("c_ApproverId");
      change.ApproverDisplayName = rdr.IsDBNull("ApproverDisplayName") ? String.Empty : rdr.GetString("ApproverDisplayName");
      change.ChangeLastModifiedDate = rdr.IsDBNull("c_ChangeLastModifiedDate") ? DateTime.MinValue : rdr.GetDateTime("c_ChangeLastModifiedDate");
      change.ItemDisplayName = rdr.IsDBNull("c_ItemDisplayName") ? "" : rdr.GetString("c_ItemDisplayName");
      change.UniqueItemId = rdr.IsDBNull("c_UniqueItemId") ? String.Empty : rdr.GetString("c_UniqueItemId");
      change.Comment = rdr.IsDBNull("c_Comment") ? String.Empty : rdr.GetString("c_Comment");

      try
      {
        change.CurrentState =
            (MetraTech.DomainModel.BaseTypes.ChangeState)
            Enum.Parse(typeof(MetraTech.DomainModel.BaseTypes.ChangeState),
                       rdr.GetString(rdr.GetOrdinal("c_CurrentState")));
        change.CurrentStateDisplayName =
            rdr.IsDBNull(rdr.GetOrdinal("CurrentStateDisplayName"))
                ? String.Empty
                : rdr.GetString(rdr.GetOrdinal("CurrentStateDisplayName"));
      }
      catch (Exception)
      {
        throw new MASBasicException(string.Format("Change with id {0} has invalid state of '{1}' in the database",
                                                          change.Id, rdr.GetString(rdr.GetOrdinal("c_CurrentState"))));
      }

      return;
    }

    /// <summary>
    /// Populates the change from reader.
    /// </summary>
    /// <param name="rdr">The Reader object.</param>
    /// <param name="change">The Change object.</param>
    /// <remarks></remarks>
    protected void PopulateChangeFromReader(IMTDataReader rdr, ref Change change)
    {
      ChangeSummary changeSummaryTest = change as ChangeSummary;
      PopulateChangeSummaryFromReader(rdr, ref changeSummaryTest);

      byte[] changeDetails = rdr.GetBytes("c_ChangeDetails");
      System.Text.Encoding enc = System.Text.Encoding.ASCII;
      change.ChangeDetailsBlob = ((changeDetails == null) ? String.Empty : enc.GetString(changeDetails));
    }

    /// <summary>
    /// Populates the change summary from reader.
    /// </summary>
    /// <param name="rdr">The Reader object</param>
    /// <param name="changeHistoryItem">The ChangeHistoryItem to populate</param>
    /// <remarks></remarks>
    protected void PopulateChangeHistoryItemFromReader(IMTDataReader rdr, ref ChangeHistoryItem changeHistoryItem)
    {
      changeHistoryItem.Id = rdr.GetInt32("UniqueId");
      changeHistoryItem.User = rdr.GetInt32("UserId");
      changeHistoryItem.UserDisplayName = rdr.GetString("UserDisplayName");
      changeHistoryItem.Date = rdr.IsDBNull("CreateDate") ? DateTime.MinValue : rdr.GetDateTime("CreateDate");
      changeHistoryItem.Event = rdr.GetInt32("EventId");
      changeHistoryItem.EventDisplayName = rdr.IsDBNull("EventDisplayName") ? "" : rdr.GetString("EventDisplayName");
      changeHistoryItem.Details = rdr.IsDBNull("Details") ? "" : rdr.GetString("Details");

      return;
    }

    //public void GetChangeByIdDetails(int changeId, ref MTList<Change> changedetails )
    /// <summary>
    /// Gets the change by id.
    /// </summary>
    /// <param name="changeId">The change id.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    protected Change GetChangeById(int changeId)
    {
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        {
          Change change = new Change();

          // TODO : Fix this, language needs to be pulled in programatically
          LanguageCode mtLanguageCode = LanguageCode.US;
          string locale = "en-US";

          try
          {
            CultureInfo cultureInfo = new CultureInfo(locale);
            mtLanguageCode = ConvertCultureToMetraTechLanguageCode(cultureInfo);
          }
          catch (Exception)
          {
            mLogger.LogWarning("GetChangeById : Unable to convert '{0}' to MetraTech Language Code: Defaulting to '{1}'",
                locale, mtLanguageCode.ToString());
          }

          using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(APPROVALSMANAGEMENT_QUERY_FOLDER, "__GET_CHANGE_BY_ID__"))
          {
            stmt.AddParam("%%id_languagecode%%", mtLanguageCode.ToString().ToLower(), true);
            stmt.AddParam("%%ID_APPROVAL%%", changeId);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              if (stmt.TotalRows == 0)
                throw new MASBasicException("Unable to find change with id " + changeId + " in database.");
              else if (stmt.TotalRows > 1)
                throw new MASBasicException("Database inconsistency as there is more than one change with the id " + changeId + " in database.");

              rdr.Read();
              PopulateChangeFromReader(rdr, ref change);
            }

            return change;
          }
        }
      }
      catch (MASBasicException masE)
      {
        mLogger.LogException("GetChangeById failed..", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("GetChangeById failed..", e);
        throw new MASBasicException("GetChangeById failed..");
      }
    }
    #endregion

    public Auth.IMTSessionContext SessionContext
    {
      get;
      set;
    }

    #region Authorization
    protected bool UserHasRequiredCapability(string requiredCapabilityName)
    {
      IMTSecurity security = new MTSecurity();
      IMTCompositeCapability requiredCapability = security.GetCapabilityTypeByName(requiredCapabilityName).CreateInstance();
      return SessionContext.SecurityContext.CoarseHasAccess(requiredCapability);
    }


    protected void VerifyUserHasPermissionToViewApprovalInformation()
    {
      VerifySessionContextIsSet();

      if (!UserHasRequiredCapability(CAPABILITYNAME_VIEW))
        throw new MASBasicException("The user does not have the capability required to do this operation");
    }

    protected void VerifyUserHasPermissionToWorkWithThisChangeType(string changeType)
    {
      VerifySessionContextIsSet();

      ChangeTypeConfiguration config = Configuration.GetChangeTypeConfiguration(changeType);

      if (!UserHasRequiredCapability(config.CapabilityRequiredForApproveOrDeny))
        throw new MASBasicException("The user does not have the capability required to do this operation");

    }

    protected void VerifyUserHasPermissionToWorkWithThisChangeTypeOrUserIsSubmitterOfTheChange(Change change)
    {
      VerifySessionContextIsSet();

      if (change.SubmitterId == SessionContext.AccountID)
        return;
      else
        VerifyUserHasPermissionToWorkWithThisChangeType(change.ChangeType);
    }

    protected bool IsUserSubmitterOfTheChange(Change change)
    {
      return (change.SubmitterId == SessionContext.AccountID);
    }

    protected void VerifySessionContextIsSet()
    {
      if (SessionContext == null)
      {
        throw new Exception("SessionContext must be set. Unable to authorize user.");
      }
    }
    #endregion

    protected void VerifyChangeCurrentStateIs(ChangeState requiredState, Change change)
    {
      if (change.CurrentState != requiredState)
        throw new MASBasicException(string.Format("Change {0} must be in the state of {1} but is currently {2}", change.Id, requiredState, change.CurrentState));
    }

    /// <summary>
    /// Get a list of changes in the approval system. These can include pending and non-pending changes.
    /// </summary>
    /// <param name="changes">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    public void GetChangesSummary(ref MTList<ChangeSummary> changes)
    {
      GetChangesSummary(ref changes, "en-US");
    }

    /// <summary>
    /// Get a list of changes in the approval system. These can include pending and non-pending changes.
    /// </summary>
    /// <param name="changes">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    /// <param name="locale">string corresponding to valid CultureInfo to be used as language for returned values (Example: 'en-US', 'de', 'de-DE')</param>
    public void GetChangesSummary(ref MTList<ChangeSummary> changes, string locale)
    {
      VerifyUserHasPermissionToViewApprovalInformation();

      changes.Items.Clear();

      LanguageCode mtLanguageCode = LanguageCode.US;
      try
      {
        CultureInfo cultureInfo = new CultureInfo(locale);
        mtLanguageCode = ConvertCultureToMetraTechLanguageCode(cultureInfo);
      }
      catch (Exception)
      {
        mLogger.LogWarning("GetChangesSummary: Unable to convert '{0}' to MetraTech Language Code: Defaulting to '{1}'", locale, mtLanguageCode.ToString());
      }

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        {
          using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(APPROVALSMANAGEMENT_QUERY_FOLDER, "__SHOW_ALL_APPROVALS__"))
          {
            stmt.AddParam("%%id_languagecode%%", mtLanguageCode.ToString().ToLower(), true);

            MTListFilterSort.ApplyFilterSortCriteria<ChangeSummary>(stmt, changes, MapChangeObjectPropertyNamesToDatabaseColumnNames, null);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                MetraTech.DomainModel.BaseTypes.ChangeSummary change = new ChangeSummary();
                PopulateChangeSummaryFromReader(rdr, ref change);
                changes.Items.Add(change);
              }
            }

            changes.TotalRows = stmt.TotalRows;
          }
        }
      }
      catch (MASBasicException masE)
      {
        mLogger.LogException("GetChangesSummary failed:", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("GetChangesSummary failed..", e);
        throw new MASBasicException("GetChangesSummary:" + e.Message);
      }
    }

    /// <summary>
    /// Get a list of pending changes in the approval system.
    /// Note: This is equivalent to GetChangesSummary with filter set to State=Pending
    /// </summary>
    /// <param name="changes">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    public void GetPendingChangesSummary(ref MTList<ChangeSummary> changes)
    {
      GetPendingChangesSummary(ref changes, "en-US");
    }

    /// <summary>
    /// Get a list of pending changes in the approval system.
    /// Note: This is equivalent to GetChangesSummary with filter set to State=Pending
    /// </summary>
    /// <param name="changes">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    /// <param name="locale">string corresponding to valid CultureInfo to be used as language for returned values (Example: 'en-US', 'de', 'de-DE')</param>
    public void GetPendingChangesSummary(ref MTList<ChangeSummary> changes, string locale)
    {
      VerifyUserHasPermissionToViewApprovalInformation();

      changes.Items.Clear();

      LanguageCode mtLanguageCode = LanguageCode.US;
      try
      {
        CultureInfo cultureInfo = new CultureInfo(locale);
        mtLanguageCode = ConvertCultureToMetraTechLanguageCode(cultureInfo);
      }
      catch (Exception)
      {
        mLogger.LogWarning("GetChangesSummary: Unable to convert '{0}' to MetraTech Language Code: Defaulting to '{1}'", locale, mtLanguageCode.ToString());
      }

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        {
          using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(APPROVALSMANAGEMENT_QUERY_FOLDER, "__SHOW_ALL_APPROVALS__"))
          {
            stmt.AddParam("%%id_languagecode%%", mtLanguageCode.ToString().ToLower(), true);

            MTListFilterSort.ApplyFilterSortCriteria<ChangeSummary>(stmt, changes, MapChangeObjectPropertyNamesToDatabaseColumnNames, null);

            #region Apply Filters

            FilterElement fe = new FilterElement("c_CurrentState", FilterElement.OperationType.Equal, "Pending");

            stmt.AddFilter(fe);

            #endregion

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                ChangeSummary change = new ChangeSummary();
                PopulateChangeSummaryFromReader(rdr, ref change);
                changes.Items.Add(change);
              }
            }

            changes.TotalRows = stmt.TotalRows;

          }
        }


      }

      catch (MASBasicException masE)
      {
        mLogger.LogException("Selecting All Approvals failed..", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("Selecting All Approvals failed..", e);

        throw new MASBasicException("Selecting All Approvals failed..");
      }
    }


    /// <summary>
    /// Get a list of pending changes in the approval system.
    /// Note: This is equivalent to GetChangesSummary with filter set to State=FailedToApply
    /// </summary>
    /// <param name="changes">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    public void GetFailedChangesSummary(ref MTList<ChangeSummary> changes)
    {
      GetFailedChangesSummary(ref changes, "en-US");
    }

    /// <summary>
    /// Get a list of pending changes in the approval system.
    /// Note: This is equivalent to GetChangesSummary with filter set to State=Pending
    /// </summary>
    /// <param name="changes">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    /// <param name="locale">string corresponding to valid CultureInfo to be used as language for returned values (Example: 'en-US', 'de', 'de-DE')</param>
    public void GetFailedChangesSummary(ref MTList<ChangeSummary> changes, string locale)
    {
      VerifyUserHasPermissionToViewApprovalInformation();

      changes.Items.Clear();

      LanguageCode mtLanguageCode = LanguageCode.US;
      try
      {
        CultureInfo cultureInfo = new CultureInfo(locale);
        mtLanguageCode = ConvertCultureToMetraTechLanguageCode(cultureInfo);
      }
      catch (Exception)
      {
        mLogger.LogWarning("GetChangesSummary: Unable to convert '{0}' to MetraTech Language Code: Defaulting to '{1}'", locale, mtLanguageCode.ToString());
      }

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        {
          using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(APPROVALSMANAGEMENT_QUERY_FOLDER, "__SHOW_ALL_APPROVALS__"))
          {
            stmt.AddParam("%%id_languagecode%%", mtLanguageCode.ToString().ToLower(), true);

            MTListFilterSort.ApplyFilterSortCriteria<ChangeSummary>(stmt, changes, MapChangeObjectPropertyNamesToDatabaseColumnNames, null);

            #region Apply Filters

            FilterElement fe = new FilterElement("c_CurrentState", FilterElement.OperationType.Equal, "FailedToApply");

            stmt.AddFilter(fe);

            #endregion

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                ChangeSummary change = new ChangeSummary();
                PopulateChangeSummaryFromReader(rdr, ref change);
                changes.Items.Add(change);
              }
            }

            changes.TotalRows = stmt.TotalRows;

          }
        }


      }

      catch (MASBasicException masE)
      {
        mLogger.LogException("Selecting Failed Approvals failed..", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("Selecting Failed Approvals failed..", e);

        throw new MASBasicException("Selecting Failed Approvals failed..");
      }
    }


    /// <summary>
    /// Return the custom change details for a particular change.
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="changeDetailsPayload">The string that is populated with the change details.</param>
    public void GetChangeDetails(int changeId, out string changeDetailsPayload)
    {
      VerifyUserHasPermissionToViewApprovalInformation();

      Change change = GetChangeById(changeId);

      if (change == null)
        throw new ArgumentOutOfRangeException("ChangeId", "No change found with id of " + changeId);

      //Return the change details
      changeDetailsPayload = change.ChangeDetailsBlob;

      return;
    }


    /// <summary>
    /// Updates the change details for a given pending change. Useful when editing is allowed and the details of the change need
    /// to be modified.
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="changeDetailsPayload">The string containing the updated change details.</param>
    /// <param name="comment">The string containing the comment.</param>
    public void UpdateChangeDetail(int changeId, string changeDetailsPayload, string comment)
    {
      //string changedStateMessage = "";

      Change change = GetChangeById(changeId);

      VerifyUserHasPermissionToWorkWithThisChangeType(change.ChangeType);

      if (!IsUserSubmitterOfTheChange(change))
        throw new Exception("Only submitter of the change can update the change details");

      //If the details were edited/updated on a change that was failed, then the state reverts to pending
      if (change.CurrentState == ChangeState.FailedToApply)
      {
        //Change state from Failed to Pending as the updated change details need to be re-approved
        change.CurrentState = UpdateChangeState(changeId, ChangeState.Pending, change.CurrentState);
        //changedStateMessage = ": The change was marked as 'Pending' as the new updated details must be approved again.";
      }

      VerifyChangeCurrentStateIs(ChangeState.Pending, change);

      //Update the change details

      //Update change state to Denied in the database
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpdateChangeDetails"))
          {
            stmt.AddParam("@id_approval", MTParameterType.Integer, changeId);
            System.Text.UTF8Encoding encoding = new System.Text.UTF8Encoding();
            stmt.AddParam("@ChangeDetails", MTParameterType.Blob, encoding.GetBytes(changeDetailsPayload));
            stmt.AddParam("@ChangeModificationDate", MTParameterType.DateTime, MetraTime.Now);
            stmt.AddParam("@Comment", MTParameterType.String, comment);

            //Output Parameters from the Stored Proc
            stmt.AddOutputParam("@Status", MTParameterType.Integer);

            mLogger.LogDebug("Executing stored procedure UpdateChangeDetails for change ({0}) to update the change details", changeId);
            stmt.ExecuteNonQuery();

            int status = (int)stmt.GetOutputValue("@Status");

            if (status == -1)
            {
              throw new MASBasicException(string.Format("Update Change Details failed for this change id {0} ", changeId));
            }
          }
        }
      }
      catch (MASBasicException masE)
      {
        mLogger.LogException("Update Change Details failed", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("Update Change Details failed", e);

        throw new MASBasicException("Update Change Details failed");
      }

      //Log the audit event upon successful addition of change item 
      int.TryParse(change.UniqueItemId, out intUniqueItemId);

      approvalAuditor.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_APPROVALMANAGEMENT_CHANGEDETAILSUPDATED, this.SessionContext.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_APPROVAL, changeId,
                                (string.IsNullOrEmpty(comment) ? "" : String.Format("Comment[{0}]", comment)));
      return;
    }

    /// <summary>
    /// Called to approve a pending change
    /// </summary>
    /// <param name="changeId">id of the change within the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="comment">Optional comment for additional approval information; most likely only useful when change is approved by an automated process or outside system</param>
    public void ApproveChange(int changeId, string comment)
    {
      Change change = GetChangeById(changeId);

      VerifyUserHasPermissionToWorkWithThisChangeType(change.ChangeType);

      if (IsUserSubmitterOfTheChange(change))
        throw new Exception("Approver cannot be the submitter of the change");

      VerifyChangeCurrentStateIs(ChangeState.Pending, change);

      change.CurrentState = UpdateChangeState(changeId, ChangeState.ApprovedWaitingToBeApplied, change.CurrentState);

      approvalAuditor.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_APPROVALMANAGEMENT_CHANGEAPPROVED, this.SessionContext.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_APPROVAL, changeId,
                          (string.IsNullOrEmpty(comment) ? "" : String.Format("Comment[{0}]", comment)));

      QueueChangeToBeApplied(change);
    }

    /// <summary>
    /// Queues the change to be applied.
    /// </summary>
    /// <param name="changeId">The change id.</param>
    /// <remarks></remarks>
    private void QueueChangeToBeApplied(int changeId)
    {
      Change change = GetChangeById(changeId);
      QueueChangeToBeApplied(change);
    }

    /// <summary>
    /// Queues the change to be applied.
    /// </summary>
    /// <param name="change">The change.</param>
    /// <remarks></remarks>
    private void QueueChangeToBeApplied(Change change)
    {
      ApplyApprovedChange(change);
    }

    /// <summary>
    /// Applies the approved change.
    /// </summary>
    /// <param name="change">The change.</param>
    /// <remarks></remarks>
    protected void ApplyApprovedChange(Change change)
    {

      VerifyChangeCurrentStateIs(ChangeState.ApprovedWaitingToBeApplied, change);

      //TODO: Retrieve/generate a session context for the submitter

      //LockThisChange

      try
      {
        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions { IsolationLevel = IsolationLevel.ReadCommitted }, EnterpriseServicesInteropOption.Full))
        {
          change.CurrentState = UpdateChangeState(change.Id, ChangeState.Applied, change.CurrentState);

          CallConfiguredApplyChangeMethod(change);

          scope.Complete();
        }

      }
      catch (MASBasicException basic)
      {
        //There was an error applying the change, set the change state to Failed and record the error details
        change.CurrentState = UpdateChangeState(change.Id, ChangeState.FailedToApply, null);

        approvalAuditor.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_APPROVALMANAGEMENT_CHANGEAPPLYFAILED, this.SessionContext.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_APPROVAL, change.Id,
                                  String.Format("Error[{0}]", basic.Message));

        throw;
      }

      catch (Exception ex)
      {
        //There was an error applying the change, set the change state to Failed and record the error details
        change.CurrentState = UpdateChangeState(change.Id, ChangeState.FailedToApply, null);

        approvalAuditor.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_APPROVALMANAGEMENT_CHANGEAPPLYFAILED, this.SessionContext.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_APPROVAL, change.Id,
                                  String.Format("Error[{0}]", ex.Message));

        throw new MASBasicException(ex.Message, ErrorCodes.APPROVAL_COULD_NOT_APPLY_CHANGE);
      }

      approvalAuditor.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_APPROVALMANAGEMENT_CHANGEAPPLIED, this.SessionContext.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_APPROVAL, change.Id,
                           String.Format("Applied approved change to {0} ({1})", change.ItemDisplayName, change.UniqueItemId));

    }

    /// <summary>
    /// Calls the configured apply change method.
    /// </summary>
    /// <param name="change">The change.</param>
    /// <remarks></remarks>
    protected void CallConfiguredApplyChangeMethod(Change change)
    {
      mLogger.LogDebug("Approvals.CallConfiguredApplyChangeMethod called for {0}:{1}:{2}", change.ChangeType, change.UniqueItemId, change.ItemDisplayName);

      ChangeTypeConfiguration config = Configuration.GetChangeTypeConfiguration(change.ChangeType);

      if (config.MethodForApply == null)
      {
        //Error that apply method is not configured
        throw new MASBasicException(string.Format("Change Type {0} does not have a configured apply method", change.ChangeType));
      }

      //If we are calling assembly then...
      if (!string.IsNullOrEmpty(config.MethodForApply.Assembly))
      {
        IApprovalFrameworkApplyChange customChangeType;
        customChangeType = Reflection.GetInterface<IApprovalFrameworkApplyChange>(config.MethodForApply.Assembly, config.MethodForApply.Classname);

        if (customChangeType == null)
        {
          throw new Exception("The change type {0} has invalid configuration for the MethodForApply: Assembly and Classname");
        }

        //Setup the session context
        Auth.IMTSessionContext sessionContextOfSubmitter = this.SessionContext; //TODO: Punt and use approver context for now

        try
        {
          customChangeType.ApplyChange(change, "", sessionContextOfSubmitter);
        }
        catch (Exception ex)
        {
          throw new Exception("There was an error applying the change", ex);
        }
      }
      else
      {
        //Call web service method that is configured
        Dictionary<string, object> possibleArgumentValues = GetDictionaryOfChangeDetailsFromChange(change);
        Reflection.CallWebServiceClientMethodDynamically(config.MethodForApply, possibleArgumentValues, change.SubmitterId);

      }

    }

    /// <summary>
    /// Gets the dictionary of change details from change.
    /// </summary>
    /// <param name="change">The change.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    protected static Dictionary<string, object> GetDictionaryOfChangeDetailsFromChange(Change change)
    {
      try
      {
        if (string.IsNullOrEmpty(change.ChangeDetailsBlob))
        {
          return new Dictionary<string, object>();
        }
        else
        {
          ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
          //TODO: Make known types configurable so we can expand this easily in the future!
          changeDetails.KnownTypes.AddRange(MetraTech.DomainModel.BaseTypes.Account.KnownTypes());
          changeDetails.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.ProductOffering));
          changeDetails.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember));
          changeDetails.KnownTypes.Add(typeof(List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>));
          changeDetails.KnownTypes.Add(typeof(Dictionary<AccountIdentifier, MetraTech.DomainModel.ProductCatalog.AccountTemplateScope>));
          changeDetails.KnownTypes.Add(typeof(AccountIdentifier));
          changeDetails.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.AccountTemplateScope));
          changeDetails.KnownTypes.Add(typeof(ProdCatTimeSpan));
          changeDetails.FromBuffer(change.ChangeDetailsBlob);
          return changeDetails.ToDictionary();
        }
      }
      catch (Exception ex)
      {
        string msg = "Unable to Deserialize change details:" + ex.Message;
        mLogger.LogError(msg);

        throw new MASBasicException(msg);
      }
    }

    /// <summary>
    /// Calls the configured submit change method.
    /// </summary>
    /// <param name="change">The change.</param>
    /// <param name="changeRequiresApproval">if set to <c>true</c> [change requires approval].</param>
    /// <param name="sessionContextOfSubmitter">The session context of submitter.</param>
    /// <remarks></remarks>
    protected void CallConfiguredSubmitChangeMethod(ref Change change, ref bool changeRequiresApproval, Auth.IMTSessionContext sessionContextOfSubmitter)
    {
      ChangeTypeConfiguration config = this.Configuration[change.ChangeType];

      if ((config == null) || (config.MethodForSubmit == null))
      {
        //Method is not configured, no error, just return
        return;
      }

      //If we are calling assembly then...
      if (!string.IsNullOrEmpty(config.MethodForSubmit.Assembly))
      {
        IApprovalFrameworkSubmitChange customChangeType;
        customChangeType = Reflection.GetInterface<IApprovalFrameworkSubmitChange>(config.MethodForSubmit.Assembly, config.MethodForSubmit.Classname);

        if (customChangeType == null)
        {
          throw new Exception("The change type {0} has invalid configuration for the MethodForSubmit: Assembly and Classname");
        }

        try
        {
          customChangeType.BeforeSubmitChange(ref change, ref changeRequiresApproval, sessionContextOfSubmitter);
        }
        catch (Exception ex)
        {
          throw new Exception("There was an error submitting the change", ex);
        }
      }
      else
      {
        //Call web service method that is configured
        //Insert *Magic* here
      }

    }

    /// <summary>
    /// Called to deny a pending change
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="comment">optional comment describing why the change was denied</param>
    public void DenyChange(int changeId, string comment)
    {
      Change change = GetChangeById(changeId);

      VerifyUserHasPermissionToWorkWithThisChangeType(change.ChangeType);

      //If change is pending, only the submitter can dismiss it
      switch (change.CurrentState)
      {
        case ChangeState.Applied:
        case ChangeState.Dismissed:
          throw new MASBasicException("The change cannot be changed from its current state of " +
                                      change.CurrentState.ToString());
      }

      //Update change state to Denied in the database
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("DenyApproval"))
          {
            stmt.AddParam("@id_approval", MTParameterType.Integer, changeId);
            stmt.AddParam("@Comment", MTParameterType.String, comment);

            //Output Parameters from the Stored Proc
            stmt.AddOutputParam("@Status", MTParameterType.Integer);


            mLogger.LogDebug("Executing stored procedure DenyApproval for change ({0})", changeId);
            stmt.ExecuteNonQuery();

            int status = (int)stmt.GetOutputValue("@Status");

            if (status == -1)
            {
              throw new MASBasicException(string.Format("The Deny Approval failed for this change id {0} ", changeId));
            }

          }
        }

      }

      catch (MASBasicException masE)
      {
        mLogger.LogException("Deny approval failed", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("Deny approval failed", e);

        throw new MASBasicException("Deny approval failed");
      }

      approvalAuditor.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_APPROVALMANAGEMENT_CHANGEDENIED, this.SessionContext.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_APPROVAL, changeId,
      String.Format("Approval denied for the change id {0}, appoval Unique Item Id {1} successfully." + comment, changeId, change.UniqueItemId));

    }

    /// <summary>
    /// Called to remove/delete a pending change. Equivalent to DenyChange but can be called by user who created the change.
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="comment">optional comment describing why the change was removed</param>
    public void DismissChange(int changeId, string comment)
    {
      Change change = GetChangeById(changeId);

      //If change is pending, only the submitter can dismiss it
      switch (change.CurrentState)
      {
        case ChangeState.Pending:
          if (!IsUserSubmitterOfTheChange(change))
            throw new MASBasicException(
              "Pending change can only be dismissed by submitter of the change. Other users should Deny the change.");
          break;

        case ChangeState.Applied:
        case ChangeState.Dismissed:
          throw new MASBasicException("The change cannot be changed from its current state of " +
                                      change.CurrentState.ToString());

      }

      //Update change state to Dismissed in the database
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("DismissApproval"))
          {
            stmt.AddParam("@id_approval", MTParameterType.Integer, changeId);
            stmt.AddParam("@Comment", MTParameterType.String, comment);

            //Output Parameters from the Stored Proc
            stmt.AddOutputParam("@Status", MTParameterType.Integer);


            mLogger.LogDebug("Executing stored procedure DismissApproval for change ({0})", changeId);
            stmt.ExecuteNonQuery();

            int status = (int)stmt.GetOutputValue("@Status");

            if (status == -1)
            {
              throw new MASBasicException(string.Format("DismissApproval failed for this change id {0} ", changeId));
            }

          }
        }

      }

      catch (MASBasicException masE)
      {
        mLogger.LogException("Dismiss approval failed", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("Dismiss approval failed", e);

        throw new MASBasicException("Dismiss approval failed");
      }

      approvalAuditor.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_APPROVALMANAGEMENT_CHANGEDISMISSED,
                                this.SessionContext.AccountID,
                                (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_APPROVAL, changeId,
                                (string.IsNullOrEmpty(comment) ? "" : String.Format("Comment[{0}]", comment)));

    }

    /// <summary>
    /// Gets a history for a particular change
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="changeHistoryItems">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    public void GetChangeHistory(int changeId, ref MTList<ChangeHistoryItem> changeHistoryItems)
    {
      GetChangeHistory(changeId, ref changeHistoryItems, "en-US"); //Default is english but could be Thread.CurrentThread.CurrentUICulture;
    }

    /// <summary>
    /// Gets a history for a particular change
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="changeHistoryItems">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    /// <param name="locale">string corresponding to valid CultureInfo to be used as language for returned values (Example: 'en-US', 'de', 'de-DE')</param>
    public void GetChangeHistory(int changeId, ref MTList<ChangeHistoryItem> changeHistoryItems, string locale)
    {

      VerifyUserHasPermissionToViewApprovalInformation();

      Change change = GetChangeById(changeId);

      LanguageCode mtLanguageCode = LanguageCode.US;
      try
      {
        CultureInfo cultureInfo = new CultureInfo(locale);
        mtLanguageCode = ConvertCultureToMetraTechLanguageCode(cultureInfo);
      }
      catch (Exception)
      {
        mLogger.LogWarning("GetChangeHistory: Unable to convert '{0}' to MetraTech Language Code: Defaulting to '{1}'", locale, mtLanguageCode.ToString());
      }

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        {

          using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(APPROVALSMANAGEMENT_QUERY_FOLDER, "__GET_CHANGE_HISTORY_INFO__"))
          {
            stmt.AddParam("%%id_approval%%", changeId);
            stmt.AddParam("%%id_languagecode%%", mtLanguageCode.ToString().ToLower(), true);

            MTListFilterSort.ApplyFilterSortCriteria<ChangeHistoryItem>(stmt, changeHistoryItems, MapChangeHistoryObjectPropertyNamesToDatabaseColumnNames, null);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                //MetraTech.DomainModel.BaseTypes.ChangeSummary changesummary = new ChangeSummary();
                ChangeHistoryItem changehistoryItem = new ChangeHistoryItem();

                PopulateChangeHistoryItemFromReader(rdr, ref changehistoryItem);

                changeHistoryItems.Items.Add(changehistoryItem);
              }
            }

            changeHistoryItems.TotalRows = stmt.TotalRows;

          }
        }

      }

      catch (MASBasicException masE)
      {
        mLogger.LogException("Selecting Change History failed..", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("Selecting Change History failed..", e);

        throw new MASBasicException("Selecting Change History failed..");
      }
    }

    /// <summary>
    /// Submit a change for approval in the framework.
    /// </summary>
    /// <param name="change">The populated change object being submitted.
    /// Required properties that need to be populated for the chagne are: changeType, uniqueItemId, changeDetailsPayload.
    /// Optional properties that can be populated are: itemDisplayName, comment</param>
    /// <param name="changeId">Populated with the id of the newly created id within the approval framework; returns 0 if the change does not require approval and was applied immediately</param>
    public void SubmitChange(Change change, out int changeId)
    {
      mLogger.LogDebug("Approvals.SubmitChange called for {0}:{1}:{2}", change.ChangeType, change.UniqueItemId, change.ItemDisplayName);

      VerifySessionContextIsSet();

      //Make sure required properties are set
      if (string.IsNullOrEmpty(change.ChangeType))
        throw new Exception("Change Type is required when submitting a change");
      if (string.IsNullOrEmpty(change.UniqueItemId))
        throw new Exception("Item id is required when submitting a change");
      if (string.IsNullOrEmpty(change.ChangeDetailsBlob))
        throw new Exception("Change Details are required when submitting a change");

      //Update the other change properties, we don't accept them from the user even if the user set them
      change.SubmittedDate = MetraTime.Now;
      change.SubmitterId = this.SessionContext.AccountID;
      change.SubmitterDisplayName = ""; //Empty it in case it was set, probably not an issue for the real database
      change.CurrentState = ChangeState.Pending;

      ChangeTypeConfiguration config = Configuration.GetChangeTypeConfiguration(change.ChangeType);

      //If this change type does not allow more than one pending change on an item, check for other pending changes
      //We check this first, even if enabled=false to avoid issues with a pending change existing and then approvals being disabled
      if (!config.AllowMoreThanOnePendingChange)
      {
        bool hasPendingChange = false;
        HasPendingChange(change.ChangeType, change.UniqueItemId.ToString(), out hasPendingChange);
        if (hasPendingChange)
          throw new MASBasicException(string.Format("The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.", change.UniqueItemId, change.ChangeType));
      }

      //Is this change type enabled? Otherwise just apply the change
      bool changeRequiresApproval = true;
      if (!config.Enabled)
      {
        //If not enabled, then we apply the change immediately
        changeRequiresApproval = false;
      }
      else
      {
        changeRequiresApproval = true;

        //Does this change type have a custom handler for submitting?
        if (config.MethodForSubmit != null)
        {
          //Call the configured custom method
          //It may modify the change
          //It may return telling us that this change doesn't need approval (apply it immediately)
          //It may Throw errors to be returned to the caller/submitter

          try
          {
            CallConfiguredSubmitChangeMethod(ref change, ref changeRequiresApproval, this.SessionContext);
          }
          catch (Exception ex)
          {
            mLogger.LogException("Exception when calling CallConfiguredSubmitChangeMethod", ex);
            throw new MASBasicException("Failed to submit change:" + ex.Message);
          }

          if (!changeRequiresApproval)
          {
            mLogger.LogDebug("Configured custom SubmitChange handler determined this change does not require approval.");
          }
        }
      }

      // If approvals is enabled and the custom handler hasn't told us to bypass
      // approvals for this change, then submit it as pending, otherwise apply it immediately
      if (changeRequiresApproval)
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
          {
            using (IMTCallableStatement stmt = conn.CreateCallableStatement("AddApproval"))
            {
              //Input Parameters to the Stored Proc
              stmt.AddParam("@SubmittedDate", MTParameterType.DateTime, change.SubmittedDate);
              stmt.AddParam("@SubmitterId", MTParameterType.Integer, change.SubmitterId);
              stmt.AddParam("@ChangeType", MTParameterType.String, change.ChangeType);
              System.Text.UTF8Encoding encoding = new System.Text.UTF8Encoding();
              stmt.AddParam("@ChangeDetails", MTParameterType.Blob, encoding.GetBytes(change.ChangeDetailsBlob));
              stmt.AddParam("@ItemDisplayName", MTParameterType.String, change.ItemDisplayName);
              stmt.AddParam("@UniqueItemId", MTParameterType.String, change.UniqueItemId);
              stmt.AddParam("@Comment", MTParameterType.String, change.Comment);
              stmt.AddParam("@CurrentState", MTParameterType.String, change.CurrentState);
              stmt.AddParam("@AllowMultiplePendingChangesForThisChangeType", MTParameterType.Integer,
                            config.AllowMoreThanOnePendingChange ? 1 : 0); // Best way to pass a 'bit'?

              //Output Parameters from the Stored Proc
              stmt.AddOutputParam("@IdApproval", MTParameterType.Integer);
              stmt.AddOutputParam("@Status", MTParameterType.Integer);

              mLogger.LogDebug("Executing stored procedure AddApproval to submit change ({0} {1} {2}", change.ChangeType, change.UniqueItemId, change.ItemDisplayName);
              stmt.ExecuteNonQuery();

              int status = (int)stmt.GetOutputValue("@Status");
              changeId = (int)stmt.GetOutputValue("@IdApproval");


              if (status == -1)
              {
                throw new MASBasicException(string.Format("The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.", change.UniqueItemId, change.ChangeType));
              }

              approvalAuditor.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_APPROVALMANAGEMENT_CHANGESUBMITTED, this.SessionContext.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_APPROVAL, changeId,
                                        (string.IsNullOrEmpty(change.Comment) ? "" : String.Format("Comment[{0}]", change.Comment)));


            }

          }

        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Submit change for approval failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Submit change for approval failed", e);

          throw new MASBasicException("Submit change for approval failed");
        }

        ////Log the audit event upon successful addition of change item 
        //int.TryParse(change.UniqueItemId, out intUniqueItemId);

        //approvalauditor.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_APPROVALMANAGEMENT_CHANGESUBMITTED, this.SessionContext.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_APPROVAL, changeId,
        //String.Format("Submitted the change successfully for approval for Unique Item Id {0}  The approval Id assigned to this change is {1}", change.UniqueItemId, changeId));

      }
      else
      {
        changeId = 0;
        CallConfiguredApplyChangeMethod(change);
      }
    }

    /// <summary>
    /// If changes have been approved but failed while being applied, this method is called to re-attempt to apply the approved changes.
    /// </summary>
    /// <param name="changeIds">List of failed change ids to re-attempt to apply</param>
    public void ResubmitFailedChanges(MTList<int> changeIds)
    {
      VerifyUserHasPermissionToViewApprovalInformation();

      var errors = new MASBasicFaultDetail();

      foreach (int changeId in changeIds.Items)
      {
        try
        {
          UpdateChangeState(changeId, ChangeState.ApprovedWaitingToBeApplied, ChangeState.FailedToApply);
          approvalAuditor.FireEvent(
            (int)AuditManager.MTAuditEvents.AUDITEVENT_APPROVALMANAGEMENT_FAILEDCHANGERESUBMITTED,
            this.SessionContext.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_APPROVAL, changeId, "");

          QueueChangeToBeApplied(changeId);

        }
        catch (Exception ex)
        {
          if (errors.ErrorMessages.Count == 0)
          {
            errors.ErrorMessages.Add("Some changes could not be resubmitted");
          }
          
          errors.ErrorMessages.Add("Change Id " + changeId + ":" + ex.Message);
        }
      }

      if (errors.ErrorMessages.Count > 0)
        throw new MASBasicException(errors);
    }


    /// <summary>
    /// Called to determine if a particular item type and item id have a pending change.
    /// </summary>
    /// <param name="changeType">The type of type as specified in the framework and ApprovalConfiguration.xml</param>
    /// <param name="itemId">The unique id of the item of a given type that was passed when the item was submitted</param>
    /// <param name="hasPendingChanges">The result indicating if there are pending changes.</param>
    public bool HasPendingChange(string changeType, string itemId, out bool hasPendingChanges)
    {
      //***May want to consider changing this to a MTList<int> of changeIds
      int status;
      hasPendingChanges = false;

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
        {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("IsApprovalPending"))
          {
            //Input Parameters to the Stored Proc
            stmt.AddParam("@ChangeType", MTParameterType.String, changeType);
            stmt.AddParam("@UniqueItemId", MTParameterType.String, itemId);

            //Output Parameters from the Stored Proc
            stmt.AddOutputParam("@Status", MTParameterType.Integer);

            mLogger.LogDebug("Executing stored procedure IsApprovalPending for change ({0} {1})", changeType, itemId);
            stmt.ExecuteNonQuery();

            status = (int)stmt.GetOutputValue("@Status");
          }

        }

      }

      catch (MASBasicException masE)
      {
        mLogger.LogException("Unable to verify pending approvals for this change", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("Unable to verify pending approvals for this change", e);

        throw new MASBasicException("Unable to verify pending approvals for this change");
      }

      if (status == 1)
      {
        hasPendingChanges = true;
      }

      return hasPendingChanges;
    }

    /// <summary>
    /// Helper method to load a particular query and return the text so it
    /// can be used in a parameterized query
    /// </summary>
    /// <param name="queryTag"></param>
    /// <returns></returns>
    private static string GetQueryText(string queryTag)
    {
      string sql;
      using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
      {
        queryAdapter.Item = new MTQueryAdapterClass();
        queryAdapter.Item.Init(APPROVALSMANAGEMENT_QUERY_FOLDER);
        queryAdapter.Item.SetQueryTag(queryTag);
        sql = queryAdapter.Item.GetQuery();
      }
      return sql;
    }

    /// <summary>
    /// Gets the pending change ids for item.
    /// </summary>
    /// <param name="changeType">Type of the change.</param>
    /// <param name="uniqueItemId">The unique item id.</param>
    /// <param name="pendingChangeIds">The pending change ids.</param>
    /// <remarks></remarks>
    public void GetPendingChangeIdsForItem(string changeType, string uniqueItemId, out List<int> pendingChangeIds)
    {
      pendingChangeIds = new List<int>();
      using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
      {
        using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(GetQueryText("__GET_PENDING_APPROVALS_FOR_ITEM__")))
        {
          prepStmt.AddParam(MTParameterType.String, changeType);
          prepStmt.AddParam(MTParameterType.String, uniqueItemId);

          using (IMTDataReader reader = prepStmt.ExecuteReader())
          {
            while (reader.Read())
            {
              pendingChangeIds.Add(reader.GetInt32("id_approval"));
            }
          }
        }
      }
    }

    /// <summary>
    /// Gets the change types user is allowed to work with.
    /// </summary>
    /// <returns></returns>
    /// <remarks></remarks>
    public List<string> GetChangeTypesUserIsAllowedToWorkWith()
    {
      List<string> result = new List<string>();
      foreach (ChangeTypeConfiguration changeTypeConfiguration in this.Configuration.Values)
      {
        IMTCompositeCapability requiredCapability;
        try
        {
          //May want to consider caching these
          IMTSecurity security = new MTSecurity();
          requiredCapability = security.GetCapabilityTypeByName(changeTypeConfiguration.CapabilityRequiredForApproveOrDeny).CreateInstance();
        }
        catch (Exception)
        {
          mLogger.LogError("Unable to create capability {0} specified in config for {1} in {2}", changeTypeConfiguration.CapabilityRequiredForApproveOrDeny, changeTypeConfiguration.Name, changeTypeConfiguration.ConfigFilePath);
          continue;
        }

        if (SessionContext.SecurityContext.CoarseHasAccess(requiredCapability))
          result.Add(changeTypeConfiguration.Name);
      }

      return result;
    }

    /// <summary>
    /// Gets the pending change notifications for user.
    /// </summary>
    /// <param name="idLanguageCode">The id language code.</param>
    /// <param name="pendingChangeNotifications">The pending change notifications.</param>
    /// <remarks></remarks>
    public void GetPendingChangeNotificationsForUser(int idLanguageCode, out List<ChangeNotificationSummary> pendingChangeNotifications)
    {
      VerifyUserHasPermissionToViewApprovalInformation();

      pendingChangeNotifications = new List<ChangeNotificationSummary>();

      //Get the list of change types the user can see
      string changeTypesTheUserCanSee = ""; //"'SampleUpdate', 'AccountUpdate'";
      foreach (string changeType in GetChangeTypesUserIsAllowedToWorkWith())
      {
        changeTypesTheUserCanSee += ((changeTypesTheUserCanSee.Length == 0) ? "" : ",") + "'" + changeType + "'";
      }

      if (string.IsNullOrEmpty(changeTypesTheUserCanSee))
      {
        //User isn't allow to approve/deny any change type, we can just return
        //without checking database
        return;
      }

      using (IMTConnection conn = ConnectionManager.CreateConnection(APPROVALSMANAGEMENT_QUERY_FOLDER))
      {
        //Weird but in this case we need to set the case statement and so need to combine setting parameters using query adapter AND
        //parameterized query
        MTQueryAdapter queryAdapter = new MTQueryAdapter();
        queryAdapter.Init(APPROVALSMANAGEMENT_QUERY_FOLDER);
        queryAdapter.SetQueryTag("__GET_PENDING_APPROVALS_FOR_USER__");
        queryAdapter.AddParam("%%CHANGE_TYPES_USER_CAN_APPROVE%%", changeTypesTheUserCanSee, true);

        using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(queryAdapter.GetQuery()))
        {
          //prepStmt.AddParam(MTParameterType.String, changeTypesTheUserCanSee);
          prepStmt.AddParam(MTParameterType.Integer, idLanguageCode);
          prepStmt.AddParam(MTParameterType.Integer, SessionContext.AccountID);

          using (IMTDataReader reader = prepStmt.ExecuteReader())
          {
            while (reader.Read())
            {
              ChangeNotificationSummary changeNotificationSummary = new ChangeNotificationSummary();
              changeNotificationSummary.PendingCount = reader.GetInt32("PendingCount");
              changeNotificationSummary.ChangeType = reader.GetString("ChangeType");
              changeNotificationSummary.ChangeTypeDisplayName = reader.GetString("DisplayName");
              pendingChangeNotifications.Add(changeNotificationSummary);
            }
          }
        }
      }

    }

    /// <summary>
    /// Is Approvals enabled for the given change type.
    /// </summary>
    /// <param name="changeType">Type of the change.</param>
    /// <param name="allowsMoreThanOnePendingChange">if set to <c>true</c> [allows more than one pending change].</param>
    /// <returns></returns>
    /// <remarks></remarks>
    public bool ApprovalsEnabledForChangeType(string changeType, out bool allowsMoreThanOnePendingChange)
    {
      ChangeTypeConfiguration configChangeType = Configuration[changeType];
      if (configChangeType != null)
      {
        allowsMoreThanOnePendingChange = configChangeType.AllowMoreThanOnePendingChange;
        return configChangeType.Enabled;
      }
      else
      {
        throw new MASBasicException("Invalid/Unknown ChangeType:" + changeType);
      }
    }

    #region internal
    /// <summary>
    /// Converts the culture to metra tech language code.
    /// </summary>
    /// <param name="culture">The culture.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    public LanguageCode ConvertCultureToMetraTechLanguageCode(CultureInfo culture)
    {
      try
      {
        var languageCode = (LanguageCode)CommonEnumHelper.GetEnumByValue(typeof(LanguageCode), culture.ToString());
        return languageCode;
      }
      catch (Exception)
      {
        mLogger.LogWarning("Unable to convert culture of {0} to MetraTech language code; using default");
        return LanguageCode.US;
      }
    }
    #endregion
  }

  /// <summary>
  /// Class used to summarize changes for dashboard notification display
  /// </summary>
  public class ChangeNotificationSummary
  {
    public string ChangeType
    {
      get;
      set;
    }
    public string ChangeTypeDisplayName
    {
      get;
      set;
    }
    public int PendingCount
    {
      get;
      set;
    }
  }
}
