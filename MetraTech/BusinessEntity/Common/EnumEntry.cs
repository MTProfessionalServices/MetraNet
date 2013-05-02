using System;
using System.Runtime.Serialization;
using MetraTech.BusinessEntity.Core.Model;

namespace MetraTech.BusinessEntity.Common
{
  [DataContract]
  [Serializable]
  public class EnumEntry : IEnumEntry
  {
    #region Properties

    /// <summary>
    ///    t_enum_data.id_enum_data
    /// </summary>
    [DataMember]
    public virtual int Id { get; private set; }

    /// <summary>
    ///    t_enum_data.nm_enum_data 
    /// </summary>
    [DataMember]
    public virtual string DbEnumEntry { get; set; }


    /// <summary>
    ///    The EnumEntry portion of [Namespace/EnumType/EnumEntry] in t_enum_data.nm_enum_data
    /// </summary>
    [DataMember]
    public virtual string Name 
    { 
      get
      {
        string name = String.Empty;
        if (!String.IsNullOrEmpty(DbEnumEntry))
        {
          name = DbEnumEntry.Substring(DbEnumEntry.LastIndexOf('/') + 1);
        }
        return name;
      }
    }

    /// <summary>
    ///   The english localized value for this enum entry.
    /// 
    ///    select tx_description from t_description de
    ///    inner join t_enum_data en on en.id_enum_data = de.id_desc
    ///    inner join t_language lg on lg.id_lang_code = de.id_lang_code
    ///    where de.id_desc = Id and lg.tx_lang_code = 'us'
    ///      
    /// </summary>
    [DataMember]
    public virtual string Label { get; set; }

    #endregion
  }
}
