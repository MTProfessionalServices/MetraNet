using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace MetraTech.UI.Controls.MTLayout
{
  [Serializable]
  public class SQLQueryInfoLayout
  {
    public string QueryDir;
    public string QueryName;
    public string SQLString;

    [XmlArrayItem("QueryParameter")]
    public List<SQLQueryParamLayout> QueryParameters = new List<SQLQueryParamLayout>();
  }

  [Serializable]
  public class SQLQueryParamLayout
  {
    public string Name;
    public string Value;
    public string DataType;
  }
}
