import 'dart:html';
import 'dart:js' as js;

import 'package:polymer/polymer.dart';
import 'package:d3/dsv/dsv.dart';
import 'util.dart';
export 'package:polymer/init.dart';

@CustomTag('main-app')
class MainApp extends PolymerElement {
  Element get insertionPoint => document.querySelector('.pageone');
  TableElement get elections => document.getElementById('elections');
  Element get popup => document.querySelector('.popup');

  var all = new NodeValidatorBuilder()
    ..allowHtml5(uriPolicy: new WikiUriPolicy())
    ..allowInlineStyles()
    ..allowImages(new WikiUriPolicy())
    ..allowNavigation(new WikiUriPolicy())
    ..allowElement('iframe', attributes: ['src'], uriPolicy: new WikiUriPolicy());

  MainApp.created() : super.created() {
    /// To Replace add_election_selector.js
    //var countryCodes = d3.map();
    Map countryCodes = new Map();
    tsv("data/codes.tsv", callback: (final List<Map<String, Object>> data) {
      data.forEach((d) {
        countryCodes[d['name']] = d['code'];
      });
    });
    tsv("data/elections.tsv", callback: (final List<Map<String, Object>> data) {
      var electionTable = "<table id='elections' on-click='{{countryClicked}}'><tr><th>Upcoming Elections</th><th>Election Type</th><th>Last Date</th></tr>";
      data.forEach((d) {
        electionTable += "<tr id='" + lowercaseNoSpaces(d['country'])
            + "'><td><p><span class='flag-icon flag-icon-" + countryCodes[d['country']]
            + "'></span></p>" + d['country'] + "</td><td>" + d['type'] + "</td><td>" + d['date'] + "</td></tr>";
      });
      electionTable += "</table>";
      document.getElementById("pageone").innerHTML += electionTable;
    });

    if (elections == null) return; // Error message, broken HTML.
    for (TableRowElement tableRow in elections.rows) {
      if (tableRow.cells[2].text == '') {
        tableRow.innerHtml = '';
        continue;
      }
      List<String> dateParts = tableRow.cells[2].text.split(' ');
      if (dateParts.length != 3) continue; // Format Error, dates should be exactly 3 parts.
      int month = monthNumber(dateParts[1]);
      int year = int.parse(dateParts[2]);
      if (dateParts[0] == '??') dateParts[0] = endOfTheMonth(month, year).toString(); // Unknown day should overestimate.

      /// Hide historical elections until alternate functionality is implemented.
      int day = int.parse(dateParts[0]);
      if (new DateTime(year, month, day).isBefore(new DateTime.now())) {
        tableRow.style.backgroundColor = 'lightgrey';
        tableRow.style.display = 'none';
      }
      tableRow.dataset['datemag'] = (day + month * 33 + year * 397).toString();
    }
    sortElectionsByDate();
    insertionPoint.appendHtml('<div><a id="chosenelectionlink"><h1 id="chosenelection"></h1></a></div>', validator: all);
    insertionPoint.appendHtml("<div class='spaced'><a>News</a><a>Parliament</a> <a>Electoral System</a> <a>Economy</a></div>");
    insertionPoint.appendHtml('<div class="popup"></div>', validator: all);

    tsv("data/elections.tsv", callback: (final List<Map<String, Object>> data) {
      data.forEach((d) {
        String electionId = d['country'].toLowerCase() + d['date'];
        String electionBox = '<div class="electionbox" id="' + electionId.replaceAll(' ', '_').replaceAll('?', '_') + '">';
        if (d['data_html'] == '' || d['data_html'] == null) {
          popup.insertAdjacentHtml('afterbegin', electionBox + '<div id="wikiimport"><div id="polldata" style="text-align: center; padding: 4%; border: 1px black solid; margin-top: 4%; margin: 2%;">No data could be provided by Wikipedia.</div></div><iframe seamless class="dataiframe" style="display: none; width: 96%; height: 400px; overflow: hidden;" src="https://en.wikipedia.org/w/index.php?title=Opinion_polling_for_the_next_United_Kingdom_general_election&printable=yes"></iframe>' + '</div>', validator: all);
        } else {
          popup.insertAdjacentHtml('afterbegin', electionBox + d['data_html'] + '</div>', validator: all);
        }
      });
      elections.children.first.children[2].click();
    });
  }
  
  sortElectionsByDate() {
    Map datedRowOrder = new Map();
    int rowCount = -1;
    for (TableRowElement tableRow in elections.rows) {
      rowCount++;
      if (tableRow.style.display == 'none' || tableRow.innerHtml == '' || tableRow.cells[2].text.split(' ').length != 3) continue;
      datedRowOrder.putIfAbsent(tableRow.dataset['datemag'], () => rowCount);
    }
    String newElectionsTable = '<tbody><tr><th>Upcoming Elections</th><th>Election Type</th><th>Latest Date</th></tr>';
    for (var key in datedRowOrder.keys.toList()..sort()) {
      TableRowElement row = elections.rows[datedRowOrder[key]];
      print(row.outerHtml);
      newElectionsTable += '<tr id="' + row.id + '">' + row.innerHtml + '</tr>';
    }
    newElectionsTable += '</tbody>';
    elections.setInnerHtml(newElectionsTable, validator: all);
    elections.rows.forEach((TableRowElement row) => row.onClick.listen((e) => countryClicked(e)));
    //for (TableRowElement tableRow in elections.rows) tableRow.onClick.listen((e) => countryClicked(e));
  }
  
  countryClicked(MouseEvent event) {
    event.stopPropagation();
    var targetRow = event.target.parent;
    if (targetRow == null) return;
    if (event.target is TableRowElement) targetRow = event.target;
    String targetRowID = targetRow.id.toString();

    querySelectorAll('tr').forEach((e) => e.attributes.remove('selected'));
    targetRow.attributes['selected'] = 'true';
    querySelectorAll('.electionbox').forEach((e) => e.classes.remove('visible'));

    if (SHOW_NEWS_FEED) {
      if (querySelector('#feedwind_9721439341107723') != null) querySelector('#feedwind_9721439341107723').remove();
      if (querySelector('#toslink') != null) querySelector('#toslink').remove();
      popup.appendHtml('<iframe id="feedwind_9721439341107723" width="500" src="http://feed.mikle.com/widget/?rssmikle_url=http%3A%2F%2Fnews.google.com%2Fnews%3Fq%3D' + targetRowID + '%2520general%2520election%26output%3Drss&amp;rssmikle_frame_width=500&amp;rssmikle_frame_height=400&amp;frame_height_by_article=6&amp;rssmikle_target=_blank&amp;rssmikle_font=Arial%2C%20Helvetica%2C%20sans-serif&amp;rssmikle_font_size=12&amp;rssmikle_border=off&amp;responsive=off&amp;text_align=left&amp;text_align2=left&amp;corner=off&amp;scrollbar=off&amp;autoscroll=off&amp;scrolldirection=up&amp;scrollstep=3&amp;mcspeed=20&amp;sort=Off&amp;rssmikle_title=on&amp;rssmikle_title_sentence=News&amp;rssmikle_title_bgcolor=%230066FF&amp;rssmikle_title_color=%23FFFFFF&amp;rssmikle_item_bgcolor=%23FFFFFF&amp;rssmikle_item_title_length=55&amp;rssmikle_item_title_color=%230066FF&amp;rssmikle_item_border_bottom=on&amp;rssmikle_item_description=on&amp;item_link=off&amp;rssmikle_item_description_length=150&amp;rssmikle_item_description_color=%23666666&amp;rssmikle_item_date=gl1&amp;rssmikle_timezone=Etc%2FGMT&amp;datetime_format=%25b%20%25e%2C%20%25Y%20%25l%3A%25M%20%25p&amp;item_description_style=text%2Btn&amp;item_thumbnail=full&amp;item_thumbnail_selection=auto&amp;article_num=15&amp;rssmikle_item_podcast=off&amp;iframe_id=feedwind_9721439341107723&amp;" scrolling="no" name="rssmikle_frame" marginwidth="0" marginheight="0" vspace="0" hspace="0" frameborder="0" style="height: 869px;"></iframe><div id="toslink" style="font-size:10px; text-align:center; width:500px;"><a href="http://feed.mikle.com/" target="_blank" style="color:#CCCCCC;">RSS Feed Widget</a></div>', validator: all);
    }

    querySelector('#chosenelection').innerHtml = targetRow.cells[0].innerHtml;
    tsv("data/countries.tsv", callback: (final List<Map<String, Object>> data) {
     data.where((d) => targetRowID == lowercaseNoSpaces(d['name'])).forEach((d) => selectCountryByCode(int.parse(d['id'])));
    });
    tsv("data/elections.tsv", callback: (final List<Map<String, Object>> data) {
      String soughtID = '#chosenelectionlink';
      data.where((d) => targetRowID == lowercaseNoSpaces(d['country'])).forEach((d) => querySelector(soughtID).setAttribute('href', d['data_url']));
    });

    var e = document.querySelector(('#' + targetRowID + targetRow.children[2].text).replaceAll(' ', '_').replaceAll('?', '_'));
    if (e != null) e.classes.add('visible');

    if (SHOW_LOCAL_GRAPH) js.context.callMethod('loadGraph');
  }
}