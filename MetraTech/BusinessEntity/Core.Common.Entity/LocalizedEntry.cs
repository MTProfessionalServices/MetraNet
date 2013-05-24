using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.Basic;

namespace Core.Common
{
  [Serializable]
  [DataContract]
  public class LocalizedEntry
  {
    #region Public Properties
    // id_enum_data from t_enum_data
    [DataMember]
    public virtual int Id { get; set; }

    // nm_enum_data from t_enum_data
    [DataMember]
    public virtual string LocaleKey { get; set; }

    // tx_desc from t_description
    [DataMember]
    public virtual string Value { get; set; }

    // This represents the CultureInfo.TwoLetterISOLanguageName
    // Based on InternalLocale and the mapping in languageMappings
    [DataMember]
    public virtual string Locale { get; set; }

    // tx_lang_code from t_language
    [DataMember]
    public virtual string InternalLocale { get; set; }

    public static string SqlQuery
    {
      get
      {
        return "GetLocalizedEntriesSql";
      }
    }

    public static string OracleQuery
    {
      get
      {
        return "GetLocalizedEntriesOracle";
      }
    }

    public static string LocaleKeysParameter
    {
      get
      {
        return "localeKeys";
      }
    }

    public static string SeparatorParameter
    {
      get
      {
        return "separator";
      }
    }
    #endregion

    public LocalizedEntry Clone()
    {
      var localizedEntry = new LocalizedEntry();
      localizedEntry.Id = Id;
      localizedEntry.LocaleKey = LocaleKey;
      localizedEntry.Locale = Locale;
      localizedEntry.InternalLocale = InternalLocale;
      localizedEntry.Value = Value;

      return localizedEntry;
    }

    public void SetLocale()
    {
      Check.Require(!String.IsNullOrEmpty(InternalLocale),
                    String.Format("Cannot find metratech language identifier for key '{0}' and Id '{1}'",
                                  LocaleKey, Id));

      string locale;
      languageMappings.TryGetValue(InternalLocale.ToLower(), out locale);
      Check.Require(!String.IsNullOrEmpty(locale),
                    String.Format("Cannot map metratech language identifier '{0}' to a TwoLetterISOLanguageName for key '{1}' and Id '{2}'",
                                  InternalLocale, LocaleKey, Id));
      Locale = locale;
    }

    public override string ToString()
    {
      return String.Format("Locale: '{0}', Key: '{1}', Value: '{2}', Id: '{3}'", Locale, LocaleKey, Value, Id);
    }

    #region Private Properties
    private static readonly Dictionary<string, string> languageMappings =
      new Dictionary<string, string>()
        {
          {"us", "en"},
          {"de", "de"},
          {"cn", "zh"},
          {"fr", "fr"},
          {"jp", "ja"},
          {"it", "it"}
        };
    #endregion
  }
}

