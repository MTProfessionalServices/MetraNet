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
        DataTypeInfo DataTypeInfo { get; set; }
        ComplexType ParentEntity { get; }
        string Description { get; set; }
        Property.DirectionType Direction { get; set; }
        string Image { get; }
        string ImageDirection { get; }
        string GetCompatableKey();
        string ToExpressionSnippet { get; }
        object Clone();
        ValidationMessageCollection Validate(bool prefixMsg, ValidationMessageCollection messages = null);
        //void WriteXmlNode(XmlNode parentNode, string propertyNodeName);
    }
}
