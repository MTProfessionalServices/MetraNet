using System;
using System.Collections.Generic;
using System.IO;
using NUnit.Framework;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;


namespace MetraTech.BusinessEntity.Test.DataAccess.Common
{
  public class CommonTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      // Log4NetConfig.Configure();
    }

    [Test]
    public void GetRmpDir()
    {
      string rmpDir = SystemConfig.GetRmpDir();
      Assert.IsNotNull(rmpDir);
      Assert.IsTrue(Directory.Exists(rmpDir));
    }

    [Test]
    public void ProcessTemplate()
    {
      //Entity entity =
      //  new Entity()
      //    {
      //      ClassName = "Test",
      //      Namespace = "MetraTech.BusinessEntity.OrderManagement",
      //      AssemblyName = "MetraTech.BusinessEntity",
      //    };

      //entity.Properties.Add(new Property(entity) { Name = "Property1", QualifiedName = new QualifiedName("System.String", SystemConfig.DefaultTenant) });
      //entity.Properties.Add(new Property(entity) { Name = "Property2", QualifiedName = new QualifiedName("System.Int32", SystemConfig.DefaultTenant) });

      //string outputFile = Path.Combine(SystemConfig.GetTenantEntityDir(SystemConfig.DefaultTenant), "abc.cs");
      //if (File.Exists(outputFile))
      //{
      //  File.Delete(outputFile);
      //}
      
      //TemplateProcessor.Instance.ProcessBusinessEntity(entity, outputFile);
      //Assert.IsTrue(File.Exists(outputFile));

      //File.Delete(outputFile);
    }

    [Test]
    public void BuildEntities()
    {
      // MSBuildHelper.BuildEntities(SystemConfig.DefaultTenant, false);
    }

    // [Test]
    //public void GetDatabaseType()
    //{
    //  DatabaseType databaseType = SystemConfig.GetDatabaseType();
    //  Assert.AreEqual(DatabaseType.SqlServer, databaseType);
    //}

    #region Data
    #endregion
  }
}
