using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public class AppDbPreferences : IPrefComp
    {
        public string name { set; get; }
        public string address { set; get; }
        public string port { set; get; }
        public string database { set; get; }
        public string userName { set; get; }
        public string password { set; get; }

        public AppDbPreferences()
        {
            setToDefaults();
        }

        public void setToDefaults()
        {
            address = "perf10";
            port = "1433";
            database = "jeff70";
            userName = "sa";
            password = "MetraTech1";
        }

    }
}
