using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  public static class TableNameGenerator
  {
    /// <summary>
    ///   Table names for non relationship tables are specified as
    ///   t_be_[Class Name Section (20)]_[Hash (5)]
    /// where:
    /// 'cor' represents the first three letters of the extension 
    /// 'ord' represents the first three letters of the entity group
    /// b - represents backup
    /// h - represents history
    /// </summary>
    /// <param name="entity"></param>
    /// <returns></returns>
    public static string CreateTableName(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null");
      Check.Require(!String.IsNullOrEmpty(entity.FullName), "entity does not have a full name");

      if (!String.IsNullOrEmpty(entity.TableName))
      {
        return entity.TableName;
      }

      string tableName = null;

      return tableName;
    }
    /// <summary>
    ///    Some of the items in entities, may not have table names.
    /// </summary>
    /// <param name="entity"></param>
    /// <param name="entities"></param>
    /// <returns></returns>
    public static string CreateTableName(Entity entity, List<Entity> entities)
    {
      Check.Require(entity != null, "entity cannot be null");
      Check.Require(entities != null, "entities cannot be null");
      Check.Require(!String.IsNullOrEmpty(entity.FullName), "entity does not have a full name");

      if (!String.IsNullOrEmpty(entity.TableName))
      {
        return entity.TableName;
      }

      List<Entity> entitiesWithoutTableName = entities.FindAll(e => String.IsNullOrEmpty(e.TableName));
      List<Entity> entitiesWithTableName = entities.FindAll(e => !String.IsNullOrEmpty(e.TableName));

      // Collect all the existing table names
      var tableNames = new List<string>();
      entitiesWithTableName.ForEach(e => tableNames.Add(e.TableName.ToLowerInvariant()));

      // Generate table names for entitiesWithoutTableName, except for the input 'entity'
      foreach(Entity entityWithoutTableName in entitiesWithoutTableName)
      {
        if (entityWithoutTableName.Equals(entity)) continue;
        tableNames.Add(CreateTableNameInternal(entityWithoutTableName, tableNames));
      }

      string tableName = CreateTableNameInternal(entity, tableNames);
      return tableName.ToLowerInvariant();
    }


    private static string CreateTableNameInternal(Entity entity, List<string> tableNames)
    {
      // Table names for non relationship tables are specified as
      // t_be_cor_ord_[Class Name Section (15)]_[b/h]
      // where:
      // 'cor' represents the first three letters of the extension 
      // 'ord' represents the first three letters of the entity group
      // b - represents backup
      // h - represents history

      // Table names for relationship tables are specified as
      // t_be_cor_ord_r_[Class Name Section (13)]_[b/h]
      // 

      // classNameSection can only be 15 (13 for relationship entities) because the rest take up 15 (17 for relationship entities) 
      // Thanks, Oracle.

      string prefix =
        "t_be_" +
        SystemConfig.GetAbbreviatedExtensionEntityGroupCombination(entity.ExtensionName, entity.EntityGroupName) +
        "_";

      if (entity.EntityType == EntityType.Relationship || entity.EntityType == EntityType.SelfRelationship)
      {
        prefix = prefix + "r_";
      }

      string classNameSection = entity.GetClassNameSectionForTable();
      string tableName = prefix + classNameSection;

      // Uniquefy classNameSection across all entities in this entity group.
      // Replace the last 6 characters with a hash code based on a Guid

      string duplicateTableName = tableNames.Find(s => s.ToLowerInvariant() == tableName.ToLowerInvariant());
      if (duplicateTableName != null)
      {
        // First 6 of the hash
        string uniqueifier = Math.Abs((Guid.NewGuid().ToString()).GetHashCode()).ToString();
        if (uniqueifier.Length > 6)
        {
          uniqueifier = uniqueifier.Substring(0, 6);
        }

        if (entity is RelationshipEntity)
        {
          // Reduce class name section to 7
          classNameSection = classNameSection.Length > 7 ? classNameSection.Substring(0, 7) : classNameSection;
        }
        else
        {
          // Reduce class name section to 9
          classNameSection = classNameSection.Length > 9 ? classNameSection.Substring(0, 9) : classNameSection;
        }

        classNameSection = classNameSection + uniqueifier;

        tableName = prefix + classNameSection;
      }

      Check.Ensure(!String.IsNullOrEmpty(tableName),
                   String.Format("Cannot generate table name for entity '{0}'", entity.FullName));

      Check.Ensure(!tableNames.Contains(tableName.ToLowerInvariant()), String.Format("Cannot generate unique table name for entity '{0}'", entity.FullName));

      return tableName.ToLowerInvariant();
    }
  }
}
