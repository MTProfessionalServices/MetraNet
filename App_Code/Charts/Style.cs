using System.Xml.Linq;

namespace MetraNet.Charts
{
  /// <summary>
  /// 
  /// </summary>
  public class Style
  {
    /// <summary>
    /// 
    /// </summary>
    public string Name { get; set; }
    /// <summary>
    /// get prorerty from TypeStyle class to use
    /// </summary>
    public string Typestyle { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public bool? IsHtml { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public int? Distance { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public Font? Font { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public int? Size { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public bool? Bold { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string Color { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string Align { get; set; }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public XElement Render()
    {
      var root = new XElement(NodeAndAttributeName.StyleNodeName, new XAttribute(NodeAndAttributeName.NameAttributeName, Name), new XAttribute(NodeAndAttributeName.TypeAttributeName, Typestyle));
      if(IsHtml != null)
        root.Add(new XAttribute(NodeAndAttributeName.IsHtmlAttributeName, (bool)IsHtml ? "1" : "0"));
      if(Distance != null)
        root.Add(new XAttribute(NodeAndAttributeName.DistanceAttributeName, Distance));
      if(Font != null)
        root.Add(new XAttribute(NodeAndAttributeName.FontAttributeName, Font.ToString()));
      if(Size != null)
        root.Add(new XAttribute(NodeAndAttributeName.SizeAttributeName, Size));
      if (Bold != null)
        root.Add(new XAttribute(NodeAndAttributeName.BoldAttributeName, (bool)Bold ? "1" : "0"));
      if (!string.IsNullOrEmpty(Color))
        root.Add(new XAttribute(NodeAndAttributeName.ColorAttributeName, Color));
      if (!string.IsNullOrEmpty(Align))
        root.Add(new XAttribute(NodeAndAttributeName.AlignAttributeName, Align));
      return root;
    }
  }
}
