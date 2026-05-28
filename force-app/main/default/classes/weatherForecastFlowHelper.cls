public with sharing class weatherForecastFlowHelper {
    public class Request {
        @InvocableVariable(required=true label='City Name')
        public String cityName;
        
        @InvocableVariable(required=true label='Forecast Date')
        public Date forecastDate;
    }
    
    public class Result {
        @InvocableVariable(label='Success')
        public Boolean success;
        
        @InvocableVariable(label='Message')
        public String message;
        
        @InvocableVariable(label='Timezone')
        public String timezone;
        
        @InvocableVariable(label='Time List')
        public String timeList;
        
        @InvocableVariable(label='Temperature List')
        public String temperatureList;
    }
    
    public class WeatherCityInfo {
        public Decimal latitude;
        public Decimal longitude;
        
        public WeatherCityInfo(Decimal latitude, Decimal longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }
    }
    
    public class WeatherForecastException extends Exception {}
    
    @InvocableMethod(label='Get Weather Forecast'description='Fetch hourly weather forecast for a selected city and date')
    public static List<Result> getWeatherForecast(List<Request> requests) {
        List<Result> results = new List<Result>();
        
        for (Request req : requests) {
            Result res = new Result();
            
            try {
                WeatherCityInfo cityInfo = getCityInfo(req.cityName);
                if (cityInfo == null) {
                    throw new WeatherForecastException('Selected city not found or inactive.');
                }
                
                String isoDate = String.valueOf(req.forecastDate.year()) + '-' +
                    String.valueOf(req.forecastDate.month()).leftPad(2, '0') + '-' +
                    String.valueOf(req.forecastDate.day()).leftPad(2, '0');
                
                String endpoint = 'https://api.open-meteo.com/v1/forecast' +'?latitude=' + String.valueOf(cityInfo.latitude) +
                    '&longitude=' + String.valueOf(cityInfo.longitude) + '&hourly=temperature_2m' +
                    '&start_date=' + isoDate + '&end_date=' + isoDate;
                
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint(endpoint);
                httpReq.setMethod('GET');
                httpReq.setTimeout(60000);
                
                Http http = new Http();
                HttpResponse httpRes = http.send(httpReq);
                
                if (httpRes.getStatusCode() != 200) {
                    throw new WeatherForecastException('Open-Meteo API error: ' + httpRes.getStatus());
                }
                
                Map<String, Object> apiBody = (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
                
                String timezone = (String) apiBody.get('timezone');
                Map<String, Object> hourly = (Map<String, Object>) apiBody.get('hourly');
                
                if (hourly == null) {
                    throw new WeatherForecastException('Invalid response from weather API.');
                }
                
                List<Object> times = (List<Object>) hourly.get('time');
                List<Object> temps = (List<Object>) hourly.get('temperature_2m');
                
                if (times == null || temps == null) {
                    throw new WeatherForecastException('Hourly data not found in API response.');
                }
                
                Integer count = Math.min(times.size(), temps.size());
                
                List<String> timeLines = new List<String>();
                List<String> tempLines = new List<String>();
                
                for (Integer i = 0; i < count; i++) {
                    String rawTime = String.valueOf(times[i]);
                    String hourOnly = rawTime.substring(11, 16);
                    
                    timeLines.add(hourOnly);
                    tempLines.add(String.valueOf(temps[i]) + ' °C');
                }
                
                res.success = true;
                res.message = 'Forecast retrieved successfully';
                res.timezone = timezone;
                res.timeList = String.join(timeLines, '\n');
                res.temperatureList = String.join(tempLines, '\n');
                
            } catch (Exception e) {
                res.success = false;
                res.message = e.getMessage();
            }
            results.add(res);
        }
        return results;
    }
    
    private static WeatherCityInfo getCityInfo(String cityName) {
        List<Weather_City__mdt> cities = [SELECT Latitude__c, Longitude__c FROM Weather_City__mdt WHERE City_Name__c = :cityName 
                                          AND Active__c = true LIMIT 1];
        
        if (cities.isEmpty()) {
            return null;
        }
        
        Weather_City__mdt c = cities[0];
        return new WeatherCityInfo(c.Latitude__c, c.Longitude__c);
    }
}