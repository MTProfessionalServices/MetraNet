
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;

namespace MetraTech.Tax.Framework.MetraTax
{
    // Represents a row int TaxRate parameter table.
    // Each row maps a country/zone/tax band to a specific rate
  internal class TaxRateRateScheduleRow
    {
        // The ID for the row
        public int Id { set; get; }

        // Identifies the particular edited version of the rate schedule.
        public int AuditId { set; get; }

        // The country code.
        // May or may not be the MetraTech global country code.
        public int CountryCode { set; get; }

        // The special geographic zone
        public TaxZone TaxZone { set; get; }

        // The tax band
        public TaxBand TaxBand { set; get; }

        // The tax rate to use for the country/zone/tax band
        public decimal TaxRate { set; get; }

        // The name that should be used to describe the country/zone/tax band
        public string TaxName { set; get; }
    }
}