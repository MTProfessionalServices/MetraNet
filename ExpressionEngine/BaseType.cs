namespace MetraTech.ExpressionEngine
{
    //The underlying data type. DataTypeInfo
    public enum BaseType
    {
        Unknown,            // Used so that we don't need to do nullable type casting (i.e., BaseType?) What FIRST so that this is the default!
        String,
        Integer,
        Integer32,
        Integer64,
        DateTime,
        ComplexType,             //Spans everying from BMEs to ProductViews
        Enumeration,            
        Decimal,
        Float,
        Double,
        Boolean,
        Any,                // Used to mactch any of the data types
        Numeric,            // See DataTypeInfo.IsNumeric
        Guid,
        Binary,
        UniqueIdentifier,   //This is different than a Guid
        Charge              //Decimal with Currency
    }
}
