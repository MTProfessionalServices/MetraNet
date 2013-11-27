using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    /// <summary>
    /// The preferences for an individual AppMethod
    /// </summary>
    /// 
    public class ActivityServicePreferences : IPrefComp
    {
        public string name { set; get; }

        public string authName { set; get; }
        public string authPassword { set; get; }

        public ActivityServicePreferences()
        {
            setToDefaults();
        }

        public void setToDefaults()
        {
            authName = "admin";
            authPassword = "123";
        }
    }

}
