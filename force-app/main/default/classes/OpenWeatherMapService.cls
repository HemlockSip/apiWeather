public class OpenWeatherMapService {
    private static final String BASE_URL = 'http://api.openweathermap.org/geo/1.0/direct';
    private static final String API_KEY = WeatherAPIKey__c.getInstance().Api_Key__c;
    
    public class LocationRequest {
        // Private backing fields
        private String cityValue;
        private String stateCodeValue;
        private String countryCodeValue;
        private Integer limitValue;
        
        // City property with validation
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
        
        // State code property with validation
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
        
        // Country code property with validation
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
        
        // Limit property with validation
        public Integer limitInteger {
            get { return limitValue; }
            set {
                if (value == null) {
                    limitValue = 5; // Default value
                } else if (value < 1) {
                    throw new OpenWeatherMapException('Limit must be at least 1');
                } else if (value > 5) {
                    throw new OpenWeatherMapException('Limit cannot exceed 5');
                } else {
                    limitValue = value;
                }
            }
        }
        
        // Constructor with validation
        public LocationRequest(String city, String stateCode, String countryCode, Integer limitInteger) {
            // These assignments will trigger the validation in the setters
            this.city = city;
            this.stateCode = stateCode;
            this.countryCode = countryCode;
            this.limitInteger = limitInteger;
            
            // Additional cross-field validation
            validateLocationCombination();
        }
        
        // Default constructor
        public LocationRequest() {
            this.limitInteger = 5; // Set default limit
        }
        
        // Method to validate combination of fields
        private void validateLocationCombination() {
            if (String.isNotBlank(stateCode) && String.isBlank(countryCode)) {
                throw new OpenWeatherMapException('Country code is required when state code is provided');
            }
        }
        
        // Method to validate the entire request
        public void validate() {
            if (String.isBlank(city)) {
                throw new OpenWeatherMapException('City is required');
            }
            validateLocationCombination();
        }
    }
    
    public static HttpResponse getGeoLocation(LocationRequest request) {
        try {
            // Validate request before proceeding
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
            
            return http.send(req);

            // from here on the request should be handled


        } catch (Exception e) {
            System.debug('Error making API call: ' + e.getMessage());
            throw new OpenWeatherMapException('Error making API call: ' + e.getMessage());
        }
    }
    
    public class OpenWeatherMapException extends Exception {}
}