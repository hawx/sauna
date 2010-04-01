### Suana

Sauna is a small forum app written in Ruby and using Sinatra.


Class Breakdown
---------------
Sauna > Discussion > Post > Comment


Sauna is the container, it also holds all of the options and settings, from setup, etc.

Discussion holds a number of posts, there can be multiple Discussions.

Post is the first post on a certain subject and also contains a number of comments.

Comments are small posts, they can also be replies to other comments with Twitter style syntax.

Each post can have an optional Topic (tag)


- - -
# Naming Convention (draft)

@sauna - (global) holds settings, and global variables like title
@discussion - (only available for pages showing a single discussion) holds the discussion being viewed
@post - (only for pages showing a single post) holds the post being viewed
@comment - (only for pages showing a single comment) holds the comment being viewed
@member - (only for pages showing members) holds the members data

current\_user - (global) holds the logged in user, and if not a GuestUser object is returned


- - -
# Forms

Forms will return items as they are named in the model for the object, but inside a hash of the name of the object, e.g. for Member:

`<input name="member[fname]" />`

This makes it very easy to write the values.
There is also a specific way of making forms, certain classes are also available for styling.
