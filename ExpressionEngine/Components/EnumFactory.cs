namespace MetraTech.ExpressionEngine.Components
{
    public static class EnumFactory
    {
        public static EnumCategory CreateCategory(EnumNamespace parent, bool isUnitOfMeasure, string name, int id, string description)
        {
            if (isUnitOfMeasure)
                return new UnitOfMeasureCategory(parent, name, id, description);
            return new EnumCategory(parent, name, id, description);
        }
    }
}
