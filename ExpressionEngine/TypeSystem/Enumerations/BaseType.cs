namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
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
        Charge,             //Decimal with Currency that is a, or part of a, charge or a settlement  ((PropertyAttribute))
        DateTime,
        Decimal,
        Double,
        Entity,             //Spans everying from BMEs to ProductViews
        Enumeration,
        Float,
        Guid,
        Integer,
        Integer32,
        Integer64,
        Money,              //Decimal with currency that is NOT a charge or a, or part of a, settlement
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
