using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.PropertyBags;

namespace PropertyGui
{
    public partial class Form1 : Form
    {
        public Form1(Context context, PropertyBag propertyBag)
        {
            InitializeComponent();

            ctlP11.Init(context, propertyBag);
        }
    }
}
