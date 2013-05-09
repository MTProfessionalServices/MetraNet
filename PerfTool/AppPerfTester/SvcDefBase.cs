using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public class SvcDefBase
    {
        public void initEnum<T>(ref T f)
        {
            Type t;
            t = typeof(T);
            System.Array a = t.GetEnumValues();
            f = (T)a.GetValue(0);
        }

        public string FLS_ISO8601(DateTime dt)
        {
            return dt.ToString("yyyy-MM-dd hh:mm:ss tt");
        }

    }

}
