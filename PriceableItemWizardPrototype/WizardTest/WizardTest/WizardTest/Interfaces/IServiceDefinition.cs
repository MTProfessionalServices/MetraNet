using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WizardTest.Interfaces
{
    interface IServiceDefinition
    {
        string Name { get; set; }
        string Description { get; set; }
        string Configuration { get; set; }
        string TableName { get; set; }

    }
}
