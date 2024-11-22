public with sharing class GeoLocalitazionService {
    
    // The purpose of this method is to retrive the geo localitazion of a city
    // since a Callout cannot accept SObjects as parameters, i will need to extract the city name from the SObject and pass it
    // to the rest api to retrive the geo localitazion.
    
    private static final String BASE_URL = 'http://api.openweathermap.org/geo/1.0/direct?q=';
    private static final String API_KEY = WeatherAPIKey__c.getInstance().Api_Key__c;
    
    
    public void geoLocalitazionCallout(String cityName, String countryCode, String baseUrl, String apiKey, Id recordId) {
        
        
        // example of endpoint http://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}  
        Http http = new Http();
        HttpRequest geoReq = new HttpRequest();
        geoReq.setEndpoint(baseUrl + cityName + ',' + countryCode + '&limit=5&appid=' + apiKey);
        geoReq.setMethod('GET');
        
        
        HttpResponse geoResponse = http.send(geoReq);
        
        if (geoResponse.getStatusCode() == 200) {
            String responseBody = geoResponse.getBody();
            
            Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(geoResponse.getBody());
            
            // Extract the latitude and longitude from the response
            Double latitude = (Double)resultMap.get('lat');
            Double longitude = (Double)resultMap.get('lon');
            
            // Update the record with the latitude and longitude
            
            Schema.SObjectType objectType = recordId.getSObjectType();
            String objectName = objectType.getDescribe().getName(); // Returns 'Account', 'Contact', etc.
            
            switch on objectName {
                when 'Account' {
                    Account acc = [SELECT Id, BillingCity,Latitude__c,Longitude__c FROM Account WHERE Id = :recordId];
                    acc.Latitude__c = latitude;
                    acc.Longitude__c = longitude;
                    update acc;
                }	
                when 'Contact' {		
                    Contact con = [SELECT Id, MailingCity,Latitude__c,Longitude__c FROM Contact WHERE Id = :recordId];
                    con.Latitude__c = latitude;
                    con.Longitude__c = longitude;
                    update con;
                }
                when 'Event' {		
                    Event evt = [SELECT Id, Location,Latitude__c,Longitude__c FROM Event WHERE Id = :recordId];
                    evt.Latitude__c = latitude;
                    evt.Longitude__c = longitude;
                    update evt;
                }
                when else {		 
                    System.debug('The Object is not yet supported. Please contact the developer.');
                }
                
            }
            
        }
    }
    
    
    
    // Support method that returns the city name from the SObject
    // For the moment it will work on Accounts, Contacts and Events
    private String getCityName(SObject sobjectToVerify) {
        
        if (sobjectToVerify instanceof Account) {
            return (String)sobjectToVerify.get('BilingCity');
        } else if (sobjectToVerify instanceof Contact) {
            return (String)sobjectToVerify.get('MailingCity');
        } else if (sobjectToVerify instanceof Event) {
            return (String)sobjectToVerify.get('Location');
        } else {
            System.debug('Object not yet supported');
            return null;
        }
        
    }
    
    // Support method that returns the country name from the SObject
    // For the moment it will work on Accounts, Contacts and Events
    
    private String getCountryName(SObject sobjectToVerify) {
        
        if (sobjectToVerify instanceof Account) {
            return (String)sobjectToVerify.get('BillingCountry');
        } else if (sobjectToVerify instanceof Contact) {
            return (String)sobjectToVerify.get('MailingCountry');
        } else if (sobjectToVerify instanceof Event) {
            return (String)sobjectToVerify.get('Country__c');
        } else {
            System.debug('Object not yet supported');
            return null;
        }
        
    }
}

