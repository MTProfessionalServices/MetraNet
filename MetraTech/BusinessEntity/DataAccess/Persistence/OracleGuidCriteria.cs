using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Remoting.Metadata.W3cXsd2001;
using NHibernate;
using NHibernate.Criterion;
using NHibernate.Engine;
using NHibernate.SqlCommand;

using MetraTech.Basic;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class OracleGuidCriteria : SimpleExpression
  {
    public OracleGuidCriteria(string propertyName, 
                              object value, 
                              string op, 
                              string columnName)
      :base(propertyName, value, op)
    {
      Check.Require(value is Guid, "value must be a Guid");
      ColumnName = columnName;
    }

    #region AbstractCriterion Methods

    public override SqlString ToSqlString(ICriteria criteria, 
                                          ICriteriaQuery criteriaQuery, 
                                          IDictionary<string, IFilter> enabledFilters)
    {
      // Oracle stores Guids differently from SQL Server. The Oracle storage maps 
      // to the Byte array of the Guid. The OracleGuidCriteria class allows us to specify
      // the Guid filter criteria as a string by converting the Guid to the byte array representation.
      // Example: The Guid '32929302-2cc9-40a6-ac5a-f620d0fc17db' is stored in Oracle as
      //                   '02939232C92CA640AC5AF620D0FC17DB' 
      // 

      byte[] byteArray = ((Guid) Value).ToByteArray();
      string parameterValue = new SoapHexBinary(byteArray).ToString(); 
      var sqlString = new SqlString(ColumnName + Op + "'" + parameterValue + "'");
      return sqlString;
    }

    #endregion

    #region Public Properties
    public string ColumnName { get; set; }
    #endregion
  }
}
