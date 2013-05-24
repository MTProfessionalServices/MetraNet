using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Xml.Serialization;
using System.Web;
using System.Resources;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls.MTLayout
{
  [Serializable]
  public enum LabelSourceType
  {
    ResourceFile,
    DomainModel,
    BusinessEntity
  }

  [Serializable]  
  public class ElementLayout
  {
#pragma warning disable 169
    public EnumValueLayout FilterEnum = new EnumValueLayout();

    [XmlArrayItem("DropdownItem")]
    public List<DropdownItemLayout> DropdownItems = new List<DropdownItemLayout>();
    public LabelSourceType LabelSource = LabelSourceType.ResourceFile; 
    public bool IsIdentity = false;
    public bool ReadOnly = true;
    public bool ShowInExpander = true;
    public bool Exportable = true;
    public string ID = null;
    public bool RecordElement = true;
    public bool Sortable = true;
    public bool Resizable = true;
    public bool IsColumn = true;
    public bool DefaultColumn = true;
    public bool ColumnHideable = true;
    public bool Filterable = true;
    public bool FilterHideable = true;
    public bool DefaultFilter = true;
    public bool RequiredFilter = false;
    public LocalizableString HeaderText = null;
    public LocalizableString FilterLabel = null;
    public String DataIndex = null;
    public string DataType = null;
    public LocalizableString ElementValue = null;
    public LocalizableString ElementValue2 = null;
    public string FilterOperation = null;
    public bool FilterReadOnly = false;
    public string ObjectName = null;
    public string AssemblyFilename = null;
    public int Width = 120;
    public string Formatter;
    public bool RangeFilter = false;
    public bool MultiValue = false;

    public InputValidationLayout EditorValidation = new InputValidationLayout();
#pragma warning restore 169
  }
}
