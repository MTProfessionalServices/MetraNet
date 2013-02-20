using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;

namespace PropertyGui
{
    public partial class frmTest : Form
    {
        #region Properties
        private Context Context;
        #endregion

        #region Constructor
        public frmTest()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(Context context)
        {
            Context = context;
            var results = Context.GetExpressionParseResults();
            foreach (var parameter in results.Parameters)
            {
                lstInputs.Items.Add(parameter.Name);
            }    
        }
        #endregion
    }
}
