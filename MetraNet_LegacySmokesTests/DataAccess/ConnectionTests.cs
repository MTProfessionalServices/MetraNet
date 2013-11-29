using System;
using System.Text;
using MetraTech.DataAccess.OleDb;
using MetraTech.TestCommon;
using NUnit.Framework;

namespace MetraTech.DataAccess.Test
{
  // To run the this test fixture:
  // nunit-console /fixture:MetraTech.DataAccess.Test.ConnectionTests  /assembly:O:\debug\bin\MetraTech.DataAccess.Test.dll
  [Category("NoAutoRun")]
  [TestFixture]
  public class ConnectionTests
  {
    #region Variables

    private const string TestProcedureName = "InsertTestDataType";
    private const string TestTableName = "t_test_data_type";
    private const int Intval = 123;
    private const string Strval = "strval";

    private static ConnectionInfo _connInfo;
    private static IMTNonServicedConnection _conn1;
    private static readonly byte[] Binval = { 0xff, 0x55 };
    private static readonly DateTime Dtval = DateTime.Parse("12/12/02 11:44:12");
    private static readonly Decimal Decval = new Decimal(23.234234);

    private static string _calendarName;

    #endregion

    #region Properties

    private static DBType DatabaseType
    {
      get
      {
        if (_connInfo == null)
          _connInfo = new ConnectionInfo("NetMeter");
        return _connInfo.DatabaseType;
      }
    }

    #endregion

    #region Test Initialization and Cleanup

    /// <summary>
    ///   Initialize data for ownership tests.
    /// </summary>
    [TestFixtureSetUp]
    public void Setup()
    {
      _conn1 = ConnectionManager.CreateNonServicedConnection();
      _calendarName = "AudioConf Setup Calendar " + DateTime.Now.Ticks;
      CreateCalendar();
    }

    /// <summary>
    /// Restore system to state prior the test run
    /// </summary>
    [TestFixtureTearDown]
    public void TearDown()
    {
      _conn1.Close();
      _conn1.Dispose();
    }

    #endregion

    #region Tests
    [Test]
    public void T01TestServicedStatement()
    {
      var tester = new ServicedComponentTester();
      var str = tester.RetrieveCalendar(_calendarName);
      Assert.AreEqual(str, _calendarName);
      tester.Dispose();
    }

    [Test]
    public void T02ServicedErrorWrapperPositiveTest()
    {
      var outer = new ServicedErrorWrapper();
      Assert.AreEqual(_calendarName, outer.RetrieveCalendar(false, _calendarName));
      outer.Dispose();
    }

    [Test]
    public void T03ServicedErrorWrapperNegativeTest()
    {
      var wrapper = new ServicedErrorWrapper();
      ExceptionAssert.Expected<ApplicationException>(() => wrapper.RetrieveCalendar(true, _calendarName), "Aborting transaction");
    }

    [Test]
    // TODO: this test fails on smoke test machines
    //[Ignore("Need to rework this test so that it uses a non-product stored procedure.")]
    public void T04TestStoredProcedure()
    {
      int id;
      using (var stmt = _conn1.CreateCallableStatement("InsertProductView"))
      {
        stmt.AddParam("a_id_view", MTParameterType.Integer, 123);
        stmt.AddParam("a_nm_name", MTParameterType.WideString, "My PV");
        stmt.AddParam("a_dt_modified", MTParameterType.DateTime, DateTime.Now);
        stmt.AddParam("a_nm_table_name", MTParameterType.WideString, "t_my_pv");
        stmt.AddParam("a_b_can_resubmit_from", MTParameterType.WideString, "N");
        stmt.AddOutputParam("a_id_prod_view", MTParameterType.Integer);

        var count = stmt.ExecuteNonQuery();
        Assert.AreEqual(1, count);

        id = (int) stmt.GetOutputValue("a_id_prod_view");

      }
      _conn1.CommitTransaction();

      ExecuteStatement("DELETE FROM t_prod_view WHERE id_prod_view = " + id);
    }

    [Test]
    public void T05TestSelectStoredProcedure()
    {
      const string procedureName = "SelectAccount";
      DropTestStoredProcedure(procedureName);
      var builder = new StringBuilder();
      switch (DatabaseType)
      {
        case DBType.SQLServer:
          builder.Append("CREATE PROCEDURE "+procedureName+" @a_id_acc INTEGER ");
          builder.Append("AS ");
          builder.Append("SELECT id_type, dt_crt from t_account where id_acc = @a_id_acc");
          break;
        case DBType.Oracle:
          builder.Append("create or replace procedure "+procedureName+" " +
                         "(p_a_id_acc integer, p_cur out sys_refcursor)\n");
          builder.Append("as\n");
          builder.Append("begin\n");
          builder.Append("  open p_cur for\n");
          builder.Append("    SELECT id_type, dt_crt from t_account where id_acc = p_a_id_acc;\n");
          builder.Append("end;\n");
          break;
        default:
          throw new ApplicationException(string.Format("Database type {0} not supported", _connInfo.DatabaseType));
      }
      ExecuteStatement(builder);


      using (var stmt = _conn1.CreateCallableStatement(procedureName))
      {
        stmt.AddParam("a_id_acc", MTParameterType.Integer, 123);

        using (var reader = stmt.ExecuteReader())
        {
          Assert.IsTrue(reader.Read(), "Accounts with id = 123 is not found");
          Assert.AreEqual(6, reader.GetInt32("id_type"), "Account with id = 123 must have id_type = 6");
          Assert.IsFalse(reader.Read(), "More than 1 accounts with id = 123");
        }
      }
      _conn1.CommitTransaction();

      DropTestStoredProcedure(procedureName);
    }

    [Test]
    public void T06TestDataTypeSqlServer()
    {
      if (DatabaseType != DBType.SQLServer)
        return;

      CreateTestTable();
      CreateTestStoredProcedureSqlServer();

      CallTestProcedure(1);
      GetBackDataFromTestTable();


      DropTestStoredProcedure(TestProcedureName);
      DropTestTable(TestTableName);
    }
    
    [Test]
    public void T07TestDataTypeOracle()
    {
      if (DatabaseType != DBType.Oracle)
        return;

      CreateTestTable();
      CreateTestStoredProcedureOracle();

      CallTestProcedure(-1);
      GetBackDataFromTestTable();

      DropTestTable(TestTableName);
      DropTestStoredProcedure(TestProcedureName);
    }

    [Test]
    public void T08TestReadToXml()
    {
      using (var conn = ConnectionManager.CreateConnection())
      {
        using (var stmt = conn.CreateStatement("select * from t_account"))
        {
          using (var reader = stmt.ExecuteReader())
          {
            int rowsRead;
            var xml = reader.ReadToXml("outerTag", "innerTag", 2, out rowsRead);
            Assert.IsNotEmpty(xml);
            Assert.Greater(rowsRead, 0);
          }
        }
      }
    }

    #endregion

    #region PrivateMethods

    private static void CreateCalendar()
    {
      int retVal;

      using (var stmt = _conn1.CreateCallableStatement("InsertBasePropsV2"))
      {
        stmt.AddParam("id_lang_code", MTParameterType.Integer, 840);
        stmt.AddParam("a_kind", MTParameterType.Integer, 240);
        stmt.AddParam("a_approved", MTParameterType.WideString, "N");
        stmt.AddParam("a_archive", MTParameterType.WideString, "N");
        stmt.AddParam("a_nm_name", MTParameterType.String, _calendarName);
        stmt.AddParam("@a_nm_desc", MTParameterType.String, _calendarName);
        stmt.AddParam("@a_nm_display_name", MTParameterType.String, null);
        stmt.AddOutputParam("a_id_prop", MTParameterType.Integer);
        stmt.ExecuteNonQuery();
        retVal = (int) stmt.GetOutputValue("a_id_prop");
      }

      using (var stmt = _conn1.CreateAdapterStatement("Queries\\ProductCatalog", "__ADD_CALENDAR__"))
      {
        stmt.AddParam("%%ID_CAL%%", retVal);
        stmt.AddParam("%%TZOFFSET%%", 0);
        stmt.AddParam("%%BCOMBWEEKEND%%", "F");
        stmt.ExecuteNonQuery();
      }

      _conn1.CommitTransaction();
    }

    private static void CreateTestTable()
    {
      DropTestTable(TestTableName);

      var queryText = new StringBuilder();
      queryText.Append("CREATE TABLE " + TestTableName + "(intval INTEGER, strval VARCHAR(255), ");
      queryText.Append("binval VARBINARY(16), decval ");
      queryText.Append(Constants.METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_STR);
      queryText.Append(", dtval DATETIME)");
      ExecuteStatement(queryText);
    }

    private static void DropTestTable(string tableName)
    {
      var queryText = new StringBuilder();
      if (DatabaseType == DBType.SQLServer)
        queryText.Append("IF EXISTS (select * from sysobjects where name = '"+ tableName +"') ");
      queryText.Append("DROP TABLE " + tableName);
      ExecuteStatement(queryText);
    }

    private static void CreateTestStoredProcedureSqlServer()
    {
      DropTestStoredProcedure(TestProcedureName); 
      
      var queryText = new StringBuilder();
      queryText.Append("CREATE PROCEDURE ");
      queryText.Append(TestProcedureName);
      queryText.Append(" @intval INTEGER, @strval VARCHAR(255), ");
      queryText.Append("@binval VARBINARY(16), @decval ");
      queryText.Append(Constants.METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_STR);
      queryText.Append(", @dtval DATETIME ");
      queryText.Append("AS ");
      queryText.Append("INSERT INTO " + TestTableName + " (intval, strval, binval, decval, dtval) VALUES ");
      queryText.Append("(@intval, @strval, @binval, @decval, @dtval)");
      ExecuteStatement(queryText);
    }

    private static void CreateTestStoredProcedureOracle()
    {
      var queryText = new StringBuilder();
      queryText.Append("create or replace procedure " + TestProcedureName + " (\n");
      queryText.Append("intval integer, strval varchar2, \n");
      queryText.Append("binval raw, decval number, dtval date)\n");
      queryText.Append("as\n");
      queryText.Append("begin\n");
      queryText.Append("   insert into " + TestTableName + " (intval, strval, binval, decval, dtval)\n");
      queryText.Append("   values (intval, strval, binval, decval, dtval);\n");
      queryText.Append("end;\n");
      ExecuteStatement(queryText);
    }

    private static void DropTestStoredProcedure(string procedureName)
    {
      var queryText = new StringBuilder();
      if (DatabaseType == DBType.SQLServer)
        queryText.Append("IF EXISTS (select * from sysobjects where name = '" + procedureName + "') ");
      queryText.Append("DROP PROCEDURE " + procedureName);
      ExecuteStatement(queryText);
    }

    private static void ExecuteStatement(string queryText)
    {
      using (var stmt = _conn1.CreateStatement(queryText))
      {
        stmt.ExecuteNonQuery();
      }
      _conn1.CommitTransaction();
    }

    private static void ExecuteStatement(StringBuilder queryText)
    {
      ExecuteStatement(queryText.ToString());
    }

    private static void CallTestProcedure(int expectedResult)
    {
      using (var stmt = _conn1.CreateCallableStatement(TestProcedureName))
      {
        stmt.AddParam("intval", MTParameterType.Integer, Intval);
        stmt.AddParam("strval", MTParameterType.String, Strval);
        stmt.AddParam("binval", MTParameterType.Binary, Binval);
        stmt.AddParam("decval", MTParameterType.Decimal, Decval);
        stmt.AddParam("dtval", MTParameterType.DateTime, Dtval);
        var ret = stmt.ExecuteNonQuery();
        Assert.AreEqual(expectedResult, ret);
      }
      _conn1.CommitTransaction();
    }

    private static void GetBackDataFromTestTable()
    {
      using (var stmt = _conn1.CreateStatement("SELECT intval, strval, binval, decval, dtval FROM " + TestTableName))
      {
        using (var reader = stmt.ExecuteReader())
        {
          while (reader.Read())
          {
            Assert.AreEqual(Intval, reader.GetInt32("intval"));
            Assert.AreEqual(Strval, reader.GetString("strval"));
            var val = reader.GetBytes("binval");
            Assert.AreEqual(2, val.Length);
            Assert.AreEqual(Binval[0], val[0]);
            Assert.AreEqual(Binval[1], val[1]);
            Assert.AreEqual(Dtval, reader.GetDateTime("dtval"));
            Assert.AreEqual(Decval, reader.GetDecimal("decval"));
          }
        }
      }
      _conn1.CommitTransaction();
    }

    #endregion
  }
}