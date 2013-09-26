using System.Runtime.Serialization;

namespace MetraTech.Domain.Notifications
{
  /// <summary>
  /// Represents a base class for configuring notifications.
  /// </summary>
  [DataContract(Namespace = "MetraTech.MetraNet")]
  [KnownType(typeof(EmailEndpointConfiguration))]
  public abstract class NotificationEndpointConfiguration
  {
    /// <summary>
    /// Represents an URL address of your service that is listening for the notification messages.
    /// </summary>
    [DataMember]
    public string EndpointAddress { set; get; }

    /// <summary>
    /// Represents the TCP/UPD port of your service that is listening for the notification messages.
    /// </summary>
    [DataMember]
    public int? Port { set; get; }
  }
}