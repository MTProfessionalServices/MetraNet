using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Rule;
using NHibernate;
using NHibernate.Event;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Events
{
  public class PostLoadEventListener : BaseEventListener, IPostLoadEventListener
  {
    #region IPostLoadEventListener Members

    public void OnPostLoad(PostLoadEvent @event)
    {
      var dataObject = @event.Entity as DataObject;
      if (dataObject == null)
      {
        return;
      }

      if (dataObject is ICompound)
      {
        var compound = dataObject as ICompound;
        compound.TransferDataFromLegacy();
      }

      DecryptProperties(dataObject);
      ConvertDbValueToEnum(dataObject);
      ProcessComputedProperties(dataObject, @event.Session.GetSession(EntityMode.Poco));

      if (RuleConfig.HasRules(dataObject.GetType().FullName, CRUDEvent.AfterLoad))
      {
        FireBusinessRules(dataObject, @event.Session.GetSession(EntityMode.Poco), CRUDEvent.AfterLoad);
      }
    }

    #endregion

   
  }
}
