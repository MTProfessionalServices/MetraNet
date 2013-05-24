using System;
using System.Threading;
using System.Web;
using System.Resources;
using System.Collections.Specialized;
using System.ComponentModel;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Localization;

namespace MetraTech.UI.Common
{
  public class LocalizableStringConverter : TypeConverter
  {
    public override bool CanConvertFrom(ITypeDescriptorContext context,
      Type sourceType)
    {

      if (sourceType == typeof(string))
      {
        return true;
      }
      return base.CanConvertFrom(context, sourceType);
    }

    public override object ConvertFrom(ITypeDescriptorContext context, System.Globalization.CultureInfo culture, object value)
    {
      if (value is string)
      {
        LocalizableString ls = new LocalizableString();
        return ls.ToString();
      }

      return base.ConvertFrom(context, culture, value);
    }

    public override bool CanConvertTo(ITypeDescriptorContext context, Type destinationType)
    {
      if (destinationType == typeof(string))
      {
        return true;
      }
      return base.CanConvertTo(context, destinationType);
    }

    public override object ConvertTo(ITypeDescriptorContext context, System.Globalization.CultureInfo culture, object value, Type destinationType)
    {
      if (destinationType == typeof(string))
      {
        return ((LocalizableString)value).ToString();
      }

      return base.ConvertTo(context, culture, value, destinationType);
    }

  }

  //[TypeConverter(typeof(LocalizableStringConverter))]
  public class LocalizableString : IConvertible
  {/*
    public LocalizableString(string value)
    {
      this._value = value;
    }
    */

    public bool IsEmpty()
    {
      if (String.IsNullOrEmpty(localizationTag) && String.IsNullOrEmpty(_value))
      {
        return true;
      }

      return false;
    }

    public static bool IsEmpty(LocalizableString ls)
    {
      if (ls == null)
      {
        return true;
      }

      return ls.IsEmpty();
    }

    public static implicit operator string(LocalizableString ls)
    {
      if (ls == null)
      {
        return string.Empty;
      }

      return ls.GetValue();
    }

    public static implicit operator LocalizableString(string value)
    {
      LocalizableString ls = new LocalizableString();
      ls.Value = value;

      return ls;
    }

    /// <summary>
    /// Get MetraNet language code for the current thread culture
    /// </summary>
    /// <returns></returns>
    public LanguageCode GetLanguageCode()
    {
      try
      {
        var languageCode = (LanguageCode)CommonEnumHelper.GetEnumByValue(typeof(LanguageCode), Thread.CurrentThread.CurrentUICulture.ToString());
        return languageCode;
      }
      catch (Exception)
      {
        return LanguageCode.US;
      }
    }

    /// <summary>
    /// Returns a displayable value for a localization string.  
    /// If LocalizationTag is available, it attempts to find a resource with that tag in local resources.
    /// If not found in local resources, attempt to find in global resources.
    /// If not found in global resources, return the value property, or empty string if value is unavailable.
    /// </summary>
    /// <returns></returns>
    public string GetValue()
    {
      // Go get MetraNet Localization if we have a FQN
      if (!String.IsNullOrEmpty(localizationFQN))
      {
        var localizedDecription = LocalizedDescription.GetInstance();
        return localizedDecription.GetByName(GetLanguageCode().ToString(), localizationFQN);
      }

      //both values are missing, return empty string
      if (IsEmpty())
      {
        return String.Empty;
      }

      //localization value is missing, then use the value
      if (String.IsNullOrEmpty(localizationTag))
      {
        return _value;
      }

      object resourceObject = null;

      //attempt to retrieve the string from local resource
      try
      {
        String path = HttpContext.Current.Request.Url.LocalPath;
        resourceObject = HttpContext.GetLocalResourceObject(path, localizationTag);
      }
      catch (MissingManifestResourceException) { }
      catch (InvalidOperationException) { }
      //if not found...
      if (resourceObject == null)
      {
        //...attempt to find it in global resources
        try
        {
          //if resourceClassKey was provided, use it, otherwise, read it from web.config
          String rcKey = resourceClassKey;

          if (String.IsNullOrEmpty(rcKey))
          {
            if (((NameValueCollection)HttpContext.Current.GetSection("appSettings")).HasKeys())
            {
              rcKey = ((NameValueCollection)HttpContext.Current.GetSection("appSettings")).Get("GlobalResourceClassKey");
            }
          }

          //no resource key could be obtained - use value property
          if (String.IsNullOrEmpty(rcKey))
          {
            return _value;
          }

          if(rcKey.Contains("App_GlobalResources/"))
          {
            rcKey = rcKey.Substring(rcKey.LastIndexOf("/") + 1);
          }
          resourceObject = HttpContext.GetGlobalResourceObject(rcKey, localizationTag);  

        }
        catch (MissingManifestResourceException) { }

        //...and if not found there use the hard-coded Value
        if (resourceObject == null)
        {
          return _value;
        }
      }

      //localization tag is present, then use it, but fall back on string value if no tag is present in resource file
      String localizedValue = resourceObject.ToString();
      if (String.IsNullOrEmpty(localizedValue))
      {
        localizedValue = _value;
      }

      return localizedValue;
    }

    private string resourceClassKey;
    public string ResourceClassKey
    {
      get { return resourceClassKey; }
      set { resourceClassKey = value; }
    }

    private string _value = "";

    public string Value
    {
      get { return _value; }
      set { _value = value; }
    }

    private string localizationTag;

    public string LocalizationTag
    {
      get { return localizationTag; }
      set { localizationTag = value; }
    }

    private string localizationFQN;
    public string LocalizationFQN
    {
      get { return localizationFQN; }
      set { localizationFQN = value; }
    }


    #region IConvertible Members

    TypeCode IConvertible.GetTypeCode()
    {
      return TypeCode.String;
    }

    bool IConvertible.ToBoolean(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    byte IConvertible.ToByte(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    char IConvertible.ToChar(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    DateTime IConvertible.ToDateTime(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    decimal IConvertible.ToDecimal(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    double IConvertible.ToDouble(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    short IConvertible.ToInt16(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    int IConvertible.ToInt32(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    long IConvertible.ToInt64(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    sbyte IConvertible.ToSByte(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    float IConvertible.ToSingle(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    string IConvertible.ToString(IFormatProvider provider)
    {
      return GetValue();
    }

    object IConvertible.ToType(Type conversionType, IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    ushort IConvertible.ToUInt16(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    uint IConvertible.ToUInt32(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    ulong IConvertible.ToUInt64(IFormatProvider provider)
    {
      throw new Exception("The method or operation is not implemented.");
    }

    #endregion
  }
}
