namespace MetraTech.ExpressionEngine
{
    //The underlying data type. DataTypeInfo
    //Not sure why I'm getting an error message when I try to change to "Enum"... If that can't be addressed, switch to Enumeration
    //Should Charge be reanmed amont? Or do we want Charge and Amount?
    public enum BaseType
    {
        Unknown,            // Used so that we don't need to do nullable type casting (i.e., BaseType?) 
        String,
        Integer,
        Integer32,
        Integer64,
        DateTime,
        Entity,             //Spans evertying from BMEs to ProductViews
        _Enum,
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
