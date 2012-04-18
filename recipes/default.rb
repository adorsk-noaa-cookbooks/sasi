include_recipe %w{postgresql postgis}

# Tmp hack to get stuff working.
postgis_sql_dir = '/usr/share/postgresql/9.1/contrib/postgis-1.5'

# Make Spatial DB.
execute "create-sasi-db" do
	user "postgres"
	command	<<END
createdb #{node['sasi']['db']};
createlang plpgsql #{node['sasi']['db']}
psql -d #{node['sasi']['db']} -f #{postgis_sql_dir}/postgis.sql
psql -d #{node['sasi']['db']} -f #{postgis_sql_dir}/spatial_ref_sys.sql
END
	not_if "sudo -u postgres psql -t -c \"select 1 from pg_database where datname='#{node['sasi']['db']}'\"|grep -q 1"
end

