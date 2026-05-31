@IsTest
public class weatherForecastFlowHelper_Test {
    // Mock response for Open-Meteo API callout
    private class OpenMeteoMock implements HttpCalloutMock {
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            
            res.setBody('{' + '"timezone":"GMT",' + '"hourly":{' + '"time":[' + '"2026-05-27T00:00",' + '"2026-05-27T01:00",' +
                        '"2026-05-27T02:00"' + '],' + '"temperature_2m":[29.0,29.2,30.4]' + '}' + '}');
            return res;
        }
    }
    
    @IsTest
    // Verify successful weather forecast retrieval
    static void testGetWeatherForecastSuccess() {
        Test.setMock(HttpCalloutMock.class, new OpenMeteoMock());
        weatherForecastFlowHelper.Request req = new weatherForecastFlowHelper.Request();
        
        req.cityName = 'Mumbai';
        req.forecastDate = Date.today().addDays(1);
        
        Test.startTest();
        List<weatherForecastFlowHelper.Result> results = weatherForecastFlowHelper.getWeatherForecast(new List<weatherForecastFlowHelper.Request>{ req });
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        
        weatherForecastFlowHelper.Result res = results[0];
        
        System.assertEquals(true, res.success);
        System.assertEquals('GMT', res.timezone);
        
        System.assert(res.timeList.contains('00:00'));
        System.assert(res.temperatureList.contains('29.0'));
    }
    
    @IsTest
    // Verify error handling when an invalid city is provided
    static void testInvalidCity() {
        weatherForecastFlowHelper.Request req = new weatherForecastFlowHelper.Request();
        req.cityName = 'InvalidCity';
        req.forecastDate = Date.today().addDays(1);
        
        Test.startTest();
        List<weatherForecastFlowHelper.Result> results = weatherForecastFlowHelper.getWeatherForecast( new List<weatherForecastFlowHelper.Request>{ req });
        Test.stopTest();
        
        System.assertEquals(false, results[0].success);
        System.assert(results[0].message.contains('Selected city not found'));
    }
}