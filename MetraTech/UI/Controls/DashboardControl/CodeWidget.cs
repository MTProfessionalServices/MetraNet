using System;
using System.Reflection;
using System.ComponentModel;
using MetraTech.UI.Tools;

namespace MetraTech.UI.Controls
{
  public class CodeWidget : BaseWidget
  {
    private readonly Logger _mtLog = new Logger("[Dashboard]");

    protected override void OnLoad(EventArgs e)
    {
      EnsureChildControls();
      base.OnLoad(e);
    }

    protected override void CreateChildControls()
    {
      var controlPath = Path; 
      try
      {
        var uc = Page.LoadControl(controlPath);
        uc.ID = Name + "_uc";

        foreach (var param in Parameters)
        {
          try
          {
            var pi = Utils.GetPropertyInfo(uc, param.Name);
            if (pi != null)
            {
            var val = CoherceStringToPropertyType(null, pi, param.Value);
            pi.SetValue(uc, val, null);
          }
            else
            {
              _mtLog.LogWarning(string.Format("Object does not contain property {0}", param.Name));
            }
          }
          catch (Exception e)
          {
            _mtLog.LogException(String.Format("Unable to process parameter {0}", param.Name), e);
          }
        }
        
        Controls.Add(uc);
      }
      catch (Exception e)
      {
        _mtLog.LogException(String.Format("Unable to load control from {0}", controlPath), e);
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
        var propertyType = pi.PropertyType;
        if (propertyType == value.GetType())
        {
          return value;
        }

        var converter = TypeDescriptor.GetConverter(propertyType);
        if (converter.CanConvertFrom(value.GetType()))
        {
          result = converter.ConvertFrom(value);
        }
      }

      return result;
    }
  }
}
