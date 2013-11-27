
CREATE TABLE t_recevent_dep
(
  id_event INT NOT NULL,			-- Foreign key to t_recevent
  id_dependent_on_event	INT	NULL,	  -- The run that this run is dependent on. NULL if there are no dependencies.
  n_distance INT NOT NULL,    -- The distance between an event and a dependency (0 is identity)
  CONSTRAINT FK_t_recevent_dep FOREIGN KEY (id_event) REFERENCES t_recevent (id_event)
)
			 