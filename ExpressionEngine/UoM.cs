using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class Uom : IExpressionEngineTreeNode
    {
        #region Properties
        public readonly UoMCategory Category;
        public string Name { get; set; }
        public readonly string PrintSymbol;
        public readonly bool IsMetric;
        public string Image { get { return "Uom.png"; } }
        public string ToolTip { get { return null; } }
        public string ToExpression { get { return string.Format("{0}.{1}", Category.ToExpression, Name); } }
        #endregion

        #region Constructor
        public Uom(UoMCategory category, string name, bool isMetric=false)
        {
            Category = category;
            Name = name;
            IsMetric = isMetric;
        }
        #endregion

    }
}
