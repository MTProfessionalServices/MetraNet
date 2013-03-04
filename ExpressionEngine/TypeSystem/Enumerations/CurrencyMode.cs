namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
{
    /// <summary>
    /// Indicates how the Currency is determined.
    /// </summary>
    public enum CurrencyMode
    {
        /// <summary>
        /// Either not a numeric or it's unknown
        /// </summary>
        None,

        /// <summary>
        /// Implied by the context which is up to the developer.
        /// </summary>
        Context,

        /// <summary>
        /// Always the same (i.e., USD). Specified in the Currency field
        /// </summary>
        Fixed,

        /// <summary>
        /// Determined via a property within the same property collection. Property name specified in the CurrencyProperty property.
        /// </summary>
        Property
    }
}
