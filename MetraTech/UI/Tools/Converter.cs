using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;
using MetraTech.Interop.Rowset;
using MetraTech.SecurityFramework;
using Rowset = MetraTech.Interop.Rowset;

namespace MetraTech.UI.Tools
{

  /// <summary>
  /// Convert helps take one data type and convert to another
  /// </summary>
  public static class Converter
  {

    public static string GetJSON(object obj)
    {
      JavaScriptSerializer jss = new JavaScriptSerializer();
      jss.RegisterConverters(new JavaScriptConverter[] { new DateTimeConverter() });
      return jss.Serialize(obj);
    }

    /// <summary>
    /// GetDataViewFromRowset
    /// Gives back an appropriate DataView for binding to
    /// </summary>
    /// <param name="rs"></param>
    /// <returns></returns>
    public static DataView GetDataViewFromRowset(IMTSQLRowset rs)
    {
      DataView view = new DataView();
      view.Table = Converter.GetDataSetFromRowset(rs).Tables[0];
      return view;
    }

    /// <summary>
    /// GetDataSetFromRowset 
    /// Gives back an appropriate DataSet for binding to
    /// </summary>
    /// <param name="rs"></param>
    /// <returns></returns>
    public static DataSet GetDataSetFromRowset(IMTSQLRowset rs)
    {
      DataSet ds = new DataSet();
      ds.Namespace = "ds";

      // Create DataTable
      DataTable dataTable = new DataTable(ds.Namespace);

      if (rs == null)
        return null;

      if (rs.RecordCount > 0)
      {
        rs.MoveFirst();
      }

      // Add columns to table
      for (int i = 0; i < rs.Count; i++)
      {
        DataColumn column;
        string theType = rs.get_Type(i).ToString();
        switch (theType.ToUpper())  // need to add the right type, so we can use the built-in formating
        {
          case "INT32":
            column = new DataColumn(rs.get_Name(i), typeof(int));
            break;
          case "FLOAT":
            column = new DataColumn(rs.get_Name(i), typeof(decimal));
            break;
          case "DOUBLE":
            column = new DataColumn(rs.get_Name(i), typeof(decimal));
            break;
          case "TIMESTAMP":
            column = new DataColumn(rs.get_Name(i), typeof(DateTime));
            break;
          default:
            column = new DataColumn(rs.get_Name(i), typeof(string));
            break;
        }
        dataTable.Columns.Add(column);
      }

      // Add rows
      DataRow newRow;
      for (int j = 0; j < rs.RecordCount; j++)
      {
        newRow = dataTable.NewRow();
        for (int k = 0; k < rs.Count; k++)
        {
          newRow[rs.get_Name(k)] = rs.get_Value(k);
        }
        dataTable.Rows.Add(newRow);
        rs.MoveNext();
      }

      // Add table to DataSet
      ds.Tables.Add(dataTable);

      return ds;

    }

    /// <summary>
    /// Creates a CSV representation of the column headers of the rowset parameter
    /// </summary>
    /// <param name="rs">Rowset to extract column headers from</param>
    /// <returns>CSV representation of column headers</returns>
    public static string GetRowsetHeadersAsCSV(Rowset.IMTSQLRowset rs)
    {
      StringBuilder sb = new StringBuilder();

      if (rs == null)
      {
        return sb.ToString();
      }

      if (rs.Count == 0)
      {
        return sb.ToString();
      }

      rs.MoveFirst();

      //iterate through columns
      for (int i = 0; i < rs.Count; i++)
      {
        //get the name
        string columnName = rs.get_Name(i);
        
        //replace quotes with two sets of quotes
        columnName = columnName.Replace("\"","\"\"");
        
        //append separator
        if (i > 0)
        {
          sb.Append(",");
        }

        //append column name enclosed in quotes
        sb.Append("\"");
        sb.Append(columnName);
        sb.Append("\"");
      }

      return sb.ToString();
    }

    /// <summary>
    /// Iterates through all the columns and add corresponding values to a CSV string
    /// </summary>
    /// <param name="rs">Row to extract values</param>
    /// <returns>CSV representation of the current row</returns>
    public static string GetRowAsCSV(Rowset.IMTSQLRowset rs)
    {
      if (rs == null)
      {
        return string.Empty;
      }

      StringBuilder sb = new StringBuilder();

      //iterate through columns
      for (int i = 0; i < rs.Count; i++)
      {
        //get the value
        string columnValue = rs.get_Value(i).ToString();

        //replace quotes with two sets of quotes
        columnValue = columnValue.Replace("\"", "\"\"");

        //append separator
        if (i > 0)
        {
          sb.Append(",");
        }

        //append column name enclosed in quotes
        sb.Append("\"");
        sb.Append(columnValue);
        sb.Append("\"");
      }

      return sb.ToString();
    }

    /// <summary>
    /// Converts an IMTRowset to CSV
    /// </summary>
    /// <param name="rs">Rowset to convert to csv</param>
    /// <param name="start">Position of the first item to return, zero based</param>
    /// <param name="limit">Number of items to return</param>
    /// <param name="includeColumnHeaders">True to include column headers, False to skip them</param>
    /// <returns></returns>
    public static string RowsetToCSV(Rowset.IMTSQLRowset rs, int start, int limit, bool includeColumnHeaders)
    {
      StringBuilder sb = new StringBuilder();

      //bad recordset
      if (rs == null)
      {
        return sb.ToString();
      }

      //should column headers be included
      if (includeColumnHeaders)
      {
        sb.Append(GetRowsetHeadersAsCSV(rs));
        sb.Append("\n");
      }

      //short-circuit if no records
      if (rs.RecordCount == 0)
      {
        return sb.ToString();
      }

      rs.MoveFirst();
      int readRows = 0;
      bool bFirst = true;

      //iterate through records
      for (int i = 0; i < rs.RecordCount; i++)
      {
        if ((readRows >= start) && (readRows < start + limit))
        {

          //append row separator
          if (!bFirst)
          {
            sb.Append("\n");
          }
          else
          {
            bFirst = false;
          }

          //add the row
          sb.Append(GetRowAsCSV(rs));

        }

        //go to the next record
        readRows++;
        rs.MoveNext();
      }

      return sb.ToString();
    }


    /// <summary>
    /// GetRowsetAsJson - takes in an IMTRowset and returns Json string
    /// </summary>
    /// <param name="rs"></param>
    /// <param name="start"></param>
    /// <param name="limit"></param>
    /// <returns></returns>
    public static string GetRowsetAsJson(Rowset.IMTRowSet rs, int start, int limit)
    {
      StringBuilder sb = new StringBuilder();

      sb.Append("[");
      rs.MoveFirst();
      bool bFirst = true;
      int count = 0;
      while (!Convert.ToBoolean(rs.EOF))
      {
        if (count >= start && count < start + limit)
        {
          if (!bFirst)
          {
            sb.Append(",");
          }
          else
          {
            bFirst = false;
          }
          sb.Append("{");
          bool bFirst2 = true;
          for (int i = 0; i < rs.Count; i++)
          {
            if (!bFirst2)
            {
              sb.Append(",");
            }
            else
            {
              bFirst2 = false;
            }
            //SECENG: Might also need to do HTML encoding because these JSON fields are used in HTML tags and attributes
            //sb.Append(String.Format("\"{0}\":\"{1}\"", rs.get_Name(i).ToString().ToLower(), rs.get_Value(i).ToString()));
            sb.Append(
                String.Format(
                    "\"{0}\":\"{1}\"",
                    SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(
                        EncoderEngineCategory.JavaScript.ToString(),
                        new ApiInput(rs.get_Name(i).ToString().ToLower())),
                    SecurityKernel.Encoder.Api.ExecuteDefaultByCategory(
                        EncoderEngineCategory.JavaScript.ToString(),
                        new ApiInput(rs.get_Value(i).ToString()))));
          }
          sb.Append("}");
        }

        count++;
        rs.MoveNext();
      }
      sb.Append("]");
      string json = String.Format("\"TotalRows\":\"{0}\",\"records\":{1}", rs.RecordCount.ToString(), sb.ToString());
      return json;
    }

  }


  /// <summary>
  /// JSON DateTimeConverter that will not take timezone into account.
  /// see:  http://www.west-wind.com/weblog/posts/471402.aspx
  ///       http://forums.asp.net/p/1061850/1526210.aspx
  /// </summary>
  public class DateTimeConverter : JavaScriptConverter
  {
    public override object Deserialize(IDictionary<string, object> dictionary, Type type, JavaScriptSerializer serializer)
    {
      string s = dictionary["timestamp"].ToString();
      
      //{"#$#$":"new Date(-62135596800000)#$#$"}
      s = s.Replace("\"#$#$\":\"new Date(", "");
      s = s.Replace(")#$#$\"", "");
      long num = long.Parse(s);
      long minTimeTicks = (new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).Ticks;
      return new DateTime((num * 10000) + minTimeTicks, DateTimeKind.Utc);
    }


    public override IDictionary<string, object> Serialize(object obj, JavaScriptSerializer serializer)
    {
      DateTime datetime = (DateTime)obj;

      StringBuilder sb = new StringBuilder();  
      long minTimeTicks = (new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).Ticks; 
      sb.Append("new Date(" + ( datetime.Ticks - minTimeTicks ) / 10000 + ")"); 
      sb.Append("#$#$");

      Dictionary<string, object> values = new Dictionary<string, object>();
      DateTime d = (DateTime)obj;
      values.Add("#$#$", sb.ToString());

      return values;
    }

    public override IEnumerable<Type> SupportedTypes
    {
      get { yield return typeof(DateTime); }
    }

  }

}
