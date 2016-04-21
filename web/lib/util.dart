library util;

import 'dart:html';

const bool SHOW_NEWS_FEED = false;
const bool SHOW_LOCAL_GRAPH = false;

class WikiUriPolicy implements UriPolicy {
  WikiUriPolicy();
  bool allowsUri(String uri) => true;
}

int endOfTheMonth(int month, int year) {
  switch (month) {
    case 1:
      return 31;
    case 2:
      return (year % 4 == 0) ? 29 : 28;
    case 3:
      return 31;
    case 4:
      return 30;
    case 5:
      return 31;
    case 6:
      return 30;
    case 7:
      return 31;
    case 8:
      return 31;
    case 9:
      return 30;
    case 10:
      return 31;
    case 11:
      return 30;
    case 12:
      return 31;
  }
  return 0;
}

int monthNumber(String month) {
  switch (month) {
    case 'January':
      return 1;
    case 'Februray':
      return 2;
    case 'March':
      return 3;
    case 'April':
      return 4;
    case 'May':
      return 5;
    case 'June':
      return 6;
    case 'July':
      return 7;
    case 'August':
      return 8;
    case 'September':
      return 9;
    case 'October':
      return 10;
    case 'November':
      return 11;
    case 'December':
      return 12;
  }
  return 0;
}

String electionTypeCode(String electionType) {
  switch (electionType) {
    case 'General Election':
    case 'Federal Election':
      return 'l';
    case 'Presidential Election':
      return 'p';
    case 'Mayoral Election':
      return 'm';
    default:
      return 'Error reading Election Type';
  }
}

lowercaseNoSpaces(String toFormat) => toFormat.toLowerCase().replaceAll(' ', '_');

selectCountryByCode(int code) {
  for (OptionElement e in document.getElementsByTagName('option')) {
    if (e.value == code.toString()) {
      e.selected = true;
      e.dispatchEvent(new CustomEvent("change"));
    }
  }
}