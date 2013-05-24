using System;
using System.Data;
using System.Data.OleDb;
using MetraTech.Test.MeterTool.MeterToolLib;
using MetraTech.Test;

namespace MetraTech.Test.MeterTool.Plugins
{
  class SmokeTestGetUsername : IPlugin
  {
    // required properties
    private string msName;
    private  IPluginHost mHost;

    // custom plugin properties
    private int mIndex = 0;
    private int mCount = 0;

    private string[] mUsernames;
    private string mTestid;

    // We will only hit the database once, since our plugin stays in memory between calls
    public SmokeTestGetUsername()
    {

		PropertyBag config = new PropertyBag();

		config.Initialize("SmokeTest");
		mTestid=config["TestID"].ToString();
		string sUsernames=config["MeterToUserNameList"].ToString();
		mUsernames = sUsernames.Split(',');

		mCount = mUsernames.Length;

    }
		
    /// <summary>
    /// Main entry point for plugin execution
    /// </summary>
    /// <param name="prop"></param>
    /// <returns>Property value as a string</returns>
    public string Run(MTMeterProp prop)
    {
      string sValue;
      
      sValue = mUsernames[mIndex] + mTestid;

      mIndex++;
      if(mIndex == mCount)
        mIndex = 0;

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
