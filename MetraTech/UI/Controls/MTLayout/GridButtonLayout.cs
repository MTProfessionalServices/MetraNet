using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls.MTLayout
{
  [Serializable]
  public class GridButtonLayout
  {
    public string ButtonID;
    public LocalizableString ButtonText;
    public LocalizableString ToolTip;
    public string IconClass;
    public string JSHandlerFunction;
    public RequiredCapabilityList RequiredCapabilities = new RequiredCapabilityList();
  }
}
