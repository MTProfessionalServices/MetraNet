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
        ContextDriven,  

        /// <summary>
        /// Always the same (i.e., hours or inches). Specified in the UomQualifier field
        /// </summary>
        FixedUnitOfMeasure,   
 
        /// <summary>
        /// Always within a given Unit of Measure FixedCategory (i.e., time or length). Specified in the UomQualifier field
        /// </summary>
        FixedCategory, 

        /// <summary>
        /// Determined via a property within the same property collection. PropertyDriven name specified in the UomQualifier property.
        /// </summary>
        PropertyDriven  
    }
}
