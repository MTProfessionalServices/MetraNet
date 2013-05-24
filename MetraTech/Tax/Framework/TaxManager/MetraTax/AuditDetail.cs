namespace MetraTech.Tax.Framework
{
    /// <summary>
    /// This class is used to record details about how the MetraTax tax
    /// rate was determined.
    /// </summary>
    public class AuditDetail
    {
        // The rate schedule that was used for the TaxBand parameter table
        public int TaxBandRateScheduleID { set; get; }

        // The audit ID that was used for the TaxBand parameter table
        public int TaxBandAuditID { set; get; }

        // The rate schedulethat was used for the TaxRate parameter table
        public int TaxRateRateScheduleID { set; get; }

        // The audit ID that was used for the TaxRate parameter table
        public int TaxRateAuditID { set; get; }

        // The override tax band that was used, if any.
        // 0 if no override tax band, otherwise the enum value of
        // the override tax band.
        public int OverrideTaxBand { set; get; }

        // An identifier of the format version of the string
        // of the audit details.
        private const int AUDIT_DETAIL_VERSION = 1;

        // The maximum permissible length of string version
        // of the audit information.
        private const int AUDIT_DETAIL_MAX_LENGTH = 255;

        /// <summary>
        /// Constructor
        /// </summary>
        public AuditDetail()
        {
            TaxBandRateScheduleID = 0;
            TaxBandAuditID = 0;
            TaxRateRateScheduleID = 0;
            TaxRateAuditID = 0;
            OverrideTaxBand = 0;
        }

        /// <summary>
        /// Come up with a string version of audit details.
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            string s = "" + AUDIT_DETAIL_VERSION + "|" + TaxBandRateScheduleID + "|" + TaxBandAuditID + "|" +
                       TaxRateRateScheduleID + "|" + TaxRateAuditID + "|" + OverrideTaxBand;
            if (s.Length > AUDIT_DETAIL_MAX_LENGTH)
            {
                s = s.Substring(0, AUDIT_DETAIL_MAX_LENGTH);
            }

            return s;
        }
    }
}
