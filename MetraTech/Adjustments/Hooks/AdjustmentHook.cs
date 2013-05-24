using System;
using System.Xml;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;
using MetraTech.Adjustments;
using MetraTech.Interop.MTHooklib;
using MetraTech.Interop.RCD;
using  ProdCat = MetraTech.Interop.MTProductCatalog;

[assembly: GuidAttribute("1eb27245-8520-4fa8-bdc4-12da390a4300")]

namespace MetraTech.Adjustments.Hooks
{
	/// <summary>
	/// Summary description for AdjustmentHook.
	/// </summary>
	/// 
  [Guid("9996ef4f-7446-4622-a601-1f86c53bfab4")]
  [ClassInterface(ClassInterfaceType.None)]
  public class AdjustmentHook : IMTHook
  {
    public AdjustmentHook()
    {
      mLog = new Logger("[AdjustmentHook]");
      mRcd = new MTRcdClass();
    }

    public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
    {
			try
			{
				MTRcdFileList files = (MTRcdFileList)MetraTech.Xml.MTXmlDocument.FindFilesInExtensions("ApplicabilityRules.xml");
				MTXmlDocument doc = new MTXmlDocument();

				//HACK: get session context from product catalog
				//language code will be initialized to 840 (US).
				//Other hooks do it...
				ProdCat.IMTProductCatalog ProdCat = new ProdCat.MTProductCatalogClass();

      
				foreach(string file in files)
				{
					doc.Load(file);
					XmlNodeList nodes = doc.SelectNodes("mt_config/applicabilityrule");
					foreach(XmlNode node in nodes)
					{
						IApplicabilityRule rule = new ApplicabilityRule();
						rule.SetSessionContext(ProdCat.GetSessionContext());
						rule.FromXML(node.OuterXml);
						rule.Save();
					}
        
				}


				//Process Reason Codes
				files = (MTRcdFileList)MetraTech.Xml.MTXmlDocument.FindFilesInExtensions("ReasonCodes.xml");

       
				foreach(string file in files)
				{
					doc.Load(file);
					XmlNodeList nodes = doc.SelectNodes("mt_config/reasoncode");
					foreach(XmlNode node in nodes)
					{
						IReasonCode code = new ReasonCode();
						code.SetSessionContext(ProdCat.GetSessionContext());
						code.FromXML(node.OuterXml);
						code.Save();
					}
        
				}
      }
			catch(System.Exception ex)
			{
				mLog.LogError(ex.ToString());
				throw ex;
			}
    }



    private MetraTech.Logger mLog;
    private IMTRcd mRcd;
  }
}
