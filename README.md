
![example Image](https://i.stack.imgur.com/IAXY4.gif)

Declare a var
```delphi
myFSM : TFSM
```
Declare type of your states and commands
```delphi
TProcessState = (SInactive, SActive, SPaused, STerminated);
TCommand = (CBegin, CEnd, CPause, CResume, CExit);
```
Define how many transitions and which starting state
```delphi
myFSM := TFSM.Create(6, SInactive);
```
Add new  Transitions with
```delphi
myFSM.AddTransition(SInactive, CExit, STerminated);
myFSM.AddTransition(SInactive, CBegin, SActive);

myFSM.AddTransition(SActive, CEnd, SInactive);
myFSM.AddTransition(SActive, CPause, SPaused);

myFSM.AddTransition(SPaused, CEnd, SInactive);
myFSM.AddTransition(SPaused, CResume, SActive);
```
How to change state, simple use MoveNext function and provide one of the TCommands
```delphi
myFSM.MoveNext(CBegin);
```
