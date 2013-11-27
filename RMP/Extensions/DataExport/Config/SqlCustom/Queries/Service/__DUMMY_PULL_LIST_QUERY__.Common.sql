/***************************************************************
* This is a dummy query to enable the
* pull list funcationality in the data export adapters.
* Here we do nothing, but you could do whatever is relavent for your
* report if necessary. The following parameters are available for pull list
* functionality if you choose. They are only replaced if they exist:
*
*  %%PARENT_ID_RUN%%
*  %%PARENT_ID_BILLGROUP%%
*  %%CHILD_ID_RUN%%
*  %%CHILD_ID_BILLGROUP%%"
*  %%METRATIME%%
***************************************************************/
   SELECT * from t_account where 0=1