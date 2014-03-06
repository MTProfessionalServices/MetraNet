using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;

namespace MetraNet.Charts
{
  /// <summary>
  /// A dataset used by charts
  /// </summary>
  public class DataSet
  {
    /// <summary>
    /// Name of the series
    /// </summary>
    public string SeriesName { get; set; }
    /// <summary>
    /// Parent Y Axis
    /// </summary>
    public string ParentYAxis { get; set; }
    /// <summary>
    /// Color
    /// </summary>
    public string Color { get; set; }
    /// <summary>
    /// Show Values
    /// </summary>
    public bool? ShowValues { get; set; }
    /// <summary>
    /// Anchor Border Color
    /// </summary>
    public string AnchorBorderColor { get; set; }
    /// <summary>
    /// Values
    /// </summary>
    public IEnumerable<DataSetValue> Values { get; set; }
    /// <summary>
    /// Show Series in Legend
    /// </summary>
    public bool ShowSeriesInLegend { get; set; }
    /// <summary>
    /// Each column with different color
    /// </summary>
    public bool EachColumnWithDifferentColor { get; set; }
    /// <summary>
    /// Render as trendline
    /// </summary>
    public bool RenderAsTrendLine { get; set; }

    /// <summary>
    /// Default constructor
    /// </summary>
    public DataSet()
    {
      ShowSeriesInLegend = true;
    }

    /// <summary>
    /// Render data set
    /// </summary>
    /// <param name="rightToLeft">Indicates whether the language is left-to-right (e.g. English) or right-to-left (e.g. Arabic)</param>
    /// <returns>Xml to use for rendering</returns>
    public XElement Render(bool rightToLeft)
    {
      var root = new XElement(NodeAndAttributeName.DataSetNodeName, new XAttribute(NodeAndAttributeName.SeriesNameAttributeName, ChartBase.PrepareTextForFusionCharts(SeriesName, rightToLeft)));
      if(!string.IsNullOrEmpty(ParentYAxis))
        root.Add(new XAttribute(NodeAndAttributeName.ParentYAxisAttributeName, ParentYAxis));
      if (!string.IsNullOrEmpty(Color))
        root.Add(new XAttribute(NodeAndAttributeName.ColorAttributeName, Color));
      if (ShowValues != null)
        root.Add(new XAttribute(NodeAndAttributeName.ShowValuesAttributeName, (bool)ShowValues ? "1" : "0"));
      if (!string.IsNullOrEmpty(AnchorBorderColor))
        root.Add(new XAttribute(NodeAndAttributeName.AnchorBorderColorAttributeName, AnchorBorderColor));
      if (RenderAsTrendLine)
      {
        root.Add(new XAttribute(NodeAndAttributeName.RenderAsAttributeName, "Line"));
        root.Add(new XAttribute(NodeAndAttributeName.ParentYAxisAttributeName, "S"));
      }

      if (Values != null && Values.Any())
      {
        if (rightToLeft) Values = Values.Reverse();

        if (EachColumnWithDifferentColor)
        {
          var currentColor = 0;
          for (var currentValueIndex = 0; currentValueIndex < Values.Count(); currentValueIndex++)
          {
            Values.ElementAt(currentValueIndex).Color = NodeAndAttributeName.Colors.ElementAt(currentColor);
            root.Add(Values.ElementAt(currentValueIndex).Render(rightToLeft));

            currentColor++;
            if (currentColor > NodeAndAttributeName.Colors.Count)
              currentColor = 0;
          }
        }
        else
          Values.ToList().ForEach(x => root.Add(x.Render(rightToLeft)));
      }

      root.Add(new XAttribute(NodeAndAttributeName.IncludeInLegendAttributeName, ShowSeriesInLegend ? "1" : "0"));
      return root;
    }
  }
}
