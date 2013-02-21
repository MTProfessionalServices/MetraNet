using System;
using System.Collections.Generic;
using System.Text;
using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine
{
    public class EntityTypeInfo : IExpressionEngineTreeNode
    {
        #region Properties
        public readonly VectorType.ComplexTypeEnum Type;
        public string Name { get { return string.Format("{0}s", Type); } set { throw new Exception("Readonly!"); } }
        public string TreeNodeLabel { get { return Name; } }
        public string ToolTip { get { return "TBD"; } }
        public string Image { get { return string.Format("{0}.png", Type); } }
        public string NamePlural { get { return string.Format(CultureInfo.InvariantCulture, "{0}s", Type); } }
        #endregion 

        #region Constructor
        public EntityTypeInfo(VectorType.ComplexTypeEnum type)
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
