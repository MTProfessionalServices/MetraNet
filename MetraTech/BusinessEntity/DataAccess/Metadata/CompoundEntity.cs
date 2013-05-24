using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using Core.Common;
using MetraTech.Basic;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public class CompoundEntity : Entity
  {
    #region Properties
    public string LegacyTableName { get; set; }
    #endregion

    #region Constructors
    /// <summary>
    ///   Constructor for initializing from ICE
    /// </summary>
    /// <param name="fullName"></param>
    /// <param name="columnMetadataList"></param>
    internal CompoundEntity(string fullName, List<DbColumnMetadata> columnMetadataList)
      : base(fullName)
    {
      Check.Require(columnMetadataList != null && columnMetadataList.Count > 0, "columnMetadataList cannot be null or empty");

      // Check that all DbColumnMetadata's have a valid PropertyName
      List<DbColumnMetadata> invalidPropertyNames =
        columnMetadataList.FindAll(c => String.IsNullOrEmpty(c.PropertyName) || 
                                        !Name.IsValidIdentifier(c.PropertyName));

      Check.Require(invalidPropertyNames.Count == 0,
                    String.Format("Found {0} DbColumnMetadata items with null, empty or invalid PropertyName: '{1}'",
                                  invalidPropertyNames.Count,
                                  StringUtil.Join(",", invalidPropertyNames, c => c.ToString())));


      
      // Check that atleast one columnMetadata is a primary key
      DbColumnMetadata primaryKey = columnMetadataList.Find(c => c.IsPrimaryKey);
      Check.Require(primaryKey != null, String.Format("No primary key specified in column metadata list"));

      EntityType = EntityType.Compound;

      // Create properties for each
      foreach(DbColumnMetadata columnMetadata in columnMetadataList)
      {
        if (String.IsNullOrEmpty(LegacyTableName))
        {
          LegacyTableName = columnMetadata.TableName;
        }

        Property property = Property.CreateProperty(columnMetadata);
        AddProperty(property);
      }
    }

    /// <summary>
    ///   Constructor for initializing from hbm.xml
    /// </summary>
    /// <param name="fullName"></param>
    internal CompoundEntity(string fullName)
      : base(fullName)
    {
      EntityType = EntityType.Compound;
    }

    protected CompoundEntity(CompoundEntity compoundEntity)
      : base(compoundEntity)
    {
      LegacyTableName = compoundEntity.LegacyTableName;
    }

    #endregion

    #region Internal Methods
    internal List<Property> GetLegacyPrimaryKeyProperties()
    {
      List<Property> legacyPrimaryKeyProperties = Properties.FindAll(p => p.IsLegacyPrimaryKey).ToList();
      Check.Ensure(legacyPrimaryKeyProperties.Count > 0, String.Format("Compound entity '{0}' must have atleast one legacy primary key", FullName));
      
      return legacyPrimaryKeyProperties;
    }

    internal override Entity Clone()
    {
      return new CompoundEntity(this);
    }
    #endregion

    #region Protected Methods
    protected override List<ErrorObject> SetupAttributes(Dictionary<string, MetaAttribute> metaAttributes)
    {
      var errors = new List<ErrorObject>();

      MetaAttribute metaAttribute;

      // Extract the CompoundMetaAttribute and remove it from metaAttributes
      metaAttributes.TryGetValue(CompoundPropertyAttribute, out metaAttribute);
      metaAttributes.Remove(CompoundPropertyAttribute);
      
      // Create Properties for each CompoundProperty
      foreach(string value in metaAttribute.Values)
      {
        DbColumnMetadata columnMetadata = DbColumnMetadata.FromHbmString(value);
        if (!columnMetadata.Validate(out errors))
        {
          continue;
        }

        if (String.IsNullOrEmpty(LegacyTableName))
        {
          LegacyTableName = columnMetadata.TableName;
        }


        columnMetadata.CSharpTypeName =
          Property.ConvertDbTypeNameToCSharpTypeName(columnMetadata);

        Property property = Property.CreateProperty(columnMetadata);
        AddProperty(property);
      }
     
      errors.AddRange(base.SetupAttributes(metaAttributes));

      return errors;
    }
    #endregion
  }
}
