namespace MetraTech.Tax.Framework
{
    /// <summary>
    /// The tax framework knows of 5 tax jurisdications.
    /// This matches the 5 tax jurisdications that are
    /// stored in t_acc_usage.  These 5 tax jurisdications are
    /// supported in the t_tax_output table that holds the results
    /// of tax calculations.
    /// </summary>
  public enum TaxJurisdiction
  {
    Unknown = -1,
    Federal = 0,
    State = 1,
    County = 2,
    Local = 3,
    Other = 4
  }

  /// <summary>
  /// Used to provided conversion utilities for the above enum.
  /// </summary>
  public static class TaxJurisdicationConverter
  {
    /// <summary>
        /// Given a TaxType enum, return a printable name of the tax type.
    /// </summary>
        /// <param name="type">type of tax jurisdication</param>
    /// <returns></returns>
    public static string ToTaxTypeName(this TaxJurisdiction type)
    {
      switch (type)
      {
        case TaxJurisdiction.Federal:
          return "federal";
        case TaxJurisdiction.State:
          return "state";
        case TaxJurisdiction.County:
          return "county";
        case TaxJurisdiction.Local:
          return "local";
        case TaxJurisdiction.Other:
          return "other";
        case TaxJurisdiction.Unknown:
          return "unknown";
                default:
                    return "unknown";
      }
    }

    /// <summary>
        /// Given the name of a tax type return the corresponding tax enum.
    /// </summary>
        /// <param name="type">type of tax jurisdication</param>
    /// <returns></returns>
    public static TaxJurisdiction ToTaxTypeEnum(this string type)
    {
      switch (type.ToLower().Trim())
      {
        case "federal":
          return TaxJurisdiction.Federal;
        case "state":
          return TaxJurisdiction.State;
        case "county":
          return TaxJurisdiction.County;
        case "local":
          return TaxJurisdiction.Local;
        case "other":
          return TaxJurisdiction.Other;
        case "unknown":
          return TaxJurisdiction.Unknown;
                default:
                    return TaxJurisdiction.Unknown;
      }
    }
  }
}