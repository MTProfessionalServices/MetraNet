namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Assemblies
  ////////////////////////////////////////////////////////////////////////////////////// 
  using System;
  using System.Collections.Generic;
  using System.Diagnostics;
  using System.Threading;
  using System.Reflection;
  using System.ComponentModel;
  using System.IO;  
  using MetraTech.Basic;
  using MetraTech.Basic.Exception;
  using MetraTech.Interop.MeterRowset;

  using Core.FileLandingService;
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Interfaces
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Delegates
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Enumerations
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Classes
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region cAgent worker class
  /// <summary>
  /// The agent class is what the director dispatches
  /// to handle the processing and execution associated
  /// with a record file
  /// </summary>
  public class cAgent : IDisposable
  {
    #region Data Members
    private static readonly ILog Log = LogManager.GetLogger("MetraTech.cFileService.cAgent");

    public Object m_QLock = new Object(); // Pending Queue Lock
    public Object m_TLock = new Object(); // Thread Lock

    /// <summary>
    /// Maximum number of concurrent processes that can be active.
    /// </summary>
    private int m_MaxAllowedConcurrentProcesses { get; set; }
    /// <summary>
    /// Current number of active concurrent processes.
    /// </summary>
    private int m_ActiveConcurrentProcesses { get; set; }
    /// <summary>
    /// Resource-centric semaphore object to control the number of active processes.
    /// </summary>
    private static Semaphore m_MaxBatchPool = null; 



    /// <summary>
    /// Reference to the BME database
    /// </summary>
    cConfigurationManager m_Bmemgr = null;
    /// <summary>
    /// Handles to all started applications
    /// </summary>
    private Queue<Process> m_AppHandles = new Queue<Process>();
    /// <summary>
    /// File Registry Singleton
    /// This provides the interface to "library" or "registry"
    /// of all the candidates that have arrived, thier processing state,
    /// which targets have processed the file, and control over adding and updating
    /// the information.
    /// </summary>
    private static readonly cFileRegistry m_FileRegistry = TSingleton<cFileRegistry>.Instance;
    #endregion Data Members


    #region Constructor
    /// <summary>
    /// CTor of a Job cConfigurationManager instance
    /// It represents all the work that must be completed when
    /// a Watcher Event is tripped. Specifically, it maintains
    /// a collection of programs that must be executed in order
    /// for that event
    /// </summary>
    public cAgent(cConfigurationManager bmemgr, string directory)
    {
      // Set the Working Set
      m_directory = directory;
      m_Bmemgr = bmemgr;
      m_MaxAllowedConcurrentProcesses = bmemgr.ServiceConfiguration.MaxConcurrentTargets;

      m_WorkCallback = new WaitCallback(RunPrograms);

      // Create queue thread first
      CreateThread();
    }
    #endregion

    #region Dispose Methods
    /// <summary>
    /// Disposes all of the FileSystemWatcher objects, and disposes this object.
    /// </summary>
    public void Dispose()
    {
      Log.Debug("cAgent.Dispose()");
      if (!this.disposed)
      {
        StopQueueMonitor();
        DisposeJobs();
        this.disposed = true;
        GC.Collect();
        GC.WaitForPendingFinalizers();
      }
    }
    /// <summary>
    /// Disposes of all of the Jobs
    /// </summary>
    public void DisposeJobs()
    {
      Log.Debug("cAgent.Disposejobs()");
      lock (m_QLock)
      {
        try
        {
          cInvocationInfo job = m_PendingWork.Dequeue();
          while (job != null)
          {
            // TODO: make sure all clean up is complete
            // Note: File has not moved from watched directory, 
            // thus should be picked up on restart of service
            Log.Info("System shutting down, not processing job " + job.WorkDescription.RECORDFILE.FullName);
            job = m_PendingWork.Dequeue();
          }
        }
        catch (System.InvalidOperationException e)
        {
          // Do nothing, queue is now empty
        }
      }
      Log.Debug("cAgent.DisposeJobs() queue now empty");
    }
    #endregion Dispose Methods

    #region Helper Methods
    /// <summary>
    /// 
    /// </summary>
    /// <param value="WorkDescription"></param>
    /// <returns></returns>
    private Queue<acVerifier> SelectVerifiers(cTargetWorkInfo workOrder)
    {
      Queue<acVerifier> verifiers = new Queue<acVerifier>();
#if false
      verifiers.Enqueue(new cFileVerifier(workOrder.OldRecordName.FullName));
      verifiers.Enqueue(new cFileNameVerifier(workOrder));

      if (workOrder.MANAGER.SERVICECFG.USEMD5)
        verifiers.Enqueue(new cMD5Verifier(workOrder.RECORDFILE.FullName, "TODO"));

      if (workOrder.MANAGER.SERVICECFG.USESHA1)
        verifiers.Enqueue(new cSHA1Verifier(workOrder.RECORDFILE.FullName, "TODO"));

      if (workOrder.MANAGER.SERVICECFG.USETOKEN)
      {
        string token = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        verifiers.Enqueue(new cTokenVerifier(workOrder.RECORDFILE.FullName, "TODO", ref token));
      }
#endif
      return verifiers;
    }
    /// <summary>
    /// Sets the failed state on the file, and moves it to the failed directory
    /// </summary>
    /// <param name="fullname"></param>
    private void FailFile(string fullname)
    {
      Log.Error(String.Format("Failing {0}", fullname));
      if (!m_FileRegistry.AddStateToFile(fullname, EFileState.FAILED))
      {
        Log.Error(String.Format("Unable to set failed state on {0}", fullname));
      }
      File.Move(fullname, m_Bmemgr.ServiceConfiguration.FailedDir);
    }
    /// <summary>
    /// Sets the completed state on the file, and moves it to the completed directory
    /// </summary>
    /// <param name="fullname"></param>
    private void CompleteFile(string fullname)
    {
      Log.Info(String.Format("Completing {0}", fullname));
      if (!m_FileRegistry.AddStateToFile(fullname, EFileState.COMPLETED))
      {
        Log.Error(String.Format("Unable to set completed state on {0}", fullname));
      }
      File.Move(fullname, m_Bmemgr.ServiceConfiguration.CompletedDir);
    }
    #endregion




    /// <summary>
    /// Adding a Job requires a WorkDescription to be passed
    /// which will contain the value of the file for looking
    /// up WorkDescription specifications in the database...
    /// This is the top level to starting that work.
    /// Note that this may be called concurrently,
    /// so locking must be maintained for adding work to the queue
    /// and all other processing....
    /// Queue processing is FIFO
    /// </summary>
    /// <param value="WorkDescription"></param>
    private void AddJob(cTargetWorkInfo desc)
    {
      Log.Debug(CODE.__FUNCTION__);

      bool queued = false;
      //TODO: Deal with List capacity issues.
      lock (m_QLock)
      {
        // Must we add to the back of the line?
        if (m_PendingWork.Count > 0 || m_MaxAllowedConcurrentProcesses <= m_ActiveConcurrentProcesses)
        {
          Log.Info(String.Format("Deferred processing of {0}, max capacity is {1}, {2} is/are pending and {3} is/are currently running",
                                    desc.WorkDescription.RECORDFILE.FullName, 
                                    m_MaxAllowedConcurrentProcesses, 
                                    m_PendingWork.Count, 
                                    m_ActiveConcurrentProcesses));
          m_PendingWork.Enqueue(desc);
          queued = true;
        }
      }
      StartQueueMonitor(); // make sure it is running
      if (!queued) ThreadPool.QueueUserWorkItem(m_WorkCallback, desc);
    }

    private void HandleStderr(object sendingProcess, System.Diagnostics.DataReceivedEventArgs outLine)
    {
      if (!String.IsNullOrEmpty(outLine.Data))
      {
        Log.Error(outLine.Data);
      }
    }

    private void HandleStdout(object sendingProcess, System.Diagnostics.DataReceivedEventArgs outLine)
    {
      if (!String.IsNullOrEmpty(outLine.Data))
      {
        Log.Info(outLine.Data);
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="target"></param>
    private int RunExecutable(cTargetWorkInfo twi)
    {
      string metraFlowProgram = String.Format("{0} {1}", twi.StartInfo.FileName, twi.StartInfo.Arguments);
      Log.Info(String.Format("Running {0}", metraFlowProgram));

      string pwdFile = System.IO.Path.GetTempFileName();

      Process mProcess = null;

      try
      {
        // Write the program to a temporary file.
        string tempFile = System.IO.Path.GetTempFileName();
        using (System.IO.StreamWriter writer = new System.IO.StreamWriter(tempFile))
        {
          writer.Write(metraFlowProgram);
        }

        mProcess = new System.Diagnostics.Process();
        System.Text.StringBuilder partitionListParameters = new System.Text.StringBuilder();
        System.Collections.Generic.Dictionary<string, int> hosts = new System.Collections.Generic.Dictionary<string, int>();

#if false
        // TODO: Add these type of info to the script configuration data
        if (metraFlowConfig != null)
        {
          for (int i = 0; i < metraFlowConfig.NumHosts; i++)
          {
            // Hostnames are case insensitive so conver to upper case.
            string upperHost = metraFlowConfig.GetHost(i).ToUpper();
            if (hosts.ContainsKey(upperHost))
              hosts[upperHost] = hosts[upperHost] + 1;
            else
              hosts.Add(upperHost, 1);
          }

          for (int j = 0; j < metraFlowConfig.NumPartitionLists; j++)
          {
            IMetraFlowPartitionList plist = metraFlowConfig.GetPartitionList(j);
            System.Text.StringBuilder listBuilder = new System.Text.StringBuilder();
            for (int k = 0; k < plist.NumPartitions; k++)
            {
              if (listBuilder.Length > 0)
                listBuilder.Append(",");
              listBuilder.Append(plist.GetPartition(k).ToString());
            }
            partitionListParameters.AppendFormat(" --partition-list \"{0}[{1}]\" ", plist.Name, listBuilder.ToString());
          }
        }
#endif
        string upperMachineName = System.Environment.MachineName.ToUpper();

        if (hosts.Count == 0)
        {
#if false
          mProcess.StartInfo.FileName = "MetraFlowShell.exe";
          mProcess.StartInfo.Arguments = string.Format(System.Globalization.CultureInfo.InvariantCulture,
                                                       "--partitions 1 {1} \"{0}\"",
                                                       tempFile,
                                                       partitionListParameters.ToString());
#endif
        }
#if false
        else
        {
          // Cons up the mpiexec string, make sure local machine name appears and is the first
          // process so we can pass it the program as a file.
          if (!hosts.ContainsKey(upperMachineName))
          {
            Log.Warn("MetraFlow configuration does not contain Billing Server machine name.  Adding to configuration and continuing");
            hosts.Add(upperMachineName, 1);
          }

          // Check for existence of a MetraFlow username and password.
          // When running as a service we really have to use these since
          // LocalSystem won't have credentials to run.
          string pwdOption = "";
          ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
          sa.Initialize();
          ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObjectIfExists("MetraFlowUser");
          if (accessData != null)
          {
            using (System.IO.StreamWriter writer = new System.IO.StreamWriter(pwdFile))
            {
              writer.WriteLine(accessData.UserName);
              writer.WriteLine(accessData.Password);
            }

            pwdOption = string.Format(System.Globalization.CultureInfo.InvariantCulture,
                                      "-pwdfile \"{0}\"", pwdFile);
          }

          mProcess.StartInfo.FileName = "mpiexec.exe";
          System.Text.StringBuilder sb = new System.Text.StringBuilder();
          sb.AppendFormat("-noprompt {3} -channel mt -n {0} -host {1} MetraFlowShell.exe {4} \"{2}\"",
                          hosts[upperMachineName],
                          upperMachineName,
                          tempFile,
                          pwdOption,
                          partitionListParameters.ToString());

          foreach (System.Collections.Generic.KeyValuePair<string, int> kvp in hosts)
          {
            if (kvp.Key != upperMachineName)
              sb.AppendFormat(" : -n {0} -host {1} MetraFlowShell.exe", kvp.Value, kvp.Key);
          }
          mProcess.StartInfo.Arguments = sb.ToString();
        }
#endif
        // Pull in the preworked data
        mProcess.StartInfo = twi.StartInfo;

        // Set up async handlers to write stdout and stderr to log file.
        mProcess.OutputDataReceived += new DataReceivedEventHandler(HandleStdout);
        mProcess.ErrorDataReceived += new DataReceivedEventHandler(HandleStderr);

#if false // DUMP ENVIRONMENT VARIABLES
        System.Collections.Specialized.StringDictionary envVars = mProcess.StartInfo.EnvironmentVariables;

        foreach (string s in envVars.Keys)
        {
          Log.Info("Env: " + s + " = " + envVars[s]);
        }

#endif
        mProcess.Start();

        mProcess.BeginOutputReadLine();
        mProcess.BeginErrorReadLine();

        // If we're redirecting the file to the standard input stream, open it up
        // and read its contents into the stream in 1 KB chunks
        if (twi.Target.RedirectFileToStdin)
        {
          BinaryReader binaryReader = new BinaryReader(File.Open(Path.Combine(twi.Target.Path, twi.Target.Name), FileMode.Open));
          BinaryWriter binaryWriter = new BinaryWriter(mProcess.StandardInput.BaseStream);
          byte[] buffer = new byte[1024];
          int readSize = binaryReader.Read(buffer, 0, buffer.Length);

          while (readSize != 0)
          {
            binaryWriter.Write(buffer, 0, readSize);
            readSize = binaryReader.Read(buffer, 0, buffer.Length);
          }
          binaryReader.Close();
          binaryWriter.Close();
        }

        if (hosts.Count == 0)
        {
          mProcess.StandardInput.Write(metraFlowProgram);
        }
        mProcess.StandardInput.Close();

        mProcess.WaitForExit();
        int exitCode = mProcess.ExitCode;
        Log.Info(String.Format("Application {0} exited with code {1}", exitCode.ToString()));
        mProcess.Close();

        System.IO.File.Delete(tempFile);

        return exitCode;
      }
      catch (System.Exception e)
      {
        Log.Error(e.StackTrace);
        return -1;
      }
      finally
      {
        // Never leave this puppy around!
        System.IO.File.Delete(pwdFile);
      }
    }

    /// <summary>
    /// Runs a specified list of processes, one after the other.
    /// </summary>
    /// <param name="source">
    /// List containing ExecutionInstance objects for each process.
    /// </param>
    public void RunPrograms(object data)
    {
      cInvocationInfo job = data as cInvocationInfo;

      // Based off the work order information encoded into
      // the BME entry, we need to select the appropriate verifiers
      Queue<acVerifier> verifiers = SelectVerifiers(job.WorkDescription);
      foreach (acVerifier qualifier in verifiers)
      {
        if (!qualifier.Verify())
        {
          Log.Error(qualifier.Name + " did not pass. Stopping processing of " + job.WorkDescription.RECORDFILE.FullName);
          return;
        }
      }

#if false // KEEP IN CASE WE NEED TO EXPAND TO SUPPORT CREATE EVENTS

      // If we're watching for a create event, we first try to open the file in exclusive 
      // mode. This ensures we don't pick up the file before the writer (ftp for example) is completed
      // actually writing the file, before firing off events.
      if (job.Event == EEventFilterType.CREATED)
      {
        FileStream fileStream = null;

        while (fileStream == null)
        {
          try
          {
            fileStream = File.Open(job.WorkDescription.RECORDFILE.FullName, FileMode.Open, FileAccess.Read, FileShare.None);
          }
          // Catch the IOException that will be thrown when we fail to open the file in 
          // exclusive mode
          catch (IOException exception)
          {
            string warningTrap = exception.Message;
            Thread.Sleep(1000);
          }

          // Log any other unhandled exceptions that are thrown
          catch (Exception exception)
          {
            Log.Error(String.Format("Unhandled exception occurred while waiting for \"{0}\" to become available.\n\nType: {1}\nMessage:\n{2}",
                      job.WorkDescription.RECORDFILE.FullName,
                      exception.GetType().FullName,
                      exception.Message));
          }
        }
        fileStream.Close();
      }
#endif
      // Claim a resource from the counting semaphore and enter the critical section
      m_MaxBatchPool.WaitOne();
m_MaxBatchPool.W

      foreach (cTargetWorkInfo twi in job.Phases)
      {
        try
        {
          // If we're running a pre-compiled application, start the process
          if (twi.Target.EventHandler == null)
          {
            int returncode = 0; 
            // Set up state so we can mark all candidates with same state...
            FileStateBE state = new FileStateBE();
            state._Time = DateTime.Now;
            if (0 == (returncode = RunExecutable(twi)))
            {
              state._State = EFileState.COMPLETED;
            }
            else
            {
              state._State = EFileState.FAILED;
            }
            state._ErrorCode = returncode; 
            twi.Target.Arguments.ForEach(delegate(cArgument a) 
              {
                if (null != twi.ArgumentFileMap[a])
                {
                  m_FileRegistry.AddStateToFile(twi.ArgumentFileMap[a], state);
                  // TODO: Move File to the correct directory
                  // File.Move(twi.ArgumentFileMap[a].BusinessKey._FullName, this.m_ServiceDefinitions[0].Directories
                }
              });

          }

#if false // TODO: Add support for notification to external (in memory) assemblies

          // Otherwise, invoke the OnFileSystemEvent() method for the handler class 
          // defined in the runtime-compiled code
          else
          {
            WriteToEventLog(EventLogEntryType.Information, "Invoking {0}.OnFileSystemEvent() in response to event for {1} being {2}.", executionInstance.EventHandler.GetType().Name, executionInstance.FilePath, executionInstance.EventType.ToString().ToLower());

            WatcherExtEventArgs eventArgs = new WatcherExtEventArgs(job.WorkDescription.WATCHER, null, nuke);
            FileSystemEventArgs eventArguments = new FileSystemEventArgs(executionInstance.EventType, fileInfo.DirectoryName, fileInfo.Name);

            executionInstance.EventHandler.OnFileSystemEvent(eventArgs);
          }
#endif
        }
        // Log any exceptions that occur while running the program
        catch (Exception exception)
        {
          Log.Error(String.Format("Exception occurred while running {0}.\n\nType: {1}\nMessage:\n{2}", 
            (twi.StartInfo != null ? "\"" + twi.StartInfo.FileName + "\"" : twi.Target.EventHandler.GetType().Name + ".OnFileLandingEvent()"), 
            exception.GetType().FullName, 
            exception.Message));
        }
      }
      // Release the resource and exit the critical section
      m_MaxBatchPool.Release();
    }

    /// <summary>
    /// Writes a formatted string message to the event log.
    /// </summary>
    /// <param name="messageType">
    /// Event log entry type for this message.
    /// </param>
    /// <param name="message">
    /// String.Format() compatible string representing the contents of the message.
    /// </param>
    /// <param name="arguments">
    /// Arguments, if any, to pass into String.Format() along with the message parameter.
    /// </param>
    protected static void WriteToEventLog(EventLogEntryType messageType, string message, params object[] arguments)
    {
      message = String.Format(message, arguments);

      EventLog eventLog = new EventLog("Application", Environment.MachineName, "Directory Watcher");
      eventLog.WriteEntry(message, messageType);
    }

    /// <summary>
    /// Validates an assembly generated from runtime-compiled code; makes sure that there is
    /// one and only one class that implements the IFileLandingEventHandler interface.
    /// </summary>
    /// <param name="assembly">
    /// Assembly object that we are to check.
    /// </param>
    protected static void ValidateAssembly(Assembly assembly)
    {
      FindEventHandlerType(assembly);
    }

    /// <summary>
    /// Creates an instance of the event handler class (class that implements the 
    /// IFileLandingEventHandler interface) that's defined in a snippet of runtime-compiled 
    /// code.
    /// </summary>
    /// <param name="assembly">
    /// Assembly containing a handler class.
    /// </param>
    /// <returns>
    /// An instance of the event handler class.
    /// </returns>
    protected static IFileLandingEventHandler CreateEventHandlerInstance(Assembly assembly)
    {
      Type eventHandlerType = FindEventHandlerType(assembly);
      return (IFileLandingEventHandler)Activator.CreateInstance(eventHandlerType);
    }
    /// <summary>
    /// Searches an assembly for a type that implements the IFileLandingEventHandler interface 
    /// and throws exceptions if more or less than one are found.
    /// </summary>
    /// <param name="assembly">
    /// Assembly object that we are to search.
    /// </param>
    /// <returns>
    /// The Type object for the class that implements IFileLandingEventHandler.
    /// </returns>
    protected static Type FindEventHandlerType(Assembly assembly)
    {
      Type eventHandlerType = null;

      foreach (Type t in assembly.GetTypes())
      {
        if (null != t.GetInterface("IFileLandingEventHandler"))
        {
          // If we've already found a qualifying type, then throw an exception
          if (null != eventHandlerType)
            throw new ArgumentException(String.Format("Multiple classes implementing IFileLandingEventHandler were found in {0}.", assembly.FullName));

          eventHandlerType = t;
        }
      }

      // If no qualifying types were found, then throw an exception
      if (null == eventHandlerType)
        throw new ArgumentException(String.Format("No classes implementing IFileLandingEventHandler were found in {0}.", assembly.FullName));

      return eventHandlerType;
    }
  
  } 
  #endregion
}
