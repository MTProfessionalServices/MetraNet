using System;
using System.Data;
using System.Data.OleDb;
using MetraTech.Test.MeterTool.MeterToolLib;

namespace MetraTech.Test.MeterTool.Plugins
{
  class SimpleEndTime : IPlugin
  {
    // required properties
    private string msName;
    private IPluginHost mHost;
    private Random mRandomGenerator;

    public SimpleEndTime()
    {
      mRandomGenerator = new Random(DateTime.Now.Millisecond);
      msName = "Hello I'm " + ToString();
    }
		
    /// <summary>
    /// Main entry point for plugin execution
    /// </summary>
    /// <param name="prop"></param>
    /// <returns>Property value as a string</returns>
    public string Run(MTMeterProp prop)
    {
      string sStart;
      int nDuration;

      sStart = prop.GetRelatedValue("StartTime");
      DateTime dtStart = DateTime.Parse(sStart);

      // Add between 1 and 120 minutes to StartTime
      nDuration = mRandomGenerator.Next(1, 120); 
      DateTime dtEnd = dtStart.AddMinutes(nDuration);

      return(dtEnd.ToString());
    }
    
    /// <summary>
    /// Plugin identification
    /// </summary>
    public string Name
    {
      get{ return msName; }
      set{ msName = value;}
    }

    /// <summary>
    /// Set host an register plugin with the host
    /// </summary>
    public  IPluginHost Host
    {
      get{ return mHost; }
      set
      {
        mHost = value;
        mHost.Register(this);
      }
    }

  }
}
