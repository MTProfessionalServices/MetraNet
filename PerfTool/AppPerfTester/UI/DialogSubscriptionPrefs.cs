using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;
using System.Threading;
using System.IO;
using log4net;
using System.Windows.Forms.DataVisualization.Charting;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;

namespace BaselineGUI
{
    public class DialogSubscriptionPrefs : Form
    {
        public class LayoutParams
        {
            public int x_label = 0;
            public int x_staticUse = 60;
            public int x_mutableUse = 80;
        }

        public class CtlPO : Control
        {
            public ProductOffering po;
            public Label label;
            public CheckBox staticUse;
            public CheckBox mutableUse;

            public LayoutParams lp;

            public CtlPO(ProductOffering po, LayoutParams lp)
            {
                this.po = po;
                this.lp = lp;

                label = new Label();
                label.AutoSize = true;
                label.Text = po.DisplayName;
                label.PerformLayout();
                this.Controls.Add(label);

                staticUse = new CheckBox();
                staticUse.AutoSize = true;
                staticUse.PerformLayout();
                this.Controls.Add(staticUse);

                mutableUse = new CheckBox();
                mutableUse.AutoSize = true;
                mutableUse.PerformLayout();
                this.Controls.Add(mutableUse);

                //staticUse.CheckedChanged += this.checkBoxChanged;
                //mutableUse.CheckedChanged += this.checkBoxChanged;
                this.Layout += this.doLayout;

                pushModelToControl();

                this.ResumeLayout();
                this.PerformLayout();
            }

            public void doLayout(object sender, LayoutEventArgs e)
            {
                int x = 0;
                int y = 0;

                label.Location = new Point(lp.x_label, y);
                staticUse.Location = new Point(lp.x_staticUse, y);
                mutableUse.Location = new Point(lp.x_mutableUse, y);

                x = 0;
                y = 0;
                foreach (Control ctl in this.Controls)
                {
                    x = Math.Max(x, ctl.Right);
                    y = Math.Max(y, ctl.Bottom);
                }

                this.Size = new Size(x, y);
            }

            public void pushModelToControl()
            {
                ProductOfferPreferences pref = PrefRepo.active.findPoPreferences(po.Name);
                staticUse.Checked = pref.staticEnabled;
                mutableUse.Checked = pref.mutableEnabled;
            }

            public void pushControlToModel()
            {

                ProductOfferPreferences pref = PrefRepo.active.findPoPreferences(po.Name);
                pref.staticEnabled = staticUse.Checked;
                pref.mutableEnabled = mutableUse.Checked;
            }

            public void checkBoxChanged(object sender, EventArgs e)
            {
                pushControlToModel();
            }

        }


        List<CtlPO> poLabelList = new List<CtlPO>();
        LayoutParams lp = new LayoutParams();
        Label staticLabel;
        Label mutableLabel;
        Button buttonOkay;
        Button buttonCancel;

        public DialogSubscriptionPrefs()
        {
            FCProductOffers fcProductOffers = FrameworkComponentFactory.find<FCProductOffers>();

            this.Text = "Product Offers";
            this.AutoScroll = true;

            staticLabel = new Label();
            staticLabel.AutoSize = true;
            staticLabel.Text = "Bulk Add";
            staticLabel.PerformLayout();
            this.Controls.Add(staticLabel);

            mutableLabel = new Label();
            mutableLabel.AutoSize = true;
            mutableLabel.Text = "Modifiable";
            mutableLabel.PerformLayout();
            this.Controls.Add(mutableLabel);

            foreach (ProductOffering po in fcProductOffers.productOfferings)
            {
                CtlPO ctl = new CtlPO(po, lp);

                ctl.PerformLayout();
                poLabelList.Add(ctl);
                this.Controls.Add(ctl);
            }

            buttonOkay = new Button();
            buttonOkay.Text = "Accept";
            buttonOkay.DialogResult = DialogResult.OK;
            this.Controls.Add(buttonOkay);

            buttonCancel = new Button();
            buttonCancel.Text = "Cancel";
            buttonCancel.DialogResult = DialogResult.Cancel;
            this.Controls.Add(buttonCancel);

            this.AcceptButton = buttonOkay;
            this.CancelButton = buttonCancel;

            this.Layout += new LayoutEventHandler(this.doLayout);
            this.ResumeLayout();
            this.PerformLayout();
        }


        public void doLayout(object sender, LayoutEventArgs e)
        {
            int x, y;
            x = 8;
            y = 8;

            staticLabel.Location = new Point(x, y);

            int ux = 0;
            foreach (var ctl in poLabelList)
            {
                ux = Math.Max(ux, ctl.label.Right);
            }
            lp.x_staticUse = ux + 8;
            lp.x_mutableUse = lp.x_staticUse + 70;


            staticLabel.Location = new Point(lp.x_staticUse, y);
            mutableLabel.Location = new Point(lp.x_mutableUse, y);

            y = staticLabel.Bottom + 8;

            foreach (var ctl in poLabelList)
            {
                ctl.PerformLayout();
                ctl.Location = new Point(x, y);
                y = ctl.Bottom + 8;
            }

            buttonOkay.Location = new Point(x, y);
            buttonCancel.Location = new Point(buttonOkay.Right+10, y);
        }


        public void pushModelToControl()
        {
            foreach (CtlPO ctl in poLabelList)
            {
                ctl.pushModelToControl();
            }
        }

        public void pushControlToModel()
        {
            foreach (CtlPO ctl in poLabelList)
            {
                ctl.pushControlToModel();
            }
        }

    }
}
