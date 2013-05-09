using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace BaselineGUI
{
    public class AppFolderPreferences : IPrefComp
    {
        public string name { set; get; }

        public string extension { set; get; }
        public string fileLandingService { set; get; }
        public string visualStudioProject { set; get; }
        public string resultsPath { set; get; }

        public AppFolderPreferences()
        {
            setToDefaults();
        }

        public void setToDefaults()
        {
            extension = @"R:\Extensions\ldperf";
            fileLandingService = @"C:\FLS";
            visualStudioProject = @"C:\users\administrator\My Documents\Visual Studio 2010\Projects\GSM\BaselineGUI";


            resultsPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), "PerfTool Results");
        }

    }

}
