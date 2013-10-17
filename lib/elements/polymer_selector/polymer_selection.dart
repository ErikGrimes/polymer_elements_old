library polymer_selection;

import 'dart:async';
import 'dart:mirrors';
import 'package:polymer/polymer.dart';

/**
 * This is a port of https://github.com/Polymer/polymer-elements/blob/stable/polymer-selector/polymer-selector.html
 * TODO fire polymer events (CustomEvent does not support arbitrary dart objects)
 * TODO figure out the public api (javascript doesn't have private methods)
 */
  
class PolymerSelectDetail {
  
  final bool isSelected;
  final item;
  
  PolymerSelectDetail(this.item, this.isSelected);
}


@CustomTag('polymer-selection')
class PolymerSelection extends PolymerElement {
  
  final List _selection = [];
  
  @published
  bool multi = false;
  
  @published
  var onPolymerSelect;
  
  get selection {
    if(this.multi){
     return this._selection;
    } else if(this._selection.isNotEmpty){
      return this._selection[0];
    } else {
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
      if(this.onPolymerSelect != null){
        runAsync((){this.onPolymerSelect([new PolymerSelectDetail(item, isSelected)]);});
      }    
    }
  }
  
  select(item) { 
    if (this.multi) {
      this._toggle(item);
    } else if (this.selection != item) {
      this.setItemSelected(this.selection, false);
      this.setItemSelected(item, true);
    }
  }
   
  created(){
    this.clear();
  }
  
  clear(){
    this._selection.clear();
  }
  
  _toggle(item) {
    this.setItemSelected(item, !this.isSelected(item));
  }
  
}