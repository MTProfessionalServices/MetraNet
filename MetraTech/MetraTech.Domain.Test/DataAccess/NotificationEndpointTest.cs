using System;
using System.Linq;
using MetraTech.DataAccess;
using MetraTech.Domain.DataAccess;
using MetraTech.Domain.Notifications;
using Microsoft.VisualStudio.TestTools.UnitTesting;
//using MetraTech.TestCommon;

namespace MetraTech.Domain.Test.DataAccess
{
    /// <summary>
    /// Notification endpoint test
    /// </summary>
    [TestClass]
    public class NotificationEndpointTest
    {
        [TestMethod]
        [TestCategory("FunctionalTest")]
        public void CreateNotificationEndpointTest()
        {
            var notificationEndpoint = EntityFactory.CreateTestNotificationEndpoint();
            var connectionInfo = new ConnectionInfo("NetMeter");
            var connection = ConnectionBase.GetDbConnection(connectionInfo, false);
            NotificationEndpoint notificationEndpointFromDb;

            using (var db = new MetraNetContext(connection))
            {
                db.Entities.Add(notificationEndpoint);
                db.SaveChanges();
                notificationEndpointFromDb = db.NotificationEndpoints.SingleOrDefault(x => x.EntityId == notificationEndpoint.EntityId);
            }

            Assert.IsNotNull(notificationEndpointFromDb, "Notification endpoint was not created");
            CompareNotificationEndpoints(notificationEndpoint, notificationEndpointFromDb);
            
            
        }

        private void CompareNotificationEndpoints(NotificationEndpoint notificationEndpoint, NotificationEndpoint notificationEndpointFromDb)
        {
            Comparers.CompareDictionaries(notificationEndpoint.Name, notificationEndpointFromDb.Name, "Name");
            Comparers.CompareDictionaries(notificationEndpoint.Description, notificationEndpointFromDb.Description, "Description");
            Assert.AreEqual(notificationEndpoint.ExternalId, notificationEndpointFromDb.ExternalId);
            Assert.AreEqual(notificationEndpoint.CreationDate, notificationEndpointFromDb.CreationDate);
            Assert.AreEqual(notificationEndpoint.ModifiedDate, notificationEndpointFromDb.ModifiedDate);
            Assert.AreEqual(notificationEndpoint.EntityId, notificationEndpointFromDb.EntityId);
            Assert.AreEqual(notificationEndpoint.EndpointConfiguration.Serialize(), notificationEndpointFromDb.EndpointConfiguration.Serialize());
            Assert.AreEqual(notificationEndpoint.Active, notificationEndpointFromDb.Active);
            Assert.AreEqual(notificationEndpoint.AuthenticationConfiguration.Serialize(), notificationEndpoint.AuthenticationConfiguration.Serialize());
        }
    }
}
