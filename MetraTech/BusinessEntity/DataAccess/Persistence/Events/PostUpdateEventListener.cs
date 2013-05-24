using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Rule;
using NHibernate;
using NHibernate.Event;


namespace MetraTech.BusinessEntity.DataAccess.Persistence.Events
{
  public class PostUpdateEventListener : BaseEventListener, IPostUpdateEventListener
  {
    #region IPostUpdateEventListener Members

    public void OnPostUpdate(PostUpdateEvent @event)
    {
      var dataObject = @event.Entity as DataObject;
      if (dataObject == null)
      {
        return;
      }

      ProcessComputedProperties(dataObject, @event.Session.GetSession(EntityMode.Poco));

      if (RuleConfig.HasRules(dataObject.GetType().FullName, CRUDEvent.AfterUpdate))
      {
        FireBusinessRules(dataObject, @event.Session.GetSession(EntityMode.Poco), CRUDEvent.AfterUpdate);
      }
    }

    #endregion
  }
}
