#region

using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using Boolean = System.Boolean;

#endregion

namespace MetraTech.Tax.Framework.MetraTax
{
    /// <summary>
    /// This class represents information stored in the account 
    /// concerning taxes.  This information is stored in the
    /// internal account view (t_av_internal).
    /// </summary>
    public struct TaxAccountView
    {
        // The account we are talking about
        public int AccountId { set; get; }

        // What tax vendor should be used?
        public TaxVendor Vendor { set; get; }

        // True if the database field was not set.
        public Boolean IsNullVendor { set; get; }

        // What country should be used in tax calculations.
        // This is a country code which could a custom country code
        // or the MetraTech global country code.
        public int MetraTaxCountryCode { set; get; }

        // True if the database field was not set.
        public Boolean IsNullMetraTaxCountry { set; get; }

        // What is the special geographic tax zone (if any)?
        public TaxZone MetraTaxCountryZone { set; get; }

        // True if the database field was not set.
        public Boolean IsNullMetraTaxCountryZone { set; get; }

        // Is override specified?
        public Boolean HasMetraTaxOverride { set; get; }

        // True if the database field was not set.
        public Boolean IsNullHasMetraTaxOverride { set; get; }

        // If override was specified, what tax band should be used?
        public TaxBand MetraTaxOverrideTaxBand { set; get; }

        // True if the database field was not set.
        public Boolean IsNullMetraTaxOverrideTaxBand { set; get; }
    }
}

