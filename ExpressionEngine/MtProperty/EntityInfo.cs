using System.Collections.Generic;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine
{
    public class EntityInfo
    {
        #region Properties 
        public static readonly Dictionary<ComplexType, EntityInfo> Items = new Dictionary<ComplexType, EntityInfo>();
        #endregion

        #region Constructor
        public EntityInfo()
        {
        }
        #endregion
    }
}
