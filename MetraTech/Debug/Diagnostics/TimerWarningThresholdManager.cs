using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Xml.Linq;

namespace MetraTech.Debug.Diagnostics
{
    /// <summary>
    /// Prior to adding this class, the most common use of the 
    /// HighResolutionTimer was to wrap the code-to-be-timed
    /// inside of a "using" block as shown below:
    ///
    /// using (new HighResolutionTimer("TimerTest", 1000)) 
    /// { 
    ///     // code to be timed
    /// }
    ///
    /// The hard coded "1000" was a bad idea because the timing might be dependent
    /// on e.g. the size of the DB.
    ///
    /// The TimerWarningThresholdManager allows this hard coded value to be replaced
    /// with a value taken from RMP/config/TimerWarningThresholds.xml.  This
    /// XML file contains lines like the following:
    ///
    /// <timerWarningThresholds>
    ///     <timerWarningThreshold timerId="TimerTest" maxMillisecondsBeforeWarning="1000"/>
    ///     <timerWarningThreshold timerId="GetAccountList" maxMillisecondsBeforeWarning="20000"/>
    ///     ...
    /// </timerWarningThresholds>
    ///
    /// </summary>
    internal class TimerWarningThresholdManager
    {
        private readonly static Logger m_Logger = new Logger("[TimerWarningThresholdManager]");

        /// <summary>
        /// Populate this container with rows from 
        /// RMP/config/TimerWarningThresholds.xml.
        /// </summary>
        Dictionary<string, long> m_TimerWarningThresholds = new Dictionary<string, long>();

        /// <summary>
        /// If the dictionary does not hold a value for the specified key, then
        /// return this default value.  The default value might also be specified within
        /// RMP/config/TimerWarningThresholds.xml.
        /// </summary>
        long m_DefaultMaxMillisecondsBeforeWarning = long.MaxValue;

        /// <summary>
        /// Allocate ourselves.
        /// We have a private constructor, so no one else can.
        /// </summary>
        static readonly TimerWarningThresholdManager m_Instance = new TimerWarningThresholdManager();

        /// <summary>
        /// Access TimerWarningThresholdManager Instance to get the singleton object.
        /// Then call methods on that instance.
        /// </summary>
        public static TimerWarningThresholdManager Instance
        {
            get { return m_Instance; }
        }

        /// <summary>
        /// If a value for the specified timerId exists in the m_TimerWarningThresholds, then return that.
        /// Otherwise, return m_DefaultMaxMillisecondsBeforeWarning.
        /// </summary>
        public long GetMaxMillisecondsBeforeWarning(string timerId)
        {
            long retValue;
            if (!m_TimerWarningThresholds.TryGetValue(timerId, out retValue))
            {
                retValue = m_DefaultMaxMillisecondsBeforeWarning;
            }
            return retValue;
        }

        /// <summary>
        /// If a value for the specified timerId exists in the m_TimerWarningThresholds, then return that.
        /// Otherwise, return the passed in maxMillisecondsBeforeWarning.
        /// </summary>
        public long GetMaxMillisecondsBeforeWarning(string timerId, long maxMillisecondsBeforeWarning)
        {
            long retValue;
            if (!m_TimerWarningThresholds.TryGetValue(timerId, out retValue))
            {
                retValue = maxMillisecondsBeforeWarning;
            }
            return retValue;
        }

        /// <summary>
        /// Populate the m_TimerWarningThresholds Dictionary with rows from
        /// RMP/config/TimerWarningThresholds.xml.
        /// Note: if there are problems reading RMP/config/TimerWarningThresholds.xml,
        /// this method continues and the m_DefaultMaxMillisecondsBeforeWarning will always
        /// be returned from the public methods.
        /// </summary>
        private TimerWarningThresholdManager()
        {
            try
            {
                // Determine the location of the thresholds file
                string rmpDir = Environment.GetEnvironmentVariable("MTRMP");
                if (rmpDir == null)
                {
                    throw new Exception("MTRMP is null");
                }
                string thresholdFile = rmpDir + @"\config\TimerWarningThresholds.xml";

                // Load the file into an XDocument
                XDocument thresholdDocument = XDocument.Load(thresholdFile);

                // Find the descendant elements with tag "timerWarningThreshold"
                foreach (XElement threshold in thresholdDocument.Descendants("timerWarningThreshold"))
                {
                    string timerId = "";
                    if (threshold.Attribute("timerId") != null)
                    {
                        timerId = threshold.Attribute("timerId").Value;
                    }
                    else
                    {
                        m_Logger.LogWarning("found threshold with no timerId, skipping threshold");
                        continue;
                    }

                    long maxMillisecondsBeforeWarning = 0;
                    if (threshold.Attribute("maxMillisecondsBeforeWarning") != null)
                    {
                        maxMillisecondsBeforeWarning = long.Parse(threshold.Attribute("maxMillisecondsBeforeWarning").Value);
                    }
                    else
                    {
                        m_Logger.LogWarning("found threshold with no maxMillisecondsBeforeWarning, skipping threshold");
                        continue;
                    }

                    // Put the timerId and maxMillisecondsBeforeWarning in a dictionary for fast lookup
                    m_TimerWarningThresholds.Add(timerId, maxMillisecondsBeforeWarning);
                }
            }
            catch (Exception e)
            {
                m_Logger.LogWarning("{0}: failed to read RMP/config/TimerWarningThresholds.xml, GetMaxMillisecondsBeforeWarning() will return invalid values", 
                        e.Message);
            }
        }
    }
}
