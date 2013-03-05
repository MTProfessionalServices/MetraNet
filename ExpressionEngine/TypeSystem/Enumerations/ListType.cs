namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
{
    /// <summary>
    /// Indicates if the data type is a scalar or some type of list
    /// </summary>
    public enum ListType
    {
        /// <summary>
        /// No list type (i.e., a scalar)
        /// </summary>
        None, 

        /// <summary>
        /// A basic list (i.e., enumerable)
        /// </summary>
        List,

        /// <summary>
        /// A key-based list (i.e., a dictionary)
        /// </summary>
        KeyList
    }
}
