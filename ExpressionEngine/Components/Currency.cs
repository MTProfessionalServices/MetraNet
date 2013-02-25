namespace MetraTech.ExpressionEngine.Components
{
    /// <summary>
    /// A currency is basically a UoM that constantly changes... need to think through object model as it relates to UnitOfMeasures...
    /// We will have to support imaginary currencies (i.e., "tokens");
    /// Conversions will be point-to-point and effective dated (default is daily)
    /// Currencies should be an enum and not a string (although we'll need to have string conversions to support legacy metranet)
    /// We will want to use some standard for names etc.
    /// </summary>
    public class Currency
    {
        #region Properties

        /// <summary>
        /// The symbol (i.e., $) I assume these aren't localized
        /// </summary>
        public string Symbol { get; set; }

        /// <summary>
        /// Some standards based label (i.e., USD). I assume that these aren't localized
        /// </summary>
        public string Label { get; set; }

        /// <summary>
        /// Indicates if the currency is virtual
        /// </summary>
        public bool IsVirtual { get; set; }

        #endregion
    }
}
