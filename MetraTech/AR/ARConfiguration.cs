using System;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;
using System.Xml;
using System.Collections;
using System.Collections.Generic;

[assembly: GuidAttribute("1D6DB558-47B8-4f12-AA3C-21B153B9470C")]

namespace MetraTech.AR
{
  /// <summary>
  /// Access to AR configuration,
  /// cached as singleton
  /// </summary>
  [ComVisible(false)]
  public class ARConfiguration
	{
    //data
    private static ARConfiguration smInstance = null;

    private bool mAREnabled;
    private string mARConfigObject;
    private string mARReaderObject;
    private string mARWriterObject;
    private string mAccountNameSpace;
    private ArrayList mAccountNameSpaces;
    private string mBatchNameSpace;
    private string mPaymentBatchPrefix;
    private string mARAdjustmentBatchPrefix;
    private string mPostBillAdjustmentBatchPrefix;
    private string mInvoiceBatchPrefix;
    private string mMoveBalanceBatchPrefix;
    private string mPaymentIDPrefix;
    private string mARAdjustmentIDPrefix;
    private string mPostBillAdjustmentIDPrefix;
    private string mCompensatingPostBillAdjustmentIDPrefix;
    private string mCompensatingPostBillAdjustmentDescriptionPrefix;
    private string mInvoiceIDPrefix;
    private string mInvoiceAdjustmentIDPrefix;

    private Dictionary<string, string> mDatabaseToInterfacePropertyMappings;

    // public functions
    public static ARConfiguration GetInstance()
    {
      if (smInstance == null)
      {
        // use double-check locking to avoid lock if we already have the single instance.
        lock (typeof(ARConfiguration))
        {
          if( smInstance == null)
          {
            smInstance = new ARConfiguration();
          }
        }
      }
      return smInstance;
    }

    public bool IsAREnabled                     { get { return mAREnabled; }}
    public string ARConfigObject                { get { return mARConfigObject; }}
    public string ARReaderObject                { get { return mARReaderObject; }}
    public string ARWriterObject                { get { return mARWriterObject; }}
    public string AccountNameSpace              { get { return mAccountNameSpace; }}
    public ArrayList AccountNameSpaces          { get { return mAccountNameSpaces; }}
    public string BatchNameSpace                { get { return mBatchNameSpace; }}
    public string PaymentBatchPrefix            { get { return mPaymentBatchPrefix; }}
    public string ARAdjustmentBatchPrefix       { get { return mARAdjustmentBatchPrefix; }}
    public string PostBillAdjustmentBatchPrefix { get { return mPostBillAdjustmentBatchPrefix; }}
    public string InvoiceBatchPrefix            { get { return mInvoiceBatchPrefix; }}
    public string MoveBalanceBatchPrefix        { get { return mMoveBalanceBatchPrefix; }}
    public string PaymentIDPrefix               { get { return mPaymentIDPrefix; }}
    public string ARAdjustmentIDPrefix          { get { return mARAdjustmentIDPrefix; }}
    public string PostBillAdjustmentIDPrefix    { get { return mPostBillAdjustmentIDPrefix; }}
    public string CompensatingPostBillAdjustmentIDPrefix { get { return mCompensatingPostBillAdjustmentIDPrefix;  }}
    public string CompensatingPostBillAdjustmentDescriptionPrefix { get { return mCompensatingPostBillAdjustmentDescriptionPrefix;  }}
    public string InvoiceIDPrefix               { get { return mInvoiceIDPrefix; }}
    public string InvoiceAdjustmentIDPrefix     { get { return mInvoiceAdjustmentIDPrefix; }}

    public Dictionary<string, string> DatabaseToInterfacePropertyMappings { get { return mDatabaseToInterfacePropertyMappings; } }
    //private functions

    private ARConfiguration()
    {
      const string ARExtension = "AR";
      const string ARConfigFile = "config\\AR\\ARConfig.xml";
      const string ARPropertyMappingFile = "config\\AR\\ARDatabaseToInterfacePropertyMappings.xml";

      Logger logger = new Logger("[ARConfiguration]");
      logger.LogDebug("loading AR config file {0}/{1}", ARExtension, ARConfigFile);

      bool fileFound = false; 
      try
      {
 
        //load config file
        MTXmlDocument doc = new MTXmlDocument();
        
        doc.LoadExtensionConfigFile(ARExtension, ARConfigFile);
     
        mAREnabled = doc.GetNodeValueAsBool("//AREnabled");
        mARConfigObject = doc.GetNodeValueAsString("//ARConfigObject");
        mARReaderObject = doc.GetNodeValueAsString("//ARReaderObject");
        mARWriterObject = doc.GetNodeValueAsString("//ARWriterObject");

        //Read in all the account namespace entries
        mAccountNameSpaces = new ArrayList();
        XmlNodeList subNodes = doc.SelectNodes("//AccountNameSpace");
        for (int i=0; i<subNodes.Count; i++)
        {
          mAccountNameSpaces.Add(subNodes[i].InnerText);
        }
        
        //For now, set the mAccountNameSpace entry to the first value
        mAccountNameSpace = mAccountNameSpaces[0].ToString();

        mBatchNameSpace = doc.GetNodeValueAsString("//BatchNameSpace");
        mPaymentBatchPrefix = doc.GetNodeValueAsString("//PaymentBatchPrefix");
        mARAdjustmentBatchPrefix = doc.GetNodeValueAsString("//ARAdjustmentBatchPrefix");
        mPostBillAdjustmentBatchPrefix = doc.GetNodeValueAsString("//PostBillAdjustmentBatchPrefix");
        mInvoiceBatchPrefix = doc.GetNodeValueAsString("//InvoiceBatchPrefix");
        mMoveBalanceBatchPrefix = doc.GetNodeValueAsString("//MoveBalanceBatchPrefix");
        mPaymentIDPrefix = doc.GetNodeValueAsString("//PaymentIDPrefix");
        mARAdjustmentIDPrefix = doc.GetNodeValueAsString("//ARAdjustmentIDPrefix");
        mPostBillAdjustmentIDPrefix = doc.GetNodeValueAsString("//PostBillAdjustmentIDPrefix");
        mCompensatingPostBillAdjustmentIDPrefix = doc.GetNodeValueAsString("//CompensatingPostBillAdjustmentIDPrefix");
        mCompensatingPostBillAdjustmentDescriptionPrefix = doc.GetNodeValueAsString("//CompensatingPostBillAdjustmentDescriptionPrefix");
        mInvoiceIDPrefix = doc.GetNodeValueAsString("//InvoiceIDPrefix");
        mInvoiceAdjustmentIDPrefix = doc.GetNodeValueAsString("//InvoiceAdjustmentIDPrefix");

        fileFound = true;
      }
      catch (System.IO.FileNotFoundException)
      {
        fileFound = false;
      }
      catch (System.IO.DirectoryNotFoundException)
      {
        fileFound = false;
      }

      if (fileFound)
      {
        try
        {
          //load mappings used to translate database property names to xml tag names
          //by adapters
          MTXmlDocument doc = new MTXmlDocument();

          doc.LoadExtensionConfigFile(ARExtension, ARPropertyMappingFile);

          mDatabaseToInterfacePropertyMappings = new Dictionary<string, string>();

          XmlNodeList subNodes = doc.SelectNodes("//Mapping");
          for (int i = 0; i < subNodes.Count; i++)
          {
            try
            {
              mDatabaseToInterfacePropertyMappings.Add(subNodes[i].SelectSingleNode("DatabaseProperty").InnerText, subNodes[i].SelectSingleNode("XmlTag").InnerText);
            }
            catch (ArgumentException)
            {
              logger.LogError("Duplicate mapping for property {0} in {1}. Ignoring additional mapping.",subNodes[i].SelectSingleNode("DatabaseProperty").InnerText, ARPropertyMappingFile);
            }
            catch (Exception ex)
            {
              logger.LogError("Exception adding Database/Interface property mappings: {0}", ex.Message);
            }
          }
        }
        catch (System.IO.FileNotFoundException)
        {
          //fileFound = false;
        }
        catch (System.IO.DirectoryNotFoundException)
        {
          //fileFound = false;
        }
        catch (Exception)
        {
          mDatabaseToInterfacePropertyMappings = null;
        }
      }

      if (!fileFound)
      {
        //config file not found, mark as disabled, leave strings empty
        logger.LogInfo("AR config file '{0}/{1}' not found. AR disabled.", ARExtension, ARConfigFile);
        mAREnabled = false;
      }
    }
  }

  [Guid("8ACAC417-B6C5-4107-82F9-16072B3D8608")]
  public interface IARConfigurationProxy
  {
    bool   IsAREnabled {get;}
    string ARConfigObject {get;}
    string ARReaderObject {get;}
    string ARWriterObject {get;}
    string AccountNameSpace {get;}
    string AccountNameSpaces {get;}
    string BatchNameSpace {get;}
    string PaymentBatchPrefix {get;}
    string ARAdjustmentBatchPrefix {get;}
    string PostBillAdjustmentBatchPrefix {get;}
    string InvoiceBatchPrefix {get;}
    string MoveBalanceBatchPrefix {get;}
    string PaymentIDPrefix {get;}
    string ARAdjustmentIDPrefix {get;}
    string PostBillAdjustmentIDPrefix {get;}
    string CompensatingPostBillAdjustmentIDPrefix {get;}
    string CompensatingPostBillAdjustmentDescriptionPrefix {get;}
    string InvoiceIDPrefix {get;}
    string InvoiceAdjustmentIDPrefix {get;}
  };

  /// <summary>
  /// Proxy to ARConfiguration.
  /// Needed for access through COM (a COM client cannot call static methods).
  /// </summary>
  [Guid("1BA6C600-D861-49ee-9464-F29F4743EC5F")]
  [ClassInterface(ClassInterfaceType.None)]
  public class ARConfigurationProxy : IARConfigurationProxy
  {
    public ARConfigurationProxy() {}
    public bool IsAREnabled                     { get { return ARConfiguration.GetInstance().IsAREnabled; }}
    public string ARConfigObject                { get { return ARConfiguration.GetInstance().ARConfigObject; }}
    public string ARReaderObject                { get { return ARConfiguration.GetInstance().ARReaderObject; }}
    public string ARWriterObject                { get { return ARConfiguration.GetInstance().ARWriterObject; }}
    public string AccountNameSpace              { get { return ARConfiguration.GetInstance().AccountNameSpace; }}
    public string AccountNameSpaces             
    {
      get 
      {
        string[] temp = (string[]) ARConfiguration.GetInstance().AccountNameSpaces.ToArray(typeof(string));
        return string.Join(";",temp);
      }
    }
    public string BatchNameSpace                { get { return ARConfiguration.GetInstance().BatchNameSpace; }}
    public string PaymentBatchPrefix            { get { return ARConfiguration.GetInstance().PaymentBatchPrefix; }}
    public string ARAdjustmentBatchPrefix       { get { return ARConfiguration.GetInstance().ARAdjustmentBatchPrefix; }}
    public string PostBillAdjustmentBatchPrefix { get { return ARConfiguration.GetInstance().PostBillAdjustmentBatchPrefix; }}
    public string InvoiceBatchPrefix            { get { return ARConfiguration.GetInstance().InvoiceBatchPrefix; }}
    public string MoveBalanceBatchPrefix        { get { return ARConfiguration.GetInstance().MoveBalanceBatchPrefix; }}
    public string PaymentIDPrefix               { get { return ARConfiguration.GetInstance().PaymentIDPrefix; }}
    public string ARAdjustmentIDPrefix          { get { return ARConfiguration.GetInstance().ARAdjustmentIDPrefix; }}
    public string PostBillAdjustmentIDPrefix    { get { return ARConfiguration.GetInstance().PostBillAdjustmentIDPrefix; }}
    public string CompensatingPostBillAdjustmentIDPrefix { get { return ARConfiguration.GetInstance().CompensatingPostBillAdjustmentIDPrefix; }}
    public string CompensatingPostBillAdjustmentDescriptionPrefix { get { return ARConfiguration.GetInstance().CompensatingPostBillAdjustmentDescriptionPrefix; }}
    public string InvoiceIDPrefix               { get { return ARConfiguration.GetInstance().InvoiceIDPrefix; }}
    public string InvoiceAdjustmentIDPrefix     { get { return ARConfiguration.GetInstance().InvoiceAdjustmentIDPrefix; }}
  };
}