tDiary -- How to write diary
============================

Index
-----

  - Format of the diary in tDiary
  - Tips

Format of the diary in tDiary
-----------------------------

Basically, you write your diary in HTML. But, the format of the diary has extra rules in order to write your diary without knowledge of HTML. In this format, a linefeed and a character at the beginning of the line have special meanings. These rules are for the purpose of setting sub-title and paragraph easily.

The rules are explained below. To distinguish a linefeed in appearance(HTML) from an actual linefeed(format), "$" stands for an actual linefeed in this manual.

```
sub-title(1)$ Like the above, the first line becomes a sub-title. With the tDiary's standard style sheet, the sub-title is displayed in bold face. Lines from the sub-title to the next space line are called section, and a section anchor is added in front of the sub-title. $ Lines after the sub-title, like this line and the line just above, are recognized as normal lines. If a paragraph begins with a sub-title, a section anchor is not attached in front of normal lines.$ $ If a space line exists, the line means the separation of the sections. If space exists in front of the line like this line, the section doesn't have a sub-title. In addition, only the first paragraph has a section anchor. In this case, the line is not shown in bold face.$ If a section doesn't begin with a sub-title, the second and later paragraphs don't have an anchor.$ $
```
$ If the paragraph begins with a line whose first character is "$ $ sub-title(2)$ As the result of it, you can't add a sub-title which begins with a HTML tag to a section. But if a line begins with "_This example is formatted below._

[2001-08-03](./?date=20010803)title
-----

### [_](./?date=20010803#p01)sub-title(1)

 Like the above, the first line becomes a sub-title. With the tDiary's standard style sheet, the sub-title is displayed in bold face. Lines from the sub-title to the next space line are called section, and a section anchor is added in front of the sub-title.

 Lines after the sub-title, like this line and the line just above, are recognized as normal lines. If a paragraph begins with a sub-title, a section anchor is not attached in front of normal lines.

[_](./?date=20010803#p02) If a space line exists, the line means the separation of the sections. If space exists in front of the line like this line, the section doesn't have a sub-title. In addition, only the first paragraph has a section anchor. In this case, the line is not shown in bold face.

 If a section doesn't begin with a sub-title, the second or later paragraphs don't have an anchor.

```
 If the paragraph begins with a line whose first character is "
### [_](./?date=20010803#p04)[sub-title(2)](foobar)

As the result of it, you can't add a sub-title which begins with a HTML tag to a section. But if a line begins with "

```
In tDiary, users can write their diary without HTML if they don't need to decorate their diary. At the same time, users who are familiar to HTML can write full functions of HTML in their diaries. But, If you use HTML tags in your diary, it is better to read the next section, Tips, to avoid pitfalls of tDiary.

Tips
----

### want a section to include a line which has a tag.

For example, you want to use

tag in your diary in order to use a list and don't want to change a section. Like this case, if you want to decorate the whole paragraph with html tags, you need to use a trick in tDiary. For instance, you hope that your diary is formatted like the next example.
[2001-08-29](./?date=20010830)
----------

### [\_](./?date=20010829#p01)sub title

Like this, you write a list which has two items.
    - item1
    - item2
Here is in the same sectionOne way is to merge a paragraph with the previous paragraph. Ordinarily, a paragraph is enclosed by -tag(you can confirm it if you read the HTML source created by tDiary.). You take advantage of this.

```
sub-title Like this, you write a list which has two items.
```

  - item1
  - item2

 Here is in the same section$

It is the point not to put a linefeed. This way is usable if a paragraph enclosed by a tag is not composed of plural lines. But, this is a little difficult to read.

In the way above, you take advantage of the fact that a paragraph is enclosed by

 in tDiary. On the contrary, another way is to take advantage of the fact that

 tag is not inserted to a section if the section has a line which begin with a tag. In the next example, tDiary insert no tag into a section because the section has a line which begins with "-

, except a list.
```
sub title$ Like this, you write a list which has two items.

$
```

$   - item1
$   - item2
$
$  Here is in the same section.

$This way is suitable if a paragraph enclosed by tags is plural. For example, you insert source code with

```
 tag.Of course, if you don't mind the fact that the sections are split, you are not bothered with formatting. In this case, it may be better to write like the next example.

```
sub title$ Like this, you write a list which has two items.$ $
```

```

$   - item1
$   - item2
$
$ $ Here is in the same section.$The last line, "Here ...", has a section anchor, but this is not a big problem.

### You want to insert an anchor per paragraph, not section

tDiary is developed under the policy that it is not necessary to insert an anchor to a paragraph. So, basically, you can't insert an anchor to a paragraph. But, you can insert an anchor to a section in appearance if you utilize the fact that we can make a section without a sub-title. Please read the next example.

```
sub-title(2)$ $ Like this, you put a space line under the sub-title and make a section to begin with space. This makes two sections. The first section has only the sub-title. The second section has only the paragraph. $ $ If you insert a space line to every paragraph, every paragraph has an anchor.$ $ sub-title(2)$ $ Please be careful that a line which doesn't begin with space becomes a sub-title.$
```
This example is displayed like this. It is the point that a line begins with space.

[2001-08-30](./?date=20010830)
----------

### [\_](./?date=20010830#p01)sub-title(1)

[\_](./?date=20010830#p02)Like this, you put a space line under the sub-title and make a section to begin with space. This makes two sections. The first section has only the sub-title. The second section has only the paragraph.

[\_](./?date=20010830#p03)If you insert a space line to every paragraph, every paragraph has an anchor.

### [\_](./?date=20010830#p04)sub-title(2)

[\_](./?date=20010830#p04)Please be careful that a line which doesn't begin with space becomes a sub-title.

```

```
