using System;
using System.Collections.Generic;
using MetraTech.Basic;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using NHibernate;

namespace MetraTech.BusinessEntity.DataAccess.Rule
{
  public abstract class BusinessRule : Logic, IBusinessRule
  {
    public abstract List<ErrorObject> Execute(DataObject dataObject, ISession session);

    protected ILog Logger
    {
      get { return logger; }
    }

    protected void LogDebugBeginCompute(string propertyName, DataObject dataObject)
    {
      if (LogLevel.Debug == logger.LogLevel)
      {
        Logger.Debug(String.Format("Begin computing property '{0}' for entity '{1}': InstanceId = {2}",
                                   propertyName,
                                   dataObject.GetType().FullName,
                                   dataObject.Id));
      }
    }

    protected void LogDebugEndCompute(string propertyName, DataObject dataObject)
    {
      if (LogLevel.Debug == logger.LogLevel)
      {
        Logger.Debug(String.Format("End computing property '{0}' for entity '{1}': InstanceId = {2}: Value = {3}",
                                   propertyName,
                                   dataObject.GetType().FullName,
                                   dataObject.Id,
                                   dataObject.GetValue(propertyName)));
      }
    }

    private static readonly ILog logger = LogManager.GetLogger("BusinessRule");
  }
}
