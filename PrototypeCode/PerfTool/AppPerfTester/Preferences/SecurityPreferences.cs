using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
  /// <summary>
  /// The preferences for reference data loading
  /// </summary>
  /// 
  public class SecurityPreferences : IPrefComp
  {
    public string name { set; get; }

    public string encryptionKey { set; get; }

    public SecurityPreferences()
    {
      setToDefaults();
    }

    public void setToDefaults()
    {
      encryptionKey = "mtkey";
    }
  }

}
