To upgrade the 5.1.1 database to 6.0.1
1) Run DBUpgradeExec tool using Setup\NetMeter scripts folder as NetMeter schema owner.
2) Run the hooks from ICE 
     Synnchronize Localization
     Database
     Product Catalog and 
     Usage
3) Run DBUpgradeExec tool using Setup\MetraPay scripts folder as MeraPay schema owner.
4) Run CCHashGenerator tool to generate tx_hash values for t_payment_instrument
5) Run DBUpgradeExec tool using Cleanup\NetMeter scripts folder as NetMeter schema owner
6) Drop all tables in the staging database.
7) Run UpgradeEncryption tool. Make sure you used the same secret (e.g. "mtkey") as 
   in 5.1.1. Need publickeyblob_pipeline sessionkeyblob_pipeline in the R:\config\ServerAccess\
   This files can be copied them from previous installation if not created by the install.

  Please backup your database before running the script.
  Do not run scripts as system user, but run them as an owner of appropirate schema
  UpgradeEncryption, DBUpgradeExec and CCHashGenerator tool should be in the bin folder as part of 6.0.1 installation.
  DBUpgradeExec replaces %%NETMETER%% and %%METRAPAY%% tags with database names for NetMeter and MetraPay
  CCHashGenerator tool populates the tx_hash field in the %%NETMETER%%..T_PAYMENT_INSTRUMENT.TX_HASH
  UpgradeEncryption tool will
    Upgrading password hash from 5.1.1 MD5 hash to new HMX 256 hash
    Decrypting credit cards encrypted with 5.1.1 standard Triple DES encryption
      and Encrypting them using new AES 256 encryption using Metratech.Security.Crypto
    Find all tables with encrypted fields 
      (T_AV, P_PV and T_SVC tables, where there are fields ending with underscore)
      and decrypt and re-encrypt data there.
   