using System;
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
  public class SaveOrUpdateEventListener : BaseEventListener, ISaveOrUpdateEventListener
  {
    #region IPreInsertEventListener Members

    /// <summary>
    /// </summary>
    /// <param name="@event"></param>
    public void OnSaveOrUpdate(SaveOrUpdateEvent @event)
    {
      var dataObject = @event.Entity as DataObject;
      if (dataObject == null)
      {
        return;
      }

      if (dataObject is ICompound)
      {
        var compound = dataObject as ICompound;
        compound.TransferDataToLegacy();
      }
    }

    #endregion

    #region Private Methods

    #endregion
  }
}
