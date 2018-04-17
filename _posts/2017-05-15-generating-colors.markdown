---
layout: post
title:  "Generating Unique Colors Programmatically"
date:   "2017-05-15"
categories: ruby colors
---

A few months ago I wanted to generate a unique color based on a set of values (in my case, a set of eight integers). It would be easy enough to create a hash function that maps to hex values or something similar, but I had the added constraint of wanting similar values to generate similar colors. To give this context - I had 'palate data' from several whiskies, and wanted to give each whisky a color. If two whiskies were similar in taste, I also wanted them to be similar in color. I wanted to be able to look at the generated color of the whisky and have a general idea of what it would taste like.

The inherent issue was that I was attempting to compress eight dimensions into two, so ultimately I wasn't 100% successful. However, I ended up with something I liked, so I thought I'd document the process I went through.

First of all, here's some data:

| name          | floral | fresh fruit | dried fruit | malt & honey | rich fruit | peaty | briney | woody |
| ------------- | ------ | ----------- | ----------- | ------------ | ---------- | ----- | ------ | ----- |
| **laphroaig** | 1      | 1           | 1           | 2            | 2          | 5     | 3      | 1     |
| **lagavulin** | 1      | 1           | 3           | 2            | 2          | 4     | 3      | 3     |
| **yamazaki**  | 3      | 3           | 4           | 4            | 3          | 2     | 2      | 3     |
| **glenlivet** | 4      | 4           | 2           | 2            | 2          | 1     | 1      | 3     |

With this paired comparison analysis table can see that Laphroaig and Lagavulin are pretty similar, so ideally they would be close to the same color.

|           | laphroaig | lagavulin | yamazaki | glenlivet |
| --------- | --------- | --------- | -------- | --------- |
| laphroaig | 0         | 5         | 16       | 15        |
| lagavulin | 5         | 0         | 11       | 12        |
| yamazaki  | 16        | 11        | 0        | 9         |
| glenlivet | 15        | 12        | 9        | 0         |

# Naive Approach - RGB Mean Method

The first idea I had was that you could map the values to RGB by giving each flavor a color value, then scale it by the strength of the flavor, and then find the mean all of the R, G and B values and use that as your unique color.

So I assigned each flavor an arbitrary (but unique) RGB value like this:

```javascript
var colors = [
  [255, 204, 51], // floral
  [207, 64, 232], // fresh fruit / vanilla
  [255, 87, 42], // dried fruit / nutty
  [30, 232, 183], // malt & honey
  [185, 255, 36], // rich fruit / spicy
  [71, 82, 232], // peaty
  [90, 204, 232], // briney
  [232, 120, 140]
]; // woody
```

After that, I scaled `colors` by their flavor values of a whisky (1 to 5) to create another two-dimensional array of RGB values.

```javascript
var flavors = [1, 1, 3, 2, 2, 4, 3, 3]; // lagavulin

function scaleRGB(val, rgb) {
  return rgb.map(e => e / 5 * val);
}

var scaledColors = flavors.map((e, index) => scaleRGB(e, colors[index]));
/*
 [[51, 40.8, 10.2], 
  [41.4, 12.8, 46.4], 
  [153, 52.199999999999996, 25.200000000000003], 
  [12, 92.8, 73.2], 
  [74, 102, 14.4], 
  [56.8, 65.6, 185.6], 
  [54, 122.39999999999999, 139.2], 
  [139.2, 72, 84]]
 */
```

Now that you have the scaled values you can just find the mean of all eight:

```javascript
var summedColors = scaledColors.reduce(
  (sum, e) => {
    return sum.map((v, index) => v + e[index]);
  },
  [0, 0, 0]
);

var averagedColors = summedColors.map(e => Math.round(e / 8));

/* 
[73, 70, 72]
*/
```

Which you can then use as you R, G and B values. When you apply that to the whiskies above, you get the following:

![Lagavulin](/assets/images/lagavulin.png)
![Laphroaig](/assets/images/laphroaig.png)
![Yamazaki](/assets/images/yamazaki.png)
![Glenlivet](/assets/images/glenlivet.png)

While you do get unique colors, you can see there are a couple problems with this approach. Because RGB is additive, you can get a lot of whiskies that are too dark or too light. Also they have a tendency to all be in a brown range due to the way the colors mix.

# Slightly Less Naive Approach - LAB Mean Method

I realized that RGB probably wasn't the best choice at this point, so I decided to look at other color spaces to see if one would fit my needs better.

I decided to go with [LAB Space](https://en.wikipedia.org/wiki/Lab_color_space)

Like RGB, LAB also uses three numerical values to determine color. However the three values are lightness, green/red, and blue/yellow. This is good because it allows us to easily choose very hue values while keeping the lightness value consistent.

![LAB Color Space](/assets/images/cie-lab.jpeg)

My strategy was to use a vector for each flavor, with the magnitude scaled to the strength of each.

An easier way to think about it would plotting a radar chart onto a color wheel, and then taking the average of the points.

![Lagavulin](/assets/images/lagavulin2.png)
![Laphroaig](/assets/images/laphroaig2.png)
![Yamazaki](/assets/images/yamazaki2.png)
![Glenlivet](/assets/images/glenlivet2.png)

Unfortunately, there are still a few issues with this method. Two strong flavors that surround another can increase its value - even if it doesn't have that flavor at all.

# Even Slightly Less Naive Approach - Space Filling Curve Method

* Hilbert Curve
* Z-Order Curve
