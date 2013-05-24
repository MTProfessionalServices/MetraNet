using System;
using System.Runtime.InteropServices;

namespace MetraTech.UsageServer
{
    /// <summary>
    /// Partition information for reporting the outcome of partition operations.
    /// </summary>
    [ComVisible(false)] // Not yet.
    public class PartitionInfo
    {
        public string Name;
        public DateTime StartDate;
        public DateTime EndDate;
        public long IntervalStart;
        public long IntervalEnd;
    }
}