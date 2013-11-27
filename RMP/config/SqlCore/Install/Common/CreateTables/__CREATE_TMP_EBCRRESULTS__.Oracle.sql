
        create global temporary table ebcrresults
        (
          id_acc number(10), /* member account (payee) */
          id_usage_cycle number(10), /* payer's cycle */
          b_compatible number(10) /* ebcr compatibility: 1 or 0 */
        ) on commit preserve rows
        