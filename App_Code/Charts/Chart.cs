using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;

namespace MetraNet.Charts
{
  /// <summary>
  /// Base class used for charts
  /// </summary>
  public abstract class ChartBase
  {
    private XElement _data = new XElement(NodeAndAttributeName.ChartNodeName);
    /// <summary>
    /// Data
    /// </summary>
    protected XElement Data { get { return _data; } set { _data = value; } }
    /// <summary>
    /// Caption
    /// </summary>
    public string Caption { get; set; }
    /// <summary>
    /// SubCaption
    /// </summary>
    public string SubCaption { get; set; }

    private bool _addToCategoriesTag = true;
    /// <summary>
    /// Add to Categories Tag
    /// </summary>
    public bool AddToCategoriesTag { get { return _addToCategoriesTag; } set { _addToCategoriesTag = value; } }

    /// <summary>
    /// Categories
    /// </summary>
    public IEnumerable<Category> Categories { get; set; }
    /// <summary>
    /// Styles
    /// </summary>
    public Styles Styles { get; set; }
    /// <summary>
    /// Legend Position Right
    /// </summary>
    public bool LegendPositionRight { get; set; }
    /// <summary>
    /// X Axis Name
    /// </summary>
    public string XAxisName { get; set; }
    /// <summary>
    /// Y Axis Name
    /// </summary>
    public string YAxisName { get; set; }
    /// <summary>
    /// Right To Left
    /// </summary>
    public bool RightToLeft { get; set; }

    /// <summary>
    /// Render chart
    /// </summary>
    public virtual void Render()
    {
      if (!string.IsNullOrEmpty(XAxisName))
        Data.Add(new XAttribute(NodeAndAttributeName.XAxisNameAttributeName, PrepareTextForFusionCharts(XAxisName, RightToLeft)));
      if (!string.IsNullOrEmpty(YAxisName))
        Data.Add(new XAttribute(NodeAndAttributeName.YAxisNameAttributeName, PrepareTextForFusionCharts(YAxisName, RightToLeft)));

      Data.Add(new XAttribute(NodeAndAttributeName.LegendPositionAttributeName,
                              LegendPositionRight
                                ? NodeAndAttributeName.LegendPositionRightAttributeValue
                                : NodeAndAttributeName.LegendPositionBottomAttributeValue));


      if (!string.IsNullOrEmpty(Caption))
        Data.Add(new XAttribute(NodeAndAttributeName.CaptionAttributeName, PrepareTextForFusionCharts(Caption, RightToLeft)));
      if (!string.IsNullOrEmpty(SubCaption))
        Data.Add(new XAttribute(NodeAndAttributeName.SubCaptionAttributeName, PrepareTextForFusionCharts(SubCaption, RightToLeft)));

      if (Styles != null)
        Data.Add(Styles.Render());

      if (Categories == null || !Categories.Any()) return;
      var parentTag = _addToCategoriesTag ? new XElement(NodeAndAttributeName.CategoriesNodeName) : Data;
      (RightToLeft ? Categories.Reverse() : Categories).ToList().ForEach(x => parentTag.Add(x.Render(RightToLeft)));
      if (_addToCategoriesTag) Data.Add(parentTag);
    }

    /// <summary>
    /// Prepare Text For Fusion Charts
    /// </summary>
    /// <param name="sourceText">source text</param>
    /// <param name="rightToLeft">is text right to left</param>
    /// <returns></returns>
    public static string PrepareTextForFusionCharts(string sourceText, bool rightToLeft)
    {
      if (!rightToLeft || string.IsNullOrEmpty(sourceText))
        return sourceText;

      var newString = new System.Text.StringBuilder();
      var stringArray = sourceText.Split(' ');

      if (stringArray.Length <= 1)
        return sourceText;

      foreach (var s in stringArray.Reverse())
      {
        newString.Append(s + " ");
      }
      var resultString = newString.ToString();
      return resultString.Substring(0, resultString.Length - 1);
    }

  }
}
