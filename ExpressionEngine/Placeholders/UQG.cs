using System.Globalization;
using MetraTech.ExpressionEngine.Expressions;

namespace MetraTech.ExpressionEngine
{
    public class Uqg : IExpressionEngineTreeNode
    {
        #region Properties
        public string Name { get; set; }
        public string TreeNodeLabel { get { return Name; } }
        public string Description { get; set; }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "Uqg.png"; } }
        public string ToExpressionSnippet { get { return string.Format(CultureInfo.InvariantCulture, "GROUP.{0}", Name); } }
        public Expression Expression { get; set; }
        #endregion

        #region Constructor
        public Uqg(string name, string description, string expression)
        {
            Name = name;
            Description = description;
            Expression = new Expression(ExpressionType.Uqg, expression, null);
        }
        #endregion

    }
}
