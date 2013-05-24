using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using MetraTech.DomainModel.Enums.Core.Global;

namespace MetraTech.Agreements.Models
{
  // NOTE: This model is based off of the SpecificationCharacteristic class from the MetraTech.DomainModel.ProductCatalog namespace
  public class SharedPropertyModel
  {
    #region ID
    /// <summary>
    /// This is the identifier of the shared property.  This is null before the property is saved to the DB for the first time.
    /// </summary>
    public int? ID { get; set; }
    #endregion

    #region Name
    /// <summary>
    /// This is the name of the shared property.
    /// </summary>
    [StringLength(40)]
    public string Name { get; set; }
    #endregion

    #region Description
    /// <summary>
    /// This is the Description of the shared property.
    /// </summary>
    [StringLength(40)]
    public string Description { get; set; }
    #endregion

    #region Category
    /// <summary>
    /// This is the Category of the shared property.
    /// </summary>
    [StringLength(40)]
    public string Category { get; set; }
    #endregion

    #region PropType
    /// <summary>
    /// This is the type of the shared property.
    /// </summary>
    public PropertyType PropType { get; set; }
    #endregion
  
    #region IsRequired
    /// <summary>
    /// This is if the shared property is required on the entity or not.
    /// </summary>
    public bool IsRequired { get; set; }
    #endregion

    #region DisplayName
    /// <summary>
    /// This is the display name of the shared property.
    /// </summary>
    public string DisplayName { get; set; }
    #endregion


    #region LocalizedCategories
    /// <summary>
    /// This is a collection of localized display names for the category of the shared property. 
    /// The collection is keyed by values from the LanguageCode enumeration.
    /// </summary>
    public Dictionary<LanguageCode, string> LocalizedCategories { get; set; }
    #endregion
    
    #region LocalizedDisplayNames
    /// <summary>
    /// This is a collection of localized display names for the shared property. 
    /// The collection is keyed by values from the LanguageCode enumeration.
    /// </summary>
    public Dictionary<LanguageCode, string> LocalizedDisplayNames { get; set; }
    #endregion

    #region LocalizedDescriptions
    /// <summary>
    /// This is a collection of localized descriptions for the shared property.  
    /// The collection is keyed by values from the LanguageCode enumeration.  
    /// If a value cannot be found for a specific LanguageCode, 
    /// the value from the Description property should be used as a default.
    /// </summary>
    public Dictionary<LanguageCode, string> LocalizedDescriptions { get; set; }
    #endregion

    #region SharedPropertyValues
    /// <summary>
    /// This is the collection of SharedPropertyValues associated with the shared property.
    /// </summary>
    public List<SharedPropertyValueModel> SharedPropertyValues { get; set; }
    #endregion

    #region DisplayOrder
    /// <summary>
    /// This is the display order of the shared property.
    /// </summary>
    public int? DisplayOrder { get; set; }
    #endregion

    #region UserVisible
    /// <summary>
    /// This attribute determines if the shared property is user visible.
    /// </summary>
    public bool UserVisible { get; set; }
    #endregion

    #region UserEditable
    /// <summary>
    /// This attribute determines if the shared property is user editable.
    /// </summary>
    public bool UserEditable { get; set; }
    #endregion

    #region StartDate
    /// <summary>
    /// This attribute determines the start date of the shared property.
    /// </summary>
    public DateTime StartDate { get; set; }
    #endregion

    #region EndDate
    /// <summary>
    /// This attribute determines the end date of the shared property.
    /// </summary>
    public DateTime EndDate { get; set; }
    #endregion

    #region MinValue
    /// <summary>
    /// This is the minimum value of the shared property.
    /// </summary>
    public string MinValue { get; set; }
    #endregion

    #region MaxValue
    /// <summary>
    /// This is the maximum value of the shared property.
    /// </summary>
    public string MaxValue { get; set; }
    #endregion 
  }
}