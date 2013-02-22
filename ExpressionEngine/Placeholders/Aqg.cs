namespace MetraTech.ExpressionEngine
{
    public class Aqg : IExpressionEngineTreeNode
    {
        #region Properties
        public string Name { get; set; }
        public string TreeNodeLabel { get { return Name; } }
        public string Description { get; set; }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "Aqg.png"; } }
        public string ToExpressionSnippet { get { return string.Format("GROUP.{0}", Name); } }
        public Expression Expression { get; set; }
        #endregion
     
        #region Constructor
        public Aqg(string name, string description, string expression)
        {
            Name = name;
            Description = description;
            Expression = new Expression(ExpressionTypeEnum.AQG, expression, null);
        }
        #endregion
    }
}
