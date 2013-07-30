using System;
using MetraTech.Domain.DataAccess;

namespace MetraTech.Domain.Notifications
{
    public class NotificationConfiguration : Entity
    {
      public string EventType { get; set; }
      public NotificationType NotificationType { get; set; }
      public Guid NotificationEndpointEntityId { get; set; }
      public virtual NotificationEndpoint NotificationEndpoint { get; set; }
      public EmailTemplate EmailTemplate { get; set; }

      /// <summary>
      /// Represents settings as Xml field in the database. Should be used only by Entity Framework.
      /// </summary>
      public string EmailTemplateXml
      {
        get { return EmailTemplate == null ? null : EmailTemplate.Serialize(); }
        set { EmailTemplate = SerializationHelper.Deserialize<EmailTemplate>(value); }
      }

    }
}
