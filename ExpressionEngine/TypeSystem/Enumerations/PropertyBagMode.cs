namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
{
    /// <summary>
    /// Indicates how the ProeprtyBag is manifested
    /// </summary>
    public enum PropertyBagMode
    {
        /// <summary>
        /// ComplexType in Metanga. I has no 1:1 instance mapping an therefore has no ID. No
        /// There is no equalivent in MetraNet yet.
        //  This is the least powerful option, so ensure that is is always first in the enum list
        /// </summary>
        PropertyBag,  
        
        /// <summary>
        /// Has an ID (i.e., is saved directly to database), but is not extensible
        /// </summary>
        Entity,             

        /// <summary>
        /// Has an ID (i.e., is saved directly to database) and is extensible. In MetraNet this includes, AccountViews, ProductViews and ServiceDefinitons
        /// </summary>
        ExtensibleEntity
    }
}
