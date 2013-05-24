using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Basic;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NHibernate;

namespace MetraTech.BusinessEntity.DataAccess.Rule
{
  public class Logic
  {
    public static DataObject LookupDataObjectByBusinessKey(ISession session, 
                                                           string entityName, 
                                                           List<PropertyInstance> businessKeyProperties)
    {
      foreach(PropertyInstance propertyInstance in businessKeyProperties)
      {
        propertyInstance.Value = StringUtil.ChangeType(propertyInstance.Value, propertyInstance.Type);
      }

      return session.GetDataObjectByBusinessKeyProperties(entityName, businessKeyProperties);
    }
  }
}
