using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.MTProperty
{
    public static class PropertyFactory
    {
        public static Property Create(ComplexType complexType, string name, Type type, bool isRequired, string description)
        {
            switch (complexType)
            {
                case ComplexType.AccountView:
                    return new AccountViewProperty(name, type, isRequired, description);
                case ComplexType.ProductView:
                    return new ProductViewProperty(name, type, isRequired, description);
                case ComplexType.ServiceDefinition:
                    return new ServiceDefinitionProperty(name, type, isRequired, description);
                default:
                    return new Property(name, type, isRequired, description);
            }
        }
    }
}
