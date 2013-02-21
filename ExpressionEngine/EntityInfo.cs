using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine
{
    public class EntityInfo
    {
        #region Properties 
        public static readonly Dictionary<VectorType.ComplexTypeEnum, EntityInfo> Items = new Dictionary<VectorType.ComplexTypeEnum, EntityInfo>();
        #endregion
    }
}
