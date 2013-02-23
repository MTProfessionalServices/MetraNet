using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.MetraNet.MtProperty
{
    [DataContract]
    public class ServiceDefinitionProperty : Property
    {
        #region Constructor
        public ServiceDefinitionProperty(string name, MtType type, string description): base(name, type, description)
        {    
        }
        #endregion
    }
}
