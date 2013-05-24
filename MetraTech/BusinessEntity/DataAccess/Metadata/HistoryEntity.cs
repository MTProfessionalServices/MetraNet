using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Xml.Serialization;
using MetraTech.Basic;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NHibernate.Cfg.MappingSchema;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public class HistoryEntity : Entity
  {
    #region Public Properties
    
    public string EntityName { get; set; }

    /// <summary>
    ///   Entity whose history is being recorded
    /// </summary>
    public Entity Entity { get; set; }

    #endregion

    #region Public Methods
    public HistoryEntity(string fullName) : base(fullName)
    {
    }

    public override string ToString()
    {
      return "HistoryEntity: " + FullName;
    }

    public override bool Validate(out List<ErrorObject> validationErrors)
    {
      if (!base.Validate(out validationErrors))
      {
        return false;
      }

      validationErrors.AddRange(ValidateAttributes());

      return validationErrors.Count > 0 ? false : true;
    }

   
    #endregion

    #region Internal Properties
    internal override string BusinessKeyPropertyName
    {
      get { return Name.GetBusinessKeyPropertyName(EntityName); }
    }

    #endregion
    #region Internal Methods
    internal HistoryEntity(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null");

      EntityName = entity.FullName;
      Entity = entity;

      SetTypeData(Name.GetEntityHistoryTypeName(entity.FullName));
      PluralName = Name.GetEntityHistoryClassName(entity.FullName) + "s";
      InternalBusinessKey = entity.InternalBusinessKey;

      InitializeProperties();

      if (String.IsNullOrEmpty(TableName))
      {
        TableName = Name.GetEntityHistoryTableName(entity.TableName);
      }
      DatabaseName = entity.DatabaseName;
      EntityType = EntityType.History;
    }

    internal void Refresh(Entity entity)
    {
      Entity = entity;
      InternalBusinessKey = entity.InternalBusinessKey;
      if (String.IsNullOrEmpty(TableName))
      {
        TableName = Name.GetEntityHistoryTableName(entity.TableName);
      }

      InitializeProperties();
    }

    public override List<Property> GetDatabaseProperties()
    {
      var dbProperties = new List<Property>();

      dbProperties.AddRange(GetStandardProperties());
      dbProperties.AddRange(Properties.Where(property => !property.IsCompound || property.IsLegacyPrimaryKey));

      return dbProperties;
    }

    public override List<Property> GetForeignKeyProperties(bool useIdPropertyName = false)
    {
      var foreignKeyProperties = new List<Property>();
        
      List<Property> entityForeignKeyProperties = Entity.GetForeignKeyProperties();
      foreach (Property property in entityForeignKeyProperties)
      {
        var propertyClone = property.Clone();
        propertyClone.Name = propertyClone.Name + "Id";
        propertyClone.Entity = Entity;
        foreignKeyProperties.Add(propertyClone);
      }

      return foreignKeyProperties;
    }

    internal override string GetHbmMappingFileContent(bool overWriteHbm)
    {
      HbmMapping hbmMapping = null;
      if (!overWriteHbm && HbmMapping != null)
      {
        hbmMapping = HbmMapping;
      }
      else
      {
        hbmMapping = CreateBasicHbmMapping();
        HbmClass hbmClass = CreateBasicHbmClass();
        var compoundEntity = Entity as CompoundEntity;
        if (compoundEntity != null)
        {
          compoundEntity.GetLegacyPrimaryKeyProperties().ForEach(p => hbmClass.AddItem(p.CreateHbmProperty()));
        }

        hbmMapping.AddHbmClass(hbmClass);

        hbmClass.MakeAllPropertiesNonUnique();

        string triggerName = Name.GetHistoryTriggerName(ClassName);

        // Remove the trigger from hbmMapping
        hbmMapping.RemoveTriggerHbmDatabaseObject(triggerName);

        // Add the trigger for Oracle
        HbmDatabaseObject oracleTrigger = GetOracleTriggerHbmDatabaseObject(triggerName, Entity.TableName, TableName, Entity.GetIdColumnName());
        hbmMapping.AddHbmDatabaseObject(oracleTrigger);

        // Add the trigger for SQLServer
        HbmDatabaseObject sqlTrigger = GetSqlServerTriggerHbmDatabaseObject(triggerName, Entity.TableName, TableName, Entity.GetIdColumnName());
        hbmMapping.AddHbmDatabaseObject(sqlTrigger);
      }
      
      var serializer = new XmlSerializer(typeof(HbmMapping));

      var stringWriter = new NullEncodingStringWriter();
      serializer.Serialize(stringWriter, hbmMapping);

      Check.Require(!String.IsNullOrEmpty(stringWriter.ToString()),
                     String.Format("Failed to generate hbm mapping for entity '{0}'", FullName));

      return stringWriter.ToString();
    }

    internal override Entity Clone()
    {
      return new HistoryEntity(this);
    }

    protected override void InitializeClassAttributes()
    {
      base.InitializeClassAttributes();
      MetaAttributes.Add(EntityNameAttribute, new MetaAttribute());
    }

    protected override void UpdateClassAttributes()
    {
      base.UpdateClassAttributes();
      MetaAttributes[EntityNameAttribute].Value = EntityName;
    }

    protected override List<ErrorObject> SetupAttributes(Dictionary<string, MetaAttribute> metaAttributes)
    {
      var errors = new List<ErrorObject>();

      MetaAttribute metaAttribute;

      metaAttributes.TryGetValue(EntityNameAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        EntityName = metaAttribute.Value;
      }

      errors.AddRange(base.SetupAttributes(metaAttributes));
      errors.AddRange(ValidateAttributes());

      return errors;
    }

    protected override void SetTypeData(string fullName)
    {
      base.SetTypeData(fullName);
      PluralName = RelationshipEntity.GetPluralName(fullName);
      EntityType = EntityType.SelfRelationship;
    }

    internal override string GetCodeFileContent()
    {
      string codeFileContent = EntityHistoryGenerator.GenerateCode(this);
      Check.Require(!String.IsNullOrEmpty(codeFileContent),
                    String.Format("Failed to generate code for entity '{0}'", FullName));

      return codeFileContent;
    }

    #endregion

    #region Protected Methods
    protected HistoryEntity(HistoryEntity historyEntity) 
      : base(historyEntity)
    {
      
    }

    #endregion

    #region Private Methods
    private HbmDatabaseObject GetOracleTriggerHbmDatabaseObject(string triggerName, 
                                                                string entityTableName,
                                                                string historyTableName,
                                                                string idColumnName)
    {
      var hbmDatabaseObjectItems = new List<object>();

      List<Property> properties = GetDatabaseProperties();
      // Remove the primary key column because it's auto-generated
      properties.RemoveAll(p => p.ColumnName.ToLower() == GetIdColumnName().ToLower());

      var columns = StringUtil.Join(", \n", properties, p => p.ColumnName.ToLower());
      var columnValues = StringUtil.Join(", \n", properties, p => ":dataRow." + p.ColumnName.ToLower());
      columnValues = columnValues.Replace(":dataRow.c__enddate", "CAST(dbo.mtmaxdate() AS TIMESTAMP)");
      columnValues = columnValues.Replace(":dataRow.c__startdate", ":dataRow.c_updatedate");


      var triggerText = "\n" +
                        "CREATE or REPLACE \n" +
                        "TRIGGER " + triggerName + "\n" +
                        " AFTER INSERT OR UPDATE ON " + entityTableName + "\n" +
                        " REFERENCING NEW AS dataRow \n" +
                        "FOR EACH ROW \n" +

                        "UPDATE " + historyTableName + "\n" +
                        " SET c__enddate = :dataRow.c_updatedate \n" +
                        "WHERE " + idColumnName + " = :dataRow." + idColumnName +
                        " AND c__enddate = CAST(dbo.mtmaxdate() AS TIMESTAMP); \n" +

                        "INSERT INTO " + historyTableName + "\n" +
                        "( \n" +
                        columns + "\n" +
                        ") \n" +
                        "VALUES \n" +
                        "( \n" +
                        columnValues + "\n" +
                        ") \n";

      var hbmCreate = new HbmCreate() {Text = new string[] {triggerText}};
      hbmDatabaseObjectItems.Add(hbmCreate);
      hbmDatabaseObjectItems.Add(new HbmDrop());

      var hbmDatabaseObject = new HbmDatabaseObject();
      hbmDatabaseObject.Items = hbmDatabaseObjectItems.ToArray();
      hbmDatabaseObject.dialectscope = new HbmDialectScope[] { new HbmDialectScope() { name = "NHibernate.Dialect.Oracle10gDialect"} };
      return hbmDatabaseObject;
    }

    private HbmDatabaseObject GetSqlServerTriggerHbmDatabaseObject(string triggerName, 
                                                                   string entityTableName,
                                                                   string historyTableName,
                                                                   string idColumnName)
    {
      var hbmDatabaseObjectItems = new List<object>();

      List<Property> properties = GetDatabaseProperties();
      // Remove the primary key column because it's auto-generated
      properties.RemoveAll(p => p.ColumnName.ToLower() == GetIdColumnName().ToLower());

      var columns = StringUtil.Join(", \n", properties, p => p.ColumnName.ToLower());
      var columnValues = StringUtil.Join(", \n", properties, p => p.ColumnName.ToLower());
      columnValues = columnValues.Replace("c__enddate", "dbo.mtmaxdate()");
      columnValues = columnValues.Replace("c__startdate", "c_updatedate");

      
      var triggerText =
        "CREATE TRIGGER " + triggerName + Environment.NewLine +
        " ON " + entityTableName + Environment.NewLine +
        " AFTER INSERT, UPDATE " + Environment.NewLine +
        "AS " + Environment.NewLine +
        "SET NOCOUNT ON " + Environment.NewLine +

        "UPDATE history SET c__enddate = ins.c_updatedate " + Environment.NewLine +
        "FROM " + historyTableName + " history " + Environment.NewLine +
        "INNER JOIN INSERTED ins ON ins." + idColumnName + " = history." + idColumnName +
        Environment.NewLine +
        " WHERE history.c__enddate = dbo.mtmaxdate(); " + Environment.NewLine +

        "INSERT INTO " + historyTableName + Environment.NewLine +
        "(" + Environment.NewLine +
        columns + Environment.NewLine +
        ")" + Environment.NewLine +
        "SELECT " + Environment.NewLine +
        columnValues + Environment.NewLine +
        "FROM INSERTED; " + Environment.NewLine;

      var hbmCreate = new HbmCreate() { Text = new string[] { triggerText.Trim() } };
      hbmDatabaseObjectItems.Add(hbmCreate);

      
      hbmDatabaseObjectItems.Add(new HbmDrop());

      var hbmDatabaseObject = new HbmDatabaseObject();
      hbmDatabaseObject.Items = hbmDatabaseObjectItems.ToArray();
      hbmDatabaseObject.dialectscope = new HbmDialectScope[] { new HbmDialectScope() { name = "NHibernate.Dialect.MsSql2008Dialect" } };

      return hbmDatabaseObject;
    }

    private void InitializeProperties()
    {
      Properties.Clear();

      // Id property for Entity
      var entityIdProperty = Entity.GetIdProperty();
      entityIdProperty.Name = Entity.ClassName + "Id";
      Properties.Add(entityIdProperty);

      // All basic properties and compound legacy primary key properties);
      foreach (Property property in Entity.Properties)
      {
        if (property.IsComputed && !property.IsLegacyPrimaryKey) continue;
        Properties.Add(property);
      }

      // Add foreign key properties
      Properties.AddRange(GetForeignKeyProperties());

      // StartDate and EndDate
      AddHistoryProperties();
    }


    private void AddHistoryProperties()
    {

      // Add the StartDate property
      var startDateProperty = new Property(BaseHistory.StartDatePropertyName, "DateTime");
      startDateProperty.Entity = this;
      startDateProperty.IsRequired = true;
      startDateProperty.DefaultValue = DateTime.MinValue.ToString();
      startDateProperty.ColumnName = "c_" + BaseHistory.StartDatePropertyName;
      Properties.Add(startDateProperty);

      // Add the EndDate property
      var endDateProperty = new Property(BaseHistory.EndDatePropertyName, "DateTime");
      endDateProperty.Entity = this;
      endDateProperty.IsRequired = true;
      endDateProperty.DefaultValue = DateTime.MaxValue.ToString();
      endDateProperty.ColumnName = "c_" + BaseHistory.EndDatePropertyName;
      Properties.Add(endDateProperty);
    }

    private List<ErrorObject> ValidateAttributes()
    {
      var validationErrors = new List<ErrorObject>();

      if (String.IsNullOrEmpty(EntityName))
      {
        string message =
          String.Format("The '{0}' meta attribute is missing or empty for HistoryEntity '{1}'",
                        EntityNameAttribute, FullName);
        var errorData = new ErrorData();
        errorData.ErrorCode = ErrorCode.HISTORY_ENTITY_VALIDATION_MISSING_ENTITY;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        historyLogger.Error(message);
      }
      else
      {
        List<ErrorObject> specificErrors;
        if (Name.IsValidEntityTypeName(EntityName, out specificErrors))
        {
          validationErrors.AddRange(specificErrors);
        }
      }

      return validationErrors;
    }
    #endregion

    #region Static Methods
   
    #endregion

    #region Private Properties
    #endregion

    #region Data
    internal static ILog historyLogger = LogManager.GetLogger("HistoryEntity");
    internal static readonly string EntityNameAttribute = "entity-name";

    #endregion
  }
}
