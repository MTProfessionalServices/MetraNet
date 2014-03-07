using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;

namespace MetraNet.Charts
{
  /// <summary>
  /// 
  /// </summary>
  public class Category
  {
    /// <summary>
    /// 
    /// </summary>
    public string Value { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string Label { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string ToolText { get; set; }
    private IEnumerable<Category> _categories;
    /// <summary>
    /// 
    /// </summary>
    public IEnumerable<Category> Categories {get { return _categories; } set { _categories = value; }}

    /// <summary>
    /// 
    /// </summary>
    /// <param name="rightToLeft"></param>
    /// <returns></returns>
    public XElement Render(bool rightToLeft)
    {
      var root = new XElement(NodeAndAttributeName.CategoryNodeName);
      if(!string.IsNullOrEmpty(Value))
        root.Add(new XAttribute(NodeAndAttributeName.ValueAttributeName, Value));
      if(!string.IsNullOrEmpty(Label))
        root.Add(new XAttribute(NodeAndAttributeName.LabelAttributeName, ChartBase.PrepareTextForFusionCharts(Label, rightToLeft)));
      if(!string.IsNullOrEmpty(ToolText))
        root.Add(new XAttribute(NodeAndAttributeName.ToolTextAttributeName, ChartBase.PrepareTextForFusionCharts(ToolText,rightToLeft)));
      if (Categories != null && Categories.Any())
        (rightToLeft ? Categories.Reverse() : Categories).ToList().ForEach(x => root.Add(x.Render(rightToLeft)));
      return root;
    }
  }
}
