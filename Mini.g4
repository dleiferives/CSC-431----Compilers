grammar Mini;


// build down from program
program: types declarations functions EOF;


type: 'int' | 'bool' | 'struct' ID;
return_type: type | 'void';

// from the type comes paramaters -> structs or something else
decl: type ID;
nested_decl: decl ';' (decl ';')*;
type_declaration: 'struct' ID '{' nested_decl '}' ';';
parameters: '(' (decl (',' decl)* )? ')';

types: (type_declaration)*;

// second is the actual code stuff
id_list: ID (',' ID )*;
declaration: type id_list ';';
declarations: (declaration)*;

// now to build down from the function
function: 'fun' ID parameters return_type '{' declarations statement_list '}';
statement_list: (statement)*;
statement: block | assignment | print | conditional | loop | delete | ret | invocation;
block: '{' statement_list '}';
assignment: lvalue '=' (expression | 'read');
print: 'print' expression ('endl')?;
conditional: 'if' '(' expression ')' block ('else' block)?;
loop: 'while' '(' expression ')' block;
delete: 'delete' expression;
ret: 'return' (expression)?;
invocation: ID arguments;

// now to build expression down
expression: boolterm ('||' boolterm)*;
boolterm: eqterm ('&&' eqterm)*;
eqterm: relterm (('==' | '!=') relterm)*;
relterm: simple (('<' | '>' | '<=' | '>=') simple)*;
simple: term (('+' | '-') term)*;
term: unary (('*' | '/') unary);
unary: ('!' | '-')* selector;
selector: factor ('.' ID)*;
factor:'(' expression ')' | ID (arguments)? | INT | 'true' | 'false' | 'new' ID | 'null';

// now we can just make arguments
arguments: '(' (expression (',' expression)* )? ')';

functions: (function)*;
lvalue: ID ('.' ID)*;





ID: [a-zA-Z][a-zA-Z0-9]*;
INT: [0-9][0-9]*;  // leading zeros are allowed now, maybe ask about that, the grammar defines it this way
WS: [ \t\n\r\f]+ -> skip;
COMMENT: '#' .*? '\n'; 
