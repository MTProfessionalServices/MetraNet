using System;
using System.Data;
using System.Data.OleDb;
using MetraTech.Test.MeterTool.MeterToolLib;

namespace MetraTech.Test.MeterTool.Plugins
{
/*
 * 	class DBProperty : IPlugin
	{
		// required properties
		private string msName;
		private IPluginHost mHost;
		private Random mRandomGenerator;
		// custom plugin properties
		private static DataSet mSet;        // dataset holds usernames
		private int mIndex = mStartIndex;
		private static int mCount = 0;
		private static int mStartIndex;

		static DBProperty()
		{
			//string DBConnString = "Server=localhost;UID=sa;PWD=metratech;Database=BTMeteringDB;Provider=SQLOLEDB;";
			IMTServerAccessDataSet sa = new MTServerAccessDataSet();
			sa.Initialize();
			IMTServerAccessData accessData = sa.FindAndReturnObject("NetMeter");

			string nmdbo = accessData.UserName;
			string pass = accessData.Password;
			string db = accessData.DatabaseName;
			string dbtype = accessData.DatabaseType;
			string svrname = accessData.ServerName;

			string DBConnString = string.Format
				("Server=localhost;UID={0};PWD={1};Database={2};Provider=SQLOLEDB;", nmdbo, pass, db);

			if (dbtype.ToLower().IndexOf("oracle") > 0)
				DBConnString = string.Format
					("Provider=OraOLEDB.Oracle;Data Source={0};User Id={1};Password={2}", svrname, nmdbo, pass);

			string sSQL = "select * from dy_AccountCreation where bt_lastname is not null";
			OleDbConnection myConn = new OleDbConnection(DBConnString);
			OleDbDataAdapter myCmd = new OleDbDataAdapter( sSQL, myConn ); 

			myConn.Open();
			mSet = new DataSet();
			myCmd.Fill( mSet, "MET_AccountCreation" );

			mCount = mSet.Tables[0].Rows.Count;
			Random rand = new Random(DateTime.Now.Millisecond);
			mStartIndex = rand.Next(mCount - 1);
		}

		public DBProperty()
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
			string sValue;
			string colName = "BT_" + prop.Name;

			object val = mSet.Tables[0].Rows[mIndex][colName];
			if (val != null)
				sValue = val.ToString();
			else
				sValue = null;

			mIndex++;
			if(mIndex == mCount)
				mIndex = 0;

			return sValue;
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
	*/
}
