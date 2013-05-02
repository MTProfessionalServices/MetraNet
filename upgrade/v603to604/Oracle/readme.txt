To upgrade the 6.0.3 database to 6.0.4
1) Run DBUpgradeExec tool using Setup\NetMeter scripts folder as NetMeter schema owner.

Note:
  Please backup your database before running the script.
  Do not run scripts as system user, but run them as an owner of appropirate schema
  DBUpgradeExec replaces %%NETMETER%% and %%METRAPAY%% tags with database names for NetMeter and MetraPay
