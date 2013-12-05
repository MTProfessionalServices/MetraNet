using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Runtime.CompilerServices;

[assembly: InternalsVisibleTo("MetraTech.UsageServer.Test, PublicKey=00240000048000009400000006020000002400005253413100040000010001009993f9ecb650f0bf59efed30ebc31bd85224c1b5905a43f1eb8907b85adea02a4a94e3fd66bb594b04066fa4f836e2c09f88bf3ca9ef98ee58cc2a8ece11c804f48306f053932fe4d711c3250b94c769d141bb76a466732466908441d4c27d9d5279758e548b0c038de1f664130e1232c2df09a53c35d1746de7966bdf27e798")]

namespace MetraTech.UsageServer
{
	using System;
  using System.Text;
	using System.Diagnostics;
	using System.Collections;
	using System.Runtime.InteropServices;

	using MetraTech;
	using DataAccess;
	using Xml;
	using Rowset = Interop.Rowset;
 
	[Guid("F8F2FE64-3ED3-30C2-A676-5C282944A73B")]
	public enum UsageIntervalStatus
	{
    Open,
    SoftClosed,
    HardClosed,
		Billable, 
		Active,
		Completed,
    All,
    Blocked
	}

	/// <remarks>
	/// Public interval management API.
	/// Implementation of IUsageIntervalManager.
	/// </remarks>
	[ComVisible(false)]
	public class UsageIntervalManager
	{
		/// <summary>
		/// Constructor.
		/// </summary>
		DateTime mPastStartDate;

		public UsageIntervalManager()
		{
			_mLogger = new Logger("[UsageServer]");
		}

    internal UsageIntervalManager(ILogger logger)
    {
      _mLogger = logger;
    }

		/// <summary>
		/// Synchronizes the database with interval settings in the usageserver.xml file
		/// </summary>
		public void Synchronize()
		{
			Synchronize(UsageServerCommon.UsageServerConfigFile);
		}

		/// <summary>
		/// Synchronizes the database with interval settings in any given file
		/// NOTE: public accessibility given only for the sake of unit testing
		/// </summary>
		public void Synchronize(string configFile)
		{
			_mLogger.LogDebug("Synchronizing interval settings from {0} configuration file", configFile);

			// reads in the config file
			Hashtable gracePeriods;
			int advanceIntervalCreationDays;
			try
			{
				ReadConfigFile(configFile, out gracePeriods, out advanceIntervalCreationDays);
			}
			catch (MTXmlException e)
			{ 
				throw new InvalidConfigurationException(String.Format("XML parsing error in file: {0}", configFile), e); 
			}
			
			// synchronizes the database
			bool changeDetected = false;
			using(var conn = DbConnectionFactory.CreateDbConnection())
			{
				if (WriteGracePeriodsToUsageCycleTypeTable(conn, gracePeriods))
					changeDetected = true;
				
				if (SynchronizeAdvanceIntervalCreationDays(conn, advanceIntervalCreationDays))
					changeDetected = true;
			}
			
			if (!changeDetected)
				_mLogger.LogDebug("No changes to interval settings were detected");
		}

		/// <summary>
		/// Adds any necessary reference intervals in the past/present/future
		/// </summary>
		public void CreateReferenceIntervals()
		{
			var now = MetraTime.Now;

			using(var conn = DbConnectionFactory.CreateDbConnection())
			{
        var lastDate = ComputeIntervalLastDate(conn);

        if (!lastDate.HasValue)
          return;
			  
			  // start one day after the last date found
				var startDate = lastDate.Value.AddDays(1);
				// one year, inclusive
				var endDate = startDate.AddYears(1);

				// we're either up to date but need to add more future intervals
				// or past intervals are missing

				if (startDate > now)
				{
					// add future intervals
					CreateReferenceIntervals(startDate, endDate);
				}
				else
				{
					// add past intervals.
					// intervals need to be added year by year so that the IDs remain consistent accross deployments
					var futureDate = now.AddYears(1);
					while (startDate < futureDate)
					{
						CreateReferenceIntervals(startDate, endDate);

						startDate = startDate.AddYears(1);

						endDate = startDate.AddYears(1);
					}
				}
			}
		}

	  private DateTime? ComputeIntervalLastDate(IMTConnection conn)
	  {
	    DateTime lastDate;
	    using (var stmt = conn.CreateAdapterStatement("Queries\\UsageServer", "__GET_LATEST_PC_INTERVAL_DATE__"))
	    {
	      using (var reader = stmt.ExecuteReader())
	      {
	        if (reader.Read())
	        {
	          // there are rows returned
	          lastDate = reader.GetDateTime("Date");
            
            // determine if we need more intervals
            if (MetraTime.Now.AddMonths(18) < lastDate)
              return null;					// at least 1.5 years worth of intervals
	        }
	        else
	        {
	          // reads in the config file
	          const string configFile = UsageServerCommon.UsageServerConfigFile;
	          try
	          {
	            Hashtable gracePeriods;
	            int advanceIntervalCreationDays;
	            ReadConfigFile(configFile, out gracePeriods, out advanceIntervalCreationDays);
	          }
	          catch (MTXmlException e)
	          {
	            throw new InvalidConfigurationException(String.Format("XML parsing error in file: {0}", configFile), e);
	          }
	          lastDate = mPastStartDate;
	        }
	      }
	    }
	    return lastDate;
	  }

	  /// <summary>
	  /// Creates all possible reference intervals between the two given dates.
	  /// </summary>
	  public ICollection<IUsageInterval> CreateReferenceIntervals(DateTime startDate, DateTime endDate)
	  {
	    _mLogger.LogInfo("Creating reference intervals between {0} and {1}",
	                    startDate, endDate);

	    var cycleTypes = UsageCycleTypes;

	    var intervals = new List<IUsageInterval>();

	    using (var bulkInsert = BulkInsertFactory.CreateBulkInsert())
	    {
	      bulkInsert.PrepareForInsert("t_pc_interval", 1000);

	      using (var conn = DbConnectionFactory.CreateDbConnection())
	      {
	        var intervalId = GetNextIntervalId(conn);

	        using (var stmt = conn.CreateAdapterStatement("Queries\\UsageServer", "__GET_ALL_USAGE_CYCLES__"))
	        {
	          using (var reader = stmt.ExecuteReader())
	          {
	            var cycle = new Cycle();
	            while (reader.Read())
	            {
	              cycle.Clear();
	              var rawCycleType = reader.GetInt32((int) CycleQueryColumns.IDCycleType);

	              var cycleId = reader.GetInt32((int) CycleQueryColumns.IDUsageCycle);

	              //
	              // see if both the cycle ID and cycle type are supported
	              //
	              if (CycleUtils.IsDiscontinuedCycleType(rawCycleType))
	              {
	                _mLogger.LogDebug("Skipping unsupported cycle {0}", rawCycleType);
	                continue;
	              }

	              if (!CycleUtils.IsSupportedCycleType(rawCycleType))
	                throw new UsageServerException(String.Format("Unsupported cycle type {0}", rawCycleType));

	              if (CycleUtils.IsDiscontinuedCycleId(cycleId))
	              {
	                _mLogger.LogDebug("Skipping unsupported cycle ID {0}", cycleId);
	                continue;
	              }

	              //
	              // cycle type and ID are supported
	              //
	              // populate all fields from the query
	              cycle.Populate(reader);

	              var cycleType = cycleTypes[rawCycleType];
	              Debug.Assert(cycleType != null);

	              // cycles coming back from the query should always be in canonical form
	              Debug.Assert(cycleType.IsCanonical(cycle));

	              intervals.AddRange(CreateReferenceCycles(bulkInsert, ref intervalId, cycleType, cycle,
	                                                       startDate, endDate));
	            }
	          }
	        }
	      }
	      // write any remaining data
	      bulkInsert.ExecuteBatch();
	    }
	    _mLogger.LogInfo("Added {0} intervals", intervals.Count);

	    return intervals;
	  }

	  /// <summary>
		/// Creates any necessary usage intervals in the present/future.
		/// </summary>
		public int CreateUsageIntervals()
		{
			ArrayList intervals = CreateUsageIntervals(false);
			return intervals.Count;
		}

		/// <summary>
		/// Creates any necessary usage intervals in the present/future.
		/// If pretend is True, then no intervals are actually created but
		/// are just returned. Returns a list of newly created intervals.
		/// </summary>
		public ArrayList CreateUsageIntervals(bool pretend)
		{
			if (pretend)
				_mLogger.LogDebug("Pretending to create new usage intervals...");
			else
				_mLogger.LogInfo("Creating new usage intervals...");

			using(var conn = DbConnectionFactory.CreateDbConnection())
			{
                ArrayList intervals;
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("CreateUsageIntervals"))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTime.Now);
                    stmt.AddParam("pretend", MTParameterType.Integer, pretend ? 1 : 0);
                    stmt.AddOutputParam("n_count", MTParameterType.Integer);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                        intervals = UsageInterval.Load(reader);
                }

				// logs the newly created intervals
				foreach (UsageInterval interval in intervals)
					if (!pretend)
						_mLogger.LogDebug("Usage interval {0} was created", interval.IntervalID);

				return intervals;
			}
		}


        /*
            /// <summary>
            /// Soft close any expired usage intervals.
            /// </summary>
            public int SoftCloseUsageIntervals()
            {
                return SoftCloseUsageIntervals(false).Count;
            }

    
            /// <summary>
            /// Soft close any expired usage intervals and return them.
            /// </summary>
            public ArrayList SoftCloseUsageIntervals(bool pretend)
            {
                if (pretend)
                    mLogger.LogDebug("Pretending to soft close intervals...");
                else
                    mLogger.LogDebug("Soft closing usage intervals...");

                using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
                {
         ArrayList intervals;
                    using(IMTCallableStatement stmt = conn.CreateCallableStatement("SoftCloseUsageIntervals"))
          {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTime.Now);
                    stmt.AddParam("id_interval", MTParameterType.Integer, null);
                    stmt.AddParam("pretend", MTParameterType.Integer, pretend ? 1 : 0);
                    stmt.AddOutputParam("n_count", MTParameterType.Integer);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                        intervals = UsageInterval.Load(reader);
		}		
                    // logs the soft closed intervals
                    foreach (UsageInterval interval in intervals)
                        if (!pretend)
                            mLogger.LogDebug("Usage interval {0} was soft-closed", interval.IntervalID);

                    return intervals;
                }
            }

            /// <summary>
            /// Manually soft close the given usage interval.
            /// </summary>
            public bool SoftCloseUsageInterval(int intervalID)
            {
                mLogger.LogDebug("Soft closing usage interval {0}...", intervalID);

                using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
                {
                    IMTCallableStatement stmt = conn.CreateCallableStatement("SoftCloseUsageIntervals");
                    stmt.AddParam("dt_now", MTParameterType.DateTime,MetraTime.Now);
                    stmt.AddParam("id_interval", MTParameterType.Integer, intervalID);
                    stmt.AddParam("pretend", MTParameterType.Integer, 0);
                    stmt.AddOutputParam("n_count", MTParameterType.Integer);

                    //BP: This stored proc returns a result set (REF CURSOR) on Oracle.
                    //DataAccess will only implicitely initialize this param in ExecuteReader method.
                    using (IMTDataReader reader = stmt.ExecuteReader()) {}
                    // NOTE: output values can't be retireved until the reader is closed

                    int count = (int) stmt.GetOutputValue("n_count");
                    if (count == 0)
                        return false;
                }
			
                return true;
            }

        /// <summary>
            /// Manually hard close the given usage interval.
            /// </summary>
            public bool HardCloseUsageInterval(int intervalID)
            {
                mLogger.LogDebug("Hard closing usage interval {0}...", intervalID);

                using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
                {
                    IMTCallableStatement stmt = conn.CreateCallableStatement("HardCloseUsageIntervals");
                    stmt.AddParam("dt_now", MTParameterType.String,MetraTime.NowWithMilliSec);
                    stmt.AddParam("id_interval", MTParameterType.Integer, intervalID);
                    stmt.AddOutputParam("n_count", MTParameterType.Integer);
                    stmt.ExecuteNonQuery();
                    int count = (int) stmt.GetOutputValue("n_count");
                    if (count == 0)
                        return false;
                }

                return true;
            }
        */

        /// <summary>
		/// Manually open a soft closed usage interval.
		/// </summary>
		/*
    public bool OpenUsageInterval(int intervalID, bool ignoreDeps, bool pretend)
		{
			if (pretend)
				mLogger.LogDebug("Pretending to open usage interval {0}", intervalID);
			else
				mLogger.LogDebug("Opening usage interval {0}{1}",
					intervalID, ignoreDeps ? " (ignoring dependencies)" : "");

			using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
			{
				IMTCallableStatement stmt = conn.CreateCallableStatement("OpenUsageInterval");
				stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTime.Now);
				stmt.AddParam("id_interval", MTParameterType.Integer, intervalID);
				stmt.AddParam("ignoreDeps", MTParameterType.Integer, ignoreDeps ? 1 : 0);
				stmt.AddParam("pretend", MTParameterType.Integer, pretend ? 1 : 0);
				stmt.AddOutputParam("status", MTParameterType.Integer);
				stmt.ExecuteNonQuery();

				int status = (int) stmt.GetOutputValue("status");

				// when pretending, just return a boolean - don't actually throw exceptions
				if (pretend)
				{
					if (status == 0)
						return true;
					else
						return false;
				}

				switch (status)
				{
					case 0: 
						mLogger.LogDebug("Usage interval {0} was successfully opened", intervalID);
						return true;

					case -1:
						throw new UsageIntervalNotFoundException(intervalID);

					case -2:
						throw new InvalidUsageIntervalStateException(intervalID, "soft-closed");

					case -3:
						throw new UsageServerException(String.Format("Start root event not found for usage interval {0}!", intervalID));

					case -4:
						throw new NotAllEventsHaveBeenReversedException(intervalID);

					case -5:
						throw new UsageServerException(String.Format("Could not udpate usage interval {0}'s status!", intervalID));

					default:
						throw new UsageServerException("Unknown failure!", true);
				}
			}
		}
    */

		public void GetUsageIntervalInfo(int intervalID, out DateTime startDate,
			out DateTime endDate, out string status)
		{
            using (IMTConnection conn = DbConnectionFactory.CreateDbConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                    "__GET_USAGE_INTERVAL_INFO__"))
                {
                    stmt.AddParam("%%ID_INTERVAL%%", intervalID);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (!reader.Read())
                            throw new UsageServerException(String.Format("Usage interval {0} not found!", intervalID));

                        startDate = reader.GetDateTime("dt_start");
                        endDate = reader.GetDateTime("dt_end");
                        status = reader.GetString("tx_interval_status");
                    }
                }
            }
		}

    public IUsageInterval GetUsageInterval(int intervalID)
    {
      IUsageInterval usageInterval;

      using (var conn = DbConnectionFactory.CreateDbConnection())
      {
          using (var stmt = conn.CreateAdapterStatement("Queries\\UsageServer", "__GET_USAGE_INTERVAL_DATA_FOR_BILLGROUPS__"))
          {
              stmt.AddParam("%%ID_INTERVAL%%", intervalID);

              using (var reader = stmt.ExecuteReader())
              {
                  if (!reader.Read())
                      throw new UsageServerException(String.Format("Usage interval {0} not found!", intervalID));

                  usageInterval = GetUsageInterval(reader);
              }
          }
      }

      return usageInterval;
    }

    /// <summary>
    ///   The rowset should conform to the query
    ///   __GET_USAGE_INTERVALS_WITH_BILLING_GROUPS__
    /// </summary>
    /// <param name="rowset"></param>
    /// <returns></returns>
    public static IUsageInterval GetUsageInterval(Rowset.IMTSQLRowset rowset)
    {
      IUsageInterval usageInterval = new UsageInterval((int)rowset.Value["IntervalID"]);
      usageInterval.CycleID = (int)rowset.Value["CycleID"];
      usageInterval.CycleType = 
        CycleUtils.ParseCycleType((string)rowset.Value["CycleType"]);
      usageInterval.StartDate = (DateTime)rowset.Value["StartDate"];
      usageInterval.EndDate = (DateTime)rowset.Value["EndDate"];
      usageInterval.TotalIntervalOnlyAdapterCount = 
        (int)rowset.Value["TotalIntervalOnlyAdapterCnt"];
      // Ignores roots and check points
      usageInterval.TotalBillingGroupAdapterCount = 
        (int)rowset.Value["TotalBillGrpAdapterCnt"];
      usageInterval.FailedAdapterCount = 
        (int)rowset.Value["FailedBillGrpAdapterCnt"] + 
        (int)rowset.Value["FailedIntervalOnlyAdapterCnt"];
      usageInterval.SucceededAdapterCount = 
        (int)rowset.Value["SucceedBillGrpAdapterCnt"] + 
        (int)rowset.Value["SucceedIntervalOnlyAdapterCnt"];
      usageInterval.OpenUnassignedAccountsCount = 
        (int)rowset.Value["OpenUnassignedAcctsCnt"];
      usageInterval.HardClosedUnassignedAccountsCount = 
        (int)rowset.Value["HardClosedUnassignedAcctsCnt"];
      usageInterval.Progress = 0; // (int)rowset.get_Value("Progress");
      var hasBeenMaterialized = (string)rowset.Value["HasBeenMaterialized"];
      usageInterval.HasBeenMaterialized = String.Compare(hasBeenMaterialized, "Y", StringComparison.OrdinalIgnoreCase) == 0;

      var usageIntervalStatus = (string)rowset.Value["Status"];
      usageInterval.IsBlockedForNewAccounts = String.Compare(usageIntervalStatus, "O", StringComparison.OrdinalIgnoreCase) != 0;
      
      usageInterval.Status = ParseIntervalStatus(usageIntervalStatus);

      usageInterval.TotalPayerAccounts = (int)rowset.Value["TotalPayingAcctsForInterval"];

      return usageInterval;
    }

    public static IUsageInterval GetUsageInterval(IMTDataReader reader)
    {
      IUsageInterval usageInterval = new UsageInterval(reader.GetInt32("IntervalID"));
      usageInterval.CycleID = reader.GetInt32("CycleID");
      usageInterval.CycleType = 
        CycleUtils.ParseCycleType(reader.GetString("CycleType"));
      usageInterval.StartDate = reader.GetDateTime("StartDate");
      usageInterval.EndDate = reader.GetDateTime("EndDate");
      usageInterval.TotalIntervalOnlyAdapterCount = 
        reader.GetInt32("TotalIntervalOnlyAdapterCnt");
      // Ignores roots and check points
      usageInterval.TotalBillingGroupAdapterCount = 
        reader.GetInt32("TotalBillGrpAdapterCnt");
      usageInterval.FailedAdapterCount = 
        reader.GetInt32("FailedBillGrpAdapterCnt") + 
        reader.GetInt32("FailedIntervalOnlyAdapterCnt");
      usageInterval.SucceededAdapterCount = 
        reader.GetInt32("SucceedBillGrpAdapterCnt") + 
        reader.GetInt32("SucceedIntervalOnlyAdapterCnt");
      usageInterval.OpenUnassignedAccountsCount = 0;
      if (!reader.IsDBNull("OpenUnassignedAcctsCnt")) 
      {
        usageInterval.OpenUnassignedAccountsCount = reader.GetInt32("OpenUnassignedAcctsCnt");
      }
      usageInterval.HardClosedUnassignedAccountsCount = 0;
      if (!reader.IsDBNull("HardClosedUnassignedAcctsCnt")) 
      {
        usageInterval.HardClosedUnassignedAccountsCount = reader.GetInt32("HardClosedUnassignedAcctsCnt");
      }
      usageInterval.Progress = 0; // reader.GetInt32("Progress");
      var hasBeenMaterialized = reader.GetString("HasBeenMaterialized");
      usageInterval.HasBeenMaterialized = String.Compare(hasBeenMaterialized, "Y", StringComparison.OrdinalIgnoreCase) == 0;

      string usageIntervalStatus = reader.GetString("Status");
      usageInterval.IsBlockedForNewAccounts = String.Compare(usageIntervalStatus, "O", StringComparison.OrdinalIgnoreCase) != 0;
      
      usageInterval.Status = ParseIntervalStatus(usageIntervalStatus);

      usageInterval.TotalPayerAccounts = 0;
      if (!reader.IsDBNull("TotalPayingAcctsForInterval")) 
      {
        usageInterval.TotalPayerAccounts = reader.GetInt32("TotalPayingAcctsForInterval");
      }

      usageInterval.TotalGroupCount = 0;
      if (!reader.IsDBNull("TotalGroupCnt")) 
      {
        usageInterval.TotalGroupCount = reader.GetInt32("TotalGroupCnt");
      }
      usageInterval.OpenGroupCount = 0;
      if (!reader.IsDBNull("OpenGroupCnt")) 
      {
        usageInterval.OpenGroupCount = reader.GetInt32("OpenGroupCnt");
      }
      usageInterval.SoftClosedGroupCount = 0;
      if (!reader.IsDBNull("SoftClosedGroupCnt")) 
      {
        usageInterval.SoftClosedGroupCount = reader.GetInt32("SoftClosedGroupCnt");
      }
      usageInterval.HardClosedGroupCount = 0;
      if (!reader.IsDBNull("HardClosedGroupCnt")) 
      {
        usageInterval.HardClosedGroupCount = reader.GetInt32("HardClosedGroupCnt");
      }

      return usageInterval;
    }

    public static UsageIntervalStatus ParseIntervalStatus(string intervalStatus)
    {
      if (String.Compare(intervalStatus, "O", StringComparison.OrdinalIgnoreCase) == 0)
      {
        return UsageIntervalStatus.Open;
      }
      if (String.Compare(intervalStatus, "H", StringComparison.OrdinalIgnoreCase) == 0)
      {
        return UsageIntervalStatus.HardClosed;
      }
      if (String.Compare(intervalStatus, "B", StringComparison.OrdinalIgnoreCase) == 0)
      {
        return UsageIntervalStatus.Blocked;
      }
    
      throw new ArgumentException
        (String.Format("Invalid Usage Interval Status {0}", intervalStatus));
    }
		/// <summary>
		/// The number of days to create intervals in advance
		/// </summary>
		public int AdvanceIntervalCreationDays
		{
			get
			{
				using(IMTConnection conn = DbConnectionFactory.CreateDbConnection())
				{
					return ReadDbAdvanceIntervalCreationDays(conn);
				}
			}
		}

		/// <summary>
		/// The last date that interval creation occurred on
		/// NOTE: if interval creation never occurred, then DateTime.MinValue is returned
		/// </summary>
		public DateTime LastIntervalCreationDate
		{
			get
			{
                using (var conn = DbConnectionFactory.CreateDbConnection())
                {
                    using (var stmt = conn.CreateStatement("SELECT dt_last_interval_creation FROM t_usage_server"))
                    {
                        using (var reader = stmt.ExecuteReader())
                        {
                            if (!reader.Read())
                                throw new UsageServerException("Table t_usage_interval is missing a row!", true);
                            return reader.IsDBNull(0) ? DateTime.MinValue : reader.GetDateTime(0);
                        }
                    }
                }
			}
		}

		/// <summary>
		/// Gets the number of days the system waits to soft close an interval
		/// NOTE: if the grace period is disabled, then this method will throw
		/// </summary>
		public int GetSoftCloseGracePeriod(CycleType cycleType)
		{
			using(var conn = DbConnectionFactory.CreateDbConnection())
			{
				var gracePeriods = ReadGracePeriodsFromUsageCycleTypeTable(conn);
				var days = (int) gracePeriods[cycleType];
				if (days == -1)
					throw new SoftCloseGracePeriodDisabledException(cycleType);

				return days;
			}
		}

		/// <summary>
		/// Determines whether a soft close grace period for a particular cycle type
		/// is enabled. This should be called before GetSoftCloseGracePeriod.
		/// </summary>
		public bool IsSoftCloseGracePeriodEnabled(CycleType cycleType)
		{
			using(var conn = DbConnectionFactory.CreateDbConnection())
			{
				var gracePeriods = ReadGracePeriodsFromUsageCycleTypeTable(conn);
				var days = (int) gracePeriods[cycleType];
				return days != -1;
			}
		}

		// reads all grace period settings from the config file
		private void ReadConfigFile(string configFile, out Hashtable gracePeriods, out int advanceIntervalCreationDays)
		{
      // Read cross-server configuration values for the grace-period settings.
      ConfigCrossServer config = ConfigCrossServerManager.GetConfig(configFile);

			gracePeriods = new Hashtable();

			gracePeriods[CycleType.Daily] = config.gracePeriodDailyInDays;
			gracePeriods[CycleType.Weekly] = config.gracePeriodWeeklyInDays;
			gracePeriods[CycleType.BiWeekly] = config.gracePeriodBiWeeklyInDays;
			gracePeriods[CycleType.SemiMonthly] = config.gracePeriodSemiMonthlyInDays;
      gracePeriods[CycleType.Monthly] = config.gracePeriodMonthlyInDays;
			gracePeriods[CycleType.Quarterly] = config.gracePeriodQuarterlyInDays;
			gracePeriods[CycleType.Annual] = config.gracePeriodAnnuallyInDays;
      gracePeriods[CycleType.SemiAnnual] = config.gracePeriodSemiAnnuallyInDays;

      if (!config.isGracePeriodDailyEnabled)       gracePeriods[CycleType.Daily] = -1;
      if (!config.isGracePeriodWeeklyEnabled)      gracePeriods[CycleType.Weekly] = -1;
      if (!config.isGracePeriodBiWeeklyEnabled)    gracePeriods[CycleType.BiWeekly] = -1;
      if (!config.isGracePeriodSemiMonthlyEnabled) gracePeriods[CycleType.SemiMonthly] = -1;
      if (!config.isGracePeriodMonthlyEnabled)     gracePeriods[CycleType.Monthly] = -1;
      if (!config.isGracePeriodQuarterlyEnabled)   gracePeriods[CycleType.Quarterly] = -1;
      if (!config.isGracePeriodAnnuallyEnabled)      gracePeriods[CycleType.Annual] = -1;
      if (!config.isGracePeriodSemiAnnuallyEnabled)  gracePeriods[CycleType.SemiAnnual] = -1;

      var doc = new MTXmlDocument();

      if (configFile == UsageServerCommon.UsageServerConfigFile)
        doc.LoadConfigFile(configFile);
      else
        // unit tests load the config from a absolute path
        doc.Load(configFile);

      // validates the file version
      int version = doc.GetNodeValueAsInt("/xmlconfig/version");
      if (version != 2)
        throw new ConfigFileVersionMismatchException(configFile, version, 2);
            //Reads PastStartDate from usageserver XML 
             mPastStartDate = doc.GetNodeValueAsDateTime("/xmlconfig/Intervals/PastStartDate", DateTime.Parse("1999-12-31T00:00:00"));
			// reads in the advance interval creation setting
			advanceIntervalCreationDays =  doc.GetNodeValueAsInt("/xmlconfig/Intervals/AdvanceIntervalCreationDays");
			if (advanceIntervalCreationDays < 0)
				throw new NegativeValueException("<AdvanceIntervalCreationDays>", advanceIntervalCreationDays);
				
		}

	  /// <summary>
	  /// Synchronizes grace period information in the database with settings from the config file
	  /// </summary>
	  private bool WriteGracePeriodsToUsageCycleTypeTable(IMTConnection conn, Hashtable gracePeriods)
	  {
	    // reads the grace periods from the database
	    Hashtable dbGracePeriods = ReadGracePeriodsFromUsageCycleTypeTable(conn);

	    var changeDetected = false;
	    const string updateQuery = "UPDATE t_usage_cycle_type SET n_grace_period = ? WHERE id_cycle_type = ?";

	    using (var stmt = conn.CreatePreparedStatement(updateQuery))
	    {
	      foreach (DictionaryEntry gracePeriod in gracePeriods)
	      {
	        var cycleType = (CycleType) gracePeriod.Key;
	        var days = (int) gracePeriod.Value;
	        var dbDays = (int) dbGracePeriods[cycleType];

	        // database doesn't match config file
	        if (days == dbDays) continue;
	        _mLogger.LogInfo("{0} grace period setting has changed from {1} to {2}. Updating database...",
	                         cycleType, dbDays == -1 ? "disabled" : dbDays.ToString(CultureInfo.InvariantCulture),
	                         days == -1 ? "disabled" : String.Format("{0} days", days));

	        // updates the cycle type entry
	        stmt.ClearParams();
	        if (days == -1) // the grace period has been disabled
	          stmt.AddParam(MTParameterType.Integer, DBNull.Value);
	        else
	          stmt.AddParam(MTParameterType.Integer, days);
	        stmt.AddParam(MTParameterType.Integer, (int) cycleType);
	        stmt.ExecuteNonQuery();

	        changeDetected = true;
	      }
	    }

	    return changeDetected;
	  }

	  /// <summary>
	  /// Read grace periods settings from the database
	  /// </summary>
	  private static Hashtable ReadGracePeriodsFromUsageCycleTypeTable(IMTConnection conn)
	  {
	    var gracePeriods = new Hashtable();

	    using (
	      var stmt =
	        conn.CreateStatement("SELECT id_cycle_type, n_grace_period FROM t_usage_cycle_type WHERE id_cycle_type <> 2"))
	    {

	      using (IMTDataReader reader = stmt.ExecuteReader())
	      {
	        while (reader.Read())
	        {
	          var cycleType = (CycleType) reader.GetInt32(0);

	          int days = -1;
	          if (!reader.IsDBNull(1))
	            days = reader.GetInt32(1);

	          gracePeriods[cycleType] = days;
	        }
	      }
	    }

	    return gracePeriods;
	  }

	  /// <summary>
		/// Synchronizes advance interval creation setting in the database with the setting in the config file
		/// </summary>
		private bool SynchronizeAdvanceIntervalCreationDays(IMTConnection conn, int advanceIntervalCreationDays)
		{
			// reads the advance interval creation days setting from the database
			int dbDays = ReadDbAdvanceIntervalCreationDays(conn);

			// database doesn't match config file
			if (dbDays != advanceIntervalCreationDays)
			{
				_mLogger.LogInfo("Advance interval creation setting has changed from {0} to {1} days. Updating database...",
					dbDays, advanceIntervalCreationDays);
				
				// updates the cycle type entry
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer", "__UPDATE_ADVANCE_INTERVAL_CREATION_SETTING__"))
                {
                    stmt.AddParam("%%DAYS%%", advanceIntervalCreationDays);
                    int rowcount = stmt.ExecuteNonQuery();
                    if (rowcount != 1)
                        throw new UsageServerException("Update of advance interval creation days setting failed!", true);
                }

				return true;
			}
			
			return false;
		}

		/// <summary>
		/// Reads the advance interval creation setting from the database
		/// </summary>
    private static int ReadDbAdvanceIntervalCreationDays(IMTConnection conn)
        {
            using (IMTStatement stmt = conn.CreateStatement("SELECT n_adv_interval_creation FROM t_usage_server"))
            {
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    if (!reader.Read())
                        throw new UsageServerException("Table t_usage_interval is missing a row!", true);
                    int dbDays = reader.GetInt32(0);
                    return dbDays;
                }
            }
        }


	  /// <summary>
	  /// Helper to used to create reference cycles for a given cycle type.
	  /// </summary>
    private IEnumerable<UsageInterval> CreateReferenceCycles(IBulkInsert bulkInsert, ref int intervalId,
	                                    ICycleType cycleType,
	                                    ICycle cycle,
	                                    DateTime startDate, DateTime endDate)
	  {
      if (bulkInsert==null)
        throw new ArgumentNullException("bulkInsert");
      if (cycleType == null)
        throw new ArgumentNullException("cycleType");
      if (cycle==null)
        throw new ArgumentNullException("cycle");

	    var intervals = new List<UsageInterval>();
	    // The epoch is the reference date for the interval key calc.
	    var epoch = new DateTime(1970, 1, 1);
	    var refDate = startDate;
	    while (refDate < endDate)
	    {
	      DateTime intervalStart, intervalEnd;
	      cycleType.ComputeStartAndEndDate(refDate, cycle, out intervalStart, out intervalEnd);

	      if (intervalStart >= startDate)
	      {
	        // add 23:59:59
	        intervalEnd = intervalEnd.AddSeconds(EndOfDaySeconds);

	        // insert interval
	        //  id_interval
	        //  id_cycle
	        //  dt_start
	        //  dt_end 

	        // Interval Id is the interval end date and cycle id encoded
	        // into 32 bits.
	        // Upper two bytes is number of days from the epoch 1970/01/01
	        //						 to the end of the interval.
	        // Lower two bytes is the CycleID
	        intervalId = (65536*(intervalEnd - epoch).Days) + cycle.CycleID;

	        intervals.Add(new UsageInterval(intervalId)
	          {
	            CycleType = cycle.CycleType,
	            StartDate = intervalStart,
	            EndDate = intervalEnd,
	          });

	        bulkInsert.SetValue(1, MTParameterType.Integer, intervalId);
	        bulkInsert.SetValue(2, MTParameterType.Integer, cycle.CycleID);
	        bulkInsert.SetValue(3, MTParameterType.DateTime, intervalStart);
	        bulkInsert.SetValue(4, MTParameterType.DateTime, intervalEnd);
	        bulkInsert.AddBatch();

	        // Execute the batch every 1k rows
	        if (bulkInsert.BatchCount()%1000 == 0)
	          bulkInsert.ExecuteBatch();

	        refDate = intervalEnd.AddDays(1);
	      }
	      else
	      {
	        refDate = refDate.AddDays(1);
	      }
	    }
	    return intervals;
	  }


	  /// <summary>
		/// Retrieve the next interval ID to be used.
		/// </summary>
        private static int GetNextIntervalId(IMTConnection conn)
        {
            using (var stmt = conn.CreateStatement("select max(id_interval) from t_pc_interval"))
            {

                using (var reader = stmt.ExecuteReader())
                {
                    if (!reader.Read())
                        Debug.Assert(false, "No rows returned from query - unexpected");

                    if (reader.IsDBNull(0))
                        // null returned - always use 1 for the first ID
                        return 1;
                  return reader.GetInt32(0) + 1;
                }
            }
        }

		/// <summary>
		/// Array of usage cycles types, indexed by CycleType.
		/// </summary>
		private static ICycleType [] UsageCycleTypes
		{
			get
			{
				// 1	MTStdMonthly.MTStdMonthly.1							Monthly
				// 2	MTStdOnDemand.MTStdOnDemand.1						On-demand
				// 3	MTStdUsageCycle.MTStdDaily.1						Daily
				// 4	MTStdUsageCycle.MTStdWeekly.1						Weekly
				// 5	MTStdUsageCycle.MTStdBiWeekly.1					Bi-weekly
				// 6	MTStdUsageCycle.MTStdSemiMonthly.1			Semi-monthly
				// 7	MTStdUsageCycle.MTStdQuarterly.1				Quarterly
				// 8	MTStdUsageCycle.MTStdAnnually.1					Annually
        // 9	MTStdUsageCycle.MTStdSemiAnnually.1			SemiAnnually

				var cycleTypes = new ICycleType[9 + 1];
				cycleTypes[0] = null;
				cycleTypes[(int) CycleType.Monthly] = new MonthlyCycleType();

				// OnDemand is discontinued
				cycleTypes[2] = null;

				cycleTypes[(int) CycleType.Daily] = new DailyCycleType();
				cycleTypes[(int) CycleType.Weekly] = new WeeklyCycleType();
				cycleTypes[(int) CycleType.BiWeekly] = new BiWeeklyCycleType();
				cycleTypes[(int) CycleType.SemiMonthly] = new SemiMonthlyCycleType();
				cycleTypes[(int) CycleType.Quarterly] = new QuarterlyCycleType();
        cycleTypes[(int) CycleType.SemiAnnual] = new SemiAnnualCycleType();
        cycleTypes[(int) CycleType.Annual] = new AnnualCycleType();

				return cycleTypes;
			}
		}

		// 23:59:59 in seconds
		private const int EndOfDaySeconds = (23 * 60 * 60) + (59 * 60) + 59;

		private ILogger _mLogger;
	}

  internal static class BulkInsertFactory
  {
    private static IBulkInsert _bulkInsert;

    //This method is used only for test purpose
    // to create a stub of IBulkInsert
    public static void SetBulkInsert(IBulkInsert bulkInsert)
    {
      _bulkInsert = bulkInsert;
    }

    public static IBulkInsert CreateBulkInsert()
    {
      return _bulkInsert ?? BulkInsertManager.CreateBulkInsert("NetMeter");
    }
  }

  internal static class DbConnectionFactory
  {
    private static IMTConnection _connection;

    //This method is used only for test purpose
    // to create a stub of IMTConnection
    public static void SetDbConnection(IMTConnection connection)
    {
      _connection = connection;
    }

    public static IMTConnection CreateDbConnection()
    {
      return _connection ?? ConnectionManager.CreateConnection(@"Queries\UsageServer");
    }
  }

  /// <summary>
  ///   Specification of a time span in terms of a start date and and end date.
  ///   used by IUsageIntervalFilter 
  /// </summary>
  [Guid("D8FCB514-40A4-4f52-A916-D93DC5294D8B")]
  public interface IUsageIntervalTimeSpan
  {
    DateTime StartDate { get; set; }
    DateTime EndDate { get; set; }
    bool UseStartDate { get; }
    bool UseEndDate { get; }
    bool StartDateInclusive { get; set; }
    bool EndDateInclusive { get; set; }

    void ClearCriteria();
  }

	/// <summary>
	/// A filter for describing a subset of usage intervals
	/// </summary>
	[Guid("4ee7f2ca-0072-4f23-88ff-cfaeaa8f49ce")]
	public interface IUsageIntervalFilter
	{
		UsageIntervalStatus Status { get; set; }
    int IntervalID { get; set; }
    bool HasBeenMaterialized { get; set; }
		bool HasBillingGroups { get; set; }
    bool HasOpenUnassignedAccounts {get; set;}
    IUsageIntervalTimeSpan UsageIntervalTimeSpan { get; set; }
    // This is no longer supported. Use GetIntervals() instead.
   	Rowset.IMTSQLRowset GetRowset();
    // Returns a list of IUsageInterval objects
    ArrayList GetIntervals();

		void ClearCriteria();
	}

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("5F5CE99E-B00F-47ed-A5C1-6ACC8CFC5A54")]
  public class UsageIntervalTimeSpan : IUsageIntervalTimeSpan
  {
    public UsageIntervalTimeSpan()
    {
      ClearCriteria();
    }

    public void ClearCriteria() 
    {
      startDate = DateTime.MinValue;
      endDate = DateTime.MaxValue;
      useStartDate = false;
      useEndDate = false;
      startDateInclusive = false;
      endDateInclusive = false;
    }

    public DateTime StartDate
    {
      get 
      { 
        return startDate; 
      }
      set 
      { 
        startDate = value; 
        useStartDate = true;
      }
    }

    public DateTime EndDate
    {
      get 
      { 
        return endDate; 
      }
      set 
      {
        endDate = value; 
        useEndDate = true;
      }
    }

    public bool UseStartDate
    {
      get 
      { 
        return useStartDate; 
      }
    }

    public bool UseEndDate
    {
      get 
      { 
        return useEndDate; 
      }
    }

    public bool StartDateInclusive
    {
      get 
      { 
        return startDateInclusive; 
      }
      set 
      {
        startDateInclusive = value;
      }
    }

    public bool EndDateInclusive
    {
      get 
      { 
        return endDateInclusive; 
      }
      set 
      {
        endDateInclusive = value;
      }
    }

    private DateTime startDate;
    private bool useStartDate;
    private DateTime endDate;
    private bool useEndDate;
    private bool startDateInclusive;
    private bool endDateInclusive;
  }

	/// <summary>
	/// A filter for describing a subset of usage intervals
	/// </summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("f58d3086-04ce-4348-9a17-b7b7face804b")]
	public class UsageIntervalFilter : IUsageIntervalFilter
	{
	  readonly Logger _mLogger;

    public Rowset.IMTSQLRowset GetRowset()
    {
      throw new NotSupportedException("Deprecated. Use 'GetIntervals()' instead");
    }

		public UsageIntervalFilter()
		{
      _mLogger = new Logger("[UsageServer]");
			ClearCriteria();
		}
		public void ClearCriteria()
		{
      mStatus = UsageIntervalStatus.All;
      mIntervalID = -1;
      mUseIntervalID = false;
      mAppendAnd = false;
      mHasBeenMaterialized = false;
      mUseHasBeenMaterialized = false;
      mHasBillingGroups = false;
      mUseHasBillingGroups = false;
      mUsageIntervalTimeSpan = null;
      mHasOpenUnassignedAccounts = false;
      mUseHasOpenUnassignedAccounts = false;
		}

		public UsageIntervalStatus Status
		{
			get
			{
				return mStatus;
			}
			set
			{
				mStatus = value;
			}
		}

    public int IntervalID
    {
      get
      {
        return mIntervalID;
      }
      set
      {
        mIntervalID = value;
        mUseIntervalID = true;
      }
    }

    public bool HasBeenMaterialized 
    {
      get
      {
        return mHasBeenMaterialized;
      }
      set
      {
        mHasBeenMaterialized = value;
        mUseHasBeenMaterialized = true;
      }
    }

    public bool HasBillingGroups 
    {
      get
      {
        return mHasBillingGroups;
      }
      set
      {
        mHasBillingGroups = value;
        mUseHasBillingGroups = true;
      }
    }

    public bool HasOpenUnassignedAccounts 
    {
      get
      {
        return mHasOpenUnassignedAccounts;
      }
      set
      {
        mHasOpenUnassignedAccounts = value;
        mUseHasOpenUnassignedAccounts = true;
      }
    }
    
    
    public IUsageIntervalTimeSpan UsageIntervalTimeSpan 
    {
      get
      {
        return mUsageIntervalTimeSpan;
      }
      set
      {
        mUsageIntervalTimeSpan = value;
      }
    }

   
    /// <summary>
    ///    Returns the following:
    ///    IntervalId
    ///    CycleType
    ///    StartDate
    ///    EndDate
    ///    TotalGroupCount
    ///    CycleID
    ///    HasBeenMaterialized
    ///    Status
    /// </summary>
    /// <returns></returns>
    public Rowset.IMTSQLRowset GetRowsetRedux()
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(@"Queries\UsageServer");
      rowset.SetQueryTag("__GET_USAGE_INTERVAL_INFO_REDUX__");
      var whereClause = new StringBuilder();

      switch (mStatus) 
      {
        case UsageIntervalStatus.Open:
        case UsageIntervalStatus.Active: 
        {
          // interval is not hard closed
          AppendToWhere(whereClause, " ui.tx_interval_status <> 'H' ");
          break;
        }
        case UsageIntervalStatus.Billable: 
        {
          // interval has an end date in the past and 
          // interval is not hard closed 
          AppendToWhere(whereClause, 
            " ui.tx_interval_status <> 'H' AND " +
            "%%%SYSTEMDATE%%% > ui.dt_end ");
          break;
        }
        case UsageIntervalStatus.Completed: 
        case UsageIntervalStatus.HardClosed:
        {
          // interval has all hard closed billing groups
          AppendToWhere(whereClause, " ui.tx_interval_status = 'H' ");
          break;
        }
        case UsageIntervalStatus.All: 
        {
          break;
        }
        case UsageIntervalStatus.SoftClosed: 
        {
          throw new InvalidUsageIntervalFilterOptionException
            (UsageIntervalStatus.SoftClosed.ToString());
        }
        default : 
        {
          throw new InvalidUsageIntervalFilterOptionException
            ("Invalid UsageIntervalStatus");
        }
      }
    
      if (mUseIntervalID) 
      {
        AppendToWhere(whereClause, String.Format(" ui.id_interval = {0} ", mIntervalID));
      }

      if (mUseHasBeenMaterialized) 
      {
        AppendToWhere(whereClause,
                      mHasBeenMaterialized
                        ? " materialization.id_usage_interval IS NOT NULL "
                        : " materialization.id_usage_interval IS NULL ");
      }

      if (mUseHasBillingGroups) 
      {
        AppendToWhere(whereClause,
                      mHasBillingGroups ? " billingGroups.TotalGroupCount > 0 " : " billingGroups.TotalGroupCount = 0 ");
      }

      if (mUsageIntervalTimeSpan != null) 
    {
        var startDate = 
          mUsageIntervalTimeSpan.StartDate.ToString("yyyy'-'MM'-'dd");
        var endDate = 
          mUsageIntervalTimeSpan.EndDate.ToString("yyyy'-'MM'-'dd");

        if (mUsageIntervalTimeSpan.UseStartDate)
        {
          AppendToWhere(whereClause,
                        mUsageIntervalTimeSpan.StartDateInclusive
                          ? String.Format(" ui.dt_start >= '{0}' ", startDate)
                          : String.Format(" ui.dt_start > '{0}' ", startDate));
        }

        if (mUsageIntervalTimeSpan.UseEndDate)
        {
          AppendToWhere(whereClause,
                        mUsageIntervalTimeSpan.EndDateInclusive
                          ? String.Format(" ui.dt_end <= '{0}' ", endDate)
                          : String.Format(" ui.dt_end < '{0}' ", endDate));
        }
      }

      rowset.AddParam("%%OPTIONAL_WHERE_CLAUSE%%", whereClause.ToString(), true);
      rowset.Execute();

      return rowset;
    }


    /// <summary>
    ///   Return a list of IUsageInterval objects based on the filter criteria.
    /// </summary>
    /// <returns></returns>
    public ArrayList GetIntervals()
    {
      var usageIntervals = new ArrayList();

      var whereClause = new StringBuilder();

      using (var conn = DbConnectionFactory.CreateDbConnection())
      {
          using (var stmt =
            conn.CreateAdapterStatement("Queries\\UsageServer", "__GET_USAGE_INTERVALS_WITH_BILLING_GROUPS__"))
          {

              if (mUseIntervalID)
              {
                  stmt.AddParam("%%ID_INTERVAL_FILTER_1%%", " WHERE IntervalID = " + mIntervalID + " ");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_2%%", " WHERE aui.id_usage_interval = " + mIntervalID + " ");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_3%%", " AND bm.id_usage_interval = " + mIntervalID + " ");
                  // stmt.AddParam("%%ID_INTERVAL_FILTER_4%%", " WHERE bg.id_usage_interval = " + mIntervalID + " ");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_5%%", " AND inst.id_arg_interval = " + mIntervalID + " ");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_6%%", " AND inst.id_arg_interval = " + mIntervalID + " ");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_7%%", " AND inst.id_arg_interval = " + mIntervalID + " ");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_8%%", " AND inst.id_arg_interval = " + mIntervalID + " ");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_9%%", " AND inst.id_arg_interval = " + mIntervalID + " ");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_10%%", " AND inst.id_arg_interval = " + mIntervalID + " ");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_BG%%", " WHERE id_usage_interval = " + mIntervalID + " ");
                  //stmt.AddParam("%%ID_INTERVAL_FILTER_11%%", " WHERE id_interval = " + mIntervalID + " ");
                  AppendToWhere(whereClause, String.Format(" allIntervals.IntervalID = {0} ", mIntervalID));
              }
              else
              {
                  stmt.AddParam("%%ID_INTERVAL_FILTER_1%%", "");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_2%%", "");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_3%%", "");
                  // stmt.AddParam("%%ID_INTERVAL_FILTER_4%%", "");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_5%%", "");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_6%%", "");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_7%%", "");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_8%%", "");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_9%%", "");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_10%%", "");
                  stmt.AddParam("%%ID_INTERVAL_FILTER_BG%%", "");
                  //stmt.AddParam("%%ID_INTERVAL_FILTER_11%%", "");
              }


              switch (mStatus)
              {
                  case UsageIntervalStatus.Open:
                  case UsageIntervalStatus.Active:
                      {
                          // interval is not hard closed
                          AppendToWhere(whereClause, " allIntervals.Status <> 'H' ");
                          break;
                      }
                  case UsageIntervalStatus.Billable:
                      {
                          // interval has an end date in the past and 
                          // interval is not hard closed 
                          AppendToWhere(whereClause,
                                        " allIntervals.Status <> 'H' AND " +
                                        "%%%SYSTEMDATE%%% > allIntervals.EndDate ");
                          break;
                      }
                  case UsageIntervalStatus.Completed:
                  case UsageIntervalStatus.HardClosed:
                      {
                          // interval has all hard closed billing groups
                          AppendToWhere(whereClause, " allIntervals.Status = 'H' ");
                          break;
                      }
                  case UsageIntervalStatus.All:
                      {
                          break;
                      }
                  case UsageIntervalStatus.SoftClosed:
                      {
                          throw new InvalidUsageIntervalFilterOptionException
                                      (UsageIntervalStatus.SoftClosed.ToString());
                      }
                  default:
                      {
                          throw new InvalidUsageIntervalFilterOptionException
                            ("Invalid UsageIntervalStatus");
                      }
              }

              if (mUseHasBeenMaterialized)
              {
                AppendToWhere(whereClause,
                              mHasBeenMaterialized
                                ? " allIntervals.HasBeenMaterialized = 'Y' "
                                : " allIntervals.HasBeenMaterialized = 'N' ");
              }

              if (mUseHasBillingGroups)
              {
                AppendToWhere(whereClause,
                              mHasBillingGroups
                                ? " allIntervals.TotalGroupCount > 0 "
                                : " allIntervals.TotalGroupCount = 0 ");
              }

              if (mUsageIntervalTimeSpan != null)
              {
                  //        string startDate = 
                  //          mUsageIntervalTimeSpan.StartDate.ToString("yyyy'-'MM'-'dd");
                  //        string endDate = 
                  //          mUsageIntervalTimeSpan.EndDate.ToString("yyyy'-'MM'-'dd");

                  if (mUsageIntervalTimeSpan.UseStartDate)
                  {
                      if (mUsageIntervalTimeSpan.StartDateInclusive)
                      {
                          AppendToWhere(whereClause, String.Format(" allIntervals.StartDate >= {0} ",
                                                                   DBUtil.ToDBString(mUsageIntervalTimeSpan.StartDate)));
                      }
                      else
                      {
                          AppendToWhere(whereClause, String.Format(" allIntervals.StartDate > {0} ",
                                                                   DBUtil.ToDBString(mUsageIntervalTimeSpan.StartDate)));
                      }
                  }

                  if (mUsageIntervalTimeSpan.UseEndDate)
                  {
                      if (mUsageIntervalTimeSpan.EndDateInclusive)
                      {
                          AppendToWhere(whereClause, String.Format(" allIntervals.EndDate <= {0} ",
                                                                   DBUtil.ToDBString(mUsageIntervalTimeSpan.EndDate)));
                      }
                      else
                      {
                          AppendToWhere(whereClause, String.Format(" allIntervals.EndDate < {0} ",
                                                                   DBUtil.ToDBString(mUsageIntervalTimeSpan.EndDate)));
                      }
                  }

                  if (mUseHasOpenUnassignedAccounts)
                  {
                    AppendToWhere(whereClause,
                                  mHasOpenUnassignedAccounts
                                    ? " allIntervals.OpenUnassignedAcctsCnt > 0 "
                                    : " allIntervals.OpenUnassignedAcctsCnt = 0 ");
                  }
              }

              stmt.AddParam("%%OPTIONAL_WHERE_CLAUSE%%", whereClause.ToString(), true);

              _mLogger.LogInfo("Executing Query [UsageIntervalFilter.GetIntervals]: -----------------------------------");
              _mLogger.LogInfo(stmt.Query);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      usageIntervals.Add(UsageIntervalManager.GetUsageInterval(reader));
                  }
              }
          }
      }

      return usageIntervals;
    }

    private void AppendToWhere(StringBuilder whereClause, string clause) 
    {
      if (mAppendAnd) 
      {
        whereClause.Append(" AND ");
        whereClause.Append(clause);
      }
      else 
      {
        whereClause.Append("WHERE ");
        whereClause.Append(clause);
        mAppendAnd = true;
      }
    }

    #region Data
    private bool mAppendAnd;
		private UsageIntervalStatus mStatus;
    private int mIntervalID;
    private bool mUseIntervalID;
    private bool mHasBeenMaterialized;
    private bool mUseHasBeenMaterialized;
    private bool mHasBillingGroups;
    private bool mUseHasBillingGroups;
    private bool mHasOpenUnassignedAccounts;
    private bool mUseHasOpenUnassignedAccounts;
    private IUsageIntervalTimeSpan mUsageIntervalTimeSpan;
    #endregion
	}

	/// <summary>
	/// A usage interval
	/// </summary>
	[Guid("1e9e7527-e3b0-4311-9342-b552b3b24724")]
	public interface IUsageInterval
	{
		/// <summary>
		/// Interval ID
		/// NOTE: this ID is the same across any MetraNet deployment (as of v3.0)
		/// </summary>
		int IntervalID
		{ get; }

		/// <summary>
		/// Start date
		/// </summary>
		DateTime StartDate
		{ get; set;}

		/// <summary>
		/// End date
		/// </summary>
		DateTime EndDate
		{ get; set;}
		
		/// <summary>
		/// Status
		/// </summary>
		UsageIntervalStatus Status
		{ get; set;}

    /// <summary>
    ///   Returns true if this interval cannot be mapped to new accounts.
    /// </summary>
    bool IsBlockedForNewAccounts
    { get; set;}

		/// <summary>
		/// Usage cycle ID of the interval
		/// </summary>
		int CycleID
		{ get; set;}

		/// <summary>
		/// Usage cycle type of the interval
		/// </summary>
		CycleType CycleType
		{ get; set;}

    #region Billing Groups
    
    int TotalIntervalOnlyAdapterCount { get; set;}
    int TotalBillingGroupAdapterCount { get; set;}
    int SucceededAdapterCount { get; set;}
    int FailedAdapterCount { get; set;}
    int OpenUnassignedAccountsCount { get; set;}
    int HardClosedUnassignedAccountsCount { get; set;}
    int Progress { get; set;}
    bool HasBeenMaterialized { get; set;}
    int TotalPayerAccounts {get; set;}
    bool HasPayerAccounts {get;}
    int TotalGroupCount {get; set;}
    int OpenGroupCount {get; set;}
    int SoftClosedGroupCount {get; set;}
    int HardClosedGroupCount {get; set;}
    
    #endregion
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("ae89dfdf-4de4-4344-9df7-d1da9cd25669")]
	public class UsageInterval : IUsageInterval
	{
		private UsageInterval(int intervalID, DateTime startDate, DateTime endDate,
			UsageIntervalStatus status, int cycleID, CycleType cycleType)
		{
		  IsBlockedForNewAccounts = false;
		  TotalPayerAccounts = 0;
		  Progress = 0;
		  HardClosedUnassignedAccountsCount = 0;
		  OpenUnassignedAccountsCount = 0;
		  FailedAdapterCount = 0;
		  SucceededAdapterCount = 0;
		  TotalBillingGroupAdapterCount = 0;
		  TotalIntervalOnlyAdapterCount = 0;
		  IntervalID = intervalID;
			StartDate = startDate;
			EndDate = endDate;
			Status = status;  // should we remove this?
			CycleID = cycleID;
			CycleType = cycleType;
      HasBeenMaterialized = false;
		}

    public UsageInterval(int intervalID)
    {
      IsBlockedForNewAccounts = false;
      TotalPayerAccounts = 0;
      Progress = 0;
      HardClosedUnassignedAccountsCount = 0;
      OpenUnassignedAccountsCount = 0;
      FailedAdapterCount = 0;
      SucceededAdapterCount = 0;
      TotalBillingGroupAdapterCount = 0;
      TotalIntervalOnlyAdapterCount = 0;
      // TODO:  Load usage interval for passed in id.
      // Old Notes:
          /*'dim rowset, sQuery
            'set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	          'rowset.Init "queries\mom"
            'rowset.SetQueryTag("__GET_USAGE_INTERVAL_DETAILS__")
            'rowset.AddParam "%%ID_INTERVAL%%", CLng(Form("IntervalId"))
	          'rowset.Execute
              
            'Service.Properties("IntervalId").Value = rowset.value("Interval")
            'Service.Properties("IntervalStatus").Value = rowset.value("State")
            'Service.Properties("IntervalType").Value = rowset.value("Type")
            'Service.Properties("IntervalStartDateTime").Value = rowset.value("Start")
            'Service.Properties("IntervalEndDateTime").Value = rowset.value("End")
            'Service.Properties("IntervalStatusIcon").Value =  "<img src='" & GetIntervalStateIcon(rowset.value("State")) & "' align='absmiddle'>&nbsp;"
          */
      IntervalID = intervalID;
    }

	  public int TotalIntervalOnlyAdapterCount { get; set; }

	  public int TotalBillingGroupAdapterCount { get; set; }

	  public int SucceededAdapterCount { get; set; }

	  public int FailedAdapterCount { get; set; }

	  public int OpenUnassignedAccountsCount { get; set; }

	  public int HardClosedUnassignedAccountsCount { get; set; }

	  public int Progress { get; set; }

	  public bool HasBeenMaterialized { get; set; }

	  public bool HasPayerAccounts
    {
      get
      {
        return TotalPayerAccounts > 0;
      }
    }

	  public int TotalPayerAccounts { get; set; }

	  public int IntervalID { get; private set; }

	  public DateTime StartDate { get; set; }

	  public DateTime EndDate { get; set; }

	  public UsageIntervalStatus Status { get; set; }

	  public bool IsBlockedForNewAccounts { get; set; }

	  public int CycleID { get; set; }

	  public CycleType CycleType { get; set; }

	  public int TotalGroupCount { get; set; }

	  public int OpenGroupCount { get; set; }

	  public int SoftClosedGroupCount { get; set; }

	  public int HardClosedGroupCount { get; set; }

	  public override string ToString()
		{
			return String.Format
        ("IntervalID={0}, StartDate={1}, EndDate={2}, Status={3}, CycleID={4}, CycleType={5}",
				IntervalID, StartDate, EndDate, Status, CycleID, CycleType);
		}


		/// <summary>
		/// Loads intervals from the database and returns an array filled with UsageInterval objects
		/// </summary>
		internal static ArrayList Load(IMTDataReader reader)
		{
			var intervalList = new ArrayList();

			while (reader.Read())
			{
				int intervalID = reader.GetInt32("id_interval");
				DateTime startDate = reader.GetDateTime("dt_start");
				DateTime endDate = reader.GetDateTime("dt_end");

				string rawStatus = reader.GetString("tx_interval_status");
				UsageIntervalStatus status;
				switch (rawStatus)
				{
					case "O":
						status = UsageIntervalStatus.Billable;  // TODO:  use new filter options
						break;

					case "C":
						status = UsageIntervalStatus.Active;
						break;

					case "H":
						status = UsageIntervalStatus.Completed;
						break;

					default:
						throw new UsageServerException(String.Format("Unknown usage interval status! {0}", rawStatus), true);
				}

				var usageCycleID = reader.GetInt32("id_usage_cycle");
				var cycleType = (CycleType) reader.GetInt32("id_cycle_type");

				intervalList.Add(new UsageInterval(intervalID, startDate, endDate, status, usageCycleID, cycleType));
			}

			return intervalList;
		}

	}
}
