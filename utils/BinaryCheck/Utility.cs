using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Tools.BinaryCheck
{
  internal static class Utility
  {
    public static string RemoveExtraBackslashes(string str)
    {
      if (StringIsNullOrWhiteSpace(str))
        return str;

      return str.Replace("\\\\\\", "\\").Replace("\\\\", "\\");
    }
    public static bool StringIsNullOrWhiteSpace(string str)
    {
      if(str == null)
        return true;

      return string.IsNullOrEmpty(str.Trim());
    }
  }
}
