using System.Collections.Generic;
using MetraTech.ExpressionEngine.Components.Enumerations;

namespace MetraTech.ExpressionEngine.Components
{
    interface IComponent
    {
        ComponentType ComponentType { get; }
        string FullName { get; }
        string UserContext { get; }
        ComponentReference GetComponentReference();
        List<ComponentLink> GetComponentLinks();
    }
}
