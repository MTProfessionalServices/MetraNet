using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace MetraTech.ExpressionEngine
{
    public interface IProperty : IExpressionEngineTreeNode
    {
        string Name { get; set; }
        bool IsCore { get; set; }
        DataTypeInfo DataTypeInfo { get; set; }
        ComplexType ParentEntity { get; }
        string Description { get; set; }
        Property.DirectionType Direction { get; set; }
        string CompatibleKey { get; }
        string ToExpressionSnippet { get; }   //This should be a Method (I had some Issue that I don't recall...
        object Clone();
        ValidationMessageCollection Validate(bool prefixMsg, ValidationMessageCollection messages);

        //Gui Properties that shold be moved
        string Image { get; }
        string ImageDirection { get; }
    }
}
