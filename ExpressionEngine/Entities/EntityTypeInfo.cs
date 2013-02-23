using System;
using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.Entities
{
    public class EntityTypeInfo : IExpressionEngineTreeNode
    {
        #region

        private readonly ComplexType _type;
        public ComplexType Type { get { return _type; } }
        public string Name { get { return Type + "s"; } set { throw new Exception("Readonly!"); } }  //We will fix this in future!
        public string TreeNodeLabel { get { return Name; } }
        public string ToolTip { get { return "TBD"; } }
        public string Image { get { return Type + ".png"; } }
        public string NamePlural { get { return string.Format(CultureInfo.InvariantCulture, "{0}s", Type); } }
        #endregion 

        #region Constructor
        public EntityTypeInfo(ComplexType type)
        {
            _type = type;
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
