using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;

namespace MetraTech.ExpressionEngine.MetraNet.MtProperty
{
    [DataContract]
    public class AccountViewProperty
    {
        #region Properties

        [DataMember]
        public bool PartOfPrimaryKey { get; set; }

        [DataMember]
        public string ForeignKeyDbTable { get; set; }

        [DataMember]
        public string ForeignKeyTableColumn;

        public bool HasSingleIndex { get; set; }

        public bool HasCompositeIndex { get; set; }

        #endregion
        }
}
