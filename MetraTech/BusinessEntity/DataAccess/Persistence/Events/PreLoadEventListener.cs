using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Rule;
using NHibernate;
using NHibernate.Event;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Events
{
  public class PreLoadEventListener : BaseEventListener, IPreLoadEventListener
  {
    #region IPreLoadEventListener Members

    public void OnPreLoad(PreLoadEvent @event)
    {
      var dataObject = @event.Entity as DataObject;
      if (dataObject == null)
      {
        return;
      }

      if (RuleConfig.HasRules(dataObject.GetType().FullName, CRUDEvent.BeforeLoad))
      {
        FireBusinessRules(dataObject, @event.Session.GetSession(EntityMode.Poco), CRUDEvent.BeforeLoad);
      }
    }

    #endregion


  }
}
