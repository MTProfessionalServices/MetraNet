using System.Collections.Generic;

namespace MetraTech.BusinessEntity.Core.Model
{
  public interface IEnumType
  {
    string Name { get; }

    string Namespace { get; }

    string Label { get; }

    IList<IEnumEntry> Entries { get; }
  }
}
