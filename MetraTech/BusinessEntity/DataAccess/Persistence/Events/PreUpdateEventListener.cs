
using System;
using MetraTech.Basic;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Rule;
using NHibernate;
using NHibernate.Event;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Events
{
  public class PreUpdateEventListener : BaseEventListener, IPreUpdateEventListener
  {
    #region IPreUpdateEventListener Members

    /// <summary>
    ///   Return true if the operation should be vetoed
    /// </summary>
    /// <param name="@event"></param>
    public bool OnPreUpdate(PreUpdateEvent @event)
    {
      var dataObject = @event.Entity as DataObject;
      if (dataObject == null)
      {
        return false;
      }

      dataObject.UpdateDate = MetraTime.Now;

      CheckCompoundLegacyPrimaryKeyValues(dataObject, @event.Session.GetSession(EntityMode.Poco));

      if (RuleConfig.HasRules(dataObject.GetType().FullName, CRUDEvent.BeforeUpdate))
      {
        FireBusinessRules(dataObject, @event.Session.GetSession(EntityMode.Poco), CRUDEvent.BeforeUpdate);
      }

      // Update the properties in the state object
      UpdateState(dataObject, @event.Persister.PropertyNames, @event.State);

      ConvertEnumToDbValue(dataObject, @event.Persister.PropertyNames, @event.State);
      EncryptProperties(dataObject, @event.Persister.PropertyNames, @event.State);

      return false;
    }

    #endregion
  }
}
