using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel;
using System.Web.UI;
using MetraTech.UI.Controls;
using MetraTech.UI.Controls.MTLayout;

namespace MetraTech.UI.Controls
{
  public enum MTFilterOperation
  {
    Equal = 1,
    NotEqual = 2,
    Less = 3,
    LessOrEqual = 4,
    Greater = 5,
    GreaterOrEqual = 6,
    Like = 7
  }

  /// <summary>
  /// Represents a data element that is used in MTFilterGrid.  An element can appear
  /// as a column, a filter, an expandable item, or be fully invisible.
  /// </summary>
  [TypeConverter(typeof(ExpandableObjectConverter))]
  public class MTGridDataElement
  {

    private List<MTFilterDropdownItem> filterDropdownItems;

    /// <summary>
    /// Specifies a collection of dropdown items
    /// </summary>
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
    [PersistenceMode(PersistenceMode.InnerProperty)]
    [NotifyParentProperty(true)]
    public List<MTFilterDropdownItem> FilterDropdownItems
    {
      get
      {
        if (filterDropdownItems == null)
        {
          filterDropdownItems = new List<MTFilterDropdownItem>();
        }
        return filterDropdownItems;
      }
    }

    private MTFilterEnum filterEnum;
    /// <summary>
    /// This property resolves the MetraTech enum that is used to populate this filter.
    /// </summary>
    [NotifyParentProperty(true)]
    [PersistenceMode(PersistenceMode.InnerProperty)]
    public MTFilterEnum FilterEnum
    {
      get
      {
        if (filterEnum == null)
        {
          filterEnum = new MTFilterEnum();
        }
        return filterEnum;

      }
      set { filterEnum = value; }
    }

    private bool isIdentity = false;

    /// <summary>
    /// Indicates whether this element is the identity element.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool IsIdentity
    {
      get { return isIdentity; }
      set { isIdentity = value; }
    }
    private bool editable = false;

    /// <summary>
    /// Indicates if this element can be edited directly inside the grid.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool Editable
    {
      get { return editable; }
      set { editable = value; }
    }

    private GridInputValidation editorValidation;

    public GridInputValidation EditorValidation
    {
      get { return editorValidation; }
      set { editorValidation = value; }
    }

    private bool showInExpander = true;
    /// <summary>
    /// Indicates if this element is shown in the expandable section of the search results.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool ShowInExpander
    {
      get { return showInExpander; }
      set { showInExpander = value; }
    }

    private bool exportable = true;
    /// <summary>
    /// Indicates whether this column can be exported when export button is clicked. Default is true.  IsColumn must be true.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool Exportable
    {
      get { return exportable; }
      set { exportable = value; }
    }

    private int position = 0;
    public int Position
    {
      get { return position; }
      set { position = value; }
    }

    private string _id;

    [NotifyParentProperty(true)]
    public string ID
    {
      get { return _id; }
      set { _id = value; }
    }

    private bool recordElement = true;

    /// <summary>
    /// Indicates whether this element is a part of javascript record.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool RecordElement
    {
      get { return recordElement; }
      set { recordElement = value; }
    }

    private int width;

    [NotifyParentProperty(true)]
    public int Width
    {
      get { return width; }
      set { width = value; }
    }

    private bool sortable = true;

    /// <summary>
    /// Indicates whether column sorting is enabled for this element.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool Sortable
    {
      get { return sortable; }
      set { sortable = value; }
    }

    private bool resizable = true;

    [NotifyParentProperty(true)]
    public bool Resizable
    {
      get { return resizable; }
      set { resizable = value; }
    }

    [Obsolete("This property has been deprecated. Use IsColumn property instead")]
    [NotifyParentProperty(true)]
    public bool Visible
    {
      get { return isColumn; }
      set { isColumn = value; }
    }

    private bool isColumn = true;

    /// <summary>
    /// Indicates whether this element appears as a column in the search results. Default is true.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool IsColumn
    {
      get { return isColumn; }
      set { isColumn = value; }
    }

    private bool defaultColumn = true;
    /// <summary>
    /// Indicates whether this column appears the very first time the grid is loaded. IsColumn must be set to true. Default is true.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool DefaultColumn
    {
      get { return defaultColumn; }
      set { defaultColumn = value; }
    }

    private bool columnHideable = true;
    /// <summary>
    /// Indicates whether the user can remove this column from the list of columns. Default = true.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool ColumnHideable
    {
      get { return columnHideable; }
      set { columnHideable = value; }
    }

    private bool filterHideable = true;
    /// <summary>
    /// Indicates if this filter can be removed by the user from the filter list. Default is true.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool FilterHideable
    {
      get { return filterHideable; }
      set { filterHideable = value; }
    }

    private bool filterable = true;
    /// <summary>
    /// Indicates if the grid can be filtered on this item. Default = true.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool Filterable
    {
      get { return filterable; }
      set { filterable = value; }
    }

    private bool defaultFilter = true;
    /// <summary>
    /// Indicates whether this filter appears on the initial load of the page. Default = true.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool DefaultFilter
    {
      get { return defaultFilter; }
      set { defaultFilter = value; }
    }

    private bool requiredFilter = false;

    /// <summary>
    /// Indicates whether the data for this filter is required.
    /// </summary>
    [NotifyParentProperty(true)]
    public bool RequiredFilter
    {
      get { return requiredFilter; }
      set { requiredFilter = value; }
    }

    //URL to retrieve the list items for list element
    private string listItemsLocation;
    [NotifyParentProperty(true)]
    public string ListItemsLocation
    {
      get { return listItemsLocation; }
      set { listItemsLocation = value; }
    }

    private string headerText = "";

    /// <summary>
    /// Specifies the value that is used for column header text and filter field label.
    /// </summary>
    [NotifyParentProperty(true)]
    public string HeaderText
    {
      get { return headerText; }
      set { headerText = value; }
    }

    private string filterLabel = "";

    /// <summary>
    /// Specifies the value used in the filter label.  If it is empty, use the value of HeaderText
    /// </summary>
    [NotifyParentProperty(true)]
    public string FilterLabel
    {
      get
      {
        if (String.IsNullOrEmpty(filterLabel))
        {
          filterLabel = headerText;
        }
        return filterLabel;
      }
      set { filterLabel = value; }
    }

    private string dataIndex = "";
    /// <summary>
    /// Column name as it appears in the js column model
    /// </summary>
    [NotifyParentProperty(true)]
    public string DataIndex
    {
      get { return dataIndex; }
      set { dataIndex = value; }
    }

    private MTDataType dataType;
    /// <summary>
    /// Data Type of the current element.  This value will be used for properly generating filters.
    /// </summary>
    [NotifyParentProperty(true)]
    public MTDataType DataType
    {
      get { return dataType; }
      set { dataType = value; }
    }

    private string elementValue;
    /// <summary>
    /// Initial value of the filter
    /// </summary>
    [NotifyParentProperty(true)]
    public string ElementValue
    {
      get { return elementValue; }
      set { elementValue = value; }
    }

    private string elementValue2;
    /// <summary>
    /// Initializes the secondary value of the filter
    /// </summary>
    [NotifyParentProperty(true)]
    public string ElementValue2
    {
      get { return elementValue2; }
      set { elementValue2 = value; }
    }

    private MTFilterOperation filterOperation = MTFilterOperation.Equal;
    /// <summary>
    /// Defines the filter operation, such as Less Than, Equal To, Greater Than, etc.
    /// </summary>
    [NotifyParentProperty(true)]
    public MTFilterOperation FilterOperation
    {
      get { return filterOperation; }
      set { filterOperation = value; }
    }

    private bool filterReadOnly = false;

    /// <summary>
    /// Indicates whether this filter appears as read-only, e.g. filter value cannot be modified. Default is False
    /// </summary>
    [NotifyParentProperty(true)]
    public bool FilterReadOnly
    {
      get { return filterReadOnly; }
      set { filterReadOnly = value; }
    }

    private LabelSourceType labelSource;
    /// <summary>
    /// Provides a hint that determines where the label text is coming from.
    /// </summary>
    public LabelSourceType LabelSource
    {
      get { return labelSource; }
      set { labelSource = value; }
    }

    private string formatter;
    /// <summary>
    /// Name of the javascript function that is used as a formatter 
    /// for this field.
    /// </summary>
    public string Formatter
    {
      get { return formatter; }
      set { formatter = value; }
    }

    private bool rangeFilter = false;
    /// <summary>
    /// Indicates whether range filter is supported. Applies only to 
    /// String and Numeric types.  Date filter is a range filter by definition.
    /// </summary>
    public bool RangeFilter
    {
      get { return rangeFilter; }
      set { rangeFilter = value; }
    }

    private bool multiValue = false;
    /// <summary>
    /// Support for multi-value dropdowns. Applies only to Lists
    /// </summary>
    public bool MultiValue
    {
      get { return multiValue; }
      set { multiValue = value; }
    }
  }
}
