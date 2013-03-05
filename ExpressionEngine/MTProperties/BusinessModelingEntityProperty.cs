using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.MTProperties
{
    [DataContract(Namespace = "MetraTech")]
    public class BusinessModelingEntityProperty : MetraNetPropertyBase
    {
        #region Properties
        #endregion

        #region Constructor
        public BusinessModelingEntityProperty(string name, Type type, bool isRequired, string description) : base(name, type, isRequired, description)
        {    
        }
        #endregion
    }
}
