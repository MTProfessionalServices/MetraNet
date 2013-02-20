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
        Charge,             //Decimal with Currency that is a, or part of a, charge or a settlement  ((PropertyAttribute))
        DateTime,
        Decimal,
        Double,
        Enumeration,
        Float,
        Guid,
        Money,              //Decimal with currency that is NOT a charge or a, or part of a, settlement
        Integer,
        Integer32,
        Integer64,
        Numeric,            // See DataTypeInfo.IsNumeric
        String,
        UniqueIdentifier    //This is different than a Guid
    }


    // AbstractType
    //     IntegerType
    //     

    //TypeFactory.CreateBoolean()
   
    //

}
