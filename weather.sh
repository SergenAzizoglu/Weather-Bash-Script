#!/bin/bash
#Sergen Azizoglu s150140
#api key : 4dc7d611f5e04d3c9f315313181612   

if [ -z "$APIXUKEY" ]; then
	echo "You Should Provide API Key at APIXUKEY Environment Variable"
	exit 0
fi
f_flag='false'
location=''
update='false'

while getopts 'fl:u' flag; do
  case "${flag}" in
    f) f_flag='true' ;;
    l) location="${OPTARG}" ;;
    u) update='true' ;;
  esac
done

if [ -n "$location" ]; then
  	api_url="http://api.apixu.com/v1/current.json?key=$APIXUKEY&q=$location"
else
	api_url="http://api.apixu.com/v1/current.json?key=$APIXUKEY&q=poznan"
fi

download_parse(){
	curl -s $api_url --output /tmp/weather.json

	json_data=$(jq . /tmp/weather.json)

	city="$(jq '.location.name' <<< "$json_data")"
	country="$(jq '.location.country' <<< "$json_data")"
	tzid="$(jq '.location.tz_id' <<< "$json_data")"
	localtime="$(jq '.location.localtime' <<< "$json_data")"
	lastupdated="$(jq '.current.last_updated' <<< "$json_data")"
	humidity="$(jq '.current.humidity' <<< "$json_data")"
	condition="$(jq '.current.condition.text' <<< "$json_data")"

	if [ $f_flag == 'true' ]; then
		temp="$(jq '.current.temp_f' <<< "$json_data") F"
		wind="$(jq '.current.wind_mph' <<< "$json_data") MPH"
		feelslike="$(jq '.current.feelslike_f' <<< "$json_data") F"
		vision="$(jq '.current.vis_miles' <<< "$json_data") Miles"
	else
		temp="$(jq '.current.temp_c' <<< "$json_data") C"
		wind="$(jq '.current.wind_kph' <<< "$json_data") KPH"
		feelslike="$(jq '.current.feelslike_c' <<< "$json_data") C"
		vision="$(jq '.current.vis_km' <<< "$json_data") KM"
	fi
}

print_func(){
	echo ""
	echo ""
	echo -e "\t\tWeather at $city/$country"
	echo ""
	echo ""
	echo -e "\t\tZone: $tzid"
	echo -e "\t\tTime: $localtime"
	echo -e "\t\tTemperature: $temp"
	echo -e "\t\tFeelslike: $feelslike"
	echo -e "\t\tCondition: $condition"
	echo -e "\t\tWind: $wind"
	echo -e "\t\tHumidity: $humidity"
	echo -e "\t\tVision: $vision"
	echo ""
	echo ""
	echo -e "\t\tLast Updated: $lastupdated"
}



if [ $update == 'false' ]; then
	download_parse
	print_func
fi

while [ $update == 'true' ]; do 
	download_parse
	print_func
	sleep 300

done