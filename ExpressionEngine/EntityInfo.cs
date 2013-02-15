using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class EntityInfo
    {
        #region Properties 
        public static readonly Dictionary<ComplexType.ComplexTypeEnum, EntityInfo> Items = new Dictionary<ComplexType.ComplexTypeEnum, EntityInfo>();
        #endregion
    }
}
