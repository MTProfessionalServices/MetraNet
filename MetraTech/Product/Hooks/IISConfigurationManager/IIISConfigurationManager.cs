using System;
using System.Runtime.InteropServices;

[assembly: GuidAttribute("2C4666B7-C262-4485-A67C-BFFCA445A276")]

namespace ICEUtils
{

  public interface IIISConfigurationManager
  {
    void AddWebApp(string appName, string fullPath, string appPool);
    void RemoveWebApp(string appName);
    bool WebAppExists(string appName);
  }
}
