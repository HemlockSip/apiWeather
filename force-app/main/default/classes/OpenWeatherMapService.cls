public class OpenWeatherMapService {
    private static final String BASE_URL = 'http://api.openweathermap.org/geo/1.0/direct';
    private static final String API_KEY = WeatherAPIKey__c.getInstance().Api_Key__c;
    
    public class LocationRequest {
        private String cityValue;
        private String stateCodeValue;
        private String countryCodeValue;
        private Integer limitValue;
        
        public String city {
            get { return cityValue; }
            set {
                if (String.isBlank(value)) {
                    throw new OpenWeatherMapException('City name cannot be blank');
                }
                if (value.length() > 100) {
                    throw new OpenWeatherMapException('City name cannot exceed 100 characters');
                }
                cityValue = value.trim();
            }
        }
        
        public String stateCode {
            get { return stateCodeValue; }
            set {
                if (value != null) {
                    if (value.length() > 2) {
                        throw new OpenWeatherMapException('State code must be 2 characters or less');
                    }
                    stateCodeValue = value.toUpperCase().trim();
                }
            }
        }
        
        public String countryCode {
            get { return countryCodeValue; }
            set {
                if (value != null) {
                    if (value.length() != 2) {
                        throw new OpenWeatherMapException('Country code must be exactly 2 characters');
                    }
                    countryCodeValue = value.toUpperCase().trim();
                }
            }
        }
        
        public Integer limitInteger {
            get { return limitValue; }
            set {
                if (value == null) {
                    limitValue = 5;
                } else if (value < 1) {
                    throw new OpenWeatherMapException('Limit must be at least 1');
                } else if (value > 5) {
                    throw new OpenWeatherMapException('Limit cannot exceed 5');
                } else {
                    limitValue = value;
                }
            }
        }
        
        public LocationRequest(String city, String stateCode, String countryCode, Integer limitInteger) {
            this.city = city;
            this.stateCode = stateCode;
            this.countryCode = countryCode;
            this.limitInteger = limitInteger;
            validateLocationCombination();
        }
        
        public LocationRequest() {
            this.limitInteger = 5;
        }
        
        private void validateLocationCombination() {
            if (String.isNotBlank(stateCode) && String.isBlank(countryCode)) {
                throw new OpenWeatherMapException('Country code is required when state code is provided');
            }
        }
        
        public void validate() {
            if (String.isBlank(city)) {
                throw new OpenWeatherMapException('City is required');
            }
            validateLocationCombination();
        }
    }
    
    public static LocationResponse getGeoLocation(LocationRequest request) {
        try {
            request.validate();
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            
            String location = EncodingUtil.urlEncode(request.city, 'UTF-8');
            if (String.isNotBlank(request.stateCode)) {
                location += ',' + EncodingUtil.urlEncode(request.stateCode, 'UTF-8');
            }
            if (String.isNotBlank(request.countryCode)) {
                location += ',' + EncodingUtil.urlEncode(request.countryCode, 'UTF-8');
            }
            
            String endpoint = BASE_URL + 
                '?q=' + location + 
                '&limit=' + request.limitInteger + 
                '&appid=' + API_KEY;
            
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000); // 2-minute timeout
            
            HttpResponse response = http.send(req);
            
            if (response.getStatusCode() == 200) {
                List<LocationResponse> locations = (List<LocationResponse>)JSON.deserialize(
                    response.getBody(), 
                    List<LocationResponse>.class
                );
                
                if (locations != null && !locations.isEmpty()) {
                    return locations[0];
                }
                throw new OpenWeatherMapException('No location data found for the given criteria');
            } else {
                throw new OpenWeatherMapException('API request failed with status code: ' + 
                    response.getStatusCode() + ' and message: ' + response.getStatus());
            }
        } catch (OpenWeatherMapException e) {
            throw e;
        } catch (Exception e) {
            throw new OpenWeatherMapException('Error making API call: ' + e.getMessage());
        }
    }
    
    public class LocationResponse {
        public Double lat { get; set; }
        public Double lon { get; set; }
        public String name { get; set; }
        public String country { get; set; }
        public String state { get; set; }
    }
    
    public class OpenWeatherMapException extends Exception {}
}