using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.Validations;

namespace PropertyGui
{
    public partial class frmValidationMessages : Form
    {
        public frmValidationMessages(ValidationMessageCollection messages)
        {
            InitializeComponent();
            txtMessages.Text = messages.GetSummary();
        }
    }
}
