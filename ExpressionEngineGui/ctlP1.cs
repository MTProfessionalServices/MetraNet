using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.PropertyBags;

namespace PropertyGui
{
    public partial class ctlP1 : UserControl
    {
        public ctlP1()
        {
            InitializeComponent();
        }

        public void Init(Context context, PropertyBag propertyBag)
        {
            ctlExpressionTree1.Init(context, null);
            ctlExpressionTree1.AddProperties(null, propertyBag.Properties, null);
        }
    }
}
