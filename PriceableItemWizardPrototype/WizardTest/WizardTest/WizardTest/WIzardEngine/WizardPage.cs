using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WizardTest.WIzardEngine
{
    public partial class WizardPage : UserControl
    {

        public string PageCaption { get; protected set; }

      
        public WizardPage()
        {
            InitializeComponent();
        }

        public WizardPage(string pageCaption)
        {
            this.PageCaption = pageCaption;
        }

        public bool Cancel()
        {
            return CancelInernal();
        }

        public bool Next(bool isFinish)
        {
            return NextInernal(isFinish);
        }

        public bool Back()
        {
            return BackInernal();
        }

        public virtual void Save()
        {
          
        }

        public virtual void Init()
        {
          
        }

        public new virtual bool Validate()
        {
          return true;
        }

        protected virtual void InitInternal() { }
        protected virtual bool CancelInernal() { return true; }
        protected virtual bool NextInernal(bool isFinish) { return true; }
        protected virtual bool BackInernal() { return true; }   

    }
}
