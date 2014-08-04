using System.Xml.Linq;

namespace MetraNet.Charts
{
  /// <summary>
  /// Series Column 3D Chart
  /// </summary>
  public class MSeriesColumn3DChart : ChartMSet
  {
    /// <summary>
    /// Show labels
    /// </summary>
    public bool ShowLabels { get; set; }
    /// <summary>
    /// Show Values
    /// </summary>
    public bool ShowValues { get; set; }
    /// <summary>
    /// Decimals
    /// </summary>
    public int Decimals { get; set; }
    /// <summary>
    /// Zero Plane Alpha
    /// </summary>
    public int ZeroPlaneAlpha { get; set; }
    /// <summary>
    /// Number Prefix
    /// </summary>
    public string NumberPrefix { get; set; }
    /// <summary>
    /// Show Sum
    /// </summary>
    public bool ShowSum { get; set; }

    /// <summary>
    /// Series Column 3D Chart
    /// </summary>
    public MSeriesColumn3DChart()
    {
      ShowLabels = true;
      ShowValues = true;
      Decimals = 2;
      NumberPrefix = "$";
      ShowSum = true;
      ZeroPlaneAlpha = 95;
    }

    /// <summary>
    /// Render chart
    /// </summary>
    /// <returns>Xml used for rendering</returns>
    public new XElement Render()
    {
      Data.Add(new XAttribute(NodeAndAttributeName.ShowLabelsAttributeName, ShowLabels ? "1" : "0"));
      Data.Add(new XAttribute(NodeAndAttributeName.ZeroPlaneAlphaAttributeName, ZeroPlaneAlpha));
      Data.Add(new XAttribute(NodeAndAttributeName.ShowValuesAttributeName, ShowValues ? "1" : "0"));
      Data.Add(new XAttribute(NodeAndAttributeName.DecimalsAttributeName, Decimals));
      Data.Add(new XAttribute(NodeAndAttributeName.NumberPrefixNAttributeName, NumberPrefix));
      Data.Add(new XAttribute(NodeAndAttributeName.ShowSumAttributeName, ShowSum ? "1" : "0"));
      base.Render();
      return Data;
    }
  }
}
