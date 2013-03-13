namespace MetraTech.ExpressionEngine
{
    public interface IExpressionEngineTreeNode
    {
        string Name { get; set; }
        string FullName { get; }
        string ToolTip { get; }
        string Image { get; }
        string ToExpressionSnippet { get; }
    }
}
