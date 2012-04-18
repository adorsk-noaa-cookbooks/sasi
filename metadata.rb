version          "0.0.1"

%w{postgresql postgis}.each do |cb|
	depends cb
end
