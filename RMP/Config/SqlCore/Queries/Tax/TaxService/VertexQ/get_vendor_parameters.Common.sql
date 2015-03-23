SELECT tx_canonical_name,
	   tx_type,
	   tx_default,
	   tx_direction
FROM t_tax_vendor_params where id_vendor = %%VENDOR_ID%% 
%%ORDER_BY%%
