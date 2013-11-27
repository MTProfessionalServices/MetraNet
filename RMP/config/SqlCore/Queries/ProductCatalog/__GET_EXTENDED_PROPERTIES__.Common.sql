
        select t_base_props.id_prop %%EXTENDED_SELECT%%
        from
        %%EXTENDED_JOIN%%
        where t_base_props.id_prop = %%ID_PROP%%
      