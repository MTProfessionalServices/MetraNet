using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;

namespace MetraTech.BusinessEntity.ImportExport.CSV
{
  public class CSVWriter : IDisposable
  {
    private StreamWriter writer;
    public CSVWriter(string FileName)
    {
      writer = new StreamWriter(FileName, false);
    }
    //public char Delimiter = ','; //delimiter fields with this char
    //public char Quote = '"'; // surround fields with this char

    public void WriteHeader(List<string> header)
    {
      string headerStr = string.Join(",", header.ToArray());
      writer.WriteLine(headerStr);
    }

    public void Close()
    {
      if (writer != null)
      {
        writer.Close();
        writer = null;
      }
    }

    #region IDisposable Members

    public void Dispose()
    {
      Close();
    }

    #endregion

    ~CSVWriter()
    {
      Dispose();
    }

    public void WriteRow(List<string> values)
    {
      string row = "";
      foreach (string value in values)
      {
        if (row != "") row += ",";
        string escapedValue = EscapeQuote(value);
        row += string.Format(@"""{0}""", escapedValue);
      }
      writer.WriteLine(row);
    }

    private string EscapeQuote(string str)
    {
      str = Regex.Replace(str, @"""", @""""""); //replace single quote in the field with double quote
      return str;
    }
  }
}
