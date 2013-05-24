using System;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Reflection;
using System.Runtime.Serialization;
using MetraTech.Accounts;
using MetraTech.Accounts.Type;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.MTAuth;
using System.Transactions;
using MetraTech.DomainModel.Common;
using System.Collections;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.Approvals;
using System.IO;
using MetraTech.Debug.Diagnostics;


namespace MetraTech.Core.Services
{

  [ServiceContract]
  [ServiceKnownType(typeof(MetraTech.DomainModel.BaseTypes.ChangeState))]
  [ServiceKnownType(typeof(MTList<Change>))]
  [ServiceKnownType(typeof(MTList<ChangeSummary>))]
  [ServiceKnownType(typeof(MTList<ChangeHistoryItem>))]

  #region Interface

  public interface IApprovalManagementService
  {
    /// <summary>
    /// Get a list of changes in the approval system. These can include pending and non-pending changes.
    /// </summary>
    /// <param name="changes">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    /// <CapabilityRequired>Requires ApprovalsView capability</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>Does not currently return localized ChangeType name.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetChangesSummary(ref MTList<ChangeSummary> changes);

    /// <summary>
    /// Get a list of changes in the approval system. These can include pending and non-pending changes.
    /// </summary>
    /// <param name="changes">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    /// <CapabilityRequired>Requires ApprovalsView capability</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>Does not currently return localized ChangeType name.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetChangesSummaryForLocale(ref MTList<ChangeSummary> changes, string locale);

    /// <summary>
    /// Get a list of pending changes in the approval system.
    /// Note: This is equivalent to GetChangesSummary with filter set to State=Pending
    /// </summary>
    /// <param name="changes">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    /// <CapabilityRequired>Requires ApprovalsView capability</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>Does not currently return localized ChangeType name.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPendingChangesSummary(ref MTList<ChangeSummary> changes);

    /// <summary>
    /// Get a list of pending changes in the approval system.
    /// Note: This is equivalent to GetChangesSummary with filter set to State=Pending
    /// </summary>
    /// <param name="changes">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    /// <CapabilityRequired>Requires ApprovalsView capability</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>Does not currently return localized ChangeType name.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPendingChangesSummaryForLocale(ref MTList<ChangeSummary> changes, string locale);

    /// <summary>
    /// Return the custom change details for a particular change.
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="changeDetailsPayload">The string that is populated with the change details.</param>
    /// <CapabilityRequired>Requires ApprovalsView capability</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>None.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetChangeDetails(int changeId, ref string changeDetailsPayload);


    /// <summary>
    /// Updates the change details for a given pending change. Useful when editing is allowed and the details of the change need
    /// to be modified.
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="changeDetailsPayload">The string containing the updated change details.</param>
    /// <param name="comment">Optional comment as to why the details were updated</param>
    /// <CapabilityRequired>Requires user is the original submitter of the change and that the change is pending.</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>None.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateChangeDetails(int changeId, string changeDetailsPayload, string comment);


    /// <summary>
    /// Called to approve a pending change
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="comment">Optional comment for additional approval information; most likely only useful when change is approved by an automated process or outside system</param>
    /// <CapabilityRequired>Requires the capibility configured for the particular change type being approved and that the change is pending</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>Functional for testing but backend is not complete.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveChange(int changeId, string comment);


    /// <summary>
    /// Called to deny a pending change
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="comment">optional comment describing why the change was denied</param>
    /// <CapabilityRequired>Requires the capibility configured for the particular change type being approved and that the change is pending</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>Functional for testing but backend is not complete.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DenyChange(int changeId, string comment);


    /// <summary>
    /// Called to remove/cancel a pending change. Equivalent to DenyChange but can be called by user who created the change.
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="comment">optional comment describing why the change was removed</param>
    /// <CapabilityRequired>Requires user is the original submitter of the change or that has the capability configured for the particular change type and that the change is pending
    /// or in the failed state.</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>None.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DismissChange(int changeId, string comment);


    /// <summary>
    /// Gets a history for a particular change
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="changeHistoryItems">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    /// <CapabilityRequired>Requires ApprovalsView capability</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>Does not populate event details, event name or localized event name.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetChangeHistory(int changeId, ref MTList<ChangeHistoryItem> changeHistoryItems);

    /// <summary>
    /// Gets a history for a particular change
    /// </summary>
    /// <param name="changeId">id of the change withing the approval framework; most likely retrieved using the GetChangesSummary method</param>
    /// <param name="changeHistoryItems">The MTList object that contains the filter criteria and will be populated with the return results.</param>
    /// <param name="locale">string corresponding to valid CultureInfo to be used as language for returned values (Example: 'en-US', 'de', 'de-DE')</param>
    /// <CapabilityRequired>Requires ApprovalsView capability</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>Does not populate event details, event name or localized event name.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetChangeHistoryForLocale(int changeId, ref MTList<ChangeHistoryItem> changeHistoryItems, string locale);

    /// <summary>
    /// Submit a change for approval in the framework.
    /// </summary>
    /// <param name="change">The populated change object being submitted.
    /// Required properties that need to be populated for the chagne are: changeType, uniqueItemId, changeDetailsPayload.
    /// Optional properties that can be populated are: itemDisplayName, comment</param>
    /// <param name="changeId">Populated with the id of the newly created id upon return.</param>
    /// <CapabilityRequired>Requires that submitter is valid user in the system but does not require a particular capability beyond what the underlying change type may require.</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>Functional and working but backend is not complete.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    //void SubmitChange(Change change, ref int changeId);
    void SubmitChange(Change change, out int changeId);


    /// <summary>
    /// If changes have been approved but failed while being applied, this method is called to re-attempt to apply the approved changes.
    /// </summary>
    /// <param name="changeIds">List of failed change ids to re-attempt to apply</param>
    /// <CapabilityRequired>Requires ApprovalsView capability</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations>Functional and working but backend is not complete.</Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ResubmitFailedChanges(MTList<int> changeIds);


    /// <summary>
    /// Called to determine if a particular item type and item id have a pending change.
    /// </summary>
    /// <param name="changeType">The type of type as specified in the framework and ApprovalConfiguration.xml</param>
    /// <param name="UniqueItemId">The unique id of the item of a given type that was passed when the item was submitted</param>
    /// <param name="pendingChangeIds">The result indicating if there are pending changes.</param>
    /// <CapabilityRequired>Requires that submitter is valid user in the system but does not require a particular capability.</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations></Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPendingChangeIdsForItem(string changeType, string UniqueItemId, out List<int> pendingChangeIds);


    /// <summary>
    /// Called to determine if approvals are enabled for a particular change type
    /// </summary>
    /// <param name="changeType">The type of type as specified in the framework and ApprovalConfiguration.xml</param>
    /// <param name="enabled">Result indicating if approvals are enabled for this change type as specified in the ApprovalConfiguration.xml</param>
    /// <CapabilityRequired>Requires that submitter is valid user in the system but does not require a particular capability.</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations></Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApprovalEnabledForChangeType(string changeType, out bool enabled);

    //May need additional methods to allow retrieving configuration information for change types from the webservice

    /// <summary>
    /// Called to get config object of this change type
    /// </summary>
    /// <param name="changeType">The type of type as specified in the framework and ApprovalConfiguration.xml</param>
    /// <CapabilityRequired>Requires that submitter is valid user in the system but does not require a particular capability.</CapabilityRequired>
    /// <UnitTests></UnitTests>
    /// <Limitations></Limitations>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RetrieveChangeTypeConfiguration(string changeType, ref MTList<ChangeTypeConfiguration> changetypeconfiguration);

  }

  #endregion

  [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
  public class ApprovalManagementService : CMASServiceBase, IApprovalManagementService
  {
    protected static ApprovalsConfiguration mConfiguration = null;
    protected static ApprovalsFileWatcher mConfigurationFileWatcher = null;

    private static Logger mLogger = new Logger("[ApprovalManagementService]");

    static ApprovalManagementService()
    {
      CMASServiceBase.ServiceStarting += new ServiceStartingEventHandler(CMASServiceBase_ServiceStarting);
    }

    private static void CMASServiceBase_ServiceStarting()
    {
      try
      {
        mConfiguration = ApprovalsConfigurationManager.LoadChangeTypesFromAllExtensions();
        mConfigurationFileWatcher = ApprovalsConfigurationManager.GetFileWatcherFromConfiguration(mConfiguration,
                                                                                                  new FileSystemEventHandler
                                                                                                    (OnConfigFileChangedHandler));
      }
      catch (Exception ex)
      {
        mLogger.LogError("Unable to load approvals configuration: " + ex.Message);
      }
    }

    /// <summary>
    /// Method to attempt to dynamically reload configuration if they have changed on disk
    /// </summary>
    /// <param name="source"></param>
    /// <param name="e"></param>
    private static void OnConfigFileChangedHandler(object source, FileSystemEventArgs e)
    {

      mLogger.LogDebug("Configuration File Changed: " + e.FullPath + " " + e.ChangeType);

      try
      {
        ApprovalsConfiguration updateConfig = ApprovalsConfigurationManager.LoadChangeTypesFromAllExtensions();
        mConfiguration = updateConfig;
      }
      catch (Exception ex)
      {
        mLogger.LogError("Unable to load update approvals configuration: " + e.FullPath + ": " + ex.Message);
        mLogger.LogError(
          "Approvals management will continue to run using previously loaded configuration but ActivityServices will not start again once stopped until the configuration loading issue is resolved.");
      }
    }

    #region Interface Implementation

    public void GetChangesSummary(ref MTList<ChangeSummary> changes)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetChangesSummary"))
      {
        ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                   GetSessionContext());
        approvalsFramework.GetChangesSummary(ref changes);
      }
    }

    public void GetChangesSummaryForLocale(ref MTList<ChangeSummary> changes, string locale)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetChangesSummaryForLocale"))
      {
        ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                   GetSessionContext());
        approvalsFramework.GetChangesSummary(ref changes, locale);
      }
    }

    public void GetPendingChangesSummary(ref MTList<ChangeSummary> changes)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPendingChangesSummary"))
      {
        ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                   GetSessionContext());
        approvalsFramework.GetPendingChangesSummary(ref changes);
      }
    }

    public void GetPendingChangesSummaryForLocale(ref MTList<ChangeSummary> changes, string locale)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPendingChangesSummaryForLocale"))
      {
        ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                   GetSessionContext());
        approvalsFramework.GetPendingChangesSummary(ref changes, locale);
      }
    }

    public void GetChangeDetails(int changeId, ref string changeDetailsPayload)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetChangeDetails"))
      {
        ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                   GetSessionContext());
        approvalsFramework.GetChangeDetails(changeId, out changeDetailsPayload);
      }
    }

    public void UpdateChangeDetails(int changeId, string changeDetailsPayload, string comment)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateChangeDetails"))
      {
        try
        {
          ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                     GetSessionContext());
          approvalsFramework.UpdateChangeDetail(changeId, changeDetailsPayload, comment);
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error in UpdateChangeDetails", ex);
          throw;
        }
      }
    }

    public void ApproveChange(int changeId, string comment)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveChange"))
      {
        try
        {
          ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                     GetSessionContext());
          approvalsFramework.ApproveChange(changeId, comment);
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error in ApproveChange", ex);
          throw;
        }
      }
    }

    public void DenyChange(int changeId, string comment)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DenyChange"))
      {
        try
        {
          ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                     GetSessionContext());
          approvalsFramework.DenyChange(changeId, comment);
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error in DenyChange", ex);
          throw;
        }
      }
    }

    public void SubmitChange(Change change, out int changeId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SubmitChange"))
      {
        try
        {
          ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                     GetSessionContext());
          approvalsFramework.SubmitChange(change, out changeId);
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error in SubmitChange", ex);
          throw;
        }
      }
    }

    public void ResubmitFailedChanges(MTList<int> changeIds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ResubmitFailedChanges"))
      {
        try
        {
          ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                     GetSessionContext());
          approvalsFramework.ResubmitFailedChanges(changeIds);
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error in ResubmitFailedChanges", ex);
          throw;
        }
      }
    }

    public void DismissChange(int changeId, string comment)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DismissChange"))
      {
        try
        {
          ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                     GetSessionContext());
          approvalsFramework.DismissChange(changeId, comment);
        }
        catch (Exception ex)
        {
          mLogger.LogException("Error in DismissChange", ex);
          throw;
        }
      }
    }

    public void GetChangeHistory(int changeId, ref MTList<ChangeHistoryItem> changeHistoryItems)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetChangeHistory"))
      {
        ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                   GetSessionContext());
        approvalsFramework.GetChangeHistory(changeId, ref changeHistoryItems);
      }
    }

    public void GetChangeHistoryForLocale(int changeId, ref MTList<ChangeHistoryItem> changeHistoryItems, string locale)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetChangeHistoryForLocale"))
      {
        ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                   GetSessionContext());
        approvalsFramework.GetChangeHistory(changeId, ref changeHistoryItems, locale);
      }
    }

    public void GetPendingChangeIdsForItem(string changeType, string uniqueItemId, out List<int> pendingChangeIds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPendingChangeIdsForItem"))
      {
        ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(mConfiguration,
                                                                                                   GetSessionContext());
        approvalsFramework.GetPendingChangeIdsForItem(changeType, uniqueItemId, out pendingChangeIds);
      }
    }

    public void ApprovalEnabledForChangeType(string changeType, out bool enabled)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveEnabledForChangeType"))
      {
        enabled = mConfiguration.GetChangeTypeConfiguration(changeType).Enabled;
      }
    }

    public void RetrieveChangeTypeConfiguration(string changeType,
                                                ref MTList<ChangeTypeConfiguration> changetypeconfiguration)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RetrieveChangeTypeConfiguration"))
      {
        ChangeTypeConfiguration ctc = new ChangeTypeConfiguration();
        ctc.Enabled = mConfiguration.GetChangeTypeConfiguration(changeType).Enabled;
        ctc.AllowMoreThanOnePendingChange =
          mConfiguration.GetChangeTypeConfiguration(changeType).AllowMoreThanOnePendingChange;
        ctc.CapabilityRequiredForApproveOrDeny =
          mConfiguration.GetChangeTypeConfiguration(changeType).CapabilityRequiredForApproveOrDeny;
        ctc.WebpageForEdit = mConfiguration.GetChangeTypeConfiguration(changeType).WebpageForEdit;
        changetypeconfiguration.Items.Add(ctc);
      }
    }

    #endregion

  }
}
