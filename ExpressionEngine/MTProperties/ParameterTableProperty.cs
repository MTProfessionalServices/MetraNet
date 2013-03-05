using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.MTProperties
{
    [DataContract (Namespace = "MetraTech")]
    public class ParameterTableProperty : MetraNetPropertyBase
    {
        #region Properties

        [DataMember]
        public ParameterTablePropertyContext ParameterTablePropertyContext { get; set; }

        [DataMember]
        public bool IsFilterable { get; set; }

        [DataMember]
        public OperatorScope OperatorScope { get; set; }

        [DataMember]
        public string Operator { get; set; }
        #endregion

        #region Constructor
        public ParameterTableProperty(string name, Type type, bool isRequired, string description) : base(name, type, isRequired, description)
        {    
        }
        #endregion

    }
}
