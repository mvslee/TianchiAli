-- Table: public.t_artists

-- DROP TABLE public.t_artists;

CREATE TABLE public.t_artists
(
  songid character(32) NOT NULL,
  artistid character(32) NOT NULL,
  publishtime character(8),
  initplay character(10),
  language character(3),
  gender character(1)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.t_artists
  OWNER TO postgres;
