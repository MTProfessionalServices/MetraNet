using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;

using NHibernate;
using NHibernate.Cfg;
using NHibernate.Cfg.MappingSchema;
using NHibernate.Event;
using NHibernate.Event.Default;

using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.Basic;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Config;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence.Events;


namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class EntityGroup
  {
    #region Public Methods
    public EntityGroup(string extensionName, string entityGroupName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null or empty", SystemConfig.CallerInfo);

      ExtensionName = extensionName;
      Name = entityGroupName;
    }

    public bool IsValid()
    {
      if (String.IsNullOrEmpty(ExtensionName) || String.IsNullOrEmpty(Name))
      {
        return false;
      }

      return true;
    }
    #endregion

    #region Public Properties
    public string Name { get; set; }
    public string ExtensionName { get; set; }
    public bool IsRemote { get; set; }
    #endregion

    #region Internal Methods
    /// <summary>
    ///   If refresh is true, recreate the AppDomain, if one exists.
    /// </summary>
    /// <param name="refresh"></param>
    internal RemoteRepositoryAccess GetRemoteRepositoryAccess(bool refresh)
    {
      if (AppDomain == null || refresh)
      {
        CreateAppDomain();
      }

      return RemoteRepositoryAccess;
    }


    /// <summary>
    /// 
    /// </summary>
    /// <param name="repositoryConfig"></param>
    /// <param name="refresh"></param>
    /// <returns></returns>
    //internal ISessionFactory GetSessionFactory(RepositoryConfig repositoryConfig, bool refresh)
    //{
    //  if (SessionFactory == null || refresh)
    //  {
    //    BuildSessionFactory(repositoryConfig);
    //  }

    //  return SessionFactory;
    //}

    //internal Configuration GetConfiguration(RepositoryConfig repositoryConfig, bool refresh)
    //{
    //  if (Configuration == null || refresh)
    //  {
    //    BuildSessionFactory(repositoryConfig);
    //  }

    //  return Configuration;
    //}

    internal void CreateAppDomain()
    {
      RefreshAppDomain();

      #region Create AppDomain and Remotable Objects
      logger.Debug(String.Format("Creating AppDomain for entity group '{0}' in extension '{1}'", Name, ExtensionName));
      AppDomain = AppDomainHelper.CreateAppDomain(ExtensionName, Name);

      string fileLocation = Path.Combine(SystemConfig.GetBinDir(), 
                            Path.GetFileName(Assembly.GetExecutingAssembly().Location));
      Check.Assert(File.Exists(fileLocation),
                   String.Format("Cannot find file '{0}'", fileLocation),
                   SystemConfig.CallerInfo);

      // Create the RemoteRepositoryAccess
      logger.Debug(String.Format("Creating RemoteRepositoryAccess for entity group '{0}' in extension '{1}'", Name, ExtensionName));
      RemoteRepositoryAccess =
       (RemoteRepositoryAccess)AppDomain.CreateInstanceFromAndUnwrap(fileLocation, 
                                                                     typeof(RemoteRepositoryAccess).FullName);
      RemoteRepositoryAccess.InitializeLifetimeService();
      RemoteRepositoryAccess.ExtensionName = ExtensionName;
      RemoteRepositoryAccess.EntityGroupName = Name;

      // Create the RemoteRepositoryInterceptor
      //logger.Debug(String.Format("Creating RemoteRepositoryInterceptor for entity group '{0}' in extension '{1}'", Name, ExtensionName));
      //RemoteRepositoryInterceptor =
      // (RemoteRepositoryInterceptor)AppDomain.CreateInstanceFromAndUnwrap(fileLocation,
      //                                                               typeof(RemoteRepositoryInterceptor).FullName);
      //RemoteRepositoryInterceptor.InitializeLifetimeService();

      #endregion
    }

    #endregion

    #region Private Properties
    private AppDomain AppDomain { get; set; }
    private ISessionFactory SessionFactory { get; set; }
    private Configuration Configuration { get; set; }
    private RemoteRepositoryAccess RemoteRepositoryAccess { get; set; }
    #endregion

    #region Private Methods
    private void RefreshAppDomain()
    {
      if (AppDomain != null)
      {
        logger.Debug(String.Format("Releasing resources in AppDomain for entity group '{0}' in extension '{1}'", Name, ExtensionName));
        if (RemoteRepositoryAccess != null)
        {
          // Clean RemoteRepositoryAccess
          RemoteRepositoryAccess = null;
        }

        try
        {
          logger.Debug(String.Format("Unloading AppDomain for entity group '{0}' in extension '{1}'", Name, ExtensionName));

          AppDomain.Unload(AppDomain);
          AppDomain = null;
        }
        catch (System.Exception e)
        {
          throw new MetadataException("Cannot unload AppDomain", e, SystemConfig.CallerInfo);
        }
      }
    }

    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("EntityGroup");
    #endregion
  }
}
