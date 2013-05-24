using System;
using System.Collections.Generic;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using NHibernate;

namespace MetraTech.BusinessEntity.DataAccess.Rule
{
  public interface IComputedProperty
  {
    /// <summary>
    ///   Update the value of property 'propertyName' on dataObject.
    /// </summary>
    /// <param name="dataObject"></param>
    /// <param name="propertyName"></param>
    /// <param name="session"></param>
    /// <returns></returns>
    List<ErrorObject> Compute(DataObject dataObject, string propertyName, ISession session);
  }
}
