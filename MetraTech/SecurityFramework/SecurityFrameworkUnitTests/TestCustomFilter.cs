using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.SecurityMonitor;

namespace MetraTech.SecurityFrameworkUnitTests
{
    /// <summary>
    /// Testing custom filter.
    /// </summary>
    internal static class TestCustomFilter
    {
        /// <summary>
        /// Gets or internall sets a number of matches.
        /// </summary>
        public static long MatchesCount
        {
            get;
            private set;
        }

        public static void Filter(object sender, CustomFilterEventArgs e)
        {
            e.Matched = e.SecurityEvent.SubsystemName == "Encoder";
            if (e.Matched)
            {
                MatchesCount++;
            }
        }
    }
}
