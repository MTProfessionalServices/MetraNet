using System;
using System.IO;
using System.Xml;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;

namespace MetraTech.AR
{
  /// <summary>
  /// utility class to construct ARDocuments using an XmlWriter.
  /// </summary>
  [ComVisible(false)]
  public class ARDocWriter : XmlTextWriter
  {
    private TextWriter mTextWriter;

    /// <summary>
    /// only two ways to construct an ARDocWriter
    /// </summary>
    /// <returns></returns>
    /// 
    public static ARDocWriter CreateWithARDocuments()
    {
      ARDocWriter writer = new ARDocWriter(new StringWriter());
      writer.WriteStartElement("ARDocuments");
      return writer;
    }
    public static ARDocWriter CreateWithARDocuments(string sAccountNameSpace)
    {
      ARDocWriter writer = new ARDocWriter(new StringWriter());
      writer.WriteStartElement("ARDocuments");
      writer.WriteAttributeString("ExtNamespace", sAccountNameSpace);
      return writer;
    }

    public void WriteARDocumentStart(string arDocTag)
    {
      WriteStartElement("ARDocument");
      WriteStartElement(arDocTag);
    }
    
    public void WriteARDocumentEnd()
    {
      WriteEndElement(); //arDocTag
      WriteEndElement(); //ARDocument
    }

    public string GetXmlAndClose()
    {
      WriteEndElement(); //ARDocuments
      Close();

      return mTextWriter.ToString();
    }

    /// <summary>
    /// private constructor. Clients use CreateXXX() factory methods
    /// </summary>
    private ARDocWriter(TextWriter textWriter)
      : base(textWriter)
    {
      mTextWriter = textWriter;
    }
  }
}
