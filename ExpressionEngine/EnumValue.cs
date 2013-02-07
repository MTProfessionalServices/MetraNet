using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class EnumValue : IExpressionEngineTreeNode
    {
        #region Properties
        public readonly EnumType Parent;
        public string Name { get; set; }
        public int Id { get; set; }
        public string Description { get; set; }
        public string ToolTip { get { return string.Format("{0}[DatabaseID={1}]", Description, Id); } }
        public string Image { get { return "EnumValue.png"; } }
        #endregion

        #region Constructor
        public EnumValue(EnumType parent, string value, int id)
        {
            Parent = parent;
            Name = value;
            Id = id;
        }
        #endregion

        #region Methods
        public string ToMtsql()
        {
            return string.Format("#{0}/{1}/{2}#", Parent.Parent.Name, Parent.Name, Name);
        }
        public string ToExpression
        {
            get
            {
                if (Settings.NewSyntax)
                {
                    var enumSpace = Parent.Parent.Name.Replace('.', '_');
                    return string.Format("ENUM.{0}.{1}.{2}", enumSpace, Parent.Name, Name);
                }
                else
                    return ToMtsql();
            }
        }

        #endregion
    }

}
