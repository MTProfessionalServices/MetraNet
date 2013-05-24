using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Threading;
using Core.Common;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.Basic.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [KnownType(typeof(EnumEntry))]
  [KnownType(typeof(LocalizedEntry))]
  [Serializable]
  public class EnumType
  {
    #region Public Methods
    public EnumType()
    {
      Entries = new List<EnumEntry>();
      LocalizedLabels = new List<LocalizedEntry>();
    }

    public virtual EnumType Clone()
    {
      var enumType = new EnumType();

      enumType.Id = Id;
      enumType.Name = Name;
      enumType.Namespace = Namespace;
      enumType.AssemblyName = AssemblyName;
      Entries.ForEach(e => enumType.Entries.Add(e.Clone()));
      LocalizedLabels.ForEach(l => enumType.LocalizedLabels.Add(l.Clone()));
      enumType.FQN = FQN;

      return enumType;
    }

    #endregion

    #region Properties
    [DataMember]
    public int Id { get; set; }

    /// <summary>
    ///    The C# enum name
    /// </summary>
    [DataMember]
    public string Name { get; set; }

    /// <summary>
    ///    The namespace for this enum
    /// </summary>
    [DataMember]
    public string Namespace { get; set; }

    /// <summary>
    ///    The assembly name
    /// </summary>
    [DataMember]
    public string AssemblyName { get; set; }

    /// <summary>
    ///    Entries for this enum
    /// </summary>
    [DataMember]
    public virtual List<EnumEntry> Entries { get; set; }

    /// <summary>
    ///   LocalizedEntry for each enum value
    /// </summary>
    [DataMember]
    public virtual List<LocalizedEntry> LocalizedLabels { get; set; }

    [DataMember]
    public string FQN { get; set; }
    #endregion

    #region Public Methods
    public int GetDbEnumValue(int cSharpEnumValue)
    {
      int dbEnumValue = Int32.MinValue;
      EnumEntry enumEntry = 
        Entries.Find(e => e.CSharpValue != null && (int)e.CSharpValue == cSharpEnumValue ? true : false);
      
      if (enumEntry != null)
      {
        dbEnumValue = enumEntry.DbValue;
      }

      return dbEnumValue;
    }

    public object GetCSharpEnumValue(int dbEnumValue)
    {
      object cSharpEnumValue = null;
      EnumEntry enumEntry = Entries.Find(e => e.DbValue == dbEnumValue);
      if (enumEntry != null)
      {
        cSharpEnumValue = enumEntry.CSharpValue;
      }

      return cSharpEnumValue;
    }

    public string GetLocalizedLabel()
    {
      string localizedLabel = String.Empty;

      LocalizedEntry localizedEntry =
        LocalizedLabels.Find(l => l.Locale == Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName);

      if (localizedEntry != null)
      {
        localizedLabel = localizedEntry.Value;
      }
      else
      {
        localizedLabel = Name;
      }

      return localizedLabel;
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as EnumType;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null && compareTo.FQN == FQN;
    }

    public override int GetHashCode()
    {
      return FQN.GetHashCode();
    }

    public override string ToString()
    {
      return String.Format("EnumType: '{0}'", FQN);
    }

   
    #endregion

    #region Internal Methods
    internal List<string> GetLocalizationKeys()
    {
      var localizationKeys = new List<string>();

      localizationKeys.Add(FQN);
      Entries.ForEach(e => localizationKeys.Add(e.FQN));

      return localizationKeys;
    }

    internal void InitLocalizationData(List<LocalizedEntry> localizedEntries)
    {
      if (!String.IsNullOrEmpty(FQN))
      {
        List<LocalizedEntry> labelLocalizedEntries =
          localizedEntries.FindAll(l => l.LocaleKey.ToLower() == FQN.ToLower());

        LocalizedLabels.Clear();

        int i = 0;
        foreach (LocalizedEntry localizedEntry in labelLocalizedEntries)
        {
          if (i == 0)
          {
            Id = localizedEntry.Id;
          }

          LocalizedLabels.Add(localizedEntry);
        }
      }

      Entries.ForEach(e => e.InitLocalizationData(localizedEntries));
    }
    #endregion

    #region Validation
    public bool Validate(out List<ErrorObject> validationErrors)
    {
      validationErrors = new List<ErrorObject>();

      return validationErrors.Count > 0 ? false : true;
    }
    #endregion
  }
}
