using System;
using System.Collections.Generic;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.DomainModel.Enums.Core.Global;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.Service.MetadataServiceTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.Service
{
  [TestFixture]
  public class MetadataServiceTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
    }

    [Test]
    [Category("GetEntity")]
    public void GetEntity()
    {
      var getEntityClient = new MetadataService_GetEntity_Client();
      getEntityClient.UserName = clientUserName;
      getEntityClient.Password = clientPassword;
      getEntityClient.In_entityName = "SmokeTest.OrderManagement.Order";
      getEntityClient.Invoke();
      Entity orderEntity = getEntityClient.Out_entity;
      Assert.IsNotNull(orderEntity);
    }

    [Test]
    [Category("GetEntities")]
    public void GetEntities()
    {
      var getEntitiesClient = new MetadataService_GetEntities_Client();
      getEntitiesClient.UserName = clientUserName;
      getEntitiesClient.Password = clientPassword;
      getEntitiesClient.Invoke();
    
    }

   
    #region Data
    private static readonly string clientUserName = "su";
    private static readonly string clientPassword = "su123";
    #endregion
  }
}
