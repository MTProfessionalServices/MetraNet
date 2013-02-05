using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class EntityInfo
    {
        #region Properties 
        public static readonly Dictionary<Entity.EntityTypeEnum, EntityInfo> Items = new Dictionary<Entity.EntityTypeEnum, EntityInfo>();
        #endregion
    }
}
