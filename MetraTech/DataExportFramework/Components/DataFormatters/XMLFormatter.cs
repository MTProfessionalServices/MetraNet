using System;
using System.Collections;
using System.IO;
//using MetraTech;
using MetraTech.DataAccess;
using System.Xml;
using System.Runtime.InteropServices;
using System.Text;

namespace MetraTech.DataExportFramework.Components.DataFormatters
{
  /// <summary>
  /// Output to XML File
  /// </summary>
  public class XMLFormatter : BaseFormatter
  {
    public XMLFormatter() : base() { __delimiter = ""; }

    //protected override int WriteToXMLOutFile(IMTDataReader oReader, bool bPrintHeaderFields, bool bAppendToExistingFile)
    protected override int WriteToOutFile(IMTDataReader oReader, bool bPrintHeaderFields, bool bAppendToExistingFile)
    {
      this.__printHeaderFields = bPrintHeaderFields;
      //StreamWriter oWriter = null;
      int iFieldCount;
      int iRowCount;


      using (XmlWriter owriter = XmlWriter.Create(this.__outFileName))
      {
      owriter.WriteStartDocument();

        iRowCount = 1;

        try
        {
      
         owriter.WriteStartElement("DataExport");

          while (oReader.Read())
          {
            string xmlFieldName = "";

            string xmlFieldValue = "";
            
           // owriter.WriteStartElement("DataExport");
            
            for (iFieldCount = 0; iFieldCount < oReader.FieldCount; iFieldCount++)
            
            {
            xmlFieldName = oReader.GetName(iFieldCount);

            xmlFieldValue = oReader.GetValue(iFieldCount).ToString();

            owriter.WriteElementString(xmlFieldName, xmlFieldValue);
            }
            
            //owriter.WriteEndElement();
            iRowCount++;
           
          }


          owriter.WriteEndElement();

          return iRowCount;

          this.__logger.LogDebug("Number of rows written to the file " + iRowCount.ToString());
        }

        catch (System.Exception e)
        {
          this.__logger.LogError("An error occurred while exporting data to XML Format file \n" + e.ToString());
          throw (e);
        }

        owriter.Flush();
        owriter.Close();
      }

    }
    
  
    //By Default all fields returned by the report query will be exported to XML o/p file. Following methods are not required
    //but because those are used by common code, I am not removing those.

    private bool CheckForInvalidFields(string sInFields)
    {
      IEnumerator enO = this.__arSpecialFormatInfo.GetEnumerator();
      while (enO.MoveNext())
      {
        string[] sFields = sInFields.Split(new Char[] { Convert.ToChar(__delimiter) });
        bool bFound = false;
        foreach (string sField in sFields)
        {
          if (sField.ToLower() == ((FieldDefinition)enO.Current).FieldName.ToLower())
            bFound = true;
        }
        if (!bFound)
          throw new Exception("The field \"" + ((FieldDefinition)enO.Current).FieldName + " does not exist in the query");
      }
      return true;
    }

    private string FieldsToStreamOut(string sInFields)
    {
      string sOut = "";
      IEnumerator enO = this.__arSpecialFormatInfo.GetEnumerator();
      while (enO.MoveNext())
      {
        string[] sFields = sInFields.Split(new Char[] { Convert.ToChar(this.__delimiter) });
        foreach (string sField in sFields)
        {
          if (sField.ToLower() == ((FieldDefinition)enO.Current).FieldName.ToLower())
          {
            if (this.__useQuotedIdentifiers)
              sOut += "\"" + ((FieldDefinition)enO.Current).DisplayName + "\"" + this.__delimiter;
            else
              sOut += ((FieldDefinition)enO.Current).DisplayName + this.__delimiter;
          }
        }
      }
      if (sOut.Trim().Length > 0)
        return sOut.Substring(0, sOut.Length - 1);
      else
        return sOut;
    }

  }

}


