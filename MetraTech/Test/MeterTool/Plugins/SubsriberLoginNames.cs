using System;
using System.Data;
using System.Data.OleDb;
using MetraTech.Interop.Rowset;
using MetraTech.Test.MeterTool.MeterToolLib;
using MetraTech.Interop.MTServerAccess;

namespace MetraTech.Test.MeterTool.Plugins
{

	public class MeterToolPluginException : ApplicationException
	{
		public MeterToolPluginException(string msg) : base(msg) {}

	}
	/// <summary>
	/// Get a valid username from the system
	/// In the plugin field enter [MetraTech.Test.MeterTool.MetraTech.Test.MeterTool.Plugins.GetUsername]
	/// </summary>
  class SubscriberLoginNames : IPlugin
  {
    // required properties
    private string msName;
    private  IPluginHost mHost;

    // custom plugin properties
    private DataSet mSet;        // dataset holds usernames
    private int mIndex = 0;
    private int mCount = 0;

    // We will only hit the database once, since our plugin stays in memory between calls
    public SubscriberLoginNames()
    {
			msName = "SubscriberLoginNames";
      IMTServerAccessDataSet sa = new MTServerAccessDataSet();
			sa.Initialize();
			IMTServerAccessData accessData = sa.FindAndReturnObject("NetMeter");

			string nmdbo = accessData.UserName;
			string pass = accessData.Password;
			string db = accessData.DatabaseName;

      string DBConnString =
				string.Format("Server=localhost;UID={0};PWD={1};Database={2};Provider=SQLOLEDB;", nmdbo, pass, db);
      string sSQL = @"select nm_login from t_account_mapper am inner join "+
				"t_account acc on acc.id_acc = am.id_acc inner join t_account_type atype on atype.id_type = acc.id_type where nm_space='mt' and UPPER(atype.name) in ('CORESUBSCRIBER', 'DEPARTMENTACCOUNT', 'CORPORATEACCOUNT')";

			IMTSQLRowset rs = new MTSQLRowsetClass();
			rs.Init("Queries\\database");
			rs.SetQueryString(sSQL); 
			rs.Execute();

			if(rs.RecordCount == 0)
			{
				throw new MeterToolPluginException("SubscriberLoginNames plugin found no subscribers in database!");
			}

			mSet = new DataSet();
			OleDbDataAdapter da = new OleDbDataAdapter();
			
			da.Fill(mSet, rs.PopulatedRecordSet, "subsribernames");
			mCount = mSet.Tables[0].Rows.Count;
    }
		
    /// <summary>
    /// Main entry point for plugin execution
    /// </summary>
    /// <param name="prop"></param>
    /// <returns>Property value as a string</returns>
    public string Run(MTMeterProp prop)
    {
      string sValue;
      
      sValue = mSet.Tables[0].Rows[mIndex]["nm_login"].ToString();
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
