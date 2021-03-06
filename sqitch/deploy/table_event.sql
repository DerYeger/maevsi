-- Deploy maevsi:table_event to pg
-- requires: schema_public
-- requires: role_account
-- requires: role_anonymous
-- requires: table_account
-- requires: enum_event_visibility

BEGIN;

CREATE TABLE maevsi.event (
    "id"                    SERIAL PRIMARY KEY,
    "name"                  TEXT NOT NULL CHECK (char_length("name") < 100),
    "slug"                  TEXT NOT NULL CHECK (char_length("slug") < 100 AND "slug" ~* '^[-A-Za-z0-9_]+$'),
    "visibility"            maevsi.event_visibility NOT NULL,
    "organizer_username"    TEXT REFERENCES maevsi_private.account("username") NOT NULL,
    "description"           TEXT CHECK (char_length("description") < 10000),
    "place"                 TEXT CHECK (char_length("place") < 300),
    "start"                 TIMESTAMP WITH TIME ZONE NOT NULL,
    "end"                   TIMESTAMP WITH TIME ZONE,
    "archived"              BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE ("organizer_username", "slug")
);

COMMENT ON TABLE maevsi.event IS 'An event.';
COMMENT ON COLUMN maevsi.event.id IS 'The record''s id.';
COMMENT ON COLUMN maevsi.event.name IS 'The event''s name.';
COMMENT ON COLUMN maevsi.event.slug IS 'The event''s name, slugified.';
COMMENT ON COLUMN maevsi.event.visibility IS 'The event''s visibility.';
COMMENT ON COLUMN maevsi.event.organizer_username IS 'The id of the event''s organizer.';
COMMENT ON COLUMN maevsi.event.description IS 'The event''s description.';
COMMENT ON COLUMN maevsi.event.place IS 'The event''s place as it can be shown on a map.';
COMMENT ON COLUMN maevsi.event.start IS 'The event''s start date and time, with timezone.';
COMMENT ON COLUMN maevsi.event.end IS 'The event''s end date and time, with timezone.';
COMMENT ON COLUMN maevsi.event.archived IS 'Indicates whether the event is archived.';

GRANT SELECT ON TABLE maevsi.event TO maevsi_account, maevsi_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE maevsi.event TO maevsi_account;

GRANT USAGE ON SEQUENCE maevsi.event_id_seq TO maevsi_account;

ALTER TABLE maevsi.event ENABLE ROW LEVEL SECURITY;

-- Display events that are public.
-- Display events that are organized by oneself.
-- Display events to which oneself is invited.
CREATE POLICY event_select ON maevsi.event FOR SELECT USING (
        visibility = 'public'
    OR  organizer_username = current_setting('jwt.claims.username', true)::TEXT
    OR  id IN (SELECT maevsi_private.events_invited())
);

COMMIT;
