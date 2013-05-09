using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace BaselineGUI
{
    public partial class DialogRuntime : Form
    {
        public DialogRuntime()
        {
            InitializeComponent();

            this.pushModelToControl();
            this.CancelButton = buttonCancel;
            this.AcceptButton = buttonOkay;
        }

        public void pushModelToControl()
        {
            textBoxPasses.Text = PrefRepo.active.runLmt.numPasses;
            textBoxMaxTime.Text = PrefRepo.active.runLmt.maxRunTime;
        }

        public void pushControlToModel()
        {
            PrefRepo.active.runLmt.numPasses = textBoxPasses.Text;
            PrefRepo.active.runLmt.maxRunTime = textBoxMaxTime.Text;
        }
    }
}
