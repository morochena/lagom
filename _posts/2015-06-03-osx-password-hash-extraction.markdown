---
layout: post
title:  "OSX Password Hash Extraction"
date:   "2015-06-03"
description: "How to extract user password hashes from OSX"
categories: osx security
published: false
---

A couple weeks ago my friend locked himself out of his Macbook. We were able to recover his password (which we knew was only off by a character or two) by getting his password hash and cracking it. I found the process interesting so I thought I'd document it.

Users of Mac OSX are able to encrypt their data with the FileVault utility. They have several options that have changed over the years. From OSX 10.4 onwards, one of the options available was the ability for users to encrypt their home directories with 128-bit AES encryption. The encrypted files are contained in a ‘sparsebundle’ file.

The sparsebundle file is actually a directory that grows incrementally with 8MiB ‘band’ files as the user populates their home directory with data (this is to help reduce file diffs for backups). In order to access the data contained in the sparsebundle files, you need the user’s password. To get that, you need to grab the hash of the users password that you want to retrieve.

Depending on the version of OSX there are two different methods to retrieve the hash, which I’ve listed below.

# Extracting OSX 10.4 - 10.6 Password Hash ###

First you must deteremine the users’s GUID by inspecting the `<useraccount>.plist` file in the `/private/var/db/dslocal/nodes/Default/users/` directory. It will be the string contained in the `generateduid` field, eg:

``` xml
<key>generateduid</key>
<array>
  <string>1273D233-11C3-4979-A877-06D4420B563B</string>
</array>
```

Once you have the GUID, you can open the corresponding file for the user at `/private/var/db/shadow/hashes/<GUID>`. Here, at offset 168 is a 48 byte SHA1 salted hash. 

# Extracting OSX 10.7+ Password Hash ###

The SHA512 hash is stored directly in the `/private/var/db/dslocal/nodes/Default/users/<username>.plist` file. You should extract the plist file elsewhere, and then convert it to xml from its binary format. The easiest way to do this is with the BSD plutil command: `plutil -convert xml1 <username>.plist`. Now when you open the file and scroll down a bit you should see some data in the ShadowHashData field, something like this:

``` xml
<key>ShadowHashData</key>
<array>
  <data>
    YnBsaXN0MDDSAQIDCl8MHlNSUC1SRkM1MDU0LTQwOTYtU0hBNTEyLVBCS0RG
    Ml8QFFNBTFRFRC1TSEE1MTItUEJLREYy0wQFBgcICVh2ZXJpZmllclRzGWx0
    Wml0ZXJhdGlvbnNPEQIAjH4FqmzsayNmSe9n6+Gd1vtrGCNvjFq3Wz0HSZnx
    v459DJPN3/98uJkhlGLjair4k4CMqoox9XembfAT/L9qhAJ6fhM8pZjxuOSp
    l7TIgahKoeAPVr9CvatRLU/pNPEcNJOrVhloRdRj2lQ7XVfKUKobTndMx7pR
    /8e0qExjYLrV7P4GZsk4plBGx6+duYVPjTAU9P5aGTBdqw76wnhNe2Zaem5v
    zPx824Dq9tQW08JJLRmMhkldUG4nmLuFoOO+3vbzK3cuWsYP3AkjgDOklHNg
    7D5NciuSJX75xAI/dxgkrnEqI89U3eZsj5h4y6606RnideyFi3E4WT+T6su6
    XRcb2uKZwoksNm2QFoqOA2AQElFYRad57VE1l4PSZC/oTRQoGtq5Y8prEYEu
    PG16YlISqNtk5OSai4J+UC++KVQz9uKpxS2nCgIDkjYhThmBKxbts3OioMCA
    PlpafYVCxTh+L+AnhpVs1FLbcpGAkZd3L3pUoe1H1gFxHjFNjQzF+gogXwvQ
    qJp7Ws6uw7HUOisUqPiT6B7ucdvIbpVE4EAn9F3ZQJuRIyyRM/cyTcZ/zkh+
    rZTSCmhmeyEOS8ocsQPaD+0NbFhMCHu5dlczIcUZjlZdwSWsXirLWB6b5wW8
    P2zpN5738ZgCNY2N+mY40J2gZHqqgTf2ZR9unO682SFPECA9Q3SBRHwyCjMu
    OJe4YW4BXpJZA0fefD8C/cLzMl5BnBFoudMLBQYMDQ5XZW50cm9weU8QgHOx
    0zsN/rnUqrlqy1oO2lR73pPsDaXRqsnZkx1JwW6I7PLE3JwrIlU6qSLpP44R
    OUr0girWL6d21shNTAhyHZwfcG2wR4d5XZh7Ty0WPaRE46dH3K9owSq3qsxR
    Ux/sXgqX6n7etwU2FjS3GhSNR80S5zTvMYS4HxVpyhTRCYfPTx3gg5Qv4hED
    i2lHXMBYnqxum41GReBgpLwHJIgVYHmPt3YRawUACAANAC4ARQBMAFUAWgBl
    AmkCjAKPApYCngMhA0QAAAAAAAACAQAAAACAAAAPAAAAAAAAAAAAAAAAAAAD
    Rw==
  </data>
 </array>
```

This is base64 encoded, so take the text inside the data field into a text editor, remove the new lines and save it somewhere and then run a command like:

`cat shadowdata.plist | base64 -D > decodedshadowdata.plist`

Once you have that, convert it to xml so you can read it:

`plutil -convert xml1 decodedshadowdata.plist`

Now if you open that up you should see three fields, entropy, salt, and iterations. Extract these to their own files, removing new lines.

Entropy and salt are both base64 encoded, so extract the data from those fields and convert:

`cat entropy.txt| base64 -D > decodedentropy.txt && cat salt.txt | base64 -D > decodedsalt.txt`

Okay, now we need to put everything together to create the hash. It will look like this: `$ml$<iterations>$<salt>$<entropy>`

To get these values, run `xxd -p <filename> | tr -d '\n'` on both decodedentropy.txt and decodedsalt.txt.

Now you have your salted hash. :)