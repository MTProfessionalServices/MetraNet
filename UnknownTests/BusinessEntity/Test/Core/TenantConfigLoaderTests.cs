using NUnit.Framework;
using System;

using MetraTech.Basic.Config;

namespace MetraTech.BusinessEntity.Test.Core
{
  [TestFixture]
  public class TenantConfigLoaderTests
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      // Log4NetConfig.Configure();
    }

    [Test]
    public void CanLoadTenantConfig() {
      TenantConfigLoader loader = TenantConfigLoader.Instance;
      Assert.IsNotNull(loader, "Loader cannot be null");
      Assert.IsNotNull(loader.TenantConfigs);
      Assert.IsTrue(loader.TenantConfigs.Length > 0);
      Assert.IsTrue(loader.TenantConfigs[0].Name == "MetraTech");
      Assert.IsNotNull(loader.DefaultTenantConfig);
      Assert.IsNotNull(loader.TenantConfigs[0].NhibernateDataSourceConfigs);
      Assert.IsTrue(loader.TenantConfigs[0].NhibernateDataSourceConfigs.Length > 0);
      Assert.IsNotNull(loader.TenantConfigs[0].DefaultNhibernateDataSourceConfig);
      Assert.IsTrue(loader.TenantConfigs[0].NhibernateDataSourceConfigs[0].Name == "NetMeter");
      Assert.IsNotNull(loader.TenantConfigs[0].NhibernateDataSourceConfigs[0].RepositoryConfigs);
      Assert.IsTrue(loader.TenantConfigs[0].NhibernateDataSourceConfigs[0].RepositoryConfigs.Length > 0);
      Assert.IsNotNull(loader.TenantConfigs[0].NhibernateDataSourceConfigs[0].DefaultRespositoryConfig);

    }
  }
}
