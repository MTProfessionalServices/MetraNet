using System;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;

namespace Core.Common
{
  [Serializable]
  public abstract class PivotTableProperty
  {
    #region Public Methods
    public static PivotTableProperty CreatePivotTableProperty(PivotTableType pivotTableType, PropertyType propertyType)
    {
      PivotTableProperty pivotTableProperty = null;

      if (pivotTableType == PivotTableType.Unique)
      {
        pivotTableProperty = new Unique();
      }
      else if (pivotTableType == PivotTableType.Index)
      {
        pivotTableProperty = new Index();
      }

      Check.Ensure(pivotTableProperty != null, "pivotTableProperty cannot be null", SystemConfig.CallerInfo);

      pivotTableProperty.PivotTableType = pivotTableType;
      pivotTableProperty.PropertyType = propertyType;

      return pivotTableProperty;
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as PivotTableProperty;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null &&
             compareTo.ExtensionName == ExtensionName &&
             compareTo.EntityGroupName == EntityGroupName &&
             compareTo.EntityName == EntityName &&
             compareTo.PropertyName == PropertyName &&
             compareTo.EntityInstanceId == EntityInstanceId;
    }

    public override int GetHashCode()
    {
      return String.Concat(ExtensionName, EntityGroupName, EntityName, PropertyName, EntityInstanceId).GetHashCode();
    }

    public virtual PivotTableProperty Copy()
    {
      var pivotTableProperty = CreatePivotTableProperty(PivotTableType, PropertyType);
      pivotTableProperty.ExtensionName = ExtensionName;
      pivotTableProperty.EntityGroupName = EntityGroupName;
      pivotTableProperty.EntityName = EntityName;
      pivotTableProperty.PropertyName = PropertyName;
      pivotTableProperty.EntityInstanceId = EntityInstanceId;

      return pivotTableProperty;
    }

    public virtual object GetValue()
    {
      object value = null;

      if (PropertyType == PropertyType.Boolean)
      {
        value = BooleanValue;
      }
      else if  (PropertyType == PropertyType.DateTime)
      {
        value = DateTimeValue;
      }
      else if (PropertyType == PropertyType.Decimal)
      {
        value = DecimalValue;
      }
      else if (PropertyType == PropertyType.Double)
      {
        value = DoubleValue;
      }
      else if (PropertyType == PropertyType.Guid)
      {
        value = GuidValue;
      }
      else if (PropertyType == PropertyType.Int32)
      {
        value = Int32Value;
      }
      else if (PropertyType == PropertyType.Int64)
      {
        value = Int64Value;
      }
      else if (PropertyType == PropertyType.String)
      {
        value = StringValue;
      }
      else if (PropertyType == PropertyType.Enum)
      {
        value = EnumValue;
      }

      return value;
    }

    public virtual void SetValue(object value)
    {
      try
      {
        if (PropertyType == PropertyType.Boolean)
        {
          BooleanValue = Convert.ToBoolean(value);
        }
        else if (PropertyType == PropertyType.DateTime)
        {
          DateTimeValue = Convert.ToDateTime(value);
        }
        else if (PropertyType == PropertyType.Decimal)
        {
          DecimalValue = Convert.ToDecimal(value);
        }
        else if (PropertyType == PropertyType.Double)
        {
          DoubleValue = Convert.ToDouble(value);
        }
        else if (PropertyType == PropertyType.Guid)
        {
          if (value != null)
          {
            GuidValue = (Guid)Convert.ChangeType(value, typeof (Guid));
          }
        }
        else if (PropertyType == PropertyType.Int32)
        {
          Int32Value = Convert.ToInt32(value);
        }
        else if (PropertyType == PropertyType.Int64)
        {
          Int64Value = Convert.ToInt64(value);
        }
        else if (PropertyType == PropertyType.String)
        {
          StringValue = Convert.ToString(value);
        }
        else if (PropertyType == PropertyType.Enum)
        {
          EnumValue = Convert.ToInt32(value);
        }
      }
      catch (System.Exception e)
      {
        string error = String.Format("Cannot set value '{0}' for property type '{1}'", value, PropertyType);
        throw new ApplicationException(error, e);
      }
    }

    public static string GetIndexPropertyName(PropertyType propertyType)
    {
      string indexPropertyName = null;

      if (propertyType == PropertyType.Boolean)
      {
        indexPropertyName = "StringValue";
      }
      else if  (propertyType == PropertyType.DateTime)
      {
        indexPropertyName = "DateTimeValue";
      }
      else if (propertyType == PropertyType.Decimal)
      {
        indexPropertyName = "DecimalValue";
      }
      else if (propertyType == PropertyType.Double)
      {
        indexPropertyName = "DoubleValue";
      }
      else if (propertyType == PropertyType.Guid)
      {
        indexPropertyName = "GuidValue";
      }
      else if (propertyType == PropertyType.Int32)
      {
        indexPropertyName = "Int32Value";
      }
      else if (propertyType == PropertyType.Int64)
      {
        indexPropertyName = "Int64Value";
      }
      else if (propertyType == PropertyType.String)
      {
        indexPropertyName = "StringValue";
      }
      else if (propertyType == PropertyType.Enum)
      {
        indexPropertyName = "EnumValue";
      }

      Check.Ensure(!String.IsNullOrEmpty(indexPropertyName), "indexPropertyName cannot be null or empty", SystemConfig.CallerInfo);
      return indexPropertyName;
    }
    #endregion

    #region Public Properties
    public abstract string ExtensionName { get; set; }
    public abstract string EntityGroupName { get; set; }
    public abstract string EntityName { get; set; }
    public abstract string PropertyName { get; set; }
    public abstract Guid EntityInstanceId { get; set; }

    public abstract bool? BooleanValue { get; set; }
    public abstract DateTime? DateTimeValue { get; set; }
    public abstract decimal? DecimalValue { get; set; }
    public abstract double? DoubleValue { get; set; }
    public abstract Guid? GuidValue { get; set; }
    public abstract int? Int32Value { get; set; }
    public abstract Int64? Int64Value { get; set; }
    public abstract string StringValue { get; set; }
    public abstract int? EnumValue { get; set; }

    public virtual string EntityFullName { get { return ExtensionName + "." + EntityGroupName + "." + EntityName; } }
    public virtual PivotTableType PivotTableType { get; set; }
    public virtual PropertyType PropertyType { get; set; }

    #endregion
  }

  public enum PivotTableType
  {
    Index,
    Unique
  }
}

