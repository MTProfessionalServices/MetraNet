using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class EnumType : IExpressionEngineTreeNode
    {
        #region Properties
        public readonly EnumSpace Parent;
        public string Name { get; set; }
        public string Description { get; set; }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "EnumType.png"; } }
        public List<EnumValue> Values = new List<EnumValue>();
        #endregion

        #region Constructor
        public EnumType(EnumSpace parent, string name, string description)
        {
            Parent = parent;
            Name = name;
            Description = description;
        }
        #endregion

        #region Methods
        public EnumValue AddValue(string value)
        {
            var enumValue = new EnumValue(this, value);
            Values.Add(enumValue);
            return enumValue;
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
