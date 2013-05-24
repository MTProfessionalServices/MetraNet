namespace MetraTech.UsageServer.Service
{
	using System;
	using System.Threading;
	using System.Collections;
  using System.Xml;

	using MetraTech.DataAccess;
	using MetraTech.Xml;
	using Auth = MetraTech.Interop.MTAuth;
	using ServerAccess = MetraTech.Interop.MTServerAccess;
  using System.Collections.Generic;

	public class Processor
	{
				/// <summary>
		/// Starts the processing
		/// </summary>
    public void Start()
		{
      Start(null);
		}

	  /// <summary>
		/// Starts the processing
		/// </summary>
		public void Start(string machineIdentifier)
		{
      Start(machineIdentifier, null);
    }

    public void Start(string machineIdentifier, ProcessingConfig processingConfiguration)
    {

			try 
			{
        //Set the machine identifier
        if (string.IsNullOrEmpty(machineIdentifier))
          machineIdentifier = System.Environment.MachineName;

        mProcessingConfiguration = processingConfiguration;

				mLogger = new Logger("[UsageServer]");
        mLogger.LogInfo(string.Format("Starting Billing Server service ({0})", machineIdentifier));
        
        mServiceTracking = new BillingServerServiceTracking(machineIdentifier);
				mClient = new Client(machineIdentifier);

				// sets the SU session context on the client
				Auth.IMTLoginContext loginContext = new Auth.MTLoginContextClass();
				ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
				sa.Initialize();
				ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
				string suName = accessData.UserName;
				string suPassword = accessData.Password;
				
				Auth.IMTSessionContext sessionContext = loginContext.Login(suName, "system_user", suPassword);
				mClient.SessionContext = sessionContext;

				mHaltCallback = new HaltProcessingCallback();
				mHaltCallback.IsShuttingDown = false;
				mHaltCallback.IsAbortable = false;

			  try
			  {
          mServiceTracking.RecordStart();
			  }
			  catch (ServiceTrackingException)
			  {
			    //Machine identifier is already marked as being online
          //For now, assume this was faulty shutdown, repair the table and restart
          mLogger.LogWarning("A service is already marked as running with the machine identifier {0}. This service will forcibly remove the entry in the database.", mServiceTracking.MachineIdentifier );
			    mServiceTracking.Repair();
          mServiceTracking.RecordStart();
			  }

				// No need to acquire mConfigLock here, since at this point
				// there is just one lonely thread
				LoadConfig();

				// sets the next daily trigger
				CalculateNextDailyTrigger();

				// creates and starts the timer threads
				mGeneralTimerThread = new Thread(new ThreadStart(GeneralTimerThreadStart));
				mGeneralTimerThread.Name = "General Timer Thread";
				mGeneralTimerThread.SetApartmentState(ApartmentState.MTA);

				mProcessRecurringEventsTimerThread = new Thread(new ThreadStart(ProcessRecurringEventsTimerThreadStart));
				mProcessRecurringEventsTimerThread.Name = "Process Recurring Events Timer Thread";
				mProcessRecurringEventsTimerThread.SetApartmentState(ApartmentState.MTA);

        if (mRecordServiceHeartbeatTimerPeriod != 0)
        {
          mRecordServiceHeartBeatThread = new Thread(new ThreadStart(ProcessServiceHeartbeatTimerThreadStart));
          mRecordServiceHeartBeatThread.Name = "Billing Server Heartbeat Thread";
          mRecordServiceHeartBeatThread.SetApartmentState(ApartmentState.MTA); //Probably not necessary
        }

				// detects and fails zombie events
        RecurringEventManager eventManager = new RecurringEventManager(machineIdentifier);
				eventManager.FailZombieEvents();

				mGeneralTimerThread.Start();
				mProcessRecurringEventsTimerThread.Start();

        if (mRecordServiceHeartbeatTimerPeriod != 0)
        {
          mRecordServiceHeartBeatThread.Start();
        }
        else
        {
          WriteConsoleAndLogFile(LogLevel.Debug, "Heartbeat recording and checking is turned of on this server");
        }

				mLogger.LogInfo("Billing Server service has been started");
			}
			catch (UsageServerException)
			{
				mLogger.LogError("Billing Server service failed to start!");
				throw;
			}
			catch (Exception e)
			{
				throw new UsageServerException("Billing Server service failed to start!", e);
			}
		}

		
		/// <summary>
		/// Stops the processing
		/// NOTE: if OnStart fails, OnStop will be called automatically by the ServiceBase
		/// since we aren't sure where OnStart failed, null references must be guarded against
		/// </summary>
		public void Stop()
		{
			try 
			{
				mLogger.LogInfo("Stopping Billing Server service");
				
				// users of the HaltProcessingCallback will now receive
				// notifcation of the impending shutdown
				if (mHaltCallback != null)
					mHaltCallback.IsShuttingDown = true;

				// waits for the timer threads to finish what they are doing
				if (mGeneralTimerThread != null)
				{
					mLogger.LogDebug("Waiting for general timer thread to finish");
					mGeneralTimerThread.Interrupt();
					mGeneralTimerThread.Join();
					mLogger.LogDebug("General timer thread has finished");
				}

				// NOTE: if an adapter is currently running, this will wait until that adapter finishes
				if (mProcessRecurringEventsTimerThread != null)
				{
					mLogger.LogDebug("Waiting for recurring event processing thread to finish");
					SafelyInterruptProcessRecurringEventsTimerThread();
					mProcessRecurringEventsTimerThread.Join();
					mLogger.LogDebug("Recurring event processing thread has finished");
				}

        // Indicate heartbeat thread should wake up and exit
        if (mRecordServiceHeartBeatThread != null)
        {
          mLogger.LogDebug("Waiting for service heartbeat thread to finish");
          mRecordServiceHeartbeatTimerThreadEvent.Set();
          mRecordServiceHeartBeatThread.Join();
          mLogger.LogDebug("Service heartbeat thread has finished");
        }

        if (mServiceTracking != null)
        {
          mServiceTracking.RecordStop();  
        }

				mLogger.LogInfo("Billing Server service has been stopped");
			}
			catch (UsageServerException)
			{
				mLogger.LogError("Billing Server service failed to stop!");
				throw;
			}
			catch (Exception e)
			{
				throw new UsageServerException("Billing Server service failed to stop!", e);
			}
		}

		
		/// <summary>
		/// Reloads configuration settings from the config file
		/// </summary>
		public void RefreshConfig()
		{
			mLogger.LogInfo("Refreshing configuration settings upon request");

			try
			{
				// synchronized access to shared state is crucial since
				// the timer threads may actively be reading from these variables
				lock (mConfigLock)
				{
					DayChange = null;
					mScheduledEventsTimers.Clear();
					
					LoadConfig();
				}
				
				// forces the recurring events timer thread to wake up and start
				// using the new period duration
				SafelyInterruptProcessRecurringEventsTimerThread();
			}
			catch (Exception e)
			{
				throw new UsageServerException("Billing Server service could not refresh its configuration!", e);
			}
		}

		/// <summary>
		/// Signals the service to immediately process recurring events
		/// </summary>
		public void ProcessRecurringEvents()
		{
			mLogger.LogInfo("Processing recurring events upon request");

			try
			{
				SafelyInterruptProcessRecurringEventsTimerThread();
			}
			catch (Exception e)
			{
				throw new UsageServerException("Billing Server service could not process recurring events upon request!", e);
			}
		}

		/// <summary>
		/// Attempts to kill the recurring event currently being processed
		/// </summary>
		public void KillRecurringEvent()
		{
			mLogger.LogInfo("Attempting to kill the recurring event currently being processed");

			try
			{
				lock (mHaltCallback)
				{
					if (mHaltCallback.IsAbortable)
						mProcessRecurringEventsTimerThread.Abort();
					else
						mLogger.LogInfo("No recurring event was being processed when the kill was requested! No action was taken.");
				}
			}
			catch (Exception e)
			{
				throw new UsageServerException("The recurring event could not be killed!", e);
			}
		}

    private void LoadConfig()
    {
      LoadLocalServerConfig();
      LoadCrossServerConfig();
      SynchronizeConfigWithDatabase();
      InitializeInternalEventsFromConfig();
    }


    private int DetermineIfHousekeepingTasksHaveChanged()
    {
      int countEventsChanged = 0;

      try
      {
        countEventsChanged = SynchronizeHousekeepingTasksWithOtherServers();

        //If the events have changed, need to update our internal events
        if (countEventsChanged > 0)
          InitializeInternalEventsFromConfig();
      }
      catch (Exception ex)
      {
        WriteConsoleAndLogFile(LogLevel.Error, "Unable to DetermineIfHousekeepingTasksHaveChanged. Unhandled exception: {0} \nStack Trace:{1}", ex.Message, ex.StackTrace);
        WriteConsoleAndLogFile(LogLevel.Error, "DetermineIfHousekeepingTasksHaveChanged being skipped and continueing on.");
      }

      return countEventsChanged;
    }

    private int SynchronizeHousekeepingTasksWithOtherServers()
    {
      if (mServiceTracking == null)
      {
        throw new Exception("Service tracking object not initialized in the service. Shutting down.");
      }

      //Notify the system as to what events this service can perform and update the current local config based on the settings
      bool willInstantiateScheduledEvents;
      bool willCreateIntervals;
      bool willSoftCloseIntervals;

      mServiceTracking.UpdateTaskConfigAndRetrieveTaskSettings(mConfigServiceCanInstantiateScheduledEvents, mConfigServiceCanCreateIntervals, mConfigServiceCanSoftCloseIntervals,
                                                               out willInstantiateScheduledEvents, out willCreateIntervals, out willSoftCloseIntervals);

      int countChangedEvents = 0;

      //Update InstantiateScheduledEvents
      //Record if this has changed from the previous setting
      if (mInstantiateScheduledEvents != willInstantiateScheduledEvents)
      {
        countChangedEvents++;
        WriteConsoleAndLogFile(LogLevel.Debug, "InstantiateScheduledEvents setting has changed from [{0}] to [{1}] after coordinating with system.", mInstantiateScheduledEvents, willInstantiateScheduledEvents);
      }

      //Log if this is different from the xml file
      if (mConfigServiceCanInstantiateScheduledEvents != willInstantiateScheduledEvents)
        WriteConsoleAndLogFile(LogLevel.Debug, "InstantiateScheduledEvents overridden from the value in xml to [{0}] after coordinating with system.", willInstantiateScheduledEvents);
      
      mInstantiateScheduledEvents = willInstantiateScheduledEvents;


      //Update CreateIntervals
      //Record if this has changed from the previous
      if (mCreateIntervals != willCreateIntervals)
      {
        countChangedEvents++;
        WriteConsoleAndLogFile(LogLevel.Debug, "CreateIntervals setting has changed from [{0}] to [{1}] after coordinating with system.", mCreateIntervals, willCreateIntervals);
      }

      //Log if this is different from the xml file
      if (mConfigServiceCanCreateIntervals != willCreateIntervals)
        WriteConsoleAndLogFile(LogLevel.Debug, "CreateIntervals overridden from the value in xml to [{0}] after coordinating with system.", willCreateIntervals);

      mCreateIntervals = willCreateIntervals;

      //Update SoftCloseIntervals
      //Record if this has changed from the previous
      if (mSoftCloseIntervals != willSoftCloseIntervals)
      {
        countChangedEvents++;
        WriteConsoleAndLogFile(LogLevel.Debug, "SoftCloseIntervals setting has changed from [{0}] to [{1}] after coordinating with system.", mSoftCloseIntervals, willSoftCloseIntervals);
      }

      //Log if this is different from the xml file
      if (mConfigServiceCanSoftCloseIntervals != willSoftCloseIntervals)
        WriteConsoleAndLogFile(LogLevel.Debug, "SoftCloseIntervals overridden from the value in xml to [{0}] after coordinating with system.", willSoftCloseIntervals);

      mSoftCloseIntervals = willSoftCloseIntervals;

      return countChangedEvents;
    }

    private void SynchronizeConfigWithDatabase()
    {
      SynchronizeHousekeepingTasksWithOtherServers();

      //Update additional config settings in the database table
      //These settings are mainly for reporting/display and for possible future changes to stored procedures
      //to make more informed choices/decisions
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\UsageServer", "__UPDATE_BILLINGSERVER_SERVICE_CONFIG__"))
        {
          stmt.AddParam("%%MaxConcurrentAdapters%%", mMaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine);
          stmt.AddParam("%%OnlyRunAssignedAdapters%%", mOnlyRunAdaptersExplicitlyAssignedToThisMachine ? "Y" : "N");
          stmt.AddParam("%%ProcessEventsPeriod%%", mProcessEventsTimerPeriod);
          stmt.AddParam("%%TX_MACHINE%%", mServiceTracking.MachineIdentifier);
          stmt.ExecuteNonQuery();
        }
      }
    }

    private void InitializeInternalEventsFromConfig()
    {
      try
      {
        // synchronized access to shared state is crucial since
        // the timer threads may actively be reading from these variables
        lock (mConfigLock)
        {
          //First clear our events
          DayChange = null;
          mScheduledEventsTimers.Clear();

          //Second, recreate the needed events
          mLogger.LogDebug(string.Format("Initializing Events for this service..."));
          // <InstantiateScheduledEvents>True</InstantiateScheduledEvents>
          if (mInstantiateScheduledEvents)
          {
            mLogger.LogDebug("InstantiateScheduledEvents : True");
            //DayChange += new DayChangeEventHandler(InstantiateDailyScheduledEvents);
            LoadScheduledEvents();
          }
          else
            mLogger.LogDebug("InstantiateScheduledEvents : False");

          //// <CreateIntervals>True</CreateIntervals>
          if (mCreateIntervals)
          {
            mLogger.LogDebug("CreateIntervals            : True");
            DayChange += new DayChangeEventHandler(CreateIntervals);
          }
          else
            mLogger.LogDebug("CreateIntervals            : False");

          // <SoftCloseIntervals blockNewAccounts="TRUE">True</SoftCloseIntervals>
          if (mSoftCloseIntervals)
          {
            mLogger.LogDebug("SoftCloseIntervals         : True");
            DayChange += new DayChangeEventHandler(CloseIntervals);
          }
          else
            mLogger.LogDebug("SoftCloseIntervals         : False");
        }

        mLogger.LogDebug(string.Format("Completed Initializing Events for service"));

      }
      catch (Exception e)
      {
        throw new UsageServerException("Billing Server service could not refresh its configuration!", e);
      }
    }

		/// <summary>
		/// Loads local configuration settings from the usageserver.xml
		/// NOTE: a writer lock must be acquired from mConfigLock before calling this method!
		/// </summary>
		private void LoadLocalServerConfig()
		{
			Console.WriteLine("Loading local configuration settings from usageserver.xml...");
			mLogger.LogDebug("Loading local BillingServer service configuration settings from usageserver.xml");
			
			MTXmlDocument doc = new MTXmlDocument();
			doc.LoadConfigFile(@"UsageServer\usageserver.xml");
			
			// <version>2</version>
			int version  = doc.GetNodeValueAsInt("/xmlconfig/version");
			if (version < 2)
				throw new UsageServerException("Billing Server service requires at least version 2 of the usageserver.xml config file. " +
																			 "Please upgrade this file!");
			
			decimal minutes  = doc.GetNodeValueAsDecimal("/xmlconfig/Service/ProcessEventsPeriod");
			mLogger.LogDebug("ProcessEventsPeriod        : {0} minutes", minutes);
			mProcessEventsTimerPeriod = (int) (minutes * 60 * 1000);



			// <DailyTriggerTime>05:00:00</DailyTriggerTime>
			mDailyTriggerTime = doc.GetNodeValueAsDateTime("/xmlconfig/Service/DailyTriggerTime").TimeOfDay;
			mLogger.LogDebug("DailyTriggerTime           : {0}", mDailyTriggerTime);

      // <InstantiateScheduledEvents>True</InstantiateScheduledEvents>
      mConfigServiceCanInstantiateScheduledEvents = doc.GetNodeValueAsBool("/xmlconfig/Service/InstantiateScheduledEvents");
      mLogger.LogDebug("Service can InstantiateScheduledEvents : {0}", mInstantiateScheduledEvents);

      // <SoftCloseIntervals blockNewAccounts="TRUE">True</SoftCloseIntervals>
      mConfigServiceCanSoftCloseIntervals = doc.GetNodeValueAsBool("/xmlconfig/Service/SoftCloseIntervals");
      mLogger.LogDebug("Service can SoftCloseIntervals : {0}", mInstantiateScheduledEvents);

      // <CreateIntervals>True</CreateIntervals>
      mConfigServiceCanCreateIntervals = doc.GetNodeValueAsBool("/xmlconfig/Service/CreateIntervals");
      mLogger.LogDebug("Service can CreateIntervals : {0}", mCreateIntervals);

		  // <SubmitForExecutionAfterInstantiation>True</SubmitForExecutionAfterInstantiation>
			mSubmitAfterInstantiation = doc.GetNodeValueAsBool("/xmlconfig/Service/SubmitForExecutionAfterInstantiation");
			mLogger.LogDebug("SubmitForExecutionAfterInstantiation : {0}", mSubmitAfterInstantiation);

			// <SubmitCheckpointsForExecution>True</SubmitCheckpointsForExecution>
			mSubmitCheckpoints = doc.GetNodeValueAsBool("/xmlconfig/Service/SubmitCheckpointsForExecution");
			mLogger.LogDebug("SubmitCheckpointsForExecution : {0}", mSubmitCheckpoints);
			
			mInitialDelay       = 10 * 1000;  // 15 seconds (in ms)
			mGeneralTimerPeriod = 60 * 1000;  // 1 minute  (in ms)

      //<MaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine>3</MaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine>
		  try
		  {
        mMaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine = doc.GetNodeValueAsInt("/xmlconfig/Service/MaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine");
		  }
		  catch (Exception)
		  {
		    WriteConsoleAndLogFile(LogLevel.Debug,string.Format(
		        "MaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine not specified in config; using default of {0}",
		        mMaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine));
		  }

      try
      {
        mOnlyRunAdaptersExplicitlyAssignedToThisMachine = doc.GetNodeValueAsBool("/xmlconfig/Service/OnlyRunAdaptersExplicitlyAssignedToThisMachine");
      }
      catch (Exception)
      {
        WriteConsoleAndLogFile(LogLevel.Debug, string.Format(
            "OnlyRunAdaptersExplicitlyAssignedToThisMachine not specified in config; using default of {0}",
            mOnlyRunAdaptersExplicitlyAssignedToThisMachine));
      }

      //Configurable heartbeat period
      decimal minutesHeartbeat;
      try
      {
        minutesHeartbeat = doc.GetNodeValueAsDecimal("/xmlconfig/Service/HeartbeatPeriod");
      }
      catch(Exception)
      {
        minutesHeartbeat = 5;
        WriteConsoleAndLogFile(LogLevel.Debug, "HeartbeatPeriod not specified in config; using default of {0} minutes", minutesHeartbeat);
      }
      mLogger.LogDebug("HeartbeatPeriod        : {0} minutes", minutesHeartbeat);
      mRecordServiceHeartbeatTimerPeriod = (int)(minutesHeartbeat * 60 * 1000);

      if (mRecordServiceHeartbeatTimerPeriod==0)
        WriteConsoleAndLogFile(LogLevel.Debug, "Heartbeat generation and heartbeat checking from this machine have been turned off");

			Console.WriteLine("Configuration successfully loaded from file");
		}

    /// <summary>
    /// Loads cross-server configuration settings from the database.
    /// </summary>
    private void LoadCrossServerConfig()
    {
      Console.WriteLine("Loading configuration settings from database...");
      mLogger.LogDebug("Loading cross-server BillingServer service configuration settings from the database.");

      ConfigCrossServer config = ConfigCrossServerManager.GetConfig();
      mGlobalSettings = config;

      //// InstantiateScheduledEvents Setting
      //mConfigInstantiateScheduledEvents = config.isRunScheduledAdaptersEnabled;
      //mLogger.LogDebug("InstantiateScheduledEvents : {0}", mConfigInstantiateScheduledEvents);

      //// SoftCloseIntervals setting
      //mConfigSoftCloseIntervals = config.isAutoSoftCloseBillGroupsEnabled;

      //if (mConfigSoftCloseIntervals)
      //{
      //  mBlockNewAccounts = config.isBlockNewAccountsWhenClosingEnabled;
      //  mLogger.LogDebug("SoftCloseIntervals         : True");
      //  mLogger.LogDebug("BlockNewAccounts           : {0}", mBlockNewAccounts);
      //}
      //else
      //{
      //  mLogger.LogDebug("SoftCloseIntervals         : False");
      //}

      //// SubmitEventsForExecution setting
      //if (config.isAutoRunEopOnSoftCloseEnabled)
      //{
      //  mLogger.LogDebug("SubmitEventsForExecution   : True");
      //  DayChange += new DayChangeEventHandler(SubmitEventsForExecution);
      //}
      //else
      //  mLogger.LogDebug("SubmitEventsForExecution   : False");

      Console.WriteLine("Configuration successfully loaded from database.");
    }



    /// <summary>
    /// For troubleshooting/debugging, it is useful to have information written to the console
    /// This helper method writes both to the console and to the log file
    /// </summary>
    /// <param name="logLevel"></param>
    /// <param name="messageFormat"></param>
    /// <param name="args"></param>
    private void WriteConsoleAndLogFile(LogLevel logLevel, string messageFormat, params object[] args)
    {
      if (args == null)
        args = new object[0];


      string message = String.Format(messageFormat, args);

      Console.WriteLine("[{0}] {1}", logLevel, message);

      switch (logLevel)
      {
        case LogLevel.Fatal:
          mLogger.LogFatal(message);
          break;
        case LogLevel.Error:
          mLogger.LogError(message);
          break;
        case LogLevel.Warning:
          mLogger.LogWarning(message);
          break;
        case LogLevel.Info:
          mLogger.LogInfo(message);
          break;
        case LogLevel.Debug:
          mLogger.LogDebug(message);
          break;
        default:
          mLogger.LogDebug(message);
          break;
      }
    }
    private void WriteConsoleAndLogFile(LogLevel logLevel, string message)
    {
      WriteConsoleAndLogFile(logLevel, message, null);
    }

    private void ProcessServiceHeartbeatTimerThreadStart()
    {
      Thread.Sleep(mInitialDelay);

      try
      {
        while (true)
        {
          //Record our heartbeat
          this.WriteConsoleAndLogFile(LogLevel.Debug, "Recording service heartbeat to indicate we are still alive");
          this.mServiceTracking.RecordHeartbeat(mRecordServiceHeartbeatTimerPeriod/1000/60*2); //We promise twice the time

          //Check for other servers that have that have gone offline unexpectedly
          List<string> machinesThatMissedHeartbeat = ServiceTracking.GetMachinesThatMissedHeartbeat();
          if (machinesThatMissedHeartbeat.Count > 0)
          {
            foreach(string machineIdentifier in machinesThatMissedHeartbeat)
            {
              this.WriteConsoleAndLogFile(LogLevel.Warning, "The machine {0} has missed its heart beat check and is not responding. It is being marked as offline.", machineIdentifier);
              ServiceTracking.MarkMachineAsOffline(machineIdentifier);

              //Now fail any events the machine had running
              int zombieEvents = RecurringEventManager.FailZombieEvents(machineIdentifier);
              if (zombieEvents > 0)
              {
                this.WriteConsoleAndLogFile(LogLevel.Warning, "{0} events were detected as running on machine {1} which has stopped responded. These events were marked as failed", zombieEvents, machineIdentifier);
              }
            }
          }

          //Check if any tasks need to be taken over by this machine
          //Not part of heartbeat checking but a convenient place/time to perform this check
          DetermineIfHousekeepingTasksHaveChanged();
          
          // handles a request to shutdown while the thread was not sleeping
          lock (mHaltCallback)
          {
            if (mHaltCallback.IsShuttingDown)
            {
              this.mServiceTracking.StopRecordingHeartbeat();
              break;
            }
          }

          try
          {
            this.mRecordServiceHeartbeatTimerThreadEvent.WaitOne(mRecordServiceHeartbeatTimerPeriod, false);

            if (mHaltCallback.IsShuttingDown)
            {
              // shutting down, just exit
              this.mServiceTracking.StopRecordingHeartbeat();
              break;
            }
          }
          catch (ThreadAbortException)
          {
            // this should have been caught in RecurringEventManager::InvokeEvents
            // if we see this, there is a bug!
            mLogger.LogError("Thread abort was not handled properly");
            Thread.ResetAbort();
            continue;
          }
          catch (Exception e)
          {
            mLogger.LogException("Unexpected exception caught waiting in ServiceHeartbeatTimerThreadStart", e);
          }
        }
      }
      catch (Exception e)
      {
        mLogger.LogError("An unhandled exception was caught from the ServiceHeartbeatTimerThreadStart thread: {0}", e);
      }
    }

		/// <summary>
		/// Mehtod called when the general timer thread is started
		/// </summary>
		private void GeneralTimerThreadStart()
		{
			try
			{
				Thread.Sleep(mInitialDelay);
				
				while (true)
				{
					FireEvents();

					Thread.Sleep(mGeneralTimerPeriod);
				}
			} 
			catch (ThreadInterruptedException)
			{ 
				// shutting down
			}
 			catch (Exception e)
			{
				mLogger.LogError("A unhandled exception was caught from the general timer thread: {0}", e);
			}
		}

		/// <summary>
		/// Mehtod called when the process recurring events timer thread is started
		/// </summary>
		private void ProcessRecurringEventsTimerThreadStart()
		{
			Thread.Sleep(mInitialDelay);

			try
			{
				while (true)
				{
					ProcessRecurringEventsInternal();

					// handles a request to shutdown while the thread was not sleeping
					lock (mHaltCallback)
					{
						if (mHaltCallback.IsShuttingDown)
							break;
					}

          try
          {
            mProcessRecurringEventTimerThreadEvent.WaitOne(mProcessEventsTimerPeriod, false);


            if (mHaltCallback.IsShuttingDown)
              // shutting down, just exit
              break;
          }
          catch (ThreadAbortException)
          {
            // this should have been caught in RecurringEventManager::InvokeEvents
            // if we see this, there is a bug!
            mLogger.LogError("Thread abort was not handled properly by RecurringEventManager::InvokeEvents!");
            Thread.ResetAbort();
            continue;
          }
          catch (Exception e)
          {
            mLogger.LogException("Unexpected exception caght waiting in ProcessRecurringEventsTimerThread", e);
          }
				}
			}
 			catch (Exception e)
			{
				mLogger.LogError("An unhandled exception was caught from the process recurring events thread: {0}", e);
			}
		}


		/// <summary>
		/// Safely interrupts the recurring event processing thread.
		/// If adapters are currently being processed, then nothing is done.
		/// This prevents an adapter from having the ThreadInterruptedException raised
		/// from its code when it performs a managed wait/join/sleep.
		/// </summary>
		private void SafelyInterruptProcessRecurringEventsTimerThread()
		{
      // Signal event to wake up processing thread
      mProcessRecurringEventTimerThreadEvent.Set();
		}

		/// <summary>
		/// Determines what needs to be done and fires the appropriate .NET events.
		/// This method is invoked as a callback from mGeneralTimer.
		/// <summary>
		private void FireEvents()
		{
			Console.WriteLine("Woke up, determining events to fire");
			try 
			{
				DateTime now = MetraTime.Now;

				//
				// fires a DayChange event if a new day has begun
				//
				if (now > mNextDay)
				{
					Console.WriteLine("Day change detected");
					mLogger.LogInfo("Day change detected");
					mLogger.LogDebug("Current time : {0}", now);

					CalculateNextDailyTrigger();

					mLogger.LogDebug("Next day     : {0}", mNextDay);
					
					// fires the day change event
					lock (mConfigLock)
					{
            if (DayChange != null)
            {
              WriteConsoleAndLogFile(LogLevel.Info, "Executing events based on day change");
              DayChange(this, null);
            }
            else
            {
              WriteConsoleAndLogFile(LogLevel.Info, "No server events (Create Intervals or Soft Close Intervals) to be executed by this server");
            }
					}
				}
			
				//
				// fires Elapsed events if any minute timers have elapsed?
				//
				lock (mConfigLock)
				{
          if (mGlobalSettings.isRunScheduledAdaptersEnabled)
          {
            foreach (DictionaryEntry entry in mScheduledEventsTimers)
            {
              ScheduledEventTimer timer = (ScheduledEventTimer)entry.Value;
              timer.FireIfElapsed(now);
            }
          }
          else
          {
            WriteConsoleAndLogFile(LogLevel.Debug, "Skipping the creation of scheduled events. The global/cross server setting set from MetraControl is false.");
          }
				}
			}
			catch (Exception e)
			{
				string msg = String.Format("Unhandled exception caught: {0}", e);
				mLogger.LogError(msg);
				Console.WriteLine(msg);
			}
		}

		/// <summary>
		/// Calculates the next point in time that daily events should be fired.
		/// This includes creating intervals, closing intervals, instantiating daily scheduled events, etc.
		/// NOTE: this calculation will efficiently handle large jumps in MetraTime 
		/// </summary>
		private void CalculateNextDailyTrigger()
		{
			mNextDay = MetraTime.Now.Date + mDailyTriggerTime;
			if (MetraTime.Now > mNextDay)
				mNextDay = mNextDay.AddDays(1);
		}

		/// <summary>
		/// Executes or reverses any recurring events that can be executed/reversed.
		/// Called by the mProcessRecurringEventsTimerThread.
		/// <summary>
		private void ProcessRecurringEventsInternal()
		{
			try 
			{
				Console.WriteLine("Processing submitted events...");

				int executions, executionFailures;
				int reversals, reversalFailures;
        
        //v6.5
        if (mMaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine != 0)
        {
          mClient.ProcessEvents(mHaltCallback,
                                mProcessingConfiguration,
                                out executions, out executionFailures,
                                out reversals, out reversalFailures);
        }
        else
        {
          //Previous method that does not run adapters concurrently; setting and functionality left for troubleshooting
          mClient.ProcessEvents(mHaltCallback,
                      out executions, out executionFailures,
                      out reversals, out reversalFailures);
        }


				if (executions > 0)
					Console.WriteLine("{0} events executed successfully.", executions);
				if (executionFailures > 0)
					Console.WriteLine("{0} events failed while executing!", executionFailures);
				if (reversals > 0)
					Console.WriteLine("{0} events reversed successfully.", reversals);
				if (reversalFailures > 0)
					Console.WriteLine("{0} events failed while reversing!", reversalFailures);
				
				if (executions + executionFailures + reversals + reversalFailures == 0)
					Console.WriteLine("No events were able to be processed at this point in time.");
			}
			catch (Exception e)
			{
				string msg = String.Format("Unhandled exception caught: {0}", e);
				mLogger.LogError(msg);
				Console.WriteLine(msg);
			}
		}

		private void CreateIntervals(object source, EventArgs e)
		{
      WriteConsoleAndLogFile(LogLevel.Debug, "Creating intervals...");
			int created = mClient.CreateUsageIntervals();
      WriteConsoleAndLogFile(LogLevel.Debug, "{0} intervals created.", created);
		}

		private void CloseIntervals(object source, EventArgs e)
		{
      if (mGlobalSettings.isAutoSoftCloseBillGroupsEnabled)
      {
        if (mGlobalSettings.isBlockNewAccountsWhenClosingEnabled)
        {
          WriteConsoleAndLogFile(LogLevel.Debug, "Blocking expired intervals...");
          int blocked = mClient.BlockExpiredIntervals();
          WriteConsoleAndLogFile(LogLevel.Debug, "Blocked {0} expired intervals.", blocked);
        }

        WriteConsoleAndLogFile(LogLevel.Debug, "Materializing billing groups...");
        int materialized = mClient.MaterializeBillingGroups();
        WriteConsoleAndLogFile(LogLevel.Debug, "{0} intervals materialized.", materialized);

        WriteConsoleAndLogFile(LogLevel.Debug, "Soft-closing intervals...");
        int closed = mClient.SoftCloseUsageIntervals();
        WriteConsoleAndLogFile(LogLevel.Debug, "{0} intervals soft-closed.", closed);

        WriteConsoleAndLogFile(LogLevel.Debug, "Hard-closing intervals with no paying accounts...");
        int hardClosed = mClient.HardCloseExpiredIntervalsWithNoPayingAccounts();
        WriteConsoleAndLogFile(LogLevel.Debug, "{0} intervals hard-closed.", hardClosed);
      }
      else
      {
        WriteConsoleAndLogFile(LogLevel.Debug, "Skipping the closing of intervals. The global/cross server setting set from MetraControl is false.");
      }

      //Prior to 6.5, the action/event to submit all not yet run adapters for execution was a distinct event
      //This was brittle in that the timing of the C# events is non-deterministic (technically). Also, this
      //event is used when automatically soft closing intervals.
      if (mGlobalSettings.isAutoRunEopOnSoftCloseEnabled)
      {
        SubmitNotYetRunEventsForExecution();
      }
		}

		private void SubmitNotYetRunEventsForExecution()
		{
			Console.WriteLine("Submitting events for execution...");

			// selects all scheduled and end-of-period not yet run instances
			RecurringEventInstanceFilter instances = new RecurringEventInstanceFilter();
			instances.AddStatusCriteria(RecurringEventInstanceStatus.NotYetRun);
			instances.AddEventTypeCriteria(RecurringEventType.Scheduled);
			instances.AddEventTypeCriteria(RecurringEventType.EndOfPeriod);
			
			instances.Apply();
			
			// submits them!
			int submitted = 0;
			foreach (int instance in instances)
			{
				try
				{
					mClient.SubmitEventForExecution(instance, SUBMIT_COMMENT);
					submitted++;
				}
				catch (UsageServerException)
				{
					// exception has already been logged
				}
			}

			// selects checkpoints only if explicitly requested
			if (mSubmitCheckpoints)
			{
				instances.ClearCriteria();
				instances.ClearResults();
				instances.AddStatusCriteria(RecurringEventInstanceStatus.NotYetRun);
				instances.AddEventTypeCriteria(RecurringEventType.Checkpoint);
				instances.Apply();

				foreach (int instance in instances)
				{
					try
					{
						// submits while ignoring depenendencies since checkpoint acknowledgement
						// is now synschronous and will throw if deps are not satisfied
						mClient.SubmitEventForExecution(instance, true, SUBMIT_COMMENT);
						submitted++;
					}
					catch (UsageServerException)
					{
						// exception has already been logged
					}
				}
			}

			Console.WriteLine("{0} instances submitted for execution.", submitted);
			
			if (submitted > 0)
				ProcessRecurringEvents();
		}


    private void InstantiateMinuteScheduledEvents(object source, EventIdTimerEventArgs args)
    {
      bool submitted = false;

      // uses the same end date for all new instances
      // to avoid subtle dependency issues with timing (CR10265)
      //DateTime now = MetraTime.Now;

      // uses the same end date for all new instances
      // to avoid subtle dependency issues with timing (CORE-4607)
      DateTime endDate = args.EndDate;

      int eventID = args.EventId;
      
      try
      {
        Console.WriteLine("Instantiating schedule-based scheduled event {0}...", eventID);
        int instanceID = mClient.InstantiateScheduledEvent(eventID, endDate);
        Console.WriteLine("Instance {0} created for event {1}.", instanceID, eventID);

        if (mSubmitAfterInstantiation)
        {
          Console.WriteLine("Submitting instance {0} for execution.", instanceID);
          mClient.SubmitEventForExecution(instanceID, SUBMIT_COMMENT);
          submitted = true;
        }
      }
      catch (UsageServerException e)
      {
        Console.WriteLine(e);
      }

      if (submitted)
        ProcessRecurringEvents();
    }

		private void LoadScheduledEvents()
		{
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        // Let's cheat and reuse the code from RecurringEventManager. Don't know why it wasn't used before
        RecurringEventManager manager = new RecurringEventManager();
        Hashtable dbSchedulesScheduled = manager.ReadDBSchedulesScheduled(conn);
        foreach (int eventId in dbSchedulesScheduled.Keys)
        {
          RecurringEventSchedule schedule = (RecurringEventSchedule)((ArrayList)dbSchedulesScheduled[eventId])[0];
          BaseRecurrencePattern pattern = schedule.Pattern;
          ScheduledEventTimer timer = new ScheduledEventTimer(mLogger, eventId, pattern);
          mLogger.LogDebug("Found event {0} that should run {1}", eventId, pattern.ToString());
          timer.Elapsed += new ScheduledEventTimer.ElapsedEventHandler(InstantiateMinuteScheduledEvents);
          mScheduledEventsTimers.Add(eventId, timer);
        }
      }
		}

		private class ScheduledEventTimer
		{
      public ScheduledEventTimer(Logger logger, int eventId, BaseRecurrencePattern pattern)
			{
				mLogger = logger;
				mEventId = eventId;
        mPattern = pattern;
				
				// don't trigger right away, wait mMinutes (CR13767)
				//mNextTrigger = MetraTime.Now.AddMinutes(mMinutes);
        mNextTrigger = pattern.GetNextOccurrence();
			}

      public BaseRecurrencePattern Pattern
      {
        get
        { return mPattern; }
      }
		
			public int EventId
			{
				get
				{ return mEventId; }
			}

			public DateTime NextTrigger
			{
				get
				{ return mNextTrigger; }
			}

			public void FireIfElapsed(DateTime now)
			{
				// fires the event if necessary
				//DateTime now = MetraTime.Now;
        if (now > mNextTrigger)
        {
          // calculates the next trigger time
          //mNextTrigger = now.AddMinutes(mMinutes);
          mNextTrigger = Pattern.GetNextOccurrence();

          Console.WriteLine("{0}-timer has elapsed, eventId: {1}", Pattern.ToString(), EventId);
          mLogger.LogDebug("{0}-timer has elapsed, eventId: {1}", Pattern.ToString(), EventId);
          Elapsed(this, new EventIdTimerEventArgs(EventId, now));
        }
        else
        {
          mLogger.LogDebug("{0}-timer has NOT elapsed, eventId: {1}: Will be triggered at [{2}]. Now is [{3}]", Pattern.ToString(), EventId, mNextTrigger, now);
        }
			}

			public event ElapsedEventHandler Elapsed;
			public delegate void ElapsedEventHandler(object source, EventIdTimerEventArgs e);

			Logger mLogger;
			int mEventId;
      BaseRecurrencePattern mPattern;
			DateTime mNextTrigger;
		}

		private class EventIdTimerEventArgs : EventArgs
		{
			public EventIdTimerEventArgs(int eventId, DateTime endDate)
			{
				mEventId = eventId;
        mEndDate = endDate;
			}
			
			public int EventId
			{
				get
				{ return mEventId; }
			}
			
			int mEventId;

      public DateTime EndDate
      {
        get
        { return mEndDate; }
      }

      DateTime mEndDate;
		}

		Logger mLogger;
		Client mClient;

	  BillingServerServiceTracking mServiceTracking;

		// a timer thread for firing off short running, day change based activities.
		// for example: interval creation; submitting instances; instantiating events
		Thread mGeneralTimerThread;
		int mGeneralTimerPeriod; // in ms

		// a timer thread dedicated to processing recurring events
		// only one recurring event is running at any given time in this process
		Thread mProcessRecurringEventsTimerThread;
		int mProcessEventsTimerPeriod;  // in ms

    // a timer thread dedicated to processing recurring events
    // only one recurring event is running at any given time in this process
    Thread mRecordServiceHeartBeatThread;
    int mRecordServiceHeartbeatTimerPeriod;  // in ms

		// inital delay after a thread is started before doing any real work
		// used to avoid time out issues when starting the service
		int mInitialDelay; // in ms

	  private int mMaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine = 1;
    private ProcessingConfig mProcessingConfiguration;

	  private bool mOnlyRunAdaptersExplicitlyAssignedToThisMachine = false;

		Hashtable mScheduledEventsTimers = new Hashtable();

		delegate void DayChangeEventHandler(object source, EventArgs e);
		event DayChangeEventHandler DayChange;
		DateTime mNextDay;
		TimeSpan mDailyTriggerTime;

    private bool mInstantiateScheduledEvents;
    private bool mCreateIntervals;
    private bool mSoftCloseIntervals;

    private bool mConfigServiceCanInstantiateScheduledEvents;
    private bool mConfigServiceCanCreateIntervals;
    private bool mConfigServiceCanSoftCloseIntervals;

    private ConfigCrossServer mGlobalSettings;

		bool mSubmitAfterInstantiation;
		bool mSubmitCheckpoints;
    //bool mBlockNewAccounts; //Moved to a global setting retrieved from the database

		const string SUBMIT_COMMENT = "Submitted automatically by the BillingServer service";

		// used to synchronize access around data structures that may change
		// based on a configuration refresh. This includes: mMinuteTimers, 
		// mMinuteScheduledEvents, and DayChange
		Object mConfigLock = new Object();

    // Event used to wake up ProcessRecurringEventTimerThread for shutdown, config refresh and for 
    // new adapter event notification
    AutoResetEvent mProcessRecurringEventTimerThreadEvent = new AutoResetEvent(false);

    // Event used to wake up ProcessRecurringEventTimerThread for shutdown, config refresh and for 
    // new adapter event notification
    AutoResetEvent mRecordServiceHeartbeatTimerThreadEvent = new AutoResetEvent(false);

		HaltProcessingCallback mHaltCallback;


  }

}
