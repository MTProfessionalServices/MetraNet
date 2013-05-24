using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Rule;
using NHibernate;
using NHibernate.Event;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Events
{
  public class PostInsertEventListener : BaseEventListener, IPostInsertEventListener
  {
    #region IPostInsertEventListener Members

    public void OnPostInsert(PostInsertEvent @event)
    {
      var dataObject = @event.Entity as DataObject;
      if (dataObject == null)
      {
        return;
      }

      ISession session = @event.Session.GetSession(EntityMode.Poco);
      
      ProcessComputedProperties(dataObject, session);

      if (RuleConfig.HasRules(dataObject.GetType().FullName, CRUDEvent.AfterCreate))
      {
        FireBusinessRules(dataObject, session, CRUDEvent.AfterCreate);
      }

    }

    #endregion
  }
}
