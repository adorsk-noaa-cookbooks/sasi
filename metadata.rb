version          "0.0.1"

%w{postgresql postgis mapserver python}.each do |cb|
	depends cb
end
