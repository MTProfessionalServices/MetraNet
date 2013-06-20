using System.Collections.Generic;
using MetraTech.ExpressionEngine.Components.Enumerations;

namespace MetraTech.ExpressionEngine.Components
{
    public interface IComponent
    {
        ComponentType ComponentType { get; }
        string Name { get; }
        string FullName { get; }
        string Description { get; set; }
        List<ComponentLink> GetComponentLinks();
        void Rename(string newName);
    }
}
