using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Xml.Linq;
using System.Xml.Serialization;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Config;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using NHibernate.Cfg.MappingSchema;
using NHibernate.Util;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Sync
{
  public class SyncManager
  {
    #region Public Methods
    public SyncManager()
    {
      LockedFiles = new Dictionary<string, FileStream>();
      CapabilityEnumFile = SystemConfig.GetCapabilityEnumFileName();
      TempCapabilityEnumDir = Path.Combine(Path.GetDirectoryName(CapabilityEnumFile), "Temp");
      TempCapabilityEnumFile = Path.Combine(TempCapabilityEnumDir, Path.GetFileName(CapabilityEnumFile));
    }

    /// <summary>
    ///   - Validate 
    ///   - Build assemblies
    ///   - Update Schema
    ///   - Commit file changes
    /// </summary>
    /// <param name="syncData"></param>
    /// <param name="updateMetadataRepository"></param>
    public List<ErrorObject> Synchronize(SyncData syncData, bool updateMetadataRepository)
    {
      Check.Require(syncData != null, "syncData cannot be null", SystemConfig.CallerInfo);

      syncData.EntityGraph = MetadataRepository.Instance.GetEntityGraphClone();
      syncData.InheritanceGraph = MetadataRepository.Instance.GetInheritanceGraphClone();
      syncData.BuildGraph = MetadataRepository.Instance.GetBuildGraphClone();

      // Validate
      Validate(syncData);

      List<ExtensionData> extensionDataList = null;

      // Categorize entities in syncData according to their database
      List<SyncData> dbSyncDataList = SplitByDatabase(syncData);

      try
      {
        EntityGenerator.InheritanceGraph = syncData.InheritanceGraph;
        EntityGenerator.BuildGraph = syncData.BuildGraph;

        // Perform synchronization per database
        foreach (SyncData dbSyncData in dbSyncDataList)
        {
          BuildAssemblies(dbSyncData, out extensionDataList);

          UpdateSchema(dbSyncData, extensionDataList);

          CommitFileChanges(dbSyncData, extensionDataList);
 
          CleanEmptyDirectories(syncData, extensionDataList);

          // Update MetadataRepository
          if (updateMetadataRepository)
          {
            logger.Debug("Updating metadata repository");
            dbSyncData.UpdateMetadataRepository();
          }
        }
      }
      catch (System.Exception e)
      {
        logger.Error("Synchronization failed", e);

        UnlockFiles(extensionDataList);

        throw new SynchronizationException("Synchronization failed", e);
      }

      return syncData.Errors;
    }

    public void BuildAssemblies(bool overWriteHbm = false)
    {
      List<ExtensionData> extensionDataList = null;

      try
      {
        MetadataRepository.Instance.InitializeFromFileSystem();

        List<Entity> entities = MetadataRepository.Instance.GetEntities(true);
        var syncData = new SyncData(overWriteHbm);

        foreach (Entity entity in entities)
        {
          syncData.AddModifiedEntity(entity);
        }

        syncData.EntityGraph = MetadataRepository.Instance.GetEntityGraphClone();
        syncData.InheritanceGraph = MetadataRepository.Instance.GetInheritanceGraphClone();
        syncData.BuildGraph = MetadataRepository.Instance.GetBuildGraphClone();

        // Validate
        Validate(syncData);
        
        EntityGenerator.InheritanceGraph = syncData.InheritanceGraph;

        BuildAssemblies(syncData, out extensionDataList);

        CommitFileChanges(syncData, extensionDataList);
      }
      catch (System.Exception e)
      {
        logger.Error("Synchronization failed", e);

        UnlockFiles(extensionDataList);

        throw new SynchronizationException("Synchronization failed", e);
      }
    }

    public void MakeSubclass(string parentEntityName, string derivedEntityName)
    {
      Check.Require(!String.IsNullOrEmpty(parentEntityName), "parentEntityName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(derivedEntityName), "derivedEntityName cannot be null or empty");

      MetadataRepository.Instance.InitializeFromFileSystem();
      Entity parentEntity = MetadataRepository.Instance.GetEntity(parentEntityName);
      Check.Require(parentEntity != null, String.Format("Cannot find parent entity '{0}'", parentEntityName));

      Entity derivedEntity = MetadataRepository.Instance.GetEntity(derivedEntityName);
      Check.Require(derivedEntity != null, String.Format("Cannot find derived entity '{0}'", derivedEntityName));

      var inheritanceData = new InheritanceData() {DerivedEntity = derivedEntity, ParentEntity = parentEntity};
      var syncData = new SyncData();
      syncData.AddNewInheritance(inheritanceData);

      Synchronize(syncData, false);
    }

    /// <summary>
    /// 
    ///    Update or add the following for every BME hbm.xml in the specified extension.
    ///    <meta attribute="database">NetMeter</meta>
    /// 
    /// </summary>
    /// <param name="databaseName"></param>
    /// <param name="extensionName"></param>
    public void SetDatabaseName(string databaseName, string extensionName)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty");

      Check.Require(NHibernateConfig.IsBmeDatabase(databaseName), 
                    String.Format("Specified database '{0}' is not marked as a BME database in servers.xml", databaseName));

      string extensionDir = Path.Combine(SystemConfig.GetExtensionsDir(), extensionName);

      Check.Require(Directory.Exists(extensionDir), 
                    String.Format("Cannot find extension directory '{0}'", extensionDir));

      // Get the entity groups for the specified extensionName
      Dictionary<string, List<string>> entityGroupsByExtension =
        SystemConfig.GetEntityGroupsByExtension();

      List<string> entityGroups;
      entityGroupsByExtension.TryGetValue(extensionName.ToLower(), out entityGroups);
      if (entityGroups == null)
      {
        logger.Debug(String.Format("No entity groups found for extension '{0}'", extensionName));
        return;
      }

      XNamespace ns = "urn:nhibernate-mapping-2.2";

      foreach(string entityGroup in entityGroups)
      {
        // Get the hbm files
        List<string> hbmFiles = 
          MetadataRepository.GetHbmMappingFiles(extensionName, entityGroup);

        foreach(string hbmFile in hbmFiles)
        {
          if (!File.Exists(hbmFile))
          {
            logger.Debug(String.Format("Cannot find hbm file '{0}'", hbmFile));
            continue;
          }

          XElement root = XElement.Load(hbmFile);
          
          // Get the <class> element. Use LocalName to ignore namespace 
          var classElement = root.Element(ns + "class");
         
          if (classElement == null)
          {
            logger.Debug(String.Format("Cannot find <class> in hbm file '{0}'", hbmFile));
            continue;
          }

          // Get the <meta> elements
          IEnumerable<XElement> metaElements = classElement.Elements(ns + "meta"); //.First(e => e.Attribute("attribute").Value == "database");

          XElement dbElement = null;

          foreach (XElement element in metaElements)
          {
            if (element.Attribute("attribute") != null && element.Attribute("attribute").Value == "database")
            {
              dbElement = element;
              break;
            }
          }

          if (dbElement != null)
          {
            dbElement.Value = databaseName;
          }
          else
          {
            var attribute = new XAttribute("attribute", "database");
            dbElement = new XElement(ns + "meta", attribute);
            dbElement.Value = databaseName;
            classElement.AddFirst(dbElement);
          }

          // Save the file
          using (var writer = new StreamWriter(new FileStream(hbmFile, FileMode.Create), Encoding.UTF8))
          {
            root.Save(writer);
            writer.Flush();
          }
        }
      }
    }
    #endregion

    #region Public Static Methods

    public static void UpperCasePropertyNamesAndRemoveCreationDateUpdateDateUIDProperties(string extensionName)
    {
      Dictionary<string, List<string>> entityGroupsByExtension = SystemConfig.GetEntityGroupsByExtension();
      List<string> entityGroupNames;
      entityGroupsByExtension.TryGetValue(extensionName, out entityGroupNames);
      if (entityGroupNames == null || entityGroupNames.Count == 0)
      {
        Console.WriteLine(String.Format("No entity groups found in extension '{0}'", extensionName));
        return;
      }

      // File name to HbmMapping
      var hbmMappings = new Dictionary<string, HbmMapping>();
      // ClassName to HbmClass mapping
      var hbmClasses = new Dictionary<string, object>();

      foreach (string entityGroupName in entityGroupNames)
      {
        // Get the entity dir
        string entityDir = Name.GetEntityDir(extensionName, entityGroupName);
        if (!Directory.Exists(entityDir))
        {
          continue;
        }

        // Get the mapping files
        string[] hbmFiles = Directory.GetFiles(entityDir, "*.hbm.xml", SearchOption.TopDirectoryOnly);
        var xmlSerializer = new XmlSerializer(typeof(HbmMapping));

        foreach (string hbmFile in hbmFiles)
        {
          HbmMapping hbmMapping = Entity.GetHbmMapping(hbmFile);
          foreach (object item in hbmMapping.Items)
          {
            var hbmClass = item as HbmClass;
            var hbmJoinedSubclass = item as HbmJoinedSubclass;

            if (hbmClass == null && hbmJoinedSubclass == null)
            {
              continue;
            }

            if (hbmJoinedSubclass == null)
            {
              hbmClass.RemoveHbmProperty("creationdate");
              hbmClass.RemoveHbmProperty("updatedate");
              hbmClass.RemoveHbmProperty("uid");
            }
            else
            {
              hbmJoinedSubclass.RemoveHbmProperty("creationdate");
              hbmJoinedSubclass.RemoveHbmProperty("updatedate");
              hbmJoinedSubclass.RemoveHbmProperty("uid");
            }

            List<HbmProperty> hbmProperties =
              hbmJoinedSubclass == null ? hbmClass.GetHbmProperties() : hbmJoinedSubclass.GetHbmProperties();
            
            foreach(HbmProperty hbmProperty in hbmProperties)
            {
              hbmProperty.name = hbmProperty.name.UpperCaseFirst();
              if (hbmProperty.column.ToLower().StartsWith("c_"))
              {
                Char[] letters = hbmProperty.column.ToCharArray();
                letters[2] = Char.ToUpper(letters[2]);
                hbmProperty.column = new string(letters);
              }
            }
          }

          using (var writer = new StreamWriter(hbmFile))
          {
            xmlSerializer.Serialize(writer, hbmMapping);
          }
        }
      }
    }
    /// <summary>
    ///   Remove the use of join tables for one-to-one and one-to-many relationships
    /// </summary>
    /// <param name="extensionName"></param>
    public static void RemoveJoinTables(string extensionName)
    {
      Dictionary<string, List<string>> entityGroupsByExtension = SystemConfig.GetEntityGroupsByExtension();
      List<string> entityGroupNames;
      entityGroupsByExtension.TryGetValue(extensionName, out entityGroupNames);
      if (entityGroupNames == null || entityGroupNames.Count == 0)
      {
        Console.WriteLine(String.Format("No entity groups found in extension '{0}'", extensionName));
        return;
      }

      var filesToDelete = new List<string>();

      // File name to HbmMapping
      var hbmMappings = new Dictionary<string, HbmMapping>();
      // ClassName to HbmClass mapping
      var hbmClasses = new Dictionary<string, object>();
      // ClassName to HbmBag mapping
      var hbmBags = new Dictionary<string, List<HbmBag>>();

      #region Get HbmMapping's
      foreach (string entityGroupName in entityGroupNames)
      {
        // Get the entity dir
        string entityDir = Name.GetEntityDir(extensionName, entityGroupName);
        if (!Directory.Exists(entityDir))
        {
          continue;
        }

        // Get the mapping files
        string[] hbmFiles = Directory.GetFiles(entityDir, "*.hbm.xml", SearchOption.TopDirectoryOnly);

        foreach (string hbmFile in hbmFiles)
        {
          HbmMapping hbmMapping = Entity.GetHbmMapping(hbmFile);

          foreach (object item in hbmMapping.Items)
          {
            var hbmClass = item as HbmClass;
            var hbmJoinedSubclass = item as HbmJoinedSubclass;
            
            if (hbmClass == null && hbmJoinedSubclass == null)
            {
              continue;
            }

            string entityTypeValue =
              hbmJoinedSubclass == null
                ? hbmClass.GetMetadata(Entity.EntityTypeAttribute)
                : hbmJoinedSubclass.GetMetadata(Entity.EntityTypeAttribute);

            Check.Require(!String.IsNullOrEmpty(entityTypeValue), "Cannot find entity-type attribute in file '{0}'", hbmFile);
            var entityType = (EntityType)Enum.Parse(typeof(EntityType), entityTypeValue);

            if (entityType == EntityType.Relationship)
            {
              filesToDelete.Add(hbmFile);
            }
            else
            {
              hbmMappings.Add(hbmFile, hbmMapping);
            }

            string className =
              hbmJoinedSubclass == null
                ? hbmClass.name
                : hbmJoinedSubclass.name;

            AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(className);
            Check.Require(!String.IsNullOrEmpty(assemblyQualifiedTypeName.Type) &&
                          !String.IsNullOrEmpty(assemblyQualifiedTypeName.Assembly),
                          String.Format("Cannot parse assembly qualified name '{0}' in file '{1}'",
                                        className, hbmFile));

            if (hbmJoinedSubclass == null)
            {
              hbmClasses.Add(assemblyQualifiedTypeName.Type, hbmClass);
            }
            else
            {
              hbmClasses.Add(assemblyQualifiedTypeName.Type, hbmJoinedSubclass);
            }

            List<HbmBag> bags;
            hbmBags.TryGetValue(assemblyQualifiedTypeName.Type, out bags);
            if (bags == null)
            {
              bags = new List<HbmBag>();
              hbmBags.Add(assemblyQualifiedTypeName.Type, bags);
            }

            if (hbmJoinedSubclass == null)
            {
              bags.AddRange(hbmClass.GetHbmBags());
            }
            else
            {
              bags.AddRange(hbmJoinedSubclass.GetHbmBags());
            }

          }
        }
      }
      #endregion

      var relationshipInfoList = new List<HbmRelationshipData>();

      #region Setup RelationshipInfo

      HbmRelationshipData relationshipInfo = null;

      foreach (KeyValuePair<string, List<HbmBag>> kvp in hbmBags)
      {
        foreach (HbmBag hbmBag in kvp.Value)
        {
          if (!hbmBag.IsLegacy()) continue;

          // Get the source/target information from the join hbmClass
          string joinClassName = hbmBag.GetJoinClassName();
          Check.Require(!String.IsNullOrEmpty(joinClassName),
                        String.Format("Cannot find join class name for HbmBag for entity '{0}'", kvp.Key));

          object joinClass;
          hbmClasses.TryGetValue(joinClassName, out joinClass);
          Check.Require(joinClass != null,
                        String.Format("Cannot find join class '{0}' specified on entity '{1}'", joinClassName, kvp.Key));

          // entity type
          string entityTypeValue = ((HbmClass)joinClass).GetMetadata(Entity.EntityTypeAttribute);
          Check.Require(!String.IsNullOrEmpty(entityTypeValue),
                        String.Format("Cannot find entity-type attribute value on '{0}'", joinClassName));
          var entityType = (EntityType)Enum.Parse(typeof(EntityType), entityTypeValue);

          #region Handle self relationships
          if (entityType == EntityType.SelfRelationship)
          {
            relationshipInfo = relationshipInfoList.Find(r => r.SelfRelationshipEntityName == kvp.Key);
            if (relationshipInfo != null)
            {
              continue;
            }

            // Get the hbmClass
            object hbmClass;
            hbmClasses.TryGetValue(kvp.Key, out hbmClass);
            Check.Require(hbmClass != null, String.Format("Cannot find entity '{0}'", kvp.Key));
            List<HbmBag> selfRelationshipHbmBags = ((HbmClass)hbmClass).GetSelfRelationshipHbmBags(joinClassName);
            Check.Require(selfRelationshipHbmBags.Count == 2,
                          String.Format("Expected to find two HbmBags for entity '{0}' with self relationship", kvp.Key));

            relationshipInfo =
              new HbmRelationshipData()
              {
                IsSelfRelationship = true,
                SelfRelationshipEntityName = kvp.Key,
                SelfRelationshipHbmBags = selfRelationshipHbmBags,
                OriginalJoinClassName = joinClassName
              };

            relationshipInfoList.Add(relationshipInfo);
            continue;
          }
          #endregion

          // source entity name
          string sourceEntityName =
            joinClass is HbmClass
              ? ((HbmClass) joinClass).GetMetadata(RelationshipEntity.SourceEntityNameAttribute)
              : ((HbmJoinedSubclass) joinClass).GetMetadata(RelationshipEntity.SourceEntityNameAttribute);

          Check.Require(!String.IsNullOrEmpty(sourceEntityName),
                        String.Format("Cannot find source-entity-name attribute value on '{0}'", joinClassName));

          // target entity name
          string targetEntityName =
            joinClass is HbmClass
              ? ((HbmClass)joinClass).GetMetadata(RelationshipEntity.TargetEntityNameAttribute)
              : ((HbmJoinedSubclass)joinClass).GetMetadata(RelationshipEntity.TargetEntityNameAttribute);
            
          Check.Require(!String.IsNullOrEmpty(targetEntityName),
                        String.Format("Cannot find target-entity-name attribute value on '{0}'", joinClassName));

          // Nothing to do if we've seen this relationship before
          relationshipInfo = relationshipInfoList.Find(r => r.SourceEntityName == sourceEntityName &&
                                                            r.TargetEntityName == targetEntityName);
          if (relationshipInfo != null)
          {
            continue;
          }

          // relationshipType
          string relationshipTypeValue =
            joinClass is HbmClass
              ? ((HbmClass)joinClass).GetMetadata(RelationshipEntity.RelationshipTypeAttribute)
              : ((HbmJoinedSubclass)joinClass).GetMetadata(RelationshipEntity.RelationshipTypeAttribute);
            
          Check.Require(!String.IsNullOrEmpty(relationshipTypeValue),
                        String.Format("Cannot find relationship-type attribute value on '{0}'", joinClassName));

          var relationshipType = (RelationshipType)Enum.Parse(typeof(RelationshipType), relationshipTypeValue);

          // Cascade
          string cascadeValue =
            joinClass is HbmClass
              ? ((HbmClass)joinClass).GetMetadata(RelationshipEntity.CascadeAttribute)
              : ((HbmJoinedSubclass)joinClass).GetMetadata(RelationshipEntity.CascadeAttribute);
            
          Check.Require(!String.IsNullOrEmpty(cascadeValue),
                        String.Format("Cannot find cascade attribute value on '{0}'", joinClassName));

          var cascade = Convert.ToBoolean(cascadeValue);

          // SourcePropertyNameForTarget
          string sourcePropertyNameForTarget =
            joinClass is HbmClass
              ? ((HbmClass)joinClass).GetMetadata(RelationshipEntity.SourcePropertyNameForTargetAttribute)
              : ((HbmJoinedSubclass)joinClass).GetMetadata(RelationshipEntity.SourcePropertyNameForTargetAttribute);
            
          Check.Require(!String.IsNullOrEmpty(sourcePropertyNameForTarget),
                        String.Format("Cannot find source-property-name-for-target attribute value on '{0}'", joinClassName));

          // TargetPropertyNameForSource
          string targetPropertyNameForSource =
            joinClass is HbmClass
              ? ((HbmClass)joinClass).GetMetadata(RelationshipEntity.TargetPropertyNameForSourceAttribute)
              : ((HbmJoinedSubclass)joinClass).GetMetadata(RelationshipEntity.TargetPropertyNameForSourceAttribute);
            
          Check.Require(!String.IsNullOrEmpty(targetPropertyNameForSource),
                        String.Format("Cannot find target-property-name-for-source attribute value on '{0}'", joinClassName));

          // SourceKeyColumn
          string sourceKeyColumn =
            joinClass is HbmClass
              ? ((HbmClass)joinClass).GetMetadata(RelationshipEntity.SourceKeyColumnNameAttribute)
              : ((HbmJoinedSubclass)joinClass).GetMetadata(RelationshipEntity.SourceKeyColumnNameAttribute);
           
          Check.Require(!String.IsNullOrEmpty(sourceKeyColumn),
                        String.Format("Cannot find source-key-column attribute value on '{0}'", joinClassName));

          // TargetKeyColumn
          string targetKeyColumn =
            joinClass is HbmClass
              ? ((HbmClass)joinClass).GetMetadata(RelationshipEntity.TargetKeyColumnNameAttribute)
              : ((HbmJoinedSubclass)joinClass).GetMetadata(RelationshipEntity.TargetKeyColumnNameAttribute);
           
           Check.Require(!String.IsNullOrEmpty(targetKeyColumn),
                        String.Format("Cannot find target-key-column attribute value on '{0}'", joinClassName));


          HbmBag sourceHbmBag = null, targetHbmBag = null;
          object sourceHbmClass = null, targetHbmClass = null;

          if (kvp.Key == sourceEntityName)
          {
            hbmClasses.TryGetValue(sourceEntityName, out sourceHbmClass);
            Check.Require(sourceHbmClass != null, String.Format("Cannot find source entity '{0}'", sourceEntityName));

            sourceHbmBag = hbmBag;
            hbmClasses.TryGetValue(targetEntityName, out targetHbmClass);
            Check.Require(targetHbmClass != null, String.Format("Cannot find target entity '{0}'", targetEntityName));
            targetHbmBag =
              targetHbmClass is HbmClass
              ? ((HbmClass)targetHbmClass).GetHbmBag(joinClassName)
              : ((HbmJoinedSubclass)targetHbmClass).GetHbmBag(joinClassName);
           
             
            Check.Require(targetHbmBag != null,
                          String.Format("Cannot find hbmBag for join class '{0}' on target entity '{1}'",
                                        joinClassName, targetEntityName));
          }
          else if (kvp.Key == targetEntityName)
          {
            hbmClasses.TryGetValue(targetEntityName, out targetHbmClass);
            Check.Require(targetHbmClass != null, String.Format("Cannot find target entity '{0}'", targetEntityName));

            targetHbmBag = hbmBag;
            hbmClasses.TryGetValue(sourceEntityName, out sourceHbmClass);
            Check.Require(sourceHbmClass != null, String.Format("Cannot find source entity '{0}'", sourceEntityName));
            sourceHbmBag =
              sourceHbmClass is HbmClass
              ? ((HbmClass)sourceHbmClass).GetHbmBag(joinClassName)
              : ((HbmJoinedSubclass)sourceHbmClass).GetHbmBag(joinClassName);
              
            Check.Require(sourceHbmBag != null,
                          String.Format("Cannot find hbmBag for join class '{0}' on source entity '{1}'",
                                        joinClassName, sourceEntityName));
          }
          else
          {
            throw new MetadataException(String.Format("Cannot match entity '{0}' to source or target", kvp.Key));
          }

          relationshipInfo =
            new HbmRelationshipData()
            {
              RelationshipType = relationshipType,
              Cascade = cascade,
              SourceEntityName = sourceEntityName,
              SourceHbmBag = sourceHbmBag,
              SourceKeyColumn = sourceKeyColumn,
              SourcePropertyNameForTarget = sourcePropertyNameForTarget,

              TargetEntityName = targetEntityName,
              TargetHbmBag = targetHbmBag,
              TargetKeyColumn = targetKeyColumn,
              TargetPropertyNameForSource = targetPropertyNameForSource,

              OriginalJoinClassName = joinClassName
            };

          if (sourceHbmClass is HbmClass)
          {
            relationshipInfo.SourceHbmClass = sourceHbmClass as HbmClass;
          }
          else
          {
            relationshipInfo.SourceHbmJoinedSubclass = sourceHbmClass as HbmJoinedSubclass;
          }

          if (targetHbmClass is HbmClass)
          {
            relationshipInfo.TargetHbmClass = targetHbmClass as HbmClass;
          }
          else
          {
            relationshipInfo.TargetHbmJoinedSubclass = targetHbmClass as HbmJoinedSubclass;
          }

          relationshipInfoList.Add(relationshipInfo);
        }
      }

      #endregion

      #region Modify Relationships
      foreach (HbmRelationshipData relinfo in relationshipInfoList)
      {
        if (relinfo.IsSelfRelationship)
        {
          // Nothing to do for SelfRelationships, for now
        }
        else
        {
          if (relinfo.RelationshipType == RelationshipType.OneToMany)
          {
            // TODO: Attributes on source and target

            // Change source
            // <bag name="Children" inverse="true" lazy="true">
            //   <key column="parent_id"/>
            //   <one-to-many class="Child"/>
            // </bag>
            relinfo.SourceHbmBag.name = relinfo.SourcePropertyNameForTarget;
            relinfo.SourceHbmBag.inverse = true;
            relinfo.SourceHbmBag.lazy = HbmCollectionLazy.True;
            relinfo.SourceHbmBag.lazySpecified = true;
            relinfo.SourceHbmBag.cascade = relinfo.Cascade ? "delete" : "none";

            // <key>
            relinfo.SourceHbmBag.key = new HbmKey();
            relinfo.SourceHbmBag.key.column1 = relinfo.SourceKeyColumn;
            relinfo.SourceHbmBag.access = "field.camelcase-underscore";

            // <one-to-many>
            relinfo.SourceHbmBag.Item = new HbmOneToMany();
            ((HbmOneToMany) relinfo.SourceHbmBag.Item).@class =
              relinfo.TargetHbmJoinedSubclass == null
                ? relinfo.TargetHbmClass.name
                : relinfo.TargetHbmJoinedSubclass.name;

            // Remove the old attribute
            relinfo.SourceHbmBag.RemoveAttribute("target-entity");

            // Add attributes
            SetRelationshipAttributes(relinfo.SourceHbmBag, relinfo, typeof(HbmBagExtension));

            // Change target
            // Delete the HbmBag on target
            if (relinfo.TargetHbmJoinedSubclass == null)
            {
              relinfo.TargetHbmClass.DeleteHbmBag(relinfo.OriginalJoinClassName);
            }
            else
            {
              relinfo.TargetHbmJoinedSubclass.DeleteHbmBag(relinfo.OriginalJoinClassName);
            }

            // <many-to-one name="parent" class="Parent" column="parent_id"/>
            var manyToOne = new HbmManyToOne();
            manyToOne.name = relinfo.TargetPropertyNameForSource;
            manyToOne.column = relinfo.SourceKeyColumn;
            manyToOne.unique = false;

            if (relinfo.SourceHbmJoinedSubclass == null)
            {
              manyToOne.@class = relinfo.SourceHbmClass.name;
            }
            else
            {
              manyToOne.@class = relinfo.SourceHbmJoinedSubclass.name; 
            }

            if (relinfo.TargetHbmJoinedSubclass == null)
            {
              relinfo.TargetHbmClass.AddItem(manyToOne);
            }
            else
            {
              relinfo.TargetHbmJoinedSubclass.AddItem(manyToOne);
            }

            // Add attributes
            SetRelationshipAttributes(manyToOne, relinfo, typeof(HbmManyToOneExtension));
          }
          else
          {
            // One to One 

            // Change Source
            // Remove Bag 
            relinfo.SourceHbmClass.DeleteHbmBag(relinfo.OriginalJoinClassName);

            // Add
            // <one-to-one name="Employee" class="Employee"/>
            var oneToOne = new HbmOneToOne();
            oneToOne.name = relinfo.SourcePropertyNameForTarget;
            oneToOne.cascade = relinfo.Cascade ? "delete" : "none";

            if (relinfo.TargetHbmJoinedSubclass == null)
            {
              oneToOne.@class = relinfo.TargetHbmClass.name;
            }
            else
            {
              oneToOne.@class = relinfo.TargetHbmJoinedSubclass.name;
            }

            if (relinfo.SourceHbmJoinedSubclass == null)
            {
              
              relinfo.SourceHbmClass.AddItem(oneToOne);
            }
            else
            {
              
              relinfo.SourceHbmJoinedSubclass.AddItem(oneToOne);
            }

            // Add attributes
            SetRelationshipAttributes(oneToOne, relinfo, typeof(HbmOneToOneExtension));


            // Change Target
            // Remove Bag
            if (relinfo.TargetHbmJoinedSubclass == null)
            {
              relinfo.TargetHbmClass.DeleteHbmBag(relinfo.OriginalJoinClassName);
            }
            else
            {
              relinfo.TargetHbmJoinedSubclass.DeleteHbmBag(relinfo.OriginalJoinClassName);
            }

            // Add
            // <many-to-one name="Person" unique="true" column="Person"/>
            var manyToOne = new HbmManyToOne();
            manyToOne.name = relinfo.TargetPropertyNameForSource;
            
            manyToOne.unique = true;
            manyToOne.column = relinfo.SourceKeyColumn;

            if (relinfo.SourceHbmJoinedSubclass == null)
            {
              oneToOne.@class = relinfo.SourceHbmClass.name;
            }
            else
            {
              oneToOne.@class = relinfo.SourceHbmJoinedSubclass.name;
            }

            if (relinfo.TargetHbmJoinedSubclass == null)
            {
              relinfo.TargetHbmClass.AddItem(manyToOne);
            }
            else
            {
              relinfo.TargetHbmJoinedSubclass.AddItem(manyToOne);
            }

            // Add attributes
            SetRelationshipAttributes(manyToOne, relinfo, typeof(HbmManyToOneExtension));
          }
        }
      }
      #endregion

      #region Write HbmMapping
      var xmlSerializer = new XmlSerializer(typeof(HbmMapping));
      foreach (KeyValuePair<string, HbmMapping> kvp in hbmMappings)
      {
        using (var writer = new StreamWriter(kvp.Key))
        {
          xmlSerializer.Serialize(writer, kvp.Value);
        }
      }
      #endregion

      #region Delete Join Class Hbm Files
      foreach(string hbmFile in filesToDelete)
      {
        File.Delete(hbmFile);
        string csFile = hbmFile.ToLower().Replace(".hbm.xml", ".cs");
        if (File.Exists(csFile))
        {
          File.Delete(csFile);
        }
      }
      #endregion
    }
    #endregion

    #region Private Methods

    /// <summary>
    ///   Pre-requisite: The EntityGraph on MetadataRepository has been initialized.
    /// </summary>
    /// <param name="syncData"></param>
    private void Validate(SyncData syncData)
    {
      List<ErrorObject> errors;

      #region New Entities
      //      - Validate the entity
      //      - Check that the entity does not exist in the graph
      List<Entity> newEntities = syncData.GetEntities(ChangeType.New, EntityType.Entity | EntityType.Compound);

      foreach (Entity entity in newEntities)
      {
        // Validate
        if (!entity.Validate(out errors))
        {
          string message = String.Format("Failed to validate entity '{0}'", entity.FullName);
          throw new SynchronizationException(message, errors, SystemConfig.CallerInfo);
        }

        Entity currentEntity = syncData.EntityGraph.GetEntity(entity.FullName);
        Check.Require(currentEntity == null, String.Format("Entity '{0}' incorrectly specified as a new entity even though it already exists", entity.FullName));

        // Create a HistoryEntity, if necessary
        if (entity.RecordHistory)
        {
          syncData.AddHistoryEntity(entity.CreateHistoryEntity());
        }

        // Create the SelfRelationshipEntity, if necessary
        //if (entity.HasSelfRelationship)
        //{
        //  syncData.NewEntities.Add(entity.CreateSelfRelationshipEntity());
        //}

        // Add the entity to the EntityGraph
        syncData.EntityGraph.AddEntity(entity);
        // Add the entity to the BuildGraph
        syncData.BuildGraph.AddAssemblyNode(entity);
      }

      #endregion

      #region Deleted Entities
      //      - If the entity is present in the MetadataRepository, make sure that each 
      //        of the relationships that this entity participates in is present in 
      //        syncData.DeletedRelationships
      List<Entity> deletedEntities = syncData.GetEntities(ChangeType.Deleted, EntityType.Entity | EntityType.Compound);
      foreach (Entity entity in deletedEntities)
      {
        // Validate
        if (!entity.Validate(out errors))
        {
          string message = String.Format("Failed to validate entity '{0}'", entity.FullName);
          throw new SynchronizationException(message, errors, SystemConfig.CallerInfo);
        }

        // Get the current relationships
        List<RelationshipEntity> currentRelationships =
          syncData.EntityGraph.GetRelationshipEntities(entity.FullName);

        // Add the deleted relationships if necessary
        foreach (RelationshipEntity relationshipEntity in currentRelationships)
        {
          if (!syncData.HasDeletedRelationship(relationshipEntity.FullName))
          {
            syncData.DeletedEntities.Add(relationshipEntity);
          }
        }

        // Add history entity to deleted entities, if necessary
        if (entity.RecordHistory &&
            entity.HistoryEntity != null &&
            !syncData.DeletedEntities.Contains(entity.HistoryEntity))
        {
          syncData.DeletedEntities.Add(entity.HistoryEntity);
        }

        // Add self relationship entity to deleted entities, if necessary
        //if (entity.HasSelfRelationship &&
        //    entity.SelfRelationshipEntity != null &&
        //    !syncData.DeletedEntities.Contains(entity.SelfRelationshipEntity))
        //{
        //  syncData.DeletedEntities.Add(entity.SelfRelationshipEntity);
        //}

        // Remove this entity from the EntityGraph
        // syncData.EntityGraph.DeleteEntity(entity.FullName);
      }

      #endregion

      #region Modified Entities
      //      - Check that the entity exists in the MetadataRepository
      //      - Validate the entity
      //         - If the data type for a property has changed, check that the change is legal
      //           [this check is not necessary, if there is no data for the entity]
      //         - Check if history is being created, deleted or modified
      //         - Check if self-relationship is being created or deleted

      syncData.EntityChangeSetList.Clear();
      List<Entity> modifiedEntitiesAndRelationships =
        syncData.GetEntities(ChangeType.Modified, EntityType.Entity | EntityType.Compound | EntityType.Relationship);

      foreach (Entity entity in modifiedEntitiesAndRelationships)
      {
        // Validate
        if (!entity.Validate(out errors))
        {
          string message = String.Format("Failed to validate entity '{0}'", entity.FullName);
          throw new SynchronizationException(message, errors, SystemConfig.CallerInfo);
        }

        Entity originalEntity = syncData.EntityGraph.GetEntity(entity.FullName);
        Check.Require(originalEntity != null, String.Format("Entity '{0}' is specified as a modified entity but is not found in the metadata repository", entity.FullName));

        #region Handle history
        // Determine if history is being created
        if (!originalEntity.RecordHistory && entity.RecordHistory)
        {
          entity.CreateHistoryEntity();
          Check.Require(!syncData.NewEntities.Contains(entity.HistoryEntity),
                        String.Format("Unexpected history entity '{0}' found in SyncData", entity.HistoryEntity));
          syncData.AddHistoryEntity(entity.HistoryEntity);
        }
        // Determine if history is being dropped
        else if (originalEntity.RecordHistory && !entity.RecordHistory)
        {
          Check.Require(entity.HistoryEntity != null, String.Format("Cannot find history entity for entity '{0}'", entity));
          if (!syncData.DeletedEntities.Contains(entity.HistoryEntity))
          {
            syncData.DeletedEntities.Add(entity.HistoryEntity);
          }
        }
        else if (entity.RecordHistory)
        {
          Check.Require(entity.HistoryEntity != null, String.Format("Cannot find history entity for entity '{0}'", entity));

          // Refresh history
          entity.HistoryEntity.Refresh(entity);

          Check.Require(!syncData.ModifiedEntities.Contains(entity.HistoryEntity),
                        String.Format("Found unexpected history entity '{0}' in sync data", entity.HistoryEntity));
          syncData.ModifiedEntities.Add(entity.HistoryEntity);

        }
        #endregion

        #region Handle Self Relationship
        //// Determine if self relationship is being created
        //if (!originalEntity.HasSelfRelationship && entity.HasSelfRelationship)
        //{
        //  entity.CreateSelfRelationshipEntity();
        //  Check.Require(!syncData.NewEntities.Contains(entity.SelfRelationshipEntity),
        //                String.Format("Unexpected self relationship entity '{0}' found in SyncData", entity.SelfRelationshipEntity));
        //  syncData.NewEntities.Add(entity.SelfRelationshipEntity);
        //}
        //// Determine if self relationship is being dropped
        //else if (originalEntity.HasSelfRelationship && !entity.HasSelfRelationship)
        //{
        //  Check.Require(entity.SelfRelationshipEntity != null, String.Format("Cannot find self relationship entity for entity '{0}'", entity));
        //  if (!syncData.DeletedEntities.Contains(entity.SelfRelationshipEntity))
        //  {
        //    syncData.DeletedEntities.Add(entity.SelfRelationshipEntity);
        //  }
        //}
        //else if (entity.HasSelfRelationship)
        //{
        //  Check.Require(entity.SelfRelationshipEntity != null,
        //                String.Format("Cannot find self relationship entity for entity '{0}'", entity));

        //  if (!syncData.ModifiedEntities.Contains(entity.SelfRelationshipEntity))
        //  {
        //    syncData.ModifiedEntities.Add(entity.SelfRelationshipEntity);
        //  }
        //}
        #endregion
      }

      // For each modified entity, add its relationships (RelationshipEntity) to the list
      // of modified entities, if the relationship has not been marked for deletion. 
      // Otherwise, the interface build will fail because it won't find the definition for the relationships
      List<Entity> modifiedEntities = syncData.GetEntities(ChangeType.Modified, EntityType.Entity | EntityType.Compound);
      foreach (Entity entity in modifiedEntities)
      {
        foreach (Relationship relationship in entity.Relationships)
        {
          var relationshipEntity =
            syncData.EntityGraph.GetEntity(relationship.RelationshipEntity.FullName) as RelationshipEntity;

          if (relationshipEntity != null &&
              !syncData.ModifiedEntities.Contains(relationshipEntity) &&
              !syncData.DeletedEntities.Contains(relationshipEntity) &&
              relationshipEntity.HasJoinTable)
          {
            syncData.ModifiedEntities.Add(relationshipEntity);
          }
        }
      }
      #endregion

      #region Deleted Relationships
      List<Entity> deletedRelationships = syncData.GetEntities(ChangeType.Deleted, EntityType.Relationship);
      foreach (RelationshipEntity relationshipEntity in deletedRelationships)
      {
        // Validate
        if (!relationshipEntity.Validate(out errors))
        {
          string message = String.Format("Failed to validate relationship entity '{0}'", relationshipEntity.FullName);
          throw new SynchronizationException(message, errors, SystemConfig.CallerInfo);
        }

        // Delete the relationship from the graph
        // syncData.EntityGraph.DeleteRelationship(relationshipEntity);
      }
      #endregion

      #region New Relationships
      // - Validate the relationship
      // - If this relationship is found in the graph, then move it to the ModifiedRelationships collection

      // - Check that the entity on each end is either new (i.e. is a member of syncData.NewEntities) 
      //   or exists in the MetadataRepository 
      // - Check that the entities on the two ends are in the same database
      // - Check that the relationship does not cause a cycle

      List<Entity> newRelationships = syncData.GetEntities(ChangeType.New, EntityType.Relationship);
      var existingRelationships = new List<Entity>();
      foreach (RelationshipEntity relationshipEntity in newRelationships)
      {
        // Validate
        if (!relationshipEntity.Validate(out errors))
        {
          string message = String.Format("Failed to validate relationship entity '{0}'", relationshipEntity.FullName);
          throw new SynchronizationException(message, errors, SystemConfig.CallerInfo);
        }

        if (syncData.EntityGraph.HasRelationship(relationshipEntity.FullName))
        {
          existingRelationships.Add(relationshipEntity);
          continue;
        }

        Entity source = syncData.EntityGraph.GetEntity(relationshipEntity.SourceEntityName);
        if (source == null)
        {
          throw new SynchronizationException(String.Format("Source entity '{0}' specified in relationship '{1}' cannot be found",
                                                           relationshipEntity.SourceEntityName, relationshipEntity));
        }

        Entity target = syncData.EntityGraph.GetEntity(relationshipEntity.TargetEntityName);
        if (target == null)
        {
          throw new SynchronizationException(String.Format("Target entity '{0}' specified in relationship '{1}' cannot be found",
                                                           relationshipEntity.TargetEntityName, relationshipEntity));
        }

        // Check that source and target are in the same database
        Check.Require(source.DatabaseName.ToLower() == target.DatabaseName.ToLower(),
                      String.Format("The database '{0}' for the source entity '{1}' does not match the database '{2}' for the target entity '{3}'",
                                     source.DatabaseName, source.FullName, target.DatabaseName, target.FullName));

        // Check that this relationship has not been specified in DeletedRelationships
        Check.Require(!syncData.HasDeletedRelationship(relationshipEntity.FullName),
                      String.Format("Relationship '{0}' has already been added to the delete list", relationshipEntity));
      }

      // Remove the relationships that are modified from NewRelationships
      syncData.RemoveFromNewEntities(existingRelationships);

      // Add the new relationships to the graph
      syncData.AddNewRelationshipsToGraph();

      // Check that we haven't created a cycle in the graph
      List<string> loopEdges;
      if (syncData.EntityGraph.HasCycle(out loopEdges))
      {
        string message = String.Format("Adding the new relationships causes the following cycle in the entity graph. '{0}'",
                                       String.Join(", ", loopEdges.ToArray()));

        throw new MetadataException(message);
      }

      #endregion

      #region New Inheritances
      foreach(InheritanceData inheritanceData in syncData.NewInheritances)
      {
        // DerivedEntity cannot be a subclass - would imply multiple inheritance
        Check.Require(inheritanceData.DerivedEntity.EntityType != EntityType.Derived,
                      String.Format("Derived entity '{0}' cannot be a subclass", inheritanceData.DerivedEntity));

        // If DerivedEntity is a member of a hierarchy and ParentEntity is a member of a hierarchy
        // then validate that the two hierarchies do not have any common entities
        Check.Require
          (syncData.InheritanceGraph.AreMembersOfDisconnectedHierarchies
            (inheritanceData.DerivedEntity.FullName, inheritanceData.ParentEntity.FullName),
           String.Format("Derived entity '{0}' and parent entity '{1}' are members of hierarchies that have overlapping entities",
                          inheritanceData.DerivedEntity, inheritanceData.ParentEntity));

        // DerivedEntity cannot have any property names in common with the hierarchy
        // starting at ParentEntity
        Dictionary<string, string> duplicatePropertyNames =
          syncData.InheritanceGraph.GetDuplicatePropertyNames(inheritanceData.DerivedEntity,
                                                              inheritanceData.ParentEntity);

        if (duplicatePropertyNames.Count > 0)
        {
          throw new MetadataException
            (String.Format("The following property names are common between the derived entity '{0}'" +
                           "and the parent entity '{1}' or its ancestors: '{2}'",
                            inheritanceData.DerivedEntity.FullName,
                            inheritanceData.ParentEntity.FullName,
                            StringUtil.Join(" , ", duplicatePropertyNames, 
                                            kvp => kvp.Value /* entity name */ + "::" + 
                                            kvp.Key /* property name */)));
        }

        // DerivedEntity cannot have a relationship with ParentEntity
        if (inheritanceData.DerivedEntity.HasRelationshipWith(inheritanceData.ParentEntity.FullName))
        {
          throw new MetadataException
            (String.Format("Derived entity '{0}' cannot have a relationship with the parent entity '{1}'",
                            inheritanceData.DerivedEntity, inheritanceData.ParentEntity));
        }

        // If ParentEntity is new, add it to NewEntities
        if (!syncData.EntityGraph.HasEntity(inheritanceData.ParentEntity.FullName))
        {
          if (!syncData.NewEntities.Contains(inheritanceData.ParentEntity))
          {
            syncData.NewEntities.Add(inheritanceData.ParentEntity);
            syncData.BuildGraph.AddAssemblyNode(inheritanceData.ParentEntity);
          }
        }

        // Update DerivedEntity
        inheritanceData.DerivedEntity.EntityType = EntityType.Derived;
        inheritanceData.DerivedEntity.ParentEntityName = inheritanceData.ParentEntity.FullName;
        
        // Add the inheritance to the InheritanceGraph. This will check for cycles.
        syncData.InheritanceGraph.AddInheritance(inheritanceData.ParentEntity, inheritanceData.DerivedEntity);

        // If DerivedEntity is new, add it to NewEntities otherwise add it to ModifiedEntities
        if (!syncData.EntityGraph.HasEntity(inheritanceData.DerivedEntity.FullName))
        {
          if (!syncData.NewEntities.Contains(inheritanceData.DerivedEntity))
          {
            syncData.NewEntities.Add(inheritanceData.DerivedEntity);
            syncData.BuildGraph.AddAssemblyNode(inheritanceData.DerivedEntity);

          }
        }
        else
        {
          if (!syncData.ModifiedEntities.Contains(inheritanceData.DerivedEntity))
          {
            syncData.ModifiedEntities.Add(inheritanceData.DerivedEntity);
          }
        }

        // If the parent and derived are in different assemblies, add a dependency to the build graph
        syncData.BuildGraph.AddDependency(inheritanceData.DerivedEntity.FullName, inheritanceData.ParentEntity.FullName);

      }

      // Fixup root
      syncData.InheritanceGraph.FixupRoot();

      #endregion

      // (6) New Computed Properties:
      // (7) Deleted Computed Properties:
      // (8) New Rules:
      // (9) Deleted Rules:
    }

    private void BuildAssemblies(SyncData syncData, out List<ExtensionData> extensionDataList)
    {
      // Organize the items in syncData by extension and entity groups
       List<EntityGroupData> entityGroups = syncData.GetEntityGroupData();
      entityGroups.ForEach(e => e.SetBuildStatus());

      // Order the entity groups by build dependency
      syncData.BuildGraph.SortByBuildDependency(ref entityGroups);

      // Categorize by ExtensionData
      extensionDataList = ExtensionData.GroupByExtension(entityGroups);

      // Copy to Temp and Lock files
      logger.Debug("Copying files to temporary location and locking necessary files");
      foreach (ExtensionData extensionData in extensionDataList)
      {
        extensionData.CopyToTempAndLockOutputFiles();
      }

      // Create capability enums (if necessary) and update syncData with the new enum entries
      LockUpdateAndBackupCapabilityEnumFile(extensionDataList, ref syncData);

      // Build
      foreach (ExtensionData extensionData in extensionDataList)
      {
         extensionData.Build();
      }
    }

    private void UpdateSchema(SyncData syncData, List<ExtensionData> extensionDataList)
    {
      // Setup data for the schema update
      syncData.PrepareForSchemaUpdate(extensionDataList);

      // Update schema
      RepositoryAccess.Instance.UpdateSchema(syncData);
    }

    private void CommitFileChanges(SyncData syncData, 
                                   List<ExtensionData> extensionDataList)
    {
      // Commit changes
      logger.Debug("Committing changes to file system");
      foreach (ExtensionData extensionData in extensionDataList)
      {
        extensionData.Commit();
      }

      // Unlock and restore the capability enum file
      UnlockAndCopyCapabilityEnumFile();
    }

    private void UnlockFiles(List<ExtensionData> extensionDataList)
    {
      try
      {
        UnlockCapabilityEnumFile();
        if (extensionDataList != null)
        {
          foreach (ExtensionData extensionData in extensionDataList)
          {
            extensionData.UnlockFilesAndRestoreAssembly();
          }
        }
      }
      catch (System.Exception ex)
      {
        logger.Error("Failed to unlock files", ex);
      }
    }
    /// <summary>
    ///   Lock the capability enum file (R:\extensions\SystemConfig\config\EnumType\metratech.com\metratech.com_businessentity.xml)
    ///   if any of the extensions in extensionDataList does not have an entry in BusinessEntityExtension.
    ///   Also create a new capability enum file in Temp with updated enum entries.
    /// </summary>
    /// <param name="extensionDataList"></param>
    private void LockUpdateAndBackupCapabilityEnumFile(List<ExtensionData> extensionDataList, ref SyncData syncData)
    {
      Check.Require(File.Exists(CapabilityEnumFile), String.Format("Cannot find file '{0}'", CapabilityEnumFile));

      XElement root = XElement.Load(CapabilityEnumFile);

      XElement businessEntityExtensionEnumElement =
        root.Descendants("enum").FirstOrDefault(e => e.Attribute("name").Value == "BusinessEntityExtension");

      Check.Require(businessEntityExtensionEnumElement != null,
                    String.Format("Cannot find 'BusinessEntityExtensionEnum in file '{0}'", CapabilityEnumFile),
                    SystemConfig.CallerInfo);

      bool backupFile = false;
      syncData.CapabilityEnumValues.Clear();

      foreach(ExtensionData extensionData in extensionDataList)
      {
        XElement extensionEntryElement = 
          businessEntityExtensionEnumElement
          .Descendants("entry")
          .FirstOrDefault(e => e.Attribute("name").Value.ToLower() == extensionData.ExtensionName.ToLower());

        if (extensionEntryElement == null)
        {
          XElement entry = new XElement("entry", new XAttribute("name", extensionData.ExtensionName),
                                        new XElement("value", extensionData.ExtensionName));

          businessEntityExtensionEnumElement.Element("entries").Add(entry);

          syncData.CapabilityEnumValues.Add("metratech.com/businessentity/businessentityextension/" +
                                            extensionData.ExtensionName.ToLowerInvariant());
          backupFile = true;
        }
      }
      
      if (backupFile)
      {
        if (!Directory.Exists(TempCapabilityEnumDir))
        {
          Directory.CreateDirectory(TempCapabilityEnumDir);
        }
        else
        {
          DirectoryUtil.CleanDir(TempCapabilityEnumDir);
        }

        using (var writer = new StreamWriter(new FileStream(TempCapabilityEnumFile, FileMode.Create)))
        {
          root.Save(writer);
          writer.Flush();
        }

        // Lock the original 
        LockedFiles.Clear();
        LockedFiles.Add(CapabilityEnumFile, DirectoryUtil.LockFile(CapabilityEnumFile));
        
      }
    }

    private void UnlockAndCopyCapabilityEnumFile()
    {
      FileStream fileStream;
      LockedFiles.TryGetValue(CapabilityEnumFile, out fileStream);

      if (fileStream != null)
      {
        fileStream.Close();

        Check.Require(File.Exists(TempCapabilityEnumFile), "Cannot find file '{0}'", TempCapabilityEnumFile);
        File.Copy(TempCapabilityEnumFile, CapabilityEnumFile, true);
        LockedFiles.Remove(CapabilityEnumFile);
      }

      if (File.Exists(TempCapabilityEnumFile))
      {
        File.Delete(TempCapabilityEnumFile);
      }
    }

    private void UnlockCapabilityEnumFile()
    {
      FileStream fileStream;
      LockedFiles.TryGetValue(CapabilityEnumFile, out fileStream);

      if (fileStream != null)
      {
        fileStream.Close();
        LockedFiles.Remove(CapabilityEnumFile);
      }

      if (File.Exists(TempCapabilityEnumFile))
      {
        File.Delete(TempCapabilityEnumFile);
      }
    } 

    private void CleanEmptyDirectories(SyncData syncData, List<ExtensionData> extensionDataList)
    {
      string[] csFiles;

      foreach(ExtensionData extensionData in extensionDataList)
      {
        foreach(EntityGroupData entityGroupData in extensionData.EntityGroupDataList)
        {
          csFiles = Directory.GetFiles(entityGroupData.EntityDir, "*.cs");
          if (csFiles.Length == 0)
          {
            // Delete the csproj file
            string csProjFile = Name.GetEntityCsProjFile(extensionData.ExtensionName, entityGroupData.EntityGroupName);
            if (File.Exists(csProjFile))
            {
              logger.Debug(String.Format("Deleting file '{0}", csProjFile));
              File.Delete(csProjFile);
              syncData.Errors.Add
                (new ErrorObject
                   (String.Format("Assembly '{0}' has been removed from '{1}'. " +
                                  "It must be removed from the following web app bin directories '{2}'",
                                  Name.GetEntityAssemblyName(extensionData.ExtensionName, entityGroupData.EntityGroupName) + ".dll",
                                  SystemConfig.GetBinDir(),
                                  StringUtil.Join(", ", 
                                                  BusinessEntityConfig.Instance.GetAssemblyCopyDirectories(),
                                                  s => s)), 
                    Level.Warning));
            }
          }
        }

        // Delete the interface csproj file, if necessary
        csFiles = Directory.GetFiles(extensionData.InterfaceDir, "*.cs");
        if (csFiles.Length == 0)
        {
          // Delete the csproj file
          string csProjFile = Name.GetInterfaceCsProjFile(extensionData.ExtensionName, false);
          if (File.Exists(csProjFile))
          {
            logger.Debug(String.Format("Deleting file '{0}", csProjFile));
            File.Delete(csProjFile);

            syncData.Errors.Add
                (new ErrorObject
                   (String.Format("Assembly '{0}' has been removed from '{1}'. " +
                                  "It must be removed from the following web app bin directories '{2}'",
                                  Name.GetInterfaceAssemblyNameFromExtension(extensionData.ExtensionName),
                                  SystemConfig.GetBinDir(),
                                  StringUtil.Join(" , ",
                                                  BusinessEntityConfig.Instance.GetAssemblyCopyDirectories(),
                                                  s => s)),
                    Level.Warning));
          }
        }
      }
    }

    /// <summary>
    ///    Categorize the entities in syncData by their database. 
    ///    Create a new SyncData for each database.
    /// </summary>
    /// <param name="syncData"></param>
    /// <returns></returns>
    private List<SyncData> SplitByDatabase(SyncData syncData)
    {
      var syncDataList = new List<SyncData>();

      SyncData splitSyncData;
      foreach(Entity entity in syncData.NewEntities)
      {
        splitSyncData = syncDataList.Find(s => s.Database == entity.DatabaseName.ToLower());
        if (splitSyncData == null)
        {
          splitSyncData = new SyncData(syncData.OverwriteHbm);
          splitSyncData.EntityGraph = syncData.EntityGraph;
          splitSyncData.InheritanceGraph = syncData.InheritanceGraph;
          splitSyncData.BuildGraph = syncData.BuildGraph;
          splitSyncData.Database = entity.DatabaseName.ToLower();
          syncDataList.Add(splitSyncData);
        }

        splitSyncData.NewEntities.Add(entity);
      }

      foreach (Entity entity in syncData.ModifiedEntities)
      {
        splitSyncData = syncDataList.Find(s => s.Database == entity.DatabaseName.ToLower());
        if (splitSyncData == null)
        {
          splitSyncData = new SyncData(syncData.OverwriteHbm);
          splitSyncData.EntityGraph = syncData.EntityGraph;
          splitSyncData.InheritanceGraph = syncData.InheritanceGraph;
          splitSyncData.BuildGraph = syncData.BuildGraph;
          splitSyncData.Database = entity.DatabaseName.ToLower();
          syncDataList.Add(splitSyncData);
        }

        splitSyncData.ModifiedEntities.Add(entity);
      }

      foreach (Entity entity in syncData.DeletedEntities)
      {
        splitSyncData = syncDataList.Find(s => s.Database == entity.DatabaseName.ToLower());
        if (splitSyncData == null)
        {
          splitSyncData = new SyncData(syncData.OverwriteHbm);
          splitSyncData.EntityGraph = syncData.EntityGraph;
          splitSyncData.InheritanceGraph = syncData.InheritanceGraph;
          splitSyncData.BuildGraph = syncData.BuildGraph;
          splitSyncData.Database = entity.DatabaseName.ToLower();
          syncDataList.Add(splitSyncData);
        }

        splitSyncData.DeletedEntities.Add(entity);
      }

      if (syncData.NewComputedPropertyDataList.Count > 0)
      {
        if (syncDataList.Count > 0)
        {
          splitSyncData = syncDataList[0];
        }
        else
        {
          splitSyncData = new SyncData(syncData.OverwriteHbm);
          splitSyncData.EntityGraph = syncData.EntityGraph;
          splitSyncData.InheritanceGraph = syncData.InheritanceGraph;
          splitSyncData.BuildGraph = syncData.BuildGraph;
          syncDataList.Add(splitSyncData);
        }
        
        foreach(ComputedPropertyData computedPropertyData in syncData.NewComputedPropertyDataList)
        {
          splitSyncData.NewComputedPropertyDataList.Add(computedPropertyData);
        }
      }

      if (syncData.DeletedComputedPropertyDataList.Count > 0)
      {
        if (syncDataList.Count > 0)
        {
          splitSyncData = syncDataList[0];
        }
        else
        {
          splitSyncData = new SyncData(syncData.OverwriteHbm);
          splitSyncData.EntityGraph = syncData.EntityGraph;
          splitSyncData.InheritanceGraph = syncData.InheritanceGraph;
          splitSyncData.BuildGraph = syncData.BuildGraph;
          syncDataList.Add(splitSyncData);
        }

        foreach (ComputedPropertyData computedPropertyData in syncData.DeletedComputedPropertyDataList)
        {
          splitSyncData.DeletedComputedPropertyDataList.Add(computedPropertyData);
        }
      }

      return syncDataList;
    }

    private static void SetRelationshipAttributes(dynamic item, HbmRelationshipData relinfo, Type extensionMethodType)
    {
      MethodInfo methodInfo = extensionMethodType.GetMethod("SetAttributeValue");

      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.RelationshipTypeAttribute, relinfo.RelationshipType.ToString() });

      methodInfo.Invoke(null,
                        new[] {item, RelationshipEntity.RelationshipNameAttribute,
                                             Name.GetEntityClassName(relinfo.SourceEntityName) + "_" + Name.GetEntityClassName(relinfo.TargetEntityName)});
      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.IsDefaultAttribute, "true" });

      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.IsBiDirectionalAttribute, "true" });

      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.HasJoinTableAttribute, "false" });

      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.CascadeAttribute, relinfo.Cascade.ToString() });

      methodInfo.Invoke(null,
                        new[] {item, RelationshipEntity.SourceMultiplicityAttribute,
                               Multiplicity.One.ToString()});

      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.SourceEntityNameAttribute, relinfo.SourceEntityName });

      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.SourceKeyColumnNameAttribute, relinfo.SourceKeyColumn });

      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.SourcePropertyNameForTargetAttribute, relinfo.SourcePropertyNameForTarget });

      methodInfo.Invoke(null,
                        new[] {item, RelationshipEntity.TargetMultiplicityAttribute,
                               relinfo.RelationshipType == RelationshipType.OneToOne ? 
                               Multiplicity.One.ToString() : 
                               Multiplicity.Many.ToString()});

      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.TargetEntityNameAttribute, relinfo.TargetEntityName });

      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.TargetKeyColumnNameAttribute, relinfo.TargetKeyColumn });

      methodInfo.Invoke(null,
                        new[] { item, RelationshipEntity.TargetPropertyNameForSourceAttribute, relinfo.TargetPropertyNameForSource });

    }

    #endregion

    #region Private Properties
    private Dictionary<string, FileStream> LockedFiles { get; set; }
    private string CapabilityEnumFile { get; set;}
    private string TempCapabilityEnumDir { get; set; }
    private string TempCapabilityEnumFile { get; set; }
    #endregion

    #region Data
    internal static ILog logger = LogManager.GetLogger("SyncManager");
    #endregion
  }
}
