using System.Collections.Generic;
using System.IO;
using log4net;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

namespace MetraTech.BusinessEntity.Test.DataAccess
{
  interface IDataAccessTestCase
  {
    #region Load Entities
    void BeforeLoadEntities();
    ICollection<Entity> LoadEntities();
    void AfterLoadEntities(ICollection<Entity> entities);
    #endregion

    #region Create Entities
    /// <summary>
    ///   If any entities were loaded during LoadEntities, they're passed into this method.
    /// </summary>
    /// <param name="entities"></param>
    void BeforeCreateEntities(ICollection<Entity> entities);
    ICollection<Entity> CreateEntities();
    void AfterCreateEntities(ICollection<Entity> entities);
    #endregion

    #region Update Entities
    /// <summary>
    ///    Return true, if any entities have been updated
    /// </summary>
    /// <param name="entities"></param>
    /// <returns></returns>
    bool UpdateEntities(ICollection<Entity> entities);
    #endregion

    #region Create Relationships
    /// <summary>
    ///   If no entities were loaded or created, entities will be null
    /// </summary>
    /// <param name="entities"></param>
    void BeforeCreateRelationships(ICollection<Entity> entities);
    /// <summary>
    ///   If no entities were loaded or created, entities will be null
    /// </summary>
    /// <param name="entities"></param>
    ICollection<Relationship> CreateRelationships(ICollection<Entity> entities);
    /// <summary>
    ///   If no relationships were created, relationships will be null
    /// </summary>
    /// <param name="relationships"></param>
    void AfterCreateRelationships(ICollection<Relationship> relationships);
    #endregion

    #region Create Data
    void CreateData(ICollection<Entity> entities);
    #endregion
  }

  public abstract class DataAccessTestCase : IDataAccessTestCase
  {
    protected DataAccessTestCase()
    {
      CleanTenantDir = true;
    }

    [TestFixtureSetUp]
    public virtual void Setup()
    {
     
    }

    [TestFixtureTearDown]
    public virtual void TearDown()
    {
    }

    #region IDataAccessTestCase

    #region Load Entities
    public virtual void BeforeLoadEntities()
    {
      logger.Warn(string.Format("'BeforeEntityLoad' has not been implemented by test case '{0}'.", GetType().FullName));
    }

    public virtual ICollection<Entity> LoadEntities()
    {
      logger.Warn(string.Format("'LoadEntities' has not been implemented by test case '{0}'.", GetType().FullName));
      return new List<Entity>();
    }

    public virtual void AfterLoadEntities(ICollection<Entity> entities)
    {
      logger.Warn(string.Format("'AfterEntityLoad' has not been implemented by test case '{0}'.", GetType().FullName));
    }
    #endregion

    #region Create Entities
    public virtual void BeforeCreateEntities(ICollection<Entity> entities)
    {
      logger.Warn(string.Format("'BeforeEntityCreation' has not been implemented by test case '{0}'.", GetType().FullName));
    }

    public virtual ICollection<Entity> CreateEntities()
    {
      logger.Warn(string.Format("'CreateEntities' has not been implemented by test case '{0}'.", GetType().FullName));
      return new List<Entity>();
    }

    public virtual void AfterCreateEntities(ICollection<Entity> entities)
    {
      logger.Warn(string.Format("'AfterEntityCreation' has not been implemented by test case '{0}'.", GetType().FullName));
    }
    #endregion

    #region Update Entities
    public virtual bool UpdateEntities(ICollection<Entity> entities)
    {
      logger.Warn(string.Format("'UpdateEntities' has not been implemented by test case '{0}'.", GetType().FullName));
      return false;
    }
    #endregion

    #region Create Relationships
    public virtual void BeforeCreateRelationships(ICollection<Entity> entities)
    {
      logger.Warn(string.Format("'BeforeRelationshipCreation' has not been implemented by test case '{0}'.", GetType().FullName));
    }

    public virtual ICollection<Relationship> CreateRelationships(ICollection<Entity> entities)
    {
      logger.Warn(string.Format("'CreateRelationships' has not been implemented by test case '{0}'.", GetType().FullName));
      return new List<Relationship>();
    }

    public virtual void AfterCreateRelationships(ICollection<Relationship> relationships)
    {
      logger.Warn(string.Format("'AfterRelationshipCreation' has not been implemented by test case '{0}'.", GetType().FullName));
    }
    #endregion

    #region Create Data
    public virtual void CreateData(ICollection<Entity> entities)
    {
      logger.Warn(string.Format("'CreateData' has not been implemented by test case '{0}'.", GetType().FullName));
    }
    #endregion

    #endregion

    [Test]
    public void Execute()
    {
      InitializeTenant(TenantName, CleanTenantDir);

      #region Load Entities
      BeforeLoadEntities();
      List<Entity> entities = new List<Entity>();
      entities.AddRange(LoadEntities());
      AfterLoadEntities((entities));


      #endregion

      #region Create Entities
      BeforeCreateEntities(entities);

      ICollection<Entity> newEntities = CreateEntities();
      if (newEntities.Count > 0)
      {
        entities.AddRange(newEntities);
        CreateEntityMetadataAndSchema(TenantName, entities);
      }

      AfterCreateEntities(entities);
      UpdateEntities(entities);
      CreateRelationships(entities);
      #endregion

      #region Create Data
      CreateData(entities);
      #endregion
    }

    #region Properties
    public string TenantName { get; set; }
    public bool CleanTenantDir { get; set; }
    #endregion

    #region Private Methods
    private static void InitializeTenant(string tenant, bool clean)
    {
      Check.Require(tenant != null, "Argument tenant cannot be null", SystemConfig.CallerInfo);

      // Create the tenant, if it doesn't exist
      if (!SystemConfig.TenantExists(tenant))
      {
        SystemConfig.CreateTenant(tenant);
      }

      if (!TenantManager.Instance.HasTenant(tenant))
      {
        TenantConfig tenantConfig = TenantConfigLoader.Instance.DefaultTenantConfig.Copy(tenant);
        TenantManager.Instance.CreateTenant(tenantConfig);
      }

      // Clean tenant dir
      if (clean)
      {
        SystemConfig.CleanEntityDir(tenant);
        SystemConfig.CreateCsProj(tenant);
        string assemblyFile = Path.Combine(SystemConfig.GetBinDir(),
                                           SystemConfig.GetTenantEntityAssembly(tenant) + ".dll");
        if (File.Exists(assemblyFile))
        {
          File.Delete(assemblyFile);
        }
      }
    }

    internal static void CreateEntityMetadataAndSchema(string tenant, List<Entity> entities)
    {
      Check.Require(entities != null && entities.Count > 0, "entities cannot be null or empty", SystemConfig.CallerInfo);

      // Remove the code driven entities, if any from entities
      entities.RemoveAll(e => e.Category == Category.CodeDriven);

      // Save the entities and create the schema
      MetadataAccess.Instance.SaveEntities(tenant, entities);
      MetadataAccess.Instance.CreateSchema(tenant);

    }

    #endregion

    #region Data
    protected static readonly ILog logger = LogManager.GetLogger("DataAccessTestCase");
    #endregion
  }
}
