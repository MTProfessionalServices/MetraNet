using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.Entities;

namespace MetraTech.ExpressionEngine.MTProperty
{
    /// <summary>
    /// I'm wondering is we should use a base class instead???
    /// </summary>
    public interface IProperty : IExpressionEngineTreeNode
    {
        string Name { get; set; }
        bool IsCore { get; set; }
        Type Type { get; set; }
        PropertyBag ParentEntity { get; }
        string Description { get; set; }
        Direction Direction { get; set; }
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
