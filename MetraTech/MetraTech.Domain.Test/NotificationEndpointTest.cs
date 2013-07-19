using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Domain.DataAccess;
using MetraTech.Domain.Notifications;
//using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Domain.Test
{
    /// <summary>
    /// Notification endpoint test
    /// </summary>
    [TestClass]
    public class NotificationEndpointTest
    {
        [TestMethod]
        public void CreateNotificationEndpointTest()
        {
            var context = new MetraNetContext();
            var notificationEndpoint = new NotificationEndpoint()
            {
                Active = true,
                AuthenticationConfiguration = new NetworkAuthenticationConfiguration()
                {
                    UserName = "aaa",
                    Password = "bbb"
                },
                CreationDate = DateTime.Now,
                EntityId = Guid.NewGuid(),
                ExternalId = "Notification endpoint test" + DateTime.Now.Ticks
            };
            context.Entities.Add(notificationEndpoint);
            context.SaveChanges();
        }
    }
}
