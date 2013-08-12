re:ACT
=====
re:ACT is our (Harry, Rob, Vesko, James & Ruben) project for [Young Rewired State 2013](http://www.youngrewiredstate.org).

About
-----
re:ACT aims to get people more interested in politics and make them more informed on the bills and legislation that are currently going through Parliament by making it more accessible for you to view.

re:ACT is split into three main elements; Bill View, Progress and Vote.

Bill View could best be described as a Google Reader (RIP) but for Political Bills and Legislation. The site is beautifully presented and easy to navigate. Using the Bing Images API, each bill or legislation is matched up with a cover photo to represent it. By hovering over the bill, you're given a brief summary of the bill in plain english to eliminate all the governmental jargon.

Progress allows you to track the bill or legislation as it goes from idea to think tank to the House of Lords to Law. The bar will show what stage the bill or legislation is currently at as well as a timeline that highlight key events in its life. Whether it be the Prime Minister making a quote about it in the news, to a mass protest for or against it, to a debate in the House of Commons, re:ACT will tell you about it.

Vote gives you the chance to feel like a Lord by voting on the bill or legislation as if they we're the one choosing its fate. From there, you can see how other people around the country have voted and if they agree with your decision or not. If it voted upon in Parliament, you can then also find out how your local MP or any other MP voted thanks to the Public Whip API.

re:ACT opens up Parliament to everyone. Whether you already follow Politics or have little to no interest, re:ACT lets you discover bills and legislation that matter to you; and re:ACT to it!

Implementation
--------------
`backend` contains the code for scraping data and interfacing with any APIs we use, and serving up the result in an API. It's a [Grape](https://github.com/intridea/grape) app (Sinatra for APIs), and has a pseudo-rails directory structure.

`docs` contains the [Swagger](https://developers.helloreverb.com/swagger/) files. This is a nice interactive frontend for API documentation, and interfaces with our API using [grape-swagger](https://github.com/tim-vandecasteele/grape-swagger).

`app` contains the bill list page (implemented in PHP), and most static resources on the site. `app_ruby` contains the bill item view page (implemented in Sinatra), and a couple of other frontend assets.

Due to the technologies used, `nginx` is used to handle requests to the site, passing them off to [Puma](http://puma.io/) instances running `app_ruby` and `backend` and a FastCGI instance for the PHP code.

Data
----
We scrape data from parliament.uk ([services](http://services.parliament.uk) and [mps](http://www.parliament.uk/mps-lords-and-offices/mps/)), [PublicWhip](http://www.publicwhip.org.uk/), and also use the downloadable PublicWhip data.

We also make heavy use of the [TheyWorkForYou](http://www.theyworkforyou.com/) API, and use the [Bing Image API](http://www.bing.com/dev/en-us/dev-center) for image search.
