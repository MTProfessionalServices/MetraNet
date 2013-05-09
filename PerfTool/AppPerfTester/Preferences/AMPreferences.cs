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
    public class AMPreferences : IPrefComp
    {
        public string name { set; get; }

        public bool stressEnabled;
        public double stressRate;

        public AMPreferences Clone()
        {
            AMPreferences p = new AMPreferences();
            p.name = name;
            p.stressEnabled = this.stressEnabled;
            p.stressRate = this.stressRate;
            return p;
        }

        public void setToDefaults()
        {
            stressEnabled = false;
            stressRate = 60000.0;
        }
    }

}
