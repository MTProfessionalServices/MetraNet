namespace MetraTech.ExpressionEngine.TypeSystem.Enumerations
{
    public enum PropertyBagMode
    {
        Value,              //Complex types in Metanga (no id)
        Entity,             //Has an Id, but not extensible
        ExtensibleEntity    //Has an Id, but is extensible
    }
}
