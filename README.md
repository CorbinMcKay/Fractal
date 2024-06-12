### Geometric Fractal Zoom ###

![myPic](https://github.com/CorbinMcKay/Fractal/assets/133295104/bf3e79be-e9a9-4cf8-8a37-c7c6c367dbdb)

For this project, I created a fractal image using 75k polygons. Each generation of a polygon consists of motion, rotation, scaling, change in color (h s v values), branching and random
number values to potentially change the branching direction of the polygons. World to screen scaling is applied and the polygon is drawn. A random seed is set to maintain the 
same fractal image. Since each generated polygon is scaled down, and there is 75k polygons, the smallest polygon is the image is less than 1.0e-12 across. As the polygons increase
in size, the move away from the center; As the polygons reduce in size, the move towards the center. 

After created the initial fractal image, a zoom function is used to iteratively zoom towards to smallest polygon until we reach this polygon. For each iteration of the zoom, a png
file is saved. Since the target is 600 images to create the video with, I zoomed by a scale of 0.88125. In this function, all scaling and coordinates are are adjusted using the 
zoom value and interation number, then the image is recreated using these values. After running the code, 600 images are saved, which I then used to create a fractal zoom video. 

An intential/inevitable bug the entire class encountered in this project was the issue of the background color changing, causing rapid flashing of color in the video. This occured because racket does not do
well with handling large shapes. As I encountered this bug, I noticed the flashing background colors matched my polygons wheel of colors. The conclusion I reached was that either the polygons increase to a certain
large size to where they are suddenly capable of overlapping the screen coordinates (and are drawn before smalled polygons, thus it overlaps the drawn background), or is an issue with overflow. Thus I could eliminate any potential issues
with the drawn background color value, as it still existed and was correct, but was being overlapped. 
The solution I found was to create a function to get the length and width of a polygon and then to call it inside of my function where I create each fractal image. For each polygon to be drawn, I evaluate the size and once a polygon reaches
a size to where it is large and outside of the screen coordinates, the polygon will not be drawn. This fixed both the bug and improved efficiency as thousands of polygons that scale and rotate outside of the screen view
do not need to be drawn as they do not contribute anymore to the image. I was one of four students in my class to solve this bug, which was one of my proudest moments in school as a software developer. It was a fun challenge
and I am happy the professor included a curveball with no warning. 

The main inspiration for this fractal was rainbow road. I wanted to feel like I was traveling down a rainbow road esque void in space. After much tinkering, I was able to find a mathematical change in hsv to reach this goal and I am so happy with the end result!

Link to the full fractal zoom video: https://www.youtube.com/watch?v=tLx-qVBrcXE&ab_channel=CorbinMcKay

See preview video below: 

https://github.com/CorbinMcKay/Fractal/assets/133295104/88aee4ca-bbe6-4ac3-a1fe-0870c2e0b510


