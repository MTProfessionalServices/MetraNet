using System.Runtime.InteropServices;


namespace MetraTech.Tax.Framework.Hooks
{
    /// <summary>
    /// VendorParamsHook is responsible for synchronizing database table t_vendor_params with 
    /// XML configuration file RMP\config\Tax\vendor_params.xml
    /// </summary>
    [Guid("95751375-f745-4178-89a4-126b3ff676e9")]
    public interface IVendorParamsHook : Interop.MTHooklib.IMTHook
    {
    }

    [Guid("54c75f94-e3bd-48e2-83ec-d4ee00ff48f6")]
    [ClassInterface(ClassInterfaceType.None)]
    public class VendorParamsHook : IVendorParamsHook
    {
        /// <summary>
        /// Constructor.
        /// </summary>
        public VendorParamsHook()
        {
            mLogger = new Logger("[VendorParamsHook]");
        }

        /// <summary>
        /// Synchronizes database table t_vendor_params with 
        /// XML configuration file RMP\config\Tax\vendor_params.xml
        /// </summary>
        /// <param name="var"></param>
        /// <param name="pVal"></param>
        public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
        {
            try
            {
                VendorParamsManager mgr = new VendorParamsManager();
                Interop.RCD.IMTRcd rcd = new Interop.RCD.MTRcd();
                string configFile = string.Format(@"{0}\Tax\vendor_params.xml", rcd.ConfigDir);
                mgr.SynchronizeConfigFile(configFile);
                mLogger.LogDebug("VendorParamsHook finished");
            }
            catch (System.Exception e)
            {
                mLogger.LogException("VendorParamsHook failed with the exception: ", e);
                throw;
            }
            finally
            {
                System.Threading.Thread.Sleep(1000); // sleep so that log messages were written to the mtlog.
            }
        }

        #region Data
        private readonly Logger mLogger;
        #endregion
    }
}
