using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using NHibernate;
using NHibernate.Criterion;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public static class NHibernateSessionExtension
  {
    public static DataObject GetDataObjectByBusinessKey(this ISession session,
                                                        string entityName,
                                                        BusinessKey businessKey)
    {
      Check.Require(businessKey != null, "businessKey cannot be null", SystemConfig.CallerInfo);
      List<PropertyInstance> businessKeyProperties = businessKey.GetPropertyData();
      return GetDataObjectByBusinessKeyProperties(session, entityName, businessKeyProperties);
    }

    public static DataObject GetDataObjectByBusinessKeyProperties(this ISession session,
                                                                  string entityName,
                                                                  List<PropertyInstance> businessKeyProperties)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(businessKeyProperties != null, "businessKeyProperties cannot be null", SystemConfig.CallerInfo);

      BusinessKey.CheckProperties(entityName, businessKeyProperties);
      DataObject dataObject = null;

      string businessKeyLog =
        String.Join(Environment.NewLine, (from p in businessKeyProperties select p.ToString()).ToArray());

      try
      {
        ICriteria criteria = session.CreateCriteria(entityName);

        foreach (PropertyInstance propertyInstance in businessKeyProperties)
        {
          criteria.Add(Expression.Eq("BusinessKey." + propertyInstance.Name, propertyInstance.Value));
        }

        IList list = criteria.List();
        Check.Ensure(list.Count <= 1,
                     String.Format("Found more than one instance for entity '{0}' and business key '{1}'",
                                   entityName, businessKeyLog),
                     SystemConfig.CallerInfo);

        if (list.Count == 1)
        {
          dataObject = list[0] as DataObject;
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load instance for entity name '{0}' and business key '{1}'",
                                       entityName, businessKeyLog);
        throw new LoadDataException(message, e);
      }
      
      return dataObject;
    } 
  }
}
