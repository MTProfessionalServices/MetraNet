namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
{
    /// <summary>
    /// Specifies the base type
    /// </summary>
    public enum BaseType
    {
        /// <summary>
        // The base type is not known. Very useful so that we don't need to do nullable type casting (i.e., BaseType?) 
        // We want this to be FIRST so that this is the default! (note DataTypeInfo does this in the constructor)
        /// </summary>
        Unknown,

        /// <summary>
        /// Used to match any other BaseType (like object in C#)
        /// </summary>
        Any,      
          
        Binary,
        Boolean,

        /// <summary>
        /// A money type with units and other attributes
        /// </summary>
        Charge,    
        
        DateTime,
        Decimal,
        Double,

        /// <summary>
        /// A "bag" of properties. See PropertyBagMode for all of the subtypes
        /// </summary>
        PropertyBag,        
        
        /// <summary>
        /// An enumeration (has a Namespace and a Category) 
        /// </summary>
        Enumeration,

        /// <summary>
        /// A floating point number
        /// </summary>
        Float,

        /// <summary>
        /// A 128-bit integer (16 bytes) that can be used across all computers and networks 
        /// when a unique identifier is required with a very low probability of being duplicated.
        /// </summary>
        Guid,

        /// <summary>
        /// The platform's default integer type
        /// </summary>
        Integer,

        /// <summary>
        /// A 32-bit integer
        /// </summary>
        Integer32,

        /// <summary>
        /// A 64-bit integer
        /// </summary>
        Integer64,

        /// <summary>
        /// A decimal number that's associated with a currency
        /// NEED to figure out if Charge is subclass of this
        /// </summary>
        Money,              

        /// <summary>
        /// A number value. This spans mulitple other BaseTypes. See Type.IsNumeric for full list
        /// </summary>
        Numeric,          

        /// <summary>
        /// A text field with an optional length
        /// </summary>
        String,

        /// <summary>
        /// A Unique Identifier that is differnt than a GUID. Ask CDE team for more information.
        /// </summary>
        UniqueIdentifier   
    }
}
