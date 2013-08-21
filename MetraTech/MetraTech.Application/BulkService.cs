using System.Collections.Generic;
using System.Linq;
using MetraTech.Domain.DataAccess;
using MetraTech.Domain.Notifications;

namespace MetraTech.Application
{
  /// <summary>
  /// Service for processing bulk operations
  /// </summary>
  public static class BulkService
  {
    public static IEnumerable<NotificationEndpoint> RetrieveNotificationEndpoints()
    {
      IEnumerable<NotificationEndpoint> notificationEndpoints;

      using (var db = new MetraNetContext())
        notificationEndpoints = db.NotificationEndpoints.ToArray();

      return notificationEndpoints;
    }
  }
}
