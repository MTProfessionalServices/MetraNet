using System;


namespace MetraTech.Tax.Framework.MetraTax
{
    public class RateScheduleProperties
  {
        // Logger
        private static readonly Logger m_logger = new Logger("[MetraTax]");

        // The beginning date for the rate schedule.
        private readonly RateScheduleDate m_beginningDate;

        // The ending date for the rate schedule.
        private readonly RateScheduleDate m_endingDate;

    /// <summary>
    /// This identifies the parameter table (note that this the "generic" parameter table,
    /// not specific instance filled with rates).
    /// This ID corresponds to table t_rsched/id_pt in table t_pl_map/id_paramtable.
    /// </summary>
    public int ParameterTableId { set; get; }

    /// <summary>
    /// This identifies a specific instance of the parameter table filled with
    /// rates.  This is known as a rate schedule.
    /// This ID corresponds to t_rsched/id_sched or t_pt_.../id_sched.
    /// </summary>
    public int RateScheduleId { set; get; }

        /// <summary>
        /// The name of the parameter table.
        /// </summary>
    public string ParameterTableName { set; get; }

        /// <summary>
        /// The effective beginning date for the schedule.
        /// </summary>
        public RateScheduleDate GetBeginningDate()
        {
            return m_beginningDate;
  }


        /// <summary>
        /// The effective ending date for the schedule.
        /// </summary>
        public RateScheduleDate GetEndingDate()
        {
            return m_endingDate;
        }

        /// <summary>
        /// Constructor
        /// </summary>
        public RateScheduleProperties()
        {
            m_beginningDate = new RateScheduleDate();
            m_endingDate = new RateScheduleDate();
        }

        /// <summary>
        /// Does the given date fall within the schedule?
        /// </summary>
        /// <param name="transactionDate"></param>
        /// <returns></returns>
        internal bool IsDateInSchedule(DateTime transactionDate)
        {
            if (!IsProperForTax())
            {
                return false;
            }

            // We know that the beginning date is 'No Date' or is absolute.
            // If absolute, make sure we are withing range.
            if (m_beginningDate.isAbsolute() && transactionDate.CompareTo(m_beginningDate.ScheduleDate) < 0)
            {
                m_logger.LogDebug("Not using rate schedule " + RateScheduleId + " for parameter table " + ParameterTableName +
                                  " because the transaction date " + transactionDate + " is too early.");
                return false;
            }
            
            // We know that the ending date is null or is 'No Date' or is absolute.
            // If the ending date is null or 'No Date' then no checking needed.
            if (m_endingDate.IsKindNull || m_endingDate.isForever())
            {
                return true;
            }

            // If we reach this point, the ending date is absolute.
            // Make sure the transaction falls within.
            if (transactionDate.CompareTo(m_endingDate.ScheduleDate) > 0)
            {
                m_logger.LogDebug("Not using rate schedule " + RateScheduleId + " for parameter table " + ParameterTableName +
                                  " because the transaction date " + transactionDate + " is too late.");
                return false;
            }

            return true;
        }

        /// <summary>
        /// For tax we require that the beginning date be 'no date' or 
        /// absolute.  And that the ending date is null or 'no date' or
        /// absolute.
        /// </summary>
        /// <returns></returns>
        internal bool IsProperForTax()
        {
            if (m_beginningDate.IsKindNull)
            {
                m_logger.LogError("The beginning date kind is missing in rate schedule " + RateScheduleId);
                return false;
            }

            if (!m_beginningDate.isAbsolute() && !m_beginningDate.isForever())
            {
                m_logger.LogError("The beginning date kind in rate schedule " + RateScheduleId +
                                  " must be 'No Date' or an absolute date.");
                return false;
            }

            if (m_beginningDate.isAbsolute() && m_beginningDate.IsScheduleDateNull)
            {
                m_logger.LogError("The beginning date in rate schedule " + RateScheduleId +
                                  " is absolute but there is no beginning date in the database.");
                return false;
            }

            if (!m_endingDate.IsKindNull && !m_endingDate.isAbsolute() && !m_endingDate.isForever())
            {
                m_logger.LogError("The ending date kind in rate schedule " + RateScheduleId +
                                  " must be 'No Date' or an absolute date.");
                return false;
            }


            if (!m_endingDate.IsKindNull && m_endingDate.isAbsolute() && m_endingDate.IsScheduleDateNull)
            {
                m_logger.LogError("The ending date in rate schedule " + RateScheduleId +
                                  " is absolute but there is no beginning date in the database.");
                return false;
            }

            return true;
        }

        /// <summary>
        /// Return a beginning date for the schedule.  If the beginning date is 'no date',
        /// or is otherwise unspecified return Jan 1, 1970 as an arbitrary very early date.
        /// This method throws an exception is asked to return a date for a case
        /// other than 'no date' or 'absolute'.
        /// </summary>
        /// <returns></returns>
        public DateTime GetNormalizedBeginningDate()
        {
            DateTime result = new DateTime(1970, 1, 1);

            if (m_beginningDate.IsKindNull || m_beginningDate.isForever())
                return result;

            // The only other case we can handle is an absolute.
            // Throw an exception if we are asked to do anything else.
            if (!m_beginningDate.isAbsolute() || m_beginningDate.IsScheduleDateNull)
            {
                String s = "Parameter table " + ParameterTableName + " rate schedule (ID: " + RateScheduleId +
                           ") " + " has a beginning effective date that is not " +
                           "an absolute date or 'No Start Date'.  This is unexpected.";
                m_logger.LogError(s);
                throw new TaxException(s);
            }

            return m_beginningDate.ScheduleDate;
        }
    }
}