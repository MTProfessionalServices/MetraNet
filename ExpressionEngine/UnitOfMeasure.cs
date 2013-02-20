using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;

namespace MetraTech.ExpressionEngine
{
    public class UnitOfMeasure : IExpressionEngineTreeNode
    {
        #region Properties
        public UnitOfMeasureCategory Category { get; private set; }
        public string Name { get; set; }
        public string TreeNodeLabel { get { return Name; } }
        public string PrintSymbol { get; private set; }
        public bool IsMetric { get; private set; }
        public string Image { get { return "Uom.png"; } }
        public string ToolTip { get { return null; } }
        public string ToExpressionSnippet { get { return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", Category.ToExpressionSnippet, Name); } }
        #endregion

        #region Constructor
        public UnitOfMeasure(UnitOfMeasureCategory category, string name, bool isMetric)
        {
            Category = category;
            Name = name;
            IsMetric = isMetric;
        }
        #endregion

    }
}
