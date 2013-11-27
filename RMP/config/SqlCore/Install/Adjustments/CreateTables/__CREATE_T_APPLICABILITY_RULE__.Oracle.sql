
          create table t_applicability_rule (
          id_prop number(10)  not null primary key,
          tx_guid RAW(16) null,
          id_formula number(10) NOT NULL
          )
        