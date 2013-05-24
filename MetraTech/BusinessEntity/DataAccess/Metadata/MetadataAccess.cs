using System;
using System.CodeDom.Compiler;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text;
using Core.Common;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Config;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Persistence.Sync;
using MetraTech.BusinessEntity.DataAccess.Rule;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class MetadataAccess
  {
    #region IMetadataAccess
    public bool IsUniqueRelationshipName(string relationshipName, Entity entity)
    {
      return true;
    }

    public bool IsRelationshipPropertyUnique(string relatioshipPropertyName, Entity entity)
    {
      return true;
    }

    public bool IsGraphvizInstalled()
    {
      return SystemConfig.IsGraphvizInstalled();
    }

    public string GetEntityGraphFileName()
    {
      return Name.GetEntityGraphDotFileName(false) + ".png";
    }

    public List<string> GetAssemblyCopyDirectories(out string rmpBinDir)
    {
      rmpBinDir = SystemConfig.GetBinDir();
      var directories = new List<string>();
      directories.AddRange(BusinessEntityConfig.Instance.GetAssemblyCopyDirectories());
      return directories;
    }

    public List<string> GetBmeDatabases()
    {
      return NHibernateConfig.GetDatabaseNames();
    }

    public List<string> GetTableNames()
    {
      return GetRepository().GetTableNames("NetMeter");
    }

    public List<DbColumnMetadata> GetColumnMetadata(string tableName)
    {
      List<DbColumnMetadata> columnMetadataList =
        GetRepository().GetColumnMetadata("NetMeter", new List<string>() { tableName });

      var unsupportedColumnMetadataList = new List<DbColumnMetadata>();

      // Set CSharp types
      foreach (DbColumnMetadata columnMetadata in columnMetadataList)
      {
        string typeName = Property.ConvertDbTypeNameToCSharpTypeName(columnMetadata);
        if (String.IsNullOrEmpty(typeName))
        {
          unsupportedColumnMetadataList.Add(columnMetadata);
        }
        else
        {
          columnMetadata.CSharpTypeName = typeName;
        }
      }

      columnMetadataList.RemoveAll(unsupportedColumnMetadataList.Contains);

      return columnMetadataList;
    }

    public Entity CreateCompoundEntity(string entityName, List<DbColumnMetadata> columnMetadata)
    {
      return new CompoundEntity(entityName, columnMetadata);
    }

    public List<Entity> GetConnectedEntities(Entity entity, List<Entity> existingEntities)
    {
      return MetadataRepository.Instance.GetConnectedEntities(entity, existingEntities);
    }

    /// <summary>
    ///   Return true if both a database table exists and the checksum
    ///   of the hbm file on disk matches the one in the database.
    /// </summary>
    public bool IsSynchronizedWithDb(string entityName)
    {
      Entity entity = MetadataRepository.Instance.GetEntity(entityName);
      if (entity == null || entity.EntitySyncData == null)
      {
        return false;
      }
      
      string hbmFileWithPath = Name.GetHbmFileNameWithPath(entity.FullName);
      if (!File.Exists(hbmFileWithPath))
      {
        return false;
      }

      string diskChecksum = DirectoryUtil.GetChecksum(hbmFileWithPath);
      if (diskChecksum != entity.EntitySyncData.HbmChecksum)
      {
        return false;
      }

      return true;
    }

    public void Synchronize(bool overWriteHbm = false, string extensionName = null)
    {
      List<Entity> entities;
      if (!String.IsNullOrEmpty(extensionName))
      {
        Check.Require(SystemConfig.ExtensionExists(extensionName),
                    String.Format("The specified extension '{0}' cannot be found", extensionName));

        entities = MetadataRepository.Instance.GetEntities(extensionName, true);
      }
      else
      {
        entities = MetadataRepository.Instance.GetEntities(true);
      }

      var syncData = new SyncData(overWriteHbm);

      foreach (Entity entity in entities)
      {
        syncData.AddModifiedEntity(entity);
      }

      var syncManager = new SyncManager();
      syncManager.Synchronize(syncData, false);
    }

    public List<ErrorObject> Synchronize(SyncData syncData)
    {
      var syncManager = new SyncManager();
      return syncManager.Synchronize(syncData, true);
    }

    public void MakeSubclass(string parentEntityName, string derivedEntityName)
    {
      var syncManager = new SyncManager();
      syncManager.MakeSubclass(parentEntityName, derivedEntityName);
    }
    
    public bool HasData(Entity entity)
    {
      if (entity == null || String.IsNullOrEmpty(entity.TableName))
      {
        return false;
      }
      return GetRepository().TableHasRows(entity.DatabaseName, entity.TableName);
    }

    /// <summary>
    ///   Use this API to create table names when there are no unsynchronized entities.
    /// </summary>
    /// <param name="entity"></param>
    /// <returns></returns>
    public string CreateTableName(Entity entity)
    {
      return CreateTableName(entity, new List<Entity>());
    }

    /// <summary>
    ///   Use this API to create table names from ICE when there are new entities which have
    ///   not been synchronized.
    /// </summary>
    /// <param name="entity"></param>
    /// <param name="entities"></param>
    /// <returns></returns>
    public string CreateTableName(Entity entity, List<Entity> entities)
    {
      var candidates = new List<Entity>();
      candidates.AddRange(entities);
      candidates.RemoveAll(e => e.FullName == entity.FullName);
      return TableNameGenerator.CreateTableName(entity, candidates);
    }

    #region Computed Property
    public string GetComputedPropertyTemplate(string entityName, 
                                              string computedPropertyName, 
                                              string description)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(computedPropertyName), "computedPropertyName cannot be null or empty", SystemConfig.CallerInfo);

      // Get the template file from RMP\config\BusinessEntity
      string fileName = SystemConfig.GetComputedPropertyTemplateFile();
      StringBuilder fileContent;

      using (var streamReader = new StreamReader(fileName))
      {
        fileContent = new StringBuilder(streamReader.ReadToEnd());
      }

      string computedPropertyClassName = Name.GetComputedPropertyClassName(entityName, computedPropertyName);

      // Substitute 
      fileContent.Replace("%%NAMESPACE%%", Name.GetComputedPropertyNamespace(entityName));
      fileContent.Replace("%%COMPUTATION_CLASS_NAME%%", computedPropertyClassName);
      fileContent.Replace("%%PROPERTY_DESCRIPTION%%", description);
      fileContent.Replace("%%ENTITY_NAME%%", entityName);
      fileContent.Replace("%%PROPERTY_NAME%%", computedPropertyName);
      fileContent.Replace("%%BME_CLASS_NAME%%", Name.GetEntityClassName(entityName));

      return fileContent.ToString();
    }

    public string GetCodeSnippetForLookingUpDataObject(string lookupEntityName,
                                                       string variableName,
                                                       List<PropertyInstance> businessKeyProperties,
                                                       bool isDebug)
    {
      BusinessKey.CheckProperties(lookupEntityName, businessKeyProperties);

      // Generates a code snippet that looks like the following: 

      //var propertyInstances = new List<PropertyInstance>();
      //propertyInstances.Add(
      //    new PropertyInstance("ReferenceNumber",
      //                         "System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089",
      //                         true,
      //                         "abc"));


      //SmokeTest.OrderManagement.Product product =
      //  LookupDataObjectByBusinessKey(session,
      //                                propertyInstances,
      //                                "SmokeTest.OrderManagement.Product") as SmokeTest.OrderManagement.Product;


      var propertyInstanceCodeSnippet = new StringBuilder("List<PropertyInstance> propertyInstances = new List<PropertyInstance>();");
      
      foreach(PropertyInstance propertyInstance in businessKeyProperties)
      {
        propertyInstanceCodeSnippet.Append("propertyInstances.Add(");
        propertyInstanceCodeSnippet.Append
          (" new PropertyInstance(\"" + propertyInstance.Name + "\",\n" +
                                 "\"" + propertyInstance.AssemblyQualifiedTypeName + "\",\n" +
                                  "true,\n" +
                                 "\"" + propertyInstance.Value + "\"));");
      }

      string variableTypeDeclaration = String.Empty;
      if (!isDebug)
      {
        variableTypeDeclaration = lookupEntityName + " ";
      }

      var codeSnippet =
        new StringBuilder(variableTypeDeclaration + variableName + " = " +
                          "LookupDataObjectByBusinessKey(session, \n" +
                          "\"" + lookupEntityName + "\",\n" +
                          "propertyInstances \n" +
                          ") as " + lookupEntityName + ";");

      propertyInstanceCodeSnippet.Append("\n");
      propertyInstanceCodeSnippet.Append(codeSnippet);

      return propertyInstanceCodeSnippet.ToString();
    }

    public void TestBuildComputedPropertyCode(string entityName, 
                                              string computedPropertyName,
                                              string code, 
                                              List<string> referencedAssemblies)
    {
      // Clean temp dir
      string computedPropertyTempDir = Name.GetComputedPropertyTempDir(entityName);
      if (!Directory.Exists(computedPropertyTempDir))
      {
        Directory.CreateDirectory(computedPropertyTempDir);
      }
      else
      {
        Array.ForEach(Directory.GetFiles(computedPropertyTempDir), File.Delete);
      }

      CodeDomProvider codeProvider = CodeDomProvider.CreateProvider("CSharp");
      string output = Path.Combine(computedPropertyTempDir, Name.GetComputedPropertyAssemblyName(entityName));
      var parameters = new CompilerParameters();
      parameters.OutputAssembly = output;
      parameters.TempFiles = new TempFileCollection(computedPropertyTempDir, true);
      parameters.ReferencedAssemblies.Add(Path.Combine(SystemConfig.GetBinDir(), "MetraTech.Common.dll"));
      parameters.ReferencedAssemblies.Add(Path.Combine(SystemConfig.GetBinDir(), "MetraTech.Basic.dll"));
      parameters.ReferencedAssemblies.Add(Path.Combine(SystemConfig.GetBinDir(), "MetraTech.BusinessEntity.Core.dll"));
      parameters.ReferencedAssemblies.Add(Path.Combine(SystemConfig.GetBinDir(), "MetraTech.BusinessEntity.DataAccess.dll"));
      parameters.ReferencedAssemblies.Add(Path.Combine(SystemConfig.GetBinDir(), "NHibernate.dll"));

      // Add the entity and interface assembly for the specified entity
      string entityAssemblyName = Path.Combine(SystemConfig.GetBinDir(), Name.GetEntityAssemblyName(entityName) + ".dll");
      string interfaceAssemblyName = Path.Combine(SystemConfig.GetBinDir(), Name.GetInterfaceAssemblyName(entityName) + ".dll");
      Check.Require(File.Exists(entityAssemblyName), String.Format("Cannot find assembly '{0}'", entityAssemblyName));
      Check.Require(File.Exists(interfaceAssemblyName), String.Format("Cannot find assembly '{0}'", interfaceAssemblyName));

      parameters.ReferencedAssemblies.Add(entityAssemblyName);
      parameters.ReferencedAssemblies.Add(interfaceAssemblyName);

      if (referencedAssemblies != null)
      {
        foreach(string referencedAssembly in referencedAssemblies)
        {
          parameters.ReferencedAssemblies.Add(Path.Combine(SystemConfig.GetBinDir(), referencedAssembly));
        }
      }

      CompilerResults results = codeProvider.CompileAssemblyFromSource(parameters, code);
      
      if (results.Errors.Count > 0)
      {
        var errors = new List<ErrorObject>();
        // Display compilation errors.
        string message =
          String.Format("Errors building computed property '{0}' for entity '{1}' using source '{2}'",
                        computedPropertyName, entityName, code);

        logger.Error(message);
        foreach (CompilerError ce in results.Errors)
        {
          logger.Error(String.Format("{0}\n", ce));
          errors.Add(new ErrorObject(ce.ToString()));
        }

        throw new MetadataException(message, errors);
      }
      
      // Clean up directory
      Array.ForEach(Directory.GetFiles(computedPropertyTempDir), File.Delete);
    }
    #endregion

    public void ClearMetadataCache()
    {
      MetadataRepository.Instance.DeleteCacheFile();
    }

    public void SaveMetadata()
    {
      MetadataRepository.Instance.SaveGraph();
    }

    public List<RelatedEntity> GetRelatedEntities(string nameSpaceQualifiedTypeName)
    {
      List<RelatedEntity> relatedEntities = new List<RelatedEntity>();

      Entity entity = GetEntity(nameSpaceQualifiedTypeName);
      if (entity == null)
      {
        return relatedEntities;
      }

      foreach (Relationship relationship in entity.Relationships)
      {
        RelatedEntity relatedEntity = new RelatedEntity();
        relatedEntity.Entity = GetEntity(relationship.End2.EntityTypeName);

        Check.Ensure(relatedEntity.Entity != null,
                     String.Format("Cannot find related entity '{0}' for entity '{1}'",
                                   relationship.Target.EntityTypeName,
                                   nameSpaceQualifiedTypeName),
                     SystemConfig.CallerInfo);

        relatedEntity.Multiplicity = relationship.End2.Multiplicity;
        relatedEntity.PropertyName = relationship.End2.PropertyName;
        relatedEntities.Add(relatedEntity);
      }

      return relatedEntities;
    }

    public List<RelatedEntity> GetTargetEntities(string entityName)
    {
      return MetadataRepository.Instance.GetTargetEntities(entityName);
    }

    public RelationshipEntity CreateRelationship(RelationshipData relationshipData)
    {
      Check.Require(relationshipData.Source != null, "relationshipData.Source cannot be null");
      Check.Require(relationshipData.Target != null, "relationshipData.Target cannot be null");
      
      #region Validate the two entities

      List<ErrorObject> validationErrors;
      if (!relationshipData.Source.Validate(out validationErrors))
      {
        throw new MetadataException
          (String.Format("Failed to validate entity '{0}'", relationshipData.Source.FullName), validationErrors);
      }

      if (!relationshipData.Target.Validate(out validationErrors))
      {
        throw new MetadataException
          (String.Format("Failed to validate entity '{0}'", relationshipData.Target.FullName), validationErrors);
      }
      #endregion

      var relationshipEntity = new RelationshipEntity(relationshipData);

      //// Check that no cycles will be created because of this relationship
      //// Does not modify the graph
      //List<string> loopEdges;
      //if (MetadataRepository.Instance.CheckCycles(new List<RelationshipEntity>() {relationshipEntity}, out loopEdges))
      //{
      //  string message = String.Format("Cannot create a relationship between entity '{0}' and entity '{1}' " +
      //                                 "because it would create a cycle in the entity graph: '{2}'",
      //                                 relationshipData.Source.FullName,
      //                                 relationshipData.Target.FullName,
      //                                 String.Join(", ", loopEdges.ToArray()));

      //  throw new MetadataException(message);
      //}

      // Update the source and target
      relationshipData.Source.Relationships.Add(new Relationship(relationshipEntity, relationshipData.Source, relationshipData.Target, relationshipData.Source.FullName));
      relationshipData.Target.Relationships.Add(new Relationship(relationshipEntity, relationshipData.Source, relationshipData.Target, relationshipData.Target.FullName));

      return relationshipEntity;
    }

    public RelationshipEntity DeleteRelationship(ref Entity entity1, ref Entity entity2, string relationshipName)
    {
      Check.Require(entity1 != null, "entity1 cannot be null", SystemConfig.CallerInfo);
      Check.Require(entity2 != null, "entity2 cannot be null", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(relationshipName), "relationshipName cannot be null", SystemConfig.CallerInfo);

      string entity1Name = entity1.FullName;
      string entity2Name = entity2.FullName;

      Relationship relationship = entity1.Relationships.Find(r => r.End2.EntityTypeName == entity2Name &&
                                                                  r.RelationshipName == relationshipName);
      if (relationship == null)
      {
        logger.Warn(String.Format("Cannot find the relationship '{0}' between entity '{1}' and entity '{2}'.",
                                  relationshipName, entity1.FullName, entity2.FullName));

        return null;
      }

      entity1.Relationships.RemoveAll(r => r.End2.EntityTypeName == entity2Name);
      entity2.Relationships.RemoveAll(r => r.End2.EntityTypeName == entity1Name);

      return relationship.RelationshipEntity;
    }

    #endregion

    #region Public Properties
    public static MetadataAccess Instance
    {
      get
      {
        if (instance == null)
        {
          lock (syncRoot)
          {
            if (instance == null)
            {
              instance = new MetadataAccess();
            }
          }
        }

        return instance;
      }
    }

    internal TemplateProcessor TemplateProcessor { get; private set; }
    #endregion

    #region Public Methods

    public List<string> GetDatabaseNames()
    {
      return NHibernateConfig.GetDatabaseNames();
    }

    public Entity GetEntity(string entityName)
    {
      Entity entity = MetadataRepository.Instance.GetEntity(entityName);
      if (entity != null)
      {
        List<Entity> entities = GetEntitiesInternal(new List<Entity>() { entity });
        Check.Require(entities.Count == 1, String.Format("Error getting entity '{0}'", entityName));
        entity = entities[0];
      }

      return entity;
    }

    /// <summary>
    ///   Return the list of entities.
    /// </summary>
    /// <returns></returns>
    public List<Entity> GetEntities()
    {
      List<Entity> graphEntities = MetadataRepository.Instance.GetEntities(false);
      return GetEntitiesInternal(graphEntities);
    }

    public List<Entity> GetEntities(string extensionName)
    {
      List<Entity> graphEntities = MetadataRepository.Instance.GetEntities(extensionName, false);
      return GetEntitiesInternal(graphEntities);
    }

    public List<Entity> GetEntities(string extensionName, string entityGroupName)
    {
      List<Entity> graphEntities = MetadataRepository.Instance.GetEntities(extensionName, entityGroupName, false);
      return GetEntitiesInternal(graphEntities);
    }

    public List<Entity> GetRelationshipCandidates(Entity sourceEntity, List<Entity> currentEntities)
    {
      return MetadataRepository.Instance.GetRelationshipCandidates(sourceEntity, currentEntities);
    }
    
    public List<Entity> GetParentCandidates(Entity sourceEntity, List<Entity> currentEntities)
    {
      return MetadataRepository.Instance.GetParentCandidates(sourceEntity, currentEntities);
    }

    public IStandardRepository GetRepository()
    {
      return RepositoryAccess.Instance.GetRepository();
    }

    public List<IMetranetEntity> GetMetraNetEntities()
    {
      var metranetEntities = new List<IMetranetEntity>();

      foreach(MetraNetEntityConfig metraNetEntityConfig in BusinessEntityConfig.Instance.MetraNetEntityConfigs)
      {
        Check.Require(!String.IsNullOrEmpty(metraNetEntityConfig.TypeName),
                      "AssemblyQualifiedTypeName cannot be null or empty",
                      SystemConfig.CallerInfo);

        Type type = Type.GetType(metraNetEntityConfig.AssemblyQualifiedName, true);
        object metranetEntity = Activator.CreateInstance(type);

        Check.Ensure(metranetEntity != null, 
                     String.Format("Cannot create instance for metranet entity '{0}'", metraNetEntityConfig.TypeName),
                     SystemConfig.CallerInfo);
        
        Check.Ensure(metranetEntity is IMetranetEntity,
                     String.Format("Metranet entity '{0}' does not implement IMetranetEntity", metraNetEntityConfig.TypeName),
                     SystemConfig.CallerInfo);

        ((IMetranetEntity) metranetEntity).MetraNetEntityConfig = metraNetEntityConfig;
        metranetEntities.Add((IMetranetEntity)metranetEntity);
      }
      return metranetEntities;
    }

    public void AddMetranetEntityAssociation(ref Entity entity, IMetranetEntity metranetEntity, Multiplicity multiplicity)
    {
      Check.Require(entity != null, "entity cannot be null", SystemConfig.CallerInfo);
      entity.AddMetranetEntityAssociation(metranetEntity, multiplicity);
    }

    public void DeleteMetranetEntityAssociation(ref Entity entity, IMetranetEntity metranetEntity)
    {
      Check.Require(entity != null, "entity cannot be null", SystemConfig.CallerInfo);
      entity.DeleteMetranetEntityAssociation(metranetEntity);
    }


    public Dictionary<CRUDEvent, List<RuleData>> GetRuleData(string entityName)
    {
      return RuleConfig.GetRulesByEvent(entityName);
    }

    public void UpdateRuleData(string entityName,
                               string assemblyNameWithPath,
                               ref Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent)
    {
      RuleConfig.UpdateRuleData(entityName, assemblyNameWithPath, ref ruleDataByEvent);
    }

    public void SaveRuleData(string entityName,
                             Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent)
    {
      RuleConfig.SaveRuleData(entityName, ruleDataByEvent);
    }

    public void DeleteRuleData(string entityName,
                               string assemblyNameWithPath,
                               ref Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent)
    {
      RuleConfig.DeleteRuleData(entityName, assemblyNameWithPath, ref ruleDataByEvent);
    }

    public List<RuleData> RefreshRules(string entityName)
    {
      throw new NotImplementedException("RefreshRules has not been implemented");
      // var ruleDataList = new List<RuleData>();
      // return ruleDataList; 
    }

    public void ClearRules(string entityName)
    {
      RuleConfig.ClearRules(entityName);
    }

    public string GetComputationTypeName(string entityName, string propertyName, string assemblyNameWithPath)
    {
      return AppDomainHelper.GetComputationTypeName(entityName, propertyName, assemblyNameWithPath);
    }

    #endregion

    #region Internal Methods

    #endregion

    #region Private Methods

    private MetadataAccess()
    {
      ColumnMetadata = new Dictionary<string, List<DbColumnMetadata>>();

      LogLevel logLevel;
      string nhLogFileWithPath = BusinessEntityConfig.Instance.GetNHibernateLogFileWithPathAndLogLevel(out logLevel);
      Log4NetConfig.Configure(nhLogFileWithPath, logLevel);

      // Clean shadow copy dir only if we're in the main AppDomain
      if (!AppDomain.CurrentDomain.FriendlyName.StartsWith(AppDomainHelper.AppDomainNamePrefix))
      {
        logger.Debug(String.Format("Deleting files in shadow copy cache directory '{0}'",
                                 SystemConfig.GetShadowCopyCacheDir()));

        SystemConfig.CleanShadowCopyCacheDir();
      }
     
      RepositoryAccess.Instance.InitializeForSync();
      MetadataRepository.Instance.InitializeFromFileSystemWithEntitySyncData();
    }

    private List<Entity> GetEntitiesInternal(List<Entity> graphEntities)
    {
      var entities = new List<Entity>();

      foreach (Entity graphEntity in graphEntities)
      {
        Entity entity = graphEntity.Clone();
        
        foreach(Relationship relationship in graphEntity.Relationships)
        {
          entity.Relationships.Add(relationship.Clone());
        }

        entities.Add(entity);
      }

      return entities;
    }
    
    #endregion

    #region Private Properties
    private Dictionary<string, List<DbColumnMetadata>> ColumnMetadata { get; set; }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("MetadataAccess");
    private static MetadataAccess instance;
    private static readonly object syncRoot = new Object();
    // private MetadataRepository.Instance MetadataRepository.Instance;
    // private RepositoryAccess repositoryAccess;
    #endregion
  }
}
