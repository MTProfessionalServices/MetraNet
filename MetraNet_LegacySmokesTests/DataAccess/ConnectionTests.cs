
namespace MetraTech.DataAccess.Test
{
	using System;
	using System.Diagnostics;
	using MetraTech.DataAccess;
	using MetraTech.DataAccess.OleDb;
	using NUnit.Framework;

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.DataAccess.Test.ConnectionTests  /assembly:O:\debug\bin\MetraTech.DataAccess.Test.dll
	//

  [Category("NoAutoRun")]
  [TestFixture] 
	public class ConnectionTests
	{
		ConnectionInfo connInfo = null;
		DBType DatabaseType
		{
			get 
			{
				if (connInfo == null)
					connInfo = new ConnectionInfo("NetMeter");
				return connInfo.DatabaseType;
			}
		}

    [Test]
    public void T01TestSimpleStatement()
		{
			using(IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
			{
                using (IMTStatement stmt = conn.CreateStatement("SELECT id_sess FROM t_acc_usage"))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            long id_sess = reader.GetInt64("id_sess");
                        }
                    }
                }
			}
		}
	
		[Test]
    public void T02TestAdapterStatement()
		{
			using(IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ProductCatalog", "__GET_CALENDAR_BYNAME__"))
                {
                    stmt.AddParam("%%CALENDAR_NAME%%", "AudioConf Setup Calendar");
                    stmt.AddParam("%%ID_LANG%%", 840);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            System.Console.WriteLine("Calendar display name = {0}", reader.GetString("nm_name"));
                        }
                    }
                }

				conn.CommitTransaction();
			}
		}
	
		[Test]
    public void T03TestServicedStatement()
		{
			ServicedComponentTester tester = new ServicedComponentTester();
			String str = tester.RetrieveCalendar();
			Console.WriteLine("Serviced display name = {0}", str);
			tester.Dispose();
	
			try
			{
				using(ServicedErrorWrapper wrapper = new ServicedErrorWrapper())
				{
					wrapper.RetrieveCalendar(true);
					Assert.IsTrue(false);
				}
			}
			catch(ApplicationException )
			{
			}
	
			ServicedErrorWrapper outer = new ServicedErrorWrapper();
			Assert.AreEqual(str, outer.RetrieveCalendar(false));
			outer.Dispose();
		}
	
		[Test]
		// TODO: this test fails on smoke test machines
		[Ignore("Need to rework this test so that it uses a non-product stored procedure.")]
    public void T04TestStoredProcedure()
		{
			using(IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
			{
                int id = -1;
                int count = -1;

                using (IMTCallableStatement stmt = conn.CreateCallableStatement("InsertProductView"))
                {
                    stmt.AddParam("a_id_view", MTParameterType.Integer, 123);
                    stmt.AddParam("a_nm_name", MTParameterType.WideString, "My PV");
                    stmt.AddParam("a_dt_modified", MTParameterType.DateTime, DateTime.Now);
                    stmt.AddParam("a_nm_table_name", MTParameterType.WideString, "t_my_pv");
                    stmt.AddOutputParam("a_id_prod_view", MTParameterType.Integer);

                    count = stmt.ExecuteNonQuery();
                    Assert.AreEqual(1, count);

                    id = (int)stmt.GetOutputValue("a_id_prod_view");

                    Console.WriteLine("Inserted Product View with id = {0}.  Deleting...", id);
                }

				conn.CommitTransaction();

                using (IMTStatement deleteStmt = conn.CreateStatement("DELETE FROM t_prod_view WHERE id_prod_view = " + id))
                {
                    count = deleteStmt.ExecuteNonQuery();
                    Assert.AreEqual(1, count);
                }

				conn.CommitTransaction();
			}
		}
	
		[Test]
    public void T05TestSelectStoredProcedure()
		{
			using(IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
			{
				System.Text.StringBuilder builder = new System.Text.StringBuilder();
				if (DatabaseType == DBType.SQLServer)
				{
				builder.Append("CREATE PROCEDURE SelectAccount @a_id_acc INTEGER ");
				builder.Append("AS ");
					builder.Append("SELECT id_type, dt_crt from t_account where id_acc = @a_id_acc");
				}
				else if (DatabaseType == DBType.Oracle)
				{
					builder.Append("create or replace procedure SelectAccount " + 
						"(p_a_id_acc integer, p_cur out sys_refcursor)\n");
					builder.Append("as\n");
					builder.Append("begin\n");
					builder.Append("  open p_cur for\n");
					builder.Append("    SELECT id_type, dt_crt from t_account where id_acc = p_a_id_acc;\n");
					builder.Append("end;\n");
				}
				else
					throw new ApplicationException(
						string.Format("Database type {0} not supported", connInfo.DatabaseType));
 
				Console.WriteLine("Creating stored procedure: {0}", builder.ToString());
                using (IMTStatement stmt = conn.CreateStatement(builder.ToString()))
                {
                    stmt.ExecuteNonQuery();
                }

				conn.CommitTransaction();

                using (IMTCallableStatement stmt = conn.CreateCallableStatement("SelectAccount"))
                {
                    stmt.AddParam("a_id_acc", MTParameterType.Integer, 123);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Console.WriteLine("Account Type ID: {0}", reader.GetInt32("id_type").ToString());
                            Console.WriteLine("Account Created: {0}", reader.GetDateTime("dt_crt"));
                        }
                    }
                }

				conn.CommitTransaction();

                using (IMTStatement stmt = conn.CreateStatement("DROP PROCEDURE SelectAccount"))
                {
                    stmt.ExecuteNonQuery();
                }

				conn.CommitTransaction();
			}
		}
	
		[Test]
    public void T06TestDataTypeSQLServer()
		{
			Console.WriteLine("TestDataTypeSQLServer()");
			if (DatabaseType != DBType.SQLServer)
				return;

			using(IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
			{
                using (IMTStatement stmt = conn.CreateStatement("IF EXISTS (select * from sysobjects where name = 'InsertTestDataType') " +
                                                         "DROP PROCEDURE InsertTestDataType"))
                {
                    stmt.ExecuteNonQuery();
                }

                using (IMTStatement stmt = conn.CreateStatement("IF EXISTS (select * from sysobjects where name = 't_test_data_type') " +
                                                         "DROP TABLE t_test_data_type"))
                {
                    stmt.ExecuteNonQuery();
                }

				conn.CommitTransaction();

                using (IMTStatement stmt = conn.CreateStatement("CREATE TABLE t_test_data_type(intval INTEGER, strval VARCHAR(255), " +
                                                         "binval VARBINARY(16), decval " +
														 Constants.METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_STR +
														 ", dtval DATETIME)"))
                {
                    stmt.ExecuteNonQuery();
                }
	
				System.Text.StringBuilder builder = new System.Text.StringBuilder();
				builder.Append("CREATE PROCEDURE InsertTestDataType @intval INTEGER, @strval VARCHAR(255), " + 
											 "@binval VARBINARY(16), @decval " +
											 Constants.METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_STR +
											 ", @dtval DATETIME ");
				builder.Append("AS ");
				builder.Append("INSERT INTO t_test_data_type (intval, strval, binval, decval, dtval) VALUES " + 
											 "(@intval, @strval, @binval, @decval, @dtval)");
                using (IMTStatement stmt = conn.CreateStatement(builder.ToString()))
                {
                    stmt.ExecuteNonQuery();
                }

				conn.CommitTransaction();
	
				// Create some data 
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("InsertTestDataType"))
                {
                    stmt.AddParam("intval", MTParameterType.Integer, 123);
                    stmt.AddParam("strval", MTParameterType.String, "strval");
                    stmt.AddParam("binval", MTParameterType.Binary, new byte[] { 0xff, 0x55 });
                    stmt.AddParam("decval", MTParameterType.Decimal, new Decimal(23.234234));
                    stmt.AddParam("dtval", MTParameterType.DateTime, DateTime.Parse("12/12/02 11:44:12"));
                    int ret = stmt.ExecuteNonQuery();
                    Assert.AreEqual(1, ret);
                }

				conn.CommitTransaction();
	
				// Now test reading the data back out.
                using (IMTStatement stmt = conn.CreateStatement("SELECT intval, strval, binval, decval, dtval FROM t_test_data_type"))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Assert.AreEqual(123, reader.GetInt32("intval"));
                            Assert.AreEqual("strval", reader.GetString("strval"));
                            byte[] val = reader.GetBytes("binval");
                            Assert.AreEqual(2, val.Length);
                            Assert.AreEqual(0xff, val[0]);
                            Assert.AreEqual(0x55, val[1]);
                            Assert.AreEqual(DateTime.Parse("12/12/02 11:44:12"), reader.GetDateTime("dtval"));
                            Assert.AreEqual(new Decimal(23.234234), reader.GetDecimal("decval"));
                        }
                    }
                }

				conn.CommitTransaction();

                using (IMTStatement stmt = conn.CreateStatement("IF EXISTS (select * from sysobjects where name = 'InsertTestDataType') " +
                                                         "DROP PROCEDURE InsertTestDataType"))
                {
                    stmt.ExecuteNonQuery();
                }

                using (IMTStatement stmt = conn.CreateStatement("IF EXISTS (select * from sysobjects where name = 't_test_data_type') " +
                                                         "DROP TABLE t_test_data_type"))
                {
                    stmt.ExecuteNonQuery();
                }

				conn.CommitTransaction();
			}
		}
	
		[Test]
    public void T07TestDataTypeOracle()
		{
			Console.WriteLine("TestDataTypeOracle()");
			if (DatabaseType != DBType.Oracle)
				return;

			using(IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
			{
				// drop test table, if it exists
				//
				try 
				{
                    using (IMTStatement stmt = conn.CreateStatement("drop table t_test_data_type"))
                    {
                        stmt.ExecuteNonQuery();
                    }
				}
				catch (Exception ex)
				{
					if (!ex.Message.StartsWith("ORA-00942"))
						throw ex;
				}

				// create temp test table
				//
                using (IMTStatement stmt = conn.CreateStatement("CREATE TABLE t_test_data_type(intval integer, strval varchar(255), " +
                    "binval raw(16), decval " +
					Constants.METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_STR +
					", dtval date)"))
                {
                    stmt.ExecuteNonQuery();
                }
	
				conn.CommitTransaction();

				// create test proc
				//
				System.Text.StringBuilder builder = new System.Text.StringBuilder();
				builder.Append("create or replace procedure InsertTestDataType (\n" +
					"p_intval integer, p_strval varchar2, \n" + 
					"p_binval raw, p_decval number, p_dtval date)\n");
				builder.Append("as\n");
				builder.Append("begin\n");
				builder.Append("   insert into t_test_data_type (intval, strval, binval, decval, dtval)\n");
				builder.Append("   values (p_intval, p_strval, p_binval, p_decval, p_dtval);\n");
				builder.Append("end;\n");
                using (IMTStatement stmt = conn.CreateStatement(builder.ToString()))
                {
                    stmt.ExecuteNonQuery();
                }
				conn.CommitTransaction();
	
				// call test proc
				//
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("InsertTestDataType"))
                {
                    stmt.AddParam("p_intval", MTParameterType.Integer, 123);
                    stmt.AddParam("p_strval", MTParameterType.String, "strval");
                    stmt.AddParam("p_binval", MTParameterType.Binary, new byte[] { 0xff, 0x55 });
                    stmt.AddParam("p_decval", MTParameterType.Decimal, new Decimal(23.234234));
                    stmt.AddParam("p_dtval", MTParameterType.DateTime, DateTime.Parse("12/12/02 11:44:12"));
                    int ret = stmt.ExecuteNonQuery();
                    Assert.AreEqual(ret, -1);
                }

				conn.CommitTransaction();
	
				// Now test reading the data back out.
				//
                using (IMTStatement stmt = conn.CreateStatement(
                            "SELECT intval, strval, binval, decval, dtval FROM t_test_data_type"))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Assert.AreEqual(123, reader.GetInt32("intval"));
                            Assert.AreEqual("strval", reader.GetString("strval"));
                            byte[] val = reader.GetBytes("binval");
                            Assert.AreEqual(2, val.Length);
                            Assert.AreEqual(0xff, val[0]);
                            Assert.AreEqual(0x55, val[1]);
                            Assert.AreEqual(DateTime.Parse("12/12/02 11:44:12"), reader.GetDateTime("dtval"));
                            Assert.AreEqual(new Decimal(23.234234), reader.GetDecimal("decval"));
                        }
                    }
                }
				conn.CommitTransaction();

                using (IMTStatement stmt = conn.CreateStatement("drop table t_test_data_type"))
                {
                    stmt.ExecuteNonQuery();
                }

                using (IMTStatement stmt = conn.CreateStatement("drop procedure InsertTestDataType"))
                {
                    stmt.ExecuteNonQuery();
                }
				conn.CommitTransaction();
			}
		}
		
		[Test]
    public void T08TestReadToXml()
		{
    	using(IMTConnection conn = ConnectionManager.CreateConnection())
    	{
            using (IMTStatement stmt = conn.CreateStatement("select * from t_acc_usage"))
            {
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    int rowsRead;
                    string xml = reader.ReadToXml("outerTag", "innerTag", 2, out rowsRead);
                    Console.Write(xml);
                }
            }
    	}
  	}
	}
}
