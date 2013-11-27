
      UPDATE t_billing_server_settings
      SET multicast_address='%%MULTICAST_ADDRESS%%',
          multicast_port = %%MULTICAST_PORT%%,
          multicast_time_to_live =%%MULTICAST_TIME_TO_LIVE%% 
      