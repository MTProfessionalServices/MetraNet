using System.Globalization;

namespace MetraTech.ExpressionEngine.Components
{
    public class UnitOfMeasure : IExpressionEngineTreeNode
    {
        #region Properties
        public UnitOfMeasureCategory Category { get; private set; }
        public string Name { get; set; }
        public string PrintSymbol { get; private set; }
        public bool IsMetric { get; private set; }
        public string ToExpressionSnippet { get { return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", Category.ToExpressionSnippet, Name); } }
        #endregion

        #region GUI Support Properties (should be moved in future)
        public string TreeNodeLabel { get { return Name; } }
        public string Image { get { return "Uom.png"; } }
        public string ToolTip { get { return null; } }
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
