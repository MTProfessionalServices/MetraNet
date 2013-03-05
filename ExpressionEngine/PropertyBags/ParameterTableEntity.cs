using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Constants;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract(Namespace = "MetraTech")]
    public class ParameterTableEntity : MetraNetEntityBase
    {
        #region Properties

        /// <summary>
        /// Documentation purposes only at this point
        /// </summary>
        [DataMember]
        public string Category { get; set; }

        [DataMember]
        public string HelpUrl{ get; set; }

        [DataMember]
        public string ConditionsCaption{ get; set; }

        [DataMember]
        public string ActionsCaption { get; set; }
        #endregion

        #region Constructor
        public ParameterTableEntity(string name, string description) : base(name, PropertyBagConstants.ParameterTable, description)
        {
        }
        #endregion
    }
}
