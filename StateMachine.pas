unit MoninStateMachine;

interface

type
  TProcessState = (SInactive, SActive, SPaused, STerminated);
  TCommand = (CBegin, CEnd, CPause, CResume, CExit);

  TFSM = class
  type

{$REGION 'StateTransition'}
    TStateTransition =
      class { a class that holds each transitions state and command }
    private
      lccurrentstate: TProcessState;
      lccommand: TCommand;
    public
      constructor Create(currentstate: TProcessState; command: TCommand);
      property GetCurrentState: TProcessState read lccurrentstate;
      property GetCurrentCommand: TCommand read lccommand;
    end;
{$ENDREGION}
{$REGION 'Transistion Set'}

    TStateTransitionSet =
      class { a class that holds TStateTrasition and its resulting state }
    private
      lcmyStateTransition: TStateTransition;
      lcmyProcessState: TProcessState;
    public
      constructor Create(mycurrentState: TProcessState; command: TCommand;
        myStateTransition: TProcessState);
    end;
{$ENDREGION}

    TTransitions = array of TStateTransitionSet;
    { the list of all possible transitions }

  private
    lcprocesscurrentstate: TProcessState;
    lcCounter: Integer;
    transitions: TTransitions;
    function CompareStates(input, list: TStateTransition): boolean;
    function DoubleCheck(newTransition: TStateTransitionSet): boolean;
  public
    constructor Create(numOfTransitions: Integer; initialStage: TProcessState);
    destructor destroy;
    property GetCurrentState: TProcessState read lcprocesscurrentstate;
    function GetNext(command: TCommand): TProcessState;
    function MoveNext(command: TCommand): TProcessState;
    function AddTransition(activeState: TProcessState;
      transitionCommand: TCommand; desiredState: TProcessState): boolean;
  end;

implementation

uses
  System.SysUtils;

{$REGION 'TStateTransition'}

constructor TFSM.TStateTransition.Create(currentstate: TProcessState;
  command: TCommand);
begin
  lccurrentstate := currentstate;
  lccommand := command;
end;
{$ENDREGION}
{$REGION 'TFSM'}

function TFSM.AddTransition(activeState: TProcessState;
  transitionCommand: TCommand; desiredState: TProcessState): boolean;
begin
  result := false;
  if lcCounter > Length(transitions) - 1 then
  begin
    raise exception.Create('Too many events');
    // You are adding too many events
  end;

  if DoubleCheck(TStateTransitionSet.Create(activeState, transitionCommand,
    desiredState)) = true then
  begin
    raise exception.Create('Duplicates are not allowed');
    // Adding two or more exact equal transitions
  end;

  transitions[lcCounter] := TStateTransitionSet.Create(activeState,
    transitionCommand, desiredState);

  inc(lcCounter);
  result := true;
end;

function TFSM.DoubleCheck(newTransition: TStateTransitionSet): boolean;
var
  I: Integer;
begin
  result := false;
  for I := 0 to lcCounter do
  begin
    if Assigned(transitions[I]) then
    begin
      if (newTransition.lcmyStateTransition.lccurrentstate = transitions[I]
        .lcmyStateTransition.lccurrentstate) AND
        (newTransition.lcmyStateTransition.lccommand = transitions[I]
        .lcmyStateTransition.lccommand) AND
        (newTransition.lcmyProcessState = transitions[I].lcmyProcessState) then
      begin
        result := true;
        exit
      end;
    end;
  end;
end;

function TFSM.CompareStates(input, list: TStateTransition): boolean;
begin { checks if the desired command and current state exists in the list }
  result := false;
  if input.GetCurrentState = list.GetCurrentState then
  begin
    if input.GetCurrentCommand = list.GetCurrentCommand then
    begin
      result := true;
    end;
  end;
end;

constructor TFSM.Create(numOfTransitions: Integer; initialStage: TProcessState);
begin
  lcprocesscurrentstate := initialStage;
  setLength(transitions, numOfTransitions);
  lcCounter := 0;
end;

destructor TFSM.destroy;
var
  transition: TStateTransitionSet;
begin
  for transition in transitions do
  begin
    transition.lcmyStateTransition.free;
    transition.free;
  end;
end;

function TFSM.GetNext(command: TCommand): TProcessState;
var
  tmptransitionset: TStateTransitionSet;
  requestedState: TStateTransition;
begin
  // finds the next possible state, if invalid combination,
  // returns the current state
  result := lcprocesscurrentstate;
  requestedState := TStateTransition.Create(lcprocesscurrentstate, command);
  for tmptransitionset in transitions do
  begin
    if CompareStates(tmptransitionset.lcmyStateTransition, requestedState) = true
    then
    begin
      result := tmptransitionset.lcmyProcessState;
      requestedState.free;
      exit;
    end;
  end;
{$IFDEF DEBUG}
  raise exception.Create('Invalid state transition');
  // Change configuration from Debug to Release to avoid this exception
{$ENDIF}
end;

function TFSM.MoveNext(command: TCommand): TProcessState;
begin
  // sets the new current state
  lcprocesscurrentstate := GetNext(command);
  result := lcprocesscurrentstate;
end;
{$ENDREGION}
{$REGION 'TProcess.TStateTransitionSet'}

constructor TFSM.TStateTransitionSet.Create(mycurrentState: TProcessState;
  command: TCommand; myStateTransition: TProcessState);
begin
  lcmyStateTransition := TStateTransition.Create(mycurrentState, command);
  lcmyProcessState := myStateTransition;
end;
{$ENDREGION}

end.
