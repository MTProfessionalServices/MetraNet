namespace MetraTech.UsageServer.Service
{
	using System;
	using System.Threading;
	using System.Collections;
	using System.ServiceProcess;
	using System.Runtime.InteropServices; 
	using MetraTech;

	public class Service : ServiceBase
	{
		/// <summary>
		/// Constructor
		/// </summary>
		public Service()
		{
			ServiceName = "BillingServer";

			CanHandlePowerEvent = false;
			CanPauseAndContinue = false;
			CanShutdown = false;
			CanStop = true;
		}

		/// <summary>
		/// Cleans up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if (mProcessor != null)
					mProcessor.Stop();
			}
			base.Dispose( disposing );
		}

		/// <summary>
		/// Sets things in motion so your service can do its work.
		/// </summary>
		[MTAThread]
		protected override void OnStart(string[] args)
		{
			// Start processor.
			mProcessor = new Processor();
			mProcessor.Start();

			// Start command listener thread.
			ThreadPool.QueueUserWorkItem(new WaitCallback(_CommandWaitThread), this);
      ThreadPool.QueueUserWorkItem(new WaitCallback(_CommandWaitForBroadcastThread), this);
    }
 
		/// <summary>
		/// Stops this service.
		/// </summary>
		protected override void OnStop()
		{
			// Terminate the command thread.
			autoStopThreadEvent.Set();

      this.RequestAdditionalTime(60000);

			// Stop processor.
			mProcessor.Stop();
			mProcessor = null;

			// Wait for command thread to terminate.
			autoListenerThreadStoppedEvent.WaitOne();
		}

		// Thread use to call custom service commands.
		private static void _CommandWaitThread(object ServiceObject)
		{
      Logger logger = new Logger("[UsageServer]");

			Service This = (Service) ServiceObject;

			// Define commands.
			string[] cmds = new string[]
			{
				This.ServiceName + "_RefreshConfig",
				This.ServiceName + "_ProcessRecurringEvents",
				This.ServiceName + "_KillRecurringEvent",
				String.Empty
			};
				
			// Initialize events to wait for.
			AutoResetEvent[] autoEvents = new AutoResetEvent[cmds.Length];

			// Initialize event map.
			Hashtable map = new Hashtable();

			// Loop through an array of event names; one event for each command.
			int counter = 0;
			foreach (string name in cmds)
			{
				if (name == String.Empty)
				break;

				// Create a named event and add to events array.
				bool bAlreadyExists;
				autoEvents[counter] = Kernel32.CreateNamedAutoEvent(name, out bAlreadyExists);
				if (autoEvents[counter] == null) 
					throw new UsageServerException(String.Format("Error creating a named event"));
				if (bAlreadyExists)
					throw new UsageServerException(String.Format("Named event ({0}) already exists", name));

				// Add to event map.
				map.Add(counter, name);

        logger.LogDebug("_CommandWaitThread: Created event '{0}'", name);

				// Increment event counter.
				counter++;
			}

			// Add the thread stop event.
			autoEvents[counter] = This.autoStopThreadEvent;
			map.Add(counter, "StopThread");

			// Wait for objects to be signalled.
			while (true)
			{
        logger.LogDebug("_CommandWaitThread: Waiting on any event");

				int index = WaitHandle.WaitAny(autoEvents);
        logger.LogDebug("_CommandWaitThread: Received event with index of '{0}'", index);

				// If a thread exits or aborts without explicitly releasing a Mutex,
				// and that Mutex is included in a WaitAny on another thread, the index
				// returned by WaitAny will be the correct value plus 128
        if (index >= 128)
        {
          logger.LogWarning("_CommandWaitThread: Index of '{0}' indicates thread was aborted or exited without releasing mutex", index);
          index -= 128;
        }

				if (index > map.Count)
				{
					throw new UsageServerException(String.Format("Invalid event index"));
				}

				// Get event name.
				string name = (string) map[index];
        logger.LogDebug("_CommandWaitThread: Received event with name of '{0}'", name);

				// Process named event.
				if (name == This.ServiceName + "_RefreshConfig")
					This.mProcessor.RefreshConfig();

				else if (name == This.ServiceName + "_ProcessRecurringEvents")
					This.mProcessor.ProcessRecurringEvents();

				else if (name == This.ServiceName + "_KillRecurringEvent")
					This.mProcessor.KillRecurringEvent();

        else if (name == "StopThread")
        {
          logger.LogDebug("_CommandWaitThread: Received StopThread event. Exiting from _CommandWaitThread");
          break;
        }
        else
        {
          This.autoListenerThreadStoppedEvent.Set();
          throw new UsageServerException(String.Format("Unknown custom command passed to BillingServer service: {0}", index));
        }
			}

			// Signal anyone waiting for this thread to finish that we're done.
      logger.LogDebug("_CommandWaitThread: Setting event to indicate we have exited the thread");
			This.autoListenerThreadStoppedEvent.Set();
		}

    private static void _CommandWaitForBroadcastThread(object ServiceObject)
    {
      Logger logger = new Logger("[UsageServer]");

      Service This = (Service)ServiceObject;

      while (true)
      {
        Signaller.SignallerMessage msg = Signaller.GetInstance.Receive();

        switch (msg)
        {
          case Signaller.SignallerMessage.ConfigChanged:
            logger.LogDebug("About to handle received billing server config change message.");
            This.mProcessor.RefreshConfig();
            break;

          case Signaller.SignallerMessage.KillRecurringEvent:
            logger.LogDebug("About to handle received billing server kill recurring event message.");
            This.mProcessor.KillRecurringEvent();
            break;

          case Signaller.SignallerMessage.ProcessRecurringEvents:
            logger.LogDebug("About to handle received billing server process recurring event message.");
            This.mProcessor.ProcessRecurringEvents();
            break;

          default:
            logger.LogError("Received unrecognized billing server message: " + msg);
            break;
        }
      }

      // Signal anyone waiting for this thread to finish that we're done.
      // This.autoListenerThreadStoppedEvent.Set();
    }

		private Processor mProcessor;
		private AutoResetEvent autoStopThreadEvent = new AutoResetEvent(false);
		private AutoResetEvent autoListenerThreadStoppedEvent = new AutoResetEvent(false);
	}
}
