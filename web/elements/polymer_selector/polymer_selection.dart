library polymer_selection;

import 'dart:async';
import 'package:polymer/polymer.dart';

/**
 * This is a port of https://github.com/Polymer/polymer-elements/blob/stable/polymer-selector/polymer-selector.html
 * TODO fire polymer events (CustomEvent does not support arbitrary dart objects)
 * TODO figure out the public api (javascript doesn't have private methods)
 */

class PolymerSelectDetail {
  final bool isSelected;
  final Object item;
  PolymerSelectDetail(this.item, this.isSelected);
}


@CustomTag('polymer-selection')
class PolymerSelection extends PolymerElement with ChangeNotifierMixin {
  
  var onPolymerSelect;
  
  final List _selection = [];
  
  bool multi = false;
  
  get selection {
    if(this.multi){
       return this._selection;
    }else if(this._selection.isNotEmpty){
      return this._selection[0];
    }else {
      return null;
    }
  }

  isSelected(item){
    return this.selection.indexOf(item) >= 0;
  }
  

  setItemSelected(item, isSelected) {
    if (item != null) {
      if (isSelected) {
        this._selection.add(item);
      } else {
        var i = this._selection.indexOf(item);
        if (i >= 0) {
          this._selection.removeAt(i);
        }
      }
      if(onPolymerSelect != null){
        Timer.run((){onPolymerSelect([new PolymerSelectDetail(item, isSelected)]);});
      }
    }
  }
  
  select(item) {
    if (this.multi) {
      this.toggle(item);
    } else if (this.selection != item) {
      this.setItemSelected(this.selection, false);
      this.setItemSelected(item, true);
    }
  }
  
  toggle(item) {
    this.setItemSelected(item, !this.isSelected(item));
  }
 
  created(){
    this.clear();
  }
  
  clear(){
    this._selection.clear();
  }
  
}