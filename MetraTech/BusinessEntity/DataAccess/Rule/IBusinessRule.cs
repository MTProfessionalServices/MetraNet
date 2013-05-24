using System;
using System.Collections.Generic;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using NHibernate;

namespace MetraTech.BusinessEntity.DataAccess.Rule
{
  public interface IBusinessRule
  {
    List<ErrorObject> Execute(DataObject dataObject, ISession session);
  }
}
