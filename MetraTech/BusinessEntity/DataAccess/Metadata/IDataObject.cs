
using System;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  public interface IDataObject
  {
    Guid Id { get; set; }
    int _Version { get; set; }
    DateTime? CreationDate { get; set; }
    DateTime? UpdateDate { get; set; }
  }
}
