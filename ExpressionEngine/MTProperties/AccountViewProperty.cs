using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.MTProperties
{
    [DataContract (Namespace = "MetraTech")]
    public class AccountViewProperty : MetraNetPropertyBase
    {
        #region Properties

        [DataMember]
        public bool PartOfPrimaryKey { get; set; }

        [DataMember]
        public string ForeignKeyDBTable { get; set; }

        [DataMember]
        public string ForeignKeyTableColumn { get; set; }

        public bool HasSingleIndex { get; set; }

        public bool HasCompositeIndex { get; set; }

        #endregion

        #region Constructor
        public AccountViewProperty(string name, Type type, bool isRequired, string description): base(name, type, isRequired, description)
        {    
        }
        #endregion
    }
}
