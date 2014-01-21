using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.MetraNet.App_Code;


/// <summary>
/// The AmpTextboxOrDropdown user control provides the user with a choice of supplying input data
/// in a textbox or in a dropdown.  The choice of textbox vs. dropdown is specified by
/// (1) the user's selection in the ddSourceType dropdown, or
/// (2) programmatic setting of either the UseTextbox or the UseDropdown property.
/// When the textbox source type is selected, then a textbox appears to the right of ddSourceType.
/// The TextboxIsNumeric property controls whether the textbox is restricted to numbers.
/// When the dropdown source type is selected, then a dropdown appears to the right of ddSourceType.
/// The text for the items in ddSourceType and the contents of the right dropdown
/// can be specified by the client of the user control.
/// </summary>
/// 
public partial class UserControls_AmpTextboxOrDropdown : System.Web.UI.UserControl
{

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      //Reset();
      ddSourceType.Listeners = @"{ 'select' : this.onChange_" + this.ID + @", scope: this }";

      // Form the script to be registered at client side.
      String scriptString = "<script type=\"text/javascript\">";
      scriptString += "// When the user changes the selection in ddSourceType, make the appropriate control visible. \n";
      scriptString += "function onChange_" + this.ID + "(field, newvalue, oldvalue) \n";
      scriptString += "{ \n";
      scriptString += "var tbnum = Ext.getCmp('" + tbNumericSource.ClientID + "'); \n";
      scriptString += "var tbtxt = Ext.getCmp('" + tbTextSource.ClientID + "');  \n";
      scriptString += "var ddsrc = Ext.getCmp('" + ddSource.ClientID + "');  \n\n";

      scriptString += "var textboxIsNumeric = " + TextboxIsNumeric.ToString().ToLower() + ";  \n\n";

      scriptString += "if (field.selectedIndex == 0) \n";
      scriptString += "{ \n";
      scriptString += "  // Make the textbox visible and the dropdown invisible. \n";
      scriptString += "  if (textboxIsNumeric) \n";
      scriptString += "  { \n";
      scriptString += "    tbnum.enable(); \n";
      scriptString += "    tbtxt.disable(); \n";
      scriptString += "    ddsrc.disable(); \n";
      scriptString += "    document.getElementById(\"" + divNumericSource.ClientID + "\").style.display = 'block'; \n";
      scriptString += "    document.getElementById(\"" + divTextSource.ClientID + "\").style.display = 'none'; \n";
      scriptString += "    document.getElementById(\"" + divDropdownSource.ClientID + "\").style.display = 'none'; \n";
      scriptString += "  } \n";
      scriptString += "  else  \n";
      scriptString += "  { \n";
      scriptString += "    tbnum.disable(); \n";
      scriptString += "    tbtxt.enable(); \n";
      scriptString += "    ddsrc.disable(); \n";
      scriptString += "    document.getElementById(\"" + divNumericSource.ClientID + "\").style.display = 'none'; \n";
      scriptString += "    document.getElementById(\"" + divTextSource.ClientID + "\").style.display = 'block'; \n";
      scriptString += "    document.getElementById(\"" + divDropdownSource.ClientID + "\").style.display = 'none'; \n";
      scriptString += "  } \n";
      scriptString += "} \n";
      scriptString += "else  \n";
      scriptString += "{ \n";
      scriptString += "  // Make the dropdown visible and the textbox invisible. \n";
      scriptString += "  tbnum.disable(); \n";
      scriptString += "  tbtxt.disable(); \n";
      scriptString += "  ddsrc.enable(); \n";
      scriptString += "  document.getElementById(\"" + divNumericSource.ClientID + "\").style.display = 'none'; \n";
      scriptString += "  document.getElementById(\"" + divTextSource.ClientID + "\").style.display = 'none'; \n";
      scriptString += "  document.getElementById(\"" + divDropdownSource.ClientID + "\").style.display = 'block'; \n";
      scriptString += "} \n";
      scriptString += "} \n";
      scriptString += "</script>";

      Page.ClientScript.RegisterStartupScript(this.GetType(), "onChange_" + this.ID, scriptString);
    }
  }


  protected void Page_Unload(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
    }
  }


  /// <summary>
  /// (Get/Set) Indicates whether the textbox source option is selected in the source type dropdown.
  /// </summary>
  public bool UseTextbox
  {
    get { return ddSourceType.SelectedIndex == 0; }
    set
    {
      if (value)
      {
        ddSourceType.SelectedIndex = 0;
        tbNumericSource.Enabled = TextboxIsNumeric;
        tbTextSource.Enabled = !TextboxIsNumeric;
        ddSource.Enabled = false;
        divNumericSource.Attributes.Add("style", (TextboxIsNumeric ? "display:block" : "display:none"));
        divTextSource.Attributes.Add("style", (TextboxIsNumeric ? "display:none" : "display:block"));
        divDropdownSource.Attributes.Add("style", "display: none;");
      }
      else
      {
        ddSourceType.SelectedIndex = 1;
        tbNumericSource.Enabled = false;
        tbTextSource.Enabled = false;
        ddSource.Enabled = true;
        divNumericSource.Attributes.Add("style", "display:none");
        divTextSource.Attributes.Add("style", "display:none");
        divDropdownSource.Attributes.Add("style", "display: block;");
      }
    }
  }


  /// <summary>
  // (Get/Set) Indicates whether the dropdown source option is selected in the source type dropdown.
  /// </summary>
  public bool UseDropdown
  {
    get { return !UseTextbox; }
    set { UseTextbox = !value; }
  }


  /// <summary>
  /// (Get/Set) Indicates whether the textbox is restricted to numeric values.
  /// </summary>
  public bool TextboxIsNumeric
  {
    get { return (bool)ViewState["textboxIsNumeric"]; }
    set
    {
      ViewState["textboxIsNumeric"] = value;
      tbNumericSource.Enabled = value;
      tbTextSource.Enabled = !value;
      divNumericSource.Attributes.Add("style", (value ? "display:block" : "display:none"));
      divTextSource.Attributes.Add("style", (value ? "display:none" : "display:block"));
    }
  }

  
  /// <summary>
  /// Gets or sets the string stored in the source textbox.
  /// </summary>
  public string TextboxText
  {
    get
    {
      if (TextboxIsNumeric)
      {
        return tbNumericSource.Text;
      }
      else
      {
        return tbTextSource.Text;
      }
    }
    set
    {
      if (TextboxIsNumeric)
      {
        tbNumericSource.Text = value;
      }
      else
      {
        tbTextSource.Text = value;
      }
    }
  }


  /// <summary>
  /// Gets or sets the selection in the source dropdown.
  /// Setting to a string that doesn't match any items in the dropdown is a no-op.
  /// </summary>
  public string DropdownSelectedText
  {
    get { return ddSource.SelectedValue; }
    set
    {
      ListItem listitem = ddSource.Items.FindByValue(value);
      if (listitem != null)
      {
        ddSource.SelectedIndex = ddSource.Items.IndexOf(listitem);
      }
    }
  }


  /// <summary>
  /// Gets or sets the string displayed in the ddSourceType dropdown that describes the textbox option,
  /// as opposed to the dropdown.  For example, a SourceTypeTextboxString of "Fixed Value"
  /// indicates to the user that a value entered in the textbox should be a fixed value.
  /// </summary>
  public string SourceTypeTextboxString
  {
    get { return ddSourceType.Items[0].Text; }
    set
    {
      ddSourceType.Items[0].Text = value;
      ddSourceType.Items[0].Value = value;
    }
  }


  /// <summary>
  /// Gets or sets the string displayed in the ddSourceType dropdown that describes the dropdown option,
  /// as opposed to the textbox.  For example, a SourceTypeDropdownString of "Get from Param Table Column"
  /// indicates to the user that the values listed in the right dropdown are names of parameter table columns.
  /// </summary>
  public string SourceTypeDropdownString
  {
    get { return ddSourceType.Items[1].Text; }
    set
    {
      ddSourceType.Items[1].Text = value;
      ddSourceType.Items[1].Value = value;
    }
  }


  /// <summary>
  /// Sets the contents of the right dropdown that appears when the second item in ddSourceType is selected.
  /// </summary>
  public List<KeyValuePair<String, String>> DropdownItems
  {
    set
    {
      ddSource.Items.Clear();
      //ddSource.Items.Insert(0, new ListItem(String.Empty, String.Empty));
      foreach (var item in value)
      {
        ddSource.Items.Add(new ListItem(item.Value, item.Key));
      }
    }
  }


  /// <summary>
  /// (Get/Set) Indicates whether the user control is in a readonly state.
  /// </summary>
  public bool ReadOnly
  {
    get { return ddSourceType.ReadOnly; }
    set
    {
      ddSourceType.ReadOnly = value;
      tbNumericSource.ReadOnly = value;
      tbTextSource.ReadOnly = value;
      ddSource.ReadOnly = value;
    }
  }


  /// <summary>
  /// (Get/Set) Indicates whether the user control is in an enabled state.
  /// </summary>
  public bool Enabled
  {
    get { return ddSourceType.Enabled; }
    set
    {
      if (value)
      {  // Enable the appropriate controls.
        if (ddSourceType.SelectedIndex == 0)
        {
          ddSourceType.Enabled = true;
          tbNumericSource.Enabled = TextboxIsNumeric;
          tbTextSource.Enabled = !TextboxIsNumeric;
          ddSource.Enabled = false;
        }
        else
        {
          ddSourceType.Enabled = true;
          tbNumericSource.Enabled = false;
          tbTextSource.Enabled = false;
          ddSource.Enabled = true;
        }
      }
      else
      {  // Disable all the controls
        ddSourceType.Enabled = false;
        tbNumericSource.Enabled = false;
        tbTextSource.Enabled = false;
        ddSource.Enabled = false;
      }
    }
  }


  /// <summary>
  /// (Get/Set) Indicates whether decimal values can be entered into the textbox.
  /// This property has effect only if TextboxIsNumeric is true.
  /// </summary>
  public bool AllowDecimalsInTextbox
  {
    get { return tbNumericSource.AllowDecimals; }
    set { tbNumericSource.AllowDecimals = value; }
  }


  /// <summary>
  /// (Get/Set) Indicates whether negative numeric values can be entered into the textbox.
  /// This property has effect only if TextboxIsNumeric is true.
  /// </summary>
  public bool AllowNegativeInTextbox
  {
    get { return tbNumericSource.AllowNegative; }
    set { tbNumericSource.AllowNegative = value; }
  }


  /// <summary>
  /// (Get/Set) Indicates whether the textbox may be blank.
  /// </summary>
  public bool AllowBlankTextbox
  {
    get { return tbNumericSource.AllowBlank; }
    set
    {
      tbNumericSource.AllowBlank = value;
      tbTextSource.AllowBlank = value;
    }
  }


  /// <summary>
  /// Sets the maximum numeric value that can be entered into the textbox.
  /// This property has effect only if TextboxIsNumeric is true.
  /// </summary>
  public int TextboxMaxValue
  {
    set { tbNumericSource.MaxValue = value.ToString(); }
  }


  /// <summary>
  /// Sets the minimum numeric value that can be entered into the textbox.
  /// This property has effect only if TextboxIsNumeric is true.
  /// </summary>
  public int TextboxMinValue
  {
    set { tbNumericSource.MinValue = value.ToString(); }
  }

  public string ddSourceTypeClientId
  {
    get { return ddSourceType.ClientID; }
  }

  public string tbNumericSourceClientId
  {
    get { return tbNumericSource.ClientID; }
  }

  public string tbTextSourceClientId
  {
    get { return tbTextSource.ClientID; }
  }

  public string ddSourceClientId
  {
    get { return ddSource.ClientID; }
  }

  /// <summary>
  /// (Get only) Indicates whether the textbox is empty.
  /// </summary>
  public bool TextboxIsEmpty
  {
    get
    {
      if (TextboxIsNumeric)
      {
        return (tbNumericSource.Text == null) || (tbNumericSource.Text.Length == 0);
      }
      else
      {
        return (tbTextSource.Text == null) || (tbTextSource.Text.Length == 0);
      }
    }
  }


  /// <summary>
  /// Sets properties on controls based on current mode (View/Edit).
  /// </summary>
  public void SetMode(string mode)
  {
    ReadOnly = (mode.ToLower() == "view");
  }


  /// <summary>
  /// Clears the entire user control and sets all properties to default values.
  /// </summary>
  public void Reset()
  {
    UseTextbox = true;
    tbNumericSource.Text = "";
    tbTextSource.Text = "";
    TextboxIsNumeric = false;
    AllowDecimalsInTextbox = true;
    AllowNegativeInTextbox = true;
    AllowBlankTextbox = true;

    ddSource.ClearSelection();
    //AllowFreeTextInDropdown = false;

    Enabled = true;
    ReadOnly = false;
    //UserControlLabel = "";
    //ShowUserControlLabel = false;
    //ErrorText = "";
  }


  /// <summary>
  ///TBD Sets things up to monitor changes to this control so that
  /// the user is warned if he tries to leave the page without
  /// first saving changes.
  /// </summary>
  public void MonitorChanges()
  {
  }


  /// <summary>
  ///TBD Gets or sets the error text that appears alongside the
  /// user control when an error is detected.
  /// </summary>
  //public string ErrorText
  //{get; set;}


  /// <summary>
  /// Public event indicating that the selection in the ddSourceType dropdown changed.
  /// Pages that contain an AmpTextboxOrDropdown user control can define
  /// event handlers for this event.
  /// </summary>
  public event EventHandler EventSourceTypeChanged;


  /// <summary>
  /// When the selection in ddSourceType changes, raise the EventSourceTypeChanged
  /// event to the containing page.
  /// </summary>
  private void handleChangeInDdSourceType(object sender, EventArgs e)
  {
    if (EventSourceTypeChanged != null)
    {
      EventSourceTypeChanged(this, e);
    }
  }


  /// <summary>
  /// Initializes the user control.
  /// </summary>
  protected override void OnInit(EventArgs e)
  {
    // InitializeDdSourceType() is called here so that it is "filled"
    // before the client page's Page_Load() is executed.
    InitializeDdSourceType();

    // Define event handler for change in ddSourceType selection.
    //TBD Although this code is executed, the event handler doesn't fire at the expected time.
    //Check ViewState of ddSourceType?
    ddSourceType.SelectedIndexChanged += new EventHandler(handleChangeInDdSourceType);

    base.OnInit(e);
  }


  /// <summary>
  /// Initializes the text of the ddSourceType's two items, which describe the choices of textbox vs. dropdown.
  /// </summary>
  private void InitializeDdSourceType()
  {
    if (ddSourceType.Items.Count == 0)
    {
      string textstr;
      textstr = GetGlobalResourceObject("AmpWizard", "TEXT_FIXED_VALUE").ToString();
      ddSourceType.Items.Add(new ListItem(textstr, textstr));
      textstr = GetGlobalResourceObject("AmpWizard", "TEXT_GET_FROM_PARAM_TABLE_COLUMN").ToString();
      ddSourceType.Items.Add(new ListItem(textstr, textstr));
    }
  }


}