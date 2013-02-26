namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
{
    public enum PropertyBagMode
    {
        /// <summary>
        /// ComplexType in Metanga. It has no ID. No Equalivent in MetraNet yet
        // Ensure that "least powerful" is first so that default is least powerful
        /// </summary>
        Value,  
        
        /// <summary>
        /// Has an ID, but is not extensible
        /// </summary>
        Entity,             

        /// <summary>
        /// Has an ID an is extensible
        /// </summary>
        ExtensibleEntity
    }
}
