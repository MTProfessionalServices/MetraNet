using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.Test
{
    /// <summary>
    /// This is test for an expression which is configured and run by the end-user.
    /// </summary>
    [DataContract]
    public class Test
    {
        #region Properties
        public string Name { get; set; }
        public PropertyCollection Properties { get; private set; }
        public string Description { get; set; }

        #endregion

        #region Constructor 
        public Test()
        {
            Properties = new PropertyCollection(this);
        }
        #endregion
    }
}
