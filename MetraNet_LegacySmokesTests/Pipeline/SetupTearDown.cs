using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Diagnostics;

using MetraTech.Test;
using MetraTech.Test.Common;
using MetraTech.Interop;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;
using System.Reflection;
using MetraTech.Interop.NameID;



namespace MetraTech.Pipeline.Test
{
	/// <summary>
	/// Common Data setup and Data TearDown routines used for Listener tests
	/// </summary>
	/// 
	[ComVisible(false)]
	public class Setup
	{
		
		public Setup()
		{
		}

		private static int attempt=0;
		
		public static void CleanupTestData()
		{

			MetraTech.Test.Common.Utils.MTSQLRowSetExecute("DROP TABLE t_listener_test");
			return;
		}
		public static void SetupTestData()
		{
				
			try
			{
				if(MetraTech.Test.Common.Utils.DatabaseType == DBType.Oracle)
				{
					MetraTech.Test.Common.Utils.MTSQLRowSetExecute("CREATE TABLE t_listener_test (a NUMBER(10), b NUMBER(10))");
				}
				else
				{
					MetraTech.Test.Common.Utils.MTSQLRowSetExecute("CREATE TABLE t_listener_test (a INT, b INT)");
				}
			}
			catch(Exception)
			{
				CleanupTestData();
				if (attempt < 2)
				{
					attempt++;
					SetupTestData();
				}
				else
					throw;
			}
			
			return;
		}


	
	}

	
}

