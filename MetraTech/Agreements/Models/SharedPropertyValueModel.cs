using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using MetraTech.DomainModel.Enums.Core.Global;

namespace MetraTech.Agreements.Models
{
  // NOTE: This model is based off of the SpecCharacteristicValue class from the MetraTech.DomainModel.ProductCatalog namespace
  public class SharedPropertyValueModel
  {
    #region ID
    /// <summary>
    /// This is the identifier of the shared property value.  This is null before the value is saved to the DB for the first time.
    /// </summary>
    public int? ID { get; set; }
    #endregion

    #region IsDefault
    /// <summary>
    /// This is true if this is the default shared property value.
    /// </summary>
    public bool IsDefault { get; set; }
    #endregion

    #region Value
    /// <summary>
    /// This is the shared property value.
    /// </summary>
    [StringLength(20)]
    public string Value { get; set; }
    #endregion

    #region ValueID
    /// <summary>
    /// This is the id of the shared property value.
    /// </summary>
    public int ValueID { get; set; }
    #endregion

    #region LocalizedDisplayValues
    /// <summary>
    /// This is a collection of localized display names for the shared property value. 
    /// The collection is keyed by values from the LanguageCode enumeration.
    /// </summary>
    public Dictionary<LanguageCode, string> LocalizedDisplayValues { get; set; }
    #endregion
  }
}