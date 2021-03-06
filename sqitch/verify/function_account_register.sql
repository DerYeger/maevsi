-- Verify maevsi:function_account_register on pg

BEGIN;

DO $$
BEGIN
   ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi_private.account_register(TEXT, TEXT, TEXT)', 'EXECUTE'));
   ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi_private.account_register(TEXT, TEXT, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
