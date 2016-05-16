-- Table: public.t_users

-- DROP TABLE public.t_users;

CREATE TABLE public.t_users
(
  userid character(32) NOT NULL,
  songid character(32) NOT NULL,
  gmt character(10) NOT NULL,
  actiontype character(1) NOT NULL,
  ds character(8) NOT NULL
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.t_users
  OWNER TO postgres;
