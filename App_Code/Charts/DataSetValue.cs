using System.Xml.Linq;

namespace MetraNet.Charts
{
  /// <summary>
  /// 
  /// </summary>
  public class DataSetValue
  {
    /// <summary>
    /// 
    /// </summary>
    public string Value { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string DisplayValue { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string ToolText { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string Link { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string Color { get; set; }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="rightToLeft"></param>
    /// <returns></returns>
    public XElement Render(bool rightToLeft)
    {
      var root = new XElement(NodeAndAttributeName.SetNodeName, new XAttribute(NodeAndAttributeName.ValueAttributeName, Value));
      if (!string.IsNullOrEmpty(Link))
        root.Add(new XAttribute(NodeAndAttributeName.LinkAttributeName, Link));
      if (!string.IsNullOrEmpty(DisplayValue))
        root.Add(new XAttribute(NodeAndAttributeName.DisplayValueAttributeName,
                                ChartBase.PrepareTextForFusionCharts(DisplayValue, rightToLeft)));
      if (!string.IsNullOrEmpty(Color))
        root.Add(new XAttribute(NodeAndAttributeName.ColorAttributeName, Color));
      if (!string.IsNullOrEmpty(ToolText))
        root.Add(new XAttribute(NodeAndAttributeName.ToolTextAttributeName,
                                ChartBase.PrepareTextForFusionCharts(ToolText, rightToLeft)));
      return root;
    }
  }
}
