public class IMDBController {
    @AuraEnabled(cacheable=true)
       public static String getMovies(String searchText){
           Http http = new Http();
           HttpRequest request = new HttpRequest();
           request.setEndpoint('callout:IMDB/imdb/imdbSearchByName?query='+searchText);
           request.setMethod('GET');
           HttpResponse response = http.send(request);
           if (response.getStatusCode() == 200) {
               return response.getBody();
           }
           else{
               return 'Error Code :'+response.getStatusCode();
           }
           
           
       }
       
       @AuraEnabled(cacheable=true)
       public static String getMovieDetails(String movieId){
           Http http = new Http();
           HttpRequest request = new HttpRequest();
           request.setEndpoint('callout:IMDB/imdb/imdbSearchById?movieId='+movieId);
           request.setMethod('GET');
           HttpResponse response = http.send(request);
           if (response.getStatusCode() == 200) {
               return response.getBody();
           }
           else{
               return 'Error Code :'+response.getStatusCode();
           }
       }
   }