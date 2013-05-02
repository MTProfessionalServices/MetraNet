using System.Collections.Generic;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using Microsoft.VisualStudio.TestTools.UnitTesting;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.Service.MetadataServiceTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.Service
{
  [TestClass]
  public class MetadataServiceTest
  {
    [TestInitialize]
    public void Setup()
    {
    }

    /// <summary>
    /// Checks whether GetEntity method returns an entity with the specified name
    /// </summary>
    /// <remarks>
    /// MetadataService.GetEntity()
    /// </remarks>
    [TestMethod]
    [TestCategory("GetEntity")]
    public void GetEntityReturnsEntityWithSpecifiedName()
    {
      #region Given

      Entity entity = null;
      var getEntityClient = new MetadataService_GetEntity_Client();
      
      #endregion

      #region When

      getEntityClient.UserName = clientUserName;
      getEntityClient.Password = clientPassword;
      getEntityClient.In_entityName = entityName;
      getEntityClient.Invoke();
      entity = getEntityClient.Out_entity;

      #endregion

      #region Then

      Assert.IsNotNull(entity);
      Assert.AreEqual(entityName, entity.FullName);

      #endregion
    }

    /// <summary>
    /// Checks whether GetEntities method returns a list of entities
    /// </summary>
    /// <remarks>
    /// MetadataService.GetEntities()
    /// </remarks>
    [TestMethod]
    [TestCategory("GetEntities")]
    public void GetEntitiesReturnsEntities()
    {
      #region Given

      List<Entity> entities = null;
      var getEntitiesClient = new MetadataService_GetEntities_Client();

      #endregion

      #region When

      getEntitiesClient.UserName = clientUserName;
      getEntitiesClient.Password = clientPassword;
      getEntitiesClient.Out_entities = entities;
      getEntitiesClient.Invoke();
      entities = getEntitiesClient.Out_entities;

      #endregion

      #region Then

      Assert.IsNotNull(entities);

      #endregion
    }


    #region Data

    private static readonly string clientUserName = "su";
    private static readonly string clientPassword = "su123";
    private static readonly string entityName = "MetraTech.SmokeTest.TestBME.AllDataTypeBME";

    #endregion
  }
}
