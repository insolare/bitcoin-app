--  This file is part of the eliona project.
--  Copyright © 2022 LEICOM iTEC AG. All Rights Reserved.
--  ______ _ _
-- |  ____| (_)
-- | |__  | |_  ___  _ __   __ _
-- |  __| | | |/ _ \| '_ \ / _` |
-- | |____| | | (_) | | | | (_| |
-- |______|_|_|\___/|_| |_|\__,_|
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
--  BUT NOT LIMITED  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
--  NON INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
--  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-- Use this file to initialize a mocking database. The database have to be PostgreSQL.
-- You can use any cloud service or a docker container to create a local database. An example
-- docker-compose.yml file is also provided in this directory.

create schema if not exists public;

create table if not exists public.asset_type
(
    asset_type         text not null primary key,
    custom             boolean default true not null,
    payload_fct        text,
    vendor             text,
    model              text,
    translation        jsonb,
    urldoc             text,
    allowed_inactivity interval,
    iv_asset_type      integer,
    icon               text
);

create table if not exists public.asset
(
    asset_id    serial primary key,
    proj_id     text,
    gai         text not null,
    name        text,
    device_pkey text unique,
    asset_type  text,
    lat         double precision,
    lon         double precision,
    storey      smallint,
    description text,
    tags        text[],
    ar          boolean default false not null,
    tracker     boolean default false not null,
    loc_ref     integer,
    func_ref    integer,
    urldoc      text,
    unique (gai, proj_id)
    );

create table if not exists public.attribute_schema
(
    id              serial primary key,
    asset_type      text                     not null,
    attribute_type  text,
    attribute       text                     not null,
    subtype         text    default ''::text not null,
    enable          boolean default true     not null,
    translation     jsonb,
    unit            text,
    formula         text,
    scale           numeric,
    zero            double precision,
    precision       smallint,
    min             numeric,
    is_digital      boolean default false    not null,
    max             numeric,
    step            numeric,
    map             json,
    pipeline_mode   text,
    pipeline_raster text[],
    viewer          boolean default false    not null,
    ar              boolean default false    not null,
    seq             smallint,
    source_path     text[],
    virtual         boolean,
    unique (asset_type, subtype, attribute)
    );

create table if not exists public.heap
(
    asset_id            integer                                not null,
    subtype             text                                   not null,
    his                 boolean                  default true  not null,
    ts                  timestamp with time zone default now() not null,
    data                jsonb,
    valid               boolean,
    allowed_inactivity  interval,
    update_cnt          bigint                   default 1     not null,
    update_cnt_reset_ts timestamp with time zone default now() not null,
    primary key (asset_id, subtype)
    );

create table if not exists public.eliona_app (
    app_name    text primary key,
    category    text,
    active      boolean default false,
    initialised boolean default false
);

insert into public.eliona_app (app_name, category, active)
values  ('example', 'app', true);

create schema if not exists versioning;

create table if not exists versioning.patches (
    app_name    text                                   not null,
    patch_name  text                                   not null,
    applied_tsz timestamp with time zone default now() not null,
    applied_by  text                                   not null,
    requires    text[],
    conflicts   text[],
    primary key (app_name, patch_name)
    );

create table if not exists public.widget (
    id           serial unique,
    dashboard_id integer not null,
    type_id      integer not null,
    seq          smallint,
    detail       json,
    asset_id     integer,
    primary key (dashboard_id, id)
);

create table if not exists public.widget_data (
    widget_id         integer not null,
    widget_element_id integer not null,
    asset_id          integer,
    data              json,
    id                serial primary key
);

create table if not exists public.widget_type (
    type_id              serial primary key,
    name                 text   not null unique,
    tag                  text,
    translation          jsonb,
    icon                 text,
    custom               boolean default true not null,
    with_alarm           boolean,
    with_timespan_select boolean
);

create table if not exists public.widget_element (
    id       serial primary key,
    type_id  integer not null,
    category text    not null,
    seq      smallint default 0,
    config   json
);

create table if not exists public.alarm (
    alarm_id    integer                  not null  primary key,
    asset_id    integer                  not null,
    subtype     text,
    attribute   text,
    prio        smallint                 not null,
    val         double precision,
    ack_p       boolean                  not null,
    ts          timestamp with time zone not null,
    gone_ts     timestamp with time zone,
    ack_ts      timestamp with time zone,
    auto_quench timestamp with time zone,
    multi       integer default 1        not null,
    message     json                     not null,
    ack_text    text,
    ack_user_id text
);

create table if not exists public.alarm_cfg (
    alarm_id    integer generated by default as identity primary key,
    asset_id    integer                       not null,
    subtype     text    default 'input'::text not null,
    attribute   text                          not null,
    enable      boolean default true          not null,
    prio        smallint                      not null,
    ack_p       boolean                       not null,
    auto_quench interval,
    equal       double precision,
    low         double precision,
    high        double precision,
    message     json,
    subject     text,
    urldoc      text,
    notify_on   char,
    dont_mask   boolean default false         not null,
    tags        text[]
);

create table if not exists public.alarm_history (
    alarm_id    integer,
    asset_id    integer                  not null,
    subtype     text                     not null,
    attribute   text,
    prio        smallint                 not null,
    val         double precision,
    ack_p       boolean                  not null,
    ts          timestamp with time zone not null,
    gone_ts     timestamp with time zone,
    ack_ts      timestamp with time zone,
    multi       integer                  not null,
    message     json,
    ack_text    text,
    ack_user_id text,
    primary key (ts, asset_id, subtype)
);

create table if not exists public.edge_bridge
(
    bridge_id   integer primary key,
    node_id     text,
    asset_id    integer,
    class       text                  not null,
    description text,
    enable      boolean default false not null,
    config      json
);

create extension if not exists "uuid-ossp";

create table if not exists public.eliona_node
(
    node_id     text    primary key,
    ident       uuid    default uuid_generate_v4()                                   not null        unique,
    password    text,
    asset_id    integer        unique,
    vendor      text,
    model       text,
    description text,
    enable      boolean default false                                                not null
);

create table if not exists public.iosys_access
(
    id              integer primary key,
    device_id       integer               not null,
    iosvar          text                  not null,
    iostype         text,
    down            boolean default false not null,
    enable          boolean default true  not null,
    asset_id        integer,
    subtype         text                  not null,
    attribute       text                  not null,
    scale           double precision,
    zero            double precision,
    mask            integer[],
    mask_attributes text[],
    dead_time       integer,
    dead_band       double precision,
    filter          text,
    tau             double precision,
    unique (device_id, iosvar)
);

create table if not exists public.iosys_device
(
    device_id   integer primary key,
    bridge_id   integer                not null,
    enable      boolean  default false not null,
    port        integer,
    certificate text,
    key         text,
    timeout     smallint default 0,
    reconnect   smallint default 30
);

create table if not exists public.mbus_access
(
    id        integer primary key,
    device_id integer              not null,
    field     smallint             not null,
    enable    boolean default true not null,
    asset_id  integer,
    subtype   text,
    attribute text,
    scale     double precision,
    zero      double precision,
    unique (device_id, field),
    unique (asset_id, subtype, attribute)
);

create table if not exists public.mbus_device
(
    device_id         integer primary key,
    bridge_id         integer                not null,
    manufacturer      text,
    model             text,
    address           smallint,
    sec_address       text,
    enable            boolean  default false not null,
    raster            text,
    max_fail          integer  default 4,
    max_retry         integer  default 3,
    send_nke          boolean  default false,
    app_reset_subcode smallint,
    multi_frames      smallint default 0
);

create table if not exists public.acl_key_access
(
    security_id integer,
    object_id   integer,
    mask        integer,
    displayname text,
    principal   boolean,
    path        text,
    public      boolean,
    key_id      integer
);

insert into public.acl_key_access (security_id, object_id, mask, displayname, principal, path, public, key_id)
values  (null, null, 3, null, false, 'api.nodes', false, 1),
        (null, null, 3, null, false, 'api.apps.patches', false, 1),
        (null, null, 3, null, false, 'api.data.trends', false, 1),
        (null, null, 3, null, false, 'api.alarms.highest', false, 1),
        (null, null, 3, null, false, 'api.alarms.history', false, 1),
        (null, null, 3, null, false, 'api.dashboards', false, 1),
        (null, null, 3, null, false, 'api.agent.devices.mappings', false, 1),
        (null, null, 3, null, false, 'api.data.listener', false, 1),
        (null, null, 3, null, false, 'api.agent.devices', false, 1),
        (null, null, 3, null, false, 'api.widget.types', false, 1),
        (null, null, 3, null, false, 'api.alarm.rules', false, 1),
        (null, null, 3, null, false, 'api.alarms', false, 1),
        (null, null, 3, null, false, 'api.aggregations', false, 1),
        (null, null, 3, null, false, 'api.asset.types', false, 1),
        (null, null, 3, null, false, 'api.agents', false, 1),
        (null, null, 3, null, false, 'api.data.aggregated', false, 1),
        (null, null, 3, null, false, 'api.data', false, 1),
        (null, null, 3, null, false, 'api.assets', false, 1),
        (null, null, 3, null, false, 'api.apps', false, 1),
        (null, null, 3, null, false, 'api.asset.types.attributes', false, 1),
        (null, null, 3, null, false, 'api.dashboards.widgets', false, 1);

create table if not exists public.keyauth
(
    key_id  integer,
    key     text,
    expires double precision
);

insert into public.keyauth (key_id, key, expires)
values  (1, 'secret', null);

create table if not exists public.dashboard
(
    dashboard_id serial unique,
    user_id      text     not null,
    proj_id      text     not null,
    name         text,
    seq          smallint default 0,
    primary key (user_id, proj_id, dashboard_id)
);
