-- Personal collection of useful prompts
--
-- Sources of inspiration (Ok, I admit I just copied them verbatim for now):
--
-- - https://harper.blog/2025/02/16/my-llm-codegen-workflow-atm/

local mcphub = require("mcphub")

local SERVER_NAME = "clj_prompts"

local SYSTEM_PROMPT_ACADEMIC = [[
You are an AI research assistant named "ResearchMate". You are currently embedded in the user’s academic writing and reading environment.

Your core tasks include:

- Summarizing academic papers or excerpts.
- Expanding outline-style bullet points into clear, concise academic prose.
- Advising on structure, clarity, tone, and argumentation in academic documents (papers, reports, theses, etc.).
- Improving the readability of academic writing without adding jargon or overly stylized expressions.
- Rewriting text to meet academic standards of clarity, precision, and tone.
- Suggesting improvements to paragraphs or sections.
- Assisting with paraphrasing or rewording citations to avoid plagiarism.
- Identifying missing references or weak points in argumentation.
- Helping frame research questions or structure literature reviews.

You must:

- Follow the user's instructions exactly and interpret minimal prompts intelligently.
- Avoid excessive verbosity or embellishment. Use plain, formal academic English.
- Avoid common LLM markers such as overly hedged transitions, excessive synonyms, or unnatural turns of phrase.
- Rewrite text cleanly, keeping it aligned with the original intent.
- Never fabricate facts or citations.
- Use Markdown formatting when showing alternatives or comparisons.
- Be direct and impersonal in your tone unless the user explicitly requests otherwise.

When given a task:

- Begin by outlining your plan in pseudocode, step-by-step, in natural language unless the user opts out.
- Output the revised or generated text in a single Markdown block.
- Always suggest a few relevant next actions the user might want to take.
- Respond with exactly one message per turn.
]]

mcphub.add_prompt(SERVER_NAME, {
	name = "spec_brainstorm_init",
	description = [[Initiates an iterative brainstorming process to develop a detailed specification for an idea.
Provide your initial idea as an argument.]],
	arguments = {
		{
			name = "idea",
			description = "The initial idea to brainstorm for a specification.",
			type = "string",
			required = true,
		},
	},
	handler = function(req, res)
		return res:user()
			:text(
				string.format(
					"Ask me one question at a time so we can develop a thorough, \z
					 step-by-step spec for this idea. \z
					 Each question should build on my previous answers, \z
					 and our end goal is to have a detailed specification I can hand off to a developer. \z
					 Let’s do this iteratively and dig into every relevant detail. \z
					 Remember, only one question at a time. Here’s the idea:\n\z
					 \n\z
					 %s",
					req.params.idea
				)
			)
			:send()
	end,
})

mcphub.add_prompt(SERVER_NAME, {
	name = "spec_compile",
	description = "Compiles brainstormed findings into a comprehensive, \z
	developer-ready specification. \z
	This should be used after an 'Idea Honing' session.",
	handler = function(_, res)
		return res:user()
			:text(
				string.format(
					"Now that we’ve wrapped up the brainstorming process, \z
					 can you compile our findings into a comprehensive, \z
					 developer-ready specification? Include all relevant requirements, \z
					 architecture choices, data handling details, error handling strategies, \z
					 and a testing plan so a developer can immediately begin implementation."
				)
			)
			:send()
	end,
})

mcphub.add_prompt(SERVER_NAME, {
	name = "plan_blueprint_tdd",
	description = "Generates a detailed, step-by-step,\z
	TDD-focused blueprint for a project based on a provided specification.",
	arguments = {
		{
			name = "spec",
			description = "The comprehensive project specification.",
			type = "string",
			required = true,
		},
	},
	handler = function(req, res)
		return res:user()
			:text(
				string.format(
					"Draft a detailed, step-by-step blueprint for building this project. \z
					 Then, once you have a solid plan, break it down into small, iterative chunks that build on each other. \z
					 Look at these chunks and then go another round to break it into small steps. \z
					 Review the results and make sure that the steps are small enough to be implemented safely with strong testing, \z
					 but big enough to move the project forward. \z
					 Iterate until you feel that the steps are right sized for this project.\n\z
					 \n\z
					 From here you should have the foundation to provide a series of prompts for a \z
					 code-generation LLM that will implement each step in a test-driven manner. \z
					 Prioritize best practices, incremental progress, and early testing, \z
					 ensuring no big jumps in complexity at any stage. \z
					 Make sure that each prompt builds on the previous prompts, \z
					 and ends with wiring things together. There should be no hanging or orphaned \z
					 code that isn't integrated into a previous step.\n\z
					 \n\z
					 Make sure and separate each prompt section. \z
					 Use markdown. Each prompt should be tagged as text using code tags. \z
					 The goal is to output prompts, but context, etc is important as well.\n\z
					 \n\z
					 <SPEC>\n\z
					 %s\n\z
					 </SPEC>",
					req.params.spec
				)
			)
			:send()
	end,
})

mcphub.add_prompt(SERVER_NAME, {
	name = "plan_blueprint_nontdd",
	description = "Generates a detailed, step-by-step blueprint for a project \z
	based on a provided specification (non-TDD).",
	arguments = {
		{
			name = "spec",
			description = "The comprehensive project specification.",
			type = "string",
			required = true,
		},
	},
	handler = function(req, res)
		return res:user()
			:text(
				string.format(
					"Draft a detailed, step-by-step blueprint for building this project. \z
					 Then, once you have a solid plan, break it down into small, iterative chunks that build on each other. \z
					 Look at these chunks and then go another round to break it into small steps. \z
					 review the results and make sure that the steps are small enough to be implemented safely, \z
					 but big enough to move the project forward. \z
					 Iterate until you feel that the steps are right sized for this project.\n\z
					 \n\z
					 From here you should have the foundation to provide a series \z
					 of prompts for a code-generation LLM that will implement each step. \z
					 Prioritize best practices, and incremental progress, ensuring no big jumps in complexity at any stage. \z
					 Make sure that each prompt builds on the previous prompts, and ends with wiring things together. \z
					 There should be no hanging or orphaned code that isn't integrated into a previous step.\n\z
					 \n\z
					 Make sure and separate each prompt section. Use markdown. \z
					 Each prompt should be tagged as text using code tags. \z
					 The goal is to output prompts, but context, etc is important as well.\n\z
					 \n\z
					 <SPEC>\n\z
					 %s\n\z
					 </SPEC>",
					req.params.spec
				)
			)
			:send()
	end,
})

mcphub.add_prompt(SERVER_NAME, {
	name = "generate_todo_list",
	description = "Generates a comprehensive `todo.md` checklist based on the current context.",
	handler = function(_, res)
		return res:user()
			:text(
				string.format(
					"Can you make a `todo.md` that I can use as a checklist? Be thorough."
				)
			)
			:send()
	end,
})

mcphub.add_prompt(SERVER_NAME, {
	name = "summarize_conversation_into_notes",
	description = "Summarize conversation into notes",
	handler = function(_, res)
		return res:user()
			:text(
				string.format("Thanks for the conversation. I learnt a lot!\n\z
					 \n\z
					 I want you to take our whole conversation and based on this content \z
					 write some Markdown files that I can insert in my personal knowledge system.\n\z
					 \n\z
					 Avoid too long prose, don't bold too many words. \z
					 In particular, prefer Markdown sections over bolded text. \z
					 Do not use section heading within bullet points though.\n\z
					 For each file, start with the level 1 section heading and \z
					 fill the top-level section heading with the title.\n\z
					 \n\z
					 Feel free to add other content that we haven't discussed about, if you deem important.\n\z
					 \n\z
					 You should first try to organize the content of our conversation \z
					 (and other potential content you deem important) into a coherent and logical structure, \z
					 similar to how you would when writing a book. \z
					 Then fill the structure with content.\n\z
					 \n\z
					 Also, while you have freedom on how to structure the content \z
					 and what to include, please take into account our conversation. \z
					 Include my questions and a summary of the answer. \z
					 Include also my remarks (if case they are wrong, include your corrections). \z
					 The goal is to make the note more \"personal\". \z
					 Use markdown admonition for these special blocks \n\z
					 \n\z
					 ```markdown\n\z
					 > [!FAQ]\n\z
					 > Useful for questions and the corresponding answer.\n\z
					 \n\z
					 > [!TIP]\n\z
					 > Helpful advice for doing things better or more easily.\n\z
					 \n\z
					 > [!IMPORTANT]\n\z
					 > Key information users need to know to achieve their goal.\n\z
					 \n\z
					 > [!WARNING]\n\z
					 > Urgent info that needs immediate user attention to avoid problems.\n\z
					 \n\z
					 > [!CAUTION]\n\z
					 > Advises about risks or negative outcomes of certain actions.\n\z
					 ```")
			)
			:send()
	end,
})

mcphub.add_prompt(SERVER_NAME, {
	name = "improve_research_prose",
	description = "Improve research prose",
	handler = function(_, res)
		return res:system()
			:text(SYSTEM_PROMPT_ACADEMIC)
			:user()
			:text(
				string.format(
					"I have the following text that I want you to improve\n\z
					 \n\z
					 I want you to improve them and make them because fine prose. \z
					 Follow closely the same prose style used in:\n\z"
				)
			)
			:send()
	end,
})
