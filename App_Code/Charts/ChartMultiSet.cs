using System.Collections.Generic;
using System.Linq;

namespace MetraNet.Charts
{
  /// <summary>
  /// 
  /// </summary>
  public abstract class ChartMSet : ChartBase
  {
    /// <summary>
    /// 
    /// </summary>
    public IEnumerable<DataSet> DataSets { get; set; }

    /// <summary>
    /// 
    /// </summary>
    public override void Render()
    {
      if(DataSets != null && DataSets.Any())
        DataSets.ToList().ForEach(x=>Data.Add(x.Render(RightToLeft)));
      base.Render();
    }
  }
}
