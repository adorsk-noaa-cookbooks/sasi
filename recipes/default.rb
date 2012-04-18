include_recipe %w{postgresql postgis}

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
END
	not_if "sudo -u postgres psql -t -c \"select 1 from pg_database where datname='#{node['sasi']['db']}'\"|grep -q 1"
end

# Install pip.
package "python-pip"

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
		options "--force-yes"
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

