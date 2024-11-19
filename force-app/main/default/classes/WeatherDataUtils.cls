public with sharing class WeatherDataUtils {
    
    public static void createWeatherData(SObject record) {
        Weather_Data__c weatherData = new Weather_Data__c();
        
        // Location Fields
        weatherData.Longitude__c = Decimal.valueOf((String)record.get('Longitude__c'));
        weatherData.Latitude__c = Decimal.valueOf((String)record.get('Latitude__c'));
        weatherData.Location_Name__c = (String)record.get('City__c');
        weatherData.Country_Code__c = (String)record.get('Country__c');
        
        // Weather Condition Fields
        weatherData.Weather_ID__c = Decimal.valueOf((String)record.get('Weather_ID__c'));
        weatherData.Weather_Main__c = (String)record.get('Weather_Main__c');
        weatherData.Weather_Description__c = (String)record.get('Weather_Description__c');
        
        // Temperature Fields
        weatherData.Temperature__c = Decimal.valueOf((String)record.get('Temperature__c'));
        weatherData.Feels_Like_Temperature__c = Decimal.valueOf((String)record.get('Feels_Like_Temperature__c'));
        weatherData.Min_Temperature__c = Decimal.valueOf((String)record.get('Min_Temperature__c'));
        weatherData.Max_Temperature__c = Decimal.valueOf((String)record.get('Max_Temperature__c'));
        
        // Atmospheric Fields
        weatherData.Pressure__c = Decimal.valueOf((String)record.get('Pressure__c'));
        weatherData.Humidity__c = Decimal.valueOf((String)record.get('Humidity__c'));
        
        // Wind Fields
        weatherData.Wind_Speed__c = Decimal.valueOf((String)record.get('Wind_Speed__c'));
        weatherData.Wind_Direction__c = Decimal.valueOf((String)record.get('Wind_Direction__c'));
        weatherData.Wind_Gust__c = Decimal.valueOf((String)record.get('Wind_Gust__c'));
        
        // Precipitation Fields
        weatherData.Rainfall_1h__c = Decimal.valueOf((String)record.get('Rainfall_1h__c'));
        
        // System Fields
        weatherData.Weather_Timestamp__c = DateTime.valueOf((String)record.get('Weather_Timestamp__c'));
        
        // Name field
        weatherData.Name = (String)record.get('Name');
        
        insert weatherData;
    }


}