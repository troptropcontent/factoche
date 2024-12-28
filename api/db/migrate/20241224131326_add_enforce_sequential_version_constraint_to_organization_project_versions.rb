class AddEnforceSequentialVersionConstraintToOrganizationProjectVersions < ActiveRecord::Migration[8.0]
  def up
    statement = <<-SQL
      CREATE OR REPLACE FUNCTION enforce_sequential_version() RETURNS TRIGGER AS $$
              BEGIN
                      IF (SELECT COALESCE(MAX(number), 0) + 1
              FROM organization_project_versions
              WHERE project_id = NEW.project_id) <> NEW.number THEN
              RAISE EXCEPTION 'number must be sequential for each project_id';
          END IF;

          RETURN NEW;
              END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER check_version_sequence
      BEFORE INSERT ON organization_project_versions
      FOR EACH ROW
      EXECUTE FUNCTION enforce_sequential_version();
    SQL
    execute(statement)
  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS check_version_sequence ON organization_project_versions;
      DROP FUNCTION IF EXISTS enforce_sequential_version();
    SQL
  end
end
