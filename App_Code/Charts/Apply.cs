using System.Xml.Linq;

namespace MetraNet.Charts
{
  /// <summary>
  /// 
  /// </summary>
  public class Apply
  {
    /// <summary>
    /// 
    /// </summary>
    public string ToObject { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string Styles { get; set; }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public XElement Render()
    {
      return new XElement(NodeAndAttributeName.ApplyNodeName, new XAttribute(NodeAndAttributeName.ToObjectAttributeName, ToObject),
                          new XAttribute(NodeAndAttributeName.StylesAttributeName, Styles));
    }
  }
}
