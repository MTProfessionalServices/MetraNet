using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.UI.Controls.Layouts;

namespace MetraTech.UI.Controls
{
  public class WidgetParameter
  {
    private string name;
    public string Name
    {
      get { return name; }
      set { name = value; }
    }

    private string _value;
    public string Value
    {
      get { return _value; }
      set { _value = value; }
    }
    private string description;
    public string Description
    {
      get { return description; }
      set { description = value; }
    }

    private bool required;
    public bool Required
    {
      get { return required; }
      set { required = value; }
    }

    public void LoadFromLayout(WidgetParameterLayout layout)
    {
      Name = layout.Name;
      Value = layout.Value;
      Description = layout.Description;
      Required = layout.Required;
    }

    public void LoadFromBME(Core.UI.Parameter param)
    {
      Name = param.Name;
      Value = param.Value;
      Description = param.Description;
      Required = (param.IsRequired.HasValue)? param.IsRequired.Value : false;
    }
  }
}
