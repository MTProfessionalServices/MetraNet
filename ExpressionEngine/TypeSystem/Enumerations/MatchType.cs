namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
{
    /// <summary>
    /// The level to which two DataTypeInfos match. Note that order is important
    /// because the higher number indicates a better match
    /// </summary>
    public enum MatchType
    {
        None = 0,                 //For example, String and Integer32
        BaseTypeWithDiff = 1,     //The BaseTypes match but there is some difference (i.e., two enums with differnt enumtypes)
        Convertible = 2,          //The base types are compatiable, but a UoM or Curency conversion must be performed. Only applies to numerics. 
        ImplicitCast = 3,         //The start type can be implicitly cast to the end type. Only applies to numerics (i.e., Integer32 can be implicitly cast to Integer64 but the coversion isn't true)
        Any = 4,            //Note that Any only works one way
        Exact = 5           // Integer32 and Integer32 or two enums with the same enumspace and enumtype 
    }
}
