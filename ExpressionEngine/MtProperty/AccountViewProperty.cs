using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.MtProperty
{
    [DataContract]
    public class AccountViewProperty : Property
    {
        #region Properties

        [DataMember]
        public bool PartOfPrimaryKey { get; set; }

        [DataMember]
        public string ForeignKeyDbTable { get; set; }

        [DataMember]
        public string ForeignKeyTableColumn { get; set; }

        public bool HasSingleIndex { get; set; }

        public bool HasCompositeIndex { get; set; }

        #endregion

        #region Constructor
        public AccountViewProperty(string name, MtType type, string description): base(name, type, description)
        {    
        }
        #endregion
    }
}
