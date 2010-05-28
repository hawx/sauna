# Suana

Sauna is a small forum app written in Ruby and using Sinatra. It runs on Heroku, and probably anything else.
It contains all the usual stuff you'd expect from a forum; members, posts, etc.
Check out the [demo](http://sauna.heroku.com/).

## To Install & Run

To get the forum just clone this project in the directory of your choice.

    git clone git://github.com/hawx/sauna.git

Then to run start the server you normally use, eg.

    thin start -R config.ru

Then navigate to the correct url to see the setup page. Fill this form out and press setup. Done! 
Well you may want to start a discussion as the message says so follow the link, login and create the first discussion. Then just play around and use it like you would a normal forum!

## Avatar Storage

Members can have avatars, these can either be stored on the server or with Amazon S3 (necessary to run on Heroku). To set up Amazon S3 you need to log in and navigate to `/settings`, then just add your credentials in the relevent fields and tick the checkbox.

## Hacking

This was meant to be quite small and simple so it would be easy to hack new features onto, though somewhere along the way it became a little more complex than it should have been. Feel free to fork and improve...

#### For Theming

To change the style of it you only need to venture into `views/`. I've split the templates into different folders based on what they are for. These are the variables you can use (not available in all circumstances, apply common sense), in some cases plurals are used for lists and stuff:

    current_user -> the user who is logged in
    @member(s) -> the member(s)
    @post(s) -> the post(s)
    @discussion(s) -> the discussion(s)
    @comment(s) -> the comment(s)
    @tag(s) -> the tag(s)
    @topic(s) -> the topic(s)

If you want to see what properties each of these have look for the corresponding file in `lib/` and check the properties and methods.