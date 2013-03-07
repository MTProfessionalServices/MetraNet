namespace MetraTech.ExpressionEngine.MTProperties.Enumerations
{
    /// <summary>
    /// The availability of a property
    /// </summary>
    public enum Availability
    {
        /// <summary>
        /// The availability of the property is unknown. This should always be the default
        /// </summary>
        Unknown,

        /// <summary>
        /// The property is always available.
        /// </summary>
        Always,

        /// <summary>
        /// The property is sometimes available. For example, not all entities of a given PropretyBagType have the same extended properties
        /// </summary>
        Sometimes,

        /// <summary>
        /// There are two properties with the same name but different data types
        /// </summary>
        Conflict
    }
}
