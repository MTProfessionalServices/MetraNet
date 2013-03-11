namespace MetraTech.ExpressionEngine.Placeholders
{
    public class PageLayout : IExpressionEngineTreeNode
    {
        #region Properties
        public string Name { get; set; }
        public string FullName { get { return Name; } }
        public string TreeNodeLabel { get { return Name; } }
        public string Description { get; set; }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "PageLayout.png"; } }
        public string ToExpressionSnippet { get { return Name; } }
        #endregion

        #region Constructor
        public PageLayout(string name, string description)
        {
            Name = name;
            Description = description;
        }
        #endregion
    }
}
