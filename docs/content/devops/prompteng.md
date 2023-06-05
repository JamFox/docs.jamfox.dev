---
title: "Prompt Engineering"
---

!!! info
    [LLM Bootcamp - Spring 2023](https://fullstackdeeplearning.com/llm-bootcamp/spring-2023/) |
    [Prompt Engineering Guide](https://github.com/dair-ai/Prompt-Engineering-Guide) |
    [Microsoft - Prompt engineering techniques](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/concepts/advanced-prompt-engineering) |
    [Jailbreak Chat](https://www.jailbreakchat.com/) |
    [LLM list with stats](https://docs.google.com/spreadsheets/d/1kT4or6b0Fedd-W_jMwYpb63e1ZR3aePczz3zlbJW-Y4/edit#gid=0)

From [ChatGPT Prompt Engineering for Developers](https://www.deeplearning.ai/short-courses/chatgpt-prompt-engineering-for-developers/)

# General tips for LLMs

- Leverage the system-assistant-user role approach. System role is to provide the context to all prompts and the assistant role is to perform the task, user role is you - the one asking the prompts. A system prompt could be something like telling the model to write in some particular style, this prompt can then be inserted into all other prompts for convenience.
- Different wording for the same prompts can lead to different results. Try to experiment with different wording and see what works best.

# Guidelines for Prompting

## Write clear and specific prompts

Remember clear and specific does not mean short. In fact longer prompts provide more context, usually leading to better results.

### Tactic 1: Use delimiters to clearly indicate distinct parts of the input

- Delimiters can be anything like: ```, """, < >, `<tag> </tag>`, `:`

Using delimiters makes it clear for the model what the input is and what the prompt is. 

As a side effect it clearly isolates the input from the prompt, making it harder to make prompt injections.

Example:

````
Summarize the text delimited by triple backticks into a single sentence.
```<TEXT>```
````

### Tactic 2: Ask for a structured output

Think ahead of time what format the output should be in and ask for it explicitly.

Instead of a regular text output, ask for a JSON output with specific keys.

### Tactic 3: Ask the model to check whether conditions are satisfied

If the prompt makes assumptions that aren't necessarily satisfied, then we can tell the model to check these assumptions first and then if they're not satisfied, indicate this and kind of stop short of a full task completion attempt. You might also consider potential edge cases and how the model should handle them to avoid unexpected errors or result.

Example:

````
You will be provided with text delimited by triple quotes. 
If it contains a sequence of instructions, re-write those instructions in the following format:
Step 1 - ...
Step 2 - …
…
Step N - …

If the text does not contain a sequence of instructions, then simply write "No steps provided."
````

### Tactic 4: "Few-shot" prompting

Few-shot prompting is just providing examples of successful executions of the task you want performed before asking the model to do the actual task you want it to do.

````
Your task is to answer in a consistent style.

<child>: Teach me about patience.

<grandparent>: The river that carves the deepest \ 
valley flows from a modest spring; the \ 
grandest symphony originates from a single note; \ 
the most intricate tapestry begins with a solitary thread.

<child>: Teach me about resilience.
````

## Give the model time to "think"

If a model is making reasoning errors by rushing to an incorrect conclusion, try reframing the query to request a chain or series of relevant reasoning before the model provides its final answer. Another way to think about this is that if you give a model a task that's too complex for it to do in a short amount of time or in a small number of words, it may make up a guess which is likely to be incorrect.

In these situations, you can instruct the model to think more about the problem and to provide more context for the model to make its final decision. It also means it will be spending more computational effort on the task. Or you can ask the model to provide a series of intermediate steps before it provides its final answer.

### Tactic 1: Specify the steps required to complete a task

First tactic is to give a step by step list of instructions for the model to follow.

Break down each step into smaller and smaller steps until the model can reach the correct final output.

### Tactic 2: Instruct the model to work out its own solution before rushing to a conclusion

Another tactic is to ask the model to work out its own solution before rushing to a conclusion. 

This is especially useful for checking output from other sources, like trying to grade the answers of a student. In these cases models usually rush to agreeing with the source, even if the source is wrong. Instructing the model to work out its own solution first and then compare it to the source can help avoid this.

# Summarizing

One of the strongest use cases for LLMs is summarization.

## Summarize with a word/sentence/character limit

LLMs can vary in the length of the output they produce. In some times they try to fit as much of the context as possible, other times they try to be too concise. 

Specifying a word/sentence/character limit can help the model produce the consistent desired output length.

Note: LLMs usually can't really count, so it might not follow the limit exactly, but it will usually be close enough and definitely helps.

## Summarize with a focus on a specific topic

At times we are summarizing a text with the purpose of getting something specific out of it. In these cases we can tell the model to focus on a specific topic.

## Try "extract" instead of "summarize"

To really nail down the last tip, you can try to extract it instead of summarizing it.

# Inferring

Inferring is when we perform some kind of deeper analysis on the input text. In addition to extracting clear information from the text, we can also infer information that is not explicitly stated in the text.

## Identify sentiment (positive/negative)

Ask the LLM to identify the sentiment of the input text. It can be positive, negative or neutral.

## Identify types of emotions

Ask the LLM to identify the types of emotions in the input text. It can be anything from anger, disgust, fear, joy, sadness, surprise or neutral. Ask for specifics.

## Extract key information

The text may not explicitly mention how key information relates to each other. For example a review of a product may mention the product name, price and manufacturer in different parts of the text. We can ask the LLM to infer the relationship between these key information.

# Transforming

LLMs are very good at transforming its input to a different format, such as inputting a piece of text in one language and transforming it or translating it to a different language, or helping with spelling and grammar corrections, so taking as input a piece of text that may not be fully grammatical and helping you to fix that up a bit, or even transforming formats such as inputting HTML and outputting JSON.

## Translation

LLMs are trained on a lot of text from kind of many sources, a lot of which is the internet, and this is kind of, of course, in many different languages. So this kind of imbues the model with the ability to do translation. And these models know kind of hundreds of languages to varying degrees of proficiency.

Note that how good the translation is depends on the data the model was trained on.

## Tone Transformation

You can ask the model to transform the tone of the text. From slang to formal, from formal to casual or to also include emotions.

## Format Conversion

LLMs can convert between different formats. For example, converting HTML to JSON to XML, etc.

## Spell/Grammar check

LLMs can help with spelling and grammar corrections and for the most part they do a very good job, but they're not perfect. So you should always double check the output.
