using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class EntityTypeInfo : IExpressionEngineTreeNode
    {
        #region Properties
        public readonly ComplexType.ComplexTypeEnum Type;
        public string Name { get { return string.Format("{0}s", Type); } set { throw new Exception("Readonly!"); } }
        public string TreeNodeLabel { get { return Name; } }
        public string ToolTip { get { return "TBD"; } }
        public string Image { get { return string.Format("{0}.png", Type); } }
        public string NamePlural { get { return string.Format("{0}s", Type); } }
        #endregion 

        #region Constructor
        public EntityTypeInfo(ComplexType.ComplexTypeEnum type)
        {
            Type = type;
        }

        public string ToExpressionSnippet
        {
            get
            {
                throw new NotImplementedException();
            }
        }
        #endregion
    }
}
