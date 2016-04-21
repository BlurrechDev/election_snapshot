    var countryCodes = d3.map();
    d3.tsv("data/codes.tsv", function(data) {
      data.forEach(function(d) {
        countryCodes[d.name] = d.code;
      });
    });
    d3.tsv("data/elections.tsv", function(data) {
      var electionTable = "<table id='elections' on-click='{{countryClicked}}'><tr><th>Upcoming Elections</th><th>Election Type</th><th>Last Date</th></tr>";
      data.forEach(function(d) {
        electionTable += "<tr id='" + d.country.toLowerCase().split(' ').join('_') + "'><td><p><span class='flag-icon flag-icon-" + countryCodes[d.country] + "'></span></p>" + d.country + "</td><td>" + d.type + "</td><td>" + d.date + "</td></tr>";
      });
      electionTable += "</table>";
      document.getElementById("pageone").innerHTML += electionTable;
    });