using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

using LinFu.AOP.Interfaces;
using MetraTech.BusinessEntity.Core.Config;

using MetraTech.BusinessEntity.Core.Persistence;
using MetraTech.Basic;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.Basic.Config;

// Ambiguous reference with NHibernate
using IInterceptor = LinFu.AOP.Interfaces.IInterceptor;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class RepositoryInterceptor : IInterceptor
  {
    #region Public Methods
    public RepositoryInterceptor(RepositoryConfig repositoryConfig)
    {
      Check.Require(repositoryConfig != null, "repositoryConfig cannot be null");

      RepositoryConfig = repositoryConfig;

      Initialize();
    }
    #endregion

    #region IInterceptor
    /// <summary>
    /// 
    /// </summary>
    /// <param name="info"></param>
    /// <returns></returns>
    public virtual object Intercept(IInvocationInfo info)
    {
      IRepository repository;
      object returnValue;

      // logger.Debug(String.Format("Intercepting call to method '{0}'", info.TargetMethod.Name));

      if (info.TargetMethod.Name.ToLower().Contains("tostring"))
      {
        return "";
      }

      try
      {
        #region Get extension name and entity group name
        string extensionName, entityGroupName;
        StandardRepository.GetExtensionAndEntityGroup(info, out extensionName, out entityGroupName);
        Check.Ensure(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", SystemConfig.CallerInfo);
        Check.Ensure(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null or empty", SystemConfig.CallerInfo);
        #endregion

        #region Handle Remote AppDomain
        // Forward call to remote AppDomain, if necessary.
        if (CallRemoteRepositoryInterceptor)
        {
          // Convert the type arguments (for generic methods) to string so that they can be
          // passed to the remote AppDomain
          List<string> typeArgumentsAsString = new List<string>();

          foreach (Type type in info.TypeArguments)
          {
            typeArgumentsAsString.Add(type.AssemblyQualifiedName);
          }

          RemoteRepositoryInterceptor remoteRepositoryInterceptor =
            RepositoryAccess.Instance.GetRemoteRepositoryInterceptor(extensionName, entityGroupName);

          Check.Require(remoteRepositoryInterceptor != null, 
                        "remoteRepositoryInterceptor cannot be null",
                        SystemConfig.CallerInfo);

          returnValue = remoteRepositoryInterceptor.Execute(RepositoryConfig.Interface,
                                                            info.TargetMethod.Name,
                                                            info.Arguments,
                                                            typeArgumentsAsString.ToArray(),
                                                            RepositoryConfig);
          return returnValue;
        }
        #endregion

        #region Create Repository
        MethodInfo methodInfo = info.TargetMethod;
        object[] arguments = info.Arguments;

        Check.Require(RepositoryType != null, "RepositoryType cannot be null", SystemConfig.CallerInfo);

        // Create the Repository instance
        repository =
          Activator.CreateInstanceFrom(RepositoryType.Assembly.CodeBase, 
                                       RepositoryType.FullName).Unwrap() as IRepository;

        Check.Ensure(repository != null, "RepositoryInstance cannot be null", SystemConfig.CallerInfo);

        // Get the SessionFactory
        var sessionFactory =
          RepositoryAccess.Instance.GetSessionFactory(extensionName, entityGroupName, RepositoryConfig);
        Check.Require(sessionFactory != null, "sessionFactory cannot be null", SystemConfig.CallerInfo);
        // Set the SessionFactory on the RepositoryInstance
        repository.SessionFactory = sessionFactory;

        // Set the Configuration on the RepositoryInstance
        var configuration =
          RepositoryAccess.Instance.GetConfiguration(extensionName, entityGroupName, RepositoryConfig);
        Check.Require(configuration != null, "configuration cannot be null", SystemConfig.CallerInfo);
        repository.Configuration = configuration;
        #endregion

        // Call Repository Method
        returnValue = methodInfo.Invoke(repository, arguments);

      }
      catch (System.Exception e)
      {
        var message = 
          String.Format("The operation '{0}' failed for repository type '{1}' and interface '{2}'",
                        info.TargetMethod.Name,
                        RepositoryConfig.AssemblyQualifiedType,
                        RepositoryConfig.Interface);
        logger.Error(message);
        
        throw e;
      }

      return returnValue;
    }
    #endregion

    #region Private Methods
    private void Initialize()
    {
      try
      {
        RepositoryType = Type.GetType(RepositoryConfig.AssemblyQualifiedType, true);
        Check.Assert(RepositoryType != null, String.Format("Cannot load type '{0}'", RepositoryConfig.AssemblyQualifiedType), SystemConfig.CallerInfo);
      }
      catch (System.Exception e)
      {
        throw new MetadataException(
         (String.Format("Cannot load repository type '{0}' with interface '{1}'",
                        RepositoryConfig.AssemblyQualifiedType,
                        RepositoryConfig.Interface)), e, SystemConfig.CallerInfo);
      }

      RepositoryInterfaceType = RepositoryType.GetInterface(RepositoryConfig.Interface);
      if (RepositoryInterfaceType == null)
      {
        throw new MetadataException(
         (String.Format("The repository type '{0}' does not implement the interface '{1}'",
                        RepositoryConfig.AssemblyQualifiedType,
                        RepositoryConfig.Interface)), SystemConfig.CallerInfo);
      }
    }

    


    #endregion

    #region Properties
    internal bool CallRemoteRepositoryInterceptor { get; set; }
    internal Type RepositoryInterfaceType { get; set; }
    internal Type RepositoryType { get; set; }

    private RepositoryConfig RepositoryConfig { get; set; }

    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("RepositoryInterceptor");
    #endregion
  }
}
