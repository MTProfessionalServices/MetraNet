using System;
using System.Collections.Generic;
using System.Reflection;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Rule;
using NHibernate;
using NHibernate.Event;
using NHibernate.Persister.Entity;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Events
{
  public class PreInsertEventListener : BaseEventListener, IPreInsertEventListener
  {
    #region IPreInsertEventListener Members

    /// <summary>
    ///   Return true if the operation should be vetoed
    /// </summary>
    /// <param name="@event"></param>
    public bool OnPreInsert(PreInsertEvent @event)
    {
      var dataObject = @event.Entity as DataObject;
      if (dataObject == null)
      {
        return false;
      }

      dataObject.CreationDate = MetraTime.Now;
      dataObject.UpdateDate = dataObject.CreationDate;

      CheckCompoundLegacyPrimaryKeyValues(dataObject, @event.Session.GetSession(EntityMode.Poco));

      SetInternalBusinessKey(dataObject, @event);

      if (RuleConfig.HasRules(dataObject.GetType().FullName, CRUDEvent.BeforeCreate))
      {
        FireBusinessRules(dataObject, @event.Session.GetSession(EntityMode.Poco), CRUDEvent.BeforeCreate);
      }

      UpdateState(dataObject, @event.Persister.PropertyNames, @event.State);

      ConvertEnumToDbValue(dataObject, @event.Persister.PropertyNames, @event.State);
      EncryptProperties(dataObject, @event.Persister.PropertyNames, @event.State);


      return false;
    }

    #endregion

    #region Private Methods

    private void SetInternalBusinessKey(DataObject dataObject, PreInsertEvent @event)
    {
      // History objects acquire their business key from the original object
      if (dataObject is BaseHistory)
      {
        return;
      }

      // Set Internal BusinessKey, if necessary
      // Have to update both DataObject and the NHibernate entity state
      // http://ayende.com/Blog/archive/2009/04/29/nhibernate-ipreupdateeventlistener-amp-ipreinserteventlistener.aspx
      // if (dataObject.GetInternalBusinessKey() == Guid.Empty)
      // {
        Dictionary<Guid, string> keyByPropertyNames = dataObject.SetInternalBusinessKey();
        foreach (KeyValuePair<Guid, string> kvp in keyByPropertyNames)
        {
          var index = Array.IndexOf(@event.Persister.PropertyNames, kvp.Value);
          Check.Require(index != -1,
                        String.Format("Cannot find business key property '{0}' in NHibernate state for entity '{1}'",
                                      kvp.Value, dataObject.GetType().FullName));

          var businessKey = @event.State[index] as BusinessKey;
          Check.Require(businessKey != null,
                        String.Format("Cannot convert property '{0}' to type '{1}' for entity '{2}'",
                                      kvp.Value, typeof(BusinessKey).FullName, dataObject.GetType().FullName));

          businessKey.SetInternalKey(kvp.Key);
        }
      // }
    }

    #endregion
  }
}
