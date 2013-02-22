using System;
using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine
{
    public class EntityTypeInfo : IExpressionEngineTreeNode
    {
        #region Properties
        public readonly ComplexType Type;
        public string Name { get { return string.Format("{0}s", Type); } set { throw new Exception("Readonly!"); } }  //We will fix this in future!
        public string TreeNodeLabel { get { return Name; } }
        public string ToolTip { get { return "TBD"; } }
        public string Image { get { return string.Format("{0}.png", Type); } }
        public string NamePlural { get { return string.Format(CultureInfo.InvariantCulture, "{0}s", Type); } }
        #endregion 

        #region Constructor
        public EntityTypeInfo(ComplexType type)
        {
            Type = type;
        }

        public string ToExpressionSnippet
        {
            get
            {
                return Name;
            }
        }
        #endregion
    }
}
