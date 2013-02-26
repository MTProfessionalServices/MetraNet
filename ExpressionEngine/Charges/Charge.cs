using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.Charges
{
    public class Charge// : Property
    {
        #region Properties

        /// <summary>
        /// The name of the property that specifes the quantity to calcualte the 
        /// charge.  Optional??? Mario thinks required. Ask Jonah for pipeline replacement
        /// </summary>
        public string QuantityProperty { get; set; }

        /// <summary>
        /// The property that contains monetary value. 
        /// Must be set!
        /// </summary>
        public MoneyType MoneyProperty { get; set; }
        #endregion

        #region Constructor
        //public Charge():base(UriHostNameType,)
        #endregion
    }
}
