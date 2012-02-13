## About this repo

This is the basic infraestructure to build the standalone favmonster web client.

## Flow

Add your `cofee`s or `js`s to `application.js`, your `sass`s or `css`s to `application.css`, run `bundle exec shotgun server.rb` to initalize the sinatra app that will precompile and serve everything nicely. The main HTML file is in `views/index.haml`. Don't spect to see many more files here, because the idea is to move to the javascript files as much as possible.

## Embbeded Haml Templates

We are **not** using `ECO` any more. I prefer to write my layouts in a haml-style syntax. And I don't think that putting logic inside the javascript templates is a good idea...

As a way to solve the how-in-hell-I-put-haml-in-my-javascrip problem, I just hacked a little wraper around Haml that generates javascript strings with a mechanism similar to the JST's: just put your markup in a file ending with '.js.ehaml' and it will be magically available to you inside the global singleton `T`. The name of the template inside `T` will be the relative path to your template file (the same way JST does it). So, for example, the haml written in `/assets/javascripts/templates/something/template1.js.ehaml` will be avaiable in `T['templates/something/template1'] as a javasript string.
