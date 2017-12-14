/** Detect if AWS RDS user present and fix permissions if required
Reference:
(1) https://gist.github.com/matthewberryman/7689766b5f94a5499d8c
**/
CREATE OR REPLACE FUNCTION set_rds_postgis_permissions()
  RETURNS VOID AS $$
  DECLARE rds INTEGER;
  BEGIN
    SELECT INTO rds count(*) FROM information_schema.schemata WHERE schema_name = 'topology' AND schema_owner = 'rdsadmin';
    IF rds > 0 THEN
      ALTER SCHEMA tiger owner to rds_superuser;
      ALTER SCHEMA topology owner to rds_superuser;

      CREATE FUNCTION exec(text) returns text language plpgsql volatile AS $f$ BEGIN EXECUTE $1; RETURN $1; END; $f$;
      SELECT exec('ALTER TABLE ' || quote_ident(s.nspname) || '.' || quote_ident(s.relname) || ' OWNER TO rds_superuser')
        FROM (
          SELECT nspname, relname
          FROM pg_class c JOIN pg_namespace n ON (c.relnamespace = n.oid)
          WHERE nspname in ('tiger','topology') AND
          relkind IN ('r','S','v') ORDER BY relkind = 'S')
      s;
    END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE
COST 100;

SELECT * FROM set_rds_postgis_permissions();
