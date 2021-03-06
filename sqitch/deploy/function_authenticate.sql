-- Deploy maevsi:function_authenticate to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: role_account
-- requires: role_anonymous
-- requires: type_jwt
-- requires: table_account

BEGIN;

CREATE FUNCTION maevsi.authenticate(
  "username" TEXT,
  "password" TEXT
) RETURNS maevsi.jwt AS $$
BEGIN
  IF ("username" = '' AND "password" = '') THEN
    RETURN (SELECT ('maevsi_anonymous', NULL, NULL, maevsi.invite_claim_array())::maevsi.jwt);
  ELSIF ("username" IS NOT NULL AND "password" IS NOT NULL) THEN
    RETURN (SELECT ('maevsi_account', account.contact_id, account.username, NULL)::maevsi.jwt
      FROM maevsi_private.account
      WHERE
        account."username" = $1
        AND account.password_hash = maevsi.crypt($2, account.password_hash));
  END IF;
END $$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.authenticate(TEXT, TEXT) IS 'Creates a JWT token that will securely identify an account and give it certain permissions.';

GRANT EXECUTE ON FUNCTION maevsi.authenticate(TEXT, TEXT) TO maevsi_account, maevsi_anonymous;

COMMIT;
