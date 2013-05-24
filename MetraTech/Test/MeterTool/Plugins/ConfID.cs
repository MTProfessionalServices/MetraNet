using System;
using System.Data;
using System.Data.OleDb;
using MetraTech.Test.MeterTool.MeterToolLib;

namespace MetraTech.Test.MeterTool.Plugins
{
  class ConfID : IPlugin
  {
    // required properties
    private string msName;
    private IPluginHost mHost;

    // custom plugin properties
    private static int mStart=1;   
   
    public ConfID()
    {
      msName = "Hello I'm " + ToString();
    }
		
    /// <summary>
    /// Main entry point for plugin execution
    /// </summary>
    /// <param name="prop"></param>
    /// <returns>Property value as a string</returns>
    public string Run(MTMeterProp prop)
    {      
      string sValue;
      
      sValue = "Conf" + mStart.ToString();;
      mStart++;
      return(sValue);
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
