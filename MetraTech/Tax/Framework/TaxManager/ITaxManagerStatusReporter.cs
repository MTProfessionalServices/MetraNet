
namespace MetraTech.Tax.Framework
{
    /// <summary>
    /// This interface is used by tax adapters (MetraTax, BillSoft, Taxware, etc.)
    /// to report messages back to the application using the tax manager.
    /// Typical use is the tax adapter is reporting messages back to the
    /// EOP or scheduled adapter.  See TaxAssistantStatusReporter as an 
    /// example implementation of this interface.
    /// </summary>
    public interface ITaxManagerStatusReporter
    {
        /// <summary>
        /// Report an information message about how tax calculations are
        /// going.
        /// </summary>
        /// <param name="detail"></param>
        void ReportInfo(string detail);

        /// <summary>
        /// Report a warning message about tax calculations.
        /// </summary>
        /// <param name="detail"></param>
        void ReportWarning(string detail);
    }
}
