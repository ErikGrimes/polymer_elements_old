library polymer_selector;

import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';

import 'dart:mirrors';

/**
 * This is a port of https://github.com/Polymer/polymer-elements/blob/stable/polymer-selector/polymer-selector.html
 * TODO support target attribute ($id syntax is not available in FancySyntax)
 * TODO fire polymer events (CustomEvent does not support arbitrary dart objects)
 * TODO note these issues in web-ui group
 * TODO figure out the public api (javascript doesn't have private methods)
 * TODO convert to ChangeNotifierMixin (otherwise it forces Observable.dirtyCheck everywhere)
 * TODO change _selection to PolymerSelection when the releveant dart bug is fixed
 */

@CustomTag('polymer-selector')
class PolymerSelector extends PolymerElement {
  
  //TODO polymer.js uses tap, but tap doesn't exist yet 
  
  @published
  String activateEvent = 'click';
  
  @published
  bool selectedIsAttribute = true;
  
  @published
  String itemsSelector = '';
  
  @published
  bool multi = false;
  
  @published
  bool notap = false;
  
  @published
  String selectedClass = 'polymer-selected';
  
  @published
  String selectedProperty = 'active';
  
  @published
  String valueattr = 'name';

  @published
  var selectedModel;
  
  @published
  var onPolymerSelect;
  
  @published
  var onPolymerActivate;
  
  @published
  Element target;
  
  @published
  var selected;
   
  @published
  Element selectedItem;
  
  //TODO using PolymerSelection here throws a type exception
  PolymerSelection _selection;
  
  StreamSubscription _selectedSub;
  
  inserted(){
    _selection = this.shadowRoot.query('#selection').xtag;
    
    if(this.target == null){
      this.target = this;
    }
    /**
     * TODO have to set this manually because of initialization issues with 
     * attribute binding
     */
    _selection.multi = multi;
  
    _validateSelected();
    
    Observable.dirtyCheck();
    
  }
  
  get selection => _selection.selection;
  
  //TODO revisit the polymer code - what does the where clause do?
  get items {
    List nodes;
    if(itemsSelector.isNotEmpty){
      nodes = target.queryAll(itemsSelector);
    } else {
      nodes = target.children;
    }
    return nodes.where((Element e){
      return e.localName != 'template';
    }).toList();     
  }
  
  clearSelection() {
    if (this.multi) {
      var copy = new List.from(this.selection);
      copy.forEach((s) {
        _selection.setItemSelected(s, false);
      });
    } else {
      this._selection.setItemSelected(this.selection, false);
    }
      this.selectedItem = null;
      this._selection.clear();
  }
  

  
  selectedChanged(old){ 
    _validateSelected();
    if (this.multi) {
      this.clearSelection();
      if(this.selected != null){
        this.selected.forEach((s) {
        this._valueToSelection(s);
        });
      } 
    } else {
      this._valueToSelection(this.selected);
    }
  }
  
  selectedItemChanged(old){
    if(this.selectedItem != null){
      var t = this.selectedItem.templateInstance;
      if(t != null){
        this.selectedModel = t.model;
      }
    } else {
      this.selectedModel = null;
    }
  }
  
  _validateSelected(){
    if(this.selected == null){
      if(this.multi){
        selected = new ObservableList();
      }else {
        selected = new ObservableBox();
      }
     } else if(selected is String){
      var values = selected.split(' ');
      if(this.multi){
        selected = new ObservableList.from(values);
      }else {
        selected = new ObservableBox(selected);   
      }
     }else if(selected is int){
       selected = new ObservableBox(selected.toString()); 
    } else if (selected is! ObservableBox && selected is! ObservableList){
      throw 'selected should be a literal String, literal String list, ObservableBox<String> or ObservableList<String>';
    }
    
    if(_selectedSub != null){
      _selectedSub.cancel();
    }
    _selectedSub = selected.changes.listen(_observableSelectedChanged);
    
  }
  
  _observableSelectedChanged(crs){
    selectedChanged(null);
  }
  
  _valueToSelection(value) {
    if(value is ObservableBox){
      value = value.value;
    }
    if(value is String && value.isEmpty) return;
    var item = (value == null) ? 
      null : this.items[this._valueToIndex(value)];
    this.selectedItem = item;
    this._selection.select(item);
  }
  
  _valueToIndex(value) {
    for (var i=0, items=this.items; i< items.length; i++) {
        if (this._valueForNode(items[i]) == value) {
        return i;
      }
    }
    // if no item found, the value itself is probably the index
    if(value is int){
      return value;
    }
    return int.parse(value);
  }
  
  _valueForNode(node) {
    return node.attributes[this.valueattr];
  }
  
  targetChanged(old) {
    if (old!= null) {
      this._removeListener(old);
    }

    if (this.target != null) {
      this._addListener(this.target);
    }
  }
  
  _addListener(Node node) {
    node.$dom_addEventListener(this.activateEvent,_activateHandler);
  }
  
  _removeListener(node) {
    node.$dom_RemoveEventListener(this.activateEvent,_activateHandler);
  }
  
// events fired from <polymer-selection> object
  _selectionSelect(detail) {
    if (detail.item != null) {
      this._applySelection(detail.item, detail.isSelected);
      if(onPolymerSelect != null){
        runAsync((){onPolymerSelect([detail]);});
      }
    }
  }
  
  _applySelection(item, isSelected) {
    if (this.selectedClass != null) {
      item.classes.toggle(this.selectedClass, isSelected);
    }
    if (this.selectedProperty != null) {
      if(selectedIsAttribute){
        item.attributes[this.selectedProperty] = isSelected.toString();
      }else {
        reflect(item).setField(const Symbol('checked'), isSelected);
      }
    }
  }
  
  _activateHandler(e) {
    if (!this.notap) {
      var i = this._findDistributedTarget(e.target, this.items);
      if (i >= 0) {
        var item = this.items[i];
        var s = _valueOrDefault(this._valueForNode(item),i.toString());
        if (this.multi) {
          this._addRemoveSelected(s);
        } else {
          this.selected.value = s.toString();
        }
        if(onPolymerActivate != null){
          runAsync((){onPolymerActivate([item]);});
        } 
      }
    }
  }
  
  _valueOrDefault(value, defaultValue){
    if(value != null){
    return value;
    }
    return defaultValue;
  }
  
  _addRemoveSelected(value) {
    var i = this.selected.indexOf(value);
    if (i >= 0) {
    this.selected.removeAt(i);
    } else {
    this.selected.add(value);
    }
    this._valueToSelection(value);
  }
  
  _findDistributedTarget(target, nodes) {
    // find first ancestor of target (including itself) that
    // is in nodes, if any
    var i = 0;
    while (target != null && target != this) {
    i = nodes.indexOf(target);
    if (i >= 0) {
      return i;
    }
    target = target.parentNode;
    }
  }
  
}