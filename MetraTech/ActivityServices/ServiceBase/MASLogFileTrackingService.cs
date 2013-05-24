#pragma warning disable 1591  // Disable XML Doc warning for now.
using System;
using System.Collections.Generic;
using System.IO;
using System.Workflow.Runtime.Tracking;
using System.Xml.Schema;
using System.Diagnostics;
using System.Workflow.Activities;
using System.Workflow.Runtime;
using System.Workflow.ComponentModel;

namespace MetraTech.ActivityServices.Services.Common
{
  public class MASLogFileTrackingChannel : TrackingChannel
  {
    private TrackingParameters trackingParameters = null;
    private Logger m_Logger = new Logger(@"Logging\ActivityServices", "[SimpleTrackingChannel]");

    protected MASLogFileTrackingChannel()
    {
    }

    public MASLogFileTrackingChannel(TrackingParameters parameters)
    {
      trackingParameters = parameters;

      WriteTitle("Tracking {" + parameters.RootActivity.Name + "_" + parameters.InstanceId + "}");
    }

    // Send() is called by Tracking runtime to send various tracking records
    protected override void Send(TrackingRecord record)
    {
      //filter on record type
      if (record is WorkflowTrackingRecord)
      {
          WriteWorkflowTrackingRecord((WorkflowTrackingRecord)record);
      }
      if (record is ActivityTrackingRecord)
      {
          WriteActivityTrackingRecord((ActivityTrackingRecord)record);
      }
      //if (record is UserTrackingRecord)
      //{
      //    WriteUserTrackingRecord((UserTrackingRecord)record);
      //}
    }

    // InstanceCompletedOrTerminated() is called by Tracking runtime to indicate that the Workflow instance finished running
    protected override void InstanceCompletedOrTerminated()
    {
       WriteTitle("Workflow Instance Completed or Terminated");
    }

    private void WriteTitle (string title)
    {
      WriteToFile(Environment.NewLine);
      WriteToFile("**** " + title + " ****");
    }

    private void WriteWorkflowTrackingRecord(WorkflowTrackingRecord workflowTrackingRecord)
    {
       WriteToFile("Workflow: " + workflowTrackingRecord.TrackingWorkflowEvent.ToString());        
    }

    private void WriteActivityTrackingRecord(ActivityTrackingRecord activityTrackingRecord)
    {
       WriteToFile("Activity: [" + activityTrackingRecord.QualifiedName.ToString() + "] " + activityTrackingRecord.ExecutionStatus.ToString());
    }

    private void WriteUserTrackingRecord(UserTrackingRecord userTrackingRecord)
    {
       WriteToFile("User Data: " + userTrackingRecord.UserData.ToString());
    }

    private void WriteToFile(string toWrite)
    {
      try
      {
        m_Logger.LogInfo(toWrite);
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception in WriteToFile", e);
      }
    }
  }

  public class MASLogFileTrackingService : TrackingService
  {
    private string directoryPath = String.Empty;
    private string filePrefix = String.Empty;

    public MASLogFileTrackingService(string directoryPath, string filePrefix)
    {
      System.Diagnostics.Debug.Assert(!String.IsNullOrEmpty(directoryPath));
      System.Diagnostics.Debug.Assert(!String.IsNullOrEmpty(filePrefix));

      this.directoryPath = directoryPath;
      this.filePrefix = filePrefix;
    }

    /// <summary>
    ///   Delete the files with the given file prefix from the given directory.
    /// </summary>
    public void ClearTrackingFiles()
    {
      DirectoryInfo directoryInfo = new DirectoryInfo(directoryPath);
      FileInfo[] fileInfoList = directoryInfo.GetFiles(filePrefix + "*.txt");

      foreach (FileInfo fileInfo in fileInfoList)
      {
        fileInfo.Delete();
      }
    }

    protected override bool TryGetProfile(Type workflowType, out TrackingProfile profile)
    {
      //Depending on the workflowType, service can return different tracking profiles
      //In this sample we're returning the same profile for all running types
      profile = GetProfile();
      return true;
    }

    protected override TrackingProfile GetProfile(Guid workflowInstanceId)
    {
      // Does not support reloading/instance profiles
      throw new NotImplementedException("The method or operation is not implemented.");
    }

    protected override TrackingProfile GetProfile(Type workflowType, Version profileVersionId)
    {
      // Return the version of the tracking profile that runtime requests (profileVersionId)
      return GetProfile();
    }

    protected override bool TryReloadProfile(Type workflowType, Guid workflowInstanceId, out TrackingProfile profile)
    {       
      // Returning false to indicate there are no new profiles
      profile = null;
      return false;
    }

    protected override TrackingChannel GetTrackingChannel(TrackingParameters parameters)
    {
      return new MASLogFileTrackingChannel(parameters);
    }

    #region Tracking Profile Creation

    // Reads a file containing an XML representation of a Tracking Profile
    private static TrackingProfile GetProfile()
    {
      TrackingProfile profile = null;

        lock (typeof(MASLogFileTrackingService))
        {
          if (null == profile)
          {
            profile = new TrackingProfile();
            ActivityTrackPoint activityTrack = new ActivityTrackPoint();
            ActivityTrackingLocation activityLocation = new ActivityTrackingLocation(typeof(Activity));
            activityLocation.MatchDerivedTypes = true;
            IEnumerable<ActivityExecutionStatus> statuses = Enum.GetValues(typeof(ActivityExecutionStatus)) as IEnumerable<ActivityExecutionStatus>;
            foreach (ActivityExecutionStatus status in statuses)
            {
              activityLocation.ExecutionStatusEvents.Add(status);
            }

            activityTrack.MatchingLocations.Add(activityLocation);
            profile.ActivityTrackPoints.Add(activityTrack);
            profile.Version = new Version("3.0.0.0");

            WorkflowTrackPoint workflowTrack = new WorkflowTrackPoint();
            WorkflowTrackingLocation workflowLocation = new WorkflowTrackingLocation();
            IEnumerable<TrackingWorkflowEvent> eventStatuses = Enum.GetValues(typeof(TrackingWorkflowEvent)) as IEnumerable<TrackingWorkflowEvent>;
            foreach (TrackingWorkflowEvent status in eventStatuses)
            {
              workflowLocation.Events.Add(status);
            }

            workflowTrack.MatchingLocation = workflowLocation;
            profile.WorkflowTrackPoints.Add(workflowTrack);

          }
        }

      return profile;
    }

    #endregion
  }
}
