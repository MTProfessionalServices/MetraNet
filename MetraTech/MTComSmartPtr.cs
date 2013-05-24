using System;
using System.Runtime.InteropServices;

namespace MetraTech
{
    /// <summary>
    /// Smart pointer wrapper class for IJW to ensure Marshal.ReleaseComObject is called
    /// </summary>
    /// <typeparam name="T">This is the interface type of the COM class that will be held by the smart pointer</typeparam>
    [ComVisible(false)]
    public sealed class MTComSmartPtr<T> : IDisposable where T : class
    {
        #region Private members
        private T m_Item = null;
        #endregion

        #region Constructor and Finalizer
        public MTComSmartPtr()
        {
        }

        ~MTComSmartPtr()
        {
            Dispose();
        }
        #endregion

        #region Public Methods and Properties
        public T Item
        {
            get { return m_Item; }
            set { m_Item = value; }
        }

        public T Detach()
        {
            T temp = m_Item;
            m_Item = null;

            return temp;
        }
        #endregion

        #region IDisposable Members

        public void Dispose()
        {
            if (m_Item != null)
            {
                Marshal.ReleaseComObject(m_Item);
            }

            GC.SuppressFinalize(this);
        }

        #endregion
    }

}