using System;
using System.Collections.Generic;
using System.IO;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core.Config;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using MetraTech.BusinessEntity.DataAccess.Persistence.Sync;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class RemoteRepositoryAccess  : MarshalByRefObject
  {
    #region Public Methods
    public override object InitializeLifetimeService()
    {
      LogLevel logLevel;
      string nhLogFileWithPath = BusinessEntityConfig.Instance.GetNHibernateLogFileWithPathAndLogLevel(out logLevel);
      Log4NetConfig.Configure(nhLogFileWithPath, logLevel);

      // HibernatingRhinos.NHibernate.Profiler.Appender.NHibernateProfiler.InitializeOfflineProfiling(SystemConfig.GetNhibernateQueryLogFile());
      
      RepositoryAccess.Instance.InitializeForSync();
      RepositoryAccess.Instance.IsRunningRemotely = true;
      
      // Returning null tells the .NET Remoting infrastructure that the object instance should live indefinitely
      return null;
    }

    public void UpdateSchema(SyncData syncData)
    {
      Check.Require(syncData != null, "syncData cannot be null");
      RepositoryAccess.Instance.UpdateSchema(syncData);
    }

    #endregion

    #region Public Properties
    public string ExtensionName { get; set; }
    public string EntityGroupName { get; set; }
    #endregion

    #region Private Properties
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("RemoteRepositoryAccess");
    #endregion
  }
}
