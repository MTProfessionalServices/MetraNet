using System;
using System.Collections.Generic;
using System.IO;
using System.Xml.Serialization;
using MetraTech.UI.Common;

namespace MetraTech.UI.CDT
{
  /// <summary>
  /// Configuration class that holds the rendering template for an object.
  /// </summary>
  [Serializable]
  public class PageLayout
  {
    public bool IsBusinessEntityLayout = false;
    public string Name = "";
    public string Tenant = "MetraTech";
    public string AssemblyName = "";
    public string ObjectName = "";
    public string Description = "";
    public HeaderSection Header = new HeaderSection();
    public HelpSection Help = new HelpSection();
    public List<Section> Sections = new List<Section>();
    
    /// <summary>
    /// Contains optional javascript includes for the grid that should included
    /// after the grid javascript so they may override existing methods
    /// Multiple includes should be separated with semi-colons (;)
    /// </summary>    
    public string CustomOverrideJavascriptIncludes = "";

    #region Serializer Methods
    public bool Save(string layoutFile)
    {
      if (layoutFile != null)
      {
        // Serialization
        XmlSerializer s = new XmlSerializer(typeof (PageLayout));
        TextWriter w = new StreamWriter(layoutFile);
        s.Serialize(w, this);
        w.Close();
        return true;
      }

      return false;
    }

    public static PageLayout Load(string layoutFile)
    {
      PageLayout pl = null;
      
      if (layoutFile != null)
      {
        if (File.Exists(layoutFile))
        {
          // Deserialization
          using (FileStream fileStream = File.Open(layoutFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
          {
            XmlSerializer s = new XmlSerializer(typeof (PageLayout));
            pl = (PageLayout) s.Deserialize(fileStream);
          }          
        }
      }

      return pl;
    }
    #endregion
  }

  [Serializable]
  public class HeaderSection
  {
    public LocalizableString PageTitle = new LocalizableString();
  }

  [Serializable]
  public class Button
  {
    public string ButtonID = "";
    public LocalizableString ButtonText = new LocalizableString();
    public LocalizableString ToolTip = new LocalizableString();
    public string IconClass = "";
    public string JSHandlerFunction = "";
    public RequiredCapabilityList RequiredCapabilities = new RequiredCapabilityList();
  }

  [Serializable]
  public class HelpSection
  {
    public string Mode = "";
    public string Name = "";
    public string URL = "";
  }

  [Serializable]
  public class Section
  {
    public string Name = "";
    public LocalizableString Title = new LocalizableString();
    public string TabOrder = "LeftToRight";
    public List<Column> Columns = new List<Column>();
    public List<Button> ToolbarButtons = new List<Button>();
    // TODO:  Add required capabilities
  }

  [Serializable]
  public class Column
  {
    public List<Field> Fields = new List<Field>();
  }

  [Serializable] 
  public class Field
  {
    public string AssemblyFilename = "";
    public string ObjectName = "";
    public string ID = "";
    private string name = "";
    public string Name
    {
      get
      {
        name = name.Replace("[]", "[0]");
        return name;
      }
      set { name = value; }
    }

    public LocalizableString Label = new LocalizableString();
    public bool ReadOnly;
    
    public bool Required
    {
      get { return EditorValidation.Required; }
      set { EditorValidation.Required = value; }
    }

    public string ValidationType
    {
      get { return EditorValidation.ValidationType; }
      set { EditorValidation.ValidationType = value; }
    }

    public string ValidationRegEx
    {
      get { return EditorValidation.Regex; }
      set { EditorValidation.Regex = value; }
    }

    public string ControlType = "";
    public string Alignment = "Left";
    public string OptionalExtConfig = "";
    public RequiredCapabilityList RequiredCapabilities = new RequiredCapabilityList();
    public RequiredCapabilityList RequiredCapabilitiesReadonly = new RequiredCapabilityList();
    public InputValidation EditorValidation = new InputValidation();
    public RelatedEntityDefinition RelatedEntity = new RelatedEntityDefinition();
  }

  [Serializable]
  public class RelatedEntityDefinition
  {
    public string ID = "";
    public string ObjectName = "";
  }

  [Serializable]
  public class InputValidation
  {
    public bool Required = false;
    public string MinValue;
    public string MaxValue;
    public int MinLength = 0;
    public int MaxLength = -1;
    public string Regex = "";
    public string ValidationFunction = "";
    public string ValidationType = "";
  }

  [Serializable]
  public class RequiredCapabilityList
  {
    [XmlElement("Capability")]
    public List<string> Capabilities = new List<string>();
  }

}
