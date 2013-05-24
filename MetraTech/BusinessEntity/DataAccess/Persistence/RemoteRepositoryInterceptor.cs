using System;
using System.Collections.Generic;
using System.Reflection;

using LinFu.IoC.Reflection;
using LinFu.Proxy;
using LinFu.Proxy.Interfaces;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Config;
using MetraTech.BusinessEntity.Core.Persistence;
using MetraTech.BusinessEntity.DataAccess.Exception;
//using MetraTech.BusinessEntity.OrderManagement;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class RemoteRepositoryInterceptor : MarshalByRefObject
  {
    public override object InitializeLifetimeService()
    {
      // Returning null tells the .NET Remoting infrastructure that the object instance should live indefinitely
      return null;
    }

    public object Execute(string interfaceType, 
                          string methodName, 
                          object[] arguments, 
                          string[] typeArguments,
                          RepositoryConfig repositoryConfig)
    {
      Check.Require(!String.IsNullOrEmpty(interfaceType), "interfaceType cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(methodName), "methodName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(arguments != null, "arguments cannot be null", SystemConfig.CallerInfo);
      Check.Require(typeArguments != null, "typeArguments cannot be null", SystemConfig.CallerInfo);
      Check.Require(repositoryConfig != null, "repositoryConfig cannot be null", SystemConfig.CallerInfo);

      IProxyFactory proxyFactory = new ProxyFactory();

      var interceptor = new RepositoryInterceptor(repositoryConfig);

      object repositoryProxy =
        proxyFactory.CreateProxy(interceptor.RepositoryInterfaceType,
                                 interceptor,
                                 new Type[0]);

      Check.Assert(repositoryProxy != null, "repositoryProxy cannot be null", SystemConfig.CallerInfo);

      // Convert typeArguments from string to Type
      var types = new List<Type>();

      foreach (String type in typeArguments)
      {
        types.Add(Type.GetType(type, true));
      }

      return repositoryProxy.Invoke(interfaceType + "." + methodName, types.ToArray(), arguments);
    }

    #region Properties
    #endregion

  }
}
