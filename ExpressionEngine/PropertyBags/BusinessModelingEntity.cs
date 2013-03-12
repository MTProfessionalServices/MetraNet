using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Constants;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract(Namespace = "MetraTech")]
    public class BusinessModelingEntity : MetraNetEntityBase
    {
         #region Properties
        public override string SubDirectoryName { get { return "BusinessModelingEntities"; } }
        #endregion

        #region Constructor
        public BusinessModelingEntity(string _namespace, string name, string description) : base(_namespace, name, PropertyBagConstants.BusinessModelingEntity, description)
        {
        }
        #endregion
    }
}
