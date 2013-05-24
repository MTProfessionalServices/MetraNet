#region

using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;

#endregion

namespace MetraTech.Tax.Framework.MetraTax
{
  // Represents a row in a TaxBand parameter table.
  // Each row maps a country/product code to a tax band.
  public struct TaxBandRateScheduleRow
  {
    // The product code
    private string m_productCode;

    // The rate schedule id for the parameter table.
    public int Id { set; get; }

    // Identifies the particular edited version of the rate schedule.
    public int AuditId { set; get; }

    // The MetraTax country code of eligibility.
    // May or may not be the global MetraTech country code.
    public int CountryCode { set; get; }

    // The tax band that should be used for the given country/product code
    public TaxBand TaxBand { set; get; }

    // The product code
    public string ProductCode
    {
      set { m_productCode = value.ToLower(); }
      get { return m_productCode; }
    }
  }
}