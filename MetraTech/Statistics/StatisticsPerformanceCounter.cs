using System.Runtime.InteropServices;

namespace MetraTech.Statistics
{
	using System;
  using System.Diagnostics;

	using System.Collections;
  using System.Web;
  using System.Text;
	using System.Xml;
  
  using MetraTech.Xml;
  using MetraTech.Interop.RCD;


	//using MetraTech.Interop.MTUsageServer;
  [Guid("B7C0A4D3-44CA-4e37-A3FD-8B57AB801B62")]
  public interface IStatisticsPerformanceCounter 
  {
    string GetPerformanceCounterValue(string CategoryName, string CounterName, string InstanceName, string MachineName);
    //string GetMenuXML(string classification, string menuLink, string menuLinkTarget);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("4B221A52-9767-4af9-A413-694812BACBE9")]
  public class StatisticsPerformanceCounter : IStatisticsPerformanceCounter
  {
    public string GetPerformanceCounterValue(string CategoryName, string CounterName, string InstanceName, string MachineName)
    {
      System.Diagnostics.PerformanceCounter counter = new System.Diagnostics.PerformanceCounter();
      counter.CategoryName = CategoryName;
      counter.CounterName = CounterName;
      counter.InstanceName = InstanceName;
      counter.MachineName = MachineName;
      
      return counter.NextValue().ToString();
    }
  }


}
