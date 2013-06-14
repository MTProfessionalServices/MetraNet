using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public class StressPreferences
    {
        public string name { set; get; }
        public int numThreads { set; get; }
        public int maxRunTime { set; get; }

        public StressPreferences()
        {
            setToDefaults();
        }

        public void setToDefaults()
        {
            maxRunTime = 300;
            numThreads = 10;
        }
    }
}
