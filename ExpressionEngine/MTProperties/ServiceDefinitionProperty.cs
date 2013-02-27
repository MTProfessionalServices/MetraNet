using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.MTProperties
{
    [DataContract (Namespace = "MetraTech")]
    public class ServiceDefinitionProperty : Property
    {
        #region Constructor
        public ServiceDefinitionProperty(string name, Type type, bool isRequired, string description): base(name, type, isRequired, description)
        {    
        }
        #endregion
    }
}
