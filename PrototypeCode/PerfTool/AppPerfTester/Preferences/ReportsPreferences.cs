using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public class ReportsPreferences
    {
        public string name { set; get; }

        public bool saveStatsReport { set; get; }
        public bool appendStatsReport { set; get; }
        public string rptFilename { get; set; }

        public ReportsPreferences()
        {
            setToDefaults();
        }

        public void setToDefaults()
        {
            saveStatsReport = false;
            appendStatsReport = false;
            rptFilename = "Statistics.csv";
        }
    }
}
