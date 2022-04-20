set -x

docker run \
    --detach \
    --name learn-postgres \
    -e POSTGRES_USER=root \
    -e POSTGRES_PASSWORD=rootpassword \
    -p 5432:5432 \
    --rm \
    postgres

docker exec -i \
    learn-postgres \
    psql -U root -c "CREATE ROLE \"ro\" NOINHERIT;"


docker exec -i \
    learn-postgres \
    psql -U root -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"ro\";"

/*
vault write database/config/postgresql \
     plugin_name=postgresql-database-plugin \
     connection_url="postgresql://{{username}}:{{password}}@localhost:5432/postgres?sslmode=disable" \
     allowed_roles=readonly \
     username="root" \
     password="rootpassword"
*/

