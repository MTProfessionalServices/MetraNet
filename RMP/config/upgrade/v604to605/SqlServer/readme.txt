To upgrade the 6.0.4 database to 6.0.5
1) Run DBUpgradeExec tool using Setup\NetMeter scripts folder


Note: 
  Please backup your database before running the script.
  Run these files as nmdbo or sa user.
  DBUpgradeExec and CCHashGenerator tool should be in the bin folder as part of 6.0.5 installation.
  DBUpgradeExec replaces %%NETMETER%% and %%METRAPAY%% tags with database names for NetMeter and MetraPay

Note: this upgrade script is generated on 4-23-09, prior to final release.