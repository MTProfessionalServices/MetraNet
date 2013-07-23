using System.Runtime.Serialization;

namespace MetraTech.Domain.Notifications
{
  [DataContract(Namespace = "MetraTech.MetraNet")]
  public class LocalizedEmailTemplate
  {
    [DataMember]
    public string SubjectTemplate { get; set; }

    [DataMember]
    public string BodyTemplate { get; set; }
  }
}
