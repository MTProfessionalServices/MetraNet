using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Rule;
using NHibernate;
using NHibernate.Event;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Events
{
  public class PostDeleteEventListener : BaseEventListener, IPostDeleteEventListener
  {
    #region IPostDeleteEventListener Members

    /// <summary>
    /// </summary>
    /// <param name="@event"></param>
    public void OnPostDelete(PostDeleteEvent @event)
    {
      var dataObject = @event.Entity as DataObject;
      if (dataObject == null)
      {
        return;
      }

      if (RuleConfig.HasRules(dataObject.GetType().FullName, CRUDEvent.AfterDelete))
      {
        FireBusinessRules(dataObject, @event.Session.GetSession(EntityMode.Poco), CRUDEvent.AfterDelete);
      }
    }

    #endregion
  }
}
