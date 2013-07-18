using System.Runtime.Serialization;

namespace MetraTech.Domain.Notifications
{
	/// <summary>
	/// Represents a base class for configuring notifications.
	/// </summary>
	[DataContract(Namespace = "MetraTech.MetraNet")]
	[KnownType(typeof(EmailTemplate))]
	public abstract class MessageTemplate
	{
	}
}
