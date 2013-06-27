using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract (Namespace = "MetraTech")]
    public class ServiceDefinitionEntity : PropertyBag
    {
        #region Properties
        [DataMember]
        public bool AutoResubmit { get; set; }

        [DataMember]
        public bool AutoDelete { get; set; }

        public override string DatabaseColumnName { get { return "t_sd_" + Name; } }

        #endregion

        #region Constructor
        public ServiceDefinitionEntity(string _namespace, string name, string description)
            : base(_namespace, name, PropertyBagConstants.ServiceDefinition, PropertyBagMode.ExtensibleEntity, description)
        {
        }
        #endregion
    }
}
