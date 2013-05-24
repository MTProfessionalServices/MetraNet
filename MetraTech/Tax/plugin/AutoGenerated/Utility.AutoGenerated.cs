//////////////////////////////////////////////////////////////////////////////
// This file was automatically generated using ICE.
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////

#region

using System;

#endregion

namespace MetraTech.Tax.Plugins.BillSoft
{
  public static class Utility
  {
    public static string GetFQMethodName()
    {
      string @class = "ClassNotFound";
      string method = "MethodNotFound";

      try
      {
        var st = new System.Diagnostics.StackTrace();
        var sf = st.GetFrame(1);
        @class = sf.GetMethod().DeclaringType.Name;
        method = sf.GetMethod().Name;
      }
      catch (Exception)
      {
      }

      return @class + "." + method;
    }
  }

  public class Constants
  {
    public const int E_FAIL = -2147467259;
    public const int E_NOTIMPL = -2147467263;
  }
}