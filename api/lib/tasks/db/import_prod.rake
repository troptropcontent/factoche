namespace :db do
  desc "Download production database and restore it locally (requires SSH access to production)"
  task import_prod: :environment do
    abort "This task can only be run in the development environment." unless Rails.env.development?

    prod_host      = "ubuntu@51.83.33.169"
    service_name   = "fabati-production-web"
    local_dump_path = "/tmp/factoche_prod_backup.dump"

    db_config  = ActiveRecord::Base.connection_db_config.configuration_hash
    local_db   = db_config[:database]
    local_host = db_config[:host] || "localhost"
    local_port = (db_config[:port] || 5432).to_s
    local_user = db_config[:username] || "postgres"
    local_pass = db_config[:password].to_s

    puts "WARNING: This will overwrite your local database '#{local_db}' with production data."
    print "Are you sure? [y/N] "
    response = $stdin.gets&.chomp
    abort "Aborted." unless response&.downcase == "y"

    puts "\n=> Dumping production database (this may take a while)..."

    # Run pg_dump via a postgres:17 Docker image on the production server.
    # The Rails container ships postgresql-client 15 which is incompatible with the
    # production DB server (PostgreSQL 17), so we spin up a matching client container instead.
    dump_cmd = <<~SHELL
      ssh #{prod_host} "
        CONTAINER=\\$(docker ps --filter 'name=#{service_name}' --format '{{.Names}}' | head -1) && \
        DB_URL=\\$(docker exec \\$CONTAINER sh -c 'echo \\$DATABASE_URL') && \
        docker run --rm postgres:17 pg_dump \\"\\$DB_URL\\" --no-owner --no-acl -Fc
      " > #{local_dump_path}
    SHELL

    system(dump_cmd.strip) or abort "Failed to dump production database."

    size_mb = (File.size(local_dump_path) / 1_048_576.0).round(1)
    puts "=> Downloaded #{size_mb} MB backup to #{local_dump_path}"

    pg_env = {}
    pg_env["PGPASSWORD"] = local_pass unless local_pass.empty?

    ActiveRecord::Base.connection_pool.disconnect!

    # pg client binaries (dropdb/createdb/pg_restore) are not available in this container.
    # Route all pg commands through a throwaway postgres:17 Docker container that can reach
    # the local DB host.
    pg_docker_run = lambda do |*args|
      docker_env = local_pass.empty? ? [] : [ "-e", "PGPASSWORD=#{local_pass}" ]
      system("docker", "run", "--rm", "--network=host", *docker_env, "postgres:17", *args)
    end

    puts "=> Dropping local database '#{local_db}'..."
    pg_docker_run.call("dropdb", "--if-exists", "-h", local_host, "-p", local_port, "-U", local_user, local_db) \
      or abort "Failed to drop local database."

    puts "=> Creating local database '#{local_db}'..."
    pg_docker_run.call("createdb", "-h", local_host, "-p", local_port, "-U", local_user, local_db) \
      or abort "Failed to create local database."

    puts "=> Restoring backup to '#{local_db}'..."
    # Mount the dump file into the container so pg_restore can read it.
    restore_ok = system(
      "docker", "run", "--rm", "--network=host",
      *(local_pass.empty? ? [] : [ "-e", "PGPASSWORD=#{local_pass}" ]),
      "-v", "#{local_dump_path}:/tmp/restore.dump",
      "postgres:17",
      "pg_restore", "-h", local_host, "-p", local_port, "-U", local_user,
      "-d", local_db, "--no-owner", "--no-acl", "/tmp/restore.dump"
    )
    puts "   (Note: pg_restore reported warnings above — these are usually harmless)" unless restore_ok

    puts "=> Cleaning up..."
    File.delete(local_dump_path)

    puts "\n=> Done! Production database successfully restored to '#{local_db}'."
  end
end
