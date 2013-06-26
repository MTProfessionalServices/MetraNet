using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public class EventChargeMapping
    {
        #region Properties
        public string ProductView { get; set; }
        public string ChargeName { get; set; }
        public string FieldName { get; set; }
        public CdeFieldMappingType FieldType { get; set; }
        public string ContributingField { get; set; }
        public int Precision { get; set; }
        public string PrecisionFormatted {get { return GetFormattedPrecision(); }}
        public string CurrencyField { get; set; }
        public string PercentageField { get; set; }
        public string Modifier { get; set; }
        public string Filter { get; set; }
        public int FieldOrder { get; set; }
        #endregion

        #region Methods

        public static string GetCsvHeaderString()
        {
            var s ="PRODUCTVIEW_NAME," +
                   "CHARGE_NAME," +
                   "FIELD_NAME," +
                   "FIELD_TYPE," +
                   "CONTRIBUTING_FIELD," +
                   "PRECISION," +
                   "CURRENCY_FIELD," +
                   "PERCENTAGE_FIELD," +
                   "MODIFIER," +
                   "FILTER," +
                   "FIELD_ORDER";
            return s;
        }

        public string GetCsvString(bool convertBodyToLower)
        {
            var s = ProductView + "," +
                    ChargeName + "," +
                    FieldName + "," +
                    FieldType.ToString() + "," +
                    ContributingField + "," +
                    PrecisionFormatted + "," +
                    CurrencyField + "," +
                    PercentageField + "," +
                    Modifier + "," +
                    Filter + "," +
                    FieldOrder;
            if (convertBodyToLower)
                s = s.ToLower();
            return s;
        }

        private string GetFormattedPrecision()
        {
            if (Precision == 0)
                return "-99";
            return null;
        }

        #endregion
    }
}
