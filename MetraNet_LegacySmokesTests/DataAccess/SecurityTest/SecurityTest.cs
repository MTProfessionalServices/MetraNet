using System;
using System.Collections.Generic;
using System.Text;

using NUnit.Framework;

using MetraTech;
using MetraTech.DataAccess;
using MetraTech.Test;

namespace MetraTech.DataAccess.Test.SecurityTest
{

	//
	// To run the this test fixture:
  // nunit-console /fixture:MetraTech.DataAccess.Test.SecurityTest.SecurityTests /assembly:O:\debug\bin\MetraTech.DataAccess.Test.SecurityTest.dll
	//
  [Category("NoAutoRun")]
  [TestFixture]
	public class SecurityTests 
	{
    private Logger mLogger = new Logger("[SecurityTest]");

		/// <summary>
		/// Tests to run a simple query
		/// </summary>
		[Test]
    public void T01TestSimpleQuery()
		{
      TestLibrary.Trace("TestSimpleQuery");
      mLogger.LogDebug("Starting Simple Query Test...");
      
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("select * from t_account"))
            {
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        //TestLibrary.Trace(reader.GetInt32("id_acc").ToString(), true);
                        count++;
                    }
                    Assert.IsTrue(count > 0);
                }
            }
        }
      }
      catch (Exception exp)
      {
        mLogger.LogFatal("Error running test query. " + exp.ToString() );
        Assert.Fail();
      }
			
		}

    /// <summary>
    /// Tests to run a simple query with param
    /// </summary>
    [Test]
    public void T02TestSimpleParamQuery()
    {
      TestLibrary.Trace("TestSimpleParamQuery");
      mLogger.LogDebug("Starting TestSimpleParamQuery Test...");

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("select * from t_account where id_acc = %%ID%%"))
            {
                stmt.AddParam("%%ID%%", 123);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        TestLibrary.Trace("OK -->" + reader.GetInt32("id_acc").ToString(), true);
                        count++;
                    }
                    Assert.IsTrue(count > 0);
                }
            }
        }
      }
      catch (Exception exp)
      {
        mLogger.LogFatal("Error running TestSimpleParamQuery. " + exp.ToString());
        Assert.Fail();
      }

    }

    /// <summary>
    /// Tests to run a simple query with param that is hacked
    /// 
    /// Right now this test is failing.  The funny thing is we allow you to do AddParam for your parameters, but we don't
    /// enforce the type (which we do for a prepared statement).  I think this test should not work, and you should be forced
    /// to specify the type, or at least have the option to.
    /// </summary>
    [Test]
    [Ignore]  // CR entered for this
    public void T03TestHackedSimpleParamQuery()
    {
      TestLibrary.Trace("TestHackedSimpleParamQuery");
      mLogger.LogDebug("Starting TestHackedSimpleParamQuery Test...");

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("select * from t_account where id_acc = %%ID%%"))
            {
                stmt.AddParam("%%ID%%", "123 or 1=1");
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        TestLibrary.Trace("OK -->" + reader.GetInt32("id_acc").ToString(), true);
                        count++;
                    }
                    Assert.IsTrue(count == 1);
                }
            }
        }
      }
      catch (Exception exp)
      {
        mLogger.LogFatal("Error running TestHackedSimpleParamQuery. " + exp.ToString());
        Assert.Fail();
      }

    }

    /// <summary>
    /// Test running a simple callable statement
    /// </summary>
    [Test]
    [Ignore]  // CR entered for this, proc was removed, so we need a new test one.
    public void T04TestSimpleCallableStatement()
    {
      TestLibrary.Trace("TestSimpleCallableStatement");
      mLogger.LogDebug("Starting TestSimpleCallableStatement Test...");

      try
      {
        //InfoMessage msg = new InfoMessage("Hello", "World");
        string msgBlob = "hello";//msg.ToBlob(EventType.InfoMessage);

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTCallableStatement stmt = conn.CreateCallableStatement("createUIEvent"))
            {
                stmt.AddParam("EventType", MTParameterType.String, "info");
                stmt.AddParam("JSONBlob", MTParameterType.NText, msgBlob);
                stmt.AddParam("AccountID", MTParameterType.Integer, 129);
                stmt.ExecuteNonQuery();
            }
        }
      }
      catch (Exception exp)
      {
        mLogger.LogFatal("Error running TestSimpleCallableStatement. " + exp.ToString());
        Assert.Fail();
      }

    }

    /// <summary>
    /// Test running a simple callable statement that is hacked
    /// </summary>
    [Test]
    [Ignore]  // CR entered for this, proc was removed, so we need a new test one.
    public void T05TestHackSimpleCallableStatement()
    {
      TestLibrary.Trace("TestHackSimpleCallableStatement");
      mLogger.LogDebug("Starting TestHackSimpleCallableStatement Test...");

      try
      {
        //InfoMessage msg = new InfoMessage("Hello", "World");

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTCallableStatement stmt = conn.CreateCallableStatement("createUIEvent"))
            {
                stmt.AddParam("EventType", MTParameterType.String, "info");
                string hacked = "`'); Create table t_hacked;";
                stmt.AddParam("JSONBlob", MTParameterType.NText, hacked);
                stmt.AddParam("AccountID", MTParameterType.Integer, 129);
                stmt.ExecuteNonQuery();
            }
        }
      }
      catch (Exception exp)
      {
        mLogger.LogFatal("Error running TestHackSimpleCallableStatement. " + exp.ToString());
        Assert.Fail();
      }

    }

	}
}
