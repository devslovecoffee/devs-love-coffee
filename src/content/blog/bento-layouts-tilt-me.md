---
title: Bento Layouts Tilt Me
published: true
image: /images/bento-og.png
description: A short post about making a bento layout tilt toward the pointer using HTML, javascript and css.
excerpt: A short write-up of how to make cursor-facing, tilted tiles in a bento grid.
pubDate: 'Sep 04 2023'
---

I was recently playing around with bento layouts (if you don't know what Bento layout / grid is, it's the new trend all the <a class="external" href="https://bentogrids.com" target="_blank">cool kids</a> are doing, <a class="external" href="https://www.webdesignerdepot.com/2023/07/what-is-the-bento-ui-trend-and-how-can-you-get-started" target="_blank">catch up</a>) and actually automating it a little - basically using grid-auto-flow on grid layout. Then I got an idea: "Could I make the tiles tilt towards the mouse?" Why? - Why not? Let's do it.

Bento layouts actually don't tilt me, sorry. I just wanted to use this awesome clickbait opportunity for what I've made. This is a semi-demo, semi-tutorial, short post about how to do it.

## Making a single tile tilt

Tilting a single tile is actually pretty simple and a really nice person - some Armando Canals, <a class="external" href="https://armandocanals.com/posts/CSS-transform-rotating-a-3D-object-perspective-based-on-mouse-position.html" target="_blank">already did that</a>.

All I needed to do was scale it by adding multiple tiles, inside a grid layout. The code is here, with the relevant parts described in the comments:

<iframe loading="lazy" title="The bento layout with tiles tilting towards the cursor" src="/assets/index-basic.html" height="500px" width="100%" style="border:none;"></iframe>
<figcaption align = "center">Bento layout with tiles tilting toward the cursor</figcaption>

```html


<style>
    body {
        background: #302c31;
    }
    .container {
        height: 100%;
        width: 100%;
        /* Make it a grid */
        display: grid;

        /* 8 columns and 4 rows */
        grid-template-columns: repeat(8, 100px);
        grid-template-rows: repeat(4, 100px);

        /* Make the layout dense = fill out any "holes" and leave uncompleted rows if necessary */
        /* Try commenting the dense option out to see the difference */
        grid-auto-flow: dense;

        align-content: center;
        justify-content: center;
        gap: 8px;
    }

    .box {
        background: white;
    }

    /* Here we make some if the tiles different size */
    /* to see the effect of the grid layout */
    .box:is(:nth-child(2), :nth-child(8), :nth-child(10)) {
        grid-column: span 2;
        grid-row: span 1;
    }

    .box:is(:nth-child(3), :nth-child(7), :nth-child(13)) {
        grid-column: span 2;
        grid-row: span 2;
    }
</style>
<body>
<!--    Spawn multiple boxes -->
    <div class="container" id="container">
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
        <div class="box"></div>
    </div>
</div>
</body>
<script>
    // Try smaller numbers to see more tilt
    let constrain = 30;
    // the part where mouse movement will be taken into account
    // replace with 'body' to consider the whole body of the webpage
    let mouseOverContainer = document.getElementById("container");
    // select all our boxes
    let boxes = document.getElementsByClassName("box");

    function transforms(x, y, el) {
        let box = el.getBoundingClientRect();
        let calcX = -(y - box.y - (box.height / 2)) / constrain;
        let calcY = (x - box.x - (box.width / 2)) / constrain;

        // try smaller perspective for more tilt. (may produce some fun artifacts)
        return "perspective(500px) "
            + "   rotateX("+ calcX +"deg) "
            + "   rotateY("+ calcY +"deg) ";
    }

    function transformElement(el, xyEl) {
        el.style.transform  = transforms.apply(null, xyEl);
    }

    mouseOverContainer.onmousemove = function(e) {
        let xy = [e.clientX, e.clientY];
        window.requestAnimationFrame(function(){
            // Calculate the transform for all our boxes
            for (const box of boxes) {
                let position = xy.concat([box]);
                transformElement(box, position);
            }
        });
    };
</script>
```

## Bonus: making the highlight pop

We can add some more flavour to the layout - the hovered tile can pop out. To do that, we check whether we've hovered a smaller area inside the tile, and if so, we scale it. Simple and effective. To try it out, just replace your transforms function with the one below.

```javascript
function transforms(x, y, el) {
let box = el.getBoundingClientRect();
let calcX = -(y - box.y - (box.height / 2)) / constrain;
let calcY = (x - box.x - (box.width / 2)) / constrain;

        // try smaller perspective for more tilt. (may produce some fun artifacts)
        let transformString = "perspective(500px) "
            + "   rotateX("+ calcX +"deg) "
            + "   rotateY("+ calcY +"deg) ";

        // make the hover area half the tile's bounding box
        const halfBox = {
            left: box.left + box.width / 4,
            right: box.right - box.width / 4,
            top: box.top + box.height / 4,
            bottom: box.bottom - box.height / 4,
        }

        // if the mouse is within the half-BBox, 
        // don't apply the rotation, but scale the tile instead
        if (x >= halfBox.left && x <= halfBox.right
            && y >= halfBox.top && y <= halfBox.bottom) {
            transformString = "   scale(2) "
        }
        return transformString;
    }
```
<iframe loading="lazy" title="The final result with tiles enlarging on hover" src="/assets/index-advanced.html" height="500px" width="100%" style="border:none;"></iframe>
<figcaption align = "center">The final result</figcaption>

## The end (that was fast)

Thanks for reading this quick post. Now that you are a cool kid, tweet (X?) me your best Bento grid <a class="external" href="https://x.com/devslovecoffee" target="_blank">@devslovecoffee</a>. 

Don't forget to check out my other posts and projects ☕.

