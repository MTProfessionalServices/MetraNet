using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Reflection;
using System.ComponentModel;

namespace MetraTech.UI.Controls
{
  public class CodeWidget : BaseWidget
  {
    private MetraTech.Logger mtLog = new Logger("[Dashboard]");

    public CodeWidget()
    {
      
    }

    protected override void OnLoad(EventArgs e)
    {
      EnsureChildControls();
      base.OnLoad(e);
    }

    protected override void CreateChildControls()
    {
      string controlPath = this.Path; 
      try
      {
        Control uc = (Control)Page.LoadControl(controlPath);
        uc.ID = base.Name + "_uc";

        foreach (WidgetParameter param in Parameters)
        {
          try
          {
            PropertyInfo pi = uc.GetType().GetProperty(param.Name);
            //object val = CoherceStringToPropertyType(uc, pi, param.ParameterValue);
            if (pi != null)
            {
            //string val = param.Value;
            object val = CoherceStringToPropertyType(null, pi, param.Value);
            pi.SetValue(uc, val, null);
          }
            else
            {
              mtLog.LogWarning(string.Format("Object does not contain property {0}", param.Name));
            }
          }
          catch (Exception e)
          {
            mtLog.LogException(String.Format("Unable to process parameter {0}", param.Name), e);
            continue;
          }
        }
        
        Controls.Add(uc);
      }
      catch (Exception e)
      {
        mtLog.LogException(String.Format("Unable to load control from {0}", controlPath), e);
      }
      base.CreateChildControls();
    }

    /// <summary>
    /// Converts a value to a proper data type
    /// </summary>
    /// <param name="targetObject"></param>
    /// <param name="pi"></param>
    /// <param name="value"></param>
    /// <returns></returns>
    protected object CoherceStringToPropertyType(object targetObject, PropertyInfo pi, object value)
    {
      object result = null;
      
      if (pi != null && value != null)
      {
        Type propertyType = pi.PropertyType;

        if (propertyType == value.GetType())
        {
          return value;
        }

        TypeConverter converter = TypeDescriptor.GetConverter(propertyType);

        if (converter != null)
        {

          if (converter.CanConvertFrom(value.GetType()))
          {
            result = converter.ConvertFrom(value);
          }
        }
      }
      return result;
    }

    
  }
}
