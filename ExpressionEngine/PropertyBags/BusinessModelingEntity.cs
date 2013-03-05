using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Constants;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract(Namespace = "MetraTech")]
    public class BusinessModelingEntity : MetraNetEntityBase
    {
         #region Properties
        //Need to add the incremental properties
        #endregion

        #region Constructor
        public BusinessModelingEntity(string name, string description) : base(name, PropertyBagConstants.ParameterTable, description)
        {
        }
        #endregion
    }
}
