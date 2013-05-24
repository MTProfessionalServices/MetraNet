using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;
using MetraTech.Interop.MTProductCatalog;

using MetraTech.Interop.RCD;
//using MetraTech.Interop.GenericCollection;
using MetraTech.Xml;
using System.Xml;


namespace  MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for ReasonCodeFileReader.
  /// </summary>
  /// 
  [Guid("b3819dbc-0a17-4be2-9a09-39463a43eb87")]
  public interface IReasonCodeFileReader
  {
    IReasonCode FindReasonCodeByName(IMTSessionContext apCTX, string aName);
    MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodes(IMTSessionContext apCTX);
  }

	[ClassInterface(ClassInterfaceType.None)]
  [Guid("60d695fd-2817-4a43-8c14-b8174ae5cf8d")]
  public class ReasonCodeFileReader : IReasonCodeFileReader
  {
    private IMTRcd mRcd;
    private MetraTech.Interop.GenericCollection.IMTCollection mReasonCodes;

   
    public ReasonCodeFileReader()
    { 
      mRcd = new MTRcdClass();
      mReasonCodes = new MetraTech.Interop.GenericCollection.MTCollectionClass();
    }

    public MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodes(IMTSessionContext apCTX)
    {
      if(mReasonCodes.Count == 0)
        return GetReasonCodesInternal(apCTX);
      else
        return mReasonCodes;

    }
    
    public IReasonCode FindReasonCodeByName(IMTSessionContext apCTX, string aName)
    {
      if(mReasonCodes.Count == 0)
        GetReasonCodesInternal(apCTX);
      foreach(IReasonCode code in mReasonCodes)
      {
        if(string.Compare(code.Name, aName, true) == 0)
          return code;
      }
      throw new AdjustmentException(string.Format("Reason Code {0} not found", aName));
    }
    
    
    protected MetraTech.Interop.GenericCollection.IMTCollection GetReasonCodesInternal(IMTSessionContext apCTX) 
    {
      try
      {
        MTRcdFileList files = (MTRcdFileList)MetraTech.Xml.MTXmlDocument.FindFilesInExtensions("ReasonCodes.xml");
        MTXmlDocument doc = new MTXmlDocument();
        mReasonCodes = new MetraTech.Interop.GenericCollection.MTCollectionClass();

        foreach(string file in files)
        {
          doc.Load(file);
          XmlNodeList nodes = doc.SelectNodes("mt_config/reasoncode");
          foreach(XmlNode node in nodes)
          {
            IReasonCode code = new ReasonCode();
            code.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)apCTX);
            code.FromXML(node.OuterXml);
            mReasonCodes.Add(code);
          }
        
        }
      }
      catch(System.Exception ex)
      {
        throw ex;
      }
      return mReasonCodes;
    }

    

   
  }

 
}
