using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;

namespace MetraTech.ExpressionEngine.MetraNet.MtProperty
{
    [DataContract]
    public class ProductViewProperty
    {
        #region Properties
        [DataMember]
        public bool UserVisible { get; set; }
        [DataMember]
        public bool IsExportable { get; set; }
        [DataMember]
        public bool IsFilterable { get; set; }
        #endregion
    }
}
