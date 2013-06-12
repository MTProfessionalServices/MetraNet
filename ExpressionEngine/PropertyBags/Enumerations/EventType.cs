namespace MetraTech.ExpressionEngine.PropertyBags.Enumerations
{
    /// <summary>
    /// Used to further qualify ProductView entities
    /// </summary>
    public enum EventType
    {
        /// <summary>
        /// Unknown is the default value so that when an upgrade is done it's clear to the person doing the upgrade
        /// which events need to set. This value should always be first so that it's the default.
        /// </summary>
        Unknown,

        /// <summary>
        /// Money flows into the system
        /// </summary>
        Charge,

        /// <summary>
        /// Money flows out of the system
        /// </summary>
        Payment
    }
}
