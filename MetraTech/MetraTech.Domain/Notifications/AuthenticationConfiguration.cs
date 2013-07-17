using System.Runtime.Serialization;

namespace MetraTech.Domain.Notifications
{
  /// <summary>
  /// Represents a base class for configuring authentication method to be used by notifications at the notification endpoint. 
  /// </summary>
  [DataContract(Namespace = "MetraTech.MetraNet")]
  [KnownType(typeof(NetworkAuthenticationConfiguration))]
  public abstract class AuthenticationConfiguration
  {
  }
}
