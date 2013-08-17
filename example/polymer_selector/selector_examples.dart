library selector_examples;

import 'dart:html';
import 'package:polymer_elements/elements/polymer_selector/polymer_selector.dart';
import 'package:polymer/polymer.dart';

@CustomTag('selector-examples')
class SelectorExamples extends PolymerElement with ObservableMixin {
  
  ObservableBox observableString = new ObservableBox('2');
  
  ObservableList multiSelected = new ObservableList.from(['1', '3']);
  
  ObservableBox color = new ObservableBox('green');
  
  ObservableBox emptyObservableString = new ObservableBox("");
  
  ObservableList emptyList = new ObservableList();
 
  @observable
  String latestActivate;
  
  @observable
  //TODO have to use var or get a type error
  var latestSelect;
  
  activate(item){
  latestActivate = item.attributes['value'];
  Observable.dirtyCheck();
  }
  
  select(item){
  latestSelect = item;
  Observable.dirtyCheck();
  }
  
  created(){
  super.created();
  }
  
}