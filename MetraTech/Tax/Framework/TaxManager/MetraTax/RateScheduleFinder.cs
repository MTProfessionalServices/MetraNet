#region

using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.DataAccess;

#endregion

namespace MetraTech.Tax.Framework.MetraTax
{
    /// <summary>
    /// Used to find the most appropriate rate schedule to use.
    /// This class holds the properties of all rate schedules in memory.
    /// Using this information, this class can find the most appropriate
    /// rate schedule to use for a given account, for a given date.
    /// </summary>
    internal class RateScheduleFinder
    {
        // Logger
        private static readonly Logger m_logger = new Logger("[MetraTax]");

        // True if rate schedules properties have been loaded in memory.
        private Boolean m_isDictionaryLoadedWithRateScheduleProperties;


        // A dictionary of all the general rate schedule information on the system
        // indexed by parameter table name.  This dictionary basically contains
        // the id for the parameter table instances, the validate date range, but
        // does not count the rate schedule itself.
        private readonly MultiValueDictionary<string, RateScheduleProperties> m_rateScheduleDict;

        /// <summary>
        /// Constructor.
        /// </summary>
        public RateScheduleFinder()
        {
            m_isDictionaryLoadedWithRateScheduleProperties = false;
            m_rateScheduleDict = new MultiValueDictionary<string, RateScheduleProperties>();
            LoadRateSchedules();
        }

        /// <summary>
        /// Given an account, transaction date, and parameter table name,
        /// returns the best rate schedule instance of the parameter table
        /// to use.  Throws an exception if no appropriate instances of 
        /// the parameter table can be found.
        /// </summary>
        /// <param name="usageAccountId"></param>
        /// <param name="transactionDate"></param>
        /// <param name="parameterTableName">Parameter table name. Example "metratech.com/MyTable".</param>
        /// <returns>the id of the rate schedule instance</returns>
        public int GetBestRateScheduleId(int usageAccountId,
                                         DateTime transactionDate,
                                         string parameterTableName)
        {
            HashSet<RateScheduleProperties> hashSet = m_rateScheduleDict.GetValues(parameterTableName, true);
            m_logger.LogDebug("There are " + hashSet.Count + " potential matches for " + parameterTableName);

            int bestScheduleSoFar = -1;
            TimeSpan bestScoreSoFar = new TimeSpan(0);

            // Find the best schedule to use.
            for (int i = 0; i < hashSet.Count; i++)
            {
                RateScheduleProperties sched = hashSet.ElementAt(i);

                // Is the schedule configured properly?
                if (!sched.IsProperForTax())
                {
                    String s = "Parameter table " + parameterTableName + " rate schedule (ID: " + sched.RateScheduleId +
                               ") " + "is not configured properly for MetraTax.  The beginning/ending effective dates but be " +
                               "an absolute date or 'No Start Date' or 'No End Date'";
                    m_logger.LogError(s);
                    throw new TaxException(s);
                }

                // Does the transaction date fall within the schedule
                if (!sched.IsDateInSchedule(transactionDate))
                {
                    m_logger.LogDebug("Eliminating schedule " + sched.RateScheduleId + " since the date doesn't fall within the schedule.");
                    continue;
                }

                // Score this match
                TimeSpan score = transactionDate.Subtract(sched.GetNormalizedBeginningDate());
                m_logger.LogDebug("Schedule " + sched.RateScheduleId + " start date is " + score.Days + " days from the transaction date.");

                // Is this the best match so far?
                if (bestScheduleSoFar < 0 || score < bestScoreSoFar)
                {
                    bestScoreSoFar = score;
                    bestScheduleSoFar = sched.RateScheduleId;
                    m_logger.LogDebug("Schedule " + sched.RateScheduleId + " is the best schedule so far.");
                }
            }

            if (bestScheduleSoFar < 0)
            {
                m_logger.LogError("Unable to find the rate schedule to use for parameter table " +
                                  parameterTableName + " because there are no such rate schedules.");
                throw new TaxException("Unable to find the rate schedule to use for parameter table " +
                                       parameterTableName + " because there are no such rate schedules.");
            }

            m_logger.LogDebug("Rate schedule ID " + bestScheduleSoFar + "/" + parameterTableName +
                        " is best schedule for account: " + usageAccountId + " date: " + transactionDate);
            return bestScheduleSoFar;
        }


        /// <summary>
        /// Loads rate schedule informatin into the rate schedule dictionary.
        /// Does nothing if the rate schedule information is already in memory.
        /// </summary>
        private void LoadRateSchedules()
        {
            if (m_isDictionaryLoadedWithRateScheduleProperties)
            {
                return;
            }

            // We need to load rate schedule properties into the dictionary
            m_logger.LogDebug("Reading all rate schedule properties into memory.");
            IMTConnection dbConnection = null;

            // We are going to take table t_pl_map and join it with t_base_props so that
            // we get a column that has the corresponding parameter table name.
            // We are also going to join with t_rsched and t_effective_date to pick
            // up the dates associated with the rate schedule instances.
            try
            {
                dbConnection = ConnectionManager.CreateConnection();
                IMTAdapterStatement statement = dbConnection.CreateAdapterStatement(@"Queries\Tax\MetraTax", "__GET_ALL_RATE_SCHEDULES__");
                IMTDataReader reader = statement.ExecuteReader();

                // Load the rate schedules into memory.
                while (reader.Read())
                {
                    RateScheduleProperties scheduleProperties = new RateScheduleProperties();
                    scheduleProperties.ParameterTableName = reader.GetString("nm_name");
                    scheduleProperties.RateScheduleId = reader.GetInt32("id_sched");

                    // Beginning date
                    if (!reader.IsDBNull("n_begintype"))
                    {
                        scheduleProperties.GetBeginningDate().Kind = reader.GetInt32("n_begintype");
                        scheduleProperties.GetBeginningDate().IsKindNull = false;
                    }


                    if (!reader.IsDBNull("dt_start"))
                    {
                        scheduleProperties.GetBeginningDate().ScheduleDate = reader.GetDateTime("dt_start");
                        scheduleProperties.GetBeginningDate().IsScheduleDateNull = false;
                    }

                    // Ending date
                    if (!reader.IsDBNull("n_endtype"))
                    {
                        scheduleProperties.GetEndingDate().Kind = reader.GetInt32("n_endtype");
                        scheduleProperties.GetEndingDate().IsKindNull = false;
                    }

                    if (!reader.IsDBNull("dt_end"))
                    {
                        scheduleProperties.GetEndingDate().ScheduleDate = reader.GetDateTime("dt_end");
                        scheduleProperties.GetEndingDate().IsScheduleDateNull = false;
                    }

                    m_logger.LogDebug("Adding schedule " + scheduleProperties.RateScheduleId + " to dictionary for " + scheduleProperties.ParameterTableName);
                    m_rateScheduleDict.Add(scheduleProperties.ParameterTableName, scheduleProperties);
                }

                m_logger.LogDebug("Read the properties for " + m_rateScheduleDict.Count + " rate schedules.");

                m_isDictionaryLoadedWithRateScheduleProperties = true;
            }
            catch (Exception e)
            {
                m_logger.LogError("An error occurred attempt to read rate schedule properties: " + e.Message +
                                  " Inner exception: " + e.InnerException +
                                  " Stack: " + e.StackTrace);
                throw new TaxException(e.Message);
            }
            finally
            {
                try
                {
                    if (dbConnection != null)
                        dbConnection.Close();
                }
                catch (Exception)
                {
                    // Don't report close failure.
                }
            }
        }
    }
}