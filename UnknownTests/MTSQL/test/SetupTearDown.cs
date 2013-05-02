using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Diagnostics;
using NUnit.Framework;
using NUnit.Framework.Extensions;

using MetraTech.MTSQL;
using MetraTech.Test;
using MetraTech.Test.Common;
using PC=MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using YAAC = MetraTech.Interop.MTYAAC;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;
using MetraTech.Interop.COMInterpreter;
using System.Reflection;
using MetraTech.Interop.NameID;



namespace MetraTech.MTSQL.Test
{
	/// <summary>
	/// Common Data setup and Data TearDown routines used for MTSQL tests
	/// </summary>
	public class Setup
	{
		
		public Setup()
		{
		}

		private static int attempt=0;
		
		public static void CleanupTestData()
		{
			
			Utils.MTSQLRowSetExecute("DROP TABLE mtsqltest_1");
			Utils.MTSQLRowSetExecute("DROP TABLE mtsqltest_2");
			Utils.MTSQLRowSetExecute("DROP TABLE mtsqltest_3");
			Utils.MTSQLRowSetExecute("DROP TABLE mtsqltest_4");
			Utils.MTSQLRowSetExecute("DROP TABLE mtsqltest_5");
			Utils.MTSQLRowSetExecute("DROP TABLE mtsqltest_6");
			return;
		}
		public static void SetupTestData()
		{
				
			try
			{
				if(Utils.DatabaseType == DBType.Oracle)
				{
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_1 (a NUMBER(10), b NUMBER(10))");
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_2 (a NUMBER(10), c NUMBER(10))");
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_3 (a NUMBER(10), d DATE)");
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_4 (a NUMBER(10) NOT NULL, e NUMBER(22,10) NULL)");
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_5 (a NUMBER(10) NOT NULL, f VARCHAR(128) NULL)");
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_6 (a NUMBER(10) NOT NULL, f VARCHAR(128) NULL)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_1 (a, b) VALUES (1, 1)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_1 (a, b) VALUES (2, 2)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_1 (a, b) VALUES (3, 3)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_1 (a, b) VALUES (3, 4)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_2 (a, c) VALUES (1, 1)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_2 (a, c) VALUES (2, 4)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_2 (a, c) VALUES (3, 9)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_3 (a, d) VALUES (1, {ts '2002-03-25 00:00:00'})");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_3 (a, d) VALUES (3, {ts '2002-03-27 00:00:00'})");
					//BP TOD: next rows is just to have the tests pass without new t_pc_intervals table. Remove later
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_3 (a, d) VALUES (2, {ts '2002-03-26 00:00:00'})");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_4 (a, e) VALUES (1, 12.23)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_4 (a, e) VALUES (2, NULL)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_5 (a, f) VALUES (1, 'one')");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_5 (a, f) VALUES (2, 'two')");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_5 (a, f) VALUES (3, 'three')");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_6 (a, f) VALUES (718077954, 'one')");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_6 (a, f) VALUES (718078030, 'two')");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_6 (a, f) VALUES (718143490, 'three')");
				}
				else
				{
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_1 (a INT, b INT)");
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_2 (a INT, c INT)");
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_3 (a INT, d DATETIME)");
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_4 (a INT NOT NULL PRIMARY KEY, e DECIMAL(22,10) NULL)");
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_5 (a INT NOT NULL PRIMARY KEY, f VARCHAR(128) NULL)");
					Utils.MTSQLRowSetExecute("CREATE TABLE mtsqltest_6 (a INT NOT NULL PRIMARY KEY, f VARCHAR(128) NULL)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_1 (a, b) VALUES (1, 1)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_1 (a, b) VALUES (2, 2)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_1 (a, b) VALUES (3, 3)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_1 (a, b) VALUES (3, 4)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_2 (a, c) VALUES (1, 1)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_2 (a, c) VALUES (2, 4)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_2 (a, c) VALUES (3, 9)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_3 (a, d) VALUES (1, {ts '2002-03-25 00:00:00'})");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_3 (a, d) VALUES (3, {ts '2002-03-27 00:00:00'})");
					//BP TODO: next rows is just to have the tests pass without new t_pc_intervals table. Remove later
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_3 (a, d) VALUES (2, {ts '2002-03-26 00:00:00'})");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_4 (a, e) VALUES (1, 12.23)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_4 (a, e) VALUES (2, NULL)");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_5 (a, f) VALUES (1, 'one')");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_5 (a, f) VALUES (2, 'two')");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_5 (a, f) VALUES (3, 'three')");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_6 (a, f) VALUES (718077954, 'one')");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_6 (a, f) VALUES (718078030, 'two')");
					Utils.MTSQLRowSetExecute("INSERT INTO mtsqltest_6 (a, f) VALUES (718143490, 'three')");
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

