#!/usr/bin/env node

const fs = require("fs");

function escapeFormulaForAnkiMarkdown(formula) {
    /*
     * Escape every line break "//" in mathjax block
     */
    formula = formula.replace(/\\\\/g, `\\\\\\\\`);
    /*
     * Escape every unescaped '*' in mathjax block
     */
    formula = formula.replace(/\*/g, `\\*`);
    /*
     * Escape every unescaped '_' in mathjax block
     */
    formula = formula.replace(/_/g, `\\_`);
    /*
     * Escape delimiters "\{ \}" to "\\{ \\}" in mathjax block
     *
     * Handle also nested "\{ \}"
     */
    let deepestCurlyBracePairRegex = new RegExp(
        /(?<!\\)\\\{(.+?(?!\\\{))(?<!\\)\\\}/g
    );
    while (formula.match(deepestCurlyBracePairRegex)) {
        formula = formula.replace(deepestCurlyBracePairRegex, `\\\\\{$1\\\\\}`);
    }
    return formula;
}

function processInput(text, markdownEscape = false) {
    let blockFormulaRegex = new RegExp(/\$\$([^$]*)\$\$/gm);
    let inlineFormulaRegex = new RegExp(/(?<!\$)\$([^$]+)\$(?!\$)/g);

    if (markdownEscape) {
        let blockFormulas = text.match(blockFormulaRegex);
        let inlineFormulas = text.match(inlineFormulaRegex);

        /**
         * When calling String.prototype.replace(), use a replacer function
         * instead of passing a replacement string, which has special
         * characters with special semantics. I don't want to go through the
         * hassle of escaping them.
         */
        blockFormulas?.forEach((blockFormula) => {
            text = text.replace(blockFormula, () =>
                escapeFormulaForAnkiMarkdown(blockFormula)
            );
        });

        inlineFormulas?.forEach((inlineFormula) => {
            text = text.replace(inlineFormula, () =>
                escapeFormulaForAnkiMarkdown(inlineFormula)
            );
        });
    }

    const delimiter = markdownEscape ? "\\\\" : "\\";
    /*
     * replace "$$ formula $$" with "\[ formula \]" or "\\[ formula \\]" depending on
     * whether using anki's  markdown transformer
     */
    text = text.replace(blockFormulaRegex, `${delimiter}[$1${delimiter}]`);
    /*
     * replace "$ formula $" with "\( formula \)" or "\\( formula \\)"
     * depending on whether using anki's  markdown transformer
     */
    text = text.replace(inlineFormulaRegex, `${delimiter}($1${delimiter})`);

    // output the processed input
    console.log(text);
}

fs.readFile(0, { encoding: "utf-8" }, (err, data) => {
    if (err) throw err;
    const args = process.argv.slice(2);
    if (args.length === 1 && args[0] === "--markdown-escape") {
        processInput(data, true);
    } else {
        processInput(data);
    }
});
