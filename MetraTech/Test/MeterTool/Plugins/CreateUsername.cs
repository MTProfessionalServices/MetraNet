using System;
using System.Threading;
using MetraTech.Test.MeterTool.MeterToolLib;

namespace MetraTech.Test.MeterTool.Plugins
{
	/// <summary>
	/// Get a valid username from the system
	/// In the plugin field enter [MetraTech.Test.MeterTool.MetraTech.Test.MeterTool.Plugins.GetUsername]
	/// </summary>
  class CreateUsername : IPlugin
  {
    // required properties
    private string msName;
    private  IPluginHost mHost;

    // custom plugin properties
    
    // We will only hit the database once, since our plugin stays in memory between calls
    public CreateUsername()
    {
      
    }
		
    /// <summary>
    /// Main entry point for plugin execution
    /// </summary>
    /// <param name="prop"></param>
    /// <returns>Property value as a string</returns>
    public string Run(MTMeterProp prop)
    {
      string sValue = string.Format("ACCOUNT_{0}", Environment.TickCount.ToString());
      Thread.Sleep(10);
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

    //SAMPLE CODE: To get sibling property "ActionType"
    //foreach(MTMeterProp oMeterType in prop.Parent.Nodes)
    //{
    //  if(String.Compare(oMeterType.Name, "ActionType", true) == 0)
    //    return(oMeterType.GetGeneratedValue().ToString());
    //}

  }
}
