using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.BusinessEntity.ImportExport.Metadata;

namespace MetraTech.BusinessEntity.ImportExport.Persistence
{
  public class StatementBuilder
  {
    protected TableMetadata Table;
    public string BuildSelectStatement(TableMetadata table)
    {
      this.Table = table;
      string statement = string.Format("SELECT {0} FROM {1}",
        BuildFromClause(),
        Table.Name);
      return statement;
    }

    public string BuildInsertStatement(TableMetadata table)
    {
      this.Table = table;
      string statement = string.Format("INSERT INTO {0} ({1}) VALUES ({2})",
        Table.Name,
        BuildInsertFields(),
        BuildValuesParamList());
      return statement;

    }

    public string BuildDeleteStatement(TableMetadata table)
    {
      this.Table = table;
      string statement = string.Format("delete from {0}", Table.Name);
      return statement;
    }

    protected string BuildValuesParamList()
    {
      string valuesStr = "";
      foreach (FieldMetadata field in Table.Fields)
      {
        if (valuesStr != "") valuesStr += ", ";
        valuesStr += StringParamToType(field);
      }
      return valuesStr;
    }

    protected virtual string StringParamToType(FieldMetadata field)
    {
      return "?";
    }

    protected string BuildInsertFields()
    {
      string fieldsStr = "";
      foreach (FieldMetadata field in Table.Fields)
      {
        if (fieldsStr != "") fieldsStr += ", ";
        fieldsStr += field.Name;
      }
      return fieldsStr;
    }

    private string BuildFromClause()
    {
      string fromClause = "";
      if (Table.Fields.Count == 0)
        throw new Exception(string.Format("Unable to build from clause for table {0}, as there is no fields in the table", Table.Name));
      foreach (FieldMetadata field in Table.Fields)
      {
        if (fromClause != "") fromClause += ", ";
        fromClause += field.Name;
      }
      return fromClause;
    }


  }

  public class OracleStatementBuilder : StatementBuilder
  {
    protected override string StringParamToType(FieldMetadata field)
    {
      switch (field.Type)
      {
        case MetraTech.BusinessEntity.Core.PropertyType.Boolean:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.DateTime:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.Decimal:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.Double:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.Enum:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.Guid:
          return "hextoraw(REPLACE(?, '-' ))";
        //break;
        case MetraTech.BusinessEntity.Core.PropertyType.Int32:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.Int64:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.String:
          break;
        default:
          break;
      }
      return base.StringParamToType(field);
    }
  }

  public class SQLServerStatementBuilder : StatementBuilder
  {
    protected override string StringParamToType(FieldMetadata field)
    {
      switch (field.Type)
      {
        case MetraTech.BusinessEntity.Core.PropertyType.Boolean:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.DateTime:
          //return "convert(datetime,?)";
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.Decimal:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.Double:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.Enum:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.Guid:
          return "CONVERT(uniqueidentifier, ?)";
          //break;
        case MetraTech.BusinessEntity.Core.PropertyType.Int32:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.Int64:
          break;
        case MetraTech.BusinessEntity.Core.PropertyType.String:
          break;
        default:
          break;
      }
      return base.StringParamToType(field);
    }

  }


  public class StatementBuilderFactory
  {
    public static StatementBuilder GetStatementBuilder(bool isOracle)
    {
      StatementBuilder statementBuilder;
      if (isOracle)
      {
        statementBuilder = new OracleStatementBuilder();
      }
      else
      {
        statementBuilder = new SQLServerStatementBuilder();
      }
      return statementBuilder;
    }
  }
}
