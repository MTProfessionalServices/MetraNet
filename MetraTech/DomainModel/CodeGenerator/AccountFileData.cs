using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class AccountFileData : FileData
  {
    #region Public Methods

    public AccountFileData()
    {
      viewProperties = new Dictionary<string, ViewFileData>();
      ancestors = new List<string>();
      descendants = new List<string>();
    }

    /// <summary>
    ///    Return AccountFileData for each view file in RMP\Extensions. 
    /// </summary>
    /// <returns></returns>
    public static List<AccountFileData> GetAccountFileData()
    {
      List<AccountFileData> accountFiles = new List<AccountFileData>();
      List<string> accountTypeNames = new List<string>();

      foreach(string extension in BaseCodeGenerator.RCD.ExtensionList)
      {
        accountFiles.AddRange(GetAccountFileData(extension, accountTypeNames));
      }
      return accountFiles;
    }
    /// <summary>
    ///   Return AccountFileData items for the given extension
    /// </summary>
    /// <param name="extension"></param>
    /// <param name="accountTypeNames"></param>
    /// <returns></returns>
    public static List<AccountFileData> GetAccountFileData(string extension, List<string> accountTypeNames)
    {
      List<AccountFileData> accountFiles = new List<AccountFileData>();

      // Get the msixdef files under extension/.../AccountView
      List<string> files = BaseCodeGenerator.GetFiles(extension, "AccountType", "xml");
      XmlDocument xmlDocument = new XmlDocument();
      foreach (string file in files)
      {
        xmlDocument.Load(file);
        XmlNode nameNode = xmlDocument.SelectSingleNode("//AccountType/Name");

        AccountFileData accountFileData = new AccountFileData();
        accountFileData.ExtensionName = BaseCodeGenerator.RCD.GetExtensionFromPath(file);
        accountFileData.FileName = Path.GetFileName(file);
        accountFileData.FullPath = file;
        accountFileData.className = GetAccountClassName(nameNode, file, accountTypeNames);
        accountFileData.name = nameNode.InnerText.Trim();

        accountFiles.Add(accountFileData);

        InitViewProperties(xmlDocument, accountFileData, file);

        InitHierarchyData(xmlDocument, accountFileData);
        
        // Only for base account properties
        if (extension.ToLower() == "account")
        {
          accountFileData.LocalizationFiles.AddRange(LocalizationFileData.GetLocalizationFileData(extension, "metratech.com/account"));
        }
      }
      return accountFiles;
    }
    #endregion

    #region Properties

    /// <summary>
    ///    The <Name> element in the Account type config file. (<xmlconfig><AccountType><Name>)
    /// </summary>
    private string name;
    public string Name
    {
      get { return name; }
    }

    /// <summary>
    ///    The <Name> element in the Account type config file modified to be a valid class name.
    /// </summary>
    private string className;
    public string ClassName
    {
      get { return className; }
    }

    /// <summary>
    ///    Given the following snippet from an account type config file (ie. CoreSubscriber.xml), map
    ///    <Name> to the ViewFileData for the corresponding <ConfigFile>
    ///    e.g.  Internal - [ViewFileData for metratech.com/internal]
    /// 
    /// <AccountViews>
		///	 <AdapterSet>
	  ///			<Name>Internal</Name>
		///		<ProgID>MTAccount.MTSQLAdapter.1</ProgID>
		///		<ConfigFile>metratech.com/internal</ConfigFile>
		///	 </AdapterSet>
		///	 <AdapterSet>
		///		<Name>LDAP</Name>
		///		<ProgID>MTAccount.MTSQLAdapter.1</ProgID>
		///		<ConfigFile>metratech.com/contact</ConfigFile>
		///	 </AdapterSet>
		/// </AccountViews>
		/// 
    /// </summary>
    private readonly Dictionary<string, ViewFileData> viewProperties;
    public Dictionary<string, ViewFileData> ViewProperties
    {
      get { return viewProperties; }
    }

    private readonly List<string> descendants;
    public List<string> Descendants
    {
      get { return descendants; }
    }

    private readonly List<string> ancestors;
    public List<string> Ancestors
    {
      get { return ancestors; }
    }

    /// <summary>
    ///   This is used as the key for the checksum associated with this file.
    ///   The key/checksum pair is stored as a resource in the generated assembly.
    ///   The key looks like the following:
    ///   <enumFile ext="ExtensionName" file="fileName.xml"/>
    /// </summary>
    public override string ChecksumKey
    {
      get
      {
        StringWriter stringWriter = new StringWriter();
        XmlTextWriter xmlTextWriter = new XmlTextWriter(stringWriter);
        xmlTextWriter.WriteStartElement("accountFile");
        xmlTextWriter.WriteAttributeString("ext", ExtensionName);
        xmlTextWriter.WriteAttributeString("file", FileName);
        xmlTextWriter.WriteEndElement();
        xmlTextWriter.Close();
        stringWriter.Close();
        return stringWriter.ToString();
      }
    }
    #endregion

    #region Protected Methods
    
    #endregion

    #region Private Methods
    private static string GetAccountClassName(XmlNode nameNode, string fileName, ICollection<string> accountClassNames)
    {
      if (nameNode == null)
      {
        logger.LogError(String.Format("Missing <name> element in '{0}'.", fileName));
        throw new ApplicationException(String.Format("Missing <name> element in '{0}'.", fileName));
      }

      if (String.IsNullOrEmpty(nameNode.InnerText) || String.IsNullOrEmpty(nameNode.InnerText.Trim()))
      {
        logger.LogError(String.Format("<name> element in '{0}' does not have a value.", fileName));
        throw new ApplicationException(String.Format("<name> element in '{0}' does not have a value.", fileName));
      }

      string accountClassName = nameNode.InnerText.Trim();
      // Cannot name the class 'Account' because this is the name of the base class
      if (accountClassName.ToLower() == "account")
      {
				logger.LogError(String.Format("Cannot create an account type called '{0}' from file '{1}' because it conflicts with a system class name.", accountClassName, fileName));
				throw new ApplicationException(String.Format("Cannot create an account type called '{0}' from file '{1}' because it conflicts with a system class name.", accountClassName, fileName));
      }

      if (accountClassNames.Contains(accountClassName))
      {
        logger.LogError(String.Format("Found duplicate AccountType name '{0}' in '{1}'.", accountClassName, fileName));
        accountClassName = accountClassName + "_";
      }

      accountClassNames.Add(accountClassName);

      return BaseCodeGenerator.MakeAlphaNumeric(accountClassName);
    }

    private static void InitViewProperties(XmlNode xmlDocument, AccountFileData accountFileData, string file)
    {
      // View properties
      XmlNodeList viewNodes = xmlDocument.SelectNodes("//AccountViews/AdapterSet");

      if (viewNodes == null)
      {
        return;
      }

      foreach (XmlNode node in viewNodes)
      {
        XmlNode viewNameNode = node.SelectSingleNode("./Name");
        if (viewNameNode == null || String.IsNullOrEmpty(viewNameNode.InnerText) || String.IsNullOrEmpty(viewNameNode.InnerText.Trim()))
        {
          logger.LogError(
            String.Format("'//AccountViews/AdapterSet/Name' element in '{0}' is not found or does not have a value.",
                          file));
          continue;
        }

        string viewPropertyName = BaseCodeGenerator.MakeAlphaNumeric(viewNameNode.InnerText.Trim());

        XmlNode configFileNode = node.SelectSingleNode("./ConfigFile");
        if (configFileNode == null || String.IsNullOrEmpty(configFileNode.InnerText))
        {
          logger.LogError(
            String.Format(
              "'//AccountViews/AdapterSet/Config' element in '{0}' is not found or does not have a value.", file));
          continue;
        }

        string viewTypeName = configFileNode.InnerText.Trim();

        if (!ViewFileData.ViewFileMap.ContainsKey(viewTypeName.ToLower()))
        {
          logger.LogError(String.Format("Config element '{0}' specified in '{1}' does not match a view definition.",
                                        viewTypeName, file));
          continue;
        }

        ViewFileData viewFileData = ViewFileData.ViewFileMap[viewTypeName.ToLower()];
        accountFileData.viewProperties.Add(viewPropertyName, viewFileData);
      }
    }

    private static void InitHierarchyData(XmlNode xmlDocument, AccountFileData accountFileData)
    {
      XmlNodeList nodeList = xmlDocument.SelectNodes("//AccountType/DirectDescendentAccountTypes/Descendent");
      if (nodeList != null)
      {
        foreach (XmlNode descendantNode in nodeList)
        {
          XmlNode node = descendantNode.SelectSingleNode("Name");
          if (node != null && !String.IsNullOrEmpty(node.InnerText))
          {
            accountFileData.Descendants.Add(node.InnerText);
          }
        }
      }

      nodeList = xmlDocument.SelectNodes("//AccountType/DirectAncestorAccountTypes/Ancestor");
      
      if (nodeList == null) return;

      foreach (XmlNode ancestorNode in nodeList)
      {
        XmlNode node = ancestorNode.SelectSingleNode("Name");
        if (node != null && !String.IsNullOrEmpty(node.InnerText))
        {
          accountFileData.Ancestors.Add(node.InnerText);
        }
      }
    }

    #endregion
  }

  #region ViewData
  #endregion
}
