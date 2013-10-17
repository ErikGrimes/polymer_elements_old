library selector_examples;

import 'package:polymer/polymer.dart';

@CustomTag('selector-examples')
class SelectorExamples extends PolymerElement with ObservableMixin {
  
  ObservableBox observableString = new ObservableBox('2');
  
  ObservableList multiSelected = new ObservableList.from(['1', '3']);
  
  ObservableBox color = new ObservableBox('green');
  
  ObservableBox emptyObservableString = new ObservableBox("");
  
  ObservableList emptyList = new ObservableList();
  
  ObservableBox checkboxColor = new ObservableBox('green');
  
  ObservableList checkboxMulti = new ObservableList.from(['red', 'green']);
 
  @published
  String latestActivate;
  
  @published
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