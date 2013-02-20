namespace MetraTech.ExpressionEngine
{
    //The underlying data type. DataTypeInfo
    public enum BaseType
    {
        // Used so that we don't need to do nullable type casting (i.e., BaseType?) 
        // We want this to be FIRST so that this is the default! (note DataTypeInfo does this in the constructor)
        Unknown,

        Any,                // Used to mactch any of the data types
        Binary,
        Boolean,
        ComplexType,        //Spans everying from BMEs to ProductViews
        Charge,             //Decimal with Currency
        DateTime,
        Decimal,
        Double,
        Enumeration,
        Float,
        Guid,
        Integer,
        Integer32,
        Integer64,
        Numeric,            // See DataTypeInfo.IsNumeric
        String,
        UniqueIdentifier    //This is different than a Guid
    }
}
