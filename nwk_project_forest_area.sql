drop table if exists project_forest_area;

create table project_forest_area as select "CLASSNAME", geom from nwk_evt_att where "EVT_PHYS" = 'Conifer';
comment on table project_forest_area is 'All LandFIRE EVT pixels where Phys = Conifer';

-- drop table if exists project_forest;

-- --create table project_forest  as with forest as (select st_union(wkb_geometry) geom from sel_ccover where dn >=15), prop as (select gid, parcel_id, usage, (st_dump(geom)).geom from project_area) select gid, o.parcel_id, o.usage, st_setsrid((st_dump(st_intersection(o.geom,f.geom))).geom,3338) geom from prop o, forest f;

-- drop table if exists cc_disolve;

-- create table cc_disolve as SELECT ST_Union(st_makevalid(wkb_geometry))  geom FROM sel_ccover;

-- alter table cc_disolve add column gid serial primary key;

-- create table project_forest as select st_intersection(c.geom, b.geom) from cc_disolve c, sel_boundary b;

