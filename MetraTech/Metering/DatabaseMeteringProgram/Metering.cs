using System;
using System.Data;
using System.Data.OleDb;
using System.Xml;
using System.Xml.Schema;
using System.Collections;
using System.IO; 
using MetraTech.Metering.DatabaseMetering;
using Microsoft.Win32;


namespace MetraTech.Metering.DatabaseMeteringProgram
{

	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class MainClass
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		// SC: This needs to run in a multi-threaded apartment because the ISessionSet COM
      // interface is called from multiple threads (see ServiceDef::MeterSessionSetsInBatch).
		[MTAThread]
		static int Main(string[] args)
		{
      try 
      {
        MeterHelper objMeter = new MeterHelper();
        return objMeter.Meter(args);
      }
      catch(Exception) 
      {
        return -1;
      }
		}
	}
}
