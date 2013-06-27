using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract(Namespace = "MetraTech")]
    public class ParameterTableEntity : PropertyBag
    {
        #region Properties

        /// <summary>
        /// Documentation purposes only at this point
        /// </summary>
        [DataMember]
        public string Category { get; set; }

        [DataMember]
        public System.Uri HelpUrl{ get; set; }

        [DataMember]
        public string ConditionsCaption{ get; set; }

        [DataMember]
        public string ActionsCaption { get; set; }
        #endregion

        #region Constructor
        public ParameterTableEntity(string _namespace, string name, string description)
            : base(_namespace, name, PropertyBagConstants.ParameterTable, PropertyBagMode.ExtensibleEntity, description)
        {
        }
        #endregion
    }
}
