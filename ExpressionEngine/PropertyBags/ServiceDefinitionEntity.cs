using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Constants;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract (Namespace = "MetraTech")]
    public class ServiceDefinitionEntity : MetraNetEntityBase
    {
        #region Properties
        [DataMember]
        public bool AutoResubmit { get; set; }

        [DataMember]
        public bool AutoDelete { get; set; }

        public override string DatabaseName { get { return "t_sd_" + Name; } }
        #endregion

        #region Constructor
        public ServiceDefinitionEntity(string _namespace, string name, string description)
            : base(_namespace, name, PropertyBagConstants.ServiceDefinition, description)
        {
          //Add the core properties
          var accountId = Properties.AddInteger32("AccountId", "The internal MetraNet account identifier", true);
          accountId.IsCore = true;

          var timestamp = Properties.AddDateTime("Timestamp", "The time the event is deemed to have occurred", true);
          timestamp.IsCore = true;
        }
        #endregion
    }
}
