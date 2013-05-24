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
  [KnownType(typeof(LocalizedEntry))]
  [Serializable]
  public class EnumEntry
  {
    #region Public Methods
    public EnumEntry()
    {
      LocalizedLabels = new List<LocalizedEntry>();
    }

    public EnumEntry Clone()
    {
      var enumEntry = new EnumEntry();

      enumEntry.DbValue = DbValue;
      enumEntry.CSharpValue = CSharpValue;
      enumEntry.Name = Name;
      enumEntry.FQN = FQN;

      LocalizedLabels.ForEach(l => enumEntry.LocalizedLabels.Add(l.Clone()));

      return enumEntry;
    }

    #endregion

    #region Properties
    /// <summary>
    ///    id_enum_data from t_enum_data
    /// </summary>
    [DataMember]
    public int DbValue { get; set; }

    /// <summary>
    ///   CSharp value of the enum (0, 1, 2 ...etc). 
    /// </summary>
    public object CSharpValue { get; set; }

    /// <summary>
    ///    enum entry name from the xml file
    /// </summary>
    [DataMember]
    public string Name { get; set; }

    [DataMember]
    public string FQN { get; set;}
   
    /// <summary>
    ///   LocalizedEntry for each enum value
    /// </summary>
    [DataMember]
    public virtual List<LocalizedEntry> LocalizedLabels { get; set; }

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
      return String.Format("EnumEntry: '{0}'", FQN);
    }

    internal void InitLocalizationData(List<LocalizedEntry> localizedEntries)
    {
      List<LocalizedEntry> labelLocalizedEntries =
        localizedEntries.FindAll(l => l.LocaleKey.Trim().ToLower() == FQN.Trim().ToLower());

      LocalizedLabels.Clear();

      int i = 0;
      foreach (LocalizedEntry localizedEntry in labelLocalizedEntries)
      {
        if (i == 0)
        {
          DbValue = localizedEntry.Id;
        }

        LocalizedLabels.Add(localizedEntry);
      }
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
