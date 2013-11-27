
                  SELECT id_payment_instrument from t_payment_instrument with(updlock) where id_payment_instrument = ?
        