%%% -*- Mode: Prolog -*-
%%% Buser Daniele 894514

% Dynamic predicates
:- dynamic class/1.
:- dynamic instance/1.


% Define the structure of both fields and methods

% Field is a list of two or three elements: [Field_name, Field_value, _]
field_structure(Field_name, _) :-
    atom(Field_name).

field_structure(Field_name, Field_value, Field_type) :-
    atom(Field_name),
    atom(Field_type),

    % Check that Field_value and Field_type are compatible
    field_value_type_compatible(Field_value, Field_type).


% Method is a list of three elements: [Method_name, Arglist, Form]
method_structure(Method_name, Arglist, _) :-
    atom(Method_name),
    is_list(Arglist).


% def_class is a predicate to define a new class and add it to the
% database
def_class(Class_name, Parents) :-
    atom(Class_name),
    is_list(Parents),

    % Check that each parent is a defined class
    maplist(is_class, Parents),

    % Check if the class has already been defined
    not(is_class(Class_name)),

    % If you are trying to define a new class assert it
    assert(class([Class_name, Parents, []])).

def_class(Class_name, Parents, Parts) :-
    atom(Class_name),
    is_list(Parents),

    % Check that each parent is a defined class
    maplist(is_class, Parents),

    % Check if the class has already been defined
    not(is_class(Class_name)),

    % Check that each field in Parts has a type that is narrower or
    % equal to the type in the superclasses
    maplist(check_field_type_width_in_superclasses(Parents), Parts),

    % If you are trying to define a new class assert it
    assert(class([Class_name, Parents, Parts])),

    % Process each method in Parts adding it to the database
    forall(member(method(Method_name, Arglist, _), Parts),

	   % When processing a method use Class_name as a logic
	   % variable, it will be replace by the instance name later
	   process_method(Method_name, Class_name, Arglist)).


% is_class is a predicate to understand if a structure is a class
is_class(Class_name) :-
    atom(Class_name),
    class([Class_name, _, _]).


% make is a predicate to create a new instance of a class
make(Instance_name, Class_name) :-
    atom(Instance_name),
    is_class(Class_name),
    assert(instance([Instance_name, Class_name, []])).

make(Instance_name, Class_name, Fields) :-
    atom(Instance_name),
    is_class(Class_name),
    is_list(Fields),

    % Check that Field is a list of fields structured as
    % [Field_name = Field_Value]
    maplist(check_field_structure, Fields),

    % Check that each Field is defined in the instance class or in its
    % superclasses
    maplist(field_in_class_or_superclass(Class_name), Fields),

    % Associate the Instance_name with the new instance in the
    % database
    assert(instance([Instance_name, Class_name, Fields])).

make(Instance_name, Class_name, Fields) :-
    var(Instance_name),
    is_class(Class_name),
    is_list(Fields),

    % Check that Field is a list of fields structured as
    % [Field_name = Field_Value]
    maplist(check_field_structure, Fields),

    % Check that each Field is defined in the instance class or in its
    % superclasses
    maplist(field_in_class_or_superclass(Class_name), Fields),

    % Unify Instance_name with the new instance
    Instance_name = [_, Class_name, Fields].

make(Instance_name, Class_name, Fields) :-
    is_class(Class_name),
    is_list(Fields),

    % Check that Field is a list of fields structured as
    % [Field_name = Field_Value]
    maplist(check_field_structure, Fields),

    % Check that each Field is defined in the instance class or in its
    % superclasses
    maplist(field_in_class_or_superclass(Class_name), Fields),

    % Associate the Instance_name with the new instance in the
    % database
    Instance_name = [_, Class_name, Fields].


% is_instance is a predicate to understand if a structure is an
% instance
is_instance(Value) :-
    
    % is_instance succeeds if Value is an instance of any class
    instance([Value, _, _]).

is_instance(Value, Class_name) :-

    % is_instance succeeds if Value is an instance of the class
    % Class_name
    instance([Value, Instance_class, _]),
    Instance_class = Class_name.

is_instance(Value, Class_name) :-

    % is_instance succeeds if Value is an instance of a class which
    % has the class Class_name as a superclass
    instance([Value, Instance_class, _]),
    is_superclass(Instance_class, Class_name).


% inst is a predicate that retrieves an instance given the name with
% which it was created by make
inst(Instance_name, Instance) :-
    atom(Instance_name),
    instance([Instance_name, Class_name, Fields]),
    Instance = [Instance_name, Class_name, Fields].
inst(Instance_name, Instance) :-
    atom(Instance_name),
    instance([Instance_name, Subclass, Fields]),
    all_superclasses(Subclass, Superclasses),
    member(Class_name, Superclasses),
    Instance = [Instance_name, Class_name, Fields].


% field is a predicate that extract the value of a field from an
% instance if the field is  in the instance's Fields
field(Instance_name, Field_name, Result) :-
    atom(Instance_name),
    atom(Field_name),
    inst(Instance_name, [_, _, Fields]),
    member(Field_name = Result, Fields).

field(Instance_name, Field_name, Result) :-
    atom(Instance_name),
    atom(Field_name),
    inst(Instance_name, [_, Class_name, _]),
    class([Class_name, _, Parts]),

    % extract the value if field has a type
    member(field(Field_name, Result, _), Parts).

field(Instance_name, Field_name, Result) :-
    atom(Instance_name),
    atom(Field_name),
    inst(Instance_name, [_, Class_name, _]),
    class([Class_name, _, Parts]),

    % extract the value if the field has no type
    member(field(Field_name, Result), Parts).

field(Instance_name, Field_name, Result) :-
    atom(Instance_name),
    atom(Field_name),
    inst(Instance_name, [_, Class_name, _]),

    % extract from the superclasses
    all_superclasses(Class_name, Superclasses),
    member(Superclass, Superclasses),
    class([Superclass, _, Parts]),

    % extract the value if field has a type
    member(field(Field_name, Result, _), Parts).

field(Instance_name, Field_name, Result) :-
    atom(Instance_name),
    atom(Field_name),
    inst(Instance_name, [_, Class_name, _]),

    % extract from the superclasses
    all_superclasses(Class_name, Superclasses),
    member(Superclass, Superclasses),
    class([Superclass, _, Parts]),

    % extract the value if field has no type
    member(field(Field_name, Result), Parts).


% The fieldx predicate is used to retrieve the value of a nested field
% from an instance.
fieldx(Instance, [Field_name], Result) :-
    field(Instance, Field_name, Result).

fieldx(Instance, [First_field_name|Rest_field_names], Result) :-
    field(Instance, First_field_name, Intermediate_result),
    Intermediate_result =.. [_, Instance_name],
    fieldx(Instance_name, Rest_field_names, Result).


% USEFUL FUNCTIONS

% replace_this replaces all occurrences of "this" in a form with the
% instance name
replace_this(_, _, X, X) :- var(X), !.

replace_this(Old, New, Old, New) :- !.

replace_this(Old, New, Term1, Term2) :-
    compound(Term1),
    Term1 =.. [Functor|Args1],
    replace_this_list(Old, New, Args1, Args2),
    Term2 =.. [Functor|Args2].

replace_this(_, _, X, X).

replace_this_list(_, _, [], []).

replace_this_list(Old, New, [H1|T1], [H2|T2]) :-
    replace_this(Old, New, H1, H2),
    replace_this_list(Old, New, T1, T2).


% process_method is a predicate that dynamically create and assert a
% new predicate for a method
process_method(Method_name, Class_name, Arglist) :-
    Method =.. [Method_name, Instance_name | Arglist],
    assertz((Method :- 
		 inst(Instance_name, [_, Class_name, _]),
		 call_method(Method_name, Instance_name, Arglist))).


% call_method is a predicate used to call a method on an instance of a
call_method(Method_name, Instance_name, Arglist) :-
    inst(Instance_name, [_, Class_name, _]),
    class([Class_name, _, Parts]),
    member(method(Method_name, Arglist, Form), Parts),
    replace_this(this, Instance_name, Form, New_form),
    call(New_form).

% If the method is not found in the class, check in the superclasses
call_method(Method_name, Instance_name, Arglist) :-
    inst(Instance_name, [_, Class_name, _]),
    all_superclasses(Class_name, Superclasses),
    member(Superclass, Superclasses),
    class([Superclass, _, Parts]),
    member(method(Method_name, Arglist, Form), Parts),
    replace_this(this, Instance_name, Form, New_form),
    call(New_form).


% check_part is a predicate that check each part of Parts starts with
% field or method and then has a list of some element
check_part(field(Field_name, Field_value)) :-
    field_structure(Field_name, Field_value).

check_part(field(Field_name, Field_value, Field_type)) :-
    field_structure(Field_name, Field_value, Field_type).

check_part(method(Method_name, Arglist, Form)) :-
    method_structure(Method_name, Arglist, Form).


% check_field_structure is a predicate that check the field structure
% when creating an instance
check_field_structure(Field) :-
    Field =.. [=, Field_name, _],
    atom(Field_name).


% field_value_type_compatible is a predicate that check if the value
% of field is of the right type
field_value_type_compatible(Field_value, 'integer') :-
    integer(Field_value).

field_value_type_compatible(Field_value, 'atom') :-
    atom(Field_value).

field_value_type_compatible(Field_value, 'float') :-
    float(Field_value).

field_value_type_compatible(Field_value, 'string') :-
    string(Field_value).

field_value_type_compatible(Field_value, 'rational') :-
    rational(Field_value).

field_value_type_compatible(Field_value, 'number') :-
    number(Field_value).

field_value_type_compatible(Field_value, Class_name) :-
    is_class(Class_name),
    instance([Field_value, Class_name, _]).


% all_superclasses is a predicate that extract all the superclasses of
% a given class
all_superclasses(Class_name, Superclasses) :-
    class([Class_name, Parents, _]),
    Parents \= [], % Ensure Parents is not an empty list
    findall(Parent,
            member(Parent, Parents),
            Direct_superclasses),

    findall(Indirect_superclass,
            (member(Direct_superclass, Direct_superclasses),
             all_superclasses(Direct_superclass, Indirect_superclass)),
            Nested_Indirect_superclasses),

    flatten(Nested_Indirect_superclasses, Indirect_superclasses),

    append(Direct_superclasses, Indirect_superclasses, Superclasses).

all_superclasses(_, []).


% field_in_class_or_superclass is a predicate that check if a field is
% in the class or its superclasses
field_in_class_or_superclass(Class_name, Field) :-
    Field =.. [=, Field_name, Field_value],
    class([Class_name, _, Parts]),
    member(field(Field_name, _, Field_type), Parts),
    field_value_type_compatible(Field_value, Field_type).

field_in_class_or_superclass(Class_name, Field) :-
    Field =.. [=, Field_name, _],
    class([Class_name, _, Parts]),
    member(field(Field_name, _), Parts).

field_in_class_or_superclass(Class_name, Field) :-
    Field =.. [=, Field_name, Field_value],
    all_superclasses(Class_name, Superclasses),
    member(Superclass, Superclasses),
    class([Superclass, _, Parts]),
    member(field(Field_name, _, Field_type), Parts),
    field_value_type_compatible(Field_value, Field_type).

field_in_class_or_superclass(Class_name, Field) :-
    Field =.. [=, Field_name, _],
    all_superclasses(Class_name, Superclasses),
    member(Superclass, Superclasses),
    class([Superclass, _, Parts]),
    member(field(Field_name, _), Parts).


% is_superclass is a predicate to check if Superclass is actually a
% superclass of a class
is_superclass(Class, Superclass) :-
    class([Class, Parents, _]),
    member(Superclass, Parents).

is_superclass(Class, Superclass) :-
    class([Class, Parents, _]),
    member(Parent, Parents),
    is_superclass(Parent, Superclass).


% subtype is a predicate to establish type hierarchy
subtype('integer', 'rational').

subtype('rational', 'float').

subtype('integer', 'number').

subtype('rational', 'number').

subtype('float', 'number').

subtype(Class, Superclass) :-
    is_superclass(Superclass, Class).


% subtypep is a predicate similar to the Common Lisp one
subtypep(Type1, Type2) :-
    subtype(Type1, Type2).

subtypep(Type1, Type2) :-
    subtype(Type1, Intermediate),
    subtypep(Intermediate, Type2).


% check_field_type_width_in_superclasses is a predicate to check if a
% field type is narrower than the one in the superclasses
check_field_type_width_in_superclasses(Parents, Field) :-
    Field = field(_, _, _),
    maplist(check_field_type_width_in_superclass(Field), Parents).

check_field_type_width_in_superclasses(Parents, Field) :-
    Field = field(_, _),
    maplist(check_field_type_width_in_superclass(Field), Parents).

check_field_type_width_in_superclasses(_, Field) :-
    Field = method(_, _, _).

check_field_type_width_in_superclass(Field, Parent) :-
    all_superclasses(Parent, Superclasses),
    maplist(check_field_type_width(Field), Superclasses).

% If the field exists in the class and has a type, check if the type
%is narrower or equal
check_field_type_width(Field, Class_name) :-
    Field = field(Field_name, _, Field_type),
    class([Class_name, _, Parts]),
    member(field(Field_name, _, Class_field_type), Parts),
    subtypep(Field_type, Class_field_type).

% If the field does not exist in the class, it's a new field and the
%check passes
check_field_type_width(Field, Class_name) :-
    Field = field(Field_name, _, _),
    class([Class_name, _, Parts]),
    \+ member(field(Field_name, _, _), Parts).





%%%
