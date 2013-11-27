using System.Windows.Forms;


namespace BaselineGUI
{




    public class LiveStatus
    {
        Form form;
        TextBox textBox;
        Label label;

        public LiveStatus(Form form, TextBox textBox, Label label)
        {
            this.form = form;
            this.textBox = textBox;
            this.label = label;
        }

        delegate void SetLabelCallback(string text);
        public void SetLabel(string text)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (label.InvokeRequired)
            {
                SetLabelCallback d = new SetLabelCallback(SetLabel);
                form.Invoke(d, new object[] { text });
            }
            else
            {
                label.Text = text;
            }
        }

        delegate void AppendTextBoxCallback(string text);
        public void AppendTextBox(string text)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (textBox.InvokeRequired)
            {
                AppendTextBoxCallback d = new AppendTextBoxCallback(AppendTextBox);
                form.Invoke(d, new object[] { text });
            }
            else
            {
                textBox.AppendText( text);
                textBox.AppendText(System.Environment.NewLine);
            }
        }
    }
}
