using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public class RunLimitPreferences
    {
        public string name { set; get; }

        public string numPasses { set; get; }
        public string maxRunTime { set; get; }

        public RunLimitPreferences()
        {
            setToDefaults();
        }

        public void setToDefaults()
        {
            numPasses = "1000";
            maxRunTime = "1800";
        }
    }
}
