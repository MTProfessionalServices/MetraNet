using MetraTech.Interop.Rowset;

namespace MetraTech.Core.Services.Quoting
{
  class QuoteXMLReport
  {
    public void CreateXML()
    {
      
    }

    public static System.Data.DataSet ExecuteSQLQuery(string sql)
    {
      IMTSQLRowset rowset = new MTSQLRowset();
      rowset.Init("\\dummy");
      rowset.SetQueryString(sql);
      rowset.Execute();
      return MetraTech.UI.Tools.Converter.GetDataSetFromRowset(rowset);
    }
  }
}
