using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.ImportExport
{
  public class EntityNameParser
  {
    string mEntityNameMask;
    string mEntityName = "*";
    string mEntityGroupName = "*";
    public string EntityGroupName { get { return mEntityGroupName; } }
    string mExtensionName = "*";
    public string ExtensionName { get { return mExtensionName; } }

    public bool IsExtension
    {
      get
      {
        if (mExtensionName != "*" && !IsEntityGroup && !IsEntity) return true;
        return false;
      }
    }
    
    public bool IsEntityGroup
    {
      get
      {
        if (mEntityGroupName != "*" && !IsEntity) return true;
        return false;
      }
    }
    
    public bool IsEntity
    {
      get
      {
        if (mEntityName != "*") return true;
        return false;
      }
    }

    public bool AllEntities
    {
      get
      {
        if (mExtensionName == "*") return true;
        return false;
      }
    }
    
    public EntityNameParser(string EntityNameMask)
    {
      mEntityNameMask = EntityNameMask;
      try
      {
        Parse();
      }
      catch (Exception ex)
      {
        throw new Exception(string.Format("{0} Unable to parse extension name or mask: {1}", ex.Message, EntityNameMask), ex);
      }
    }
    
    /// <summary>
    /// Parsing Entity name mask. It can be one of 3 things
    ///   EntityFullName, like Core.UI.Site
    ///   EntiyGroup, like Core.UI.*
    ///   Extension, like Core.*
    ///   Everything, like *
    /// </summary>

    // GMH 06/27/2012: ESR-5445: the below "convoluted" parsing logic is a "hack" to
	// get around the user-defined BME's starting with MetraNet.[extension name],
	// while existing (out-of-the-box) BME's start with [extension name]. 
    private void Parse()
    {
      string[] name = mEntityNameMask.Split('.');
      switch (name.Length)
      {
        case 1:
          mExtensionName = name[0];
          if (mExtensionName != "*")
            throw new Exception("Extension name not followed by .*");
          break;
        case 2:
          if (name[0] == MetraTech.BusinessEntity.Core.BMEConstants.BMERootNameSpace)
		  {
            throw new Exception(string.Format("If BMERootNameSpace indicated, Extension name must be of the form: {0}.ExtensionName", MetraTech.BusinessEntity.Core.BMEConstants.BMERootNameSpace));
		  }
          mExtensionName = name[0];
          mEntityGroupName = name[1];
          if (mEntityGroupName != "*")
            throw new Exception("EntityGroup name not followed by .*");
          if (mExtensionName == "")
            throw new Exception("Extension name is empty");
          break;
        case 3:
          if (name[0] == MetraTech.BusinessEntity.Core.BMEConstants.BMERootNameSpace)
		  {
            if (name[2] != "*")
            {
              throw new Exception(string.Format("If BMERootNameSpace indicated, Extension name must be of the form: {0}.ExtensionName.EntityGroup.EntityName", MetraTech.BusinessEntity.Core.BMEConstants.BMERootNameSpace));
            } else
            {
              if (name[1] == "")
              {
                throw new Exception(string.Format("BMERootNameSpace ({0}) indicated, but actual Extension name is missing.", MetraTech.BusinessEntity.Core.BMEConstants.BMERootNameSpace));
              }
              mExtensionName = string.Format("{0}.{1}", name[0], name[1]);
              mEntityGroupName = name[2];
              break;
            }
          }

          mExtensionName = name[0];
          mEntityGroupName = name[1];
          mEntityName = name[2];
          if (mExtensionName == "")
            throw new Exception("Extension name is empty");
          if (mEntityGroupName == "")
            throw new Exception("EntityGroupName name is empty");
          if (mEntityName == "")
            throw new Exception("EntityName name is empty");
          break;
        case 4:
          mExtensionName = string.Format("{0}.{1}", name[0], name[1]);
          mEntityGroupName = name[2];
          mEntityName = name[3];
          if (mExtensionName == "")
            throw new Exception("Extension name is empty");
          if (mEntityGroupName == "")
            throw new Exception("EntityGroupName name is empty");
          if (mEntityName == "")
            throw new Exception("EntityName name is empty");
          break;
        default:
          throw new ArgumentException(string.Format("Invalid Extension name or mask"));
      }
    }
  }

  public class EntityImportExportBase
  {
    protected MetraTech.Logger Logger = new MetraTech.Logger("[EntityImportExportBase]");

    protected MetadataRepository metadataRepository;
    public EntityImportExportBase()
    {
      metadataRepository = MetadataRepository.Instance;
      metadataRepository.InitializeFromFileSystem();
    }

    protected Dictionary<string, Entity> entities = new Dictionary<string, Entity>();
    protected Dictionary<string, Entity> relationshipEntities = new Dictionary<string, Entity>();


    /// <summary>
    /// Add entity for import or export. Don't worry about duplicates, I get rid of duplicates. We need this 
    /// interface as it provides finer granularity. For example if we have no single root in a group of entities
    /// we can add all existing roots. if we have dealer, car, manufacturer with one to many relationship from
    /// dealer to car and from Manufacturer to car.
    /// </summary>
    /// <param name="entityName">entity full name for import or export. Exampe "Core.UI.Site"
    /// To Add EntityGroup use Core.UI.*
    /// To Add all Entities from an Extension use Core.*
    /// </param>
    /// <param name="cascade">if true - include all referenced entities</param>
    public virtual void AddEntity(string entityName, bool cascade)
    {
      EntityNameParser enp = new EntityNameParser(entityName);
      if (enp.IsEntity)
      {
        AddEntityByFullName(entityName, cascade);
      }
      else if (enp.IsEntityGroup)
      {
        List<Entity> entityList = metadataRepository.GetEntities(enp.ExtensionName, enp.EntityGroupName, true);
        if (entityList.Count == 0)
          throw new Exception(string.Format("No entities found for Entity Group {0}.{1} not found in metadata repository", enp.ExtensionName, enp.EntityGroupName));
        foreach (Entity entity in entityList)
        {
          if (entity is RelationshipEntity) 
            AddEntity(entity);
          else
            AddEntityByFullName(entity.FullName, cascade);
        }
      }
      else if (enp.IsExtension)
      {
        List<Entity> entityList = metadataRepository.GetEntities(enp.ExtensionName, true);
        if (entityList.Count == 0)
          throw new Exception(string.Format("No entities found for Extension {0} not found in metadata repository", enp.ExtensionName));
        foreach (Entity entity in entityList)
        {
          if (entity is RelationshipEntity)
            AddEntity(entity);
          else
            AddEntityByFullName(entity.FullName, cascade);
        }
      }
      else if (enp.AllEntities)
      {
        List<Entity> entityList = metadataRepository.GetEntities(true);
        if (entityList.Count == 0)
          throw new Exception("Strange. No entities found in metadata repository. None at all");
        foreach (Entity entity in entityList)
        {
          AddEntity(entity);
        }
      }
    }

    private void AddEntityByFullName(string entityName, bool cascade)
    {
      if (cascade)
      {
        List<Entity> entitiesFound;
        List<RelationshipEntity> relationshipFound;

        metadataRepository.GetChildEntitiesAndRelationships(entityName, true, out entitiesFound, out relationshipFound);
        if ((entitiesFound.Count == 0) && relationshipFound.Count == 0)
          throw new Exception(string.Format("Entity {0} not found in metadata repository", entityName));
        foreach (Entity entity in entitiesFound)
        {
          AddEntity(entity);
        }
        foreach (RelationshipEntity relEntity in relationshipFound)
        {
          AddEntity(relEntity);
        }
      }
      else
      {
        Entity entity = metadataRepository.GetEntity(entityName);
        if (entity == null)
          throw new Exception(string.Format("Entity {0} not found in metadata repository", entityName));
        AddEntity(entity);
      }
    }

    private void AddEntity(Entity entity) {
      if (entity is RelationshipEntity)
      {
        RelationshipEntity relEntity = (RelationshipEntity)entity;
        if (!relationshipEntities.ContainsKey(relEntity.FullName))
        {
          relationshipEntities.Add(relEntity.FullName, relEntity);
          Logger.LogDebug("Adding entity {0} for future processing", relEntity.FullName);
        }
      }
      else
      {
        if (!entities.ContainsKey(entity.FullName))
        {
          entities.Add(entity.FullName, entity);
          Logger.LogDebug("Adding entity {0} for future processing", entity.FullName);
        }
      }
    }

    public virtual void Clear()
    {
      entities.Clear();
      relationshipEntities.Clear();
    }
  }
}
