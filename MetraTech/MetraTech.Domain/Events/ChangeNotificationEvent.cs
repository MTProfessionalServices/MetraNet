namespace MetraTech.Domain.Events
{
    /// <summary>
    /// Defines the Change Notification Event that is used to send an email notification
    /// </summary>
    public class ChangeNotificationEvent : Event
    {
        /// <summary>
        /// The email of the user that submitted the change
        /// </summary>
        public string SubmitterEmail { get; set; }

        /// <summary>
        /// The id of the change that was submitted
        /// </summary>
        public int ChangeId { get; set; }

        /// <summary>
        /// Comments entered by the person approving or dismissing the change
        /// </summary>
        public string Comment { get; set; }
    }
}
