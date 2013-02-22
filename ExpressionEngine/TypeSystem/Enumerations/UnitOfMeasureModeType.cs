namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
{
    /// <summary>
    /// Indicates how the UoM is determined. Only valid for numeric data types.
    /// </summary>
    public enum UnitOfMeasureModeType
    {
        None,     // Either not a numeric or it's unknown
        Context,  // Implied by the context which is up to the developer.
        Fixed,    // Always the same (i.e., hours or inches). Specified in the UomQualifier field
        Category, // Always within a UomCategory (i.e., time or length). Specified in the UomQualifier field
        Property  // Determined via a property within the same property collection. Property name specified in the UomQualifier property.
    }
}
