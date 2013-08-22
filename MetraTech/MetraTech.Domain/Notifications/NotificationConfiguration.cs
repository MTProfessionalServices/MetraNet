using System;
using System.Runtime.Serialization;
using MetraTech.Domain.DataAccess;

namespace MetraTech.Domain.Notifications
{
	[DataContract(Namespace = "MetraTech.MetraNet")]
	public class NotificationConfiguration : Entity
	{
		[DataMember]
		public string EventType { get; set; }

		[DataMember]
		public NotificationType NotificationType { get; set; }

    [DataMember]
    public string Criteria { get; set; }

    [DataMember]
		public Guid NotificationEndpointEntityId { get; set; }

		public virtual NotificationEndpoint NotificationEndpoint { get; set; }

		[DataMember]
		public MessageTemplate MessageTemplate { get; set; }

		/// <summary>
		/// Represents settings as Xml field in the database. Should be used only by Entity Framework.
		/// </summary>
		public string MessageTemplateXml
		{
			get { return MessageTemplate == null ? null : MessageTemplate.Serialize(); }
			set { MessageTemplate = SerializationHelper.Deserialize<MessageTemplate>(value); }
		}

	}
}
