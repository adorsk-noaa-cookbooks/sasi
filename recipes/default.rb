include_recipe %w{postgresql postgis python}

# Make sasi user.
user "#{node['sasi']['user']}" do
	supports :manage_home => true
end

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
psql -c "CREATE USER #{node['sasi']['dbuser']} WITH PASSWORD '#{node['sasi']['dbpass']}';"
psql #{node['sasi']['db']} -c "GRANT ALL ON DATABASE #{node['sasi']['db']} to #{node['sasi']['dbuser']}"
psql #{node['sasi']['db']} -c "GRANT ALL ON spatial_ref_sys to #{node['sasi']['dbuser']}"
psql #{node['sasi']['db']} -c "GRANT ALL ON geometry_columns to #{node['sasi']['dbuser']}"
END
	not_if "sudo -u postgres psql -t -c \"select 1 from pg_database where datname='#{node['sasi']['db']}'\"|grep -q 1"
end



# Install dependencies for python packages.
python_dependencies = [
	"python-dev",
	"python-gdal",
	"libgdal1-1.7.0",
	"libgdal1-dev",
]
python_dependencies.each do |dependency|
	package dependency do
		action :install
	end
end


# Install python packages
python_packages = [
	"fiona",
	"flask",
	"Flask-Cache",
	"GDAL",
	"geoalchemy",
	"sqlalchemy",
	"numpy",
	"PIL",
	"psycopg2",
	"shapely"
]

python_packages.each do |pkg|
	python_pip pkg do
		action :install
	end
end


# Enable mod wsgi.
apache_module "wsgi" do
	enable true
end

# Make sasi webdir.
directory "#{node['sasi']['webdir']}" do
	action :create
	owner node['sasi']['user']
	group node['sasi']['group']
	recursive true
end

# Make sasi docroot.
directory "#{node['sasi']['docroot']}" do
	action :create
	owner node['sasi']['user']
	group node['sasi']['group']
	recursive true
end

# Configure virtualhost.
web_app "sasi-webapp" do
	template "sasi-webapp.conf.erb"
	enable true
	docroot node['sasi']['docroot']
	server_name node['sasi']['server_name']
	server_aliases node['sasi']['server_aliases']
end

