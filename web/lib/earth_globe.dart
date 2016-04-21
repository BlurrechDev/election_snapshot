import 'dart:html' as html;
import 'dart:js' as js;
import 'package:d3/selection/selection.dart';
import 'package:polymer/polymer.dart';

@CustomTag('earth-globe')
class EarthGlobe extends PolymerElement {

  EarthGlobe.created() : super.created() {
    js.context.callMethod('loadEarth'); 
//    var projection = js.context['d3']['geo'].callMethod('orthographic').callMethod('scale', ['300']).callMethod('rotate',  [['0', '0']])
//      .callMethod('translate', [[(width/2).toString(), (height/2).toString()]]).callMethod('clipAngle', ['90']);
//    
//    js.context['d3']['geo'].callMethod('path').callMethod('projection', [projection]);
//    print(path);
//    js.context['d3'].callMethod('select', [shadowRoot.querySelector('#svg')])
//      .callMethod('attr', ['height', height.toString()])
//      .callMethod('attr', ['width', width.toString()])
//      .callMethod('append', ['path'])
//      .callMethod('datum', [{"type" : "Sphere"}])
//      .callMethod('attr', ['class', 'water'])
//      .callMethod('attr', ['d', path]);
  }
}
