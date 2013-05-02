using System;
using System.Collections;
using System.Runtime.InteropServices;

using NUnit.Framework;

using MetraTech.Interop.MTPipelineLib;
using MetraTech.DataAccess;
using MetraTech.Utils;

namespace MetraTech.Pipeline.Plugins.Test
{
	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Pipeline.Plugins.Test.RemeterPluginTest 
  //               /assembly:O:\debug\bin\MetraTech.Pipeline.Plugins.Test.dll
	//
  [Category("NoAutoRun")]
  [TestFixture]
	public class RemeterPluginTest
	{
    public RemeterPluginTest() 
    {
      pluginTestLib = new PluginTestLib(extensionName);
    }

    [SetUp]
    public void Init()
    {
      plugin = pluginTestLib.CreatePlugin(pluginProgId, pluginConfiguration);
    }

    [TearDown]
    public void Dispose()
    {
      plugin.Shutdown();
      plugin = null;
    }

    // Test
//    [Test]
//    public void TestRemeterPluginStatic()
//    {
//      plugin.CreateSessionSet(sessionData);
//      plugin.ProcessSessions();
//
//      // Check expected session changes here
//
//      // The remeter plugin remeters sessions of the type 
//      // specified in the remeter plugin configuration file at 
//      // (xmlconfig->configdata->ServiceName).
//      
//      // The test will check if the expected rows exist in the t_svc_testparent
//      // table based on the value of the '_collectionID' field.
//      CheckCollectionId(uid, 2);
//    }

    // Test
    [Test]
    public void TestRemeterPluginDynamic()
    {
      PluginSession pluginSession = null;
      
      string collectionId = MSIXUtils.CreateUID();

      pluginSession = plugin.CreateSession();

      pluginSession.SetProperty("RemeterProcessSession", "1", PropertyType.Bool);
      pluginSession.SetProperty("description", "Some descr", PropertyType.String);
      pluginSession.SetProperty("time", DateTime.Now, PropertyType.DateTime);
      pluginSession.SetProperty("accountname", "IADaily", PropertyType.String);
      pluginSession.SetProperty("_collectionID", collectionId, PropertyType.String);

      pluginSession = plugin.CreateSession();

      pluginSession.SetProperty("RemeterProcessSession", "1", PropertyType.Bool);
      pluginSession.SetProperty("description", "Some descr", PropertyType.String);
      pluginSession.SetProperty("time", DateTime.Now, PropertyType.DateTime);
      pluginSession.SetProperty("accountname", "IADaily", PropertyType.String);
      pluginSession.SetProperty("_collectionID", collectionId, PropertyType.String);

      pluginSession = plugin.CreateSession();

      pluginSession.SetProperty("RemeterProcessSession", "1", PropertyType.Bool);
      pluginSession.SetProperty("description", "Some descr", PropertyType.String);
      pluginSession.SetProperty("time", DateTime.Now, PropertyType.DateTime);
      pluginSession.SetProperty("accountname", "IADaily", PropertyType.String);
      pluginSession.SetProperty("_collectionID", collectionId, PropertyType.String);
      
      plugin.ProcessSessions();

      // Check expected session changes here

      // The remeter plugin remeters sessions of the type 
      // specified in the remeter plugin configuration file at 
      // (xmlconfig->configdata->ServiceName).
      
      // The test will check if the expected rows exist in the t_svc_testparent
      // table based on the value of the '_collectionID' field.
      CheckCollectionId(collectionId, 3);
    }

    private void CheckCollectionId(string uid, int expectedSessionCount) 
    {
      int meteredCount = 0;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTPreparedStatement stmt =
            conn.CreatePreparedStatement
            (
              "select count(*) from t_svc_testparent tp " +
              "inner join t_batch b on b.tx_batch = tp.c__collectionID " +
              "where b.tx_batch_encoded = '" +
               uid +
               "'"
            ))
          {

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      meteredCount = reader.GetInt32(0);
                  }
              }
          }
      }

      Assert.AreEqual
        (expectedSessionCount, meteredCount,
				"Number of services remetered do not match number of services found!");
    }

    // Data
    private PluginTestLib pluginTestLib;
    private Plugin plugin;

    private const string extensionName = "metratech.com/testparent";
    private const string pluginProgId = "MetraPipeline.MTReMeterPlugin.1";
    private const string sessionDescription = "Some Description";
    private const int sessionCount = 2;
    private const string uid = "wKgBW0hmL495MAdBccX//w==";

    private const string pluginConfiguration = 
      "<xmlconfig>" +
        // "<mtsysconfigdata>" +
        //  "<effective_date ptype=\"DATETIME\">1998-11-19T00:00:00Z</effective_date>" +
        //  "<timeout ptype=\"INTEGER\">30</timeout>" +
        //  "<configfiletype>CONFIG_DATA</configfiletype>" +
        // "</mtsysconfigdata>" +

        // "<mtconfigdata>" +
        //  "<version ptype=\"INTEGER\">1</version>" +
        //  "<!-- First processor configuration -->" +
        //  "<processor>" +
        //    "<name>Remeter</name>" +
        //    "<progid>MetraPipeline.MTReMeterPlugin.1</progid>" +
        //    "<description>Transactionally remeters to AccountCreation stage</description>" +
        //    "<inputs></inputs>" +
        //    "<outputs></outputs>" +

            "<!-- Processor specific configuration data -->" +
            "<configdata>" +
              "<ServerAccessEntry>DTCGetWhereAbouts</ServerAccessEntry>" +
              "<Listener></Listener>" +
              "<Secure ptype=\"BOOLEAN\">FALSE</Secure>" +
              "<AlternatePort ptype=\"INTEGER\">0</AlternatePort>" +
              "<MeterUserName></MeterUserName>" +
              "<MeterUserPassword></MeterUserPassword>" +
              "<RequestFeedback ptype=\"BOOLEAN\">FALSE</RequestFeedback>" +
              "<Transactional ptype=\"BOOLEAN\">TRUE</Transactional>" +
              "<Retries ptype=\"INTEGER\">1</Retries> " +
              "<ServiceName>metratech.com/testparent</ServiceName>" +
              "<RemeterProcessSession>RemeterProcessSession</RemeterProcessSession>" +
              "<ServiceProperties>" +
                "<ReMeterServiceTag>description</ReMeterServiceTag>" +
                "<SessionProp>description</SessionProp>" +
                "<type>string</type>" +
                "<ReMeterServiceTag>time</ReMeterServiceTag>" +
                "<SessionProp>time</SessionProp>" +
                "<type>timestamp</type>" +
                "<ReMeterServiceTag>accountname</ReMeterServiceTag>" +
                "<SessionProp>accountname</SessionProp>" +
                "<type>string</type>" +
                "<ReMeterServiceTag>_collectionID</ReMeterServiceTag>" +
                "<SessionProp>_collectionID</SessionProp>" +
                "<type>string</type>" +
              "</ServiceProperties>" +

              "<FeedBackProperties>" +
                "<ReMeterServiceTag>description</ReMeterServiceTag>" +
                "<SessionProp>description</SessionProp>" +
                "<Type>string</Type>" +
                "<ReMeterServiceTag>time</ReMeterServiceTag>" +
                "<SessionProp>time</SessionProp>" +
                "<type>timestamp</type>" +
              "</FeedBackProperties>" +
            "</configdata>" +
        // "</processor>" +
        // "</mtconfigdata>" +
      "</xmlconfig>";

    private const string sessionData = 
      "<xmlconfig>" +
        "<session>" +

          "<property>" +
            "<name>RemeterProcessSession</name>" +
            "<value>1</value>" +
            "<type>bool</type>" +
          "</property>" +

          "<property>" +
            "<name>description</name>" +
            "<value>" + sessionDescription + "</value>" +
            "<type>string</type>" +
          "</property>" +

          "<property>" +
            "<name>time</name>" +
            "<value>[metratime]</value>" +
            "<type>timestamp</type>" +
          "</property>" +

          "<property>" +
            "<name>accountname</name>" +
            "<value>IADaily</value>" +
            "<type>string</type>" +
          "</property>" +

          "<property>" +
            "<name>_collectionID</name>" +
            "<value>" + uid + "</value>" +
            "<type>string</type>" +
          "</property>" +

        "</session>" +

      "<session>" +

        "<property>" +
          "<name>RemeterProcessSession</name>" +
          "<value>1</value>" +
          "<type>bool</type>" +
        "</property>" +

        "<property>" +
          "<name>description</name>" +
          "<value>" + sessionDescription + "</value>" +
          "<type>string</type>" +
        "</property>" +

        "<property>" +
          "<name>time</name>" +
          "<value>[metratime]</value>" +
          "<type>timestamp</type>" +
        "</property>" +

        "<property>" +
          "<name>accountname</name>" +
          "<value>IADaily</value>" +
          "<type>string</type>" +
        "</property>" +

      "<property>" +
        "<name>_collectionID</name>" +
        "<value>" + uid + "</value>" +
        "<type>string</type>" +
      "</property>" +

      "</session>" +
      "</xmlconfig>";
	}
}
