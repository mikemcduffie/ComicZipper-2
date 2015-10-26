---
title: Exclude List
group: Settings
order: 2
---

![Exclude List Settings](settings-excludelist.png)

##Exclude non-standard file sand folders

###Exclude metadata files and folders

- Removes Mac and Windows unneeded metadata files (Thumbs.db and \_\_MACOSX)
- See [Glossary](glossary.html) for more details.

###Exclude hidden files and folders

- Removes files and folders beginning with a "." (period/dot) or otherwise marked by the OS as hidden
- Examples include .DS_Store and "AppleDouble" resource files that begin with ".\_") as well ".xvpics" thumbnails from the GIMP image editor.
- See [Glossary](glossary.html) for more details.


###Exclude empty files

- Remove empty (0 byte) files

*Note: ComicZipper already removes all empty subfolders including any subfolders that originally contained only excluded files per the options above and any additional filters below."

###Add filenames (or optionally regular expressions) below to exclude from the comic book archive

- Add simple filename strings for exact name matches of files you want excluded fro the comic book archive
- Add regex strings for more powerful filters. [Read more...](https://en.wikipedia.org/wiki/Regular\_expression) 
- For example the regex string "\\.txt$" would exclude all files ending with the ".txt" extension.
