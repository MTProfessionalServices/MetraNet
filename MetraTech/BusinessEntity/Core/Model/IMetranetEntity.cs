using System.Collections.Generic;
using MetraTech.BusinessEntity.Core.Config;

namespace MetraTech.BusinessEntity.Core.Model
{
  /// <summary>
  ///   Marker interface for MetraNet entities e.g. AccountDef.
  /// </summary>
  public interface IMetranetEntity
  {
    MetraNetEntityConfig MetraNetEntityConfig { get; set; }
    List<MetranetEntityProperty> Properties { get; } 
  }
}
