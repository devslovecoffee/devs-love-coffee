---
title: Making the Resend cube from scratch using Three.js
image: /images/img-card-1.png
description: Step-by-Step Replication of the Resend Cube Using Three.js and a Single HTML File. Starting with a boilerplate and adding the cube, making it the correct shape, materials and lightning.
excerpt: An exploration and tutorial on how to make the resend cube from scratch using Three.js.
pubDate: 'Jun 15 2023'
---
<iframe loading="lazy" title="The Resend cube lookalike" src="/assets/resend_cube.html" height="400px" width="100%" style="border:none;"></iframe>
<figcaption align = "center">The final result. Interactive. (code at the end of the post)</figcaption>


4 months ago - on 30th January, I have seen the <a class="external" href="https://resend.com" target="_blank">resend.com</a> webpage with the amazing looking 3D cube. My brain immediately kicked into gear trying to figure out how they did it.

4 months later, their recent launch reminded me of this desire of mine to steal it (Steal like an artist reference, yay!). As I have some experience with Three.js, I went right in.

## Start with a boilerplate

This sets you up with the most basic scene - a single white cube, black background, and standard material on the cube, meaning you should see the shadows and stuff. Pretty neat. You're welcome. (I have actually stolen this and adapted it a bit from <a class="external" href="https://www.3dcodekits.com/simple-boilerplate-code-for-three-js-in-a-single-html-file/" target="_blank">3dcodekits</a>; thanks 3dcodekits, I love you!).

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Resend Cube</title>
    <style>
        body { margin: 0; }
        canvas { display: block; }
    </style>
</head>
<body>
<script src="https://cdn.jsdelivr.net/npm/three@0.142.0/build/three.min.js"></script>
<script>
    // Create the scene
    const scene = new THREE.Scene();
    scene.background = new THREE.Color( 0x000000 );

    // Create the light
    const light = new THREE.DirectionalLight( 0xffffff );
    light.position.set( 0, 0.5, 1 );
    scene.add( light );
    // Create the camera
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);

    // Create the renderer
    const renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);

    // Create a cube
    const geometry = new THREE.BoxGeometry();
    const material = new THREE.MeshStandardMaterial({ color: 0xffffff });
    const cube = new THREE.Mesh(geometry, material);
    scene.add(cube);

    // Position the camera
    camera.position.z = 10;

    // Animate the cube
    function animate() {
        requestAnimationFrame(animate);
        cube.rotation.x += 0.005;
        cube.rotation.y += 0.005;
        renderer.render(scene, camera);
    }
    animate();
</script>
</body>
</html>
```

## Let's make the cube a bit less cuber (more round)

Turns out, three js does not have a direct solution to this. So a quick google search yielded this neat little function (<a class="external" href="https://discourse.threejs.org/t/round-edged-box/1402" target="_blank">source</a>)

```javascript
function createBoxWithRoundedEdges( width, height, depth, radius0, smoothness ) {
    let shape = new THREE.Shape();
    let eps = 0.00001;
    let radius = radius0 - eps;
    shape.absarc( eps, eps, eps, -Math.PI / 2, -Math.PI, true );
    shape.absarc( eps, height -  radius * 2, eps, Math.PI, Math.PI / 2, true );
    shape.absarc( width - radius * 2, height -  radius * 2, eps, Math.PI / 2, 0, true );
    shape.absarc( width - radius * 2, eps, eps, 0, -Math.PI / 2, true );
    let geometry = new THREE.ExtrudeBufferGeometry( shape, {
        amount: depth - radius0 * 2,
        bevelEnabled: true,
        bevelSegments: smoothness * 2,
        steps: 1,
        bevelSize: radius,
        bevelThickness: radius0,
        curveSegments: smoothness
    });

    geometry.center();

    return geometry;
}
```

Calling the function produces a neat little cube with rounded corners. you can tweak how much you would like to have the corners rounded with the 4th parameter - radius0. (don't forget to adjust smoothness as you make the radius larger. You'll see why once you do it)

```javascript
const geometry = createBoxWithRoundedEdges( 1, 1, 1, .06, 20 ); //the smoother the better
```

## Material + Lights

Now we want the cube to feel like the resend one - meaning we need to make it metal and a different light. Metal is easy - we already use standard material, so we just add some metalness and tone down roughness (while we are at it, we change the color to dark grey).

```javascript
const material = new THREE.MeshStandardMaterial({ color: 0x2a2a2a, metalness: 1, roughness: 0.11 });
```

Now the cube is faded a lot - it almost blends into the background, and you occasionally see some flashes. We need to replace the light with a point light and tune it to always light some part of the cube up.

Compared to directional light, which gets emitted in a specific direction (but is quite weak and falling on a side of the cube creates a "flashlight" effect - you see small surface being affected), point light emits light in all directions, which creates a nice effect we can use - the light reflected in the cube will be larger, and always hitting surfaces - edges for even more cool effect. We create quite a large point light capable of lightning a whole side of the cube.

We can also add a second light for the undertones. Placing it below the cube ensures that we always have some part highlighted.

```javascript
// Create the light
const light = new THREE.PointLight( 0xffffff, 100, 500 );
light.position.set( 0, 10, 10 );
scene.add( light );

const light2 = new THREE.PointLight( 0xffffff, 10, 500 );
light2.position.set( 0, -10, -5 );
scene.add( light2 );
```

You can play with the material properties and lights (intensities, colors) to create some cool effects.

## Making baby cubes

Here comes the fun part. We will create another function which will call the rounded edges cube function in some nested loops and make 27 cubes. Let's go.

```javascript
function makeCubes() {
    const material = new THREE.MeshStandardMaterial({ color: 0x1a1a1a, metalness: 1, roughness: 0.18 });
    const numCubes = 3;
    // Create the group, we will add cubes to the group
    const cubes = new THREE.Group();
    // iterate over all dimensions + trick to center the cube
    for (let i = -Math.floor(numCubes / 2); i <= Math.floor(numCubes / 2); i++) {
        for (let j = -Math.floor(numCubes / 2); j <= Math.floor(numCubes / 2); j++) {
            for (let k = -Math.floor(numCubes / 2); k <= Math.floor(numCubes / 2); k++) {
                // adding the cubes
                const geom = createBoxWithRoundedEdges(1, 1, 1, .1, 20);
                geom.translate(i, j, k);
                const cube = new THREE.Mesh(geom, material);
                cubes.add(cube);
            }
        }
    }
    return cubes;
}
```

All we need to do now is call it:

```javascript
// Create a cube
const cube = makeCubes();
scene.add(cube);
```

## Adding controls

As a bonus we can add controls and rotate the cube as we like. If you want to disable the autorotation, just comment away the two `cube.rotation` lines.

First we need to import addons script. Place this line below the three import script.

```html
<script src="https://cdn.jsdelivr.net/npm/three-addons@1.2.0/build/three-addons.min.js"></script>
```

Then we add the controls - you can add it anywhere, for example near the camera = ... line.

```javascript
const controls = new THREE_ADDONS.OrbitControls(camera,renderer.domElement);
```

And finally we edit the animate function which gets called every time something is rendering.

```javascript
// Animate the cube
function animate() {
    requestAnimationFrame(animate);
    cube.rotation.x += 0.005;
    cube.rotation.y -= 0.005;
    controls.update();
    renderer.render(scene, camera);
}
```

Why does the resend cube look better?

1. BLOOM - the glow effect you see coming off the cube is called bloom. In three js it is overly complicated to add (<a class="external" href="https://codepen.io/prisoner849/pen/LYLrawm" target="_blank">example_1</a>, <a class="external" href="https://threejs.org/examples/webgl_postprocessing_unreal_bloom" target="_blank">example_2</a>), and I was just too lazy. I have actually implemented it once in another project which I will perhaps share some other time.
2. The mini cubes are not the same - resend has different geometry with the "squares" that are being extruded into cubes having rounded corners as well. Might be a good exercise for both you and me to try and make some other time.
3. The effect of rotating layer - This looks cool and in theory could be made by always rotating just 1 layer -  right before rotating, you can flip the cube by a before-defined, random transformation turning it on one of the sides. This way you can create the effect that you always rotate a different side.
4. Better lightning - Nailing the lightning is difficult, so I approximated the best I could (I gave it 2 minutes).

I encourage you to add these features and tag me in the results - perhaps on <a class="external" href="https://twitter.com/devslovecoffee" target="_blank">Twitter</a>. Have fun.

Final code:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Resend Cube</title>
    <style>
        body { margin: 0; }
        canvas { display: block; }
    </style>
</head>
<body>

<script src="https://cdn.jsdelivr.net/npm/three@0.142.0/build/three.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three-addons@1.2.0/build/three-addons.min.js"></script>

<script type="module">
    function createBoxWithRoundedEdges( width, height, depth, radius0, smoothness ) {
        let shape = new THREE.Shape();
        let eps = 0.00001;
        let radius = radius0 - eps;
        shape.absarc( eps, eps, eps, -Math.PI / 2, -Math.PI, true );
        shape.absarc( eps, height -  radius * 2, eps, Math.PI, Math.PI / 2, true );
        shape.absarc( width - radius * 2, height -  radius * 2, eps, Math.PI / 2, 0, true );
        shape.absarc( width - radius * 2, eps, eps, 0, -Math.PI / 2, true );
        let geometry = new THREE.ExtrudeBufferGeometry( shape, {
            depth: depth - radius0 * 2,
            bevelEnabled: true,
            bevelSegments: smoothness * 2,
            steps: 1,
            bevelSize: radius,
            bevelThickness: radius0,
            curveSegments: smoothness
        });

        geometry.center();

        return geometry;
    }

    function makeCubes() {
        const material = new THREE.MeshStandardMaterial({ color: 0x2a2a2a, metalness: 1, roughness: 0.11 });
        const numCubes = 3;
        // Create the group, we will add cubes to the group
        const cubes = new THREE.Group();
        // iterate over all dimensions
        for (let i = -Math.floor(numCubes / 2); i <= Math.floor(numCubes / 2); i++) {
            for (let j = -Math.floor(numCubes / 2); j <= Math.floor(numCubes / 2); j++) {
                for (let k = -Math.floor(numCubes / 2); k <= Math.floor(numCubes / 2); k++) {
                    // adding the cubes
                    const geom = createBoxWithRoundedEdges(1, 1, 1, .17, 20);
                    geom.translate(i, j, k);
                    const cube = new THREE.Mesh(geom, material);
                    cubes.add(cube);
                }
            }
        }
        return cubes;
    }

    // Create the scene
    const scene = new THREE.Scene();
    scene.background = new THREE.Color( 0x000000 );

    // Create the light
    const light = new THREE.PointLight( 0xffffff, 100, 500 );
    light.position.set( 0, 5, 10 );
    scene.add( light );
    const light2 = new THREE.PointLight( 0xffffff, 10, 500 );
    light2.position.set( 0, -10, -5 );
    scene.add( light2 );

    // Create the camera
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);

    // Create the renderer
    const renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);

    // Create a cube
    const cube = makeCubes();
    scene.add(cube);

    // Position the camera
    camera.position.z = 10;

    const controls = new THREE_ADDONS.OrbitControls(camera,renderer.domElement);

    // Animate the cube
    function animate() {
        requestAnimationFrame(animate);
        cube.rotation.x += 0.005;
        cube.rotation.y -= 0.005;
        controls.update();
        renderer.render(scene, camera);
    }
    animate();
</script>
</body>
</html>
```

<a class="internal" href="/blog//resend-cube-lookalike-part-2">Part 2 where I add the Bloom and Animation is live here</a>.
<a class="internal" href="/blog/resend-cube-lookalike-part-3">Part 3 where we get as close to the real thing as possible here</a>.