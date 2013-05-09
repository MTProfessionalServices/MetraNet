using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public interface IPrefComp
    {
        string name { get; set; }

        void setToDefaults();
    }
}
