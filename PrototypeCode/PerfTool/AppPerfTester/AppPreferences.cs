using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Baseline;
namespace BaselineGUI
{
    public class AppDbPreferences
    {
        public string address;
        public string port;
        public string database;
        public string userName;
        public string password;

        public AppDbPreferences()
        {
			address = PerfTesterConfig.Instance.AppDbPreferences.address;
			port = PerfTesterConfig.Instance.AppDbPreferences.port;
			database = PerfTesterConfig.Instance.AppDbPreferences.database;
			userName = PerfTesterConfig.Instance.AppDbPreferences.userName;
			password = PerfTesterConfig.Instance.AppDbPreferences.password;

			//address = "perf10";
			//port = "1433";
			//database = "NetMeter";
			//userName = "sa";
			//password = "123";
		}

    }

    public class AppFolderPreferences
    {
        public string extension;
        public string fileLandingService;
        public string visualStudioProject;

        public AppFolderPreferences()
        {
			//extension = @"C:\MetraTech\RMP\Extensions\ldperf";
			//fileLandingService = @"C:\FLS";
			//visualStudioProject = @"C:\users\administrator\My Documents\Visual Studio 2010\Projects\GSM\BaselineGUI";            
			extension = PerfTesterConfig.Instance.AppFolderPreferences.extension;
			fileLandingService = PerfTesterConfig.Instance.AppFolderPreferences.fileLandingService;
			visualStudioProject = PerfTesterConfig.Instance.AppFolderPreferences.visualStudioProject;
		}

    }


    public static class AppPreferences
    {
        public static AppDbPreferences db = new AppDbPreferences();
        public static AppFolderPreferences folders = new AppFolderPreferences();
    }
}
