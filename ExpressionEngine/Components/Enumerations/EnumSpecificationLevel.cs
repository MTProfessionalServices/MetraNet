namespace MetraTech.ExpressionEngine.Components.Enumerations
{
    public enum EnumSpecificationLevel
    {
        /// <summary>
        /// Only the category is specified
        /// </summary>
        Category,

        /// <summary>
        /// The actual item is specified which depending on the EnumMode may be an Item, a UnitOfMeasure or
        /// a Currency. An item obviously includes its category.
        /// </summary>
        Item
    }
}
