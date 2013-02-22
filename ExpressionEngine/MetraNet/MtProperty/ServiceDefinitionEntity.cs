using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.MetraNet.MtProperty
{
    [DataContract]
    public class ServiceDefinitionEntity : Entity
    {
        #region Properties
        [DataMember]
        public bool AutoResubmit { get; set; }

        [DataMember]
        public bool AutoDelete { get; set; }
        #endregion

        #region Constructor
        public ServiceDefinitionEntity(string name, string description) : base(name, ComplexType.ProductView, null, true, description)
        {
          //Add the core properties
          var accountId = Properties.AddInteger32("AccountId", "The internal MetraNet account identifiert", true);
          accountId.IsCore = true;

          var timestamp = Properties.AddDateTime("Timestamp", "The time the event is deemed to have occurred", true);
          timestamp.IsCore = true;
        }
        #endregion
    }
}
