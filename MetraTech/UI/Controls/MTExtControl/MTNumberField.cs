using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MetraTech.UI.Controls
{
  [DefaultProperty("Text")]
  [ToolboxData("<{0}:MTNumberField runat=server></{0}:MTNumberField>")]
  public class MTNumberField : MTExtControl
  {
    #region JavaScript
    public string Options = @"allowDecimals:%%ALLOW_DECIMALS%%,
                              allowNegative:%%ALLOW_NEGATIVE%%,
                              decimalPrecision:%%DECIMAL_PRECISION%%,
                              decimalSeparator:'%%DECIMAL_SEPARATOR%%',
                              trailingZeros:%%TRAILING_ZEROS%%,
                              maxValue:%%MAX_VALUE%%,
                              minValue:%%MIN_VALUE%%,
                              minLength:%%MIN_LENGTH%%,
                              maxLength:%%MAX_LENGTH%%,
                              regex:%%VALIDATION_REGEX%%";
    #endregion

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(false)]
    [NotifyParentProperty(true)]
    public string DecimalPrecision
    {
      get
      {
        String s = (String)ViewState["DecimalPrecision"];
        return ((s == null) ? "10" : s);
      }

      set
      {
        ViewState["DecimalPrecision"] = value;
      }
    }
    
    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    public bool TrailingZeros
    {
      get
      {
        bool b = false;
        if (ViewState["TrailingZeros"] != null)
        {
          b = (bool)ViewState["TrailingZeros"];
        }
        return b;
      }

      set
      {
        ViewState["TrailingZeros"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    public bool AllowDecimals
    {
      get
      {
        bool b = false;
        if (ViewState["AllowDecimals"] != null)
        {
          b = (bool)ViewState["AllowDecimals"];
        }
        return b;
      }

      set
      {
        ViewState["AllowDecimals"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    public bool AllowNegative
    {
      get
      {
        bool b = true;
        if (ViewState["AllowNegative"] != null)
        {
          b = (bool)ViewState["AllowNegative"];
        }
        return b;
      }

      set
      {
        ViewState["AllowNegative"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string DecimalSeparator
    {
      get
      {
        String s = (String)ViewState["DecimalSeparator"];
        return (s ?? Thread.CurrentThread.CurrentUICulture.NumberFormat.NumberDecimalSeparator);
      }

      set
      {
        ViewState["DecimalSeparator"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string MaxValue
    {
      get
      {
        String s = (String)ViewState["MaxValue"];
        return ((s == null) ? Decimal.MaxValue.ToString() : s);
      }

      set
      {
        ViewState["MaxValue"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string MinValue
    {
      get
      {
        String s = (String)ViewState["MinValue"];
        return ((s == null) ? Decimal.MinValue.ToString() : s);
      }

      set
      {
        ViewState["MinValue"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public int MinLength
    {
      get
      {
        if (ViewState["MinLength"] == null)
        {
          return 0;
        }
        return (int)ViewState["MinLength"];
      }

      set
      {
        ViewState["MinLength"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public int MaxLength
    {
      get
      {
        if (ViewState["MaxLength"] == null)
        {
          return -1;
        }
        return (int)ViewState["MaxLength"];
      }

      set
      {
        ViewState["MaxLength"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string ValidationRegex
    {
      get
      {
        string s = (string)ViewState["ValidationRegex"];
        return ((String.IsNullOrEmpty(s)) ? "null" : s);
      }

      set
      {
        ViewState["ValidationRegex"] = value;
      }
    }

    #region Events
    protected override void OnInit(EventArgs e)
    {
      // MTNumberField can't use XType "NumberField" because Ext.form.NumberField
      // uses IEEE-754 double precision floating point, which supports
      // a precision of only 15 digits (total left and right of the decimal point).
      // Our database columns are now (22,10), which means that SQL Server
      // supports up to 12 digits left of the decimal point and up to 10 digits 
      // right of the decimal point.
      // Consequently, MTNumberField now uses new XType "LargeNumberField" to constrain
      // the value in the text field to be a decimal number with up to 12 digits left 
      // of the decimal point and up to 10 digits right of the decimal point.

      // Set values used in MTExtControl.cs.
      XTypeNameSpace = "ux.form";
      XType = "LargeNumberField";
     
      base.OnInit(e);
    }

    protected override void RenderContents(HtmlTextWriter output)
    {
      // modify js
      ControlScript = ControlScript.Replace("%%CONTROL_ID%%", this.ClientID);

      string options = Options.Replace("%%DECIMAL_PRECISION%%", DecimalPrecision);
      options = options.Replace("%%DECIMAL_SEPARATOR%%", DecimalSeparator);
      options = options.Replace("%%MAX_VALUE%%", MaxValue);
      options = options.Replace("%%MIN_VALUE%%", MinValue);
      options = options.Replace("%%MIN_LENGTH%%", MinLength.ToString());
      options = options.Replace("%%MAX_LENGTH%%", ((MaxLength == -1) ? "Number.MAX_VALUE" : MaxLength.ToString()));
      options = options.Replace("%%VALIDATION_REGEX%%", (String.IsNullOrEmpty(ValidationRegex)? "null" : ValidationRegex));
      options = options.Replace("%%ALLOW_DECIMALS%%", AllowDecimals.ToString().ToLower());
      options = options.Replace("%%ALLOW_NEGATIVE%%", AllowNegative.ToString().ToLower());
      options = options.Replace("%%TRAILING_ZEROS%%", TrailingZeros.ToString().ToLower());
      
      //attach options to OptionalExtConfig. NOTE: there is no duplicate resolution
      OptionalExtConfig = (String.IsNullOrEmpty(OptionalExtConfig) ? options : options + "," + OptionalExtConfig);

      // call base render
      base.RenderContents(output);
    }
    #endregion
  }
}
