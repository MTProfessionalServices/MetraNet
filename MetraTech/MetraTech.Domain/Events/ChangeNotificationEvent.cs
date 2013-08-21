using System.Runtime.Serialization;

namespace MetraTech.Domain.Events
{
    /// <summary>
    /// Defines the Change Notification Event that is used to send an email notification
    /// </summary>
  [DataContract(Namespace = "MetraTech.MetraNet")]
  public class ChangeNotificationEvent : Event
    {
        /// <summary>
        /// The email of the user that submitted the change
        /// </summary>
        [DataMember]
        public string SubmitterEmail { get; set; }

        /// <summary>
        /// The id of the change that was submitted
        /// </summary>
        [DataMember]
        public string ChangeId { get; set; }

        /// <summary>
        /// Comments entered by the person approving or dismissing the change
        /// </summary>
        [DataMember]
        public string Comment { get; set; }

        [DataMember]
        public string ApproverDisplayName { get; set; }

        [DataMember]
        public string ChangeType { get; set; }

        [DataMember]
        public string ItemDisplayName { get; set; }
    }
}
