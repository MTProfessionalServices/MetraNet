using System.Runtime.Serialization;

namespace MetraTech.Domain.Notifications
{
  [DataContract(Namespace = "MetraTech.MetraNet")]
  public class NetworkAuthenticationConfiguration : AuthenticationConfiguration
  {
    [DataMember]
    public string UserName { get; set; }

    [DataMember]
    public string Password { get; set; }
  }
}
