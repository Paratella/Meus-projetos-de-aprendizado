/** mermaid
 *  https://mermaidjs.github.io/
 *  (c) 2015 Knut Sveidqvist
 *  MIT license.
 */
%lex
%options case-insensitive
%x acc_title
%x acc_descr
%x acc_descr_multiline

%%

\%%(?!\{)[^\n]*                                                 /* skip comments */
[^\}]\%\%[^\n]*                                                 /* skip comments */
[\n]+                   return 'NEWLINE';
\s+                     /* skip whitespace */
\#[^\n]*                /* skip comments */

"journey"               return 'journey';
"title"\s[^#\n;]+       return 'title';
accTitle\s*":"\s*                                               { this.begin("acc_title");return 'acc_title'; }
<acc_title>(?!\n|;|#)*[^\n]*                                    { this.popState(); return "acc_title_value"; }
accDescr\s*":"\s*                                               { this.begin("acc_descr");return 'acc_descr'; }
<acc_descr>(?!\n|;|#)*[^\n]*                                    { this.popState(); return "acc_descr_value"; }
accDescr\s*"{"\s*                                { this.begin("acc_descr_multiline");}
<acc_descr_multiline>[\}]                       { this.popState(); }
<acc_descr_multiline>[^\}]*                     return "acc_descr_multiline_value";
"section"\s[^#:\n;]+    return 'section';
[^#:\n;]+               return 'taskName';
":"[^#\n;]+             return 'taskData';
":"                     return ':';
<<EOF>>                 return 'EOF';
.                       return 'INVALID';

/lex

%left '^'

%start start

%% /* language grammar */

start
	: journey document 'EOF' { return $2; }
	;

document
	: /* empty */ { $$ = [] }
	| document line {$1.push($2);$$ = $1}
	;

line
	: SPACE statement { $$ = $2 }
	| statement { $$ = $1 }
	| NEWLINE { $$=[];}
	| EOF { $$=[];}
	;

statement
  : title {yy.setDiagramTitle($1.substr(6));$$=$1.substr(6);}
  | acc_title acc_title_value  { $$=$2.trim();yy.setAccTitle($$); }
  | acc_descr acc_descr_value  { $$=$2.trim();yy.setAccDescription($$); }
  | acc_descr_multiline_value { $$=$1.trim();yy.setAccDescription($$); }
  | section {yy.addSection($1.substr(8));$$=$1.substr(8);}
  | taskName taskData {yy.addTask($1, $2);$$='task';}
  ;

%%
