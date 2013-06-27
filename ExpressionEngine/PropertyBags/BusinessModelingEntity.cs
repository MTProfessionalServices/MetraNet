using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract(Namespace = "MetraTech")]
    public class BusinessModelingEntity : PropertyBag
    {
         #region Properties
        public override string SubDirectoryName { get { return "BusinessModelingEntities"; } }
        #endregion

        #region Constructor
        public BusinessModelingEntity(string _namespace, string name, string description)
            : base(_namespace, name, PropertyBagConstants.BusinessModelingEntity, PropertyBagMode.ExtensibleEntity, description)
        {
        }
        #endregion
    }
}
