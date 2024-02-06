'use strict';

export class Network {
    static fetchSync (url) {
    var request = new XMLHttpRequest();
        request.open('GET', url, false); // Set the third parameter to false for a synchronous request
        request.send(null);
        
        if (request.status === 200) {
            return request.responseText;
        } else {
            // Handle HTTP error (404, 500, etc.)
            console.error("Failed to fetch data: ", request.statusText);
        }
    }
}