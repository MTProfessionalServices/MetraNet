

namespace MetraTech.UsageServer.USM
{
	using System;
	using System.Text;
	using System.Threading;
	using System.Collections;
  using System.Collections.Generic;

	using MetraTime = MetraTech.Interop.MetraTime;
	using Auth = MetraTech.Interop.MTAuth;
	using Rowset = MetraTech.Interop.Rowset;

	/// <summary>
	/// Usage Server Maintenance command line client.
	/// </summary>
	class USMExecutable
	{
		[MTAThread]
		static int Main(string[] args)
		{
			USMExecutable usm = new USMExecutable(args);
			int status = usm.Execute();
			return status;
		}

		public USMExecutable(string [] args)
		{
			mArgs = args;
			mClient = new Client();
		}

		public int Execute()
		{
			// at least one argument, the action, is required
			if (mArgs.Length == 0)
			{
				DisplayUsage();
				return 1;
			}

			try
			{
				mParser = new CommandLineParser(mArgs, 1, mArgs.Length);
				mParser.Parse();

				//
				// parses global arguments
				//

				// metratime
				MetraTime.IMetraTimeControl timeControl;
				timeControl = (MetraTime.IMetraTimeControl) new MetraTime.MetraTimeControl();
				if (mParser.OptionExists("metratime"))
				{
					DateTime newTime = mParser.GetDateTimeOption("metratime");
					Console.WriteLine("Setting MetraTime to {0}", newTime);
					timeControl.SetSimulatedOLETime(newTime);
				}

				//
				// handles main actions
				//
				string action = mArgs[0].ToLower();
				switch (action)
				{

					case "sync":
						Synchronize();
						break;

					case "-create":
					case "create":
						ParseCreateAction();
						break;

					case "materialize":
					case "mbg":
						ParseMaterializeAction();
						break;

					case "partition":
						ParsePartitionAction();
						break;

					case "-close":
					case "close":
						ParseCloseBillingGroupAction();
						break;

					case "open":
						ParseOpenAction();
						break;

					case "-run":
					case "run":
						ParseRunAction();
						break;

					case "reverse":
						ParseReverseAction();
						break;

					case "-all":
					case "all":
						Console.WriteLine("\nusm all is no longer supported.\n");
						//All();
						break;

					case "cancel":
						ParseCancelAction();
						break;

					case "override":
						ParseOverrideAction();
						break;

					case "li":
					case "list-instances":
						ParseListInstancesAction();
						break;

					case "lb":
					case "lbg":
					case "list-billing-groups":
						ParseListBillingGroupsAction();
						break;

					case "lu":
					case "lui":
					case "list-intervals":
						ParseListIntervalsAction();
						break;

					case "lr":
					case "list-runs":
						ParseListRunsAction();
						break;

					case "ld":
					case "ldeps":
					case "list-deps":
						ParseListDepsAction();
						break;

					case "test":
						return ParseTestAction();

					case "wait":
						return ParseWaitAction();

					case "kill":
						Kill();
						break;

					case "-help":
					case "--help":
					case "/?":
					case "-?":
					case "help":
						DisplayUsage();
						break;

						//
						// undocumented actions
						//
					case "-createcycles":
						mParser.CheckForUnusedOptions();
						Console.WriteLine("Creating usage cycles");
						mClient.CreateUsageCycles();
						break;

					case "-createpc": // backward compatibility with old usm
					case "-createref":
						mParser.CheckForUnusedOptions();
						Console.WriteLine("Creating reference intervals");
						mClient.CreateReferenceIntervals();
						break;

					case "process":
					case "execute": // technically, this is more than just executing
						mParser.CheckForUnusedOptions();
						ProcessEvents();
						break;

					case "-bootstrap":
						mParser.CheckForUnusedOptions();
						mClient.Bootstrap();
						break;

					case "service":
						ParseServiceAction();
						break;


					default:
						Console.WriteLine("Unknown action: {0}", action);
						Console.WriteLine("For usage syntax, type: usm /?");
						return 1;
				}
			}
			catch (CommandLineParserException e)
			{
				Console.WriteLine("{0}", e.Message);
				Console.WriteLine("For usage syntax, type: usm /?");
				return 1;
			}
			catch (UsageServerException e)
			{
				Console.WriteLine("{0}", e.Message);
				Exception innerException = e.InnerException;
				while (innerException != null)
				{
					Console.WriteLine("    {0}", innerException);
					innerException = innerException.InnerException;
				}
				return 1;
			}
				// lets unexpected exceptions bubble up to developers on DEBUG builds
#if !DEBUG
			catch (Exception e)
			{
				Console.WriteLine("Unhandled exception:");
				Console.WriteLine("{0}\a", e);

				Logger logger = new Logger("[UsageServer]");
				
				// cons up the argument string
				StringBuilder args = new StringBuilder();
				foreach (string arg in mArgs)
				{
					args.Append(arg);
					args.Append(" ");
				}

				logger.LogError("Unhandled exception caught in usm.exe! args = '{0}'", args);
				logger.LogError(e.ToString());
				
				return 1;
			}
#endif

			return 0;
		}

		// this method should be called after all other parsing has
		// been performed since it calls CheckForUnusedOptions
		private void AuthenticateUser()
		{
			if (mParser.OptionExists("login"))
			{
				string login = mParser.GetStringOption("login");
				string @namespace = mParser.GetStringOption("namespace");
				string password = mParser.GetStringOption("password");

				mParser.CheckForUnusedOptions();
				Console.WriteLine("Authenticating user {0}...", login);
				try 
				{
					Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
					Auth.IMTSessionContext sessionContext = loginContext.Login(login, @namespace, password);
					mClient.SessionContext = sessionContext;
				}
				catch (Exception e)
				{
					throw new UsageServerException("Could not authenticate user based on login, namespace and password!", e);
				}
			}
			else 
			{
				mParser.CheckForUnusedOptions();
				Console.WriteLine("Authenticating anonymous user...");
				try
				{
					Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
					Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();
					mClient.SessionContext = sessionContext;
				}
				catch (Exception e)
				{
					throw new UsageServerException("Could not authenticate anonymous user!", e);
				}
			}
		}

		private void ParseCreateAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm create [options]");
				Console.WriteLine();
				Console.WriteLine("Creates new usage intervals if necessary.");
				Console.WriteLine();
				Console.WriteLine("Options for 'create' action:");
				Console.WriteLine("  /pretend             displays intervals that would have been created");
				return;
			}

			bool pretend = mParser.GetBooleanOption("pretend", false);
			AuthenticateUser();
			mParser.CheckForUnusedOptions();
			CreateIntervals(pretend);
		}

    private void ParseMaterializeAction()
    {
      if (mParser.GetBooleanOption("?", false))
      {
        Console.WriteLine("Usage: usm materialize /interval:<id>");
        Console.WriteLine("Usage: usm mbg /interval:<id>");
        Console.WriteLine();
        Console.WriteLine("Materializes billing groups for the specified interval.");
        Console.WriteLine();
        return;
      }

      if (mParser.OptionExists("interval"))
      {
        int intervalID = mParser.GetIntegerOption("interval");
        AuthenticateUser();
        mParser.CheckForUnusedOptions();
        MaterializeBillingGroups(intervalID);
        return;
      }

      if (mParser.OptionExists("all"))
      {
        bool all = mParser.GetBooleanOption("all", false);
        AuthenticateUser();
        mParser.CheckForUnusedOptions();
        MaterializeBillingGroups();
        return;
      }

      throw new CommandLineParserException(
        "You must specify the /interval:<id> option.");
    }

		private void ParsePartitionAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm partition ");
				Console.WriteLine();
				Console.WriteLine("Creates new usage partitions if necessary.");
				Console.WriteLine();
				return;
			}

			AuthenticateUser();
			mParser.CheckForUnusedOptions();
			CreatePartitions();
		}

	  private void ParseCloseBillingGroupAction()
    {
      if (mParser.GetBooleanOption("?", false))
      {
        Console.WriteLine("Usage: usm close [options]");
        Console.WriteLine();
        Console.WriteLine("Closes a billing group or \n" + 
                          "   all billing groups for an interval or \n" + 
                          "   all billing groups for all applicable intervals \n");
        Console.WriteLine();
        Console.WriteLine("Options for 'close' action:");
        Console.WriteLine("  /interval:<id>       numeric ID of interval to close");
        Console.WriteLine("                       (default: all applicable billing groups)");
        Console.WriteLine("  /billingGroup:<id>   numeric ID of billing group to close");

        Console.WriteLine("                       (default: all applicable billing groups)");
        Console.WriteLine("  /soft[+|-]           whether to soft close (default: true)");
        Console.WriteLine("  /hard[+|-]           whether to hard close (default: false)");
        Console.WriteLine("  /ignoreBG            ignore billing groups. Only valid with the /interval /hard option");
        // Console.WriteLine("  /beforeDate:<date>   hard close all intervals prior to given date. Only valid with the /hard option. Will not create billing groups");
        Console.WriteLine("  /pretend             displays intervals that would have been soft-closed");
        return;
      }

      bool hasInterval = mParser.OptionExists("interval");
      bool hasBillingGroup = mParser.OptionExists("billingGroup");
      bool hasSoft = mParser.OptionExists("soft");
      bool hasHard = mParser.OptionExists("hard");
      bool hasIgnoreBG = mParser.OptionExists("ignoreBG");
      // bool hasBeforeDate = mParser.OptionExists("beforeDate");

      // Illegal to provide both interval and billing group
      if (hasInterval && hasBillingGroup)
        throw new CommandLineParserException("The options /interval and /billingGroup are mutually exclusive!");

      // Determine if it's soft close or hard close
      bool softClose = false;
      if (hasSoft)
        softClose = mParser.GetBooleanOption("soft");
			
      bool hardClose = false;
      bool ignoreBG = false;
      // DateTime beforeDate = DateTime.Now;
      if (hasHard)
      {
        hardClose = mParser.GetBooleanOption("hard");

        if (hasIgnoreBG)
        {
          if (hasBillingGroup || hasSoft || !hasInterval)
          {
            throw new CommandLineParserException("/ignoreBG can only be used with /interval and /hard and nothing else.!");
          }

          ignoreBG = mParser.GetBooleanOption("ignoreBG");
        }

        //if (hasBeforeDate)
        //{
        //  if (hasInterval || hasBillingGroup || hasIgnoreBG)
        //  {
        //    throw new CommandLineParserException("/beforeDate can only be used with /hard and nothing else.!");
        //  }
         
        //  beforeDate = mParser.GetDateTimeOption("beforeDate");
        //}
      }

			
      if (softClose && hardClose)
        throw new CommandLineParserException("The options /soft and /hard are mutually exclusive!");
			
      // by default, soft close
      if (!softClose && !hardClose)
        softClose = true;

      
      bool pretend = mParser.GetBooleanOption("pretend", false);

      // No interval, no billing group
      if (!hasInterval && !hasBillingGroup) 
      { 
        // Authenticate and check for unused options
        AuthenticateUser();
        mParser.CheckForUnusedOptions();
        SoftCloseBillingGroups(pretend);
        return;
      }

      // interval, no billing group
      if (hasInterval && !hasBillingGroup) 
      {
        int intervalID = mParser.GetIntegerOption("interval");
        // Authenticate and check for unused options
        AuthenticateUser();
        mParser.CheckForUnusedOptions();

        if (softClose)
        {
          SoftCloseUsageInterval(intervalID);
        }
        else
        {
          //if (hasBeforeDate)
          //{
          //  HardCloseUsageInterval(beforeDate);
          //}
          //else
          //{
            HardCloseUsageInterval(intervalID, ignoreBG);
          //}
        }
        return;
      }

      // no interval, billing group
      if (!hasInterval && hasBillingGroup) 
      {
        int billingGroupID = mParser.GetIntegerOption("billingGroup");
        // Authenticate and check for unused options
        AuthenticateUser();
        mParser.CheckForUnusedOptions();
        if (softClose) 
        {
          SoftCloseBillingGroup(billingGroupID);
        }
        else 
        {
          HardCloseBillingGroup(billingGroupID);
        }
      }
	  }

		private void ParseOpenAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm open [options]");
				Console.WriteLine();
				Console.WriteLine("Opens a previously soft-closed billing group(s)");
				Console.WriteLine();
				Console.WriteLine("Options for 'open' action:");
				Console.WriteLine("  /interval:<id>       numeric ID of interval to open");
        Console.WriteLine("  /billingGroup:<id>   numeric ID of billing group to open");
				Console.WriteLine("  /ignoredeps[+|-]     whether open dependencies are ignored (default: false)");
        Console.WriteLine("  /pretend             displays billing groups that would have been opened");
				return;
			}

      bool hasInterval = mParser.OptionExists("interval");
      bool hasBillingGroup = mParser.OptionExists("billingGroup");

      // Illegal to provide both interval and billing group
      if (hasInterval && hasBillingGroup)
        throw new CommandLineParserException
          ("The options /interval and /billingGroup are mutually exclusive!");

      // Must provide either interval or billing group
      if (!hasInterval && !hasBillingGroup)
        throw new CommandLineParserException
          ("Must provide either /interval or /billingGroup!");


			bool pretend = mParser.GetBooleanOption("pretend", false);
      bool ignoreDeps = mParser.GetBooleanOption("ignoredeps", false);

			if (pretend && hasInterval)
			{
        int intervalID = mParser.GetIntegerOption("interval");

				AuthenticateUser();
				mParser.CheckForUnusedOptions();
				CanOpenUsageInterval(intervalID);
				return;
			}

      if (pretend && hasBillingGroup)
      {
        int billingGroupId = mParser.GetIntegerOption("billingGroup");

        AuthenticateUser();
        mParser.CheckForUnusedOptions();
        CanOpenBillingGroup(billingGroupId);
        return;
      }

      if (hasInterval)
      {
        int intervalID = mParser.GetIntegerOption("interval");
        AuthenticateUser();
        mParser.CheckForUnusedOptions();
        OpenUsageInterval(intervalID, ignoreDeps, pretend);
        return;
      }
 		
      if (hasBillingGroup)
      {
        int billingGroupId = mParser.GetIntegerOption("billingGroup");
        AuthenticateUser();
        mParser.CheckForUnusedOptions();
        OpenBillingGroup(billingGroupId, ignoreDeps, pretend);
        return;
      }
		}


		private IRecurringEventInstanceFilter ParseInstanceOptions(ref bool includeScheduled,
			ref bool includeEOP,
			ref bool includeCheckpoint,
			bool allowStatus,
			bool returnOnInstanceID)
		{
			return ParseInstanceOptions(ref includeScheduled, ref includeEOP, ref includeCheckpoint,
				allowStatus, returnOnInstanceID, false, DateTime.MinValue);
		}
																			

		private IRecurringEventInstanceFilter ParseInstanceOptions(ref bool includeScheduled,
			ref bool includeEOP,
			ref bool includeCheckpoint,
			bool allowStatus,
			bool returnOnInstanceID,
			bool instantiateScheduled,
			DateTime effDate)
		{
			IRecurringEventInstanceFilter instances = new RecurringEventInstanceFilter();
			IRecurringEvent recurringEvent = null;

			// sets the instance criteria
			bool hasInstanceID = mParser.OptionExists("instance");
			if (hasInstanceID)
			{
				int instanceID = mParser.GetIntegerOption("instance");
				instances.AddInstanceCriteria(instanceID);

				if (returnOnInstanceID)
					return instances;

				recurringEvent = mClient.GetEventByInstance(instanceID);
			}

			// sets the event name criteria
			bool hasEventName = mParser.OptionExists("event");
			if (hasEventName)
			{
				string eventName = mParser.GetStringOption("event");
				instances.EventName = eventName;
				recurringEvent = mClient.GetEventByName(eventName);
			}

			if (hasEventName && hasInstanceID)
				throw new CommandLineParserException("The options /event and /instance are mutually exclusive!");

			if (hasEventName || hasInstanceID)
			{
				includeScheduled = false;
				includeEOP = false;
				includeCheckpoint = false;

				switch (recurringEvent.Type)
				{
					case RecurringEventType.Scheduled:
						includeScheduled = true;
						if (instantiateScheduled && !hasInstanceID)
						{
							// instantiates the scheduled event
							// NOTE: uses the effective date option to also specify the
							// end date argument of the scheduled event's run
							int instanceID = InstantiateScheduledEvent(instances.EventName, effDate);
							if (returnOnInstanceID)
							{
								instances.AddInstanceCriteria(instanceID);
								return instances;
							}
						}
						break;
					
					case RecurringEventType.EndOfPeriod:
						includeEOP = true;
						break;
					
					case RecurringEventType.Checkpoint:
						includeCheckpoint = true;
						break;
				}
			}

			// sets the usage interval criteria
			if (mParser.OptionExists("interval"))
			{
				int intervalID = mParser.GetIntegerOption("interval");
				instances.UsageIntervalID = intervalID;
			}

      // sets the billing group criteria
      if (mParser.OptionExists("billingGroup"))
      {
        int billingGroupID = mParser.GetIntegerOption("billingGroup");
        instances.BillingGroupID = billingGroupID;
      }

			// sets the status criteria
			if (allowStatus && mParser.OptionExists("status"))
			{
				string status = mParser.GetStringOption("status");
				try 
				{
					instances.AddStatusCriteria((RecurringEventInstanceStatus)
						Enum.Parse(typeof(RecurringEventInstanceStatus), status, true));
				}
				catch (ArgumentException)
				{
					throw new CommandLineParserException("Unrecognized value given to the /status option!");
				}
			}

			if (!hasEventName)
			{
				includeScheduled = mParser.GetBooleanOption("scheduled", includeScheduled);
				includeScheduled = mParser.GetBooleanOption("sch", includeScheduled);
				includeEOP = mParser.GetBooleanOption("eop", includeEOP);
				includeCheckpoint = mParser.GetBooleanOption("checkpoint", includeCheckpoint);
			}

			if (!includeScheduled && !includeEOP && !includeCheckpoint)
				throw new CommandLineParserException("Either the /eop, /scheduled or /checkpoint option must be enabled!");
				
			// sets the event type filter criteria
			if (includeScheduled)
				instances.AddEventTypeCriteria(RecurringEventType.Scheduled);
			if (includeEOP)
				instances.AddEventTypeCriteria(RecurringEventType.EndOfPeriod);
			if (includeCheckpoint)
				instances.AddEventTypeCriteria(RecurringEventType.Checkpoint);

			// instantiates scheduled events so that the filter will see them
			if (includeScheduled && instantiateScheduled)
				mClient.InstantiateScheduledEvents(effDate);

			return instances;
		}

		private void ParseRunAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm run [options]");
				Console.WriteLine();
				Console.WriteLine("Submits events for execution.");
				Console.WriteLine();
				Console.WriteLine("Options for 'run' action:");
				Console.WriteLine("  /instance:<id>       numeric ID of event instance to submit");
				Console.WriteLine("  /event:<name>        name of event to submit (default: all)");
				Console.WriteLine("  /interval:<id>       the usage interval associated with an event");
				Console.WriteLine("                       (default: all)");
        Console.WriteLine("  /billingGroup:<id>   the billing group associated with an event");
        Console.WriteLine("                       (default: all)");
        Console.WriteLine("  /scheduled[+|-]      whether to submit scheduled events (default: true)");
				Console.WriteLine("  /eop[+|-]            whether to submit end-of-period events (default: true)");
				Console.WriteLine("  /checkpoint[+|-]     whether to submit checkpoint events (default: false)");
				Console.WriteLine("  /ignoredeps[+|-]     whether dependencies are ignored (default: false)");
				Console.WriteLine("  /effdate:<date>      when the adapter will be run (default: now)");
				Console.WriteLine("  /comment:<text>      optional descriptive comment (for auditing purposes)");
				return;
			}

      bool hasInterval = mParser.OptionExists("interval");
      bool hasBillingGroup = mParser.OptionExists("billingGroup");
			
      // Illegal to provide both interval and billing group
      if (hasInterval && hasBillingGroup)
        throw new CommandLineParserException("The options /interval and /billingGroup are mutually exclusive!");

			DateTime effDate = mParser.GetDateTimeOption("effdate", DateTime.MinValue);
			bool ignoreDeps = mParser.GetBooleanOption("ignoredeps", false);
			string comment = mParser.GetStringOption("comment", null);

			// gets instances (includes scheduled and EOP by default)
			bool includeScheduled = true;
			bool includeEOP = true;
			bool includeCheckpoint = false;
			IRecurringEventInstanceFilter instances = 
				ParseInstanceOptions(ref includeScheduled, ref includeEOP, ref includeCheckpoint,
				false, // don't allow /status
				true,  // return as soon as we have an instance ID
				true,  // instantiate scheduled events
				effDate);

			AuthenticateUser();
			SubmitEvents(RecurringEventAction.Execute,
        instances, ignoreDeps, effDate, comment);

      if (includeCheckpoint && ignoreDeps)
      {
        if (hasBillingGroup)
        {
          int billingGroupId = mParser.GetIntegerOption("billingGroup");
          IgnoreEndRootDependenciesForBillingGroup(billingGroupId);
        }
        else if (hasInterval)
        {
          int intervalId = mParser.GetIntegerOption("interval");
          IgnoreEndRootDependenciesForInterval(intervalId);
        }
      }
		}

		private void ParseReverseAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm reverse [options]");
				Console.WriteLine();
				Console.WriteLine("Submits events for reversal.");
				Console.WriteLine();
				Console.WriteLine("Options for 'reverse' action:");
				Console.WriteLine("  /instance:<id>       numeric ID of event instance to submit");
				Console.WriteLine("  /event:<name>        name of event to submit (default: all)");
				Console.WriteLine("  /interval:<id>       the usage interval associated with an event");
				Console.WriteLine("                       (default: all)");
        Console.WriteLine("  /billingGroup:<id>   the billing group associated with an event");
        Console.WriteLine("                       (default: all)");
				Console.WriteLine("  /scheduled[+|-]      whether to submit scheduled events (default: false)");
				Console.WriteLine("  /eop[+|-]            whether to submit end-of-period events (default: false)");
				Console.WriteLine("  /checkpoint[+|-]     whether to submit checkpoint events (default: false)");
				Console.WriteLine("  /ignoredeps[+|-]     whether dependencies are ignored (default: false)");
				Console.WriteLine("  /effdate:<date>      when the adapter will be reversed (default: now)");
				Console.WriteLine("  /comment:<text>      optional descriptive comment (for auditing purposes)");
				return;
			}

      bool hasInterval = mParser.OptionExists("interval");
      bool hasBillingGroup = mParser.OptionExists("billingGroup");
			
      // Illegal to provide both interval and billing group
      if (hasInterval && hasBillingGroup)
        throw new CommandLineParserException("The options /interval and /billingGroup are mutually exclusive!");

			DateTime effDate = mParser.GetDateTimeOption("effdate", DateTime.MinValue);
			bool ignoreDeps = mParser.GetBooleanOption("ignoredeps", false);
			string comment = mParser.GetStringOption("comment", null);

			// gets instances (doesn't include any event type by default)
			bool includeScheduled = false;
			bool includeEOP = false;
			bool includeCheckpoint = false;
			IRecurringEventInstanceFilter instances = 
				ParseInstanceOptions(ref includeScheduled, ref includeEOP, ref includeCheckpoint,
				false,  // don't allow /status option
				true);  // return as soon as we have an instance ID

			AuthenticateUser();
			SubmitEvents(RecurringEventAction.Reverse,
        instances, ignoreDeps, effDate, comment);
		}

		private void ParseCancelAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm cancel [options]");
				Console.WriteLine();
				Console.WriteLine("Cancels submitted events which have not yet executed or reversed.");
				Console.WriteLine();
				Console.WriteLine("Options for 'cancel' action:");
				Console.WriteLine("  /instance:<id>       numeric ID of event instance to cancel");
				Console.WriteLine("  /event:<name>        name of event to cancel (default: all)");
				Console.WriteLine("  /interval:<id>       the usage interval associated with an event");
				Console.WriteLine("                       (default: all)");
        Console.WriteLine("  /billingGroup:<id>   the billing group associated with an event");
        Console.WriteLine("                       (default: all)");
        Console.WriteLine("  /status:<status>     cancels instances with this status (default: both)");
				Console.WriteLine("                       choices include: ReadyToRun, ReadyToReverse");
				Console.WriteLine("  /scheduled[+|-]      whether to cancel scheduled events (default: false)");
				Console.WriteLine("  /eop[+|-]            whether to cancel end-of-period events (default: true)");
				Console.WriteLine("  /checkpoint[+|-]     whether to cancel checkpoint events (default: false)");
				Console.WriteLine("  /comment:<text>      optional descriptive comment (for auditing purposes)");
				return;
			}

      bool hasInterval = mParser.OptionExists("interval");
      bool hasBillingGroup = mParser.OptionExists("billingGroup");
			
      // Illegal to provide both interval and billing group
      if (hasInterval && hasBillingGroup)
        throw new CommandLineParserException("The options /interval and /billingGroup are mutually exclusive!");

			string comment = mParser.GetStringOption("comment", null);

			// gets instances (doesn't include any event type by default)
			bool includeScheduled = false;
			bool includeEOP = false;
			bool includeCheckpoint = false;
			IRecurringEventInstanceFilter instances = 
				ParseInstanceOptions(ref includeScheduled, ref includeEOP, ref includeCheckpoint,
				false,  // don't allow /status option
				true,   // return as soon as we have an instance ID
				false, // don't instantiate scheduled events
				DateTime.MinValue);
			
			if (mParser.OptionExists("status"))
			{
				string rawStatus = mParser.GetStringOption("status");
				try 
				{
					RecurringEventInstanceStatus status;
					status = (RecurringEventInstanceStatus) Enum.Parse(typeof(RecurringEventInstanceStatus), rawStatus, true);
					
					if ((status != RecurringEventInstanceStatus.ReadyToRun) && 
						(status != RecurringEventInstanceStatus.ReadyToReverse))
						throw new CommandLineParserException("Unrecognized value given to the /status option!");
					
					instances.AddStatusCriteria(status);
				}
				catch (ArgumentException)
				{
					throw new CommandLineParserException("Unrecognized value given to the /status option!");
				}
			}

			AuthenticateUser();
			CancelSubmittedEvents(instances, comment);
		}

		private void ParseOverrideAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm override [options]");
				Console.WriteLine();
				Console.WriteLine("Overrides an event's status.");
				Console.WriteLine();
				Console.WriteLine("Options for 'override' action:");
				Console.WriteLine("  /instance:<id>       numeric ID of event instance to override");
				Console.WriteLine("  /status:<status>     status to override instance to");
				Console.WriteLine("                       choices include: Succeeded, Failed, NotYetRun");
				Console.WriteLine("  /comment:<text>      optional descriptive comment (for auditing purposes)");
				return;
			}

			string comment = mParser.GetStringOption("comment", null);
			int instanceID = mParser.GetIntegerOption("instance");
			
			string rawStatus = mParser.GetStringOption("status");
			RecurringEventInstanceStatus status;
			try 
			{
				status = (RecurringEventInstanceStatus) Enum.Parse(typeof(RecurringEventInstanceStatus), rawStatus, true);
				
				if ((status != RecurringEventInstanceStatus.Succeeded) && 
					(status != RecurringEventInstanceStatus.Failed) &&
					(status != RecurringEventInstanceStatus.NotYetRun))
					throw new CommandLineParserException("Unrecognized value given to the /status option!");
			}
			catch (ArgumentException)
			{
				throw new CommandLineParserException("Unrecognized value given to the /status option!");
			}

			AuthenticateUser();
			OverrideEventStatus(instanceID, status, comment);
		}

		private int ParseTestAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm test [options]");
				Console.WriteLine();
				Console.WriteLine("Submits a test instance of an adapter.");
				Console.WriteLine();
				Console.WriteLine("Options for 'test' action:");
				Console.WriteLine("  /event:<name>        name of event from a recurring_events.xml file");
				Console.WriteLine("                       used to fill in class name, extension, config file, etc");
				Console.WriteLine("  /adapter:<classname> class name or ProgID for adapter");
				Console.WriteLine("  /extension:<name>    name of extension where adapter's config file lives");
				Console.WriteLine("  /config:<file>       configuration file relative to the adapter's extension");
				Console.WriteLine("  /type:eop            specifies the type of adapter is end-of-period");
				Console.WriteLine("  /type:scheduled      specifies the type of adapter is scheduled");
				Console.WriteLine("  /interval:<id>       interval ID to be passed to end-of-period adapter");
        Console.WriteLine("  /billingGroup:<id>   billing group ID to be passed to end-of-period adapter");
				Console.WriteLine("  /startdate:<date>    start date to be passed to scheduled adapter");
				Console.WriteLine("  /enddate:<date>      end date to be passed to scheduled adapter");
				Console.WriteLine("  /comment:<text>      optional descriptive comment (for auditing purposes)");
				Console.WriteLine();
				Console.WriteLine("Examples:");
				Console.WriteLine();
				Console.Write    ("  usm test /adapter:Metratech.MTRecurringChargeAdapter.1 /extension:systemconfig");
				Console.WriteLine("           /config:RecurringCharges.xml /type:eop /interval:863698974 ");
				Console.WriteLine("           /billinggroup:1000");
				Console.WriteLine();
				Console.WriteLine("  usm test /event:RecurringCharges /interval:863698974 /billinggroup:1000");

				return 0;
			}

			RecurringEvent recurringEvent = new RecurringEvent();

			string eventName;
			if (mParser.OptionExists("event"))
			{
				eventName = mParser.GetStringOption("event");
				RecurringEventManager manager = new RecurringEventManager();
				Hashtable events = manager.LoadEventsFromFile();
				if (!events.Contains(eventName))
				{
					Console.WriteLine("Event '{0}' not found in any recurring_events.xml file!", eventName);
					return 1;
				}

				recurringEvent = (RecurringEvent) events[eventName];
				if ((recurringEvent.Type != RecurringEventType.EndOfPeriod) && (recurringEvent.Type != RecurringEventType.Scheduled))
				{
					Console.WriteLine("Adapter's type must either be 'EndOfPeriod' or 'Scheduled'");
					return 1;
				}
			}
			else
			{
				recurringEvent.ClassName = mParser.GetStringOption("adapter");
				recurringEvent.ExtensionName = mParser.GetStringOption("extension");
				
				if (mParser.OptionExists("config"))
					recurringEvent.ConfigFileName = mParser.GetStringOption("config");

				string adapterType = mParser.GetStringOption("type").ToLower();
				if (adapterType == "eop")
					recurringEvent.Type = RecurringEventType.EndOfPeriod;
				else if ((adapterType == "scheduled") || (adapterType == "sch"))
					recurringEvent.Type = RecurringEventType.Scheduled;
				else
				{
					Console.WriteLine("Adapter's type must either be 'eop' or 'scheduled'");
					return 1;
				}
			}

			RecurringEventRunContext context = new RecurringEventRunContext();
			if (recurringEvent.Type == RecurringEventType.EndOfPeriod)
			{
				context.UsageIntervalID = mParser.GetIntegerOption("interval");
        context.BillingGroupID = mParser.GetIntegerOption("billinggroup");
			}
			else
			{
				recurringEvent.Type = RecurringEventType.Scheduled;
				context.StartDate = mParser.GetDateTimeOption("startdate");
				context.EndDate = mParser.GetDateTimeOption("enddate");
			}

			string comment = null;
			if (mParser.OptionExists("comment"))
				comment = mParser.GetStringOption("comment");
			
			AuthenticateUser();
			CreateAdapterTest(recurringEvent, context, comment);
			
			return 0;
		}

		private int ParseWaitAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm wait [options]");
				Console.WriteLine();
				Console.WriteLine("Waits for nightly event processing to complete.");
				Console.WriteLine();
				Console.WriteLine("Options for 'wait' action:");
				Console.WriteLine("  /timeout:<minutes>   number of minutes to wait before giving up.");
				Console.WriteLine("                       If not included, wait forever.");
				return 0;
			}

			int timeout;
			if (mParser.OptionExists("timeout"))
				// convert to seconds
				timeout = mParser.GetIntegerOption("timeout") * 60;
			else
				timeout = -1;

			AuthenticateUser();
			mParser.CheckForUnusedOptions();

			bool succeeded = mClient.Wait(timeout);
			if (succeeded)
				Console.WriteLine("Wait succeeded");
			else
				Console.WriteLine("Wait failed");

			return succeeded ? 0 : -1;
		}

		private int ParseListInstancesAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm list-instances [options]");
				Console.WriteLine("Usage: usm li [options]");
				Console.WriteLine();
				Console.WriteLine("Lists recurring event instances.");
				Console.WriteLine();
				Console.WriteLine("Options for 'list-instances' action:");
				Console.WriteLine("  /instance:<id>       numeric ID of event instance to list");
				Console.WriteLine("  /event:<name>        name of event to list (default: all)");
				Console.WriteLine("  /interval:<id>       the usage interval associated with an event");
				Console.WriteLine("                       (default: all)");
        Console.WriteLine("  /billingGroup:<id>   the billing group associated with an event");
        Console.WriteLine("                       (default: all)");
				Console.WriteLine("  /status:<status>     lists only instances with this status (default: all)");
				Console.WriteLine("                       choices include: NotYetRun, ReadyToRun, Running,");
				Console.WriteLine("                       Succeeded, Failed, ReadyToReverse, Reversing");
				Console.WriteLine("  /scheduled[+|-]      whether to list scheduled events (default: true)");
				Console.WriteLine("  /eop[+|-]            whether to list end-of-period events (default: true)");
				Console.WriteLine("  /checkpoint[+|-]     whether to list checkpoint events (default: true)");
				Console.WriteLine("  /long[+|-]           whether to use the long list format (default: false)");
				Console.WriteLine("  /executable          lists executable instances (must be used alone)");
				Console.WriteLine("  /reversible          lists reversible instances (must be used alone)");
        Console.WriteLine("  /runnable            lists executable and reversible instances (must be used alone)");
				return 0;
			}

      bool hasInterval = mParser.OptionExists("interval");
      bool hasBillingGroup = mParser.OptionExists("billingGroup");
			
      // Illegal to provide both interval and billing group
      if (hasInterval && hasBillingGroup)
        throw new CommandLineParserException("The options /interval and /billingGroup are mutually exclusive!");

			bool longFormat = mParser.GetBooleanOption("long", false);
			longFormat = mParser.GetBooleanOption("l", longFormat);
			
			IRecurringEventInstanceFilter instances;
      bool showExecutableEvents = mParser.GetBooleanOption("executable", false);
      bool showReversibleEvents = mParser.GetBooleanOption("reversible", false);
      if (mParser.GetBooleanOption("runnable", false))
      {
        showExecutableEvents = true;
        showReversibleEvents = true;
      }

      if (showExecutableEvents || showReversibleEvents)
      {
        mParser.CheckForUnusedOptions();

        if (showExecutableEvents)
        {
          instances = mClient.DetermineExecutableEvents();
          instances.Apply();
          if (instances.Count > 0)
            ListEventInstances(instances, "Executable Events", longFormat, true, true, true);
          else
            Console.WriteLine("No executable event instances exist at this point in time.");
        }

        if (showReversibleEvents)
        {
          if (showExecutableEvents)
            Console.WriteLine(""); //Extra line break to separate lists

          instances = mClient.DetermineReversibleEvents();
          instances.Apply();
          if (instances.Count > 0)
            ListEventInstances(instances, "Reversible Events", longFormat, true, true, true);
          else
            Console.WriteLine("No reversible event instances exist at this point in time.");
        }

        return 0;
      }

			// parses instance options
			bool includeScheduled = true;
			bool includeEOP = true;
			bool includeCheckpoint = true;
			instances = ParseInstanceOptions(ref includeScheduled, ref includeEOP, ref includeCheckpoint,
				true,   // allow /status option
				false); // don't return as soon as we have an instance ID

			mParser.CheckForUnusedOptions();
			ListEventInstances(instances, true, longFormat, includeScheduled, includeEOP, includeCheckpoint);

			return 0;
		}

    private int ParseListBillingGroupsAction()
    {
      if (mParser.GetBooleanOption("?", false))
      {
        Console.WriteLine("Usage: usm list-billing-groups [options]");
        Console.WriteLine("Usage: usm lbg [options]");
        Console.WriteLine();
        Console.WriteLine("Lists billing groups.");
        Console.WriteLine();
        Console.WriteLine("Options for 'list-billing-groups' action:");
        Console.WriteLine("  /billingGroup:<id>   numeric ID of the billing group to list");
        Console.WriteLine("                       (default: all)");
        Console.WriteLine("  /interval:<id>       the usage interval associated with a billing group");
        Console.WriteLine("                       (default: all)");
        Console.WriteLine("  /status:<status>     lists only billing groups with this status (default: all)");
        Console.WriteLine("                       choices include: Open, SoftClosed, HardClosed");
        return 0;
      }

      try 
      {
        bool hasBillingGroup = mParser.OptionExists("billingGroup");
        bool hasInterval = mParser.OptionExists("interval");
        bool hasStatus = mParser.OptionExists("status");
        string status = String.Empty;
   
        // Illegal to provide both interval and billing group
        if (hasInterval && hasBillingGroup)
          throw new CommandLineParserException("The options /interval and /billingGroup are mutually exclusive!");

        IBillingGroupFilter filter = new BillingGroupFilter();
        filter.BillingGroupOrder = BillingGroupOrder.Interval;

        // get interval if present
        if (hasInterval)
        {
          filter.IntervalId = mParser.GetIntegerOption("interval");
        }

        // get billing group if present
        if (hasBillingGroup)
        {
          filter.BillingGroupId = mParser.GetIntegerOption("billingGroup");
        }

        // get status if present
        if (hasStatus)
        {
          status = mParser.GetStringOption("status");
          filter.Status = status;
        }

        AuthenticateUser();
        mParser.CheckForUnusedOptions();
   
        ListBillingGroupsExtended(filter);
      } 
      catch (Exception ex)
      {
        Console.WriteLine("\nError: {0}", ex.Message);
      }
      return 0;
    }

		private void ParseListIntervalsAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm list-intervals [options]");
				Console.WriteLine("Usage: usm lui [options]");
				Console.WriteLine();
				Console.WriteLine("Lists usage intervals.");
				Console.WriteLine();
				Console.WriteLine("Options for 'list-intervals' action:");
				Console.WriteLine("  /status:<status>     lists only intervals with this status (default: all)");
				Console.WriteLine("                       choices include: Open, HardClosed");
				Console.WriteLine("                       short forms: O, H");
				Console.WriteLine();
				return;
			}

			UsageIntervalFilter intervals = new UsageIntervalFilter();
			
			if (mParser.OptionExists("status"))
			{
				string status = mParser.GetStringOption("status").ToLower();
				switch (status)
				{
					case "o":
					case "open":
						intervals.Status = UsageIntervalStatus.Open;
						break;

       		case "h":
					case "hardclosed":
						intervals.Status = UsageIntervalStatus.HardClosed;
						break;

					default:
						throw new CommandLineParserException("Unrecognized value given to the /status option!");
				}
			}

			mParser.CheckForUnusedOptions();
			ListUsageIntervals(intervals);
		}

		private void ParseListRunsAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm list-runs [options]");
				Console.WriteLine("Usage: usm lr [options]");
				Console.WriteLine();
				Console.WriteLine("Lists recurring event runs.");
				Console.WriteLine();
				Console.WriteLine("Options for 'list-runs' action:");
				Console.WriteLine("  /instance:<id>       numeric ID of instance whose runs should be listed");
				Console.WriteLine("                       (default: all)");
				Console.WriteLine("  /status:<status>     lists only runs with this status (default: all)");
				Console.WriteLine("                       choices include: Succeeded, Failed, InProgess");
				Console.WriteLine("  /action:<type>       lists only runs of this action type (default: all)");
				Console.WriteLine("                       choices include: Execute, Reverse");
				Console.WriteLine("  /long[+|-]           whether to use the long list format (default: false)");
				return;
			}

			RecurringEventRunFilter runs = new RecurringEventRunFilter();

			bool longFormat = mParser.GetBooleanOption("long", false);
			longFormat = mParser.GetBooleanOption("l", longFormat);

			if (mParser.OptionExists("instance"))
				runs.InstanceID = mParser.GetIntegerOption("instance");
			
			if (mParser.OptionExists("status"))
			{
				string status = mParser.GetStringOption("status");
				try 
				{
					runs.Status = (RecurringEventRunStatus) 
						Enum.Parse(typeof(RecurringEventRunStatus), status, true);
				}
				catch (ArgumentException)
				{
					throw new CommandLineParserException("Unrecognized value given to the /status option!");
				}
			}

			if (mParser.OptionExists("action"))
			{
				string action = mParser.GetStringOption("action");
				try 
				{
					runs.Action = (RecurringEventAction) 
						Enum.Parse(typeof(RecurringEventAction), action, true);
				}
				catch (ArgumentException)
				{
					throw new CommandLineParserException("Unrecognized value given to the /action option!");
				}
			}

			mParser.CheckForUnusedOptions();
			ListEventRuns(runs, longFormat);
		}

		private void ParseListDepsAction()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm list-deps [options]");
				Console.WriteLine("Usage: usm ldeps [options]");
				Console.WriteLine();
				Console.WriteLine("Lists recurring event dependencies.");
				Console.WriteLine();
				Console.WriteLine("Options for 'list-deps' action:");
				Console.WriteLine("  /instance:<id>       instance ID whose dependencies should be listed");
				Console.WriteLine("  /type:<type>         chooses what type of dependencies to calculate");
				Console.Write    ("                       choices include: Execution, Reversal (default: execution)");
				Console.WriteLine("  /status:<status>     lists only dependencies with this status (default: all)");
				Console.WriteLine("                       Choices include: Satisfied, Unsatisfied");
				Console.WriteLine("  /dot                 emits event dependencies in Graphviz project's DOT code");
				return;
			}

			if (mParser.OptionExists("instance"))
			{
				int instanceID = mParser.GetIntegerOption("instance");
				IRecurringEventInstanceFilter instances = new RecurringEventInstanceFilter();
				instances.AddInstanceCriteria(instanceID);

				RecurringEventDependencyType depType = RecurringEventDependencyType.Execution; 
				if (mParser.OptionExists("type"))
				{
					string rawType = mParser.GetStringOption("type");
					try 
					{
						depType = (RecurringEventDependencyType) 
							Enum.Parse(typeof(RecurringEventDependencyType), rawType, true);
					}
					catch (ArgumentException)
					{
						throw new CommandLineParserException("Unrecognized value given to the /type option!");
					}
				}

				RecurringEventDependencyStatus depStatus = RecurringEventDependencyStatus.All;
				if (mParser.OptionExists("status"))
				{
					string rawStatus = mParser.GetStringOption("status");
					try 
					{
						depStatus = (RecurringEventDependencyStatus) 
							Enum.Parse(typeof(RecurringEventDependencyStatus), rawStatus, true);
					}
					catch (ArgumentException)
					{
						throw new CommandLineParserException("Unrecognized value given to the /status option!");
					}
				}
				
				mParser.CheckForUnusedOptions();
				ListInstanceDeps(instances, depType, depStatus);
				return;
			}

			bool generateDOT = mParser.GetBooleanOption("dot", false);
			if (generateDOT)
			{
				bool includeRootEvents = mParser.GetBooleanOption("showroots", false);
				mParser.CheckForUnusedOptions();
				GenerateDOTOutput(includeRootEvents);
				return;
			}

			mParser.CheckForUnusedOptions();
			throw new CommandLineParserException("Either the /instance or /dot option is required!");
		}

		private void ParseServiceAction()
		{
			if (mParser.GetBooleanOption("inproc", false))
			{
        ProcessingConfig processingConfig = ProcessingConfigManager.LoadFromFile();
        
        string machineIdentifierToUse = mParser.GetStringOption("machineidentifier", null);
        if (machineIdentifierToUse==null)
          machineIdentifierToUse = mParser.GetStringOption("machinename", null);

        if (string.IsNullOrEmpty(machineIdentifierToUse))
          processingConfig.MachineIdentifierToUse = machineIdentifierToUse;

        string machineRolesToProcess = mParser.GetStringOption("machineroles", null);
        if (!string.IsNullOrEmpty(machineRolesToProcess))
        {
          foreach (string machineRoleName in machineRolesToProcess.Split(','))
          {
            //Strip quotes
            machineRoleName.TrimStart('\"', '\'');
            machineRoleName.TrimEnd('\"', '\'');
            processingConfig.MachineRolesToConsiderForProcessing.Add(machineRoleName);
          }
        }

        if (processingConfig.MachineRolesToConsiderForProcessing.Count != 0)
          processingConfig.OnlyRunAdaptersExplicitlyAssignedToThisMachine = true;
        else
          processingConfig.OnlyRunAdaptersExplicitlyAssignedToThisMachine = false;

        mParser.CheckForUnusedOptions();

				Console.WriteLine("Running indefinitely as service...");
				Service.Processor processor = new Service.Processor();
        processor.Start(machineIdentifierToUse,processingConfig);
				Thread.Sleep(Timeout.Infinite);
				return;
			}					

			if (mParser.GetBooleanOption("refresh-config", false))
			{
				mParser.CheckForUnusedOptions();
				Console.WriteLine("Notifying service of configuration change");
				mClient.NotifyServiceOfConfigChange();
				return;
			}					

			if (mParser.GetBooleanOption("process-events", false))
			{
				mParser.CheckForUnusedOptions();
				Console.WriteLine("Notifying service of submitted events");
				mClient.NotifyServiceOfSubmittedEvents();
				return;
			}					
			
			Console.WriteLine("Usage: usm service [options]");
			Console.WriteLine();
			Console.WriteLine("Debugging Options:");
			Console.WriteLine("  /inproc               runs the service inside of the usm.exe process");
      Console.WriteLine("                        for testing, /inproc can also specify the machine name");
      Console.WriteLine("                        to use instead of the computername using the syntax:");
      Console.WriteLine("                          usm service /inproc /machinename:MyMachineName");
      Console.WriteLine("  /refresh-config       notifies the service of a configuration change");
			Console.WriteLine("  /process-events       requests the service process events immediately");
			Console.WriteLine();
		}

		private void Synchronize()
		{
			string eventConfigFile = mParser.GetStringOption("eventfile", null);
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm sync [options]");
				Console.WriteLine();
				Console.WriteLine("Synchronizes database with configuration files.");
        Console.WriteLine();
        Console.WriteLine("Options for 'sync' action:");
        Console.WriteLine("  /update:db        Updates database with data in recurring events configuration files");
        Console.WriteLine("                      Overwrites any changes made with MetraControl");
        Console.WriteLine("  /update:db /silent  The same as /update:db, but no confirmation messages");

        Console.WriteLine("  /update:file      Updates recurring events configuration files with data in database");
        Console.WriteLine("                      Only recurrence pattern for scheduled adapters will be updated");
        Console.WriteLine("  /update:both      Updates recurring events configuration files first; then updates database");
        Console.WriteLine("                      this is the default option.");
        Console.WriteLine();
        Console.WriteLine("Examples:");
        Console.Write("  usm sync");
        Console.WriteLine();
        Console.WriteLine("  usm sync /update:db");
        Console.Write("  usm sync /update:db /silent");
        return;
			}

      bool updateConfigFile = true;
      bool updateDb = true;

      string overrideType = mParser.GetStringOption("update", "both").ToLower();
      if (overrideType == "db")
      {
        if (!mParser.GetBooleanOption("silent", false))
        {
          Console.WriteLine("You will lose all changes made to scheduled adapter schedules with MetraControl");
          string answer;
          while (true)
          {
            Console.Write("Are you sure? (Y/N) : ");
            answer = Console.ReadLine().ToUpper().Trim();
            if (answer == "N") return;
            if (answer == "Y") break;
          }
        }

        updateConfigFile = false;
        updateDb = true;
      }
      else if (overrideType == "file")
      {
        updateConfigFile = true;
        updateDb = false;
      }
      else if (overrideType == "both")
      {
        updateConfigFile = true;
        updateDb = true;
      }

      AuthenticateUser();

			Console.WriteLine("Synchronizing database with configuration files...");
      if (updateConfigFile)
      {
        Console.WriteLine("Updating configuration files...");
        List<RecurringEvent> modifiedEvents;
        if (eventConfigFile == null)
          mClient.SynchronizeConfigFile(out modifiedEvents);
        else
          mClient.SynchronizeConfigFile(eventConfigFile, out modifiedEvents);

        if (modifiedEvents.Count == 0)
          Console.WriteLine("  No Updates made to scheduled adapters Recurrence Pattern");
        else
        {
          foreach (RecurringEvent modifiedEvent in modifiedEvents)
            Console.WriteLine("  updated '{0}' from '{1}' extension", modifiedEvent.Name, modifiedEvent.ExtensionName);

          Console.WriteLine();

          if (modifiedEvents.Count > 0)
            Console.WriteLine("  {0} events were modified.", modifiedEvents.Count);
        }

      }
      if (updateDb)
      {
        Console.WriteLine("Updating Database...");
        ArrayList addedEvents, removedEvents, modifiedEvents;
        if (eventConfigFile == null)
          mClient.Synchronize(out addedEvents, out removedEvents, out modifiedEvents);
        else
          mClient.Synchronize(eventConfigFile, out addedEvents, out removedEvents, out modifiedEvents);

        if (addedEvents.Count + modifiedEvents.Count + removedEvents.Count == 0)
          Console.WriteLine("  No Interval and Service changes detected.");
        else
        {
          foreach (RecurringEvent newEvent in addedEvents)
            Console.WriteLine("  added '{0}' from '{1}' extension", newEvent.Name, newEvent.ExtensionName);

          foreach (RecurringEvent modifiedEvent in modifiedEvents)
            Console.WriteLine("  updated '{0}' from '{1}' extension", modifiedEvent.Name, modifiedEvent.ExtensionName);

          foreach (RecurringEvent removedEvent in removedEvents)
            Console.WriteLine("  removed '{0}' from '{1}' extension", removedEvent.Name, removedEvent.ExtensionName);

          Console.WriteLine();

          if (addedEvents.Count > 0)
            Console.WriteLine("  {0} events were added.", addedEvents.Count);

          if (modifiedEvents.Count > 0)
            Console.WriteLine("  {0} events were modified.", modifiedEvents.Count);

          if (removedEvents.Count > 0)
            Console.WriteLine("  {0} events were removed.", removedEvents.Count);
        }
      }
		}

		private void CreateIntervals(bool pretend)
		{
			if (pretend)
				Console.WriteLine("These usage intervals would have been created:");
			else
				Console.WriteLine("Creating usage intervals...");

			ArrayList intervals = mClient.CreateUsageIntervals(pretend);
		
			if (pretend)
				Console.WriteLine("\n{0} usage intervals would have been created.", intervals.Count);
			else
				Console.WriteLine("\n{0} usage intervals were created.", intervals.Count);

			// display the new intervals
			if (intervals.Count > 0)
			{
				Console.WriteLine();
				ListUsageIntervals(intervals);
				Console.WriteLine();
			}

		}

    private void MaterializeBillingGroups() 
    {
      Console.WriteLine("Materializing all intervals...");
      mClient.MaterializeBillingGroups();
      Console.WriteLine("Finished materializing all intervals.");
    }

    private void MaterializeBillingGroups(int intervalId) 
    {
      Console.WriteLine("Materializing interval '{0}'...", intervalId);
      mClient.MaterializeBillingGroups(intervalId);
      Console.WriteLine("Finished materializing interval '{0}'.", intervalId);
    }

		private void CreatePartitions()
		{
			Console.WriteLine("Creating usage partitions...");
			mClient.CreateUsagePartitions();
			Console.WriteLine("Usage partitions created.");
		}


		private void SoftCloseUsageIntervals(bool pretend)
		{
			if (pretend)
				Console.WriteLine("These billing groups would have been soft-closed:");
			else
				Console.WriteLine("Soft closing billing groups...");

			ArrayList billingGroups = mClient.SoftCloseUsageIntervals(pretend);

			// display the new intervals
			if (billingGroups.Count > 0)
			{
				Console.WriteLine();
				ListBillingGroups(billingGroups);
				Console.WriteLine();
			}
			
			if (pretend)
				Console.WriteLine("{0} billing groups would have been soft-closed.", billingGroups.Count);
			else
				Console.WriteLine("{0} billing groups were soft closed.", billingGroups.Count);
		}

    private void SoftCloseBillingGroups(bool pretend)
    {
      if (pretend)
        Console.WriteLine("These billing groups would have been soft-closed:");
      else
        Console.WriteLine("Soft closing billing groups...");

      ArrayList billingGroups = mClient.SoftCloseBillingGroups(pretend);

      // display the new billing groups
      if (billingGroups.Count > 0)
      {
        Console.WriteLine();
        ListBillingGroups(billingGroups);
        Console.WriteLine();
      }
			
      if (pretend)
        Console.WriteLine("{0} billing groups would have been soft-closed.", 
                           billingGroups.Count);
      else
        Console.WriteLine("{0} billing groups were soft closed.", 
                          billingGroups.Count);
    }

		private int SoftCloseUsageInterval(int intervalID)
		{
			Console.WriteLine("Soft closing usage interval {0}...", intervalID);
			if (!mClient.SoftCloseUsageInterval(intervalID))
			{
				Console.WriteLine("Usage interval could not be soft closed!");
				return 1;
			}

			Console.WriteLine("Usage interval was successfully soft closed.");
			return 0;
		}

    private int SoftCloseBillingGroup(int billingGroupID)
    {
      Console.WriteLine("Soft closing billing group {0}...", billingGroupID);
      if (!mClient.SoftCloseBillingGroup(billingGroupID))
      {
        Console.WriteLine("Billing Group could not be soft closed!");
        return 1;
      }

      Console.WriteLine("Billing Group was successfully soft closed.");
      return 0;
    }
		private void OpenUsageInterval(int intervalID, bool ignoreDeps, bool pretend)
		{
			Console.WriteLine("Opening usage interval {0}{1}...",
				intervalID, ignoreDeps ? " (ignoring dependencies)" : "");

			int billingGroupsOpened = 
        mClient.OpenUsageInterval(intervalID, ignoreDeps);

			Console.WriteLine
        ("{0} Billing groups in Usage interval {1} were successfully opened.", billingGroupsOpened, intervalID);
		}

    private void OpenBillingGroup(int billingGroupID, bool ignoreDeps, bool pretend)
    {
      Console.WriteLine("Opening billing group {0}{1}...",
                        billingGroupID, ignoreDeps ? " (ignoring dependencies)" : "");

      mClient.OpenBillingGroup(billingGroupID, ignoreDeps);

      Console.WriteLine("Billing group was successfully opened.");
    }

		private void CanOpenUsageInterval(int intervalID)
		{
			if (mClient.CanOpenUsageInterval(intervalID))
				Console.WriteLine("Usage interval would have been successfully opened.");
			else
				Console.WriteLine("Usage interval would not have been successfully opened.");
		}

    private void CanOpenBillingGroup(int billingGroupID)
    {
      if (mClient.CanOpenBillingGroup(billingGroupID))
        Console.WriteLine("Billing Group would have been successfully opened.");
      else
        Console.WriteLine("Billing Group would not have been successfully opened.");
    }

    private int HardCloseUsageInterval(int intervalID, bool ignoreBillingGroups)
    {
      if (!ignoreBillingGroups)
      {
        if (!mClient.HasBeenFullyMaterialized(intervalID))
        {
          Console.WriteLine
          ("Either create billing groups for interval {0} or specify the /ignoreBG option.", intervalID);
          return 0;
        }
      }

      Console.WriteLine("Hard closing billing groups for usage interval {0}...", intervalID);
      int numBillingGroupsHardClosed = 0;

      mClient.HardCloseUsageInterval(intervalID, ignoreBillingGroups, out numBillingGroupsHardClosed);

      if (!ignoreBillingGroups)
      {
        Console.WriteLine
          ("[{0}] billing groups in Usage interval [{1}] were successfully hard closed.",
             numBillingGroupsHardClosed, intervalID);

        Rowset.IMTSQLRowset rowset = mClient.GetBillingGroupsRowset(intervalID, true);

        IUnassignedAccountsFilter filter = new UnassignedAccountsFilter();
        filter.IntervalId = intervalID;
        filter.Status = UnassignedAccountStatus.All;

        Rowset.IMTSQLRowset unAssignedRowset = mClient.GetUnassignedAccountsForIntervalAsRowset(filter);
        if (unAssignedRowset.RecordCount != 0)
        {
          Console.WriteLine("Warning: Please log into MetraControl for specific details and proceed with your eop from there.");
        }
      }
      return 0;
    }
    private int HardCloseUsageInterval(DateTime beforeDate)
    {
      Console.WriteLine("Hard closing intervals which have an end date prior to {0}...", beforeDate);
      int count = 0;

      count = mClient.HardCloseUsageIntervals(beforeDate);

      Console.WriteLine("[{0}] Intervals successfully hard closed.", count);
      return 0;
    }

    private int HardCloseBillingGroup(int billingGroupID)
    {
        int retval = 0;
      Console.WriteLine("Hard closing billing group {0}...", billingGroupID);
      try
      {
          mClient.HardCloseBillingGroup(billingGroupID);
          
          Console.WriteLine("Billing group was successfully hard closed.");
      }
        catch(Exception e)
      {
        Console.WriteLine("Billing group could not be hard closed!");
        Console.WriteLine("Error message was: {0}", e.Message);
        retval = 1;
      }

      
      return retval;
    }

		private void SubmitEventForExecution(int instanceID, bool ignoreDeps, DateTime effDate,
			string comment)
		{
			Console.WriteLine("Submitting event instance {0} for execution...", instanceID);
			if (effDate != DateTime.MinValue)
				Console.WriteLine("Event instance will execute no earlier than {0}.", effDate);
			if (ignoreDeps)
				System.Console.WriteLine("Dependencies will be ignored!");

			mClient.SubmitEventForExecution(instanceID, ignoreDeps, effDate, comment);
			mClient.NotifyServiceOfSubmittedEvents();

			Console.WriteLine("Event instance was successfully submitted.");
		}

		private void SubmitEvents(RecurringEventAction action,
			IRecurringEventInstanceFilter instances,
			bool ignoreDeps, DateTime effDate, string comment)
		{
			string noun = "";
			bool singleInstance = instances.GetInstanceCriteria().Count == 1;
			
			switch (action)
			{
				case RecurringEventAction.Execute:
					noun = "execution";
				
					// only adds the status criteria if a single instance wasn't selected
					if (!singleInstance)
					{
						instances.AddStatusCriteria(RecurringEventInstanceStatus.NotYetRun);
						instances.AddStatusCriteria(RecurringEventInstanceStatus.ReadyToRun);
					}
					break;
				
				case RecurringEventAction.Reverse:
					noun = "reversal";
				
					// only adds the status criteria if a single instance wasn't selected
					if (!singleInstance)
					{
						instances.AddStatusCriteria(RecurringEventInstanceStatus.Succeeded);
						instances.AddStatusCriteria(RecurringEventInstanceStatus.Failed);
						instances.AddStatusCriteria(RecurringEventInstanceStatus.ReadyToReverse);
					}
					break;
			}
			
			// applies the instance filter
			instances.Apply();
			
			// did all instances get filtered out?
			if (instances.Count == 0)
				throw new CommandLineParserException("No event instances were found that match the criteria specified!");

			string effDateStr = "";
			if (effDate != DateTime.MinValue)
				effDateStr = String.Format(" no earlier than {0}", effDate.ToString());
			string ignoreDepsStr = "";
			if (ignoreDeps)
				ignoreDepsStr = " (ignoring dependencies)";
			Console.WriteLine("Submitting {0} events for {1}{2}{3}...",
				instances.Count, noun, effDateStr, ignoreDepsStr);

			int count = 0;
			foreach (int instance in instances)
			{
				try
				{
					mClient.SubmitEvent(action, instance, ignoreDeps, effDate, comment);
					count++;
				}
				catch (UsageServerException e)
				{
					Console.WriteLine(e.Message);
				}
			}

      if (count < instances.Count)
				Console.WriteLine("  {0} events failed to be submitted!", instances.Count - count);

			if (count > 0)
			{
				Console.WriteLine("  {0} events were successfully submitted.", count);
				mClient.NotifyServiceOfSubmittedEvents();
			}

		}

    private void IgnoreEndRootDependenciesForBillingGroup(int billingGroupId)
    {
      mClient.IgnoreEndRootDependenciesForBillingGroup(billingGroupId);
    }

    private void IgnoreEndRootDependenciesForInterval(int intervalId)
    {
      mClient.IgnoreEndRootDependenciesForInterval(intervalId);
    }

		private void CancelSubmittedEvents(IRecurringEventInstanceFilter instances, string comment)
		{
			// no specific status was given, so only include cancellable instances
			if (instances.GetStatusCriteria().Count == 0)
			{
				instances.AddStatusCriteria(RecurringEventInstanceStatus.ReadyToRun);
				instances.AddStatusCriteria(RecurringEventInstanceStatus.ReadyToReverse);
			}

			// applies the instance filter
			instances.Apply();

			// the filter filtered everything out
			if (instances.Count == 0)
			{
				Console.WriteLine("No event instances were found that match the criteria specified!");
				return;
			}

			Console.WriteLine("Cancelling {0} events...", instances.Count);
			mClient.CancelSubmittedEvents(instances, comment);
			Console.WriteLine("  {0} events were successfully cancelled.", instances.Count);
		}

		private void OverrideEventStatus(int instanceID, RecurringEventInstanceStatus status, string comment)
		{
			Console.WriteLine("Overriding event instance {0}'s status to '{1}'...", instanceID, status);
			switch (status)
			{
				case RecurringEventInstanceStatus.Succeeded:
					mClient.MarkEventAsSucceeded(instanceID, comment);
					break;
				case RecurringEventInstanceStatus.Failed:
					mClient.MarkEventAsFailed(instanceID, comment);
					break;
				case RecurringEventInstanceStatus.NotYetRun:
					mClient.MarkEventAsNotYetRun(instanceID, comment);
					break;
			}

			Console.WriteLine("  Successfully overrided instance {0}'s status.", instanceID);
		}

		private void ProcessEvents()
		{
			Console.WriteLine("Processing submitted events...");

			int executions, executionFailures;
			int reversals, reversalFailures;
			mClient.ProcessEvents(out executions, out executionFailures, 
				out reversals, out reversalFailures);

			if (executions > 0)
				Console.WriteLine("  {0} events executed successfully.", executions);
			if (executionFailures > 0)
				Console.WriteLine("  {0} events failed while executing!\a", executionFailures);
			if (reversals > 0)
				Console.WriteLine("  {0} events reversed successfully.", reversals);
			if (reversalFailures > 0)
				Console.WriteLine("  {0} events failed while reversing!\a", reversalFailures);

			if (executions + executionFailures + reversals + reversalFailures == 0)
				Console.WriteLine("  No events were able to be processed at this point in time.");
				
		}

		private int InstantiateScheduledEvent(string eventName, DateTime endDate)
		{
			Console.WriteLine("Instantiating scheduled event...");
			IRecurringEvent recurringEvent = mClient.GetEventByName(eventName);

			int instanceID = mClient.InstantiateScheduledEvent(recurringEvent.EventID, endDate);
			Console.WriteLine("Instance {0} was successfully created/updated.", instanceID);
			return instanceID;
		}

		private void CreateAdapterTest(RecurringEvent recurringEvent,
			RecurringEventRunContext context,
			string comment)
		{
			Console.WriteLine("Creating test event and test instance...");
			int instanceID = mClient.CreateAdapterTest(recurringEvent, context);
			Console.WriteLine("Instance {0} successfully created for testing.", instanceID);

			// ignore deps so that cross-interval dependencies don't get in the way
			SubmitEventForExecution(instanceID, true, DateTime.MinValue, comment);
		}

    private void ListEventInstances(IRecurringEventInstanceFilter instances,
      bool showGenericTitle, bool longFormat,
      bool listScheduled, bool listEOP, bool listCheckpoint)
    {
      ListEventInstances(instances,
                         showGenericTitle ? "List of Recurring Event Instances" : null,
                         longFormat,
                         listScheduled, listEOP, listCheckpoint);
    }

		private void ListEventInstances(IRecurringEventInstanceFilter instances,
			string titleForList, bool longFormat,
			bool listScheduled, bool listEOP, bool listCheckpoint)
		{
			if (!string.IsNullOrEmpty(titleForList))
				Console.WriteLine(titleForList);

			if (listEOP || listCheckpoint)
				ListEndOfPeriodEventInstances(instances, longFormat, listEOP, listCheckpoint);

			if (listScheduled)
				ListScheduledEventInstances(instances, longFormat);
		}

		private void ListEndOfPeriodEventInstances(IRecurringEventInstanceFilter instances,
			bool longFormat,
			bool listEOP, bool listCheckpoint)
		{
			// TODO: date format specifiers "G" and "g" don't seem to work
			const string dateFormat = "MM/dd/yyyy HH:mm:ss";

			Rowset.IMTSQLRowset rowset = instances.GetEndOfPeriodRowset(listEOP, listCheckpoint);
				
			int oldIntervalID = 0;
      int billingGroupIntervalId = 0;
			string intervalInfo = "";
			while (!System.Convert.ToBoolean(rowset.EOF))
			{
				//
				// retireves instance information
				//
				int instanceID = (int) rowset.get_Value("InstanceID");

				string eventName = (string) rowset.get_Value("EventName");
				// truncates the event name for the concise view
				if (!longFormat && eventName.Length > 25) 
					eventName = eventName.Substring(0, 25);

				string displayName = (string) rowset.get_Value("EventDisplayName");
				string eventType = (string) rowset.get_Value("EventType");
				int intervalID = (int) rowset.get_Value("ArgIntervalID");

        // Get the billing group id
        string billingGroupID = "N/A";
        object dbBillingGroupID = rowset.get_Value("BillGroupID");
        if (dbBillingGroupID != DBNull.Value) 
        {
          billingGroupID = dbBillingGroupID.ToString();
          if (billingGroupIntervalId == 0)
          {
            billingGroupIntervalId = intervalID;
          }
        }
        else 
        {
          // if this is for a billing group then 
          // skip rows which do not belong to the billing group's interval
          if (instances.BillingGroupID != 0) 
          {
            if (intervalID != billingGroupIntervalId) 
            {
              rowset.MoveNext();
              continue;
            }
          }
        }

        // Get the billing group support type
        string billGroupSupportType = "N/A";
        object dbbillGroupSupportType = rowset.get_Value("BillGroupSupportType");
        if (dbbillGroupSupportType != DBNull.Value) 
        {
          billGroupSupportType = dbbillGroupSupportType.ToString();
        }

				RecurringEventInstanceStatus status = (RecurringEventInstanceStatus)
					Enum.Parse(typeof(RecurringEventInstanceStatus), (string) rowset.get_Value("Status"));

				string ignoreDeps = (string) rowset.get_Value("IgnoreDeps");
				if (ignoreDeps == "Y")
					ignoreDeps = "True";
				else
					ignoreDeps = "False";

				string effDate = "Anytime";
				if (rowset.get_Value("EffectiveDate") != DBNull.Value)
				{
					DateTime date = (DateTime) rowset.get_Value("EffectiveDate");
					effDate = date.ToString(dateFormat);
				}

				//
				// gets last run info if available
				//
				bool hasRun = false;
				int runID = 0;
				RecurringEventAction runAction = RecurringEventAction.Execute;
				DateTime runStart = DateTime.MinValue;
				string runEnd = "Not yet finsihed";
				int runBatches = 0;
				string runDetail = "None";
        string runMachine = "";
				int runWarnings = 0;
				string warningFlag = "";
				object val = rowset.get_Value("LastRunID");
				if (val != DBNull.Value)
				{
					hasRun = true;
					runID = (int) val;
					runAction = (RecurringEventAction) 
						Enum.Parse(typeof(RecurringEventAction), (string) rowset.get_Value("LastRunAction"));
					runStart = (DateTime) rowset.get_Value("LastRunStart");

					object runEndVal = rowset.get_Value("LastRunEnd");
					if (runEndVal != DBNull.Value)
						runEnd = ((DateTime) runEndVal).ToString(dateFormat);

					runBatches = Convert.ToInt32(rowset.get_Value("LastRunBatches"));

					object runDetailVal = rowset.get_Value("LastRunDetail");
					if (runDetailVal != DBNull.Value)
						runDetail = (string) runDetailVal;

          object machineVal = rowset.get_Value("LastRunMachine");
          if (machineVal != DBNull.Value)
            runMachine = (string)machineVal;

					runWarnings = Convert.ToInt32(rowset.get_Value("LastRunWarnings"));
					if (runWarnings > 0)
					{
						if (longFormat)
							warningFlag = " (with warnings!)";
						else
							warningFlag = " (!)";
					}
				}

				// gets the interval's status
				if (intervalID != oldIntervalID)
				{
					DateTime intervalStart;
					DateTime intervalEnd;
					string intervalStatus;
					mClient.GetUsageIntervalInfo(intervalID, 
						out intervalStart,
						out intervalEnd,
						out intervalStatus);
					intervalInfo = String.Format("{0} ({1} - {2})",
						intervalID,
						intervalStart.ToString(dateFormat),
						intervalEnd.ToString(dateFormat));
				}

        
				//
				// displays the info
				//
				if (longFormat)
				{
					Console.WriteLine();
					Console.WriteLine("Instance ID       : {0}", instanceID);
          Console.WriteLine("BillGroup ID      : {0}", billingGroupID);
          Console.WriteLine("BillGroup Support : {0}", billGroupSupportType);
					Console.WriteLine("Event Name        : {0}", eventName);
					Console.WriteLine("Display Name      : {0}", displayName);
					Console.WriteLine("Event Type        : {0}", eventType);
					Console.WriteLine("Interval ID       : {0}", intervalInfo);

					if (status == RecurringEventInstanceStatus.ReadyToRun ||
						status == RecurringEventInstanceStatus.ReadyToReverse)
					{
						Console.WriteLine("Process after    : {0}", effDate);
						Console.WriteLine("Ignore Deps      : {0}", ignoreDeps);
					}
					
					if (hasRun)
					{
						Console.WriteLine("Last Run ID      : {0}", runID);
						Console.WriteLine("Last Run Action  : {0}", runAction.ToString());
						Console.WriteLine("Last Run Start   : {0}", runStart.ToString(dateFormat));
						Console.WriteLine("Last Run End     : {0}", runEnd);
						if (runBatches > 0)
							Console.WriteLine("Last Run Batches : {0}", runBatches);
						Console.WriteLine("Last Run Detail  : {0}", runDetail);
            Console.WriteLine("Last Run Machine : {0}", runMachine);
					}
					Console.WriteLine("Status           : {0}{1}", status, warningFlag);

				}
				else
				{
					// uses the concise display format
					
					if (intervalID != oldIntervalID)
					{
						// displays the usage interval banner
						Console.WriteLine();
						Console.WriteLine(" Usage Interval: {0}", intervalInfo);
						Console.WriteLine();
						Console.WriteLine("  Inst ID  BlGrpID Event Name                 Status             BG Support");
						Console.WriteLine("  --------|-------|--------------------------|------------------|----------");
						oldIntervalID = intervalID;
					}
					Console.WriteLine("  {0,-8} {1,-8}{2,-25}  {3,-14}{4,-3}  {5,-5}", 
            instanceID, billingGroupID, eventName, status, warningFlag, billGroupSupportType);
				}
				
				rowset.MoveNext();
			}
		}

		private void ListScheduledEventInstances(IRecurringEventInstanceFilter instances,
			bool longFormat)
		{
			//TODO: date format specifiers "G" and "g" don't seem to work
			const string dateFormat = "MM/dd/yyyy HH:mm:ss";
      DateTime startDate;
      DateTime endDate;

			Rowset.IMTSQLRowset rowset = instances.GetScheduledRowset();
			
			string oldEventName = "";
			while (!System.Convert.ToBoolean(rowset.EOF))
			{
				//
				// retrieves instance information
				//
				int instanceID = (int) rowset.get_Value("InstanceID");
				
				string eventName = (string) rowset.get_Value("EventName");
				if (!longFormat && eventName.Length > 25) 
					eventName = eventName.Substring(0, 25);
				string displayName = (string) rowset.get_Value("EventDisplayName");
				string eventType = (string) rowset.get_Value("EventType");
				
        // Display Min Date if a null is retrieved
        if (rowset.get_Value("ArgStartDate") != DBNull.Value)
        {
          startDate = (DateTime)rowset.get_Value("ArgStartDate");
        }
        else
        {
          startDate = System.DateTime.MinValue;
        }

        if (rowset.get_Value("ArgEndDate") != DBNull.Value)
        {
          endDate = (DateTime)rowset.get_Value("ArgEndDate");
        }
        else
        {
          endDate = System.DateTime.MinValue;
        }

				RecurringEventInstanceStatus status = (RecurringEventInstanceStatus)
					Enum.Parse(typeof(RecurringEventInstanceStatus), (string) rowset.get_Value("Status"));

				string ignoreDeps = (string) rowset.get_Value("IgnoreDeps");
				if (ignoreDeps == "Y")
					ignoreDeps = "True";
				else
					ignoreDeps = "False";
				
				string effDate = "Anytime";
				if (rowset.get_Value("EffectiveDate") != DBNull.Value)
				{
					DateTime date = (DateTime) rowset.get_Value("EffectiveDate");
					effDate = date.ToString(dateFormat);
				}

				//
				// gets last run info if available
				//
				bool hasRun = false;
				int runID = 0;
				RecurringEventAction runAction = RecurringEventAction.Execute;
				DateTime runStart = DateTime.MinValue;
				string runEnd = "Not yet finsihed";
				int runBatches = 0;
				string runDetail = "None";
				int runWarnings = 0;
				string warningFlag = "";
        string machine = "";

				object val = rowset.get_Value("LastRunID");
				if (val != DBNull.Value)
				{
					hasRun = true;
					runID = (int) val;
					runAction = (RecurringEventAction)
						Enum.Parse(typeof(RecurringEventAction), (string) rowset.get_Value("LastRunAction"));
					runStart = (DateTime) rowset.get_Value("LastRunStart");

					object runEndVal = rowset.get_Value("LastRunEnd");
					if (runEndVal != DBNull.Value)
						runEnd = ((DateTime) runEndVal).ToString(dateFormat);

					runBatches = Convert.ToInt32(rowset.get_Value("LastRunBatches"));

					object runDetailVal = rowset.get_Value("LastRunDetail");
					if (runDetailVal != DBNull.Value)
						runDetail = (string) runDetailVal;

          object machineVal = rowset.get_Value("LastRunMachine");
          if (machineVal != DBNull.Value)
            machine = (string)machineVal;

					runWarnings = Convert.ToInt32(rowset.get_Value("LastRunWarnings"));
					if (runWarnings > 0)
					{
						if (longFormat)
							warningFlag = " (with warnings!)";
						else
							warningFlag = " (!)";
					}
				}
				
				//
				// displays the info
				//
				if (longFormat)
				{
					Console.WriteLine();
					Console.WriteLine("Instance ID      : {0}", instanceID);
					Console.WriteLine("Event Name       : {0}", eventName);
					Console.WriteLine("Display Name     : {0}", displayName);
					Console.WriteLine("Event Type       : {0}", eventType);
					Console.WriteLine("Start Date Arg   : {0}", startDate.ToString(dateFormat));
					Console.WriteLine("End Date Arg     : {0}", endDate.ToString(dateFormat));

					if (status == RecurringEventInstanceStatus.ReadyToRun ||
						status == RecurringEventInstanceStatus.ReadyToReverse)
					{
						Console.WriteLine("Process after    : {0}", effDate);
						Console.WriteLine("Ignore Deps      : {0}", ignoreDeps);
					}

					if (hasRun)
					{
						Console.WriteLine("Last Run ID      : {0}", runID);
						Console.WriteLine("Last Run Action  : {0}", runAction.ToString());
						Console.WriteLine("Last Run Start   : {0}", runStart.ToString(dateFormat));
						Console.WriteLine("Last Run End     : {0}", runEnd);
						if (runBatches > 0)
							Console.WriteLine("Last Run Batches : {0}", runBatches);
						Console.WriteLine("Last Run Detail  : {0}", runDetail);
            Console.WriteLine("Last Run Machine : {0}", machine);
					}

					Console.WriteLine("Status           : {0}{1}", status, warningFlag);
				}
				else
				{
					// uses the concise display format
					
					// displays the event name banner
					if (eventName != oldEventName)
					{
						Console.WriteLine();
						Console.WriteLine(" Scheduled Event: {0}", eventName);
						Console.WriteLine();
						Console.WriteLine("  Instance ID  Start Date           End Date             Status");
						Console.WriteLine("  -----------|--------------------|--------------------|---------------");
						oldEventName = eventName;
					}
					//                   inst  start   end     status
					Console.WriteLine("  {0,11}  {1,-18}  {2,-18}  {3}{4}",
						instanceID, startDate.ToString(dateFormat),
						endDate.ToString(dateFormat), status, warningFlag);
				}
				
				rowset.MoveNext();
			}
		}

		private void ListUsageIntervals(UsageIntervalFilter intervals)
		{
			const string dateFormat = "MM/dd/yyyy";

			ArrayList intervalList = intervals.GetIntervals();

			Console.WriteLine("List of Usage Intervals");
			Console.WriteLine();
			Console.WriteLine(" IntrvlID         Start Date  End Date     Cycl Cycle     Total   Open SC   HC");
      Console.WriteLine(" State[O,H,B]                              ID   Type      BG      BG   BG   BG");
			Console.WriteLine(" ----------------|-----------|-----------|----|---------|-------|----|----|----");
      foreach(IUsageInterval usageInterval in intervalList)
      {
        //
        // retrieves interval information
        //

        Console.WriteLine(" {0,-14} {1,-10}  {2,-10}  {3,4} {4,-9} {5,2} ({6,-2}) {7,3}  {8,3}  {9,3}",
          usageInterval.IntervalID + " [" + usageInterval.Status + "]", 
          usageInterval.StartDate.ToString(dateFormat),
          usageInterval.EndDate.ToString(dateFormat), 
          usageInterval.CycleID, 
          usageInterval.CycleType.ToString(), 
          usageInterval.TotalGroupCount, 
          usageInterval.OpenUnassignedAccountsCount + usageInterval.HardClosedUnassignedAccountsCount,
          usageInterval.OpenGroupCount, 
          usageInterval.SoftClosedGroupCount,
          usageInterval.HardClosedGroupCount);

        //				int intervalID = (int) rowset.get_Value("IntervalID");
        //        string status = (string) rowset.get_Value("Status");
        //				DateTime startDate = (DateTime) rowset.get_Value("StartDate");
        //				DateTime endDate = (DateTime) rowset.get_Value("EndDate");
        //				int cycleID = (int) rowset.get_Value("CycleID");
        //				string cycleTypeName = (string) rowset.get_Value("CycleType");
        //        int totalGroupCount = (int) rowset.get_Value("TotalGroupCount");
        //        int openGroupCount = (int) rowset.get_Value("OpenGroupCount");
        //        int softClosedGroupCount = (int) rowset.get_Value("SoftClosedGroupCount");
        //        int hardClosedGroupCount = (int) rowset.get_Value("HardClosedGroupCount");
        //        int openUnassignedAccountsCount = (int) rowset.get_Value("OpenUnassignedAccountsCount");
        //        int hardClosedUnassignedAccountsCount = (int) rowset.get_Value("HardClosedUnassignedAccountsCount");
      }
		}

		private void ListUsageIntervals(ArrayList intervals)
		{
			const string dateFormat = "MM/dd/yyyy";

			Console.WriteLine(" IntrvlID  Start Date  End Date   CycleID  Cycle Type   Status");
			Console.WriteLine(" ---------|-----------|-----------|-------|------------|----------");

			foreach (UsageInterval ui in intervals)
				Console.WriteLine(" {0,-8}  {1,-10}  {2,-10}  {3, -7} {4,-12} {5,-11}",
					ui.IntervalID, ui.StartDate.ToString(dateFormat),
					ui.EndDate.ToString(dateFormat), ui.CycleID, ui.CycleType, ui.Status);
		}

    private void ListBillingGroups(ArrayList billingGroups)
    {
      const string dateFormat = "MM/dd/yyyy";

      Console.WriteLine(" BillGrpID  IntrvlID  Start Date  End Date   CycleID  Cycle Type   Status");
      Console.WriteLine(" ---------|---------|-----------|-----------|-------|------------|----------");

      foreach (IBillingGroup bg in billingGroups)
        Console.WriteLine(" {0,-8}  {1,-8}  {2,-10}  {3,-10}  {4, -7} {5,-12} {6,-11}",
          bg.BillingGroupID, bg.IntervalID, bg.StartDate.ToString(dateFormat),
          bg.EndDate.ToString(dateFormat), bg.CycleID, bg.CycleType, bg.Status);
    }

    private void ListBillingGroupsExtended(IBillingGroupFilter filter)
    {
      const string dateFormat = "MM/dd/yyyy HH:mm:ss";

      Rowset.IMTSQLRowset rowset = mClient.GetBillingGroupsRowset(filter);

      int oldIntervalID = 0;

      while (!System.Convert.ToBoolean(rowset.EOF)) 
      {
        int intervalID = (int)rowset.get_Value("IntervalID");
        int billingGroupID = (int)rowset.get_Value("BillingGroupID");
        string name = (string)rowset.get_Value("Name");
        string status = 
          BillingGroup.ParseBillingGroupStatus((string)rowset.get_Value("Status")).ToString();
        int memberCount = Convert.ToInt32(rowset.get_Value("MemberCount"));
        string hasChild = (string)rowset.get_Value("HasChildren");

        string parentBillGrpID = "N/A";
        object dbParentBillGrpID = rowset.get_Value("ParentBillingGroupID");
        if (dbParentBillGrpID != DBNull.Value) 
        {
          parentBillGrpID = dbParentBillGrpID.ToString();
        }

        if (intervalID != oldIntervalID)
        {
          string intervalInfo = 
            String.Format("{0} ({1} - {2})",
                          intervalID,
                          ((DateTime)rowset.get_Value("StartDate")).ToString(dateFormat),
                          ((DateTime)rowset.get_Value("EndDate")).ToString(dateFormat));

          Console.WriteLine();
          Console.WriteLine(" Usage Interval: {0}", intervalInfo);
          Console.WriteLine();

          Console.WriteLine();
          Console.WriteLine("  BlGrpID Name            Status      MembCount HasChild ParentBillGrpID   ");
          Console.WriteLine("  -------|---------------|-----------|---------|--------|---------------");

          oldIntervalID = intervalID;
        }

        Console.WriteLine("  {0,-7} {1,-15} {2,-10}  {3,9} {4,-1}        {5,-4}", 
          billingGroupID, name, status, memberCount, hasChild, parentBillGrpID);
  
        rowset.MoveNext();
      }
    }

		private void ListEventRuns(RecurringEventRunFilter runs, bool longFormat)
		{
			//TODO: date format specifiers "G" and "g" don't seem to work
			const string dateFormat = "MM/dd/yyyy HH:mm:ss";

			Rowset.IMTSQLRowset rowset = runs.GetRowset();

			Console.WriteLine("List of Recurring Event Runs");
			int oldInstanceID = 0;
			while (!System.Convert.ToBoolean(rowset.EOF))
			{
				// default values if these items are null
				string endDate = "N/A";
				string reversedRun = "N/A";
				string result = "None";
        int batches = 0;
        string machine = "";

				int runID = (int) rowset.get_Value("RunID");
				int instanceID = (int) rowset.get_Value("InstanceID");

				RecurringEventAction action = (RecurringEventAction)
					Enum.Parse(typeof(RecurringEventAction), (string) rowset.get_Value("Action"));

				object reversedRunVal = rowset.get_Value("ReversedRunID");
				if (reversedRunVal != DBNull.Value)
					reversedRun = ((int) reversedRunVal).ToString();				

				DateTime startDate = (DateTime) rowset.get_Value("StartDate");
				
				object endDateVal = rowset.get_Value("EndDate");
				if (endDateVal != DBNull.Value)
					endDate = ((DateTime) endDateVal).ToString(dateFormat);

        object batchesVal = rowset.get_Value("Batches");
        if (batchesVal != DBNull.Value)
          batches = Convert.ToInt32(batchesVal);

				object resultVal = rowset.get_Value("Result");
				if (resultVal != DBNull.Value)
					result = (string) resultVal;

				string strHasDetails = (string) rowset.get_Value("HasDetails");
				bool hasDetails = (strHasDetails == "Y") ? true : false;
					
        object machineVal = rowset.get_Value("Machine");
        if (machineVal != DBNull.Value)
          machine = (string)machineVal;

				RecurringEventRunStatus status = (RecurringEventRunStatus)
					Enum.Parse(typeof(RecurringEventRunStatus), (string) rowset.get_Value("Status"));

				if (longFormat)
				{
					Console.WriteLine();
					Console.WriteLine("Run ID          : {0}", runID);
					Console.WriteLine("Instance ID     : {0}", instanceID);
					Console.WriteLine("Action          : {0}", action);
					Console.WriteLine("Reversed Run ID : {0}", reversedRun);
					Console.WriteLine("Start Date      : {0}", startDate.ToString(dateFormat));
					Console.WriteLine("End Date        : {0}", endDate);
					Console.WriteLine("Batches         : {0}", batches);
					Console.WriteLine("Detail          : {0}", result);
					Console.WriteLine("More Details    : {0}", hasDetails);
					Console.WriteLine("Status          : {0}", status);
          Console.WriteLine("Machine         : {0}", machine);
				}
				else
				{
					if (instanceID != oldInstanceID)
					{
						Console.WriteLine();
						Console.WriteLine("Instance ID: {0}", instanceID);
						Console.WriteLine();
						Console.WriteLine(" Run ID        Start Date           End Date        Action    Status     Machine  ");
            Console.WriteLine(" -------|--------------------|--------------------|--------|----------|-----------");
						oldInstanceID = instanceID;
					}
					
					Console.WriteLine(" {0,-7}  {1,-18}  {2,-18}  {3,-7}  {4,-10} {5,-24}",
						runID, startDate.ToString(dateFormat), endDate, action, status, machine);
				}

				rowset.MoveNext();
			}
		}
		
		private void ListInstanceDeps(IRecurringEventInstanceFilter instances,
			RecurringEventDependencyType depType,
			RecurringEventDependencyStatus depStatus)
		{
			//TODO: date format specifiers "G" and "g" don't seem to work
			const string dateFormat = "MM/dd/yyyy HH:mm:ss";

			instances.Apply();
			Rowset.IMTSQLRowset rowset = mClient.GetDependenciesByInstanceRowset(instances, depType, depStatus);
			
			int oldOrigInstanceID = Int32.MinValue;
    	string oldEventName = "";
			int oldIntervalID = 0;      
			
			while (!Convert.ToBoolean(rowset.EOF))
			{
				//
				// retrieves instance information
				//
				int origInstanceID = Convert.ToInt32(rowset.get_Value("OriginalInstanceID"));
        string origEventName = (string) rowset.get_Value("OriginalEventName");

        string origBillGroupSupportType = "N/A";
        object dbOrigBillGroupSupportType = rowset.get_Value("OriginalBillGroupSupportType");
        if (dbOrigBillGroupSupportType != DBNull.Value) 
        {
          origBillGroupSupportType = dbOrigBillGroupSupportType.ToString();
        }

        string depBillGroupSupportType = "N/A";
        object dbDepBillGroupSupportType = rowset.get_Value("BillGroupSupportType");
        if (dbDepBillGroupSupportType != DBNull.Value) 
        {
          depBillGroupSupportType = dbDepBillGroupSupportType.ToString();
        }

        string origBillingGroupID = "N/A";
        object dbOrigBillingGroupID = rowset.get_Value("OriginalBillingGroupID");
        if (dbOrigBillingGroupID != DBNull.Value) 
        {
          origBillingGroupID = dbOrigBillingGroupID.ToString();
        }

        string depBillingGroupID = "N/A";
        object dbDepBillingGroupID = rowset.get_Value("BillingGroupID");
        if (dbDepBillingGroupID != DBNull.Value) 
        {
          depBillingGroupID = dbDepBillingGroupID.ToString();
        }

				string depInstanceID = "N/A";
				object dbInstanceID = rowset.get_Value("InstanceID");
				if (dbInstanceID != DBNull.Value)
					depInstanceID = dbInstanceID.ToString();

				string eventName = (string) rowset.get_Value("EventName");
				if (eventName.Length > 25) 
					eventName = eventName.Substring(0, 25);

				RecurringEventType eventType = (RecurringEventType) 
					Enum.Parse(typeof(RecurringEventType), (string) rowset.get_Value("EventType"));

				string startDate = "";
				string endDate = "";
				int intervalID = 0;
				if (eventType == RecurringEventType.Scheduled)
				{
					DateTime dbStartDate = (DateTime) rowset.get_Value("ArgStartDate");
					startDate = dbStartDate.ToString(dateFormat);

					DateTime dbEndDate = (DateTime) rowset.get_Value("ArgEndDate");
					endDate = dbEndDate.ToString(dateFormat);
				}
				else
					intervalID = Convert.ToInt32(rowset.get_Value("ArgIntervalID"));

				string status = (string) rowset.get_Value("Status");

      	//
				// displays the info
				//

				if (origInstanceID != oldOrigInstanceID)
				{
					Console.WriteLine();
          Console.WriteLine("Status of Dependencies for Recurring Event Instance");
					Console.WriteLine
            ("  Name:             {0}", origEventName);
          Console.WriteLine
            ("  Instance ID:      {0}", origInstanceID);
          Console.WriteLine
            ("  Billing Group ID: {0} [{1}]", origBillingGroupID, origBillGroupSupportType);
					Console.WriteLine();
					oldOrigInstanceID = origInstanceID;
				}

				if (eventType == RecurringEventType.Scheduled)
				{
					if (oldEventName != eventName)
					{
						Console.WriteLine();
						Console.WriteLine(" Scheduled Event {0}:", eventName);
						Console.WriteLine();
						Console.WriteLine("  Instance ID  Start Date           End Date             Status");
						Console.WriteLine("  -----------|--------------------|--------------------|---------------");
						oldEventName = eventName;
					}
					//                   inst  start   end     status
					Console.WriteLine("  {0,11}  {1,18}  {2,18}  {3,-14}",
						depInstanceID, startDate, endDate, status);
				}
				else
				{
					if (oldIntervalID != intervalID)
					{
						DateTime intervalStart;
						DateTime intervalEnd;
						string intervalStatus;
						mClient.GetUsageIntervalInfo(intervalID, 
							out intervalStart,
							out intervalEnd,
							out intervalStatus);
						string intervalInfo = String.Format("{0} ({1} - {2})",
							intervalID,
							intervalStart.ToString(dateFormat),
							intervalEnd.ToString(dateFormat));
						// displays the usage interval banner
						Console.WriteLine();
						Console.WriteLine(" Usage Interval: {0}", intervalInfo);
						Console.WriteLine();
						Console.WriteLine("  InstID    BillGroupID   Event Name               Status          BG Support");
						Console.WriteLine("  ---------|-----------|--------------------------|---------------|-----------");

						oldIntervalID = intervalID;
					}
					Console.WriteLine("  {0,-8}  {1,-9}   {2,-25}  {3,-14}  {4,-10}", 
                            depInstanceID, depBillingGroupID, eventName, status, depBillGroupSupportType);

				}
				
				rowset.MoveNext();
			}
		}

		private void GenerateDOTOutput(bool includeRootEvents)
		{
			Console.WriteLine(mClient.GenerateDOTOutput(includeRootEvents));
		}

		private void Kill()
		{
			if (mParser.GetBooleanOption("?", false))
			{
				Console.WriteLine("Usage: usm kill");
				Console.WriteLine();
				Console.WriteLine("Attempts to kill the recurring event currently being processed.");
				return;
			}

			Console.WriteLine("Attempting to kill the recurring event currently being processed...");
			mClient.KillCurrentlyProcessingRecurringEvent();
			Console.WriteLine("Kill request made successfully.");
			Console.WriteLine("Please check the status of the recurring event instance in question.");
		}

		private void DisplayUsage()
		{
			Console.WriteLine("Usage: usm action [options] [/?]");
			Console.WriteLine();
			Console.WriteLine("Actions:");
			Console.WriteLine("  sync                 synchronizes database with configuration files");
			Console.WriteLine("  create               creates new usage intervals");
			Console.WriteLine("  materialize          creates new billing groups");
      Console.WriteLine("  close                closes usage intervals");
			Console.WriteLine("  open                 opens an already closed usage interval");
			Console.WriteLine("  run                  submits events for execution");
			Console.WriteLine("  reverse              submits events for reversal");
			Console.WriteLine("  cancel               cancels submitted events");
			Console.WriteLine("  override             overrides events status");
			Console.WriteLine("  test                 submits a test run for an adapter");
			Console.WriteLine("  list-intervals       lists usage intervals (short form: 'lui')");
      Console.WriteLine("  list-billing-groups  lists billing groups (short form: 'lbg')");
			Console.WriteLine("  list-instances       lists recurring event instances (short form: 'li')");
			Console.WriteLine("  list-deps            lists recurring event dependencies (short form: 'ldeps')");
			Console.WriteLine("  list-runs            lists recurring event runs (short form: 'lr')");
			//Console.WriteLine("  all                  performs create, close, and run actions in this order");
			Console.WriteLine("  wait                 waits for event processing to complete");
			Console.WriteLine("  kill                 attempts to kill the recurring event currently");
			Console.WriteLine("                       being processed");
			Console.WriteLine();
			Console.WriteLine("Help on a particular action is available by adding a /? switch to the command.");
			Console.WriteLine("For example: usm run /?");
		}

		string [] mArgs;
		CommandLineParser mParser;
		Client mClient;		
	}
}

