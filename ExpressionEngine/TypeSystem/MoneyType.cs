using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract]
    public class MoneyType : MtType
    {
        #region Properties
        [DataMember]
        public string UnitsProperty { get; set; }
        #endregion
      
        #region Constructor
        public MoneyType():base(BaseType.Money)
        {
        }
        #endregion

        #region Methods

        public MoneyType Copy()
        {
            var type = (MoneyType)base.Copy();
            InternalCopy(type);
            type.UnitsProperty = UnitsProperty;
            return type;
        }
        #endregion
    }
}
