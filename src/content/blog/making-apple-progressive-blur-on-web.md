---
title: Making Apple Progressive Blur on the Web
image: /images/blur-blog.png
description: Developing Apple-inspired progressive blur for the web; Technical insights and challenges.
excerpt: Technical insights and challenges of implementing progressive blur for your browser.
pubDate: 'Apr 5 2024'
---
Throughout the years, apple consistently delivers great design. They seem to always define (or at least popularize) a new trend, which then storms the world and everyone copies it. One of the trends, they seem to have doubled down on lately, is progressive blur. Some examples can be seen in the app store, maps, and, most recently, the apple vision OS. Seeing all that made me want to see whether it could also be done for the web (aka for the rest of the world not using swiftUI).

![Examples of Apple Blur](/blog/making-apple-progressive-blur-on-web/apple-blur.png)

*Examples of apple usages of progressive blur*

The idea came to me when I was redesigning my blog (the one you are reading right now). I'd wanted to make the header blurred, but the currently most popular solution - throw a single blur + solid color with opacity turned slightly down at it and call it a day, was just too boring. I wanted to be like apple. I wanted progressive blur.

## Gradient Blur Since 2009
Progressive blur isn't anything new. I've found mentions of it under the name of 'gradient blur' on <a class="external" href="https://community.adobe.com/t5/photoshop-ecosystem-discussions/how-can-i-create-a-gradient-blur/td-p/1554916" target="_blank">photoshop forums dated to 2009</a>, or more recently a <a class="external" href="https://stackoverflow.com/questions/45381849/how-to-achieve-a-progressive-blur-using-svg-by-combining-a-filter-with-a-mask" target="_blank">stackoverflow question from 2017</a>, and a <a class="external" href="https://support.apple.com/sk-sk/guide/motion/motn169fcc4b/5.4.4/mac/10.14" target="_blank">motion guide page from 2019</a>. What I couldn't find was usages of the progressive blur for the web or any easily usable HTML + css generator for it.

My original solution, for this blog, was based on <a class="external" href="https://codepen.io/silas/pen/rNYqZoz" target="_blank">this codepen</a>. The way it works is by stacking multiple divs with different backdrop filters and gradient masks on top of one other, each blurring the background more and more. It is a great single-use solution and, with some fine-tuning, it produced the desired effect. I wanted more though. I wanted it to be usable for any element, without too much fine-tuning (or at least without fine-tuning it directly inside css).

## The Blur Is Not Enough
At this point you may be asking: Why go through all the trouble of stacking blurs? Why not just use a single blur with a single mask? Well. <a class="external" href="https://www.purplesquirrels.com.au/2023/11/blur-gradient-with-css/" target="_blank">Here is an example</a> of what the effect looks like using only a single blur. The blurred part looks like bloom, the transition from blurred to non-blurred is almost invisible, and if you use a white color for the text (such as apple uses), the readability of the text drops rapidly, mainly due to the high frequency (rapid transitions between colors) of the background.

![image.png](/blog/making-apple-progressive-blur-on-web/image_11.png)

This is exactly what the progressive blur solves - more blur = lower frequency of the background = better readability of the text. Ok, so we can just blur it more and be done with it, right? Not really. Below is the same example with the blur set to `32px`, instead of the original `10px`. Now the blur is almost gone, and the image just looks a bit hazy. Essentially, we have blurred it too much and have largely lost the effect we were trying to achieve.

![image.png](/blog/making-apple-progressive-blur-on-web/image_7.png)
*Too high blur radius*

## Stacking Blurs
My learnings so far were:
1. the stacking is definitely needed
2. doing it manually every time is not viable


Only one possible conclusion could have come out of this: I need to make a progressive blur editor with a HTML + css generator.

### Using Backdrop Filter
My first step was to take the "static" blur and make the parameters editable in a simple and visual way. I have put together a simple site with some images (to thoroughly test the feel) and some sliders to fine-tune the blur. Internally, there were just multiple `divs` spawning on top of the image, each having its own backdrop filter with increasing blur radius, and a mask, using a linear gradient with alpha values.

![image.png](/blog/making-apple-progressive-blur-on-web/image_4.png)
*The initial design using backdrop filter*

This has worked surprisingly well - it has produced the desired results and is not that heavy on the performance (not that I've measured anything, it just feels ok). It has just one tiny little problem. The moment we increase the `border-radius` of the wrapping element (while using the cutting-edge browser built by google), this happens:

![image.png](/blog/making-apple-progressive-blur-on-web/image_10.png)
*The result on chrome*

It seems that ~~modern css~~ chromium just can't deal with multiple stacked backdrop filters, masks, and `overflow: hidden` on the wrapping element. Not entirely sure why, but <a class="external" href="https://stackoverflow.com/a/73156812" target="_blank">one answer on stackoverflow</a> gives us some hints. It also made me try it on safari and firefox, both of which, much to my surprise, could have the border radius and progressive blur on at the same time. Chrome is unfortunately the most used browser, so we primarily needed a working solution for that one.

![image.png](/blog/making-apple-progressive-blur-on-web/image_8.png)
*The result on safari and firefox*

### Blurring Multiple Images On Top Of Each Other
The second solution, which enables us to have border radius even in chrome, is heavyweight (again, no measurements, but the page starts to be laggy sometimes, which is a pretty good indication for me), non-optimal, and just plainly shouldn't be used anywhere on the web. You have been warned.

![blur-layers.png](/blog/making-apple-progressive-blur-on-web/blur-layers.png)
*The stacked blur layers*

This approach achieves the progressive blur by stacking multiple divs with background image set to the original photo, and then applies blur + mask. Since it doesn't use backdrop filter, there are no shenanigans with the `border-radius` , which just works. The issue is that it spawns multiple images (that are the size of the original image) with large blur radii (sometimes even `512px`), on top of which it does some more operations, like masking. Below is the comparison of the two approaches - backdrop-filter on the left, blur on the right.

![Frame 89.png](/blog/making-apple-progressive-blur-on-web/Frame_89.png)

They look pretty much the same, except for this part:
![image 1729.png](/blog/making-apple-progressive-blur-on-web/image_1729.png)

This artefact comes from using the blur, which doesn't reach the edges (as there is no padding for the filter, it is just blurring it with the radius of `512px` and not reaching the edge). To deal with this, I have scaled the image up by the factor of `1.2`. No special reason to use 1.2, it just worked for most of the cases, while not cutting off too much of the image. It is still a tradeoff, but if we are using the progressively blurred image as a card, we can afford our image to be cut off. Below is the comparison with the scaled image using blurs:

![Frame 891.png](/blog/making-apple-progressive-blur-on-web/Frame_891_1.png)

Another possible approach would be just to scale the blur. this way it would reach the bottom, still blur the image in the correct parts, and the original image could stay the same. Well, not exactly. It won't work in our case as the blurred image and the background image must precisely match. The blurred image is just the background image with alpha mask, meaning that at one point it will be trying to blend in with the original image, and any scale or position difference will be noticeable. See for yourself in the images below. On the left, only the blur is scaled, on the right both the blur and the image are scaled.

![Frame 90.png](/blog/making-apple-progressive-blur-on-web/Frame_90.png)

## The Generator
The generator itself is simple. It takes the parameters input through the sliders, does some calculations for the alpha gradients of the masks, blur amounts, and the actual inserted divs with blur, and then displays the image with its blurry overlays. It then takes the parameters and generates the code you can copy to your website.

You can play with it here: <a class="external" href="https://www.posterramen.com/progressive-blur" target="_blank">posterramen.com/progressive-blur</a>

You can see <a class="external" href="https://github.com/petttr1/PosterRamen/tree/main/components/progressive-blur" target="_blank">the source code here</a>.