using System.Runtime.Serialization;
using MetraTech.Domain.DataAccess;

namespace MetraTech.Domain.Notifications
{
  /// <summary>
  /// The NotificationEndpoint class represents a notification endpoint in Metanga.
  /// You can use notification endpoints to support different methods of authentication to external systems.
  /// </summary>
  [DataContract(Namespace = "MetraTech.MetraNet")]
  public class NotificationEndpoint : Entity
  {
    /// <summary>
    /// Represents a state of the endpoint. Notification endpoint and notification itself can be Enabled or Disabled independently.
    /// And notification message will be sent only if both of them the Notification and the Endpoint are Active.
    /// </summary>
    [DataMember]
    public bool Active { get; set; }

    /// <summary>
    /// Represents settings to be used for sending notification messages.
    /// It can be initialized by SoapNotificationConfiguration object or RestfulNotificationConfiguration object.
    /// </summary>
    [DataMember]
    public NotificationEndpointConfiguration EndpointConfiguration { get; set; }

    /// <summary>
    /// Represents settings as Xml field in the database. Should be used only by Entity Framework.
    /// </summary>
    public string EndpointConfigurationXml
    {
      get { return EndpointConfiguration == null ? null : EndpointConfiguration.Serialize(); }
      set { EndpointConfiguration = SerializationHelper.Deserialize<NotificationEndpointConfiguration>(value); }
    }

    /// <summary>
    /// Represents an authentication protocol to be used for authentication at the service that is listenning for the notification message.
    /// It can be initialized by ClientCertificateConfiguration object or OAuthWebServerConsumerConfiguration object.
    /// </summary>
    [DataMember]
    public AuthenticationConfiguration AuthenticationConfiguration { get; set; }

    /// <summary>
    /// Represents an authentication protocol as Xml field in the database. Should be used only by Entity Framework.
    /// </summary>
    public string AuthenticationConfigurationXml
    {
      get { return AuthenticationConfiguration == null ? null : AuthenticationConfiguration.Serialize(); }
      set { AuthenticationConfiguration = SerializationHelper.Deserialize<AuthenticationConfiguration>(value); }
    }
  }
}
