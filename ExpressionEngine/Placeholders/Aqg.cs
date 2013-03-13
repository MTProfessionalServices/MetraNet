using System.Globalization;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;

namespace MetraTech.ExpressionEngine.Placeholders
{
    public class Aqg : IExpressionEngineTreeNode
    {
        #region Properties
        public string Name { get; set; }
        public string FullName { get { return Name; } }
        public string Description { get; set; }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "Aqg.png"; } }
        public string ToExpressionSnippet { get { return string.Format(CultureInfo.InvariantCulture, "GROUP.{0}", Name); } }
        public Expression Expression { get; set; }
        #endregion
     
        #region Constructor
        public Aqg(string name, string description, string expression)
        {
            Name = name;
            Description = description;
            Expression = new Expression(ExpressionType.Aqg, expression, null);
        }
        #endregion
    }
}
