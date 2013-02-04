using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class EntityTypeInfo : IExpressionEngineTreeNode
    {
        #region Properties
        public readonly Entity.EntityTypeEnum Type;
        public string Name { get { return string.Format("{0}s", Type); } set { throw new Exception("Readonly!"); } }
        public string ToolTip { get { return "TBD"; } }
        public string Image { get { return string.Format("{0}.png", Type); } }
        public string NamePlural { get { return string.Format("{0}s", Type); } }
        #endregion 

        #region Constructor
        public EntityTypeInfo(Entity.EntityTypeEnum type)
        {
            Type = type;
        }

        public string ToExpression
        {
            get
            {
                throw new NotImplementedException();
            }
        }
        #endregion
    }
}
