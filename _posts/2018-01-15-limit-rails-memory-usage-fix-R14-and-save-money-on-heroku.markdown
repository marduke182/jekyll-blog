---
layout: post
title: Reduce Rails Memory Usage, Fix R14 and Save Money on Heroku
head_title: Reduce Rails Memory Usage, Fix R14, Save Money on Heroku [4 Tips]
date: 2018-01-15T10:00:25+01:00
summary: In theory, you can run both Rails web server and Sidekiq process on one 512mb Heroku dyno. For side projects with small traffic, saving $7/month always comes in handy. Unfortunately when trying to fit two Ruby processes on one dyno you can run into memory issues. In this post, I will explain how you can limit memory usage in Rails apps.
last_modified_at: 2018-02-07T20:10:10+01:00
preview_image: pig-represents-saving-money-on-heroku.jpg
keywords: ruby, rails, memory, heroku, save money, startup, optimization, full stack, r14 error
prev_amp:
  url: productive-laziness-optimize-your-shell-workflow
  title: Productive Laziness - Optimize your Shell Workflow
next_amp:
  url: setup-multiple-domains-with-free-ssl-from-cloudflare
  title: Multiple Domains with Free Wildcard SSL from Cloudflare
---

{% asset pig-represents-saving-money-on-heroku.jpg class="center-image post-main-image" alt="Reduce costs on Heroku, represented by a pig image" !width !height %}

In theory, you can run both Rails web server and Sidekiq process on one 512mb Heroku dyno. For side projects with small traffic, saving $7/month always comes in handy. Unfortunately when trying to fit two Ruby processes on one dyno you can run into memory issues. In this post, I will explain how you can reduce memory usage in Rails apps.

Recently, I read a [great article](https://bilalbudhani.com/running-sidekiq-on-heroku-free-dyno/){: target="_blank"} by Bilal Budhani explaining how to run Sidekiq process alongside Puma on one Heroku dyno. After applying it to [one of my side projects](https://wishlist.apki.io){: target="_blank"}, I started running into those dreaded R14 errors.

{% asset R14_error.png class="center-image" alt="Heroku R14 - Memory Quota Exceeded in Ruby errors" !width !height %}

<span class='annotation'>Memory usage spiked followed by a bunch of memory errors and automatic restart</span>

I did some digging and, after a couple of optimizations memory usage charts started looking like this:

{% asset R14_fixed.png class="center-image" alt="Heroku R14 - Memory Quota Exceeded in Ruby fixed" !width !height %}

<span class='annotation'>Stable memory usage followed by garbage collection</span>

Here's what I did:

## Put your Gemfile on a diet

_There is a Gem for that..._ In the Ruby world, dropping in a Gem to solve a problem is usually the _"easiest"_ solution. Apart from other costs, memory bloat is one that can easily get overlooked.

The best way to check how much memory each of your gems consumes is to use [derailed benchmarks](https://github.com/schneems/derailed_benchmarks){: target="_blank"}. Just add:


{% highlight ruby lineanchors %}
gem 'derailed_benchmarks', group: :development
{% endhighlight %}

to your `Gemfile` and run `bundle exec derailed bundle:mem`.

My project powers [Twitter](https://twitter.com/apps_wishlist){: target="_blank"} and [Facebook](https://www.facebook.com/SmartWishlistiOS/){: target="_blank"} bot profiles. I was surprised to find out that a popular [twitter](https://github.com/sferik/twitter){: .link target="_blank"} gem uses over `13 MB` of memory on startup. First I replaced it with its lightweight alternative [grackle](https://github.com/hayesdavis/grackle){: target="_blank"} (`~1 MB`) and finally ended up writing a custom code making a HTTP call to Twitter API. I also managed to get rid of [koala](https://github.com/arsduo/koala){: target="_blank"} gem (`~2 MB`) in the same way.

Another quick win was replacing [gon](https://github.com/gazay/gon){: target="_blank"} gem (`~6 MB`) with custom JavaScript data attributes.

Importing a couple of MBs worth of gem files to simplify making one HTTP call or preventing writing a couple of JavaScript lines should definitely be avoided.

## Use jemalloc to reduce Rails memory usage

[jemalloc](http://jemalloc.net/) is an alternative to official MRI memory allocator. On Heroku, you can add jemalloc using a [buildpack](https://github.com/gaffneyc/heroku-buildpack-jemalloc){: .link target="_blank"}. For my app, it resulted in ~20% memory usage decrease. Just make sure to test your app with jemalloc thoroughly on a staging environment before deploying it to production.

## Limit concurrency and workers

For a side project with limited traffic you probably don't need a lot of throughput anyway. You can limit memory usage by reducing Sidekiq and Puma workers and threads count. Here's my `config/puma.rb` file:

{% highlight ruby lineanchors %}
threads_count = 1
threads threads_count, threads_count
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "production" }
workers 1

preload_app!

on_worker_boot do
  @sidekiq_pid ||= spawn('bundle exec sidekiq -t 1')
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

on_restart do
  Sidekiq.redis.shutdown { |conn| conn.close }
end

plugin :tmp_restart
{% endhighlight %}

and `config/sidekiq.yml`:

{% highlight yaml lineanchors %}
---
:concurrency: 1
:queues:
  - default
  - [critical, 100]
{% endhighlight %}

Although we specify 1 as the max number of threads, Puma can [spawn up to 7 threads](https://github.com/puma/puma#thread-pool){: target="_blank"}. With those minimal settings, [Smart Wishlist](http://wishlist.apki.io/){: target="_blank"} is still able to process around 100k Sidekiq jobs daily and serve both React frontend and mobile JSON API.

## Optimize JSON parsing

All those Sidekiq jobs are necessary to download up to date prices from iTunes API (requests batching is on my TODO list) and send push notifications about discounts. This means there's quite a lot of JSON parsing going on there. There is an oneline fix which can help optimize both memory usage and performance in such cases:

{% highlight ruby lineanchors %}
gem 'yajl-ruby', require: 'yajl/json_gem'
{% endhighlight %}

[yaji-ruby](https://github.com/brianmario/yajl-ruby){: target="_blank"} offers a JSON gem Compatibility API, which hooks into `JSON.parse` calls, improving their performance and memory usage.

## Summary

Working in constrained environments is a great way to flex your programming muscles and discover new optimization techniques. In theory, you could always solve memory issues by throwing more money at your servers, but why not keep those $7 instead?

Check out my other blog post for more tips on how to [improve performance and reduce memory usage of Rails apps]({{ site.url }}/2018/02/05/optimize-rails-performance-bottleneck-with-caching-and-rack-middleware/).

