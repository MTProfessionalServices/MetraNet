using System.Globalization;
using System.Text;

namespace MetraTech.FileService
{
  using System;
  using System.IO;
  using System.Collections.Generic;
  using System.ComponentModel;
  using System.Diagnostics;
  using System.Linq;
  using System.ServiceProcess;
  using System.Threading;
  using System.Text.RegularExpressions;
  using Core.FileLandingService;
  using DomainModel.Enums.Core.Metratech_com_FileLandingService;

  /// <summary>
  /// The states the FileService can be in.
  /// </summary>
  public enum DispatcherState
  {
    STOP = -1,
    RUN = 0,
    PAUSE = 1,
  }

  /// <summary>
  /// FileService monitors a directory for incoming files.  When a file is
  /// received, determines which executable to invoke based on configuration.
  /// The file name(s) is passed to the executable in the command line.
  /// Can pass single file per executable or multiple files per executable.
  /// </summary>
  public partial class FileService : ServiceBase
  {
    #region Data Members

    /// <summary>
    /// The maximum amount of time to wait for all the multipoint files to 
    /// arrive before issuing an error (minutes).
    /// </summary>
    private const int MAX_MULTIPOINT_FILE_WAIT_MINS = 2;

    /// <summary>
    /// Logger.
    /// </summary>
    private static readonly TLog m_log = new TLog("MetraTech.FileService.FileService");

    /// <summary>
    /// Hold FLS configuration
    /// </summary>
    private static readonly Registry m_configManager = TSingleton<Registry>.Instance;

    /// <summary>
    /// Lock for altering m_state.
    /// </summary>
    private Object m_stateLock = new Object();

    /// <summary>
    /// The current state of the FileService: running, paused, or stopped.
    /// </summary>
    private DispatcherState m_state = DispatcherState.PAUSE;

    /// <summary>
    /// A list of the control numbers that are currently being worked on
    /// or have been submitted and are awaiting processing.
    /// </summary>
    private List<string> m_pendingControlNumbers = new List<string>();

    /// <summary>
    /// Polls the new directory looking for files waiting to be processed.
    /// </summary>
    private BackgroundWorker m_directoryMonitor = new BackgroundWorker();

    /// <summary>
    /// Callback routine used by a thread to processing a 
    /// file that arrived.
    /// </summary>
    private WaitCallback m_processWorkOrderCallback;

    private bool m_wasMissingConfigMsgIssued;


    #endregion Data Members

    /// <summary>
    /// Constructor
    /// </summary>
    public FileService()
    {
      m_log.Debug(CODE.__FUNCTION__);
      InitializeComponent();

      AppDomain.CurrentDomain.UnhandledException += AppDomainUnhandledExceptionHandler;
    }

    public DispatcherState State
    {
      get
      {
        DispatcherState state;
        lock (m_stateLock)
        {
          state = m_state;
        }
        return state;
      }
      set
      {
        lock (m_stateLock)
        {
          m_state = value;
        }
      }
    }

    /// <summary>
    /// Handles any unhandled exceptions and 
    /// </summary>
    /// <param name="sender">The sender of the event</param>
    /// <param name="e">The evnet arguments</param>
    internal static void AppDomainUnhandledExceptionHandler(object sender, UnhandledExceptionEventArgs e)
    {
      const string methodName = "[AppDomainUnhandledExceptionHandler]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        m_log.Error(string.Concat("Domain Level Unhandled Exception Handler Triggered [IsTerminating=", (e.IsTerminating ? "true" : "false"), "]"));

        var exception = e.ExceptionObject as Exception;
        if (exception != null)
        {
          LogException(methodName, exception);
        }
        else
        {
          m_log.Error("Domain Level Unhandled Exception Handler Exception Is Null.");
        }
      }
      catch // Trap all exceptions
      {
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    #region Service Events
    protected override void OnStart(string[] args)
    {
      // Break for debug mode builds; this starts a debugging instance
      CODE.__BREAKPOINT__();

      const string methodName = "[OnStart]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        m_log.Info(string.Concat(methodName, "Starting the FileLandingService..."));

        // Start configuration.  Although a framework is in place for watching
        // configuration changes, we do not use this.
        m_configManager.EventChanged += ActivateConfigurationChange;
        m_configManager.ReadConfiguration();
        ActivateConfigurationChange(new CfgEvtChangeArgs(CfgEventArgType.ServiceChange, null));

        // Any files that are left in the inprogress directory from last time
        // should be moved to done.
        MoveFilesFromInProgressToDone();

        // Start the thread that polls the new directory looking
        // for files.
        m_directoryMonitor.DoWork += MonitorNewDirectory;
        m_directoryMonitor.WorkerSupportsCancellation = true;
        m_directoryMonitor.RunWorkerAsync(this);

        var minThreads = Math.Max(m_configManager.ServiceConfiguration.MinimumThreadsReadyToRunExecutables, 1);
        var maxThreads = Math.Max(m_configManager.ServiceConfiguration.MaximumExecutablesRunningConcurrently, 2);
        ThreadPool.SetMinThreads(minThreads, minThreads);
        ThreadPool.SetMaxThreads(maxThreads, maxThreads);

        // Thread pool handlers for async processing of events.
        m_processWorkOrderCallback = ProcessWorkOrder;

        /// TODO: FEATURE ENHANCEMENT (Need to create a thread which monitors work queue for jobs for not processed (ie not gotten all files satisfied within a grace period) These files must fail. If the final file comes in, then the update CTRL batch should restart the process.
        /// TODO: FEATURE ENHANCEMENT (Need to create MSMQ (Use RecoverableQueue from ActivityServices Template code) This will allow for job recovery, on stop start with no loss. Will need to add logic to handle the restart of queued work.


        m_log.Info(string.Concat(methodName, "The FileLandingService has started."));
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Stops the service and cleans up resouces
    /// </summary>
    protected override void OnStop()
    {
      const string methodName = "[OnStop]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        m_log.Info(string.Concat(methodName, "Stopping the FileLandinService..."));
        State = DispatcherState.STOP;

        // Stop the directory monitor
        m_directoryMonitor.CancelAsync();
        m_directoryMonitor.DoWork -= MonitorNewDirectory;

        /// TODO: FEATURE ENHANCEMENT (Need to create a thread which monitors work queue for jobs for not processed (ie not gotten all files satisfied within a grace period) These files must fail. If the final file comes in, then the update CTRL batch should restart the process.
        /// TODO: FEATURE ENHANCEMENT (Need to create MSMQ (Use RecoverableQueue from ActivityServices Template code) This will allow for job recovery, on stop start with no loss. Will need to add logic to handle the restart of queued work.


        m_log.Debug(string.Concat(methodName, "The FileLandService has stopped."));
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }
    #endregion

    /// <summary>
    /// This is the configuration change callback from the Config Manager (BME database)
    /// As things in the DB change, this callback will be invoked to address the changes.
    /// </summary>
    /// <param name="arg"></param>
    void ActivateConfigurationChange(CfgEvtChangeArgs arg)
    {
      const string methodName = "[ActivateConfigurationChange]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        State = DispatcherState.PAUSE;

        // Notice we don't clean up old directories...
        // as they may have had collection in them....
        if (CfgEventArgType.ServiceChange == arg.ChgType)
        {
          CheckConfiguration();
        }

        m_state = DispatcherState.RUN;
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Verify that we have the global configuration information.
    /// </summary>
    private void CheckConfiguration()
    {
      const string methodName = "[CheckConfiguration]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        if (!m_configManager.ServiceConfiguration.HasGlobalConfiguration() &&
            !m_wasMissingConfigMsgIssued)
        {
          m_log.Warn(string.Concat(methodName, "The FLS will not accept files since FLS has not been configured."));
          m_wasMissingConfigMsgIssued = true;
        }
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    #region Helper Routines

    /// <summary>
    /// Takes all steps to reject a file:
    /// Updates the database, marking the file record as rejected;
    /// logs the rejection; clears the retry flag;
    /// moves all associated files from New directory to Done directory;
    /// removes the control number from the list of control numbers currently being processed.
    /// </summary>
    /// <param name="parsedFilename">The file being rejected.</param>
    /// <param name="associatedFiles">Files in the same job as the rejected file.</param>
    /// <param name="reason">Reason code for rejection.</param>
    /// <param name="errorText">Explanation for rejection.</param>
    private void RejectFile(ParsedFileName parsedFilename, List<string> associatedFiles, ERejectionReason reason, string errorText)
    {
      const string methodName = "[RejectFile]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        m_log.Error(String.Format("{0} Marking file {1} as rejected.", methodName, parsedFilename.FullName));

        FileBE file = m_configManager.FileRegistry.FindByFullName(parsedFilename.FullName);

        if (file != null)
        {
          m_log.Error(String.Format("{0} FILE: {1}:  REJECTED - {2}  {3}", methodName, parsedFilename.FullName, reason.ToString(), errorText));

          file._State = EFileState.REJECTED;
          file._RejectReason = reason;
          file._Retry = 0; // Indicates that a retry is not in progress.

          // Prepend timestamp and omit path when storing error message in DB.
          file._ErrorMessage = String.Format("{0} {1}  FILE: {2}:  REJECTED - {3}  {4}",
                                             methodName, DateTime.Now.ToString("s"), parsedFilename.Name, reason.ToString(), errorText);

          m_configManager.FileRegistry.Update(file);
        }
        else
        {
          m_log.Error(string.Concat(methodName, "Unexpectedly failed to find file: ", parsedFilename.FullName));
        }

        MoveFiles(associatedFiles, NewDir(), DoneDir());
        if (parsedFilename.IsHealthy)
        {
          RemovePendingControlNumber(parsedFilename.ControlNumber);
        }
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Mark the given files as accepted.
    /// </summary>
    /// <param name="files">Files to mark as accepted.</param>
    private void MarkFilesAsAccepted(List<FileBE> files)
    {
      const string methodName = "[MarkFilesAsAccepted]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        foreach (FileBE file in files)
        {
          m_log.Debug(String.Format("{0} Marking file {1} as accepted.", methodName, file._Name));
          file._State = EFileState.ASSIGNED;
          file._Retry = 0;
          file._ErrorMessage = null;
          m_configManager.FileRegistry.Update(file);
        }
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Given a list of file names (not full path, just name) move the files
    /// from the 'fromDir' to the 'toDir'.  If the file is not in the 'toDir'
    /// do NOT log an error.
    /// </summary>
    /// <param name="files"></param>
    /// <param name="fromDir"></param>
    /// <param name="toDir"></param>
    private void MoveFiles(List<string> files, string fromDir, string toDir)
    {
      const string methodName = "[MoveFiles]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        foreach (string file in files)
        {
          string from = fromDir + file;
          string to = toDir + file;

          m_log.Debug(String.Format("{0} Moving file {1} to {2}", methodName, from, to));

          if (!File.Exists(from))
          {
            m_log.Debug(string.Concat(methodName, "Not moving file since ", from, " not found."));
            continue;
          }

          if (File.Exists(to))
          {
            m_log.Debug(string.Concat(methodName, "Removing existing file ", to));
            File.Delete(to);
          }

          try
          {
            File.Move(from, to);
          }
          catch (Exception e)
          {
            m_log.Error(string.Concat(methodName, "Unable to move ", from, " to ", to, "Exception: " + e.Message));
          }
        }
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Append the second given list of full path names to the first given list,
    /// but only add the name (not the full path).
    /// Do not append the list item if already present in the first list.
    /// </summary>
    /// <param name="origList">list to append to</param>
    /// <param name="more">list of full pathnames</param>
    private void AddFileNamesToList(List<string> origList, List<string> more)
    {
      const string methodName = "[AddFileNamesToList]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        foreach (string file in more)
        {
          string name = Path.GetFileName(file);

          if (origList.Contains(name))
          {
            continue;
          }
          origList.Add(name);
        }
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Move all the files in the inprogress directory to
    /// the done directory.
    /// </summary>
    private void MoveFilesFromInProgressToDone()
    {
      const string methodName = "[MoveFilesFromInProgressToDone]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        var filesToMove = new List<string>();
        try
        {
          string[] files = Directory.GetFiles(InProgressDir());

          for (int i = 0; i < files.Length; i++)
          {
            filesToMove.Add(System.IO.Path.GetFileName(files[i]));
          }
        }
        catch (Exception)
        {
          m_log.Error("Unable to read directory: " + NewDir());
        }

        MoveFiles(filesToMove, InProgressDir(), DoneDir());
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Path the the new directory.
    /// </summary>
    /// <returns></returns>
    private string NewDir()
    {
      return m_configManager.ServiceConfiguration.NewDir;
    }

    /// <summary>
    /// Path to the inprogress directory.
    /// </summary>
    /// <returns></returns>
    private string InProgressDir()
    {
      return m_configManager.ServiceConfiguration.InProgressDir;
    }

    /// <summary>
    /// Path to the done directory.
    /// </summary>
    /// <returns></returns>
    private string DoneDir()
    {
      return m_configManager.ServiceConfiguration.DoneDir;
    }

    #endregion Helper Routines

    /// <summary>
    /// This method is called when a file should be processed.
    /// </summary>
    /// <param name="incomingFile">File to process</param>
    private void AddWorkOrderToThreadPool(string incomingFile)
    {
      const string methodName = "[AddWorkOrderToThreadPool]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        // Create a new workOrder.
        var workOrder = new WorkOrder(m_configManager.ServiceConfiguration.DB, new InvocationRecordBE())
                                     {parsedNameOfFile = new ParsedFileName(incomingFile)};

        ThreadPool.QueueUserWorkItem(m_processWorkOrderCallback, workOrder);
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Poll the new directory looking for files.  If a file is found, a work order
    /// containing the filename is added to the thread pool for processing.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="eventArgs"></param>
    private void MonitorNewDirectory(object sender, DoWorkEventArgs eventArgs)
    {
      const string methodName = "[MonitorNewDirectory]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        /// TODO: FEATURE ENHANCEMENT (Need to create a thread which monitors work queue for jobs for not processed (ie not gotten all files satisfied within a grace period) These files must fail. If the final file comes in, then the update CTRL batch should restart the process.
        /// TODO: FEATURE ENHANCEMENT (Need to create MSMQ (Use RecoverableQueue from ActivityServices Template code) This will allow for job recovery, on stop start with no loss. Will need to add logic to handle the restart of queued work.

        var worker = sender as BackgroundWorker;
        var maxFilesInQueue = Math.Min(m_configManager.ServiceConfiguration.MaximumFilesInQueue, 5000);
        var holdTime = Math.Max(m_configManager.ServiceConfiguration.HoldAgeInMilliseconds, 100);
        var scanTime = Math.Max(m_configManager.ServiceConfiguration.DirectoryScanTimeInMilliseconds, 100);
        while (DispatcherState.STOP != State)
        {
          // Causes the thread to sleep on configuration
          // changes...
          if (CheckForPendingStop(eventArgs, worker)) return;

          // Every loop make sure we are not pushing too much work onto the queue
          // This will ensure we don't run out of memory due to queue overloading
          while (m_pendingControlNumbers.Count > maxFilesInQueue)
          {
            if (CheckForPendingStop(eventArgs, worker)) return;
            m_log.Debug("Monitor thread sleeping until consumers catch up");
            Thread.Sleep(1000);
          }
          // On with real work (in RUN mode)
          try
          {
            var filesInNew = Directory.GetFiles(NewDir());

            foreach (var t in filesInNew)
            {
              if (CheckForPendingStop(eventArgs, worker)) return;

              // Make sure the file modification time is at least N-minutes old
              var fi = new FileInfo(t);
              var mark = DateTime.UtcNow.AddMilliseconds(-(holdTime));
              if ((fi.CreationTimeUtc > mark ) ||
                  (fi.LastAccessTimeUtc > mark) ||
                  (fi.LastWriteTimeUtc > mark))
              {
                m_log.Debug(String.Concat("Skipping file ", 
                                          t, 
                                          " as the last mod, creation, or access time is less than ", 
                                          holdTime, 
                                          " minutes.",
                                          " MARK: ",
                                          mark,
                                          " CreationTimeUtc: ",
                                          fi.CreationTimeUtc,
                                          " LastAccessTimeUtc: ",
                                          fi.LastAccessTimeUtc,
                                          " LastWriteTimeUtc: ",
                                          fi.LastWriteTimeUtc
                                          ));
                continue;
              }

              // If the control number is already present in pending control numbers
              // (jobs being processed or in the thread pool)  then don't add this file.  
              // We wouldn't want different threads picking out different work orders referring
              // to the same control number.
              var parsed = new ParsedFileName(t);
              if (parsed.IsHealthy)
              {
                if (IsControlNumberAwaitingProcessing(parsed.ControlNumber))
                {
                  m_log.Debug(String.Concat("Not enrolling file ",t," is already enrolled: "));
                  continue;
                }

                // We keep track of all the control numbers that are being processed.
                AddPendingControlNumber(parsed.ControlNumber);
              }

              m_log.Info("Enrolling file to be processed: " + t);
              AddWorkOrderToThreadPool(t);
            }
          }
          catch (Exception e)
          {
            m_log.Error("Unable to read directory: " + NewDir() + " Error: " + e.Message +
                         " " + e.InnerException);
            Thread.Sleep(120000);
          }

          // Give us an escape route...
          if (worker != null && worker.CancellationPending)
          {
            eventArgs.Cancel = true;
            return;
          }

          Thread.Sleep(scanTime);
        }
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    private bool CheckForPendingStop(DoWorkEventArgs eventArgs, BackgroundWorker worker)
    {
      while (DispatcherState.PAUSE == State)
      {
        // Sleep for 1 second
        Thread.Sleep(1000);

        // Give us an escape route...
        if (worker == null || !worker.CancellationPending) continue;
        eventArgs.Cancel = true;
        return true;
      }
      return false;
    }

    /// <summary>
    /// Return true if the given control number is already associated with
    /// a work order and is awaiting processing.
    /// </summary>
    /// <param name="controlNumber"></param>
    /// <returns></returns>
    private bool IsControlNumberAwaitingProcessing(string controlNumber)
    {
      lock (m_pendingControlNumbers)
      {
        return m_pendingControlNumbers.Contains(controlNumber);
      }
    }

    /// <summary>
    /// Adding control number to pending control numbers (jobs
    /// being processed or in the thread pool).
    /// </summary>
    /// <param name="controlNumber"></param>
    /// <returns></returns>
    private void AddPendingControlNumber(string controlNumber)
    {
      lock (m_pendingControlNumbers)
      {
        m_pendingControlNumbers.Add(controlNumber);
      }
    }

    /// <summary>
    /// Remove control number from the pending control numbers (jobs
    /// being processed or in the thread pool).
    /// </summary>
    /// <param name="controlNumber"></param>
    /// <returns></returns>
    private void RemovePendingControlNumber(string controlNumber)
    {
      const string methodName = "[RemovePendingControlNumber]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        m_log.Debug(string.Concat(methodName, "Done running control number: ", controlNumber));
        lock (m_pendingControlNumbers)
        {
          m_pendingControlNumbers.Remove(controlNumber);
        }
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    #region Work Order Processing

    private bool CheckForHalt()
    {
      const string methodName = "[CheckForHalt]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        while (State == DispatcherState.PAUSE) Thread.Sleep(0);

        if (State == DispatcherState.STOP)
        {
          m_log.Info(string.Concat(methodName, "Halt captured... stopping."));
          return true;
        }
        return false;
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
        throw;
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Given a work order containing the name of an incoming file,
    /// determine if the file matches a target and if so, run
    /// the target.
    /// </summary>
    /// <param name="data">A work order</param>
    public void ProcessWorkOrder(object data)
    {
      const string methodName = "[ProcessWorkOrder]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        if (CheckForHalt()) return;

        WorkOrder workOrder = data as WorkOrder;

        // Check input
        if (null == workOrder)
        {
          m_log.Error(string.Concat(methodName, "Unexpectedly encountered a null work order."));
          return;
        }

        m_log.Info(string.Concat(methodName, "Processing file ", workOrder.parsedNameOfFile.Name));

        /// TODO: FEATURE ENHANCEMENT (Need to allow for resubmition of failed jobs)
        /// we will change the following logic to accomidate file state and allow for updates
        /// versus new entries.
        
        // Store this file in the database.
        // This will do nothing if this file has already be stored (retry).
        FileBE incomingFile = StoreFileInDatabase(workOrder.parsedNameOfFile.FullName);

        if (incomingFile == null)
        {
          // Errors have already been logged by underlying layers.
          return;
        }

        // Create a list of files associated with this work order.  This will be the incoming file available
        // in the work order plus any additional files that arrived earlier in the multipoint case.  This
        // list is slightly different than the files that will be passed to the executables.  You can have
        // a file that triggers the executable, but is not an argument to the executable.
        List<string> associatedFiles = new List<string>();
        associatedFiles.Add(workOrder.parsedNameOfFile.Name);

        // Make sure the file follows the naming convention.
        if (!workOrder.parsedNameOfFile.IsHealthy)
        {
          RejectFile(workOrder.parsedNameOfFile, associatedFiles, ERejectionReason.IMPROPERLY_NAMED,
                     "Filename does not have format required by FLS:  " +
                     "<control number>.<target filter>.<argument filter>.<extension>");
          return;
        }

        // We have to make sure we remove the control number from our list of pending control number jobs.
        string controlNumber = workOrder.parsedNameOfFile.ControlNumber;

        // Try to find a matching target
        if (null == (workOrder.Target = m_configManager.TargetRegistry.FindTarget(workOrder.parsedNameOfFile.Name)))
        {
          RejectFile(workOrder.parsedNameOfFile, associatedFiles, ERejectionReason.TARGET_NOT_FOUND,
                     String.Format(
                       "Target filter '{0}' in the filename does not map to any configured FLS target.  " +
                       "Check FLS configuration under MetraControl => File Management => Configure Targets.",
                       workOrder.parsedNameOfFile.TargetTag));
          return;
        }

        m_log.Debug(string.Concat(methodName, "Matched file to FLS target: ", workOrder.Target.Name));

        // Check if the control number is being reused.
        InvocationRecordBE oldJob = m_configManager.OrderRegistry.FindByControlNumber(workOrder.parsedNameOfFile.ControlNumber);
        if (oldJob != null)
        {
          m_log.Info(string.Concat(methodName, "Control number '", workOrder.parsedNameOfFile.ControlNumber, "' has already been used."));

          // Since this is re-use of a control number, the old job state must be failed (retry case)
          if (oldJob._State != EInvocationState.FAILED)
          {
            RejectFile(workOrder.parsedNameOfFile, associatedFiles, ERejectionReason.CONTROL_NUMBER_REUSED,
                       String.Format(
                         "A job associated with control number '{0}' has already been processed (state: {1}).  " +
                         "Change the filename to include a different, unique control number and try again.",
                         workOrder.parsedNameOfFile.ControlNumber,
                         oldJob._State));
            return;
          }

          // This is a retry
          workOrder.IsRetry = true;
          m_log.Debug(string.Concat(methodName, "This is a retry of a previously executed job.  File: ", workOrder.parsedNameOfFile.FullName));

          // Store the found invocation record under the work order.
          // Also copy information from the found invocation record into the work order,
          // such as batch ID, tracking ID, etc.
          workOrder.UpdateBasedOnGivenInvocationRecord(oldJob);
          m_log.Debug(string.Concat(methodName, "The previously issued command was: ", workOrder.Command));

          // We expect that this file name should appear in the previously issued command.
          if (workOrder.GetNumberOfFilesRequired() > 0 &&
              !workOrder.Command.Contains(workOrder.parsedNameOfFile.Name))
          {
            RejectFile(workOrder.parsedNameOfFile, associatedFiles, ERejectionReason.IMPROPERLY_NAMED,
                       "This is a retry, but this file was not part of the originally issued command [" + workOrder.Command +
                       "].  For a retry, you must use the original file names.");
            return;
          }
        }

        // Set up a list of the files to use in the command.
        List<FileBE> fileBEs = new List<FileBE>();

        if (!workOrder.IsRetry)
        {
          // Looking in the incoming directory, create a list of files to use.  
          List<string> filesToUse = m_configManager.FileRegistry.GetFilesForArgumentsFromDir(
                                                                      m_configManager.ServiceConfiguration.NewDir,
                                                                      workOrder.parsedNameOfFile.FullName,
                                                                      workOrder.Target.FileArguments);
          // Add to the associatedFiles other incoming files we are using (multipoint case);
          AddFileNamesToList(associatedFiles, filesToUse);

          // Do we have the all the files we need?
          if (filesToUse.Count < workOrder.GetNumberOfFilesRequired())
          {
            // Give up if we needed just one file and didn't get it or we needed
            // many files but we've been waiting more than MAX_MULTIPOINT_FILE_WAIT_MINS
            // since the trigger file showed up.
            if (workOrder.GetNumberOfFilesRequired() <= 1 ||
                workOrder.FileAgeInMinutes() > MAX_MULTIPOINT_FILE_WAIT_MINS)
            {
              RejectFile(workOrder.parsedNameOfFile, associatedFiles, ERejectionReason.NOT_ENOUGH_FILES,
                         String.Format("Target '{0}' requires {1} file(s), but number of files found = {2}.  " +
                           "Make sure all required files are in the 'new' subdirectory of the configured FLS Incoming Directory.",
                           workOrder.Target.Name, workOrder.GetNumberOfFilesRequired(), filesToUse.Count)
                         );
            }
            else
            {
              m_log.Info(
                String.Format("{0} Target '{1}' requires {2} file(s), but only have {3} now.  Have waited {4} minutes so far.",
                              methodName, workOrder.Target.Name, workOrder.GetNumberOfFilesRequired(),
                              filesToUse.Count, workOrder.FileAgeInMinutes())
                );
              // We are leaving the files in the New directory.  In that way, they will
              // be picked up again by the directory monitor and retried.
              RemovePendingControlNumber(controlNumber);
            }

            return;
          }

          // Create FileBE records in the database for all these files.
          StoreFilesInDatabase(filesToUse, fileBEs);
        }
        else
        {
          // Since this is a retry, the old job contains the list of files to use.
          m_configManager.OrderRegistry.GetFiles(oldJob, fileBEs);
          //ESR-6030
          //reset associatedFiles and add there data from the old Job
          associatedFiles.Clear();
          associatedFiles.AddRange(fileBEs.Select(fileBe => fileBe._Name));
          // Do we have the all the original files we need?
          if (!m_configManager.FileRegistry.AreFilesPresent(m_configManager.ServiceConfiguration.NewDir, fileBEs))
          {
            // If we've been waiting more than MAX_MULTIPOINT_FILE_WAIT_MINS since the trigger file showed up, give up.
            if (workOrder.FileAgeInMinutes() > MAX_MULTIPOINT_FILE_WAIT_MINS)
            {
              RejectFile(workOrder.parsedNameOfFile, associatedFiles, ERejectionReason.NOT_ENOUGH_FILES,
                         String.Format("Missing some of the {0} original files for this retry of control number '{1}'.  " +
                           "Make sure all required files are in the 'new' subdirectory of the configured FLS Incoming Directory.",
                           fileBEs.Count, workOrder.ControlNo)
                         );
            }
            else
            {
              m_log.Info(String.Format("{0} Not all {1} of the original files are present yet to retry control number '{2}'.",
                           methodName, fileBEs.Count, workOrder.ControlNo));
              // We are leaving the files in the new directory.  In that way, they will
              // be picked up again by the directory monitor and retried.
              RemovePendingControlNumber(controlNumber);
            }

            return;
          }
        }

        workOrder.MapFilesToArguments(fileBEs);

        // Store the new work order in the database.
        if (!workOrder.IsRetry)
        {
          workOrder.FillInControlNumber();
          workOrder.AssignTrackingId(m_configManager.OrderRegistry);
          workOrder.AssignBatchId(m_configManager.OrderRegistry);

          // Add the workorder.
          if (!m_configManager.OrderRegistry.Add(workOrder))
          {
            RejectFile(workOrder.parsedNameOfFile, associatedFiles, ERejectionReason.INTERNAL_ERROR,
                       "Failed to store new work order for file in database.");
            return;
          }
        }

        // Store the relationship between the work order and the associated files.
        // Mark the workorder as active.
        if (!m_configManager.OrderRegistry.SaveFiles(workOrder) ||
            !m_configManager.OrderRegistry.SaveState(workOrder.Instance as InvocationRecordBE, EInvocationState.ACTIVE))
        {
          // Failed to save.
          m_configManager.OrderRegistry.SaveState(workOrder.Instance as InvocationRecordBE, EInvocationState.FAILED);
          RejectFile(workOrder.parsedNameOfFile, associatedFiles, ERejectionReason.INTERNAL_ERROR,
                     "Failed to update work order in database.");
          return;
        }

        MarkFilesAsAccepted(fileBEs);

        // Form the execution command line.
        workOrder.Compile();

        // Store the command line.
        m_configManager.OrderRegistry.SaveCommand(workOrder.Instance as InvocationRecordBE, workOrder.StartInfo.FileName + " " + workOrder.StartInfo.Arguments);

        // Move the files to the inprogress directory
        MoveFiles(associatedFiles, NewDir(), InProgressDir());

        // Execute the command.
        int retCode = RunExecutable(workOrder);

        // Move the files to the done directory.
        MoveFiles(associatedFiles, InProgressDir(), DoneDir());

        if (retCode == 0)
        {
          // The job succeeded!
          workOrder.ECode = 0;
          m_configManager.OrderRegistry.SaveState(workOrder.Instance as InvocationRecordBE, EInvocationState.COMPLETED);
        }
        else
        {
          // The job failed!
          workOrder.ECode = retCode;
          m_configManager.OrderRegistry.SaveState(workOrder.Instance as InvocationRecordBE, EInvocationState.FAILED);
        }

        RemovePendingControlNumber(controlNumber);
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Store a FileBE record in the database for the given filename.
    /// If the file already exists in the database, do nothing.
    /// </summary>
    /// <param name="fullName">File to add to the database.</param>
    /// <returns>The added record or null if unsuccessful.  If unsuccessful, an error is logged.</returns>
    private static FileBE StoreFileInDatabase(string fullName)
    {
      const string methodName = "[StoreFileInDatabase]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        /// TODO: FEATURE ENHANCEMENT (Need to allow for resubmition of failed jobs)
        /// we will change the following logic to accomidate file state and allow for updates
        /// versus new entries; thus we may try only find first.

        m_configManager.FileRegistry.Add(fullName);

        FileBE fileBE = m_configManager.FileRegistry.FindByFullName(fullName);
        if (fileBE == null)
        {
          m_log.Error(string.Concat(methodName, "Unexpectedly failed to store FileBE record in database for ", fullName));
        }

        return fileBE;
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
        throw;
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    private static void StoreFilesInDatabase(List<string> filesToUse, List<FileBE> fileBEs)
    {
      const string methodName = "[StoreFileInDatabase]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        foreach (string file in filesToUse)
        {
          FileBE fileBE = StoreFileInDatabase(file);
          if (fileBE != null)
          {
            fileBEs.Add(fileBE);
          }
        }
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    #endregion

    #region Work Order Execution Helpers

    /// <summary>
    /// 
    /// </summary>
    private int RunExecutable(WorkOrder workOrder)
    {
      const string methodName = "[RunExecutable]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      string jobCommand = String.Concat(workOrder.StartInfo.FileName, " ", workOrder.StartInfo.Arguments);
      m_log.Info(String.Concat("Running ", jobCommand));
      var timeout = Math.Max(600000, m_configManager.ServiceConfiguration.TargetExecutionTimeout);

      try
      {
        int exitCode = -1;
        using (var process = new Process { StartInfo = workOrder.StartInfo })
        {
          // Pull in the preworked data

          var output = new StringBuilder();
          var error = new StringBuilder();


#if false // DUMP ENVIRONMENT VARIABLES
        System.Collections.Specialized.StringDictionary envVars = mProcess.StartInfo.EnvironmentVariables;

        foreach (string s in envVars.Keys)
        {
          Log.Info("Env: " + s + " = " + envVars[s]);
        }

#endif
          using (var outputWaitHandle = new AutoResetEvent(false))
          {
            using (var errorWaitHandle = new AutoResetEvent(false))
            {
              process.OutputDataReceived += (sender, e) =>
                                              {
                                                if (String.IsNullOrEmpty(e.Data))
                                                {
                                                  if(outputWaitHandle != null)
                                                  {
                                                    try
                                                    {
                                                      outputWaitHandle.Set();
                                                    }
                                                    catch // (ObjectDisposedException od)
                                                    {
                                                      m_log.Debug("IO delegate called after application exit");
                                                    }
                                                  }
                                                }
                                                else
                                                {
                                                  try
                                                  {
                                                    output.AppendLine(e.Data);
                                                  }
                                                  catch (Exception)
                                                  {
                                                    m_log.Debug(String.Concat("IO delegate called after application exit with message: ", e.Data));
                                                  }
                                                }
                                              };
              process.ErrorDataReceived += (sender, e) =>
                                             {
                                               if (String.IsNullOrEmpty(e.Data))
                                               {
                                                 if (errorWaitHandle != null)
                                                 {
                                                   try
                                                   {
                                                     errorWaitHandle.Set();
                                                   }
                                                   catch // (ObjectDisposedException od)
                                                   {
                                                     m_log.Debug("IO delegate called after application exit");
                                                   } 
                                                 }
                                               }
                                               else
                                               {
                                                 try
                                                 {
                                                   error.AppendLine(e.Data);
                                                 }
                                                 catch (Exception)
                                                 {
                                                   m_log.Debug(String.Concat("IO delegate called after application exit with message: ", e.Data));
                                                 }
                                               }
                                             };

              
                
              // Use try finally, allow catch to popup to next level catch statements
              // specifically the finally is used to ensure we cancel the async IO.
              // BEFORE scope exit
              try
              {
                process.Start(); 
                process.BeginOutputReadLine();
                process.BeginErrorReadLine();

                // Only run timeout on process, it possible application exist before Io was even called.
                if (process.WaitForExit(timeout))
                  // && outputWaitHandle.WaitOne(timeout) && errorWaitHandle.WaitOne(timeout))
                {
                  exitCode = process.ExitCode;
                }
                else
                {
                  // Timed out.
                  // exit code is still -1; leave it that way and set the 
                  m_log.Error(String.Format("{0} Application {1} exited stopped due to timeout", methodName, jobCommand));
                  error.Append(String.Concat("Process execution timeout of ", timeout,
                                             " reached while waiting for output."));
                }
              }
              finally
              {
                process.CancelErrorRead();
                process.CancelOutputRead();                
              }
            }
            // Finally log the output from the app
            // if there is any
            if (output.Length > 0)
            {
              HandleStdout(output);
            }
            if (error.Length > 0)
            {
              HandleStderr(error);
            }
          }
        }


        m_log.Info(String.Format("{0} Application {1} exited with code {2}",
                                 methodName, jobCommand, exitCode.ToString(CultureInfo.InvariantCulture)));
        return exitCode;

      }
      catch (Exception e)
      {
        m_log.Error(string.Concat(methodName, "An error occurred when attempting to start an executable associated with an FLS job."));
        m_log.Error(string.Concat(methodName, "The command associated with the job is: ", jobCommand));
        m_log.Error(string.Concat(methodName, "The error was: ", e.Message, ". Stack: ", e.StackTrace));
        return -1;
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }


    /// <summary>
    /// Takes the text that was written to stderr and writes it to MTLog at ERROR level.
    /// If the error message pertains to a particular file, stores the message in the database too.
    /// </summary>
    /// <param name="error">StringBuilder with the error output (StdError)</param>
    private void HandleStderr(StringBuilder error)
    {
      const string methodName = "[HandleStderr]";
      m_log.Debug(string.Concat(methodName, " - Enter"));

      try
      {
        if (!String.IsNullOrEmpty(error.ToString()))
        {
          m_log.Error(error.ToString());

          // If the error message pertains to a particular file, store it in the DB.
          // Look for this pattern at the beginning of the error message:  "FILE: <fullFileName>[:;]"
          var regex = new Regex(@"(FILE:)\s*((.:)?[^:;]+)([:;].*)");
          var match = regex.Match(error.ToString());
          if (match.Success)
          {
            // Remove the path (extraneous info) from the filename before storing the error message in the DB.
            var fullFileName = match.Groups[2].Value;
            var fileName = Path.GetFileName(fullFileName);
            var errMsg = String.Format("{0} {1}{2}", match.Groups[1].Value, fileName, match.Groups[4].Value);

            var file = m_configManager.FileRegistry.FindByName(fileName);
            if (file != null)
            {
              file._ErrorMessage = DateTime.Now.ToString("s") + "  " + errMsg;  // with sortable datetime
              m_configManager.FileRegistry.Update(file);
            }
            else
            {
              m_log.Error(String.Format("{0} Can't store error message for file '{1}' because can't find file in DB.", methodName, fileName));
            }
          }

        }
      }
      catch (Exception exception)
      {
        LogException(methodName, exception);
      }
      finally
      {
        m_log.Debug(string.Concat(methodName, " - Exit"));
      }
    }

    /// <summary>
    /// Takes the text that was written to stdout and writes it to MTLog at INFO level.
    /// </summary>
    /// <param name="stdout">Contains text written to stdout</param>
    private void HandleStdout(StringBuilder stdout)
    {
      if (!String.IsNullOrEmpty(stdout.ToString()))
      {
        m_log.Info(stdout.ToString());
      }
    }

    #endregion Work Order Execution Helpers

    /// <summary>
    /// Exception Loggin Handler
    /// </summary>
    /// <param name="methodName">The name of the method where the exception was caught.</param>
    /// <param name="exception">The exception being logged.</param>
    private static void LogException(string methodName, Exception exception)
    {
      const string nullOrEmpty = "NULL OR EMPTY";
      
      m_log.Error(string.Concat(methodName, "Exception Caught."));
      m_log.Error(string.Concat(methodName, "Exception Message:  ", string.IsNullOrEmpty(exception.Message) ? nullOrEmpty : exception.Message));
      m_log.Error(string.Concat(methodName, "Exception Stack Trace:  ", string.IsNullOrEmpty(exception.StackTrace) ? nullOrEmpty : exception.StackTrace));

      if (exception.InnerException != null)
      {
        m_log.Error(string.Concat(methodName, "Inner Exception Message:  ", string.IsNullOrEmpty(exception.Message) ? nullOrEmpty : exception.InnerException.Message));
        m_log.Error(string.Concat(methodName, "Inner Exception Stack Trace:  ", string.IsNullOrEmpty(exception.StackTrace) ? nullOrEmpty : exception.InnerException.StackTrace));
      }
    }
  }
}