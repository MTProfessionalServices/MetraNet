using System;
using Microsoft.Win32;

namespace MetraTech.Test
{

  static public class RegistryHelper
  {

    static public string GetKeyValue(string key)
    {
      RegistryKey regKey = Registry.CurrentUser.OpenSubKey("MetraTechUnitTestValue");

      if (regKey == null)
      {
        regKey = Registry.CurrentUser.CreateSubKey("MetraTechUnitTestValue");
        regKey.SetValue(key, "1");
      }

      string val = regKey.GetValue(key).ToString();
      if(val.Equals(String.Empty) || val == null)
      {
        throw new ApplicationException("Registry key " + key + " not found.");
      }
      return val;
    }


    static public void SetKeyValue(string key, object value)
    {
      RegistryKey regKey = Registry.CurrentUser.OpenSubKey("MetraTechUnitTestValue", true);

      if (regKey == null)
      {
        regKey = Registry.CurrentUser.CreateSubKey("MetraTechUnitTestValue", RegistryKeyPermissionCheck.ReadWriteSubTree);
      }

      regKey.SetValue(key, value);
    }

  }

}