class Weather {
  ArrayList<City> cities = new ArrayList<City>();
  int cityInd = 0;
  static final String APPID = "941443d7050f07e6c7e86340797f2094";
  float windSpeed = 0, windDeg = 0;
  
  Weather() {
    cities.add(new City("Berlin","2950159"));
    cities.add(new City("Istanbul","745044"));
    cities.add(new City("Shanghai","1796236"));
    cities.add(new City("Tehran","112931"));
    cities.add(new City("Reykjavik","3413829"));
  }
  
  void query() {
    String lines[] = loadStrings("http://api.openweathermap.org/data/2.5/forecast/city?id=" + cities.get(cityInd % cities.size()).id + "&APPID=" + APPID);
    String s = "";
    for (int i = 0 ; i < lines.length; i++) {
      s += lines[i];
    }
    
    JSONObject j = JSONObject.parse(s);
    JSONArray list = j.getJSONArray("list");
    JSONObject v = list.getJSONObject(0);
    JSONObject wind = v.getJSONObject("wind");
    windSpeed = wind.getFloat("speed");
    windDeg = wind.getFloat("deg");
    City city = cities.get(cityInd % cities.size());
    println(city.name, "wind",windSpeed,windDeg);
  }
}

class City {
  String name, id;
  
  City(String aName, String aId) {
    name = aName;
    id = aId;
  }
}