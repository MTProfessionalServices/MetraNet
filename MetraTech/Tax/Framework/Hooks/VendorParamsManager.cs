using System;
using System.Collections.Generic;
using System.Xml;
using System.IO;
using System.ComponentModel;

using MetraTech.DataAccess;
using MetraTech.Xml;

namespace MetraTech.Tax.Framework
{
  /// <summary>
  /// This class represents a tax vendor parameter (or a row in the
  /// t_tax_vendor_param table).
  /// </summary>
  public class TaxParam
  {
    /// <summary>
    /// Name of the vendor parameter.
    /// </summary>
    public string Name;

    /// <summary>
    /// Type of the vendor parameter.
    /// </summary>
    public MTParameterType Type;

    /// <summary>
    /// The default value to use for the vendor parameter if the parameter 
    /// is not specified.
    /// </summary>
    public string Default;

    /// <summary>
    /// A description of the tax vendor parameter.
    /// </summary>
    public string Description;

    /// <summary>
    /// Create a loggable string version of tax vendor parameter.
    /// </summary>
    /// <returns></returns>
    public override string ToString()
    {
      return string.Format("Name: {0}, Type: {1}, Default: {2}, Description: {3}", Name, Type.ToString(), Default, Description);
    }

    /// <summary>
    /// Check if this tax vendor parameter is a legal configuration.
    /// If not, thrown an exception.
    /// </summary>
    public void Validate()
    {
      if (Name == string.Empty) throw new InvalidTaxVendorParamException("Name cannot be empty.");
      TypeConverter converter;
      switch (Type)
      {
        case MTParameterType.Integer:
          converter = TypeDescriptor.GetConverter(typeof(Int32));
          break;
        case MTParameterType.String:
          converter = TypeDescriptor.GetConverter(typeof(String));
          break;
        case MTParameterType.WideString:
          converter = TypeDescriptor.GetConverter(typeof(String));
          break;
        case MTParameterType.DateTime:
          converter = TypeDescriptor.GetConverter(typeof(DateTime));
          break;
        case MTParameterType.Decimal:
          converter = TypeDescriptor.GetConverter(typeof(Decimal));
          break;
        case MTParameterType.Boolean:
          converter = TypeDescriptor.GetConverter(typeof(Boolean));
          break;
        case MTParameterType.BigInteger:
          converter = TypeDescriptor.GetConverter(typeof(Int64));
          break;

        case MTParameterType.Binary:
        case MTParameterType.Blob:
        case MTParameterType.NText:
        case MTParameterType.Text:
        case MTParameterType.Guid:
        default:
          throw new InvalidTaxVendorParamException(string.Format("Parameter type {0} is currently not supported", Type.ToString()));
      }

      // If a default is specified, make sure we can convert
      // this default to the type of the parameter.
      if (Default != string.Empty)
      {
        Object o = converter.ConvertFromString(Default);
        if (o == null) throw new InvalidTaxVendorParamException(string.Format("Unable to convert default value {0}", ToString()));
      }
    }
  }

  /// <summary>
  /// This class is able to take a tax vendor parameter xml file and
  /// synchronize the file with the t_tax_vendor_params table in the
  /// database.
  /// </summary>
  public class VendorParamsManager
  {
    // Logger
    private readonly Logger mLogger;

    /// <summary>
    /// Constructor
    /// </summary>
    public VendorParamsManager()
    {
      mLogger = new Logger("[VendorParamsManager]");
    }

    /// <summary>
    /// Create a list of the tax vendor parameters as specified in the 
    /// xml file.  Actually, we have a dictionary where the name of the
    /// tax parameter is the index to the dictionary.
    /// </summary>
    public class TaxParamList : Dictionary<string, TaxParam> { }

    /// <summary>
    /// Create a dictionary that separates out tax vendor parameters
    /// by tax vendor.  The index to the dictionary is the tax vendor,
    /// and the entry in the dictionay is the corresponding tax vendor params
    /// for that vendor.
    /// </summary>
    public class VendorParamsDictionary : Dictionary<DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor, TaxParamList> { }

    /// <summary>
    /// Synchronize the tax vendor param xml file with the database.
    /// </summary>
    /// <param name="configFile"></param>
    public void SynchronizeConfigFile(string configFile)
    {
      mLogger.LogDebug("Synchronizing config file {0}", configFile);

      try
      {
        VendorParamsDictionary vendorParams = ReadVendorParamsFromFile(configFile);
        DeleteVendorParamsFromDB();
        InsertVendorParamsIntoDB(vendorParams);
      }
      catch (Exception ex)
      {
        string msg = String.Format("Unable to synchronize config file {0}", configFile);
        mLogger.LogException(msg, ex);
        throw;
      }
    }

    /// <summary>
    /// Given a dictionary of all the tax vendor parameters that were in the
    /// xml file, insert these vendor parameters into t_tax_vendor_params
    /// </summary>
    /// <param name="vendorParams">the vendor parameters separated out by tax vendor</param>
    private void InsertVendorParamsIntoDB(VendorParamsDictionary vendorParams)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        foreach (DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor vendor in vendorParams.Keys)
        {
          mLogger.LogDebug("Inserting tax vendor parameters to t_tax_vendor_params for vendor {0}", vendor.ToString());
          foreach (TaxParam param in vendorParams[vendor].Values)
          {
            mLogger.LogDebug("Inserting vendor parameter {0}", param.ToString());
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\Tax", "__INSERT_VENDOR_PARAM__"))
            {
              stmt.AddParam("%%TAX_VENDOR%%", (int)DomainModel.Enums.EnumHelper.GetDbValueByEnum(vendor));
              stmt.AddParam("%%NAME%%", param.Name);
              stmt.AddParam("%%TYPE%%", param.Type.ToString());
              stmt.AddParam("%%DEFAULT%%", param.Default);

              // Since the description is not essential, we are going to handle the case of the
              // user entering a description that is too long.  We silently discard the part of
              // description that doesn't fit.
              stmt.AddParam("%%DESCRIPTION%%", param.Description.Substring(0, Math.Min(param.Description.Length, 255)));

              stmt.ExecuteNonQuery();
            }
          }
        }
      }
    }

    /// <summary>
    /// Delete any existing tax vendor parameters from the database.
    /// </summary>
    private void DeleteVendorParamsFromDB()
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\Tax", "__DELETE_VENDOR_PARAMS__"))
        {
          stmt.ExecuteNonQuery();
        }
      }
    }

    /// <summary>
    /// Read the tax vendor parameters from the xml file.
    /// </summary>
    /// <param name="configFile">xml file describing parameters</param>
    /// <returns></returns>
    public VendorParamsDictionary ReadVendorParamsFromFile(string configFile)
    {
      VendorParamsDictionary vendorParams = new VendorParamsDictionary();
      if (!File.Exists(configFile)) throw new FileNotFoundException("Can't find vendor parameter config file", configFile);
      try
      {
        MTXmlDocument doc = new MTXmlDocument();
        doc.Load(configFile);
        XmlNodeList nodelist = doc.SelectNodes("/xmlconfig/VendorParameters", null);

        if (nodelist == null || nodelist.Count == 0)
        {
          mLogger.LogWarning("No Vendor Parameters found in config file {0}", configFile);
          return vendorParams;
        }
        foreach (XmlNode paramsNode in nodelist)
        {
          DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor vendor = ReadVendorFromNode(paramsNode);
          TaxParamList paramList = BuildParamsListFromNode(paramsNode);
          vendorParams.Add(vendor, paramList);
        }
      }
      catch (Exception ex)
      {
        string msg = string.Format("Unable to load config file {0}", configFile);
        mLogger.LogException(msg, ex);
        throw new InvalidConfigurationException(msg, ex);
      }

      return vendorParams;
    }

    /// <summary>
    /// Given an xml node describing the tax vendor parameters for a vendor,
    /// identify the tax vendor and return the enum representing the vendor.
    /// Throw an exception if the vendor is not recoginized.
    /// </summary>
    /// <param name="vendorParamsNode">node describing parameters for a tax vendor</param>
    /// <returns>the enum representing this vendor</returns>
    private DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor ReadVendorFromNode(XmlNode vendorParamsNode)
    {
      if (vendorParamsNode.Attributes == null)
      {
        throw new Exception(string.Format("Attributes are missing from the tax vendor parameter xml file."));
      }

      XmlAttribute vendorAttribute = vendorParamsNode.Attributes["Vendor"];
      if (vendorAttribute == null)
        throw new Exception(string.Format("Required attribute Vendor is missing! NodeXml {0}", vendorParamsNode.OuterXml));

      string vendorStr = vendorAttribute.Value;
      mLogger.LogDebug("Processing vendor {0}", vendorStr);

      foreach (DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor v in Enum.GetValues(typeof(DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor)))
      {
        if (String.Compare(v.ToString(), vendorStr, true) == 0)
        {
          return v;
        }
      }

      // We've encountered a vendor that we don't recognize.
      throw new Exception(string.Format("Unknown tax vendor {0}. Only support values from metratech.com/tax/TaxVendor enum", vendorStr));
    }

    /// <summary>
    /// Given a node holding the tax vendor parameters for a vendor,
    /// return a list of those parameters.
    /// </summary>
    /// <param name="vendorParamsNode">node containing vendor parameters</param>
    /// <returns>list of parameters constructed from the node</returns>
    private TaxParamList BuildParamsListFromNode(XmlNode vendorParamsNode)
    {
      TaxParamList list = new TaxParamList();
      XmlNodeList paramList = vendorParamsNode.SelectNodes("params/param", null);

      if (paramList == null || paramList.Count == 0)
      {
        mLogger.LogWarning("No parameters defined for the vendor {0}", vendorParamsNode.OuterXml);
        return list;
      }

      foreach (XmlNode paramNode in paramList)
      {
        TaxParam param = ReadParamFromNode(paramNode);
        mLogger.LogInfo("Adding {0}", param.Name);
        list.Add(param.Name, param);
      }
      return list;
    }

    /// <summary>
    /// Give a node representing a single tax vendor parameter,
    /// return the TaxParam representing the parameter.
    /// </summary>
    /// <param name="paramNode">describes a single parameter</param>
    /// <returns>TaxParam representing parameter</returns>
    private TaxParam ReadParamFromNode(XmlNode paramNode)
    {
      TaxParam param = new TaxParam();

      try
      {
        param.Name = MTXmlDocument.GetNodeValueAsString(paramNode, "name");
        param.Name = param.Name.Trim();
        param.Type = StringToMTParameterType(MTXmlDocument.GetNodeValueAsString(paramNode, "type"));
        param.Default = MTXmlDocument.GetNodeValueAsString(paramNode, "default");
        param.Description = MTXmlDocument.GetNodeValueAsString(paramNode, "description");
        param.Validate();
      }
      catch (Exception)
      {
        string msg = string.Format("Unable to parse parameter node {0}", paramNode.OuterXml);
        mLogger.LogError(msg);
        throw;
      }
      return param;
    }

    /// <summary>
    /// Convert a string that is suppose to be the data type of the tax
    /// vendor parameter into a MTParameterType
    /// </summary>
    /// <param name="parameterTypeString">describes data type</param>
    /// <returns>data type represented by string</returns>
    private MTParameterType StringToMTParameterType(string parameterTypeString)
    {
      MTParameterType result;
      if (Enum.TryParse(parameterTypeString, true, out result))
      {
        return result;
      }
      throw new Exception(string.Format("{0} is not a valid value for the parameter type.", parameterTypeString));
    }
  }
}
