-- NOTE!;
-- THE FILE IS TOKENIZED WITH SEMICOLON CHARACTER!;
-- EACH COMMENT _NEED_ TO END WITH A SEMICOLON OR OTHERWISE THE NEXT ACTUAL SQL IS NOT RUN!;
-- ----------------------------------------------------------------------------------------;

DROP TABLE portti_maplayer IF EXISTS;
DROP TABLE portti_layerclass IF EXISTS;
DROP TABLE oskari_maplayer_themes IF EXISTS;
DROP TABLE portti_inspiretheme IF EXISTS;
DROP TABLE oskari_maplayer IF EXISTS;
DROP TABLE oskari_layergroup IF EXISTS;


DROP TABLE oskari_resource IF EXISTS;
DROP TABLE oskari_permission IF EXISTS;

DROP TABLE portti_maplayer_metadata IF EXISTS;
DROP TABLE portti_capabilities_cache IF EXISTS;

DROP VIEW portti_backendalert IF EXISTS;
DROP VIEW portti_backendstatus_allknown IF EXISTS;
DROP TABLE portti_backendstatus IF EXISTS;

DROP TABLE portti_view_bundle_seq IF EXISTS;
DROP TABLE portti_bundle IF EXISTS;
DROP TABLE portti_view IF EXISTS;
DROP TABLE portti_view_supplement IF EXISTS;

DROP TABLE portti_published_map_usage IF EXISTS;
DROP TABLE portti_published_map_statistics IF EXISTS;

CREATE TABLE portti_capabilities_cache
(
  layer_id IDENTITY,
  data character varying(20000),
  updated timestamp DEFAULT CURRENT_TIMESTAMP,
  "WMSversion" character(10) NOT NULL,
  CONSTRAINT portti_capabilities_cache_pkey PRIMARY KEY (layer_id)
);

CREATE TABLE portti_inspiretheme (
  id int GENERATED BY DEFAULT AS IDENTITY (START WITH 1),
  locale character varying(20000),
  CONSTRAINT portti_inspiretheme_pkey PRIMARY KEY (id)
);


CREATE TABLE oskari_layergroup
(
  id int GENERATED BY DEFAULT AS IDENTITY (START WITH 1),
  locale  character varying(20000) DEFAULT '{}',
  CONSTRAINT oskari_layergroup_pkey PRIMARY KEY (id)
);

CREATE TABLE oskari_maplayer
(
  id int GENERATED BY DEFAULT AS IDENTITY (START WITH 1),
  parentId integer DEFAULT -1 NOT NULL,
  externalId character varying(50),
  type character varying(50) NOT NULL,
  base_map boolean DEFAULT false NOT NULL,
  groupId integer,
  name character varying(2000),
  url character varying(2000),
  locale character varying(20000) DEFAULT '{}',
  opacity integer,
  style character varying(100),
  minscale double precision DEFAULT -1 ,
  maxscale double precision DEFAULT -1 ,
  legend_image character varying(2000),
  metadataId character varying(200),
  tile_matrix_set_id character varying(200),
  tile_matrix_set_data character varying(20000),
  params character varying(20000) DEFAULT '{}',
  options character varying(20000) DEFAULT '{}',
  gfi_type character varying(200),
  gfi_xslt character varying(20000),
  realtime boolean DEFAULT false,
  refresh_rate integer DEFAULT 0,
  created timestamp DEFAULT CURRENT_TIMESTAMP,
  updated timestamp DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT oskari_maplayer_pkey PRIMARY KEY (id),
  CONSTRAINT oskari_maplayer_groupId_fkey FOREIGN KEY (groupId)
  REFERENCES oskari_layergroup (id)
    ON UPDATE NO ACTION ON DELETE CASCADE
);

CREATE TABLE oskari_maplayer_themes
(
  maplayerid integer NOT NULL,
  themeid integer NOT NULL,
  CONSTRAINT oskari_maplayer_id_fkey FOREIGN KEY (maplayerid)
  REFERENCES oskari_maplayer (id)
    ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT portti_inspiretheme_id_fkey FOREIGN KEY (themeid)
  REFERENCES portti_inspiretheme (id)
    ON UPDATE NO ACTION ON DELETE CASCADE
);

CREATE TABLE oskari_resource
(
  id int GENERATED BY DEFAULT AS IDENTITY (START WITH 1),
  resource_type character varying(100) NOT NULL,
  resource_mapping character varying(1000) NOT NULL,
  CONSTRAINT type_mapping UNIQUE (resource_type, resource_mapping)
);

CREATE TABLE oskari_permission
(
  id int GENERATED BY DEFAULT AS IDENTITY (START WITH 1),
  oskari_resource_id bigint NOT NULL,
  external_type character varying(100),
  permission character varying(100),
  external_id character varying(1000)
);

CREATE TABLE portti_maplayer_metadata
(
  id IDENTITY NOT NULL,
  maplayerid integer,
  uuid character varying(256),
  namefi character varying(512),
  namesv character varying(512),
  nameen character varying(512),
  abstractfi character varying(1024),
  abstractsv character varying(1024),
  abstracten character varying(1024),
  browsegraphic character varying(1024),
  geom character varying(512) default '',
  CONSTRAINT portti_maplayer_metadata_pkey PRIMARY KEY (id)
);


CREATE TABLE portti_backendstatus
(
  id IDENTITY,
  ts timestamp DEFAULT CURRENT_TIMESTAMP,
  maplayer_id character varying(50),
  status character varying(500),
  statusmessage character varying(2000),
  infourl character varying(2000),
  statusjson character varying(20000),
  CONSTRAINT portti_backendstatus_pkey PRIMARY KEY (id)
);

CREATE VIEW portti_backendalert as SELECT id,ts,maplayer_id,status,statusmessage,infourl,statusjson FROM portti_backendstatus WHERE NOT status is null AND NOT status = 'UNKNOWN' AND NOT status = 'OK';

CREATE VIEW portti_backendstatus_allknown AS
  SELECT portti_backendstatus.id, portti_backendstatus.ts, portti_backendstatus.maplayer_id, portti_backendstatus.status, portti_backendstatus.statusmessage, portti_backendstatus.infourl, portti_backendstatus.statusjson
  FROM portti_backendstatus;



CREATE TABLE portti_view_supplement (
   id               IDENTITY	  PRIMARY KEY,
   creator          BIGINT        DEFAULT -1,
   pubdomain        VARCHAR(512)  DEFAULT '',
   lang             VARCHAR(2)    DEFAULT 'en',
   width            INTEGER       DEFAULT 0,
   height           INTEGER       DEFAULT 0,
   is_public        BOOLEAN       DEFAULT FALSE,
   old_id	    BIGINT	  DEFAULT -1
);

CREATE TABLE portti_view (
   uuid             VARCHAR(128),
   id               int GENERATED BY DEFAULT AS IDENTITY (START WITH 1),
   name             VARCHAR(128)  NOT NULL,
   supplement_id    BIGINT        ,
   is_default       BOOLEAN       DEFAULT FALSE,
   type		    varchar(16)	  DEFAULT 'USER',
   description   VARCHAR(2000) ,
   page character varying(128) DEFAULT 'index',
   application character varying(128) DEFAULT 'servlet',
   application_dev_prefix character varying(256) DEFAULT '/applications/sample'
);

CREATE TABLE portti_bundle (
   id    	    IDENTITY	  PRIMARY KEY,
   name 	    VARCHAR(128)  NOT NULL,
   config 	    character varying(20000) DEFAULT '{}',
   state 	    character varying(20000) DEFAULT '{}',
   startup 	    character varying(20000) 	  NOT NULL
);

CREATE TABLE portti_view_bundle_seq (
   view_id 	    BIGINT	  NOT NULL,
   bundle_id 	    BIGINT 	   NOT NULL,
   seqno 	    INTEGER 	  NOT NULL,
   config 	    character varying(20000) DEFAULT '{}',
   state 	    character varying(20000) DEFAULT '{}',
   startup 	    character varying(20000),
   bundleinstance character varying(128) DEFAULT '',
   CONSTRAINT 	    view_seq	  UNIQUE (view_id, seqno)
);


CREATE TABLE portti_published_map_usage
(
  id int GENERATED BY DEFAULT AS IDENTITY (START WITH 1),
  published_map_id bigint NOT NULL,
  usage_count bigint NOT NULL,
  force_lock boolean DEFAULT false,
  CONSTRAINT portti_published_map_usage_pkey PRIMARY KEY (id)
);

CREATE TABLE portti_published_map_statistics
(
  id int GENERATED BY DEFAULT AS IDENTITY (START WITH 1),
  published_map_id bigint NOT NULL,
  count_total_lifecycle bigint NOT NULL,
  CONSTRAINT portti_published_map_statistics_pkey PRIMARY KEY (id)
);