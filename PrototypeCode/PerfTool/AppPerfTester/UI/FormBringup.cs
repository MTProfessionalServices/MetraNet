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
    public partial class FormBringup : Form
    {
        public Dictionary<string, Label> labels = new Dictionary<string, Label>();
        public Dictionary<string, Label> icons = new Dictionary<string, Label>();

        public FormBringup()
        {
            InitializeComponent();
			this.Location = new Point(10, 10);
        }

        delegate void modelChangeCallback();

        public void modelChanged()
        {
            if (InvokeRequired)
            {
                modelChangeCallback cb = new modelChangeCallback(modelChanged);
                Invoke(cb);
            }
            else
            {
                foreach (IFrameworkComponent comp in FrameworkComponentFactory.Values)
                {
                    string key = comp.name;

                    Label theLabel = labels[key];
                    BringupState theState = comp.bringupState;
                    theLabel.Text = comp.fullName + ": " + theState.message;

                    switch (theState.state)
                    {
                        case BringupState.State.idle:
                            icons[key].Image = global::BaselineGUI.Properties.Resources.arrow_right_2;
                            break;
                        case BringupState.State.inProgress:
                            icons[key].Image = global::BaselineGUI.Properties.Resources.go_next;
                            break;
                        case BringupState.State.success:
                            icons[key].Image = global::BaselineGUI.Properties.Resources.dialog_ok_apply_6;
                            break;
                        case BringupState.State.failure:
                            icons[key].Image = global::BaselineGUI.Properties.Resources.dialog_block;
                            break;
                    }

                }
            }
        }


        private void FormBringup_Load(object sender, EventArgs e)
        {
            int yPos = 24;
            foreach (IFrameworkComponent comp in FrameworkComponentFactory.Values)
            {
                string key = comp.name;

                BringupState state = comp.bringupState;
                state.OnUpdateEvent = modelChanged;

                Label nIcon = new System.Windows.Forms.Label();
                nIcon.Location = new System.Drawing.Point(12, yPos-2);
                nIcon.Size = new System.Drawing.Size(22, 22);
                nIcon.Image = global::BaselineGUI.Properties.Resources.arrow_right_2;
                nIcon.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;

                Label nlabel = new System.Windows.Forms.Label();
                nlabel.Location = new System.Drawing.Point(40, yPos);
                //nlabel.Size = new System.Drawing.Size(313, 18);
                nlabel.AutoSize = true;
                nlabel.TabIndex = 0;

                labels.Add(key, nlabel);
                icons.Add(key, nIcon);
                this.Controls.Add(nlabel);
                this.Controls.Add(nIcon);
                yPos += 30;
            }

            //
            // Send argument to our worker thread
            //
            buttonNext.Enabled = false;
            backgroundWorker1.RunWorkerAsync();
        }

 
        private void buttonNext_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void backgroundWorker1_DoWork(object sender, DoWorkEventArgs e)
        {
            Framework.bringup();
        }

        private void backgroundWorker1_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            buttonNext.Enabled = true;
        }

        private void FormBringup_Layout(object sender, LayoutEventArgs e)
        {
            int rightEdge = -2000;
            foreach (Label icon in icons.Values)
            {
                rightEdge = Math.Max(rightEdge, icon.Right);
            }

            foreach (Label label in labels.Values)
            {
                label.Left = rightEdge + 6;
            }
        }

    }
}
