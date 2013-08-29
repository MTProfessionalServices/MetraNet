using System;
using System.Linq;
using MetraTech.DataAccess;
using MetraTech.Domain.DataAccess;
using MetraTech.Domain.Notifications;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Data.Entity;
//using MetraTech.TestCommon;
using System.Linq.Dynamic;

namespace MetraTech.Domain.Test.DataAccess
{
    /// <summary>
    /// Notification endpoint test
    /// </summary>
    [TestClass]
    public class GenericRetrieveSortFilterTest
    {
      //ToDo: Move to EntityFactory even though it saves to database?
      /// <summary>
      /// Create a given number of NotificationEndpoints with unique external ids
      /// </summary>
      /// <param name="numberToCreate">Number of items to create</param>
      /// <param name="externalId">Partial external id to create</param>
      public void CreateNotificationEndpoints(int numberToCreate, string externalId)
      {
        var connectionInfo = new ConnectionInfo("NetMeter");
        var connection = ConnectionBase.GetDbConnection(connectionInfo, false);
        NotificationEndpoint notificationEndpointFromDb;

        using (var db = new MetraNetContext(connection))
        {
          for (int i = 1; i <= numberToCreate; i++)
          {
            var notificationEndpoint =
              EntityFactory.CreateTestNotificationEndpoint(string.Format("{0} : #{1}", externalId, i));

            db.Entities.Add(notificationEndpoint);
            db.SaveChanges();
          }
        }
      }

      [TestMethod]
      [TestCategory("FunctionalTest")]
      public void GetNotificationEndpointListTest()
      {
        using (var db = new MetraNetContext())
        {
          var allEndpoints = db.NotificationEndpoints;
          var activeEndpoints = db.NotificationEndpoints.Where(ne => ne.Active == true);
          var nonActiveEndpoints = db.NotificationEndpoints.Where(ne => ne.Active != true);

          Assert.IsTrue(allEndpoints.Count() == activeEndpoints.Count() + nonActiveEndpoints.Count(),
                        "Count of all endpoints {0} doesn't match the total count of active {1} and not active {2}");
        }
      }

      [TestMethod]
      [TestCategory("FunctionalTest")]
      public void EntityListSortTest()
      {
        string testRunUniqueIdentifier = DateTime.Now.ToString();
        CreateNotificationEndpoints(10, "Sort Test " + testRunUniqueIdentifier);

        var connectionInfo = new ConnectionInfo("NetMeter");
        var connection = ConnectionBase.GetDbConnection(connectionInfo, false);
        NotificationEndpoint notificationEndpointFromDb;

        using (var db = new MetraNetContext(connection))
        {
          //var allEndpoints2 = db.NotificationEndpoints.OrderBy("ExternalId").Select(x => new { x.ExternalId, x.Active }); //x.Name["en-us"]
          var allEndpoints = db.NotificationEndpoints.OrderBy("Active").Select("new (ExternalId, Active)"); //", Name[\"en-us\"] as NameLocalized)"); //x.Name["en-us"]

          //TODO: Actually verify they are sorted [grin]

          //Console.WriteLine(allEndpoints.ToList());
        }
      }

      [TestMethod]
      [TestCategory("FunctionalTest")]
      public void EntityListToJsonTest()
      {

        var connectionInfo = new ConnectionInfo("NetMeter");
        var connection = ConnectionBase.GetDbConnection(connectionInfo, false);
        NotificationEndpoint notificationEndpointFromDb;

        using (var db = new MetraNetContext(connection))
        {
          var allEndpoints = db.NotificationEndpoints.OrderBy("Active");

          System.Web.Script.Serialization.JavaScriptSerializer jss = new System.Web.Script.Serialization.JavaScriptSerializer();
          foreach (var endPoint in allEndpoints)
          {
            string testJson = jss.Serialize(endPoint);
            Console.WriteLine(testJson);
            Console.WriteLine("======================================");
          }

          Console.WriteLine(jss.Serialize(allEndpoints));
        }
      }
    }
}
