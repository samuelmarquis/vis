-- Copyright 2026 Samuel Marquis. See LICENSE.
-- Rocq (Coq) LPeg lexer.

local lexer = lexer
local P, S = lpeg.P, lpeg.S

local lex = lexer.new(...)

-- Strings. Rocq strings escape the double quote by doubling it; backslash
-- is an ordinary character.
local dq_str = P('"') * (P('""') + (1 - P('"')))^0 * P('"')^-1
lex:add_rule('string', lex:tag(lexer.STRING, dq_str))

-- Comments (nested, as in OCaml).
lex:add_rule('comment', lex:tag(lexer.COMMENT, lexer.range('(*', '*)', false, false, true)))

-- Attributes, e.g. #[local], #[export, universes(polymorphic)].
lex:add_rule('attribute', lex:tag(lexer.PREPROCESSOR, lexer.range('#[', ']')))

-- Proof holes ("this should not stick around"): Admitted/Abort proofs and
-- the admit/give_up tactics get their own 'admitted' tag. Styled via
-- lexers.STYLE_ADMITTED — define it in a theme or plugin (lexer files run
-- in a read-only environment and cannot set module styles themselves);
-- vis-rocq installs a loud back:#ff0000,fore:#ffffff,bold default.
lex:add_rule('admitted', lex:tag('admitted', lex:word_match('admitted')))

-- Keywords: Gallina terms, proof delimiters and the vernacular.
lex:add_rule('keyword', lex:tag(lexer.KEYWORD, lex:word_match(lexer.KEYWORD)))

-- Sorts and pervasive types.
lex:add_rule('type', lex:tag(lexer.TYPE, lex:word_match(lexer.TYPE)))

-- Tactics and tacticals.
lex:add_rule('function', lex:tag(lexer.FUNCTION, lex:word_match(lexer.FUNCTION)))

-- Pervasive constructors.
lex:add_rule('constant', lex:tag(lexer.CONSTANT, lex:word_match(lexer.CONSTANT)))

-- Identifiers.
local word = (lexer.alpha + '_') * (lexer.alnum + S("_'"))^0
lex:add_rule('identifier', lex:tag(lexer.IDENTIFIER, word))

-- Numbers.
lex:add_rule('number', lex:tag(lexer.NUMBER, lexer.number))

-- Operators, including the common unicode notations.
local uni_op = P('∀') + P('∃') + P('→') + P('←') + P('↔') + P('⇒') + P('⇔') +
	P('∧') + P('∨') + P('¬') + P('≠') + P('≤') + P('≥') + P('λ') + P('∘') +
	P('×') + P('⊢') + P('⊤') + P('⊥') + P('∈') + P('∉') + P('⊆') + P('∪') +
	P('∩') + P('∖')
lex:add_rule('operator', lex:tag(lexer.OPERATOR, uni_op + S('=<>+-*/^~:;,.!?@&|_%#()[]{}')))

lexer.property['scintillua.comment'] = '(*|*)'

lex:set_word_list('admitted', {
	'Admitted', 'Abort', 'Admit', -- vernacular (Admit as in Admit Obligations)
	'admit', 'give_up',           -- tactics
})

lex:set_word_list(lexer.KEYWORD, {
	-- Gallina --
	'forall', 'exists', 'exists2', 'fun', 'fix', 'cofix', 'struct', 'match',
	'with', 'end', 'if', 'then', 'else', 'let', 'in', 'as', 'return', 'where',
	'at', 'measure', 'wf',
	-- proof structure --
	'Proof', 'Qed', 'Defined', 'Save',
	-- vernacular --
	'Theorem', 'Lemma', 'Fact', 'Remark', 'Corollary', 'Proposition',
	'Property', 'Example', 'Goal', 'Definition', 'Fixpoint', 'CoFixpoint',
	'Inductive', 'CoInductive', 'Variant', 'Record', 'Structure', 'Class',
	'Instance', 'Existing', 'Canonical', 'Coercion', 'Let',
	'Module', 'Section', 'End', 'Include', 'Import', 'Export', 'Require',
	'From', 'Load',
	'Variable', 'Variables', 'Hypothesis', 'Hypotheses', 'Axiom', 'Axioms',
	'Parameter', 'Parameters', 'Conjecture', 'Context', 'Implicit',
	'Arguments', 'Generalizable',
	'Notation', 'Infix', 'Reserved', 'Tactic', 'Ltac', 'Ltac2',
	'Unset', 'Local', 'Global', 'Opaque', 'Transparent', 'Strategy',
	'Hint', 'Resolve', 'Constructors', 'Extern', 'Immediate', 'Unfold',
	'Rewrite', 'Create', 'HintDb',
	'Print', 'Check', 'Eval', 'Compute', 'Search', 'About', 'Locate', 'Show',
	'Undo', 'Restart', 'Fail', 'Succeed', 'Guarded', 'Validate',
	'Scheme', 'Derive', 'Combined', 'Equations', 'Function', 'Functional',
	'Program', 'Obligation', 'Obligations', 'Next', 'Solve',
	'Declare', 'Custom', 'Entry', 'Bind', 'Delimit', 'Open', 'Close', 'Scope',
	'Universe', 'Universes', 'Constraint', 'Polymorphic', 'Monomorphic',
	'Cumulative', 'NonCumulative', 'Primitive', 'Register', 'Inline',
	'Extraction', 'Extract', 'Recursive', 'Separate', 'Language',
	'Time', 'Timeout', 'Redirect', 'Reset', 'Back', 'BackTo', 'Quit', 'Drop',
	-- ssreflect / mathcomp vernacular --
	'Prenex', 'Implicits', 'Types', 'View', 'HB',
})

lex:set_word_list(lexer.TYPE, {
	-- sorts --
	'Prop', 'SProp', 'Set', 'Type',
	-- pervasive types --
	'nat', 'bool', 'option', 'list', 'unit', 'sum', 'prod', 'sig', 'sigT',
	'sumbool', 'sumor', 'comparison', 'positive', 'N', 'Z', 'Q', 'R',
	'string', 'ascii', 'byte', 'int', 'float', 'Empty_set',
	-- ssreflect / mathcomp --
	'seq', 'pred', 'rel', 'eqType', 'choiceType', 'countType', 'finType',
	'subType', 'ordinal',
	-- mathcomp order hierarchy --
	'porderType', 'latticeType', 'bLatticeType', 'tbLatticeType',
	'distrLatticeType', 'orderType', 'finPOrderType', 'finLatticeType',
	'finDistrLatticeType', 'finOrderType',
})

lex:set_word_list(lexer.FUNCTION, {
	-- tactics --
	'intro', 'intros', 'revert', 'clear', 'clearbody', 'rename', 'move',
	'apply', 'eapply', 'exact', 'eexact', 'assumption', 'eassumption',
	'refine', 'trivial', 'easy', 'now',
	'reflexivity', 'symmetry', 'transitivity', 'etransitivity', 'f_equal',
	'rewrite', 'erewrite', 'subst', 'replace', 'change', 'remember', 'set',
	'pose', 'assert', 'enough', 'cut', 'specialize', 'generalize',
	'simpl', 'cbn', 'cbv', 'lazy', 'hnf', 'red', 'unfold', 'fold', 'pattern',
	'vm_compute', 'native_compute', 'compute',
	'destruct', 'edestruct', 'induction', 'einduction', 'case', 'ecase',
	'elim', 'eelim', 'case_eq', 'dependent', 'inversion', 'injection',
	'discriminate', 'contradiction', 'contradict', 'exfalso', 'absurd',
	'split', 'esplit', 'left', 'eleft', 'right', 'eright', 'constructor',
	'econstructor', 'eexists',
	'auto', 'eauto', 'autorewrite', 'autounfold', 'congruence', 'lia', 'nia',
	'zify', 'ring', 'ring_simplify', 'field', 'field_simplify', 'fourier',
	'tauto', 'intuition', 'firstorder', 'decide', 'equality', 'btauto',
	'typeclasses', 'debug',
	'shelve', 'unshelve', 'instantiate', 'cycle', 'swap',
	'abstract', 'transparent_abstract',
	-- tacticals --
	'try', 'repeat', 'do', 'once', 'progress', 'first', 'solve', 'all',
	'idtac', 'fail', 'gfail', 'guard', 'timeout', 'time', 'assert_fails',
	'assert_succeeds', 'by', 'exactly_once', 'only',
	-- ssreflect --
	'have', 'suff', 'suffices', 'wlog', 'gen', 'congr', 'under', 'over',
	'unlock', 'done', 'last',
})

lex:set_word_list(lexer.CONSTANT, {
	'True', 'False', 'true', 'false', 'tt', 'I', 'O', 'S', 'None', 'Some',
	'nil', 'cons', 'pair', 'inl', 'inr', 'eq_refl', 'or_introl', 'or_intror',
	'conj', 'ex_intro', 'exist',
	-- ssreflect --
	'erefl', 'isT', 'Ordinal',
})

return lex
