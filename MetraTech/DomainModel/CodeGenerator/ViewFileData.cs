using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class ViewFileData : FileData
  {
    #region Public Methods

    public ViewFileData()
    {
      properties = new List<ConfigPropertyData>();
    }

    protected ViewFileData(string viewType)
    {
        this.viewType = viewType;
    }
  
    #endregion

    #region Properties
    private string viewType;
    public string ViewType
    {
      get { return viewType; }
    }

    private string className;
    public string ClassName
    {
      get { return className; }
    }

    // eg. LDAP (specified in Account type config)
    private string propertyName;
    public string PropertyName
    {
      get { return propertyName; }
      set { propertyName = value; }
    }

    // This is true if the view has one or more properties with 'isPartOfKey' attribute set to true.
    // Determines if the property on the account is to be created as a list or a single property.
    private bool makeList;
    public bool MakeList
    {
      get { return makeList; }
    }

    private readonly List<ConfigPropertyData> properties;
    public List<ConfigPropertyData> Properties
    {
      get { return properties; }
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
        xmlTextWriter.WriteStartElement("viewFile");
        xmlTextWriter.WriteAttributeString("ext", ExtensionName);
        xmlTextWriter.WriteAttributeString("file", FileName);
        xmlTextWriter.WriteEndElement();
        xmlTextWriter.Close();
        stringWriter.Close();
        return stringWriter.ToString();
      }
    }

    public static Dictionary<string, ViewFileData> ViewFileMap
    {
      get
      {
        return viewFileMap;
      }
    }

    public static ViewFileData[] ViewFiles
    {
      get
      {
        if (viewFileMap != null)
        {
          viewFileMap.Clear();
        }

        viewFileMap = GetViewFileData();
        ViewFileData[] viewFiles = new ViewFileData[viewFileMap.Values.Count];
        viewFileMap.Values.CopyTo(viewFiles, 0);
        return viewFiles;
      }
    }
    #endregion

    #region Protected Methods
    
    #endregion

    #region Private Methods
    /// <summary>
    ///    Return ViewFileData for each view file in RMP\Extensions. 
    /// </summary>
    /// <returns></returns>
    private static Dictionary<string, ViewFileData> GetViewFileData()
    {
      Dictionary<string, ViewFileData> viewFiles = new Dictionary<string, ViewFileData>();
      List<string> viewTypeNames = new List<string>();

      foreach (string extension in BaseCodeGenerator.RCD.ExtensionList)
      {
        List<ViewFileData> viewFileDataList = GetViewFileData(extension, viewTypeNames);
        foreach (ViewFileData viewFileData in viewFileDataList)
        {
          viewFiles.Add(viewFileData.ViewType, viewFileData);
        }
      }

      return viewFiles;
    }

    /// <summary>
    ///   Return ViewFileData items for the given extension
    /// </summary>
    /// <param name="extension"></param>
    /// <param name="viewTypeNames"></param>
    /// <returns></returns>
    private static List<ViewFileData> GetViewFileData(string extension, ICollection<string> viewTypeNames)
    {
      List<ViewFileData> viewFiles = new List<ViewFileData>();

      // Get the msixdef files under extension/.../AccountView
      List<string> files = BaseCodeGenerator.GetFiles(extension, "AccountView", "msixdef");
      XmlDocument xmlDocument = new XmlDocument();
      ConfigPropertyData propertyData;
      foreach (string file in files)
      {
        xmlDocument.Load(file);
        XmlNode nameNode = xmlDocument.SelectSingleNode("//name");

        ViewFileData viewFileData = new ViewFileData();
        viewFileData.ExtensionName = BaseCodeGenerator.RCD.GetExtensionFromPath(file);
        viewFileData.FileName = Path.GetFileName(file);
        viewFileData.FullPath = file;
        viewFileData.className = GetViewClassName(nameNode, file, viewTypeNames);
        viewFileData.viewType = nameNode.InnerText.Trim().ToLower();

        XmlNodeList ptypes = xmlDocument.SelectNodes("//ptype");

        if (ptypes == null || ptypes.Count == 0)
        {
          logger.LogError(String.Format("View found in '{0}' does not have any properties.", file));
          continue;
        }

        foreach (XmlNode ptype in ptypes)
        {
          if (BaseCodeGenerator.GetPropertyData(ptype, out propertyData))
          {
            viewFileData.Properties.Add(propertyData);
            if (propertyData.IsPartOfKey)
            {
              viewFileData.makeList = true;
            }
          }
        }

        // Get the localization files
        viewFileData.LocalizationFiles.AddRange(LocalizationFileData.GetLocalizationFileData(extension, viewFileData.viewType));

        viewFiles.Add(viewFileData);
      }

      return viewFiles;
    }

    private static string GetViewClassName(XmlNode viewNameNode, string fileName, ICollection<string> viewClassNames)
    {
      if (viewNameNode == null)
      {
        logger.LogError(String.Format("Missing <name> element in '{0}'.", fileName));
        throw new ApplicationException(String.Format("Missing <name> element in '{0}'.", fileName));
      }

      if (String.IsNullOrEmpty(viewNameNode.InnerText) || String.IsNullOrEmpty(viewNameNode.InnerText.Trim()))
      {
        logger.LogError(String.Format("<name> element in '{0}' does not have a value.", fileName));
        throw new ApplicationException(String.Format("<name> element in '{0}' does not have a value.", fileName));
      }

      string viewClassName = viewNameNode.InnerText.Trim();
      // Expect to find a '/' because the view name is qualified with a namespace
      // eg. ""metratech.com/internal"
      int startIndex = viewClassName.IndexOf('/') + 1;
      if (startIndex == 0)
      {
        logger.LogError(String.Format("Unable to parse <name> in '{0}'.", fileName));
        throw new ApplicationException(String.Format("Unable to parse <name> in '{0}'.", fileName));
      }

      // Strip out the namespace and remove non-alphanumerics
      viewClassName = viewClassName.Substring(startIndex, viewClassName.Length - startIndex);
      viewClassName = BaseCodeGenerator.MakeAlphaNumeric(viewClassName) + "View";

      // If the parsed viewTypeName is not unique, then use the namespace as a part of the C# type name
      if (viewClassNames.Contains(viewClassName.ToLower()))
      {
        viewClassName = BaseCodeGenerator.MakeAlphaNumeric(viewNameNode.InnerText.Trim()) + "View";
      }
      else
      {
        viewClassNames.Add(viewClassName.ToLower());
      }

      return viewClassName;
    }

    
    #endregion

    #region Data
    /// <summary>
    ///    Map viewFileType to ViewFileData. 
    ///    viewFileType is the <name> element found in the view msixdef file e.g. metratech.com/Contact
    /// </summary>
    private static Dictionary<string, ViewFileData> viewFileMap;
    #endregion
  }
}
