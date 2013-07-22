using System;
using System.Xml.Linq;
using System.Xml.Serialization;

namespace MetraTech.Domain.Expressions
{
  ///<summary>
  /// Class for serialize and desirialize of expressions
  ///</summary>
  public static class ExpressionSerializer
  {
    private static readonly XmlSerializer XmlSerializer = 
      new XmlSerializer(typeof(BinaryExpression), new[] { typeof(PropertyExpression), typeof(ConstantExpression) });

    ///<summary>
    /// Serialize
    ///</summary>
    ///<param name="binaryExpression"></param>
    ///<returns></returns>
    public static XElement Serialize(BinaryExpression binaryExpression)
    {
      if (binaryExpression == null) throw new ArgumentNullException("binaryExpression");

      var xDocument = new XDocument();
      using (var xmlWriter = xDocument.CreateWriter())
      {
        var xmlSerializerNamespaces = new XmlSerializerNamespaces();
        xmlSerializerNamespaces.Add("xsi", "http://www.w3.org/2001/XMLSchema-instance");
        xmlSerializerNamespaces.Add("xsd", "http://www.w3.org/2001/XMLSchema");
        XmlSerializer.Serialize(xmlWriter, binaryExpression, xmlSerializerNamespaces);
      }
      return xDocument.Root;
    }

    ///<summary>
    /// Deserialize
    ///</summary>
    ///<param name="serializedExpression"></param>
    ///<returns></returns>
    public static BinaryExpression Deserialize(XNode serializedExpression)
    {
      if (serializedExpression == null) throw new ArgumentNullException("serializedExpression");
      using (var xmlReader = serializedExpression.CreateReader())
      {
        return (BinaryExpression)XmlSerializer.Deserialize(xmlReader);
      }
    }
  }
}
