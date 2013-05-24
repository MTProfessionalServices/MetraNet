using QuickGraph;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  public class DependencyData 
  {
    public string SourceEntityExtensionName { get; set; }
    public string SourceEntityGroupName { get; set; }
    public string TargetEntityExtensionName { get; set; }
    public string TargetEntityGroupName { get; set; }
  }
}
