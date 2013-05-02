using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Collections;
using System.Diagnostics;
using NUnit.Framework;
using PC=MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using YAAC = MetraTech.Interop.MTYAAC;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;
using MetraTech.Interop.COMMeter;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;

namespace MetraTech.Test
{

	/// <summary>
	/// Summary description for Util.
	/// </summary>
	public class Util
	{

		public Util()
		{
		}

    public bool RunProcess(string app, string args)
    {
      Process p = new Process();

      p.StartInfo.FileName = app;
      if(!string.IsNullOrEmpty(args))
      {
        p.StartInfo.Arguments = args;
      }

      return p.Start();
    }

		/// <summary></summary>
		public string FindDLLFileNameFromPATH(string strDLLFileName){
			//BP: Exists will also return true if assembly in current execution directory
			// however it won't be the full path as we expect
			if(File.Exists(strDLLFileName)) { // Check in case a full path name is passed
				return strDLLFileName;
			}
			
			return GetFullPath(strDLLFileName);
		}
		/// <summary></summary>
		public string GetFullPath(string strDLLFileName)
		{
			string [] strPaths  = System.Environment.GetEnvironmentVariable("PATH").Split(';');
			string strFullFileName;
			foreach(string s in strPaths)
			{
				strFullFileName = s+"\\"+strDLLFileName;
				if(File.Exists(strFullFileName)) 
				{
					return strFullFileName;
				}
			}
			return strDLLFileName;
		}
	  public string Environ(string strVariable){
			return System.Environment.GetEnvironmentVariable(strVariable);
		}
	  public bool Log(string strFileName, string strText)
		{

        System.IO.StreamWriter f;

        try{

          if(System.IO.File.Exists(strFileName))
            f = System.IO.File.AppendText(strText);
          else
            f = System.IO.File.CreateText(strText);

    		  f.Write(strText);
    		  f.Close();
    		  return true;
  		  }
  		  catch{
  		    return false;
        }
		}

		public static void MTSQLRowSetExecute(string aQuery)
		{
			RS.IMTSQLRowset rs = new RS.MTSQLRowsetClass();
			rs.Init("Queries\\database");
			rs.SetQueryString(aQuery); 
			rs.Execute();
		}

	}


}
