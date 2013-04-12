using System.Collections.Generic;
using MetraTech.ExpressionEngine.Components.Enumerations;

namespace MetraTech.ExpressionEngine.Components
{
    interface IComponent
    {
        ComponentType ComponentType { get; }
        string FullName { get; }
        //string UserContext { get; }
        string Description { get; set; }
        ComponentReference GetComponentReference();
        List<ComponentLink> GetComponentLinks();
        void Reanme(string newName);
    }
}
