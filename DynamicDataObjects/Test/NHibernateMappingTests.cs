using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;

// Metratech specific.
using NUnit.Framework;
using MetraTech.DataAccess;
using QueryAdapter = MetraTech.Interop.QueryAdapter;

// NHibernate must be installed for this namespace to be present.
using NHibernate;
using NHibernate.Cfg;

// Sample Dynamic Data Object assembly.
// Contains mapped object used by these tests.
using MetraTech.DynamicDataObjects.Samples;

namespace MetraTech.DynamicDataObjects.Test
{
  /// <summary>
  ///   Unit Tests for Dynamic Data Objects framework
  ///   
  ///   To run the this test fixture:
  //    nunit-console /fixture:MetraTech.DynamicDataObjects.Test.NHibernateMappingTests /assembly:O:\debug\bin\MetraTech.DynamicDataObjects.Test.dll
  /// </summary>
  [TestFixture]
  public class NHibernateMappingTests
  {
    // Data members.
    private static QueryAdapter.IMTQueryAdapter mQueryAdapter = new QueryAdapter.MTQueryAdapter();
    private Logger mLogger = new Logger("[NHibernateMappingTests]");
    private bool mIsOracle = false;

    // NHibernate session factory.
    ISessionFactory mNHSessionFactory = null;

    // Testing criteria.
    private string mTestMessagePrefix = "Test Message_";
    private int mMessageCount = 3;

    [TestFixtureSetUp]
    public void Setup()
    {
      // Initialize query adapter.
      mQueryAdapter.Init("Queries\\SmokeTest");

      // Determine if Oracle or MS SQL.
      ConnectionInfo connInfo = new ConnectionInfo("NetMeter");
      mIsOracle = (connInfo.DatabaseType == DBType.Oracle) ? true : false;

      // Prepare NHibernate database configuration.
      string connectionString = null;
      Configuration config = new Configuration();
      config.SetProperty(NHibernate.Cfg.Environment.ConnectionProvider, "NHibernate.Connection.DriverConnectionProvider");
      if (mIsOracle)
      {
        config.SetProperty(NHibernate.Cfg.Environment.Dialect, "NHibernate.Dialect.Oracle9Dialect");
        config.SetProperty(NHibernate.Cfg.Environment.ConnectionDriver, "NHibernate.Driver.OracleClientDriver");
        connectionString = @"Data Source=" + connInfo.Server +
                           @"; User Id=" + connInfo.UserName +
                           @"; Password=" + connInfo.Password +
                           @"; Persist Security Info=true; Pooling=false"; 
      }
      else
      {
        config.SetProperty(NHibernate.Cfg.Environment.Dialect, "NHibernate.Dialect.MsSql2005Dialect");
        config.SetProperty(NHibernate.Cfg.Environment.ConnectionDriver, "NHibernate.Driver.SqlClientDriver");
        connectionString = @"Server=" + connInfo.Server +
                           @";initial catalog=" + connInfo.Catalog +
                           @";Integrated Security=SSPI";
      }
      config.SetProperty(NHibernate.Cfg.Environment.ConnectionString, connectionString);
      config.AddAssembly("MetraTech.DynamicDataObjects.Samples");

      // Initialize NHibernate session factory.
      mNHSessionFactory = config.BuildSessionFactory();
    }

    [TestFixtureTearDown]
    public void TearDown()
    {
      if (mNHSessionFactory != null)
        mNHSessionFactory.Close();
    }

    /// <summary>
    /// This test simply reads some data out of the messages table using the
    /// NHibernate runtime engine, hardcoded class and NHibernate mapping file.
    /// </summary>
    [Test]
    [Category("NHibernate")]
    public void NHibernateSetupTest()
    {
      if (mNHSessionFactory == null)
      {
        mLogger.LogDebug("Nhibernate session factory is not initialized. TestNHibernateSetup not run.");
        return;
      }

      try
      {
        // Initialize the databse for MessageProvider object.
        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
          // Create table mapped to MessageProvider class via NHibernate mapping file.
          mQueryAdapter.SetQueryTag("__DDO_CREATE_MESSAGES_TABLE__");
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(mQueryAdapter.GetQuery()))
          {
              stmt.ExecuteNonQuery();
          }

          // Populate the table with some data.
          string query = "begin ";
          for (int i = 0; i < mMessageCount; i++)
          {
            mQueryAdapter.SetQueryTag("__DDO_INSERT_MESSAGE__");
            mQueryAdapter.AddParam("%%MESSAGE%%", mTestMessagePrefix + i.ToString(), true);
            query += " ";
            query += mQueryAdapter.GetQuery();
          }
          query += " end;";

          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(query))
          {
              stmt.ExecuteNonQuery();
          }
        }
      }
      catch (Exception ex)
      {
        Exception inner = ex.InnerException;
        mLogger.LogError("Failed initialize MessageProvier database table, error: " + inner.Message);
        throw ex;
      }

      ISession session = null;
      try
      {
        int id = 0;
        session = mNHSessionFactory.OpenSession();
        IList messages = session.CreateCriteria(typeof(MessageProvider)).List();
        foreach (MessageProvider item in messages)
        {
          // Check to make sure the correct data is read.
          Assert.AreEqual(item.Message, mTestMessagePrefix + id++);
        }

        // Make sure the counts match.
        Assert.AreEqual(mMessageCount, messages.Count, "MessageProvider records");
      }
      catch (Exception ex)
      {
        Exception inner = ex.InnerException;
        mLogger.LogError("Failed to load MessageProvier object data, error: " + inner.Message);
        throw ex;
      }
      finally
      {
        // Make sure to close the session.
        if (session != null)
          session.Close();
      }
    }
  }
}