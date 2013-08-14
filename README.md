polymer_elements
================

This is a dart port of https://github.com/Polymer/polymer-elements.  

## broken/missing polymer.dart/dart features
- MutationObserver always throws an exception that the node doesn't exist in the current context
- Constructing CustomEvents with non-primitive types throws 'type conversion not supported'
- Custom event handling sugar (binding custom on-event to a handler)
- Observation handling sugar (if a variable 'target' is changed then the function 'targetChanged' is called)
- Support for binding dom elements by id
- Pointer events

## general polymer.dart/dart issues 
- dom seems to mess up types (changing var _selection in PolymerSelector to PolymerSelection results in a type error)
- different initialization/binding behavior 
- need for ObservableBox
- conditionally bound template instances don't seem to be anywhere in the dom

## notes
- polymer.js version passed the buck on the public/private api, so no clear precedent
- no criteria for choosing between a literal port or a more dart/polymer.dart port (e.g. using MutationObserver vs observe)
