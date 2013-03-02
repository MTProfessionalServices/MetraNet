namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
{
    /// <summary>
    /// The level to which two DataTypeInfos match. Note that order is important
    /// because the higher number indicates a better match
    /// </summary>
    public enum MatchType
    {
        /// <summary>
        /// No match. For example, String and Integer32
        /// </summary>
        None = 0,                 

        /// <summary>
        /// The BaseTypes match but there is some difference (i.e., two enums with different enum categories)
        /// </summary>
        BaseTypeWithDiff = 1, 
    
        /// <summary>
        /// The base types are compatiable, but a UoM or Curency conversion must be performed. Only applies to numerics. 
        /// </summary>
        Convertible = 2,

        /// <summary>
        /// The start type can be implicitly cast to the end type. Only applies to numerics (i.e., Integer32 can be implicitly cast to Integer64 but the coversion isn't true)
        /// </summary>
        ImplicitCast = 3,         

        /// <summary>
        /// The start type is Any, so everything matches. Only works one direction.
        /// </summary>
        Any = 4,          

        /// <summary>
        /// There is an exact match. For example, Integer32 and Integer32 or two enums with the same namespace and category 
        /// </summary>
        Exact = 5           // 
    }
}
