using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace BaselineGUI
{
    public class TSLabel
    {
        Form form;
        Label label;

        public TSLabel(Form form, Label label)
        {
            this.form = form;
            this.label = label;
        }

        delegate void callback(string text);
        public void SetLabel(string text)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (label.InvokeRequired)
            {
                callback cb = new callback(SetLabel);
                form.Invoke(cb, new object[] { text });
            }
            else
            {
                label.Text = text;
            }
        }
    }

}
