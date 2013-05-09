using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WizardTest.Interfaces
{
    interface IExtension
    {
        string Name { get; set; }
        string Description { get; set; }
        string Namespace { get; set; }
        string AuthorName { get; set; }
        List<string> ExistingNamespaces { get; set; }
    }
}
