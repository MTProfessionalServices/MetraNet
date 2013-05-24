using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Rule;
using NHibernate;
using NHibernate.Event;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Events
{
  public class PreDeleteEventListener : BaseEventListener, IPreDeleteEventListener
  {
    #region IPreDeleteEventListener Members

    /// <summary>
    ///   Return true if the operation should be vetoed
    /// </summary>
    /// <param name="@event"></param>
    public bool OnPreDelete(PreDeleteEvent @event)
    {
      var dataObject = @event.Entity as DataObject;
      if (dataObject == null)
      {
        return false;
      }

      if (RuleConfig.HasRules(dataObject.GetType().FullName, CRUDEvent.BeforeDelete))
      {
        FireBusinessRules(dataObject, @event.Session.GetSession(EntityMode.Poco), CRUDEvent.BeforeDelete);
      }

      return false;
    }

    #endregion
  }
}
