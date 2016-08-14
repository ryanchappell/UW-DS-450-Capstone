const fs = require('fs');
const util = require('util');

var apiUrlFormat = 'https://maps.googleapis.com/maps/api/timezone/json?location=%s,%s&timestamp=1458000000';

for (var i = 0; i < 100; i++) {
  var reqUrl = util.format(apiUrlFormat, i, i + 1);
  fs.appendFile('../output/latLongTimeZones.csv', reqUrl + '\r\n' ,function(res){
    console.log('done ' + i);
  });
}
