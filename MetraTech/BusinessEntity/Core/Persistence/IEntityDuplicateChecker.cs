
using MetraTech.BusinessEntity.Core.Model;

namespace MetraTech.BusinessEntity.Core.Persistence
{
    public interface IEntityDuplicateChecker
    {
        bool DoesDuplicateExistWithTypedIdOf<IdT>(IDataObjectWithTypedId<IdT> entity);
    }
}
