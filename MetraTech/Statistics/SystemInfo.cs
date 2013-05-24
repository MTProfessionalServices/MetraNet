using System.Runtime.InteropServices;

namespace MetraTech.Statistics
{
  using System;
  using System.Diagnostics;
  using System.Reflection;
  using System.Runtime.InteropServices;
  using System.Management;
  using System.IO;

  using System.Collections;
  using System.Web;
  using System.Text;
  using System.Text.RegularExpressions;

  using System.Xml;
  
  using MetraTech.Xml;
  using MetraTech.Interop.RCD;


  //using MetraTech.Interop.MTUsageServer;
  [Guid("40EA7192-F28D-4a73-B70F-CAF06A453AF2")]
  public interface ISystemInfo 
  {
    string GetEnviromentVariable(string Name);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("1713A2D0-6797-4ddd-94B4-2C9FA668C408")]
  public class SystemInfo : ISystemInfo
  {
    public string GetEnviromentVariable(string Name)
    {
      return System.Environment.GetEnvironmentVariable(Name);
    }
  }
}

