using System;
using System.Data;
using System.Data.OleDb;
using MetraTech.Test.MeterTool.MeterToolLib;

namespace MetraTech.Test.MeterTool.Plugins
{
  class StartTimePlusDuration : IPlugin
  {
    // required properties
    private string msName;
    private IPluginHost mHost;
    private Random mRandomGenerator;

    public StartTimePlusDuration()
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
      string sDuration;
      //int nDuration;
      

      sDuration = prop.GetRelatedValue("parent.ScheduledDuration");
      sStart = prop.GetRelatedValue("parent.ScheduledStartTime");

      DateTime dtStart = DateTime.Parse(sStart);
      //nDuration = mRandomGenerator.Next(1, (int.Parse(sDuration) + (int.Parse(sDuration) / 2)));
      DateTime dtEnd = dtStart.AddMinutes(int.Parse(sDuration));

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
