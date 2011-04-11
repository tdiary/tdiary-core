=begin

= tDiary -- How to write diary

== Index

* Format of the diary in tDiary
* Tips 


== Format of the diary in tDiary
Basically, you write your diary in HTML. But, the format of the diary has extra rules in order to write your diary without knowledge of HTML. In this format, a linefeed and a character at the beginning of the line have special meanings. These rules are for the purpose of setting sub-title and paragraph easily.

The rules are explained below. To distinguish a linefeed in appearance(HTML) from an actual linefeed(format), "$" stands for an actual linefeed in this manual.


  sub-title(1)$
  Like the above, the first line becomes a sub-title. 
  With the tDiary's standard style sheet, the sub-title is displayed in bold face. 
  Lines from the sub-title to the next space line are called section, 
  and a section anchor is added in front of the sub-title. $
  Lines after the sub-title, like this line and the line just above, are 
  recognized as normal lines. If a paragraph begins with a sub-title, 
  a section anchor is not attached in front of normal lines.$
  $
    If a space line exists, the line means the separation of the sections. 
  If space exists in front of the line like this line, 
  the section doesn't have a sub-title. In addition, only the first paragraph 
  has a section anchor. In this case, the line is not shown in bold face.$
    If a section doesn't begin with a sub-title, the second and
  later paragraphs don't have an anchor.$
  $
  <pre>$
  If the paragraph begins with a line whose first character is "<", $
  the whole section is not formatted. $
  The lines from the beginning of the section to the next space line, 
  in other words, to the next section, is shown as it is. $
  This feature is convenient if you want to use 
  HTML tags, for example, list or table. $
  This section doesn't have a section anchor. $
  </pre>$
  $
  <<a href="foobar">sub-title(2)</a>$
  As the result of it, you can't add a sub-title which begins with a HTML tag 
  to a section. But if a line begins with "<<" like the line above, 
  the line is also recognized as a sub-title.$
  $

((* This example is formatted below.*)) 

<<< result

In tDiary, users can write their diary without HTML if they don't need to 
decorate their diary. At the same time, users who are familiar to HTML can 
write full functions of HTML in their diaries. But, If you use HTML tags in your 
diary, it is better to read the next section, Tips, to avoid pitfalls of 
tDiary.

== Tips

=== want a section to include a line which has a tag.
For example, you want to use <ul> tag in your diary in order to use a list 
and don't want to change a section. Like this case, if you want to decorate 
the whole paragraph with html tags, you need to use a trick in tDiary. 
For instance, you hope that your diary is formatted like the next example.


<<< example1


One way is to merge a paragraph with the previous paragraph. Ordinarily, 
a paragraph is enclosed by <p>-</p> tag(you can confirm it if you read the HTML source
created by tDiary.). You take advantage of this.


  sub-title
  Like this, you write a list which has two items. </p><ul><li>item1</li>
  <li>item2</li></ul><p> Here is in the same section$


It is the point not to put a linefeed. This way is usable if  
a paragraph enclosed by a tag is not composed of plural lines.
But, this is a little difficult to read.

In the way above, you take advantage of the fact that a paragraph is 
enclosed by <p> in tDiary. On the contrary, another way is to take 
advantage of the fact that <p> tag is not inserted to a section if 
the section has a line which begin with a tag. In the next example,
tDiary insert no tag into a section because the section has a line 
which begins with "<". And, normal lines are enclosed by <p>-</p>, except a list.

  sub title$
  <p>Like this, you write a list which has two items.</p>$
  <ul>$
  <li>item1</li>$
  <li>item2</li>$
  </ul>$
  <p> Here is in the same section.</p>$


This way is suitable if a paragraph enclosed by tags is plural. For example, 
you insert source code with <pre> tag.

Of course, if you don't mind the fact that the sections are split, 
you are not bothered with formatting.
In this case, it may be better to write like the next example.

  sub title$
   Like this, you write a list which has two items.$
  $
  <ul>$
  <li>item1</li>$
  <li>item2</li>$
  </ul>$
  $
  Here is in the same section.$

The last line, "Here ...", has a section anchor, but this is not a big problem.

=== You want to insert an anchor per paragraph, not section
tDiary is developed under the policy that it is not necessary to insert an anchor to 
a paragraph. So, basically, you can't insert an anchor to a paragraph. 
But, you can insert an anchor to a section in appearance if you utilize the fact
that we can make a section without a sub-title. Please read the next example.


  sub-title(2)$
  $
   Like this, you put a space line under the sub-title and make a section
  to begin with space. This makes two sections. The first section has 
  only the sub-title. The second section has only the paragraph. $
  $
   If you insert a space line to every paragraph, every paragraph has an anchor.$
  $
  sub-title(2)$
  $
   Please be careful that a line which doesn't begin with space becomes a sub-title.$


This example is displayed like this. It is the point that a line begins with space.


<<< example2


=end

