using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
  [DataContract(Namespace = "MetraTech")]
  public class TaxType : Type// ChargeType
  {
    #region Properties

    /// <summary>
    /// The name of the property that specifes the geocode for the calculated tax.
    /// A GeoCode is a geographic identifier for unique combinations of tax juridictions
    /// </summary>
    [DataMember]
    public string GeoCodeProperty { get; set; }

    /// <summary>
    /// The name of the property that specifes the tax category for the calculated tax
    /// </summary>
    [DataMember]
    public string TaxCategoryProperty { get; set; }

    /// <summary>
    /// The name of the property that specifes the tax authority for the calculated tax
    /// The tax authority represents the goverment agency that receives this tax revenue
    /// </summary>
    [DataMember]
    public string TaxAuthorityProperty { get; set; }

    /// <summary>
    /// The name of the property that specifes the tax location for the calculated tax.
    /// This code is used in tax forms for reporting purposes
    /// </summary>
    [DataMember]
    public string TaxLocationProperty { get; set; }

    /// <summary>
    /// The name of the property that specifes the tax authority for the calculated tax
    /// Some tax authorities used 3rd party agencies to collect the reports on their behalf
    /// </summary>
    [DataMember]
    public string TaxReportToProperty { get; set; }

    #endregion

    #region Constructor
    public TaxType():base(BaseType.Tax)
    { }
    #endregion
  }
}