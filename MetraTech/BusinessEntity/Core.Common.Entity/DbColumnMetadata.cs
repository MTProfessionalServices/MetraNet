using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using MetraTech.Basic;
using MetraTech.Basic.Exception;

namespace Core.Common
{
  [Serializable]
  public class DbColumnMetadata
  {
    #region Public Methods
    public override string ToString()
    {
      return String.Format("DbColumnMetadata: ColumnName = '{0}' : PropertyName = '{1}' : DbType = '{2}' : CSharpType = '{3}' : IsRequired = '{4}' : IsUnique = '{5}' : IsEnum = '{6}'",
                           ColumnName,
                           PropertyName,
                           DbTypeName,
                           CSharpTypeName,
                           IsRequired,
                           IsUnique,
                           String.IsNullOrEmpty(EnumAssemblyQualifiedTypeName) ? "false" : "true");
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as DbColumnMetadata;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null &&
             compareTo.ColumnName == ColumnName &&
             compareTo.TableName == TableName;
    }

    public override int GetHashCode()
    {
      return (TableName + ColumnName).GetHashCode();
    }

    public string ToHbmString()
    {
      return String.Format("tn={0},cn={1},pn={2},dbt={3},ml={4},pr={5},scl={6},nl={7},pk={8},uk={9},en=[{10}],lbl=[{11}],desc={12}",
                            TableName, ColumnName, PropertyName, DbTypeName, MaxLength, Precision, Scale,
                            NullableFlag, PrimaryKeyFlag, UniqueFlag, EnumAssemblyQualifiedTypeName, Label, Description);
    }

    public virtual DbColumnMetadata Clone()
    {
      return new DbColumnMetadata()
      {
        TableName = TableName,
        ColumnName = ColumnName,
        PropertyName = PropertyName,
        DbTypeName = DbTypeName,
        CSharpTypeName = CSharpTypeName,
        MaxLength = MaxLength,
        Precision = Precision,
        Scale = Scale,
        NullableFlag = NullableFlag,
        PrimaryKeyFlag = PrimaryKeyFlag,
        UniqueFlag = UniqueFlag,
        EnumAssemblyQualifiedTypeName = EnumAssemblyQualifiedTypeName,
        Label = Label,
        Description = Description
      };
    }

    public void InitPropertyName()
    {
      // Remove leading c_
      string columnName = ColumnName.ToLower().StartsWith("c_") ? ColumnName.Remove(0, 2) : ColumnName;
      // Remove leading b_
      columnName = columnName.ToLower().StartsWith("b_") ? columnName.Remove(0, 2) : columnName;
      // Remove leading tx_
      columnName = columnName.ToLower().StartsWith("tx_") ? columnName.Remove(0, 3) : columnName;
      // Remove leading dt_
      columnName = columnName.ToLower().StartsWith("dt_") ? columnName.Remove(0, 3) : columnName;
      // Remove leading id_ and append Id
      if (columnName.ToLower().StartsWith("id_"))
      {
        columnName = columnName.Remove(0, 3);
        columnName = columnName + "Id";
      }

      PropertyName = StringUtil.CleanName(columnName);
    }

    public bool Validate(out List<ErrorObject> validationErrors)
    {
      validationErrors = new List<ErrorObject>();

      if (String.IsNullOrEmpty(TableName))
      {
        var errorData = new ErrorData();
        errorData.ErrorCode = ErrorCode.COLUMN_METADATA_VALIDATION_MISSING_TABLE_NAME;
        errorData.ErrorType = ErrorType.PropertyValidation;
        validationErrors.Add(new ErrorObject("Property validation failed. Missing TableName on DbColumnMetadata",
                                             errorData));
      }

      if (String.IsNullOrEmpty(ColumnName))
      {
        var errorData = new ErrorData();
        errorData.ErrorCode = ErrorCode.COLUMN_METADATA_VALIDATION_MISSING_COLUMN_NAME;
        errorData.ErrorType = ErrorType.PropertyValidation;
        validationErrors.Add(new ErrorObject("Property validation failed. Missing ColumnName on DbColumnMetadata",
                                             errorData));
      }

      if (String.IsNullOrEmpty(PropertyName))
      {
        var errorData = new ErrorData();
        errorData.ErrorCode = ErrorCode.COLUMN_METADATA_VALIDATION_MISSING_PROPERTY_NAME;
        errorData.ErrorType = ErrorType.PropertyValidation;
        validationErrors.Add(new ErrorObject("Property validation failed. Missing PropertyName on DbColumnMetadata",
                                             errorData));
      }

      if (String.IsNullOrEmpty(DbTypeName))
      {
        var errorData = new ErrorData();
        errorData.ErrorCode = ErrorCode.COLUMN_METADATA_VALIDATION_MISSING_DB_TYPE_NAME;
        errorData.ErrorType = ErrorType.PropertyValidation;
        validationErrors.Add(new ErrorObject("Property validation failed. Missing DbTypeName on DbColumnMetadata",
                                             errorData));
      }

      return validationErrors.Count == 0 ? true : false;
    }

    /// <summary>
    ///   Parse the specified hbmString
    /// </summary>
    /// <param name="hbmString"></param>
    /// <returns></returns>
    public static DbColumnMetadata FromHbmString(string hbmString)
    {
      var dbColumnMetadata = new DbColumnMetadata();

      dbColumnMetadata.TableName = GetStringSection("tn=", hbmString);
      Check.Require(!String.IsNullOrEmpty(dbColumnMetadata.TableName),
                    "Cannot find table name in string '{0}' using key 'tn='", hbmString);

      dbColumnMetadata.ColumnName = GetStringSection("cn=", hbmString);
      Check.Require(!String.IsNullOrEmpty(dbColumnMetadata.ColumnName),
                    "Cannot find column name in string '{0}' using key 'cn='", hbmString);

      dbColumnMetadata.PropertyName = GetStringSection("pn=", hbmString);
      Check.Require(!String.IsNullOrEmpty(dbColumnMetadata.PropertyName),
                    "Cannot find property name in string '{0}' using key 'pn='", hbmString);

      dbColumnMetadata.DbTypeName = GetStringSection("dbt=", hbmString);
      Check.Require(!String.IsNullOrEmpty(dbColumnMetadata.DbTypeName),
                    "Cannot find db type name in string '{0}' using key 'dbt='", hbmString);

      string maxLength = GetStringSection("ml=", hbmString);
      Check.Require(!String.IsNullOrEmpty(maxLength),
                    "Cannot find max length in string '{0}' using key 'ml='", hbmString);
      dbColumnMetadata.MaxLength = Convert.ToInt32(maxLength);

      string precision = GetStringSection("pr=", hbmString);
      Check.Require(!String.IsNullOrEmpty(precision),
                    "Cannot find precision in string '{0}' using key 'pr='", hbmString);
      dbColumnMetadata.Precision = Convert.ToInt32(precision);

      string scale = GetStringSection("scl=", hbmString);
      Check.Require(!String.IsNullOrEmpty(scale),
                    "Cannot find scale in string '{0}' using key 'sc='", hbmString);
      dbColumnMetadata.Scale = Convert.ToInt32(scale);

      string nullableFlag = GetStringSection("nl=", hbmString);
      Check.Require(!String.IsNullOrEmpty(nullableFlag),
                    "Cannot find nullable flag in string '{0}' using key 'nl='", hbmString);
      dbColumnMetadata.NullableFlag = Convert.ToInt32(nullableFlag);

      string primaryKeyFlag = GetStringSection("pk=", hbmString);
      Check.Require(!String.IsNullOrEmpty(primaryKeyFlag),
                    "Cannot find primary key flag in string '{0}' using key 'pk='", hbmString);
      dbColumnMetadata.PrimaryKeyFlag = Convert.ToInt32(primaryKeyFlag);

      string uniqueFlag = GetStringSection("uk=", hbmString);
      Check.Require(!String.IsNullOrEmpty(uniqueFlag),
                    "Cannot find unique key flag in string '{0}' using key 'uk='", hbmString);
      dbColumnMetadata.UniqueFlag = Convert.ToInt32(uniqueFlag);

      dbColumnMetadata.EnumAssemblyQualifiedTypeName = GetStringSection("en=[", hbmString);
      dbColumnMetadata.Label = GetStringSection("lbl=[", hbmString);
      dbColumnMetadata.Description = GetStringSection("desc=", hbmString);

      return dbColumnMetadata;
    }
    #endregion

    #region Public Properties

    public virtual string TableName { get; set; }
    public virtual string ColumnName { get; set; }
    public virtual string DbTypeName { get; set; }
    public virtual string CSharpTypeName { get; set; }
    public virtual int MaxLength { get; set; }
    public virtual int Precision { get; set; }
    public virtual int Scale { get; set; }
    public virtual int NullableFlag { get; set; }
    public virtual int PrimaryKeyFlag { get; set; }
    public virtual int UniqueFlag { get; set; }
    public virtual string EnumAssemblyQualifiedTypeName { get; set; }
    public virtual string Label { get; set; }
    public virtual string Description { get; set; }

    public string PropertyName { get; set; }
    public Type DataType { get; set; }
    public bool IsRequired { get { return NullableFlag == 1 ? false : true; } }
    public bool IsUnique { get { return UniqueFlag == 1 ? true : false; } }
    public bool IsPrimaryKey { get { return PrimaryKeyFlag == 1 ? true : false; } }

    public static string SqlQuery
    {
      get
      {
        return "GetColumnMetadataForSql";
      }
    }

    public static string OracleQuery
    {
      get
      {
        return "GetColumnMetadataForOracle";
      }
    }


    public static string TableNamesParameter
    {
      get
      {
        return "tableNames";
      }
    }

    public static string SeparatorParameter
    {
      get
      {
        return "separator";
      }
    }
    #endregion

    #region Private Methods
    private static string GetStringSection(string key, string hbmString)
    {
      string[] splits = hbmString.Split(new string[] { key }, StringSplitOptions.None);
      Check.Require(splits.Length >= 2, String.Format("Incorrect number of splits based on key '{0}'", key));

      string candidate = splits[1];

      // Last key
      if (key == "desc=")
      {
        return candidate;
      }

      string separator = ",";
      if (key == "lbl=[" || key == "en=[")
      {
        // Labels and enum type names are enclosed in <> to allow special characters 
        separator = "],";
      }

      int index = candidate.IndexOf(separator);
      return candidate.Substring(0, index);
    }
    #endregion

    #region Data


    #endregion
  }
}