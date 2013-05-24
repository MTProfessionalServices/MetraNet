using System.Collections.Generic;
using System.Reflection;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
    /// <summary>
    /// This serves as a base interface for <see cref="DataObjectWithTypedId"/> and 
    /// <see cref="DataObject"/>. Also provides a simple means to develop your own base DataObject.
    /// </summary>
    public interface IDataObjectWithTypedId<IdT>
    {
        IdT Id { get; }
        bool IsTransient();
        Dictionary<string, IEnumerable<PropertyInfo>> GetBusinessKeyProperties();
    }
}
