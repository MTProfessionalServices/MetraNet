using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NHibernate;
using NHibernate.Criterion;
using NHibernate.Engine;
using NHibernate.SqlCommand;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class EnumFilterCriteria : SimpleExpression
  {
    public EnumFilterCriteria(string propertyName, 
                              object value, 
                              string op, 
                              string columnName,
                              string alias)
      :base(alias + propertyName, value, op)
    {
      ColumnName = columnName;
      Alias = alias;
    }

    #region AbstractCriterion Methods

    public override SqlString ToSqlString(ICriteria criteria, 
                                          ICriteriaQuery criteriaQuery, 
                                          IDictionary<string, IFilter> enabledFilters)
    {
      return new SqlString(Alias + ColumnName + Op + Value);
    }

    #endregion

    #region Public Properties
    public string ColumnName { get; set; }
    public string Alias { get; set; }
    #endregion
  }
}
