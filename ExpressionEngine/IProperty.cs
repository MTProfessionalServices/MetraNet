using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public interface IProperty : IExpressionEngineTreeNode
    {
        string Name { get; set; }
        DataTypeInfo DataTypeInfo { get; set; }
        Entity ParentEntity { get; }
        string Description { get; set; }
        Property.DirectionType Direction { get; set; }
        string Image { get; }
        string ImageDirection { get; }
        string GetCompatableKey();
        string ToExpression { get; }
        ValidationMessageCollection Validate(bool prefixMsg, ValidationMessageCollection messages = null);
    }
}
