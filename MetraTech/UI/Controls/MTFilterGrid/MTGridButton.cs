using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.UI.Controls
{
  /// <summary>
  /// Represents a button that appears at the bottom of MTFilterGrid
  /// </summary>
  public class MTGridButton
  {
    private string buttonID;

    /// <summary>
    /// Button ID
    /// </summary>
    public string ButtonID
    {
      get { return buttonID; }
      set { buttonID = value; }
    }

    private string buttonText;

    /// <summary>
    /// Text that appears on the button
    /// </summary>
    public string ButtonText
    {
      get { return buttonText; }
      set { buttonText = value; }
    }

    private string toolTip;
    /// <summary>
    /// Tooltip that shows up when hovering above the button
    /// </summary>
    public string ToolTip
    {
      get { return toolTip; }
      set { toolTip = value; }
    }

    private string iconClass;
    /// <summary>
    /// Gets or sets the icon class for the button
    /// </summary>
    public string IconClass
    {
      get { return iconClass; }
      set { iconClass = value; }
    }

    private string jsHandlerFunction;

    /// <summary>
    /// Javascript function that should process the button click event.  
    /// NOTE:The javascript function name must contain the ClientID suffix
    /// </summary>
    public string JSHandlerFunction
    {
      get { return jsHandlerFunction; }
      set { jsHandlerFunction = value; }
    }

    private string capability;
    /// <summary>
    /// gets or sets the capability required to show this button
    /// </summary>
    public string Capability
    {
      get { return capability; }
      set { capability = value; }
    }
  }
}
