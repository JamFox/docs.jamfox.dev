---
title: "Stable Diffusion"
---

!!! info
    [How to get images that don't suck](https://old.reddit.com/r/StableDiffusion/comments/x41n87/how_to_get_images_that_dont_suck_a/) by u/pxan |
    [Stable Diffusion Akashic Records](https://github.com/Maks-s/sd-akashic) |
    [Stable Diffusion Prompt Engineering (with examples on samplers)](https://docs.google.com/document/d/1O41qGvE69qnDoaqcdeokCObcRR_4yUUjRCmvPEVd2MU/edit)


Basic settings to get started:

- CFG (Classifier Free Guidance): 8
- Sampling Steps: 50
- Sampling Method: k_lms
- Random seed

## Checkpoints

### SD 1.5

Deliberate

### SD XL

sdxl-helloworld

## Modes

### img2img

CFG: Low = image based, High = prompt/desc based

Denoising (Try 0.50 and adjust from there):  Low = orig img based, High = more creative

Steps 30 and again then adjust from there.

I prefer using the DDIM method in many cases too. Seems to let me make more adjustments while keeping more of my original.

Test prompt in txt2img first and if it consistently gives something similar to the image I'm going to use in img2img that helps too.

img2img Style transfer ideas:

- run it through a different model with high CFG (12+) and low denoise (0.1-0.2)
- img2img, change the prompt a little bit, set the CFG to 10/15, use the same seed. Use the denoise from 0.05 to 0.3 max, try multiple times step by step (0.05/1/1.5/2/2.5/3)

## ControlNet

[Control net models](https://huggingface.co/lllyasviel/sd_control_collection)

Reddit suggestion: ip-adapter

Canny: diffusers_xl_canny_full

Copy pose from image: thibaud_xl_openpose

## Options

### Classifier Free Guidance (CFG)

- CFG 2 - 6: Let the AI take the wheel.
- CFG 7 - 11: Let's collaborate, AI!
- CFG 12 - 15: No, seriously, this is a good prompt. Just do what I say, AI.
- CFG 16 - 20: DO WHAT I SAY OR ELSE, AI.

### Samplers

#### DPM++ 2M SDE Karras

Slow, but good results. Steps 30, CFG 7-9

#### LMS: The Old Reliable

k_lms at 50 steps will give you fine generations most of the time if your prompt is good. k_lms runs pretty quick, so the results will come in at a good speed as well. You could easily just stick with this setting forever at CFG 7-8 and be ok. If things are coming out looking a little cursed, you could try a higher step value, like 80. But, as a rule of thumb, make sure your higher step value is actually getting you a benefit, and you're not just wasting your time. You can check this by holding your seed and other settings steady and varying your step count up and down. You might be shocked at what a low step count can do. I'm very skeptical of people who say their every generation is 150 steps.

#### DDIM: The Speed Demon

DDIM at 8 steps (yes, you read that right. 8 steps) can get you great results at a blazing fast speed. This is a wonderful setting for generating a lot of images quickly. When I'm testing new prompt ideas, I'll set DDIM to 8 steps and generate a batch of 4-9 images. This gives you a fantastic birds eye view of how your prompt does across multiple seeds. This is a terrific setting for rapid prompt modification. You can add one word to your prompt at DDIM:8 and see how it affects your output across seeds in less than 5 seconds (graphics card depending). For more complex prompts, DDIM might need more help. Feel free to go up to 15, 25, or even 35 if your output is still coming out looking garbled (or is the prompt the issue??). You'll eventually develop an eye for when increasing step count will help. Same rule as above applies, though. Don't waste your own time. Every once in a while make sure you need all those steps.

#### Euler a: The Chameleon

Everything that applies to DDIM applies here as well. This sampler is also lightning fast and also gets great results at extremely low step counts (steps 8-16). But it also changes generation style a lot more. Your generation at step count 15 might look very different than step count 16. And then they might BOTH look very different than step count 30. And then THAT might be very different than step count 65. This sampler is wild. It's also worth noting here in general: your results will look TOTALLY different depending on what sampler you use. So don't be afraid to experiment. If you have a result you already like a lot in k_euler_a, pop it into DDIM (or vice versa).

#### DPM2 a: The Starving Artist

In my opinion, this sampler might be the best one, but it has serious tradeoffs. It is VERY slow compared to the ones I went over above. However, for my money, k_dpm_2_a in the 30-80 step range is very very good. It's a bad sampler for experimentation, but if you already have a prompt you love dialed in, let it rip. Just be prepared to wait. And wait. If you're still at the stage where you're adding and removing terms from a prompt, though, you should stick to k_euler_a or DDIM at a lower step count.

### Sampling Steps

The AI model starts from random noise and then iteratively denoises the image until you get your final image. This modifier decides how many denoising steps it will go through. Default is 50, which is perfect for most scenarios. For reference, at around 10 steps you have generally a good idea of the composition and whether you will like that image or not, at around 20 it becomes very close to finished. If cfg_scale and sampler are at default settings, then the difference 20 steps and 150 (the maximum) is often times hard to tell. So if you want to increase the speed at which your images are generated try lowering the steps. Increasing steps also often adds finer detail and fixes artifacts (often but not always).

Steps: 

- Many problems that can be solved with a higher step count can also be solved with better prompting. If your subject's eyes are coming out terribly, try adding stuff to your prompt talking about their "symmetric highly detailed eyes, fantastic eyes, intricate eyes", etc. This isn't a silver bullet, though. Eyes, faces, and hands are difficult, non-trivial things to prompt to. Don't be discouraged. Keep experimenting, and don't be afraid to remove things from a prompt as well.

### Denoising

De-Noising is how close to the image you want it. Less is closer. Think of de-noising as de-constructing your image to be something else. The higher, the more it removes your image as a reference. Probably, not how it technically works, but it makes sense when explaining and trying for yourself.

### Seed

A good seed can enforce stuff like composition and color across a wide variety of prompts, samplers, and CFGs. Say you have a nice prompt that outputs a portrait shot of a "brunette" woman. You run this a few times and find a generation that you like. Grab that particular generation's seed to hold it steady and change the prompt to a "blonde" woman instead. The woman will be in an identical or very similar pose but now with blonde hair.

- Use DDIM:8-16 to go seed hunting with your prompt.
- If you're mainly looking for a fun prompt that gets consistently good results, seed is less important.
