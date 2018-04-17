---
layout: post
date: "2016-10-20T00:00:00+00:00"
title: "Carving Files With Scalpel"
categories: scalpel
---

Recently a friend contacted me because they had accidentally deleted several terabytes of video relating to their work. Because their video camera created videos in a unique format, existing forensic suites & file carvers couldn't extract the videos from his hard drive.

# Getting the file header & footer

The first thing we needed to do was get an example video so we could analyze the header and footer of the file. I asked my friend to come over and shoot some videos with his camera. Once I had the video files, I analyzed them with [xxd](http://linuxcommand.org/man_pages/xxd1.html):

```
$ xxd -l 128 C0001.MP4

    00000000: 0000 001c 6674 7970 5841 5643 0100 1fff  ....ftypXAVC....
    00000010: 5841 5643 6d70 3432 6973 6f32 0000 0094  XAVCmp42iso2....
    00000020: 7575 6964 5052 4f46 21d2 4fce bb88 695c  uuidPROF!.O...i\
    00000030: fac9 c740 0000 0000 0000 0003 0000 0014  ...@............
    00000040: 4650 5246 0000 0000 2000 0000 0000 0000  FPRF.... .......
    00000050: 0000 002c 4150 5246 0000 0000 0000 0002  ...,APRF........
    00000060: 7477 6f73 0000 0000 0000 0000 0000 0600  twos............
    00000070: 0000 0600 0000 bb80 0000 0002 0000 0034  ...............4

$ wc -c C0001.MP4

    28398269

$ xxd -s 28398141 C0001.MP4

    01b1523d: 6374 7572 6572 3d22 536f 6e79 2220 6d6f  cturer="Sony" mo
    01b1524d: 6465 6c4e 616d 653d 2246 4452 2d41 5835  delName="FDR-AX5
    01b1525d: 3322 2073 6572 6961 6c4e 6f3d 2234 3239  3" serialNo="429
    01b1526d: 3439 3637 2a2a 2a22 2f3e 0a09 3c52 6563  4967***"/>..<Rec
    01b1527d: 6f72 6469 6e67 4d6f 6465 2074 7970 653d  ordingMode type=
    01b1528d: 226e 6f72 6d61 6c22 2063 6163 6865 5265  "normal" cacheRe
    01b1529d: 633d 2266 616c 7365 222f 3e0a 3c2f 4e6f  c="false"/>.</No
    01b152ad: 6e52 6561 6c54 696d 654d 6574 613e 0a00  nRealTimeMeta>..

$ xxd -l 128 C0002.MP4

    00000000: 0000 001c 6674 7970 5841 5643 0100 1fff  ....ftypXAVC....
    00000010: 5841 5643 6d70 3432 6973 6f32 0000 0094  XAVCmp42iso2....
    00000020: 7575 6964 5052 4f46 21d2 4fce bb88 695c  uuidPROF!.O...i\
    00000030: fac9 c740 0000 0000 0000 0003 0000 0014  ...@............
    00000040: 4650 5246 0000 0000 2000 0000 0000 0000  FPRF.... .......
    00000050: 0000 002c 4150 5246 0000 0000 0000 0002  ...,APRF........
    00000060: 7477 6f73 0000 0000 0000 0000 0000 0600  twos............
    00000070: 0000 0600 0000 bb80 0000 0002 0000 0034  ...............4

$ wc -c C0002.MP4

    92516001

$ xxd -s 92515873

    0583ae21: 6374 7572 6572 3d22 536f 6e79 2220 6d6f  cturer="Sony" mo
    0583ae31: 6465 6c4e 616d 653d 2246 4452 2d41 5835  delName="FDR-AX5
    0583ae41: 3322 2073 6572 6961 6c4e 6f3d 2234 3239  3" serialNo="429
    0583ae51: 3439 3637 2a2a 2a22 2f3e 0a09 3c52 6563  4967***"/>..<Rec
    0583ae61: 6f72 6469 6e67 4d6f 6465 2074 7970 653d  ordingMode type=
    0583ae71: 226e 6f72 6d61 6c22 2063 6163 6865 5265  "normal" cacheRe
    0583ae81: 633d 2266 616c 7365 222f 3e0a 3c2f 4e6f  c="false"/>.</No
    0583ae91: 6e52 6561 6c54 696d 654d 6574 613e 0a00  nRealTimeMeta>..
```

The good news is that these files had consistent headers, and included a footer.

# Carving with Scalpel

Next, we used a tool called [Scalpel](https://github.com/sleuthkit/scalpel). Essentially it works by scanning data (typically an image of a drive) until it finds a pattern of bytes matching your specification (typically a file header). It marks that spot and continues scanning until one of the follow occurs:
1) it finds another matching set of bytes (another file header)
2) it finds a paired pattern (footer) that you specified alongside the header
3) it reaches a byte limit that you specified

To configure scalpel we create a scalpel.conf with our file type:

```
mp4 n 100000000 \x00\x00\x00\x1c\x66\x74\x79\x70\x58\x41\x56\x43\x01\x00\x1f\xff \x6e\x52\x65\x61\x6c\x54\x69\x6d\x65\x4d\x65\x74\x61\x3e\x0a\x00
```

In order, these columns indicate:

- the extension to give the carved files
- case sensitive (y/n)
- max file size (bytes)
- header
- footer

You can see how the header and footer correspond to sections of output provided by `xxd` above (with `\x` hexadecimal character escapes added).

The reason why I specified the max file size is in case the footer is not found. I set it to 100gb because there were apparently several uncompressed HD videos that were several hours in length.

Now we can run scalpel on our image:

```
$ .\scalpel -c .\scalpel.conf -i E:\disk.01 C:\cases\scalpel-output\
```

# Bonus - More files (without footers)

The above process recovered most of the files, but after consulting with my friend it was indicated that there was another set of videos missing, from an older camera. Upon taking sample video, this was largely the same process except for the fact that these videos did not have footers. Without footers you can't determine the end of the file, but these filetypes generally don't care what data is appended to the end of the file - so the goal is to carve past the end of the file by specifiying a maximum file size. eg. most images will be no larger than 5MB, so specifying a max file size The issue in this case is that my friend indicated there were several high definition videos that were 6-7 hours long - and he didn't have any idea how large the videos were on the drive.


So as before we want to carve with a large maximum file size, this time with no footer.

```
d2ts n 100000000 \x00\x00\x00\x1c\x66\x74\x79\x70\x58\x41\x56\x43\x01\x00\x1f\xff
```

This recovers the files, but they're all 100GB which may be an acceptable size for a data center, but certainly not for my friend.

The solution in this case was to use [Handbrake](https://handbrake.fr/) to re-encode the videos to H.264. This automatically removed any extraneous data while keeping the video intact, maintaining it's original quality.

