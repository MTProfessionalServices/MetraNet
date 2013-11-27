using System.Windows.Forms;

namespace BaselineGUI
{
    /// <summary>
    /// A Thread-Safe TextBox accessor
    /// </summary>
    public class TSTextBox
    {
        Form form;
        TextBox textBox;

        public TSTextBox(Form form, TextBox textBox)
        {
            this.form = form;
            this.textBox = textBox;
        }

        delegate void callback(string text);
        public void AppendText(string text)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (textBox.InvokeRequired)
            {
                callback d = new callback(AppendText);
                form.Invoke(d, new object[] { text });
            }
            else
            {
                textBox.AppendText(text);
            }
        }
    }

}
