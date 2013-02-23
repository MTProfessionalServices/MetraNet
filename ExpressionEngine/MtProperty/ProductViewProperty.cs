using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.MetraNet.MtProperty
{
    [DataContract]
    public class ProductViewProperty : Property
    {
        #region Properties
        [DataMember]
        public bool UserVisible { get; set; }

        [DataMember]
        public bool IsExportable { get; set; }

        [DataMember]
        public bool IsFilterable { get; set; }
        #endregion

        #region Constructor
        public ProductViewProperty(string name, MtType type, string description): base(name, type, description)
        {    
        }
        #endregion
    }
}
