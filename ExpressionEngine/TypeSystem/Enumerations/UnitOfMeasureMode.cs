namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
{
    /// <summary>
    /// Indicates how the Unit of Measuse is determined. Only valid for numeric data types.
    /// </summary>
    public enum UnitOfMeasureMode
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
        /// Always the same (i.e., hours or inches). Specified in the UomQualifier field
        /// </summary>
        Fixed,   
 
        /// <summary>
        /// Always within a given Unit of Measure Category (i.e., time or length). Specified in the UomQualifier field
        /// </summary>
        Category, 

        /// <summary>
        /// Determined via a property within the same property collection. Property name specified in the UomQualifier property.
        /// </summary>
        Property  
    }
}
