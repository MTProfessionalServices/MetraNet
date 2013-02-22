using MetraTech.ExpressionEngine.MtProperty.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// I'm wondering is we should use a base class instead???
    /// </summary>
    public interface IProperty : IExpressionEngineTreeNode
    {
        string Name { get; set; }
        bool IsCore { get; set; }
        MtType Type { get; set; }
        Entity ParentEntity { get; }
        string Description { get; set; }
        DirectionType Direction { get; set; }
        string CompatibleKey { get; }
        string Value { get; set; }
        string ToExpressionSnippet { get; }   //This should be a Method (I had some Issue that I don't recall...
        object Clone();
        ValidationMessageCollection Validate(bool prefixMsg, ValidationMessageCollection messages);

        //Gui Properties that shold be moved
        string Image { get; }
        string ImageDirection { get; }
    }
}
